#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""The tile's category pictogram must actually fire for the deck's categories.

`_categoryIcon` in lib/vocab_icon.dart maps a card's category to a pictogram
and falls through to the word-class icon when nothing matches. That fallback
is correct for a card whose category genuinely carries no topic. It is a bug
when it happens because the mapping was written against category names the
deck does not use -- and that is exactly what had happened: the branches
matched `food`, `travel`, `home` and so on, while the deck's four commonest
categories are `General`, `Actions`, `Description` and `Abstract`. Nine cards
in ten fell through, so the tile documented itself as showing a category
pictogram and showed a word-class icon instead.

Nothing failed. No test broke. The only symptom was thousands of identical
tiles, which is invisible unless somebody counts. So this counts.

The check re-implements the matching in Python from the Dart source, which
means it cannot drift into agreeing with a stale copy of the rules: if a
branch is deleted from the Dart, the Python stops seeing it too and the
coverage number moves.

Two things are asserted:

1. Every category the deck uses on more than MIN_SHARE of uncovered cards is
   either matched by a branch, or named in EXPECTED_FALLTHROUGH with a reason.
   A new bulk category added to the content later must be handled, not
   silently absorbed by the fallback.
2. Overall fallthrough stays at or below MAX_FALLTHROUGH. That budget is
   sized around `General`, which is the deck's way of saying "no topic" and
   is deliberately unmapped.
"""
from __future__ import print_function

import io
import os
import re
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# A category may be left to the word-class fallback only if it is listed here,
# with the reason it carries no topic of its own.
EXPECTED_FALLTHROUGH = {
    'general': 'the deck\'s marker for a card with no topic; inventing one '
               'would attach a category the content does not claim',
}

# Share of uncovered cards above which a category must be handled explicitly.
MIN_SHARE = 0.005          # 0.5%, i.e. about 42 cards
MAX_FALLTHROUGH = 0.42     # General alone is 37.5%; this leaves a little room


def read(path):
    return io.open(os.path.join(ROOT, path), encoding='utf-8').read()


def branch_keys():
    """The substrings _categoryIcon actually tests, read from the Dart."""
    source = read(os.path.join('lib', 'vocab_icon.dart'))
    start = source.index('IconData _categoryIcon(')
    end = source.index('\n}', start)
    body = source[start:end]
    keys = re.findall(r"value\.contains\('([^']+)'\)", body)
    if not keys:
        raise SystemExit('check_category_icons: no contains() branches found; '
                         'has _categoryIcon been rewritten?')
    return keys


def vocabulary():
    fields = re.compile(
        r"id: '([^']*)'.*?german: '([^']*)'.*?category: '([^']*)'",
        re.S)
    rows = []
    lib = os.path.join(ROOT, 'lib')
    for name in sorted(os.listdir(lib)):
        if name.startswith('vocabulary') and name.endswith('.dart'):
            rows += fields.findall(read(os.path.join('lib', name)))
    return rows


def uncovered(rows):
    drawn = set()
    folder = os.path.join(ROOT, 'assets', 'vocab')
    if os.path.isdir(folder):
        drawn = {f[:-4] for f in os.listdir(folder) if f.endswith('.svg')}
    emoji = set(re.findall(r"'([^']+)': '",
                           read(os.path.join('lib', 'vocab_emoji.dart'))))
    generated = set(re.findall(
        r"'([^']+)': 'assets/vocab_generated",
        read(os.path.join('lib', 'vocab_icon.dart'))))
    out = []
    for cid, german, category in rows:
        if cid in drawn or cid in emoji:
            continue
        if german.strip().lower() in generated:
            continue
        out.append((cid, german, category))
    return out


def main():
    keys = branch_keys()
    cards = uncovered(vocabulary())
    if not cards:
        raise SystemExit('check_category_icons: no uncovered cards found')

    counts = {}
    for _cid, _german, category in cards:
        counts[category] = counts.get(category, 0) + 1

    problems = []
    fell_through = 0
    for category, count in sorted(counts.items(), key=lambda kv: -kv[1]):
        value = category.lower()
        matched = any(key in value for key in keys)
        if matched:
            continue
        fell_through += count
        share = float(count) / len(cards)
        if value in EXPECTED_FALLTHROUGH:
            continue
        if share > MIN_SHARE:
            problems.append(
                '  %-16s %5d cards (%.1f%%) matches no branch in '
                '_categoryIcon' % (category, count, 100.0 * share))

    ratio = float(fell_through) / len(cards)
    print('uncovered cards            : %d' % len(cards))
    print('matched a category branch  : %d (%.1f%%)'
          % (len(cards) - fell_through, 100.0 * (1 - ratio)))
    print('fell through to word class : %d (%.1f%%)'
          % (fell_through, 100.0 * ratio))

    if ratio > MAX_FALLTHROUGH:
        problems.append(
            '  overall fallthrough %.1f%% exceeds the %.1f%% budget'
            % (100.0 * ratio, 100.0 * MAX_FALLTHROUGH))

    if problems:
        print()
        print('CATEGORY PICTOGRAM COVERAGE')
        for line in problems:
            print(line)
        print()
        print('Either add a branch to _categoryIcon in lib/vocab_icon.dart, or')
        print('list the category in EXPECTED_FALLTHROUGH here with the reason')
        print('it carries no topic of its own.')
        return 1

    print('category pictogram coverage OK')
    return 0


if __name__ == '__main__':
    sys.exit(main())
