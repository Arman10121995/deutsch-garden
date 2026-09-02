#!/usr/bin/env python3
"""Generate the optional English civics helper offline at authoring time.

The app never calls a translation service. This tool talks only to an Ollama
instance on 127.0.0.1 while maintaining the repository, then writes the
resulting strings into the bundled asset. It is resumable because the model is
asked for small batches and a completed output file is read before work starts.
"""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
import sys
import time
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
QUESTIONS = ROOT / "assets" / "civics" / "questions.json"
OUTPUT = ROOT / "assets" / "civics" / "translations.json"
OLLAMA_URL = "http://127.0.0.1:11434/api/generate"
MODEL = "llama3.1:8b"


def load_questions() -> list[dict[str, object]]:
    payload = json.loads(QUESTIONS.read_text(encoding="utf-8"))
    questions = payload.get("questions")
    if not isinstance(questions, list):
        raise SystemExit("questions.json has no questions list")
    return [question for question in questions if isinstance(question, dict)]


def load_existing() -> dict[str, dict[str, object]]:
    if not OUTPUT.exists():
        return {}
    try:
        payload = json.loads(OUTPUT.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}
    raw = payload.get("translations", {})
    if not isinstance(raw, dict):
        return {}
    return {
        str(key): value
        for key, value in raw.items()
        if isinstance(value, dict) and valid_translation(value)
    }


def valid_translation(value: dict[str, object]) -> bool:
    question = value.get("question")
    options = value.get("options")
    return (
        isinstance(question, str)
        and bool(question.strip())
        and isinstance(options, list)
        and len(options) == 4
        and all(isinstance(option, str) and option.strip() for option in options)
    )


def prompt_for(batch: list[dict[str, object]], strict: bool = False) -> str:
    records = [
        {
            "id": question.get("id", ""),
            "question": question.get("question", ""),
            "options": question.get("options", []),
        }
        for question in batch
    ]
    extra = (
        "Return every requested id exactly once. Do not add commentary. "
        if strict
        else ""
    )
    return (
        "Translate each German civics question and exactly four answer options "
        "into clear, literal English for a language learner. Keep the same "
        "order and preserve numbers, names, punctuation, and gender-neutral "
        "forms. Do not answer the questions and do not explain anything. "
        "Return only one JSON object with a translations array. Each array "
        "entry must contain id, question, and options. "
        + extra
        + "Input:\n"
        + json.dumps(records, ensure_ascii=False)
    )


def request(prompt: str) -> object:
    body = json.dumps(
        {
            "model": MODEL,
            "prompt": prompt,
            "stream": False,
            "format": "json",
            "options": {"temperature": 0, "num_predict": 1400},
        }
    ).encode("utf-8")
    request_object = urllib.request.Request(
        OLLAMA_URL,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request_object, timeout=240) as response:
        payload = json.loads(response.read().decode("utf-8"))
    text = payload.get("response", "")
    if not isinstance(text, str):
        raise ValueError("Ollama returned no text")
    decoded = json.loads(text)
    return decoded


def parse_batch(decoded: object, expected: list[dict[str, object]]) -> dict[str, dict[str, object]]:
    if not isinstance(decoded, dict):
        raise ValueError("model response is not an object")
    raw = decoded.get("translations")
    if not isinstance(raw, list):
        raise ValueError("model response has no translations array")
    expected_ids = {str(item.get("id", "")) for item in expected}
    found: dict[str, dict[str, object]] = {}
    for item in raw:
        if not isinstance(item, dict):
            raise ValueError("translation entry is not an object")
        item_id = str(item.get("id", ""))
        candidate = {
            "question": item.get("question", ""),
            "options": item.get("options", []),
        }
        if item_id not in expected_ids or not valid_translation(candidate):
            raise ValueError(f"invalid translation entry for {item_id}")
        found[item_id] = candidate
    if set(found) != expected_ids:
        missing = sorted(expected_ids - set(found))
        raise ValueError(f"missing ids: {', '.join(missing)}")
    return found


def write_output(translations: dict[str, dict[str, object]]) -> None:
    payload = {
        "metadata": {
            "purpose": "English learner helper; German catalogue remains authoritative",
            "source": "assets/civics/questions.json",
            "generator": "Ollama " + MODEL,
            "generatedAt": date.today().isoformat(),
        },
        "translations": dict(sorted(translations.items())),
    }
    OUTPUT.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def translate_batch(batch: list[dict[str, object]]) -> dict[str, dict[str, object]]:
    """Translate one batch, falling back to individual requests if needed."""
    try:
        return parse_batch(request(prompt_for(batch)), batch)
    except (OSError, urllib.error.URLError, ValueError, json.JSONDecodeError) as error:
        if len(batch) == 1:
            raise ValueError(f"Failed {batch[0].get('id')}: {error}") from error
        result: dict[str, dict[str, object]] = {}
        for question in batch:
            decoded = request(prompt_for([question], strict=True))
            result.update(parse_batch(decoded, [question]))
        return result


def main() -> int:
    global MODEL
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch-size", type=int, default=12)
    parser.add_argument("--workers", type=int, default=3)
    parser.add_argument("--model", default=MODEL)
    args = parser.parse_args()
    MODEL = args.model
    if args.batch_size < 1 or args.batch_size > 12:
        raise SystemExit("--batch-size must be between 1 and 12")
    if args.workers < 1 or args.workers > 4:
        raise SystemExit("--workers must be between 1 and 4")

    questions = load_questions()
    translations = load_existing()
    pending = [
        question for question in questions if str(question.get("id", "")) not in translations
    ]
    print(f"Loaded {len(questions)} questions; {len(translations)} already translated.")
    batches = [
        pending[start : start + args.batch_size]
        for start in range(0, len(pending), args.batch_size)
    ]
    completed = 0
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {
            executor.submit(translate_batch, batch): batch for batch in batches
        }
        for future in as_completed(futures):
            batch = futures[future]
            try:
                translations.update(future.result())
            except (OSError, urllib.error.URLError, ValueError, json.JSONDecodeError) as error:
                ids = ', '.join(str(item.get('id')) for item in batch)
                print(f"Failed batch ({ids}): {error}", file=sys.stderr)
                return 2
            completed += len(batch)
            write_output(translations)
            print(f"Translated {completed}/{len(pending)} pending.", flush=True)
            time.sleep(0.05)

    if len(translations) != len(questions):
        print(
            f"Only {len(translations)} of {len(questions)} questions translated.",
            file=sys.stderr,
        )
        return 2
    write_output(translations)
    print(f"Wrote {OUTPUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
