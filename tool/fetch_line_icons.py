"""Fetch the mapped Tabler icons into assets/vocab_line/.

Run once when the mapping changes; the results are committed, so a build never
depends on the network. That matters more here than usual: the app's whole
premise is that it works offline, and an asset pipeline that quietly needs a
connection would be the one part that does not.

Every icon is verified rather than assumed. A name that does not exist upstream
is reported by id and word instead of leaving a hole nobody notices, and a
response that is not a plain SVG is refused.

Usage:
    python tool/fetch_line_icons.py            # report what is missing
    python tool/fetch_line_icons.py --write    # download them
"""
import io
import os
import re
import sys
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAP = os.path.join(ROOT, 'tool', 'vocab_line_icons.tsv')
OUT = os.path.join(ROOT, 'assets', 'vocab_line')
PREFIX = 'tabler'
API = 'https://api.iconify.design/%s/%s.svg'


def mapping():
    rows = []
    for number, line in enumerate(io.open(MAP, encoding='utf-8'), 1):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split(chr(9))
        if len(parts) < 3:
            raise SystemExit('%s line %d: expected 3 fields' % (MAP, number))
        rows.append((parts[0], parts[1], parts[2]))
    return rows


def normalise(svg, name):
    """Put the upstream icon on the shared grid without redrawing it.

    Only the outer <svg> attributes change: the paths are untouched, which is
    what keeps this a use of the icon rather than a derivative of it.
    """
    if '<svg' not in svg or '</svg>' not in svg:
        return None, 'the response was not an SVG'
    if '<image' in svg or 'http://' in svg.replace('http://www.w3.org', ''):
        return None, 'the icon embeds a raster or a remote reference'
    if '<script' in svg:
        return None, 'the icon contains a script'
    # 24x24 upstream, scaled onto the 64x64 grid the drawn icons use, with a
    # little padding so a stroke does not sit on the edge.
    body = svg[svg.index('>', svg.index('<svg')) + 1:svg.rindex('</svg>')]
    out = (
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
        '<!-- Tabler Icons (%s), MIT, https://tabler.io/icons -->'
        '<g transform="translate(6.4 6.4) scale(2.1333)">%s</g>'
        '</svg>' % (name, body)
    )
    return out, None


def main():
    write = '--write' in sys.argv
    rows = mapping()
    if write and not os.path.isdir(OUT):
        os.makedirs(OUT)

    ok = 0
    failures = []
    for cid, german, name in rows:
        target = os.path.join(OUT, '%s.svg' % cid)
        if os.path.exists(target) and not write:
            ok += 1
            continue
        try:
            # A User-Agent is required: the API answers urllib's default with
            # 403, which reads as "no such icon" if you are not looking.
            request = urllib.request.Request(
                API % (PREFIX, name),
                headers={'User-Agent': 'deutsch-garden-icon-fetch/1.0'})
            with urllib.request.urlopen(request, timeout=20) as r:
                raw = r.read().decode('utf-8')
        except Exception as error:
            failures.append((cid, german, name, str(error)))
            continue
        # Iconify answers an unknown name with a 404-shaped SVG rather than an
        # HTTP error, so the content has to be checked, not the status.
        if 'viewBox' not in raw or len(raw) < 80:
            failures.append((cid, german, name, 'no such icon upstream'))
            continue
        svg, problem = normalise(raw, name)
        if svg is None:
            failures.append((cid, german, name, problem))
            continue
        if write:
            io.open(target, 'w', encoding='utf-8').write(svg)
        ok += 1

    print('%d mapped, %d fetched, %d failed' % (len(rows), ok, len(failures)))
    for cid, german, name, why in failures:
        print('  %-8s %-14s tabler:%-22s %s' % (cid, german, name, why))
    if failures:
        print()
        print('Fix the name in tool/vocab_line_icons.tsv, or remove the row.')
        print('A word with no honest pictogram is better left to the')
        print('structural tile than given a misleading one.')
        return 1
    if not write:
        print('Nothing written. Re-run with --write.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
