"""Write a recorded judgement for every card, hand decisions winning.

`cefr_relevelling.tsv` has to cover the whole deck for the audit to mean
anything: a card with no row is a card nobody has looked at, and until every
row exists there is no way to tell those apart from the ones that were checked
and left alone.

Two bases, never conflated:

  hand    someone read the card and decided. 23 of these, and they win.
  corpus  derived by `cefr_evidence.py` from the level of the bundled material
          that uses the word. Reproduces 22 of the 23 hand judgements, which
          is why it is trusted enough to record -- and it is still recorded as
          derived, because agreeing with a human is not the same as being one.

Usage:
    python tool/build_relevelling.py --write
"""
import io
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAP = os.path.join(ROOT, 'tool', 'cefr_relevelling.tsv')
TAB = chr(9)

HEADER = """# Sense-specific CEFR judgements on individual cards.
#
# The deck's A1-C2 labels came from bulk import, not from reading each card, and
# the bulk was wrong in both directions. This file is the record of what has been
# decided about every card -- including the ones left alone, because "reviewed and
# correct" and "never reviewed" are different states and only one of them is
# worth revisiting.
#
# It is authoritative. tool/apply_relevelling.py writes these levels into
# lib/vocabulary*.dart, and tool/check_relevelling.py fails the build if the
# source and this file disagree, so a later bulk edit cannot quietly undo a
# judgement recorded here.
#
# The `basis` column says how a row was decided and must not be blurred:
#
#   hand    a person read the card. These win over anything derived.
#   corpus  derived by tool/cefr_evidence.py from the level of the bundled
#           material that uses the word. It reproduces 22 of the 23 hand
#           judgements, which is why it is trusted enough to record; it is
#           still marked derived, because agreeing with a human is not the
#           same as being one.
#
# A row whose `to` equals its `from` is a deliberate keep, not a no-op.
#
# id<TAB>german<TAB>from<TAB>to<TAB>basis<TAB>why
"""


def existing_hand():
    """Rows a person decided, which no derived pass may overwrite."""
    out = {}
    if not os.path.exists(MAP):
        return out
    for line in io.open(MAP, encoding='utf-8'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split(TAB)
        if len(parts) == 5:
            # The original five-column form predates the basis column and was
            # entirely hand-written.
            cid, german, before, after, why = parts
            out[cid] = (cid, german, before, after, 'hand', why)
        elif len(parts) >= 6 and parts[4] == 'hand':
            out[parts[0]] = tuple(parts[:6])
    return out


def proposals():
    result = subprocess.run(
        [sys.executable, os.path.join(ROOT, 'tool', 'cefr_evidence.py'),
         '--propose'],
        capture_output=True, text=True, encoding='utf-8', errors='replace')
    if result.returncode != 0:
        sys.stderr.write(result.stderr)
        raise SystemExit(2)
    rows = []
    for line in result.stdout.splitlines():
        if not line.strip():
            continue
        parts = line.split(TAB)
        if len(parts) >= 6:
            rows.append(tuple(parts[:6]))
    return rows


def main():
    hand = existing_hand()
    derived = proposals()
    if not derived:
        raise SystemExit('cefr_evidence.py proposed nothing')

    rows = []
    kept_hand = 0
    for row in derived:
        cid = row[0]
        if cid in hand:
            rows.append(hand[cid])
            kept_hand += 1
        else:
            rows.append(row)

    if '--write' not in sys.argv:
        print('%d rows: %d hand, %d corpus' %
              (len(rows), kept_hand, len(rows) - kept_hand))
        print('Nothing written. Re-run with --write.')
        return 0

    with io.open(MAP, 'w', encoding='utf-8', newline=chr(10)) as handle:
        handle.write(HEADER)
        for row in rows:
            handle.write(TAB.join(row) + chr(10))
    print('wrote %d rows: %d hand, %d corpus' %
          (len(rows), kept_hand, len(rows) - kept_hand))
    return 0


if __name__ == '__main__':
    sys.exit(main())
