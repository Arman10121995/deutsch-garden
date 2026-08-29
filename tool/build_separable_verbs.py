#!/usr/bin/env python3
"""Finds the separable verbs, so their prefix can be animated coming off.

Why animate this and almost nothing else
----------------------------------------
The evidence on animation in learning cuts both ways. Dual-coding supports it
for processes; Mayer's coherence principle says extraneous animation actively
hurts. A vocabulary list of wiggling tiles is plausibly worse than a still
one, which is why `docs/VISUAL_ROADMAP.md` records that motion was
deliberately *not* expanded across the deck.

A separable verb is the exception, because here the motion *is* the grammar.
`aufstehen` is one word in the infinitive and two pieces in a main clause --
*Ich stehe um sieben auf* -- with the prefix travelling to the end of the
clause. A learner who has watched that happen has seen the rule; a learner who
has read "the prefix goes to the end" has read a sentence about it.

Getting this wrong is worse than not doing it
---------------------------------------------
`wiederholen` looks exactly like a separable verb and is not one: the stress
falls on *holen*, and it stays whole -- *Ich wiederhole*. Animating it as
separable would teach a learner to say *Ich hole wieder*, which is a different
verb. So:

  * inseparable prefixes (be-, emp-, ent-, er-, ge-, miss-, ver-, zer-, and
    the ambiguous über-, unter-, um-, durch-, hinter-) are excluded outright;
  * `tool/separable_verbs_excluded.tsv` names the individual traps, with a
    reason each;
  * both parts must actually be verbs, checked by the English gloss beginning
    "to " -- without that, `hingegen` (whereas) came through as hin + gegen.

Usage:
    python tool/build_separable_verbs.py            # report
    python tool/build_separable_verbs.py --write    # regenerate the Dart
"""

from __future__ import annotations

import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'lib', 'separable_verbs.dart')
COMPOUNDS = os.path.join(ROOT, 'lib', 'vocab_compounds.dart')
EXCLUSIONS = os.path.join(ROOT, 'tool', 'separable_verbs_excluded.tsv')

FIELD = (r"id: '([^']*)'[^)]*?article: '([^']*)'[^)]*?german: '([^']*)'"
         r"[^)]*?english: '([^']*)'[^)]*?category: '([^']*)'[^)]*?level: '([^']*)'")

# Always stressed, always detach in a main clause.
SEPARABLE = {
    'ab', 'an', 'auf', 'aus', 'bei', 'ein', 'fest', 'her', 'hin', 'los',
    'mit', 'nach', 'vor', 'weg', 'wieder', 'zu', 'zurück', 'zusammen',
    'fort', 'heraus', 'herein', 'hinaus', 'hinein', 'statt', 'teil',
    'frei', 'nieder', 'entgegen', 'voran',
}

# Never detach, or detach only in one of two meanings. Excluded outright
# rather than guessed at: the ambiguous ones (über, unter, um, durch, hinter)
# are separable in a literal sense and inseparable in a figurative one, and
# nothing in the card data says which sense the card teaches.
INSEPARABLE = {
    'be', 'emp', 'ent', 'er', 'ge', 'miss', 'ver', 'zer', 'voll',
    'über', 'unter', 'um', 'durch', 'hinter', 'wider',
}


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


def is_verb(english):
    """A verb card glosses as "to ...". Nothing else in the deck does."""
    return english.strip().lower().startswith('to ')


def build():
    by_id = {c[0]: c for c in cards()}
    compounds = re.findall(
        r"'([^']+)': VocabCompound\('([^']*)', '([^']*)', '([^']*)'\)",
        io.open(COMPOUNDS, encoding='utf-8').read(),
    )
    skip = exclusions()

    rows = []
    for cid, modifier_id, head_id, link in compounds:
        if cid in skip:
            continue
        if cid not in by_id or modifier_id not in by_id or head_id not in by_id:
            continue
        _, article, german, english, _, level = by_id[cid]
        _, _, prefix, _, _, _ = by_id[modifier_id]
        _, _, stem, head_english, _, _ = by_id[head_id]

        if article in ('der', 'die', 'das'):
            continue
        # Both halves must be verbs. Without this, hingegen (whereas) arrives
        # as hin + gegen and gets animated as though it conjugated.
        if not is_verb(english) or not is_verb(head_english):
            continue
        if link:
            # A separable prefix joins its verb directly. A linking element
            # means this is a noun-style compound that happens to end in -en.
            continue
        prefix_lower = prefix.strip().lower()
        if prefix_lower in INSEPARABLE or prefix_lower not in SEPARABLE:
            continue
        if not german.strip().lower().startswith(prefix_lower):
            continue
        # Lowercased: a separable prefix is never capitalised inside the
        # verb, even when the card it came from is a noun. teilnehmen is
        # Teil + nehmen but conjugates as "Ich nehme teil".
        rows.append((cid, prefix.strip().lower(), stem.strip(), level))
    rows.sort(key=lambda r: r[0])
    return rows, len(skip)


def write(rows):
    lines = [
        '/// Separable verbs, so the prefix can be shown coming off.',
        '/// Generated by tool/build_separable_verbs.py. Do not edit by hand.',
        '///',
        '/// This is the one place in the app where animation is used for',
        '/// meaning rather than decoration: the prefix travelling to the end',
        '/// of the clause IS the rule. See the tool for why almost nothing',
        '/// else is animated, and why wiederholen is deliberately absent.',
        'library;',
        '',
        '/// A verb that splits, and what it splits into.',
        'class SeparableVerb {',
        '  const SeparableVerb(this.prefix, this.stem);',
        '',
        '  /// The piece that detaches and goes to the end of a main clause.',
        '  final String prefix;',
        '',
        '  /// The piece that stays put and conjugates.',
        '  final String stem;',
        '}',
        '',
        '/// Card id to its split.',
        'const Map<String, SeparableVerb> separableVerbs = '
        '<String, SeparableVerb>{',
    ]
    for cid, prefix, stem, level in rows:
        lines.append("  '%s': SeparableVerb('%s', '%s')," % (cid, prefix, stem))
    lines.append('};')
    lines.append('')
    io.open(OUT, 'w', encoding='utf-8', newline='\n').write(chr(10).join(lines))


def main():
    rows, skipped = build()
    print('Separable verbs')
    print('  found            : %d' % len(rows))
    print('  excluded by hand : %d (%s)'
          % (skipped, os.path.relpath(EXCLUSIONS, ROOT)))
    by_level = {}
    for row in rows:
        by_level[row[3]] = by_level.get(row[3], 0) + 1
    print('  by level         : %s' % dict(sorted(by_level.items())))

    if '--write' in sys.argv:
        write(rows)
        print('  wrote %s' % os.path.relpath(OUT, ROOT))
    else:
        print('\nRun with --write to regenerate lib/separable_verbs.dart')
    return 0


if __name__ == '__main__':
    sys.exit(main())
