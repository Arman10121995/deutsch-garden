"""Keep the translations honest about what they do and do not cover.

Two things drift silently in a localised app. A key gets added to the template
and never to the translations, so that locale quietly falls back to English and
nobody notices until a user reports "half the app is in the wrong language".
And a placeholder gets renamed on one side only, which does not fall back --
it throws at runtime, in the locale the author does not use.

Both are mechanical, so neither should ever reach a build.

Usage:
    python tool/check_l10n.py
"""
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
L10N = os.path.join(ROOT, 'lib', 'l10n')
TEMPLATE = 'app_en.arb'

# Files whose user-facing text has been migrated. A literal reappearing in one
# of these is a regression; the rest of lib/ has simply not been done yet, and
# listing it here is what makes that distinction explicit rather than implied.
MIGRATED = [
    os.path.join('lib', 'onboarding_screen.dart'),
]

# Text inside these is content, not chrome: German the learner is meant to
# read, or a label generated from data.
ALLOWED_LITERAL = re.compile(r'^[\s\W\d]*$|^[a-z_]+$')


def load(name):
    with io.open(os.path.join(L10N, name), encoding='utf-8') as handle:
        return json.load(handle)


def placeholders(value):
    """Placeholder names used in an ICU string.

    Only a name immediately followed by a comma or a closing brace counts.
    Matching every `{word` instead pulls the branches of a plural apart --
    `=0{Nothing due}` reads as a placeholder called "Nothing" -- and then
    every plural string looks like a mismatch between locales that translate
    those branches, which is all of them.
    """
    found = re.findall(r'\{(\w+)\s*[,}]', value)
    return {name for name in found if not name.isdigit()}


def main():
    if not os.path.isdir(L10N):
        print('no lib/l10n directory')
        return 1

    template = load(TEMPLATE)
    keys = [k for k in template if not k.startswith('@')]
    errors = []

    others = sorted(
        f for f in os.listdir(L10N)
        if f.endswith('.arb') and f != TEMPLATE)
    if not others:
        errors.append('only the template exists, so nothing is translated')

    for name in others:
        data = load(name)
        locale = data.get('@@locale', name)
        for key in keys:
            if key not in data:
                errors.append('%s is missing "%s"' % (locale, key))
                continue
            want = placeholders(template[key])
            got = placeholders(data[key])
            if want != got:
                # This one throws at runtime rather than falling back.
                errors.append(
                    '%s "%s" uses placeholders %s, the template uses %s'
                    % (locale, key, sorted(got) or '[]', sorted(want) or '[]'))
        for key in data:
            if key.startswith('@'):
                continue
            if key not in template:
                errors.append(
                    '%s defines "%s", which the template does not' %
                    (locale, key))

    # Migrated files must not grow new hardcoded chrome.
    literal = re.compile(r"(?:Text|label|title|tooltip)\s*:?\s*\(?\s*'([^']{4,})'")
    for rel in MIGRATED:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            continue
        source = io.open(path, encoding='utf-8').read()
        for match in literal.finditer(source):
            text = match.group(1)
            if ALLOWED_LITERAL.match(text):
                continue
            errors.append(
                '%s still has the literal "%s"; it is a migrated file, so '
                'that string belongs in app_en.arb' % (rel, text[:48]))

    if errors:
        print('L10N CHECK FAILED')
        for error in errors:
            print('  - %s' % error)
        return 1

    print('L10N CHECK PASSED')
    print('  keys        : %d' % len(keys))
    print('  locales     : %s' % ', '.join(
        [template.get('@@locale', 'en')] +
        [load(n).get('@@locale', n) for n in others]))
    print('  migrated    : %d file(s)' % len(MIGRATED))
    return 0


if __name__ == '__main__':
    sys.exit(main())
