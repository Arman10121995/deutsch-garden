#!/usr/bin/env python3
"""Fails the build if a screen can show a multiple-choice question unshuffled.

Every authored item in this app was written correct-answer-first, because that
is the natural way to write one. Measured before the fix: 386 items answered at
position 1, 119 at position 2, 73 at position 3, and none at position 4. All
sixty placement questions answered first, so tapping the top option scored
100% and placed a beginner at C2.

The fix permutes options at presentation. What makes that fragile is that it
has to be done in *every* screen: the next quiz screen someone writes will read
`.correctIndex` off a raw question and quietly reintroduce the whole bug, and
nothing will look wrong. Tests cannot catch it either, because the test would
have to know the screen exists.

So this checks the shape instead: a file that reads `.correctIndex` for
grading or rendering must also obtain its questions through a shuffle.

Run: python tool/check_answer_shuffle.py
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"

# Files that legitimately mention correctIndex without presenting anything.
EXEMPT = {
    # The type declarations themselves, plus the shuffle they now carry.
    "models.dart",
    "assessment.dart",
    "test_prep.dart",
    "civics_test.dart",
    "answer_shuffle.dart",
    # Reads the index to find the option it must NOT name. It renders
    # nothing, so there is nothing for it to render in the wrong order.
    "hints.dart",
    # Builder helpers that only forward a caller's index into a constructor.
    "curriculum.dart",
    "skill_expansion.dart",
    "grammar_expansion.dart",
    "radio_longform.dart",
    "course.dart",
}

# Evidence that a file routes its questions through the shuffle.
SHUFFLE_MARKERS = (
    "shuffled(",
    "seededFor(",
    "shuffleChoices(",
)

# A read of correctIndex that decides what the learner sees or scores.
READ = re.compile(r"\.correctIndex\b")

# A declaration rather than a read.
DECLARATION = re.compile(
    r"(required this\.correctIndex|final int correctIndex|correctIndex:|"
    r"int correctIndex)"
)


def main() -> int:
    problems: list[str] = []
    checked: list[str] = []

    for path in sorted(LIB.rglob("*.dart")):
        if path.name in EXEMPT:
            continue
        text = path.read_text(encoding="utf-8")
        rel = path.relative_to(ROOT).as_posix()

        reads = []
        for number, line in enumerate(text.splitlines(), 1):
            if not READ.search(line):
                continue
            if DECLARATION.search(line):
                continue
            reads.append(number)

        if not reads:
            continue

        checked.append(rel)
        if not any(marker in text for marker in SHUFFLE_MARKERS):
            problems.append(
                f"{rel} reads .correctIndex at line(s) "
                f"{', '.join(str(n) for n in reads[:6])}"
                f"{' …' if len(reads) > 6 else ''} but never shuffles. "
                f"Every authored item is written answer-first, so a screen "
                f"that shows them in order shows the answer first."
            )

    # The shuffle itself has to keep existing and keep being uniform.
    shuffle = (LIB / "answer_shuffle.dart")
    if not shuffle.exists():
        problems.append("lib/answer_shuffle.dart is gone.")
    else:
        source = shuffle.read_text(encoding="utf-8")
        if "order.shuffle(random)" not in source:
            problems.append(
                "lib/answer_shuffle.dart no longer permutes by index. "
                "Locating the answer again by value marks the first duplicate "
                "option correct, and der/die/das drills repeat options."
            )

    if problems:
        print("Answer-shuffle check failed:\n")
        for problem in problems:
            print(f"  - {problem}")
        print(
            "\nA screen that presents multiple choice must permute the "
            "options first. See lib/answer_shuffle.dart."
        )
        return 1

    print(
        f"Answer-shuffle check passed: {len(checked)} presenting file(s) all "
        f"route questions through the shuffle."
    )
    for rel in checked:
        print(f"    {rel}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
