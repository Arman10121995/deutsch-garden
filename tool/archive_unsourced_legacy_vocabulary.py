#!/usr/bin/env python3
"""Retire unsourced legacy placeholder cards without losing their records.

This is the second, mechanical stage of ``upgrade_legacy_vocabulary_examples``.
It removes only cards that still carry the exact legacy placeholder phrase and
whose attribution-ledger status is ``unsourced``.  Every original field is
written to a migration/audit archive before the active Dart list is updated.
"""
from __future__ import print_function

import csv
import importlib.util
import io
from pathlib import Path
import re
from collections import Counter


ROOT = Path(__file__).resolve().parents[1]
EXPANSION = ROOT / 'lib' / 'vocabulary_expansion.dart'
ATTRIBUTIONS = ROOT / 'docs' / 'LEGACY_VOCABULARY_ATTRIBUTIONS.tsv'
ARCHIVE = ROOT / 'docs' / 'LEGACY_VOCABULARY_UNSOURCED_ARCHIVE.tsv'
PLACEHOLDER_PREFIX = 'Das Lernwort heute ist'
EXPECTED = 182


def load_generator():
    path = ROOT / 'tool' / 'generate_vocabulary_6000.py'
    spec = importlib.util.spec_from_file_location('vocabulary_6000', str(path))
    if spec is None or spec.loader is None:
        raise RuntimeError('cannot load generate_vocabulary_6000.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


GEN = load_generator()


def ledger_statuses():
    with io.open(str(ATTRIBUTIONS), encoding='utf-8', newline='') as handle:
        return {row['card_id']: row['status']
                for row in csv.DictReader(handle, delimiter='\t')}


def block_span(text, match):
    """Return the whole two/three-line ``GermanWord(...),`` record span."""
    start = text.rfind('\n', 0, match.start()) + 1
    tail = re.match(r",\s*\r?\n\s*\),\s*\r?\n", text[match.end():])
    if tail is None:
        raise RuntimeError('cannot resolve record boundary for %s' %
                           match.group('id'))
    end = match.end() + tail.end()
    if 'GermanWord(' not in text[start:end]:
        raise RuntimeError('invalid record span for %s' % match.group('id'))
    return start, end


def write_archive(cards):
    fields = [
        'id', 'article', 'german', 'plural', 'english', 'exampleGerman',
        'exampleEnglish', 'category', 'level', 'status', 'retired_reason',
    ]
    with io.open(str(ARCHIVE), 'w', encoding='utf-8', newline='') as handle:
        writer = csv.DictWriter(handle, fieldnames=fields, delimiter='\t',
                                lineterminator='\n')
        writer.writeheader()
        for card in cards:
            writer.writerow({
                'id': card['id'],
                'article': card['article'],
                'german': card['german'],
                'plural': card['plural'],
                'english': card['english'],
                'exampleGerman': card['eg'],
                'exampleEnglish': card['ee'],
                'category': card['category'],
                'level': card['level'],
                'status': 'retired_unsourced',
                'retired_reason': (
                    'no safe exact target/POS/sense pair in pinned '
                    'ManyThings/Tatoeba corpus'),
            })


def main():
    text = EXPANSION.read_text(encoding='utf-8')
    matches = list(GEN.CARD_RE.finditer(text))
    placeholders = [match for match in matches
                    if match.group('eg').startswith(PLACEHOLDER_PREFIX)]
    if len(placeholders) != EXPECTED:
        raise RuntimeError('expected %d remaining placeholders, found %d' %
                           (EXPECTED, len(placeholders)))

    statuses = ledger_statuses()
    wrong_status = [match.group('id') for match in placeholders
                    if statuses.get(match.group('id')) != 'unsourced']
    if wrong_status:
        raise RuntimeError('placeholder cards are not ledger-unsourced: %s' %
                           ', '.join(wrong_status))

    cards = [match.groupdict() for match in placeholders]
    if len({card['id'] for card in cards}) != EXPECTED:
        raise RuntimeError('duplicate retired vocabulary ID')

    spans = [block_span(text, match) for match in placeholders]
    updated = text
    for start, end in reversed(spans):
        updated = updated[:start] + updated[end:]

    remaining_cards = list(GEN.CARD_RE.finditer(updated))
    remaining_ids = {match.group('id') for match in remaining_cards}
    retired_ids = {card['id'] for card in cards}
    if remaining_ids & retired_ids:
        raise RuntimeError('a retired ID remains active')
    if len(matches) - len(remaining_cards) != EXPECTED:
        raise RuntimeError('active-card delta is not %d' % EXPECTED)
    if PLACEHOLDER_PREFIX in updated:
        raise RuntimeError('a placeholder phrase remains after retirement')

    # Archive first so a successful active-list mutation can never lose the
    # historical records needed by unlock migration.
    write_archive(cards)
    with io.open(str(EXPANSION), 'w', encoding='utf-8', newline='') as handle:
        handle.write(updated)

    counts = Counter(card['level'] for card in cards)
    print('Retired legacy cards:', len(cards))
    for level in GEN.LEVELS:
        ids = [card['id'] for card in cards if card['level'] == level]
        print('%s\t%d\t%s' % (level, counts[level], ','.join(ids)))
    print('Wrote', ARCHIVE)
    print('Updated', EXPANSION)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
