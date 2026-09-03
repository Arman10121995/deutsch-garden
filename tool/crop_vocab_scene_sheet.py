"""Crop a reviewed square vocabulary scene sheet into runtime assets.

With no names this preserves the original 4x4 batch. Supplying names lets a
reviewer process a smaller square batch without maintaining a throwaway script:

    python tool/crop_vocab_scene_sheet.py sheet.png assets/vocab_generated \
        essen fahren sprechen hoeren
"""
from __future__ import print_function

import os
import sys
from math import sqrt

from PIL import Image


NAMES = (
    'kaufen', 'bezahlen', 'fragen', 'antworten',
    'helfen', 'warten', 'suchen', 'finden',
    'reisen', 'telefonieren', 'lernen', 'arbeiten',
    'feiern', 'treffen', 'krank', 'gesund',
)


def main():
    if len(sys.argv) < 3:
        raise SystemExit(
            'usage: crop_vocab_scene_sheet.py SOURCE.png OUTPUT_DIR [NAME ...]'
        )
    source, output_dir = sys.argv[1:3]
    names = tuple(sys.argv[3:]) or NAMES
    # The release machine still exposes Python 2 as `python`; keep this tiny
    # authoring helper compatible with it rather than requiring another tool.
    side = int(sqrt(len(names)))
    if side * side != len(names):
        raise SystemExit('the number of tile names must be a square')
    image = Image.open(source).convert('RGB')
    width, height = image.size
    if width != height:
        raise SystemExit('scene sheet must be square')
    os.makedirs(output_dir, exist_ok=True)
    for index, name in enumerate(names):
        row, column = divmod(index, side)
        left = column * width // side
        right = (column + 1) * width // side
        top = row * height // side
        bottom = (row + 1) * height // side
        tile = image.crop((left, top, right, bottom))
        # Runtime cards never render above 96 logical pixels. 384 preserves a
        # crisp 4x source on high-density phones without decoding a 627px tile
        # for every list row in the newer 2x2 batches.
        if tile.width > 384:
            tile = tile.resize((384, 384), Image.LANCZOS)
        target = os.path.join(output_dir, name + '.png')
        tile.save(target, optimize=True)
        print(target)


if __name__ == '__main__':
    main()
