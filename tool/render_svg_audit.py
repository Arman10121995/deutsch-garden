"""Render the current vocabulary-SVG working set as labelled contact sheets.

This is a maintainer review tool, not a source-image generator. By default it
shows modified and untracked drawings, which makes a large incoming batch
reviewable before it is committed.
"""
from __future__ import print_function

import argparse
import io
import os
import re
import subprocess

import cairosvg
from PIL import Image, ImageDraw, ImageFont


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def vocabulary():
    fields = re.compile(
        r"id:\s*'([^']*)'.*?article:\s*'([^']*)'.*?german:\s*'([^']*)'"
        r".*?english:\s*'([^']*)'.*?category:\s*'([^']*)'.*?level:\s*'([^']*)'",
        re.S,
    )
    result = {}
    lib = os.path.join(ROOT, 'lib')
    for name in sorted(os.listdir(lib)):
        if not (name.startswith('vocabulary') and name.endswith('.dart')):
            continue
        with io.open(os.path.join(lib, name), encoding='utf-8') as source:
            for match in fields.findall(source.read()):
                result[match[0]] = match
    return result


def changed_svg_paths():
    raw = subprocess.check_output(
        ['git', 'status', '--porcelain', '--', 'assets/vocab'],
        cwd=ROOT,
    ).decode('utf-8')
    paths = []
    for line in raw.splitlines():
        relative = line[3:].strip().replace('/', os.sep)
        if relative.endswith('.svg'):
            paths.append(os.path.join(ROOT, relative))
    return sorted(paths, key=lambda path: os.path.basename(path))


def font(size):
    windows = os.path.join(os.environ.get('WINDIR', r'C:\Windows'), 'Fonts')
    for name in ('segoeui.ttf', 'arial.ttf'):
        path = os.path.join(windows, name)
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def render(paths, output_dir):
    words = vocabulary()
    os.makedirs(output_dir, exist_ok=True)
    columns, rows, cell = 6, 6, 210
    label_font = font(18)
    detail_font = font(13)
    for page_start in range(0, len(paths), columns * rows):
        page = Image.new('RGB', (columns * cell, rows * cell), 'white')
        draw = ImageDraw.Draw(page)
        for local_index, path in enumerate(paths[page_start:page_start + columns * rows]):
            column = local_index % columns
            row = local_index // columns
            x, y = column * cell, row * cell
            word_id = os.path.splitext(os.path.basename(path))[0]
            data = words.get(word_id, (word_id, '', '?', '?', '', '?'))
            png = cairosvg.svg2png(url=path, output_width=112, output_height=112)
            icon = Image.open(io.BytesIO(png)).convert('RGBA')
            page.paste(icon, (x + 49, y + 8), icon)
            draw.rectangle((x, y, x + cell - 1, y + cell - 1), outline='#dddddd')
            draw.text((x + 8, y + 124), '%s  %s' % (word_id, data[2]), fill='#111111', font=label_font)
            draw.text((x + 8, y + 150), data[3][:25], fill='#555555', font=detail_font)
            draw.text((x + 8, y + 171), '%s  %s  %s' % (data[1], data[5], data[4]), fill='#777777', font=detail_font)
        page_number = page_start // (columns * rows) + 1
        target = os.path.join(output_dir, 'vocab-svg-audit-%02d.png' % page_number)
        page.save(target, optimize=True)
        print(target)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('output_dir')
    args = parser.parse_args()
    render(changed_svg_paths(), os.path.abspath(args.output_dir))


if __name__ == '__main__':
    main()
