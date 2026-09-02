"""Crop the reviewed 4x4 vocabulary scene source into runtime assets."""
from __future__ import print_function

import os
import sys

from PIL import Image


NAMES = (
    'kaufen', 'bezahlen', 'fragen', 'antworten',
    'helfen', 'warten', 'suchen', 'finden',
    'reisen', 'telefonieren', 'lernen', 'arbeiten',
    'feiern', 'treffen', 'krank', 'gesund',
)


def main():
    if len(sys.argv) != 3:
        raise SystemExit('usage: crop_vocab_scene_sheet.py SOURCE.png OUTPUT_DIR')
    source, output_dir = sys.argv[1:]
    image = Image.open(source).convert('RGB')
    width, height = image.size
    if width != height:
        raise SystemExit('scene sheet must be square')
    os.makedirs(output_dir, exist_ok=True)
    for index, name in enumerate(NAMES):
        row, column = divmod(index, 4)
        left = column * width // 4
        right = (column + 1) * width // 4
        top = row * height // 4
        bottom = (row + 1) * height // 4
        tile = image.crop((left, top, right, bottom))
        target = os.path.join(output_dir, name + '.png')
        tile.save(target, optimize=True)
        print(target)


if __name__ == '__main__':
    main()
