"""Engineering plan progress, derived from the repository rather than ticked.

A checklist someone updates by hand drifts the moment they forget. This asks
the code instead: is there a debounce timer in app_state, is `sqflite` in
pubspec, does `lib/` define a review event. The answer is therefore always
current, and an item cannot be marked done by editing a document.

The checks are deliberately shallow -- a grep, not a proof. They tell you
whether the work has been *started and landed*, not whether it is correct;
that is what `flutter test` is for. Each item names the acceptance test that
does prove it, and those live in `test/`.

Items A to F are docs/ENGINEERING_PLAN.md. Items G to J are
docs/LEARNING_UX_ROADMAP.md, where each one names the test phrase or code
condition this script looks for.

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


def relevelling_audit_complete():
    """Only complete when every vocabulary card has a recorded judgement."""
    mapping = os.path.join(ROOT, 'tool', 'cefr_relevelling.tsv')
    if not os.path.exists(mapping):
        return False
    reviewed = sum(
        1 for line in io.open(mapping, encoding='utf-8')
        if line.strip() and not line.lstrip().startswith('#')
    )
    deck = 0
    lib = os.path.join(ROOT, 'lib')
    for name in os.listdir(lib):
        if name.startswith('vocabulary') and name.endswith('.dart'):
            deck += len(re.findall(r'\bGermanWord\s*\(', read('lib', name)))
    return deck > 0 and reviewed == deck


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
         'the package, persisted setting, and bound reminder switch',
         lambda: (has(pubspec, r'flutter_local_notifications') and
                  has(app_state, r'setRemindersEnabled\b') and
                  has(read('lib', 'permissions_screen.dart'),
                      r'value:\s*controller\.remindersEnabled') and
                  has(read('lib', 'permissions_screen.dart'),
                      r'_toggleReminder\(context,\s*value\)'))),

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

        # Not just "a recogniser class exists". A recogniser nobody calls is
        # not a feature, and the licence and accuracy caveats are the part
        # most likely to be dropped in a tidy-up, so both are probed too.
        ('F1', 'F', 'Offline speech recognition', 'months',
         'a recogniser that is installed, called from the lab, and attributed',
         lambda: (has(lib, r'OfflineRecognizer|OnlineRecognizer')
                  and has(lib, r'transcribeRecording')
                  and has(lib, r'AsrModelCard')
                  and has(lib, r'CC-BY-4\.0')
                  and has(tests, r'asrUsable|transcribeRecording'))),

        ('F2', 'F', 'Card-by-card CEFR re-levelling audit', 'weeks',
         'a recorded human judgement for every vocabulary card',
         relevelling_audit_complete),
    ] + learning_items(lib, tests)


def learning_items(lib, tests):
    """Sections G to J of docs/LEARNING_UX_ROADMAP.md.

    A behaviour is probed through the test that proves it: the roadmap gives
    each item a phrase, and the item has landed when a test description in
    test/ contains it. That keeps the rule of this script -- nothing is marked
    done by editing a document -- for work that has no single identifier to
    grep for. Structural items are probed in the code as before.
    """
    def src(name):
        return read('lib', name)

    def uses(symbol, *names):
        return lambda: all(has(src(n), re.escape(symbol)) for n in names)

    def tested(phrase):
        return lambda: has(tests, re.escape(phrase))

    def item(ident, title, effort, probe, check):
        return (ident, ident[0], title, effort, probe, check)

    def behaviour(ident, title, effort, phrase):
        return item(ident, title, effort,
                    'a test described as "%s"' % phrase, tested(phrase))

    mark = 'AnswerOptionButton'
    return [
        # Civics and driving keep their lettered tile, which holds a long
        # official answer and its translation; what they share is the state
        # logic, the colours and the spoken marks.
        item('G1a', 'Marked answers: civics practice', 'hours',
             'answerOptionState in lib/civics_test_screens.dart',
             uses('answerOptionState', 'civics_test_screens.dart')),
        item('G1b', 'Marked answers: driving practice', 'hours',
             'answerOptionState in lib/driving_test_screens.dart',
             uses('answerOptionState', 'driving_test_screens.dart')),
        item('G1c', 'Marked answers: stories and mini-stories', 'hours',
             mark + ' in the story and mini-story screens',
             uses(mark, 'story_screens.dart', 'mini_story_screens.dart')),
        item('G1d', 'Marked answers: radio checkpoints', 'hours',
             mark + ' in lib/radio_screens.dart',
             uses(mark, 'radio_screens.dart')),
        item('G1e', 'Marked answers: practice games', 'days',
             mark + ' in lib/games.dart',
             uses(mark, 'games.dart')),
        item('G1f', 'Marked answers: mini mocks and checkpoints', 'hours',
             mark + ' in the exam and course screens',
             uses(mark, 'test_screens.dart', 'course_screens.dart')),
        item('G2', 'Number keys and Enter in those screens', 'days',
             'AnswerKeys in the games, civics and driving screens',
             uses('AnswerKeys', 'games.dart', 'civics_test_screens.dart',
                  'driving_test_screens.dart')),
        behaviour('G3', 'Introduce a few words before testing', 'days',
                  'a new word is not tested straight after its card'),
        behaviour('G4', 'Session progress never steps back', 'hours',
                  'session progress never steps back'),
        item('G5', 'Speed review options by word class', 'hours',
             'pickDistractors in lib/games.dart',
             uses('pickDistractors', 'games.dart')),
        behaviour('G6', 'Cloze options share the gender', 'days',
                  "cloze options share the answer's gender"),
        behaviour('G7', 'A vocabulary mistake names its word', 'hours',
                  'a vocabulary mistake names its word'),
        behaviour('G8', 'Sentence tiles hide first and last word', 'hours',
                  'sentence tiles do not mark the first or last word'),
        behaviour('H1', 'Short meanings as answer options', 'days',
                  'option labels stay short'),
        item('H3', 'Review cards that are not vocabulary', 'days',
             'tool/odd_cards_review.tsv exists',
             lambda: os.path.exists(
                 os.path.join(ROOT, 'tool', 'odd_cards_review.tsv'))),
        behaviour('H4', 'Word target and result agree', 'hours',
                  'the word target and the result agree'),
        behaviour('I1', 'Explore opens on the libraries', 'hours',
                  'Explore shows the libraries without a tap'),
        behaviour('I2', 'Shorter, illustrated onboarding', 'days',
                  'onboarding has at most three pages'),
        behaviour('I3', 'Plain words on the review card', 'hours',
                  'the review card hides scheduler numbers'),
        behaviour('I4', 'Daily goal stated once on Learn', 'hours',
                  'Learn states the daily goal once'),
        behaviour('I5', 'Question tools on one row', 'hours',
                  'question tools fit on one row'),
        behaviour('I6', 'Radio transcript starts hidden', 'hours',
                  'a radio transcript starts hidden'),
        behaviour('I7', 'Learner wording on the vocabulary page', 'hours',
                  'the vocabulary page speaks to the learner'),
        behaviour('I8', 'Hint and Skip below the options', 'hours',
                  'hint and skip follow the options'),
        behaviour('I9', 'Match pairs says what to do', 'hours',
                  'match pairs says what to do'),
        behaviour('I10', 'Reset is not the highlighted button', 'hours',
                  'reset is not the highlighted choice'),
        item('J1', 'Icons instead of emoji in Explore', 'hours',
             "no emoji: '...' argument left in lib/explore_screen.dart",
             lambda: not has(src('explore_screen.dart'), r"emoji:\s*'")),
        item('J3', 'Last interface string under the gate', 'hours',
             'separable_verb_animation.dart named in tool/check_l10n.py',
             lambda: has(read('tool', 'check_l10n.py'),
                         r'separable_verb_animation\.dart')),
        item('J4', 'Plural form for "about N minutes"', 'hours',
             'a plural form in audioDaySummary (lib/l10n/app_en.arb)',
             lambda: has(read('lib', 'l10n', 'app_en.arb'),
                         r'"audioDaySummary":\s*"[^"\n]*plural')),
        behaviour('J5', 'Readable width for opened screens', 'days',
                  'an opened screen keeps a readable width'),
        item('J6', 'Own label for the import check button', 'hours',
             'lib/backup_dialogs.dart no longer uses checkAnswer',
             lambda: not has(src('backup_dialogs.dart'), r'\bcheckAnswer\b')),
        behaviour('J7', 'Role-play controls reach 48 pixels', 'hours',
                  'role-play controls meet the tap target size'),
    ]


PHASES = {
    'A': 'Scheduling quality -- independent, hours each',
    'B': 'The data layer -- ordered, each unlocks the next',
    'C': 'Habit and reach',
    'D': 'Correctness and pedagogy',
    'E': 'Store packaging',
    'F': 'Long-running',
    'G': 'The answer loop -- docs/LEARNING_UX_ROADMAP.md from here on',
    'H': 'Content clarity',
    'I': 'Navigation, wording and first run',
    'J': 'Visual robustness',
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
