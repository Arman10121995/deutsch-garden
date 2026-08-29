#!/usr/bin/env python3
"""Fails the build if a hint could answer the question it is hinting at.

A hint exists to remind a learner which rule applies. Every question already
carries an `explanation`, and showing that instead would be one line of code
and completely useless: explanations name the right option, so a learner who
taps for help gets the answer and the exercise stops measuring anything.

The Dart side enforces this at runtime -- lib/hints.dart drops any candidate
hint containing the correct option and falls back to a weaker structural one.
This checks the things a runtime guard cannot: that the guard is still there,
that it is still whole-word for single-word answers, and that no screen has
started passing an explanation in as a hint.

Run: python tool/check_hints.py
"""

from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
LIB = ROOT / "lib"


def main() -> int:
    problems: list[str] = []

    hints = LIB / "hints.dart"
    if not hints.exists():
        print("Hint check failed:\n\n  - lib/hints.dart is gone.")
        return 1
    source = hints.read_text(encoding="utf-8")

    if "bool leaksAnswer(" not in source:
        problems.append(
            "lib/hints.dart no longer exports leaksAnswer, so nothing stops a "
            "hint naming the answer."
        )
    if "!leaksAnswer(rule, answer)" not in source:
        problems.append(
            "lib/hints.dart no longer checks the rule text against the "
            "answer before using it as a hint."
        )
    if "split(' ').contains(foldedAnswer)" not in source:
        problems.append(
            "lib/hints.dart no longer matches single-word answers as whole "
            "words. Substring matching rejects a hint saying 'gender' because "
            "'der' is inside it, and the learner gets no hint at all."
        )

    # A screen must never hand a *question's* explanation in as the hint.
    #
    # The two explanations in this codebase are opposites and the names do not
    # say so. A lesson's explanation is the rule being taught -- exactly what a
    # hint should be. A question's explanation says which option is right and
    # why, which is the one thing a hint must never do. So this bans the
    # question-shaped ones by name rather than banning the word.
    question_explanation = re.compile(
        r"ruleText:\s*(q|_?question|item|entry)\s*(\.|\?\.)\s*explanation"
    )
    for path in sorted(LIB.rglob("*.dart")):
        if path.name == "hints.dart":
            continue
        text = path.read_text(encoding="utf-8")
        for number, line in enumerate(text.splitlines(), 1):
            if question_explanation.search(line):
                problems.append(
                    f"{path.relative_to(ROOT).as_posix()}:{number} passes a "
                    f"question's explanation as the hint. That names the "
                    f"correct option. A lesson's explanation is the rule and "
                    f"is fine; a question's explanation is the answer."
                )

    if problems:
        print("Hint check failed:\n")
        for problem in problems:
            print(f"  - {problem}")
        return 1

    print("Hint check passed: hints cannot name the answer they hint at.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
