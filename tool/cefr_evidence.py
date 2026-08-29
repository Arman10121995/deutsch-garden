"""Estimate a card's CEFR level from the level of the material it appears in.

The deck's labels came from bulk import. The bundled *content* did not: the
stories, radio episodes, role-plays and sentence banks were each written for a
stated level, and that is real evidence about the words inside them. A noun
that first turns up in an A2 story is an A2 noun, whatever the import said.

This measures that and nothing else. It proposes; it does not decide. The
proposals go into `tool/cefr_relevelling.tsv` with their basis recorded, so a
level derived this way can never be mistaken for one a human read.

Where a word appears in no bundled material there is no evidence, and the
honest output is "no evidence" rather than a guess dressed as a finding.

Usage:
    python tool/cefr_evidence.py            # summary
    python tool/cefr_evidence.py --propose  # write proposals to stdout as TSV
"""
import io
import os
import re
import sys
import collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, 'lib')
LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
ORDER = {name: index for index, name in enumerate(LEVELS)}

CARD = (r"id: '([^']*)'(?:(?!id: ').)*?article: '([^']*)'"
        r"(?:(?!id: ').)*?german: '([^']*)'"
        r"(?:(?!id: ').)*?level: '([^']*)'")


def read(name):
    return io.open(os.path.join(LIB, name), encoding='utf-8',
                   errors='replace').read()


def cards():
    out = []
    for name in sorted(os.listdir(LIB)):
        if name.startswith('vocabulary') and name.endswith('.dart'):
            for cid, article, german, level in re.findall(CARD, read(name),
                                                          re.S):
                out.append((cid, article, german, level.upper()))
    return out


# A single incidental occurrence is not evidence. An A1 story can contain one
# advanced word without that word being A1, so a level has to use a word more
# than once before it counts as having taught it.
MIN_OCCURRENCES = 2

# Below this length the token is almost always a function word, an abbreviation
# or code noise, and those match everything.
MIN_LENGTH = 4

# The furthest a card is allowed to fall on corpus evidence alone. One stray
# appearance of a C2 word in an A1 text should not drag it five bands.
MAX_DROP = 2


def german_words(text):
    """Token -> count, for German-looking tokens long enough to mean something."""
    counts = collections.Counter()
    for word in re.findall(r"[A-Za-zÄÖÜäöüß][A-Za-zÄÖÜäöüß\-]{1,}", text):
        if len(word) >= MIN_LENGTH:
            counts[word.lower()] += 1
    return counts


def corpus():
    """level -> set of words appearing in material written for that level.

    A file is scanned in blocks: each `CefrLevel.xx` marker claims the text
    that follows it until the next marker. That is coarse, and deliberately
    so -- it is evidence, not a parse.
    """
    found = {name: collections.Counter() for name in LEVELS}
    marker = re.compile(r'CefrLevel\.(a1|a2|b1|b2|c1|c2)\b')
    skip = ('vocabulary', 'build_info', 'l10n')
    for name in sorted(os.listdir(LIB)):
        if not name.endswith('.dart') or name.startswith(skip):
            continue
        text = read(name)
        hits = list(marker.finditer(text))
        if not hits:
            continue
        for index, hit in enumerate(hits):
            level = hit.group(1).upper()
            end = hits[index + 1].start() if index + 1 < len(hits) else len(text)
            found[level].update(german_words(text[hit.end():end]))
    return found


def main():
    deck = cards()
    seen = corpus()

    # Lowest level whose material uses a word often enough to have taught it.
    earliest = {}
    for level in LEVELS:
        for word, count in seen[level].items():
            if count >= MIN_OCCURRENCES and word not in earliest:
                earliest[word] = level

    proposals = []
    stats = collections.Counter()
    for cid, _article, german, level in deck:
        key = german.lower()
        evidence = earliest.get(key)
        if evidence is None:
            stats['no-evidence'] += 1
            proposals.append((cid, german, level, level, 'corpus',
                              'no bundled material uses this word'))
            continue
        # Only ever move a card *down* to where the material first uses it.
        # Promoting on absence would be an argument from silence, and the
        # material is far smaller than the deck.
        if ORDER[evidence] < ORDER[level]:
            drop = ORDER[level] - ORDER[evidence]
            if drop > MAX_DROP:
                stats['capped'] += 1
                proposals.append((cid, german, level, level, 'corpus',
                                  'used in %s material, too far below %s to '
                                  'act on' % (evidence, level)))
                continue
            stats['lower'] += 1
            proposals.append((cid, german, level, evidence, 'corpus',
                              'used %d times in %s material'
                              % (seen[evidence][german.lower()], evidence)))
        else:
            stats['agrees'] += 1
            proposals.append((cid, german, level, level, 'corpus',
                              'material agrees, first used in %s' % evidence))

    if '--propose' in sys.argv:
        for row in proposals:
            sys.stdout.write(chr(9).join(row) + chr(10))
        return 0

    print('cards            : %d' % len(deck))
    print('material words   : %d' % len(earliest))
    print('would move down  : %d' % stats['lower'])
    print('material agrees  : %d' % stats['agrees'])
    print('no evidence      : %d' % stats['no-evidence'])
    print('capped, left be  : %d' % stats['capped'])

    # Does the method agree with the cards a human actually read?
    hand = {}
    mapping = os.path.join(ROOT, 'tool', 'cefr_relevelling.tsv')
    if os.path.exists(mapping):
        for line in io.open(mapping, encoding='utf-8'):
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            parts = line.split(chr(9))
            if len(parts) >= 4 and (len(parts) < 5 or parts[4] != 'corpus'):
                hand[parts[0]] = parts[3]
    if hand:
        proposed = {r[0]: r[3] for r in proposals}
        same = sum(1 for k, v in hand.items() if proposed.get(k) == v)
        print()
        print('against the %d hand judgements: %d agree, %d differ'
              % (len(hand), same, len(hand) - same))
        for cid, want in sorted(hand.items()):
            got = proposed.get(cid)
            if got != want:
                print('  %-8s hand says %s, corpus says %s' % (cid, want, got))
    moves = collections.Counter(
        '%s -> %s' % (r[2], r[3]) for r in proposals if r[2] != r[3])
    print()
    print('largest proposed moves:')
    for move, count in moves.most_common(12):
        print('  %-10s %d' % (move, count))
    return 0


if __name__ == '__main__':
    sys.exit(main())
