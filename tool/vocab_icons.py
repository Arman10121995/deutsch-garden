"""Vocabulary icon progress: what is drawn, what never will be, what is left.

State lives on disk rather than in anyone's head, so this is resumable after
an interruption:

  * drawn        -> a file exists at assets/vocab/<id>.svg
  * undrawable   -> the id is listed in tool/vocab_icons_undrawable.tsv
  * remaining    -> an A1/A2 noun that is neither

Run with no arguments for a count, or `next N` to print the next N words to
draw.
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ICON_DIR = os.path.join(ROOT, 'assets', 'vocab')
SKIP_FILE = os.path.join(ROOT, 'tool', 'vocab_icons_undrawable.tsv')

FIELD = (r"id: '([^']*)'[^)]*?article: '([^']*)'[^)]*?german: '([^']*)'"
         r"[^)]*?english: '([^']*)'[^)]*?category: '([^']*)'[^)]*?level: '([^']*)'")


def nouns():
    """A1 and A2 nouns, in file order. The drawable set."""
    out, seen = [], set()
    lib = os.path.join(ROOT, 'lib')
    for name in sorted(os.listdir(lib)):
        if not (name.startswith('vocabulary') and name.endswith('.dart')):
            continue
        text = io.open(os.path.join(lib, name), encoding='utf-8').read()
        for cid, art, ger, eng, cat, lvl in re.findall(FIELD, text, re.S):
            if art not in ('der', 'die', 'das'):
                continue
            if lvl.upper() not in ('A1', 'A2'):
                continue
            if ger.lower() in seen:
                continue
            seen.add(ger.lower())
            out.append({'id': cid, 'article': art, 'german': ger,
                        'english': eng, 'category': cat, 'level': lvl.upper()})
    return out


def drawn():
    if not os.path.isdir(ICON_DIR):
        return set()
    return {f[:-4] for f in os.listdir(ICON_DIR) if f.endswith('.svg')}


def undrawable():
    out = {}
    if not os.path.exists(SKIP_FILE):
        return out
    for line in io.open(SKIP_FILE, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line or line.startswith('#'):
            continue
        parts = line.split('\t')
        if len(parts) >= 3:
            out[parts[0]] = parts[2]
    return out


def remaining():
    have, skip = drawn(), undrawable()
    return [w for w in nouns() if w['id'] not in have and w['id'] not in skip]


def main():
    words = nouns()
    have, skip, left = drawn(), undrawable(), remaining()
    if len(sys.argv) > 1 and sys.argv[1] == 'next':
        count = int(sys.argv[2]) if len(sys.argv) > 2 else 40
        for w in left[:count]:
            print('%s\t%s %s\t%s' % (w['id'], w['article'], w['german'],
                                     w['english']))
        return
    print('drawable nouns : %d' % len(words))
    print('drawn          : %d' % len(have))
    print('undrawable     : %d' % len(skip))
    print('remaining      : %d' % len(left))


if __name__ == '__main__':
    main()
