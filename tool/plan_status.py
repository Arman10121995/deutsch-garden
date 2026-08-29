"""Engineering plan progress, derived from the repository rather than ticked.

A checklist someone updates by hand drifts the moment they forget. This asks
the code instead: is there a debounce timer in app_state, is `sqflite` in
pubspec, does `lib/` define a review event. The answer is therefore always
current, and an item cannot be marked done by editing a document.

The checks are deliberately shallow -- a grep, not a proof. They tell you
whether the work has been *started and landed*, not whether it is correct;
that is what `flutter test` is for. Each item names the acceptance test that
does prove it, and those live in `test/`.

Usage:
    python tool/plan_status.py            # the table
    python tool/plan_status.py next       # the next unfinished item
    python tool/plan_status.py --verbose  # show what each check looked for
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def read(*parts):
    path = os.path.join(ROOT, *parts)
    if not os.path.exists(path):
        return ''
    return io.open(path, encoding='utf-8', errors='replace').read()


def lib_text():
    """Every Dart file under lib/, concatenated."""
    out = []
    lib = os.path.join(ROOT, 'lib')
    for name in sorted(os.listdir(lib)):
        if name.endswith('.dart'):
            out.append(read('lib', name))
    return chr(10).join(out)


def has(text, pattern):
    # Probes such as ``^  sqflite:`` are line-oriented. Without MULTILINE the
    # caret only examined the beginning of the entire pubspec and reported B2
    # unfinished even after its SQLite store had landed.
    return re.search(pattern, text, re.MULTILINE) is not None


# Each item: (id, phase, title, effort, probe-description, check)
# The check returns True when the work has landed.
def build_items():
    pubspec = read('pubspec.yaml')
    app_state = read('lib', 'app_state.dart')
    srs = read('lib', 'srs.dart')
    ci = read('.github', 'workflows', 'ci.yml')
    lib = lib_text()
    tests = ''
    tdir = os.path.join(ROOT, 'test')
    if os.path.isdir(tdir):
        tests = chr(10).join(
            read('test', n) for n in sorted(os.listdir(tdir))
            if n.endswith('.dart'))

    return [
        ('A1', 'A', 'Debounce profile writes', 'hours',
         'a debounce timer in lib/app_state.dart',
         lambda: has(app_state, r'_saveDebounce|_pendingSave|Timer\(')),

        ('A2', 'A', 'Fuzz review intervals', 'hours',
         'interval fuzzing in lib/srs.dart',
         lambda: has(srs, r'fuzz|Fuzz')),

        ('A3', 'A', 'Credit overdue reviews', 'hours',
         'lateness handling in lib/srs.dart',
         lambda: has(srs, r'lateness|daysLate|elapsedDays|overdue')),

        ('B1', 'B', 'Append-only review event log', 'weeks',
         'a review event type in lib/',
         lambda: has(lib, r'class ReviewEvent\b')),

        ('B2', 'B', 'Profile off the single SharedPreferences key', 'weeks',
         'sqflite plus the external review store in lib/',
         lambda: (has(pubspec, r'^\s*(sqflite|drift):') and
                  has(lib, r'class SqliteReviewStore\b'))),

        ('B3', 'B', 'Reconcile two devices instead of overwriting', 'weeks',
         'an event-aware merge in lib/',
         lambda: has(lib, r'ProgressBackup\.merge|static Map<String, dynamic> merge\(')),

        ('B4', 'B', 'Undo a misgrade', 'days',
         'an undo path over the review log in lib/',
         lambda: has(lib, r'undoLastReview|revertReview')),

        ('B5', 'B', 'Retention statistics from the log', 'days',
         'a retention calculation over the review log in lib/',
         lambda: has(lib, r'trueRetention|retentionByInterval')),

        ('C1', 'C', 'Study reminders', 'days',
         'the package, persisted setting, and learner-facing switch',
         lambda: (has(pubspec, r'flutter_local_notifications') and
                  has(app_state, r'setRemindersEnabled\b') and
                  has(lib, r'Daily study reminder'))),

        ('C2', 'C', 'In-app onboarding', 'days',
         'an onboarding screen in lib/',
         lambda: has(lib, r'class OnboardingScreen\b')),

        ('C3', 'C', 'Localise the interface', 'weeks',
         'flutter_localizations in pubspec.yaml',
         lambda: has(pubspec, r'flutter_localizations')),

        ('C4', 'C', 'Translations in languages other than English', 'weeks',
         'a gloss side table plus at least one shipped language',
         lambda: (has(lib, r'String meaningFor\(') and
                  os.path.isdir(os.path.join(ROOT, 'assets', 'glosses')) and
                  any(f.endswith('.json') for f in os.listdir(
                      os.path.join(ROOT, 'assets', 'glosses'))))),

        ('D1', 'D', 'Injectable clock', 'days',
         'a Clock abstraction in lib/',
         lambda: has(lib, r'class AppClock\b|abstract class Clock\b')),

        ('D2', 'D', 'Terminate placement on confidence', 'days',
         'a confidence criterion in lib/assessment.dart',
         lambda: has(read('lib', 'assessment.dart'),
                     r'confidence|standardError|posterior')),

        ('D3', 'D', 'Score free talk on content points', 'days',
         'content-point keywords in the conversation engine',
         lambda: has(lib, r'pointKeywords|contentPointKeywords')),

        ('E1', 'E', 'Signed Android App Bundle', 'days',
         'flutter build appbundle in CI',
         lambda: has(ci, r'build appbundle')),

        ('E2', 'E', 'Windows MSIX package', 'days',
         'msix in pubspec.yaml or CI',
         lambda: has(pubspec, r'msix') or has(ci, r'msix')),

        ('E3', 'E', 'Signed and notarised macOS build', 'days',
         'notarisation in CI',
         lambda: has(ci, r'notarytool|notarize|notarise')),

        ('F1', 'F', 'Offline speech recognition', 'months',
         'an offline recogniser in lib/',
         lambda: has(lib, r'OfflineRecognizer|OnlineRecognizer')),

        ('F2', 'F', 'Card-by-card CEFR re-levelling audit', 'weeks',
         'a reviewed level mapping under tool/',
         lambda: os.path.exists(
             os.path.join(ROOT, 'tool', 'cefr_relevelling.tsv'))),
    ]


PHASES = {
    'A': 'Scheduling quality -- independent, hours each',
    'B': 'The data layer -- ordered, each unlocks the next',
    'C': 'Habit and reach',
    'D': 'Correctness and pedagogy',
    'E': 'Store packaging',
    'F': 'Long-running',
}


def main():
    items = build_items()
    verbose = '--verbose' in sys.argv
    done = [i for i in items if i[5]()]

    if 'next' in sys.argv:
        for item in items:
            if not item[5]():
                print('%s  %s  (%s)' % (item[0], item[2], item[3]))
                print('    done when: %s' % item[4])
                return
        print('everything on the plan has landed')
        return

    current = None
    for ident, phase, title, effort, probe, check in items:
        if phase != current:
            current = phase
            print()
            print('%s. %s' % (phase, PHASES[phase]))
        mark = 'x' if check() else ' '
        print('  [%s] %s  %-46s %s' % (mark, ident, title, effort))
        if verbose:
            print('         probe: %s' % probe)

    print()
    print('%d of %d landed' % (len(done), len(items)))


if __name__ == '__main__':
    main()
