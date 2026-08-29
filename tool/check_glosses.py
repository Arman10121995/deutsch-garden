"""Check the card translations against the deck they claim to translate.

These files are the one place in the project where content can go wrong
silently. An icon that fails to load is visible; a gloss for a card id that no
longer exists simply never appears, and a card whose "translation" is still
the German word looks like a translation to anyone who does not read the
language.

What this can check is mechanical: that every id is real, that nothing is
blank, that no entry is a copy of the German, and that the coverage claimed
is the coverage present. What it cannot check is whether *elma* is the right
word for *Apfel*. That is stated in `docs/KNOWN_LIMITATIONS.md` rather than
implied by a green build.

Usage:
    python tool/check_glosses.py
"""
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GLOSS_DIR = os.path.join(ROOT, 'assets', 'glosses')
LIB = os.path.join(ROOT, 'lib')
COGNATES = os.path.join(ROOT, 'tool', 'gloss_cognates.tsv')

FIELD = (r"id: '([^']*)'[^)]*?article: '([^']*)'[^)]*?german: '([^']*)'"
         r"[^)]*?english: '([^']*)'")


def deck():
    """id -> (german, english) for every card in the bundled deck."""
    out = {}
    for name in sorted(os.listdir(LIB)):
        if not (name.startswith('vocabulary') and name.endswith('.dart')):
            continue
        text = io.open(os.path.join(LIB, name), encoding='utf-8').read()
        for cid, _article, german, english in re.findall(FIELD, text, re.S):
            out[cid] = (german, english)
    return out


def cognates():
    """(language, id) pairs whose gloss is meant to equal the German."""
    out = set()
    if not os.path.exists(COGNATES):
        return out
    for line in io.open(COGNATES, encoding='utf-8'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split(chr(9))
        if len(parts) >= 2:
            out.add((parts[0], parts[1]))
    return out


def main():
    if not os.path.isdir(GLOSS_DIR):
        print('no assets/glosses directory; nothing to check')
        return 0

    cards = deck()
    if not cards:
        print('GLOSS CHECK FAILED')
        print('  - could not read the deck, so nothing could be verified')
        return 1

    allowed = cognates()
    files = sorted(f for f in os.listdir(GLOSS_DIR) if f.endswith('.json'))
    errors = []
    summary = []

    for name in files:
        code = name[:-5]
        path = os.path.join(GLOSS_DIR, name)
        try:
            data = json.load(io.open(path, encoding='utf-8'))
        except ValueError as error:
            errors.append('%s is not valid JSON: %s' % (name, error))
            continue
        if not isinstance(data, dict):
            errors.append('%s is not an object of id -> gloss' % name)
            continue

        unknown = [k for k in data if k not in cards]
        blank = [k for k, v in data.items()
                 if not isinstance(v, str) or not v.strip()]
        # A "translation" identical to the German is an untranslated entry
        # wearing a translation's clothes.
        untranslated = [
            k for k, v in data.items()
            if k in cards and isinstance(v, str)
            and v.strip().lower() == cards[k][0].strip().lower()
            and (code, k) not in allowed
        ]

        for key in unknown[:5]:
            errors.append('%s glosses "%s", which is not a card' % (name, key))
        if len(unknown) > 5:
            errors.append('%s glosses %d further unknown ids'
                          % (name, len(unknown) - 5))
        for key in blank[:5]:
            errors.append('%s has a blank gloss for "%s"' % (name, key))
        for key in untranslated[:5]:
            errors.append('%s leaves "%s" as the German word "%s"'
                          % (name, key, cards[key][0]))

        summary.append((code, len(data), len(cards)))

    if errors:
        print('GLOSS CHECK FAILED')
        for error in errors:
            print('  - %s' % error)
        return 1

    print('GLOSS CHECK PASSED')
    for code, count, total in summary:
        print('  %-4s %5d of %5d cards (%.1f%%)'
              % (code, count, total, 100.0 * count / total))
    if not summary:
        print('  (no gloss files)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
