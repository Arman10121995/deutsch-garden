"""Measure the shipped artifacts against what the stores actually accept.

The asset policy's first line is that the app stays small enough to publish.
That has to be a fact rather than a hope, and the number that matters is not
the one on disk -- Google Play measures the *compressed download size* of the
base module, which is roughly what the AAB already is, while the APK on the
release page is a different thing again.

Run it against a built release, or against the assets alone to see which way
the bundle is heading.

Usage:
    python tool/check_store_size.py                 # measure assets/
    python tool/check_store_size.py dist            # measure built artifacts
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MB = 1024.0 * 1024.0

# Google Play caps the base module at 200 MB compressed download size.
# The Microsoft Store and the App Store are far more generous, so Play is the
# binding constraint and the one worth failing on.
PLAY_LIMIT_MB = 200.0

# Leave room: the figure Play computes is not exactly the file size, and upload
# time is a bad moment to discover the difference.
PLAY_WARN_MB = 180.0


def tree_size(path):
    total = 0
    for base, _dirs, files in os.walk(path):
        for name in files:
            try:
                total += os.path.getsize(os.path.join(base, name))
            except OSError:
                pass
    return total


def biggest(path, count=8):
    entries = []
    for base, _dirs, files in os.walk(path):
        for name in files:
            full = os.path.join(base, name)
            try:
                entries.append((os.path.getsize(full), full))
            except OSError:
                pass
    entries.sort(reverse=True)
    return entries[:count]


def main():
    target = sys.argv[1] if len(sys.argv) > 1 else None

    if target:
        root = os.path.join(ROOT, target)
        if not os.path.isdir(root):
            print('no such directory: %s' % target)
            return 2
        print('Built artifacts in %s' % target)
        worst = 0.0
        for name in sorted(os.listdir(root)):
            full = os.path.join(root, name)
            if not os.path.isfile(full):
                continue
            size = os.path.getsize(full) / MB
            note = ''
            if name.endswith('.aab'):
                if size > PLAY_LIMIT_MB:
                    note = '  OVER the Play 200 MB base-module limit'
                elif size > PLAY_WARN_MB:
                    note = '  close to the Play 200 MB limit'
                worst = max(worst, size)
            print('  %-42s %7.1f MB%s' % (name, size, note))
        if worst > PLAY_LIMIT_MB:
            print()
            print('The App Bundle is over what Play accepts for a base module.')
            print('Play Asset Delivery or a smaller bundled voice are the two')
            print('honest ways out; shipping it as-is is not one.')
            return 1
        return 0

    assets = os.path.join(ROOT, 'assets')
    total = tree_size(assets)
    print('Bundled assets: %.1f MB' % (total / MB))
    print()
    print('Largest:')
    for size, full in biggest(assets):
        print('  %-52s %7.1f MB' % (os.path.relpath(full, ROOT), size / MB))
    print()
    print('Play caps the AAB base module at %.0f MB compressed download.'
          % PLAY_LIMIT_MB)
    print('Run against a built dist to measure the artifacts themselves.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
