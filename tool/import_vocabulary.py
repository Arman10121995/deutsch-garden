#!/usr/bin/env python3
"""Append generated vocabulary cards to lib/vocabulary_extra.dart.

Reads a JSON array of cards on stdin or from a file, drops anything already in
the deck, assigns ids, and writes Dart. Everything it emits still has to pass
tool/validate_content.py -- this only handles the mechanical part.

    python tool/import_vocabulary.py cards.json

Each card is an object with: article, german, plural, english, exampleGerman,
exampleEnglish, category, level.
"""
from __future__ import annotations

from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
TARGET = LIB / 'vocabulary_extra.dart'
LEVELS = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'}
NO_PLURAL = '—'
ARTICLES = {'der', 'die', 'das', ''}

HEADER = '''import 'models.dart';

/// Vocabulary added after the 3.5 releases, written with real contextual
/// example sentences rather than the metalinguistic placeholder the earlier
/// expansion used.
///
/// Generated in batches and appended by tool/import_vocabulary.py. Every entry
/// still has to satisfy the German checks in tool/validate_content.py: correct
/// gender, a plural that matches the noun, and an example that actually uses
/// the word.
final List<GermanWord> extraVocabulary = <GermanWord>[
'''

FOOTER = '];\n'


def existing_lemmas() -> tuple[set, int]:
    """Every lemma already in the deck, and the highest numeric id in use."""
    lemmas = set()
    highest = 10000
    for path in sorted(LIB.glob('vocabulary*.dart')):
        text = path.read_text(encoding='utf-8')
        for article, german in re.findall(
                r"article:\s*'([^']*)',\s*german:\s*'([^']*)'", text):
            lemmas.add((article + ' ' + german).strip().lower())
        for found in re.findall(r"id:\s*'x(\d+)'", text):
            highest = max(highest, int(found))
    return lemmas, highest


def dart_string(value: str) -> str:
    """Escape for a Dart single-quoted literal."""
    return (value.replace('\\', '\\\\')
                 .replace("'", "\\'")
                 .replace('$', '\\$'))


def main() -> int:
    source = sys.stdin if len(sys.argv) < 2 else open(
        sys.argv[1], encoding='utf-8')
    cards = json.load(source)

    lemmas, highest = existing_lemmas()
    kept, skipped, rejected = [], [], []

    for card in cards:
        try:
            article = card['article'].strip()
            german = card['german'].strip()
            plural = card['plural'].strip()
        except (KeyError, AttributeError):
            rejected.append((str(card)[:40], 'missing fields'))
            continue

        lemma = (article + ' ' + german).strip().lower()
        if lemma in lemmas:
            skipped.append(german)
            continue

        # Cheap structural rejections, so obviously broken cards never reach
        # the Dart file and turn into a build failure instead.
        if article not in ARTICLES:
            rejected.append((german, 'article %r' % article))
            continue
        if card.get('level') not in LEVELS:
            rejected.append((german, 'level %r' % card.get('level')))
            continue
        if article and not german[:1].isupper():
            rejected.append((german, 'noun not capitalised'))
            continue
        if not article and plural != NO_PLURAL:
            plural = NO_PLURAL
        if article and plural != NO_PLURAL and not plural.startswith('die '):
            rejected.append((german, 'plural %r' % plural))
            continue
        if not card.get('exampleGerman', '').strip():
            rejected.append((german, 'no example'))
            continue

        lemmas.add(lemma)
        highest += 1
        card = dict(card)
        card['id'] = 'x%d' % highest
        card['plural'] = plural
        kept.append(card)

    if TARGET.exists():
        text = TARGET.read_text(encoding='utf-8')
        body = text[:text.rindex(FOOTER)] if FOOTER in text else HEADER
    else:
        body = HEADER

    for card in kept:
        body += (
            "  GermanWord(\n"
            "    id: '%s', article: '%s', german: '%s', plural: '%s',\n"
            "    english: '%s', exampleGerman: '%s',\n"
            "    exampleEnglish: '%s', category: '%s', level: '%s',\n"
            "  ),\n" % (
                card['id'], dart_string(card['article']),
                dart_string(card['german']), dart_string(card['plural']),
                dart_string(card['english']),
                dart_string(card['exampleGerman'].strip()),
                dart_string(card['exampleEnglish'].strip()),
                dart_string(card.get('category', 'General')), card['level'],
            ))

    with open(TARGET, 'w', encoding='utf-8', newline='') as handle:
        handle.write(body + FOOTER)

    print('added    %d' % len(kept))
    print('skipped  %d (already in the deck)' % len(skipped))
    print('rejected %d' % len(rejected))
    for word, why in rejected[:15]:
        print('   - %s: %s' % (word, why))
    total = len(re.findall(r'GermanWord\(', TARGET.read_text(encoding='utf-8')))
    print('vocabulary_extra.dart now holds %d cards' % total)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
