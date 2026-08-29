"""Fail the build when the deck disagrees with a recorded CEFR judgement.

Applying the mapping once is not enough. The levels drifted originally because
they were set in bulk, and the next bulk edit would silently undo every
decision in `cefr_relevelling.tsv` with nothing to notice. This is what
notices.

Usage:
    python tool/check_relevelling.py
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
MAP = os.path.join(ROOT, 'tool', 'cefr_relevelling.tsv')

# Deliberately not `[^)]*?` between the fields. Plenty of English glosses
# contain a bracket -- "comma (,)", "mummy (embalmed corpse)" -- and a pattern
# that stops at the first `)` silently fails to find those cards, which reads
# as "judged but no longer in the deck" rather than as a broken regex.
FIELD = (r"id: '([^']*)'(?:(?!id: ').)*?german: '([^']*)'"
         r"(?:(?!id: ').)*?level: '([^']*)'")


def main():
    if not os.path.exists(MAP):
        print('no judgements recorded; nothing to check')
        return 0

    wanted = {}
    for number, line in enumerate(io.open(MAP, encoding='utf-8'), 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split(chr(9))
        if len(parts) < 6:
            print('CEFR CHECK FAILED')
            print('  - %s line %d has %d fields, expected 6'
                  % (os.path.basename(MAP), number, len(parts)))
            return 1
        wanted[parts[0]] = (parts[1], parts[3], parts[4])

    deck = {}
    for name in sorted(os.listdir(LIB)):
        if not (name.startswith('vocabulary') and name.endswith('.dart')):
            continue
        text = io.open(os.path.join(LIB, name), encoding='utf-8').read()
        for cid, german, level in re.findall(FIELD, text, re.S):
            deck[cid] = (german, level.upper())

    errors = []
    for cid, (german, level, _basis) in sorted(wanted.items()):
        if cid not in deck:
            errors.append('%s (%s) is judged but no longer in the deck'
                          % (cid, german))
            continue
        actual_german, actual_level = deck[cid]
        if actual_german != german:
            # An id reused for another word must not inherit the judgement.
            errors.append('%s was judged as "%s" but the deck now has "%s"'
                          % (cid, german, actual_german))
            continue
        if actual_level != level:
            errors.append('%s (%s) is %s in the deck, judged as %s'
                          % (cid, german, actual_level, level))

    if errors:
        print('CEFR CHECK FAILED')
        for error in errors:
            print('  - %s' % error)
        print()
        print('Either the judgement is wrong and the row should change, or the')
        print('deck was edited in bulk over it. Run tool/apply_relevelling.py')
        print('--write to restore the recorded levels.')
        return 1

    by_hand = sum(1 for v in wanted.values() if v[2] == 'hand')
    print('CEFR CHECK PASSED')
    print('  cards with a judgement : %d of %d' % (len(wanted), len(deck)))
    print('    read by a person     : %d' % by_hand)
    print('    derived from corpus  : %d' % (len(wanted) - by_hand))
    return 0


if __name__ == '__main__':
    sys.exit(main())
