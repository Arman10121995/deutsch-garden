"""List the existing drawings each new vocabulary SVG most resembles.

A maintainer review aid, run beside render_svg_audit.py before a batch is
committed. The failure it exists for is the collision: a new drawing that is
fine on its own but reads as a card already drawn -- `verletzen` first came out
as the red circle-and-X that `Fehler` already was, and `traurig` first came out
as the plain frown `Entschuldigung` already wore. Nobody remembers 1,600
drawings, so this ranks them.

Every drawing is rendered at 24px on white and compared twice: as a silhouette
(which pixels are inked) and in colour. Small distances are candidates to look
at side by side, not verdicts: a colour-chip family is meant to be close to
itself, and two unrelated round faces will always be close in silhouette.

    python tool/svg_neighbours.py              # the changed and untracked set
    python tool/svg_neighbours.py x20428 x20143
"""
from __future__ import print_function

import argparse
import io
import os

import cairosvg
from PIL import Image

from render_svg_audit import ROOT, changed_svg_paths, vocabulary

ICON_DIR = os.path.join(ROOT, 'assets', 'vocab')
SIZE = 24


def _pixels(path):
    png = cairosvg.svg2png(url=path, output_width=SIZE, output_height=SIZE,
                           background_color='white')
    raw = bytearray(Image.open(io.BytesIO(png)).convert('RGB').tobytes())
    rgb = [channel / 255.0 for channel in raw]
    ink = [1.0 if raw[i] + raw[i + 1] + raw[i + 2] < 3 * 0.9 * 255 else 0.0
           for i in range(0, len(raw), 3)]
    return ink, rgb


def _distance(a, b):
    return sum((x - y) ** 2 for x, y in zip(a, b)) / len(a)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('ids', nargs='*',
                        help='card ids to check; default: changed drawings')
    parser.add_argument('--top', type=int, default=3)
    args = parser.parse_args()

    if args.ids:
        targets = [os.path.join(ICON_DIR, i + '.svg') for i in args.ids]
    else:
        targets = changed_svg_paths()
    target_ids = {os.path.basename(p)[:-4] for p in targets}
    if not targets:
        print('No changed drawings. Name card ids to check existing ones.')
        return

    words = vocabulary()
    cache = {}
    for name in sorted(os.listdir(ICON_DIR)):
        if name.endswith('.svg'):
            cache[name[:-4]] = _pixels(os.path.join(ICON_DIR, name))

    def label(card_id):
        word = words.get(card_id, (card_id, '', card_id))[2]
        return '%s %s%s' % (card_id, word, '*' if card_id in target_ids else '')

    for path in targets:
        card_id = os.path.basename(path)[:-4]
        ink, rgb = cache[card_id]
        others = [o for o in cache if o != card_id]
        by_ink = sorted(others, key=lambda o: _distance(ink, cache[o][0]))
        by_rgb = sorted(others, key=lambda o: _distance(rgb, cache[o][1]))
        print(label(card_id))
        print('  silhouette: ' + ', '.join(
            '%s (%.3f)' % (label(o), _distance(ink, cache[o][0]))
            for o in by_ink[:args.top]))
        print('  colour:     ' + ', '.join(
            '%s (%.3f)' % (label(o), _distance(rgb, cache[o][1]))
            for o in by_rgb[:args.top]))
    print('\n* = also in the checked set')


if __name__ == '__main__':
    main()
