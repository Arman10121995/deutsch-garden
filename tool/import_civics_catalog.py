#!/usr/bin/env python3
"""Import the official BAMF Leben-in-Deutschland question catalogue.

The app ships the generated output, so end users never need a network
connection.  This importer is deliberately stricter than a downloader: it
cross-checks two independently maintained extractions of the same official
catalogue before replacing the checked-in assets.

Run from the repository root:

    python tool/import_civics_catalog.py

Sources:
* YehorAltshuler/bamf-lid-dataset: validated official text and answer keys.
* vlad-com/leben_in_de (MIT): independent answer-key check and images.

The underlying German questions are official BAMF material.  The catalogue
version imported here is "Stand 07.05.2025".
"""

from __future__ import annotations

import base64
import hashlib
import json
from pathlib import Path
import re
import shutil
import tempfile
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "civics"

VLAD_COMMIT = "303142b7279733ff8c24a12c008e769828166eac"
YEHOR_COMMIT = "8b2ef6a119a4965f13cc5778a532ca18c60fc779"
VLAD_JSON_URL = (
    "https://raw.githubusercontent.com/vlad-com/leben_in_de/"
    f"{VLAD_COMMIT}/fragen.json"
)
VLAD_HTML_URL = (
    "https://raw.githubusercontent.com/vlad-com/leben_in_de/"
    f"{VLAD_COMMIT}/index.html"
)
YEHOR_JSON_URL = (
    "https://raw.githubusercontent.com/YehorAltshuler/bamf-lid-dataset/"
    f"{YEHOR_COMMIT}/data/published/questions.json"
)

OFFICIAL_CATALOG_URL = (
    "https://www.gesetze-im-internet.de/einbtestv/anlage_1.html"
)
OFFICIAL_PDF_URL = (
    "https://www.bamf.de/SharedDocs/Anlagen/DE/Integration/Einbuergerung/"
    "gesamtfragenkatalog-lebenindeutschland.pdf?__blob=publicationFile&v=22"
)

STATES = (
    ("BW", "Baden-Württemberg", "Bundesland Baden-Württemberg"),
    ("BY", "Bayern", "Freistaat Bayern"),
    ("BE", "Berlin", "Bundesland Berlin"),
    ("BB", "Brandenburg", "Bundesland Brandenburg"),
    ("HB", "Bremen", "Freien Hansestadt Bremen"),
    ("HH", "Hamburg", "Hansestadt Hamburg"),
    ("HE", "Hessen", "Bundesland Hessen"),
    ("MV", "Mecklenburg-Vorpommern", "Bundesland Mecklenburg-Vorpommern"),
    ("NI", "Niedersachsen", "Bundesland Niedersachsen"),
    ("NW", "Nordrhein-Westfalen", "Bundesland Nordrhein-Westfalen"),
    ("RP", "Rheinland-Pfalz", "Bundesland Rheinland-Pfalz"),
    ("SL", "Saarland", "Bundesland Saarland"),
    ("SN", "Sachsen", "Freistaat Sachsen"),
    ("ST", "Sachsen-Anhalt", "Bundesland Sachsen-Anhalt"),
    ("SH", "Schleswig-Holstein", "Bundesland Schleswig-Holstein"),
    ("TH", "Thüringen", "Freistaat Thüringen"),
)


def _download_text(url: str) -> str:
    request = Request(url, headers={"User-Agent": "DeutschGarden importer"})
    with urlopen(request, timeout=60) as response:
        return response.read().decode("utf-8")


def _extract_image_map(html: str) -> dict[str, str]:
    match = re.search(r"let imageMap\s*=\s*(\{.*?\});", html, re.DOTALL)
    if not match:
        raise RuntimeError("Could not locate the embedded image map.")
    raw = json.loads(match.group(1))
    if not isinstance(raw, dict) or not raw:
        raise RuntimeError("Embedded image map is empty or malformed.")
    return {str(key): str(value) for key, value in raw.items()}


def _decode_image(data_url: str) -> tuple[bytes, str]:
    match = re.fullmatch(
        r"data:image/(png|jpeg|jpg);base64,([A-Za-z0-9+/=\r\n]+)", data_url
    )
    if not match:
        raise RuntimeError("Unsupported embedded image data URL.")
    extension = "jpg" if match.group(1) in {"jpeg", "jpg"} else "png"
    return base64.b64decode(match.group(2)), extension


def _answers_from_crosscheck(question: dict[str, object]) -> list[str]:
    answers = question.get("answers")
    if not isinstance(answers, dict):
        raise RuntimeError(f"Cross-check question {question.get('id')} has no answers.")
    return [str(answers[key]) for key in ("a", "b", "c", "d")]


def _assert_same_answer_key(primary: dict[str, object], check: dict[str, object]) -> None:
    """Require the two independent sources to agree on the correct choice.

    The MIT mirror has a known PDF line-order defect in question 171, so its
    prose is not canonical. The validated extraction supplies the actual text;
    the mirror remains an independent answer-key check and the licensed image
    source.
    """
    expected = ord(str(check["solution"]).lower()) - ord("a")
    actual = int(primary["correct_answer"]) - 1
    if actual != expected:
        raise RuntimeError(
            f"Answer key differs for {check['id']}: {actual} != {expected}."
        )


def _build_question(
    primary: dict[str, object],
    check: dict[str, object],
    question_id: str,
    scope: str,
    state_code: str | None,
    image_map: dict[str, str],
    image_dir: Path,
) -> dict[str, object]:
    _assert_same_answer_key(primary, check)

    output_images: list[dict[str, object]] = []
    image_names = primary.get("images", [])
    if not isinstance(image_names, list):
        raise RuntimeError(f"Images are malformed for {question_id}.")
    for image_number, source_name in enumerate(image_names, start=1):
        source_name = str(source_name)
        if source_name not in image_map:
            raise RuntimeError(f"Image {source_name!r} is missing for {question_id}.")
        data, extension = _decode_image(image_map[source_name])
        filename = f"{question_id}-{image_number}.{extension}"
        (image_dir / filename).write_bytes(data)
        output_images.append(
            {
                "asset": f"assets/civics/images/{filename}",
                "sha256": hashlib.sha256(data).hexdigest(),
            }
        )

    return {
        "id": question_id,
        "officialNumber": int(check["officialNumber"]),
        "scope": scope,
        "stateCode": state_code,
        "question": str(check["question"]),
        "options": _answers_from_crosscheck(check),
        "correctIndex": ord(str(check["solution"]).lower()) - ord("a"),
        "images": output_images,
    }


def main() -> None:
    primary = json.loads(_download_text(VLAD_JSON_URL))
    crosscheck_root = json.loads(_download_text(YEHOR_JSON_URL))
    image_map = _extract_image_map(_download_text(VLAD_HTML_URL))

    crosscheck_questions = crosscheck_root.get("questions", [])
    crosscheck = {str(item["id"]): item for item in crosscheck_questions}
    if len(crosscheck) != 460:
        raise RuntimeError(f"Expected 460 cross-check questions, found {len(crosscheck)}.")

    with tempfile.TemporaryDirectory(prefix="deutschgarden-civics-") as temp_name:
        temp = Path(temp_name)
        image_dir = temp / "images"
        image_dir.mkdir(parents=True)
        questions: list[dict[str, object]] = []

        general = primary.get("questions", [])
        if not isinstance(general, list) or len(general) != 300:
            raise RuntimeError("Primary source must contain exactly 300 general questions.")
        for item in general:
            number = int(item["id"])
            question_id = f"general-{number:03d}"
            questions.append(
                _build_question(
                    item,
                    crosscheck[question_id],
                    question_id,
                    "general",
                    None,
                    image_map,
                    image_dir,
                )
            )

        state_root = primary.get("questions_land", {})
        if not isinstance(state_root, dict):
            raise RuntimeError("Primary source has no state question map.")
        for code, name, source_key in STATES:
            state_questions = state_root.get(source_key)
            if not isinstance(state_questions, list) or len(state_questions) != 10:
                raise RuntimeError(f"{name} must contain exactly 10 questions.")
            for item in state_questions:
                number = int(item["id"])
                question_id = f"{code}-{number:02d}"
                questions.append(
                    _build_question(
                        item,
                        crosscheck[question_id],
                        question_id,
                        "state",
                        code,
                        image_map,
                        image_dir,
                    )
                )

        if len(questions) != 460 or len({q["id"] for q in questions}) != 460:
            raise RuntimeError("Generated catalogue count or ids are invalid.")
        image_count = sum(len(question["images"]) for question in questions)
        if image_count != len(list(image_dir.iterdir())) or image_count < 50:
            raise RuntimeError(
                f"Expected a substantive, one-to-one image set; found {image_count}."
            )

        metadata = primary.get("metadata", {})
        if str(metadata.get("stand", "")) != "07.05.2025":
            raise RuntimeError("The upstream official catalogue version changed; review it first.")

        output = {
            "metadata": {
                "title": "Leben in Deutschland und Einbürgerungstest",
                "catalogStand": "07.05.2025",
                "language": "de",
                "generalQuestionCount": 300,
                "stateQuestionCount": 160,
                "stateCount": 16,
                "officialCatalogUrl": OFFICIAL_CATALOG_URL,
                "officialPdfUrl": OFFICIAL_PDF_URL,
                "validatedTextExtraction": YEHOR_JSON_URL,
                "licensedImageExtraction": VLAD_JSON_URL,
                "validatedTextCommit": YEHOR_COMMIT,
                "licensedImageCommit": VLAD_COMMIT,
            },
            "states": [
                {"code": code, "name": name} for code, name, _ in STATES
            ],
            "questions": questions,
        }
        (temp / "questions.json").write_text(
            json.dumps(output, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        (temp / "NOTICE.md").write_text(
            "# Civics catalogue provenance\n\n"
            "The German questions and answer options are the official BAMF "
            "Leben in Deutschland / Einbürgerungstest catalogue, Stand "
            "07.05.2025. The legal catalogue is published as Anlage 1 to the "
            "Einbürgerungstestverordnung. No translation or third-party "
            "explanation is bundled.\n\n"
            "Validated official text was imported from "
            "`YehorAltshuler/bamf-lid-dataset` at commit "
            f"`{YEHOR_COMMIT}`; every answer key was "
            "independently checked against `vlad-com/leben_in_de`. Embedded "
            "images were extracted from the latter MIT-licensed project at "
            f"commit `{VLAD_COMMIT}`.\n\n"
            "This feature is an independent study aid. DeutschGarden is not "
            "affiliated with BAMF and cannot issue an official certificate.\n\n"
            "## MIT notice for vlad-com/leben_in_de\n\n"
            "Copyright (c) 2026 Vlad\n\n"
            "Permission is hereby granted, free of charge, to any person "
            "obtaining a copy of this software and associated documentation "
            "files (the \"Software\"), to deal in the Software without "
            "restriction, including without limitation the rights to use, "
            "copy, modify, merge, publish, distribute, sublicense, and/or "
            "sell copies of the Software, and to permit persons to whom the "
            "Software is furnished to do so, subject to the following "
            "conditions:\n\n"
            "The above copyright notice and this permission notice shall be "
            "included in all copies or substantial portions of the Software."
            "\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY "
            "KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE "
            "WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE "
            "AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT "
            "HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, "
            "WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING "
            "FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR "
            "OTHER DEALINGS IN THE SOFTWARE.\n",
            encoding="utf-8",
        )

        # Copy onto the repository volume first, then swap directories. If the
        # final rename fails, restore the old catalogue; never leave an
        # interrupted update looking like a valid but empty asset directory.
        staging = OUTPUT.with_name("civics.importing")
        backup = OUTPUT.with_name("civics.previous")
        if staging.exists():
            shutil.rmtree(staging)
        if backup.exists():
            shutil.rmtree(backup)
        shutil.copytree(temp, staging)
        if OUTPUT.exists():
            OUTPUT.rename(backup)
        try:
            staging.rename(OUTPUT)
        except Exception:
            if backup.exists() and not OUTPUT.exists():
                backup.rename(OUTPUT)
            raise
        if backup.exists():
            shutil.rmtree(backup)

    print("CIVICS IMPORT PASSED")
    print("Questions: 460 (300 general + 160 state)")
    print(f"Images: {image_count}")
    print("Catalogue stand: 07.05.2025")


if __name__ == "__main__":
    main()
