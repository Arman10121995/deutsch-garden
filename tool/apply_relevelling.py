"""Write the judgements in cefr_relevelling.tsv into the vocabulary sources.

The TSV is the record; the Dart files are derived from it. Doing it the other
way round -- editing the cards and hoping a note somewhere remembers why --
is how the levels drifted in the first place.

Usage:
    python tool/apply_relevelling.py            # report what would change
    python tool/apply_relevelling.py --write    # change it
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
MAP = os.path.join(ROOT, 'tool', 'cefr_relevelling.tsv')
LEVELS = ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')


def judgements():
    """id -> (german, from, to, why), in file order."""
    out = {}
    if not os.path.exists(MAP):
        return out
    for number, line in enumerate(io.open(MAP, encoding='utf-8'), 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split(chr(9))
        if len(parts) < 6:
            raise SystemExit('%s line %d: expected 6 tab-separated fields'
                             % (MAP, number))
        cid, german, before, after, _basis, why = parts[:6]
        if after not in LEVELS or before not in LEVELS:
            raise SystemExit('%s line %d: "%s" -> "%s" is not a CEFR level'
                             % (MAP, number, before, after))
        if cid in out:
            raise SystemExit('%s line %d: %s is judged twice'
                             % (MAP, number, cid))
        out[cid] = (german, before, after, why)
    return out


def main():
    write = '--write' in sys.argv
    wanted = judgements()
    if not wanted:
        print('no judgements recorded')
        return 0

    changed = 0
    unchanged = 0
    missing = set(wanted)

    for name in sorted(os.listdir(LIB)):
        if not (name.startswith('vocabulary') and name.endswith('.dart')):
            continue
        path = os.path.join(LIB, name)
        text = io.open(path, encoding='utf-8').read()
        original = text

        for cid, (german, _before, after, _why) in wanted.items():
            # Rewrite only the level of the entry with this id, and only when
            # the German on the card is the German the judgement was made
            # about -- an id that has been reused for a different word must
            # not silently inherit someone else's decision.
            pattern = re.compile(
                r"(id: '" + re.escape(cid) + r"'(?:(?!id: ').)*?"
                r"german: '" + re.escape(german) + r"'"
                r"(?:(?!id: ').)*?level: ')([A-C][12])(')",
                re.S)
            match = pattern.search(text)
            if not match:
                continue
            missing.discard(cid)
            if match.group(2) == after:
                unchanged += 1
                continue
            text = text[:match.start(2)] + after + text[match.end(2):]
            changed += 1
            print('  %-8s %-14s %s -> %s' % (cid, german, match.group(2), after))

        if write and text != original:
            io.open(path, 'w', encoding='utf-8').write(text)

    if missing:
        print()
        print('NOT FOUND in the deck (id and German must both match):')
        for cid in sorted(missing):
            print('  %s %s' % (cid, wanted[cid][0]))
        return 1

    print()
    print('%d judgement(s): %d applied, %d already correct'
          % (len(wanted), changed, unchanged))
    if changed and not write:
        print('Nothing was written. Re-run with --write.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
