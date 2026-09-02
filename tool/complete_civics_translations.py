#!/usr/bin/env python3
"""Complete the bundled civics helper with a cached local translation model.

This is an authoring utility, not application code. It requires a previously
downloaded Hugging Face MarianMT model and uses ``local_files_only=True``; it
never contacts a translation service. Existing entries are preserved so a
maintainer can resume or replace a partial Ollama run without losing work.
"""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
QUESTIONS = ROOT / "assets" / "civics" / "questions.json"
OUTPUT = ROOT / "assets" / "civics" / "translations.json"
DEFAULT_MODEL = (
    Path(r"C:\Users\arkhan\.cache\huggingface\hub")
    / "models--Helsinki-NLP--opus-mt-de-en"
    / "snapshots"
    / "1a922f3b32a8e809e17a47d4b32142d8105924e5"
)


def valid(value: object) -> bool:
    if not isinstance(value, dict):
        return False
    question = value.get("question")
    options = value.get("options")
    return (
        isinstance(question, str)
        and bool(question.strip())
        and isinstance(options, list)
        and len(options) == 4
        and all(isinstance(option, str) and option.strip() for option in options)
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model-path", type=Path, default=DEFAULT_MODEL)
    parser.add_argument("--batch-size", type=int, default=16)
    args = parser.parse_args()
    if args.batch_size < 1 or args.batch_size > 64:
        raise SystemExit("--batch-size must be between 1 and 64")

    from transformers import MarianMTModel, MarianTokenizer

    if not args.model_path.is_dir():
        raise SystemExit(f"cached model not found: {args.model_path}")
    tokenizer = MarianTokenizer.from_pretrained(
        str(args.model_path), local_files_only=True
    )
    model = MarianMTModel.from_pretrained(
        str(args.model_path), local_files_only=True
    )
    model.eval()

    source = json.loads(QUESTIONS.read_text(encoding="utf-8"))
    questions = [item for item in source["questions"] if isinstance(item, dict)]
    current = {}
    if OUTPUT.exists():
        payload = json.loads(OUTPUT.read_text(encoding="utf-8"))
        raw = payload.get("translations", {})
        if isinstance(raw, dict):
            current = {str(key): value for key, value in raw.items() if valid(value)}

    pending = [
        item for item in questions if str(item.get("id", "")) not in current
    ]
    print(f"Loaded {len(questions)} questions; {len(pending)} pending.", flush=True)
    for start in range(0, len(pending), args.batch_size):
        batch = pending[start : start + args.batch_size]
        texts: list[str] = []
        for item in batch:
            texts.append(str(item.get("question", "")))
            texts.extend(str(option) for option in item.get("options", []))
        encoded = tokenizer(
            texts,
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=256,
        )
        generated = model.generate(**encoded, max_new_tokens=96)
        translated = tokenizer.batch_decode(generated, skip_special_tokens=True)
        cursor = 0
        for item in batch:
            item_id = str(item.get("id", ""))
            candidate = {
                "question": translated[cursor].strip(),
                "options": [
                    translated[cursor + offset].strip() for offset in range(1, 5)
                ],
            }
            if not valid(candidate):
                raise SystemExit(f"invalid generated translation for {item_id}")
            current[item_id] = candidate
            cursor += 5

        payload = {
            "metadata": {
                "purpose": "English learner helper; German catalogue remains authoritative",
                "source": "assets/civics/questions.json",
                "generator": "Helsinki-NLP/opus-mt-de-en (local cached model)",
                "generatedAt": date.today().isoformat(),
            },
            "translations": dict(sorted(current.items())),
        }
        OUTPUT.write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(
            f"Translated {min(start + len(batch), len(pending))}/{len(pending)} pending.",
            flush=True,
        )

    if len(current) != len(questions):
        raise SystemExit(f"only {len(current)} of {len(questions)} complete")
    print(f"Wrote {OUTPUT}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
