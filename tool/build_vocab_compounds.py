#!/usr/bin/env python3
"""Splits German compounds into parts the learner already has cards for.

Why this is worth more than another icon set
--------------------------------------------
Only 838 of 10,000 cards carry a picture, and measurement killed every cheap
way of buying thousands more: matching English glosses to icon names gave
`pruefen` a tick and `im Gegensatz dazu` a brightness slider, and a wrong
picture teaches worse than no picture.

Compounding is the way out, because it is the one place where German gives
something away for free. 1,692 uncovered single-token words -- 23% -- are
built from two words already in the deck. `Flughafen` is Flug plus Hafen.
`Krankenhaus` is krank plus Haus. `Ohrring` is Ohr plus Ring, and both of
those parts already have a drawing, so the compound gets a composed picture
without anyone drawing anything.

Measured on the current deck, of 7,253 uncovered single-token words:

  * 1,692 decompose into two known cards
  *   781 have at least one part that is already illustrated
  *   219 have both parts illustrated -- a complete picture, for nothing

Nothing is downloaded, nothing is licensed, nothing is added to the bundle
beyond a generated Dart map. That is the first rule of docs/ASSET_POLICY.md.

What this deliberately does not claim
-------------------------------------
That the compound *means* its parts. Plenty do not: `Aufgabe` is built from
auf and Gabe but a task is not an up-gift, and `Autogramm` is not a car
gramme. So the UI says "built from" and never "means". The structure is a
fact about the word and a real memory hook even where the semantics do not
follow, which is why a wrong-looking split is still usually useful -- but the
ones that actively mislead are excluded by hand in
tool/vocab_compounds_excluded.tsv, with a reason each.

Usage:
    python tool/build_vocab_compounds.py            # report
    python tool/build_vocab_compounds.py --write    # regenerate the Dart
"""

from __future__ import annotations

import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'lib', 'vocab_compounds.dart')
EXCLUSIONS = os.path.join(ROOT, 'tool', 'vocab_compounds_excluded.tsv')

FIELD = (r"id: '([^']*)'[^)]*?article: '([^']*)'[^)]*?german: '([^']*)'"
         r"[^)]*?english: '([^']*)'[^)]*?category: '([^']*)'[^)]*?level: '([^']*)'")

# Fugenelemente: the linking morphemes German inserts at a compound seam.
# Ordered longest-first so `es` is tried before `e` and `en` before `n`.
LINKS = ['es', 'en', 'ns', 'er', 's', 'n', 'e', '']

# Below this a "part" is a fragment rather than a word, and the split is
# usually an accident: almost any long word contains some three-letter word.
MIN_PART = 3

# Short words are rarely compounds and are where false splits cluster.
MIN_WORD = 7


def cards():
    out = []
    lib = os.path.join(ROOT, 'lib')
    for name in sorted(os.listdir(lib)):
        if name.startswith('vocabulary') and name.endswith('.dart'):
            text = io.open(os.path.join(lib, name), encoding='utf-8').read()
            out += re.findall(FIELD, text, re.S)
    return out


def exclusions():
    out = {}
    if not os.path.exists(EXCLUSIONS):
        return out
    for line in io.open(EXCLUSIONS, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        parts = line.split(chr(9))
        if len(parts) >= 3:
            out[parts[0]] = parts[2]
    return out


def build():
    rows = cards()
    lexicon = {}
    for cid, article, german, english, category, level in rows:
        word = german.strip()
        if ' ' in word:
            continue
        lexicon.setdefault(word.lower(), cid)

    skip = exclusions()
    out = []
    for cid, article, german, english, category, level in rows:
        if cid in skip:
            continue
        word = german.strip()
        if ' ' in word or len(word) < MIN_WORD:
            continue
        found = split(word, lexicon)
        if found is None:
            continue
        modifier, head, link = found
        # A word is not a compound of itself.
        if lexicon[modifier] == cid or lexicon[head] == cid:
            continue
        out.append((cid, lexicon[modifier], lexicon[head], link))
    out.sort(key=lambda r: r[0])
    return out, len(skip)


def split(word, lexicon):
    """The most specific two-part split, or None.

    Longest modifier wins. `Rechtsanwalt` splits at Recht+s+anwalt rather than
    at a shorter accidental prefix, and preferring the longer left part is
    what picks the real seam without a morphological analyser.
    """
    lowered = word.lower()
    best = None
    for cut in range(MIN_PART, len(lowered) - MIN_PART + 1):
        head = lowered[cut:]
        if len(head) < MIN_PART or head not in lexicon:
            continue
        for link in LINKS:
            if link:
                if not lowered[:cut].endswith(link):
                    continue
                modifier = lowered[:cut - len(link)]
            else:
                modifier = lowered[:cut]
            if len(modifier) < MIN_PART or modifier not in lexicon:
                continue
            if best is None or len(modifier) > len(best[0]):
                best = (modifier, head, link)
            break
    return best


def write(entries):
    lines = [
        '/// German compounds, split into cards the learner already has.',
        '/// Generated by tool/build_vocab_compounds.py. Do not edit by hand.',
        '///',
        '/// This says how a word is *built*, never what it means. Plenty of',
        '/// compounds are not compositional -- Aufgabe is auf plus Gabe and a',
        '/// task is not an up-gift -- so the UI says "built from". The',
        '/// structure is a fact about the word and a memory hook either way.',
        '///',
        '/// Where both parts have a picture, the compound gets a composed one',
        '/// without anyone drawing anything. That is the whole point: it',
        '/// multiplies the 838 existing illustrations instead of adding to',
        '/// them.',
        'library;',
        '',
        '/// How a compound is put together.',
        'class VocabCompound {',
        '  const VocabCompound(this.modifierId, this.headId, this.link);',
        '',
        '  /// The card for the first part.',
        '  final String modifierId;',
        '',
        "  /// The card for the second part, which carries the word's gender",
        '  /// and its core meaning: a Handschuh is a kind of Schuh.',
        '  final String headId;',
        '',
        '  /// The Fugenelement joining them, or empty. Worth showing: the',
        "  /// linking -s- in Rechtsanwalt is not part of either word and a",
        '  /// learner who thinks it is will spell the parts wrong.',
        '  final String link;',
        '}',
        '',
        '/// Card id to its parts.',
        'const Map<String, VocabCompound> vocabCompounds = '
        '<String, VocabCompound>{',
    ]
    for cid, modifier, head, link in entries:
        lines.append(
            "  '%s': VocabCompound('%s', '%s', '%s')," % (cid, modifier, head, link)
        )
    lines.append('};')
    lines.append('')
    io.open(OUT, 'w', encoding='utf-8', newline='\n').write(chr(10).join(lines))


def main():
    entries, skipped = build()
    print('Vocabulary compounds')
    print('  split into known parts : %d' % len(entries))
    print('  excluded by hand       : %d (%s)'
          % (skipped, os.path.relpath(EXCLUSIONS, ROOT)))

    illustrated = set()
    for folder in ('vocab', 'vocab_line'):
        path = os.path.join(ROOT, 'assets', folder)
        if os.path.isdir(path):
            illustrated |= {f[:-4] for f in os.listdir(path) if f.endswith('.svg')}
    emoji_file = os.path.join(ROOT, 'lib', 'vocab_emoji.dart')
    if os.path.exists(emoji_file):
        illustrated |= set(
            re.findall(r"'([^']+)': '", io.open(emoji_file, encoding='utf-8').read())
        )
    one = sum(1 for _, m, h, _ in entries
              if m in illustrated or h in illustrated)
    both = sum(1 for _, m, h, _ in entries
               if m in illustrated and h in illustrated)
    print('  at least one part drawn: %d' % one)
    print('  both parts drawn       : %d (a composed picture, free)' % both)

    if '--write' in sys.argv:
        write(entries)
        print('  wrote %s' % os.path.relpath(OUT, ROOT))
    else:
        print('\nRun with --write to regenerate lib/vocab_compounds.dart')
    return 0


if __name__ == '__main__':
    sys.exit(main())
