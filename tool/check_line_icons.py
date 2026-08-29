"""Check the third-party line icons against their mapping and their licence.

These are the only images in the bundle this project did not draw, which makes
them the only ones with an obligation attached. Three things have to stay true
and none of them is visible in the app:

  * every file corresponds to a row in tool/vocab_line_icons.tsv, so an icon
    cannot appear with nobody able to say where it came from;
  * every row names a real vocabulary card;
  * the licence text is present, and each file still carries its attribution
    comment -- which is what an "unmodified apart from the wrapper" claim
    rests on.

It also enforces the same provenance rules the drawn icons have: no embedded
raster, no script, no remote reference.

Usage:
    python tool/check_line_icons.py
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIR = os.path.join(ROOT, 'assets', 'vocab_line')
MAP = os.path.join(ROOT, 'tool', 'vocab_line_icons.tsv')
LICENCE = os.path.join(DIR, 'LICENSE-tabler.txt')
LIB = os.path.join(ROOT, 'lib')

CARD = r"id: '([^']*)'(?:(?!id: ').)*?german: '([^']*)'"


def deck():
    out = {}
    for name in sorted(os.listdir(LIB)):
        if name.startswith('vocabulary') and name.endswith('.dart'):
            text = io.open(os.path.join(LIB, name), encoding='utf-8').read()
            for cid, german in re.findall(CARD, text, re.S):
                out[cid] = german
    return out


def mapping():
    rows = {}
    for number, line in enumerate(io.open(MAP, encoding='utf-8'), 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split(chr(9))
        if len(parts) < 3:
            raise SystemExit('%s line %d: expected 3 fields' % (MAP, number))
        rows[parts[0]] = (parts[1], parts[2])
    return rows


def main():
    if not os.path.isdir(DIR):
        print('no assets/vocab_line directory; nothing to check')
        return 0

    cards = deck()
    rows = mapping()
    errors = []

    if not os.path.exists(LICENCE):
        errors.append('the licence text is missing; these icons are MIT and '
                      'the notice has to ship with them')

    files = sorted(f for f in os.listdir(DIR) if f.endswith('.svg'))
    for name in files:
        cid = name[:-4]
        path = os.path.join(DIR, name)
        svg = io.open(path, encoding='utf-8').read()

        if cid not in rows:
            errors.append('%s has no row in vocab_line_icons.tsv, so nobody '
                          'can say where it came from' % name)
        if cid not in cards:
            errors.append('%s matches no vocabulary card' % name)
        if 'viewBox="0 0 64 64"' not in svg:
            errors.append('%s is off the shared 64x64 grid' % name)
        if 'MIT' not in svg or 'tabler' not in svg.lower():
            errors.append('%s has lost its attribution comment' % name)
        if '<image' in svg:
            errors.append('%s embeds a raster' % name)
        if '<script' in svg:
            errors.append('%s contains a script' % name)
        stripped = svg.replace('http://www.w3.org/2000/svg', '')
        stripped = stripped.replace('https://tabler.io/icons', '')
        if 'http' in stripped:
            errors.append('%s reaches out to the network' % name)

    for cid, (german, icon) in sorted(rows.items()):
        if cid not in cards:
            errors.append('the mapping claims %s (%s), which is not a card'
                          % (cid, german))
        elif cards[cid] != german:
            errors.append('the mapping calls %s "%s"; the deck says "%s"'
                          % (cid, german, cards[cid]))
        elif not os.path.exists(os.path.join(DIR, '%s.svg' % cid)):
            errors.append('%s (%s) is mapped to tabler:%s but never fetched; '
                          'run tool/fetch_line_icons.py --write'
                          % (cid, german, icon))

    if errors:
        print('LINE ICON CHECK FAILED')
        for error in errors:
            print('  - %s' % error)
        return 1

    print('LINE ICON CHECK PASSED')
    print('  icons   : %d' % len(files))
    print('  mapped  : %d' % len(rows))
    print('  licence : present')
    return 0


if __name__ == '__main__':
    sys.exit(main())
