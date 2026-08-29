#!/usr/bin/env python3
"""Maps vocabulary cards to emoji, from Unicode's own German annotations.

Why this exists
---------------
513 cards carry a hand-drawn SVG and 85 carry a Tabler pictogram. That is 6%
of the deck. The other 9,402 cards show a generated structural tile, which
says what kind of word it is but not what it means, and a visual learner gets
nothing from it.

Three ways of closing that were measured before this one was written:

* **English gloss -> Tabler icon name.** 828 matches (8.8%), and the precision
  is terrible, because the gloss goes through English and English is where the
  ambiguity lives. It gave `pruefen` (to check) a tick mark, `kuendigen` (to
  resign) a cancel cross, and `im Gegensatz dazu` (in contrast) a
  brightness-contrast slider. A wrong picture teaches the wrong thing and is
  worse than no picture, so this was rejected outright.

* **CLDR German keyword lists.** 1,205 matches (12.8%), also poor: `Vorteil`
  (advantage) got a Japanese "bargain" ideograph and `Verhandlung`
  (negotiation) got the Japanese "free of charge" sign. Keyword lists exist
  for search, where a loose match costs nothing, not for illustration.

* **CLDR German canonical names.** 249 matches, and they are almost all
  right: Nase to nose, Leiter to ladder, Schaf to sheep, Wissenschaftler to
  scientist. This is the one that shipped.

The difference is that a canonical name is Unicode's own statement of what the
character depicts, in German, rather than a bag of words that might retrieve
it. Matching German to German also removes the translation step where the
false friends were coming from.

Cost: none. An emoji is a Unicode code point rendered by a font the device
already has. No asset, no bytes in the bundle, no licence, nothing to
attribute -- which is the first rule of docs/ASSET_POLICY.md satisfied
exactly rather than approximately. CLDR itself is under the Unicode licence,
but only its data is read here, at build time, and none of it ships.

Usage:
    python tool/build_vocab_emoji.py            # report
    python tool/build_vocab_emoji.py --write    # regenerate lib/vocab_emoji.dart
"""

from __future__ import annotations

import io
import json
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'lib', 'vocab_emoji.dart')
EXCLUSIONS = os.path.join(ROOT, 'tool', 'vocab_emoji_excluded.tsv')
CACHE = os.path.join(ROOT, 'tool', 'cldr_de_annotations.json')

CLDR_URL = (
    'https://raw.githubusercontent.com/unicode-org/cldr-json/main/cldr-json/'
    'cldr-annotations-full/annotations/de/annotations.json'
)

# Code points whose glyph is too new to rely on.
#
# An emoji only exists if the device's font has it; otherwise the learner gets
# an empty box, which is worse than the structural tile it replaced. These are
# the Unicode 16 (2024) additions that appeared in the candidate list, checked
# by eye and found not to render. The cutoff is a judgement about how long a
# font takes to reach real devices, not a fact, and it is worth revisiting:
# raising it would recover a harp, a trombone, a shovel and a splatter.
TOO_NEW = {
    0x1FA89,  # harp
    0x1FA8A,  # trombone
    0x1FA8F,  # shovel
    0x1FABE,  # leafless tree
    0x1FAC6,  # fingerprint
    0x1FADC,  # root vegetable
    0x1FADF,  # splatter
    0x1FAE9,  # face with bags under eyes
}

FIELD = (r"id: '([^']*)'[^)]*?article: '([^']*)'[^)]*?german: '([^']*)'"
         r"[^)]*?english: '([^']*)'[^)]*?category: '([^']*)'[^)]*?level: '([^']*)'")


def cards():
    out = []
    lib = os.path.join(ROOT, 'lib')
    for name in sorted(os.listdir(lib)):
        if name.startswith('vocabulary') and name.endswith('.dart'):
            text = io.open(os.path.join(lib, name), encoding='utf-8').read()
            out += re.findall(FIELD, text, re.S)
    return out


def already_illustrated():
    have = set()
    for folder in ('vocab', 'vocab_line'):
        path = os.path.join(ROOT, 'assets', folder)
        if os.path.isdir(path):
            have |= {f[:-4] for f in os.listdir(path) if f.endswith('.svg')}
    return have


def annotations():
    """CLDR German annotations, cached so a build never needs the network."""
    if os.path.exists(CACHE):
        return json.loads(io.open(CACHE, encoding='utf-8').read())
    request = urllib.request.Request(
        CLDR_URL, headers={'User-Agent': 'deutsch-garden-tooling'}
    )
    raw = urllib.request.urlopen(request, timeout=120).read().decode('utf-8')
    data = json.loads(raw)['annotations']['annotations']
    io.open(CACHE, 'w', encoding='utf-8').write(
        json.dumps(data, ensure_ascii=False, indent=0, sort_keys=True)
    )
    return data


def exclusions():
    """Cards deliberately given no emoji, with a written reason each."""
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


def is_picture(emoji):
    """True when the code points are pictographs rather than punctuation.

    CLDR annotates `&` and the maths symbols too, because they are in the
    emoji keyboard. They are not pictures and a card showing one has not
    gained anything, so they are dropped: matching German `und` to a literal
    ampersand illustrates nothing.
    """
    core = [c for c in emoji if c not in '‍️']
    if not core:
        return False
    for char in core:
        point = ord(char)
        if point in TOO_NEW:
            return False
        if not (point >= 0x1F000 or 0x2600 <= point <= 0x27BF):
            return False
    return True


def build():
    data = annotations()
    canonical = {}
    for emoji, value in sorted(data.items()):
        names = value.get('tts') or []
        if not names:
            continue
        canonical.setdefault(names[0].strip().lower(), emoji)

    skip = exclusions()
    have = already_illustrated()
    rows = []
    rejected_new = 0
    for cid, article, german, english, category, level in cards():
        if cid in have or cid in skip:
            continue
        emoji = canonical.get(german.strip().lower())
        if not emoji:
            continue
        if not is_picture(emoji):
            rejected_new += 1
            continue
        rows.append((cid, german, english, emoji, level))
    rows.sort(key=lambda r: r[0])
    return rows, len(skip), rejected_new


def write(rows):
    lines = [
        '/// Emoji for vocabulary cards. Generated by'
        ' tool/build_vocab_emoji.py.',
        '///',
        '/// Do not edit by hand. The source is the Unicode CLDR German',
        '/// annotation set: each entry matches a card whose German word is',
        '/// exactly what Unicode says the character depicts. Matching German',
        '/// to German rather than through the English gloss is what makes the',
        '/// precision usable -- the gloss route produced a tick mark for',
        '/// "pruefen" and a brightness slider for "im Gegensatz dazu".',
        '///',
        '/// These cost nothing. An emoji is a code point drawn by a font the',
        '/// device already has: no asset, no bundle bytes, no licence and',
        '/// nothing to attribute.',
        'library;',
        '',
        '/// Card id to emoji, for cards with no drawing and no pictogram.',
        'const Map<String, String> vocabEmoji = <String, String>{',
    ]
    for cid, german, english, emoji, level in rows:
        comment = german.replace('*/', '')
        lines.append("  '%s': '%s', // %s" % (cid, emoji, comment))
    lines.append('};')
    lines.append('')
    io.open(OUT, 'w', encoding='utf-8', newline='\n').write(chr(10).join(lines))


def main():
    rows, skipped, rejected = build()
    print('Vocabulary emoji')
    print('  matched            : %d' % len(rows))
    print('  excluded by hand   : %d (tool/vocab_emoji_excluded.tsv)' % skipped)
    print('  dropped, not a picture or too new : %d' % rejected)
    by_level = {}
    for row in rows:
        by_level[row[4]] = by_level.get(row[4], 0) + 1
    print('  by level           : %s' % dict(sorted(by_level.items())))

    if '--write' in sys.argv:
        write(rows)
        print('  wrote %s' % os.path.relpath(OUT, ROOT))
    else:
        print('\nRun with --write to regenerate lib/vocab_emoji.dart')
    return 0


if __name__ == '__main__':
    sys.exit(main())
