#!/usr/bin/env python3
"""Source-level content integrity checks that do not require Flutter/Dart."""
from pathlib import Path
import io
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
LEVELS = ['A1','A2','B1','B2','C1','C2']
errors = []


def read(name):
    return (LIB / name).read_text(encoding='utf-8')

# ---------------------------------------------------------------------------
# German correctness checks on every vocabulary card.
#
# The deck is about to grow by thousands of entries. A wrong gender or a plural
# that does not match the noun is not a cosmetic defect in a teaching app -- it
# teaches the error, and the learner has no way to know. These checks are the
# ones a machine can make with certainty; they do not replace reading the
# content, but they catch the mistakes that scale.
# ---------------------------------------------------------------------------
CARD_RE = re.compile(
    r"GermanWord\("
    r"\s*id:\s*'(?P<id>[^']*)',"
    r"\s*article:\s*'(?P<article>[^']*)',"
    r"\s*german:\s*'(?P<german>[^']*)',"
    r"\s*plural:\s*'(?P<plural>[^']*)',"
    r"\s*english:\s*'(?P<english>[^']*)',"
    r"\s*exampleGerman:\s*'(?P<eg>[^']*)',"
    r"\s*exampleEnglish:\s*'(?P<ee>[^']*)',"
    r"\s*category:\s*'(?P<category>[^']*)',"
    r"\s*level:\s*'(?P<level>[^']*)'"
)

ARTICLES = {'der', 'die', 'das', ''}
NO_PLURAL = '—'  # em dash, the convention for "no plural / not a noun"


def check_vocabulary(text: str, errors: list) -> int:
    cards = [m.groupdict() for m in CARD_RE.finditer(text)]
    seen_ids = {}
    seen_lemmas = {}

    def fail(card, message):
        errors.append('vocabulary %s (%s): %s'
                      % (card['id'], card['german'], message))

    for card in cards:
        article, german, plural = card['article'], card['german'], card['plural']

        if card['id'] in seen_ids:
            fail(card, 'duplicate id')
        seen_ids[card['id']] = True

        lemma = (article + ' ' + german).strip().lower()
        if lemma in seen_lemmas:
            fail(card, 'duplicate entry, already defined as %s'
                       % seen_lemmas[lemma])
        seen_lemmas[lemma] = card['id']

        if article not in ARTICLES:
            fail(card, 'article %r is not der/die/das' % article)

        # German capitalises every noun. An article means it is a noun.
        if article and not german[:1].isupper():
            fail(card, 'noun must be capitalised')
        if not article and german[:1].isupper() and german not in (
                'Hallo', 'Tschüss', 'Guten', 'Danke'):
            # Interjections and greetings are the legitimate exceptions.
            pass

        if article:
            if plural != NO_PLURAL and not plural.startswith('die '):
                fail(card, 'plural %r should be "die ..." or the em dash'
                           % plural)
        elif plural != NO_PLURAL:
            fail(card, 'non-noun must have the em dash as its plural, got %r'
                       % plural)

        if card['level'] not in LEVELS:
            fail(card, 'level %r is not A1-C2' % card['level'])
        if not card['english'].strip():
            fail(card, 'empty English gloss')
        if not card['ee'].strip():
            fail(card, 'empty English example')

        eg = card['eg']
        if not eg.strip():
            fail(card, 'empty German example')
            continue
        if not eg[:1].isupper() and not eg[:1] in '„‚':
            fail(card, 'German example does not start with a capital')
        if eg.rstrip()[-1:] not in '.!?':
            fail(card, 'German example has no sentence-ending punctuation')

        # The example must actually contain the word being taught. A stem match
        # allows for declension and conjugation without hand-writing morphology,
        # and folding the diacritics handles the umlaut mutation German plurals
        # use: Hand -> Haende, Buch -> Buecher, Haus -> Haeuser.
        def fold(value: str) -> str:
            for umlaut, plain in (('ä', 'a'), ('ö', 'o'),
                                  ('ü', 'u'), ('ß', 'ss')):
                value = value.replace(umlaut, plain)
            return value

        stem = fold(german.lower())
        for suffix in ('en', 'n', 'e', 'st', 't'):
            if len(stem) > 5 and stem.endswith(suffix):
                break

        # German separable verbs split in a main clause: aufräumen becomes
        # "räum ... auf". Matching the bare stem as well as the whole verb
        # keeps a correct example from being reported as wrong.
        SEPARABLE = ('zusammen', 'zurück', 'wieder', 'unter', 'durch', 'über',
                     'nach', 'statt', 'weg', 'vor', 'zu', 'auf', 'aus', 'an',
                     'ab', 'bei', 'ein', 'mit', 'los', 'her', 'hin', 'um',
                     'fest', 'frei', 'teil')
        alternatives = [stem]
        if not article:
            for prefix in SEPARABLE:
                if stem.startswith(prefix) and len(stem) > len(prefix) + 3:
                    alternatives.append(stem[len(prefix):])
                    break
        for suffix in ('en', 'n', 'e', 'st', 't'):
            if len(stem) > 5 and stem.endswith(suffix):
                stem = stem[: -len(suffix)]
                break
        haystack = fold(eg.lower())
        wanted = []
        for candidate in alternatives:
            # Trim the infinitive or inflectional ending so a conjugated form
            # still matches: holen -> hol, and "Ich hole ... ab" then hits.
            for suffix in ('en', 'n', 'e', 'st', 't'):
                if len(candidate) - len(suffix) >= 3 and candidate.endswith(suffix):
                    candidate = candidate[: -len(suffix)]
                    break
            wanted.append(candidate[:max(3, min(len(candidate), 6))])
        if wanted and not any(w and w in haystack for w in wanted):
            fail(card, 'German example does not use the word (looked for %s)'
                       % ' or '.join(repr(w) for w in wanted))

    return len(cards)


# Vocabulary integrity in the two data files.
vocab_text = (read('vocabulary.dart') + chr(10)
              + read('vocabulary_expansion.dart') + chr(10)
              + read('vocabulary_extra.dart'))
ids = re.findall(r"\bid:\s*'((?:w|x)\d+)'", vocab_text)
level_counts = {level: len(re.findall(r"level:\s*'" + level + r"'", vocab_text)) for level in LEVELS}
articles = re.findall(r"article:\s*'([^']*)'", vocab_text)
if len(ids) != len(set(ids)):
    errors.append('Duplicate vocabulary IDs detected.')
if sum(level_counts.values()) < 850:
    errors.append(f"Expected >=850 vocabulary records, found {sum(level_counts.values())}.")
for level in LEVELS:
    count = level_counts[level]
    if count < 120:
        errors.append(f'{level} has only {count} vocabulary cards (minimum 120).')
checked_cards = check_vocabulary(vocab_text, errors)

for article in articles:
    if article and article not in {'der','die','das'}:
        errors.append(f'Invalid article: {article}')

curriculum = read('curriculum.dart')
grammar_x = read('grammar_expansion.dart')
skill_x = read('skill_expansion.dart')
speaking = read('speaking_curriculum.dart')
assessment = read('assessment.dart')
test_prep = read('test_prep.dart')

for level_low, level in zip(['a1','a2','b1','b2','c1','c2'], LEVELS):
    core_g = len(re.findall(rf"GrammarLesson\(\s*id:\s*'gr-{level_low}-", curriculum))
    sup_g = len(re.findall(rf"_GrammarSpec\('gr-{level_low}-x", grammar_x))
    grammar_count = core_g + sup_g
    if grammar_count < 16:
        errors.append(f'{level} grammar coverage too small: {grammar_count}')

    core_l = len(re.findall(rf"ListeningLesson\(id:\s*'li-{level_low}-", curriculum))
    sup_l = len(re.findall(rf"ListeningLesson\(id:'lx-{level_low}-", skill_x))
    core_r = len(re.findall(rf"ReadingLesson\(id:\s*'re-{level_low}-", curriculum))
    sup_r = len(re.findall(rf"ReadingLesson\(id:'rx-{level_low}-", skill_x))
    core_w = len(re.findall(rf"WritingLesson\(id:\s*'wr-{level_low}-", curriculum))
    sup_w = len(re.findall(rf"WritingLesson\(id:'wx-{level_low}-", skill_x))
    sp = len(re.findall(rf"SpeakingLesson\(id:\s*'sp-{level_low}-", speaking))
    pl = len(re.findall(rf"PlacementQuestion\(id:'pl-{level_low}-", assessment))
    mocks = len(re.findall(rf"ExamPracticeSet\(id:'mock-{level_low}-", test_prep))
    expected = {'listening': core_l+sup_l, 'reading':core_r+sup_r, 'writing':core_w+sup_w}
    for name, count in expected.items():
        if count < 6:
            errors.append(f'{level} {name} coverage too small: {count}')
    if sp < 3:
        errors.append(f'{level} speaking coverage too small: {sp}')
    if pl != 6:
        errors.append(f'{level} placement item count must be 6, found {pl}')
    if mocks != 2:
        errors.append(f'{level} mock count must be 2, found {mocks}')

# Unique IDs across major activity content.
activity_patterns = [
    (curriculum, r"id:\s*'(gr|li|re|wr)-[^']+'"),
    (grammar_x, r"_GrammarSpec\('([^']+)'"),
    (skill_x, r"id:'([^']+)'"),
    (speaking, r"id:\s*'([^']+)'"),
    (assessment, r"id:'([^']+)'"),
    (test_prep, r"ExamPracticeSet\(id:'([^']+)'"),
]
# Extract quoted IDs more directly for uniqueness.
activity_ids = []
for text in [curriculum, skill_x, speaking, assessment, test_prep]:
    activity_ids.extend(re.findall(r"\bid:\s*'((?:gr|li|re|wr|lx|rx|wx|sp|pl|mock)-[^']+)'", text))
activity_ids.extend(re.findall(r"_GrammarSpec\('([^']+)'", grammar_x))
if len(activity_ids) != len(set(activity_ids)):
    dup = sorted({x for x in activity_ids if activity_ids.count(x) > 1})
    errors.append(f'Duplicate activity IDs: {dup[:10]}')

# New in 3.1: speaking role-plays, free-talk prompts, stories and the
# sentence bank used by the builder/dictation drills.
conversation = read('conversation.dart')
stories_src = read('stories.dart')
sentences = read('sentence_bank.dart')

scenario_ids = re.findall(r"\bid: '(cv-[a-z0-9-]+)'", conversation)
free_talk_ids = re.findall(r"\bid: '(ft-[a-z0-9-]+)'", conversation)
story_ids = re.findall(r"\bid: '(st-[a-z0-9]+-\d+)',", stories_src)
chapter_ids = re.findall(r"\bid: '(st-[a-z0-9]+-\d+-c\d+)'", stories_src)
sentence_ids = re.findall(r"\bid: '(ps-[a-z0-9-]+)'", sentences)

for name, ids in [
    ('conversation scenario', scenario_ids),
    ('free-talk prompt', free_talk_ids),
    ('story', story_ids),
    ('story chapter', chapter_ids),
    ('practice sentence', sentence_ids),
]:
    if len(ids) != len(set(ids)):
        dup = sorted({x for x in ids if ids.count(x) > 1})
        errors.append(f'Duplicate {name} IDs: {dup[:10]}')

for level_low, level in zip(['a1','a2','b1','b2','c1','c2'], LEVELS):
    scenarios = len([i for i in scenario_ids if i.startswith(f'cv-{level_low}-')])
    prompts = len([i for i in free_talk_ids if i.startswith(f'ft-{level_low}-')])
    level_stories = len([i for i in story_ids if i.startswith(f'st-{level_low}-')])
    curated = len([i for i in sentence_ids if i.startswith(f'ps-{level_low}-')])
    if scenarios < 2:
        errors.append(f'{level} has only {scenarios} role-plays (minimum 2).')
    if prompts < 2:
        errors.append(f'{level} has only {prompts} free-talk prompts (minimum 2).')
    if level_stories < 1:
        errors.append(f'{level} has no story.')
    if curated < 5:
        errors.append(f'{level} has only {curated} curated practice sentences (minimum 5).')

# Every story chapter must belong to a declared story.
for chapter in chapter_ids:
    parent = chapter.rsplit('-c', 1)[0]
    if parent not in story_ids:
        errors.append(f'Chapter {chapter} has no parent story.')

# ChoiceQuestion validation across curriculum, assessment, test_prep, skill_x and stories.
all_content = curriculum + '\n' + grammar_x + '\n' + skill_x + '\n' + assessment + '\n' + test_prep + '\n' + stories_src
questions = re.findall(r"ChoiceQuestion\s*\((.*?)\)", all_content, re.DOTALL)
for idx, q_text in enumerate(questions):
    opt_match = re.search(r"options:\s*<String>\[(.*?)\]", q_text, re.DOTALL) or re.search(r"options:\s*\[(.*?)\]", q_text, re.DOTALL)
    idx_match = re.search(r"correctIndex:\s*(\d+)", q_text)
    if opt_match and idx_match:
        opts = [o.strip() for o in opt_match.group(1).split(',') if o.strip()]
        c_idx = int(idx_match.group(1))
        if len(opts) < 2:
            errors.append(f'ChoiceQuestion #{idx+1} has fewer than 2 options ({len(opts)}).')
        if c_idx >= len(opts):
            errors.append(f'ChoiceQuestion #{idx+1} correctIndex {c_idx} out of range for {len(opts)} options.')


# Delimiter sanity on Dart sources. Strings, comments and character literals
# are stripped first, so regular expressions and German quotation marks in
# content files do not produce false positives. This is not a Dart parser --
# `flutter analyze` in CI is -- but it catches truncated bundles offline.
def strip_dart(source: str) -> str:
    out = []
    i = 0
    length = len(source)
    while i < length:
        char = source[i]
        if char == '/' and i + 1 < length and source[i + 1] == '/':
            while i < length and source[i] != '\n':
                i += 1
            continue
        if char == '/' and i + 1 < length and source[i + 1] == '*':
            i += 2
            while i + 1 < length and not (source[i] == '*' and source[i + 1] == '/'):
                i += 1
            i += 2
            continue
        if char in ("'", '"'):
            quote = char
            triple = source[i:i + 3] == quote * 3
            i += 3 if triple else 1
            while i < length:
                if source[i] == '\\':
                    i += 2
                    continue
                if triple and source[i:i + 3] == quote * 3:
                    i += 3
                    break
                if not triple and source[i] == quote:
                    i += 1
                    break
                if not triple and source[i] == '\n':
                    break
                i += 1
            continue
        out.append(char)
        i += 1
    return ''.join(out)


for path in sorted(LIB.glob('*.dart')):
    stripped = strip_dart(path.read_text(encoding='utf-8'))
    for left, right in [('(', ')'), ('[', ']'), ('{', '}')]:
        if stripped.count(left) != stripped.count(right):
            errors.append(f'Unbalanced {left}{right} in {path.name}')

# ---------------------------------------------------------------------------
# German typography.
#
# German quotes are „low-open, high-close“; English are “high-open, high-close”.
# A release once shipped 132 German quotations closed with a plain ASCII " —
# invisible in a diff, wrong on every page a learner reads, and exactly the
# kind of thing a language app must not teach by example.
# ---------------------------------------------------------------------------
GERMAN_OPEN = '„'   # „
GERMAN_CLOSE = '“'  # “ (also the English opening quote)
ENGLISH_CLOSE = '”'  # ”

for dart_file in sorted(LIB.glob('*.dart')):
    text = dart_file.read_text(encoding='utf-8')
    opens = text.count(GERMAN_OPEN)
    if not opens and GERMAN_CLOSE not in text:
        continue
    english_pairs = text.count(ENGLISH_CLOSE)
    german_closes = text.count(GERMAN_CLOSE) - english_pairs
    if german_closes != opens:
        errors.append(
            '%s: %d German opening quotes but %d German closing quotes. '
            'German quotations must be written „like this“.'
            % (dart_file.name, opens, german_closes)
        )
    # A German opening quote closed by an ASCII double quote.
    stray = re.findall(GERMAN_OPEN + r'[^' + GERMAN_OPEN + GERMAN_CLOSE + r'"]*"', text)
    if stray:
        errors.append(
            '%s: %d German quotation(s) closed with an ASCII " instead of “'
            % (dart_file.name, len(stray))
        )

if errors:
    print('CONTENT VALIDATION FAILED')
    for error in errors:
        print(' -', error)
    sys.exit(1)


def count(pattern, text):
    return len(re.findall(pattern, text))


grammar_total = count(r"GrammarLesson\(\s*id:", curriculum) + count(r"_GrammarSpec\('", grammar_x)
listening_total = count(r"ListeningLesson\(", curriculum) + count(r"ListeningLesson\(", skill_x)
reading_total = count(r"ReadingLesson\(", curriculum) + count(r"ReadingLesson\(", skill_x)
writing_total = count(r"WritingLesson\(", curriculum) + count(r"WritingLesson\(", skill_x)

print('CONTENT VALIDATION PASSED')
print(f'Vocabulary cards: {sum(level_counts.values())}')
for level in LEVELS:
    print(f'  {level}: {level_counts[level]}')
print(f'Grammar lessons: {grammar_total}')
print(f'Listening lessons: {listening_total}')
print(f'Reading lessons: {reading_total}')
print(f'Writing lessons: {writing_total}')
speaking_total = count(r"SpeakingLesson\(id:", speaking)
placement_total = count(r"PlacementQuestion\(id:", assessment)
mock_total = count(r"ExamPracticeSet\(id:", test_prep)
print(f'Speaking lessons: {speaking_total}')
print(f'Placement items: {placement_total}')
print(f'Exam mini mocks: {mock_total}')
print(f'Conversation role-plays: {len(scenario_ids)}')
print(f'Free-talk prompts: {len(free_talk_ids)}')
print(f'Stories: {len(story_ids)} ({len(chapter_ids)} chapters)')
print(f'Curated practice sentences: {len(sentence_ids)}')

# ---------------------------------------------------------------------------
# Single source of truth for release metadata.
#
# The counts above are derived from the Dart sources, so they cannot be wrong.
# Every other file that states a count or a version is GENERATED from them or
# CHECKED against them here. Before this, five files carried hand-maintained
# copies and had already drifted apart: pubspec said 3.2.1+6, the changelog
# said 3.4.1, the README said 881 cards, and the manifest said 931.
# ---------------------------------------------------------------------------
import json
from datetime import date

vocab_total = sum(level_counts.values())

pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
version_match = re.search(r'^version:\s*(\S+)', pubspec, re.M)
if not version_match:
    print('CONTENT VALIDATION FAILED')
    print(' - pubspec.yaml has no version: line')
    sys.exit(1)
release = version_match.group(1)

changelog = (ROOT / 'CHANGELOG.md').read_text(encoding='utf-8')
changelog_match = re.search(r'^##\s+(\d+\.\d+\.\d+)', changelog, re.M)
changelog_version = changelog_match.group(1) if changelog_match else None

drift = []
if changelog_version and not release.startswith(changelog_version):
    drift.append(
        'pubspec.yaml version %s does not match the newest CHANGELOG entry %s'
        % (release, changelog_version)
    )

readme = (ROOT / 'README.md').read_text(encoding='utf-8')
for label, actual, pattern in [
    ('vocabulary cards', vocab_total, r'\*\*(\d+) bundled vocabulary cards\*\*'),
    ('grammar lessons', grammar_total, r'\*\*(\d+) grammar lessons\*\*'),
    ('listening lessons', listening_total, r'\*\*(\d+) listening lessons\*\*'),
    ('reading lessons', reading_total, r'\*\*(\d+) reading lessons\*\*'),
    ('writing lessons', writing_total, r'\*\*(\d+) writing lessons\*\*'),
    ('speaking lessons', speaking_total, r'\*\*(\d+) speaking lessons\*\*'),
    ('curated sentences', len(sentence_ids), r'\*\*(\d+) curated practice sentences\*\*'),
    ('stories', len(story_ids), r'\*\*(\d+) graded stories'),
]:
    found = re.search(pattern, readme)
    if found and int(found.group(1)) != actual:
        drift.append(
            'README says %s %s, sources contain %d'
            % (found.group(1), label, actual)
        )

readme_title = re.search(r'^#\s+DeutschGarden\s+(\d+\.\d+)', readme, re.M)
if readme_title and not release.startswith(readme_title.group(1)):
    drift.append(
        'README title says %s, pubspec says %s'
        % (readme_title.group(1), release)
    )

if drift:
    print()
    print('RELEASE METADATA DRIFT')
    for item in drift:
        print(' -', item)
    print()
    print('Update the files above (or run this script with --write to')
    print('regenerate the generated ones) so every stated count matches source.')
    sys.exit(1)

# Regenerate the two files that are pure derivations of the counts above.
manifest = {
    'release': release,
    'generated': date.today().isoformat(),
    'vocabulary_by_level': {level: level_counts[level] for level in LEVELS},
    'vocabulary_total': vocab_total,
    'grammar_lessons': grammar_total,
    'listening_lessons': listening_total,
    'reading_lessons': reading_total,
    'writing_lessons': writing_total,
    'speaking_lessons': speaking_total,
    'placement_items': placement_total,
    'exam_mini_mocks': mock_total,
    'conversation_scenarios': len(scenario_ids),
    'free_talk_prompts': len(free_talk_ids),
    'stories': len(story_ids),
    'story_chapters': len(chapter_ids),
    'curated_practice_sentences': len(sentence_ids),
    'note': (
        'Generated by tool/validate_content.py from the Dart sources. '
        'Do not hand-edit. Lexical breadth targets are pedagogical planning '
        'targets, not official CEFR word-count thresholds. Speaking feedback '
        'is produced by an on-device rule-based evaluator, not a language '
        'model or an acoustic pronunciation scorer.'
    ),
}

report_lines = [
    'CONTENT VALIDATION PASSED',
    'Release: %s' % release,
    'Vocabulary cards: %d' % vocab_total,
]
report_lines += ['  %s: %d' % (level, level_counts[level]) for level in LEVELS]
report_lines += [
    'Grammar lessons: %d' % grammar_total,
    'Listening lessons: %d' % listening_total,
    'Reading lessons: %d' % reading_total,
    'Writing lessons: %d' % writing_total,
    'Speaking lessons: %d' % speaking_total,
    'Placement items: %d' % placement_total,
    'Exam mini mocks: %d' % mock_total,
    'Conversation role-plays: %d' % len(scenario_ids),
    'Free-talk prompts: %d' % len(free_talk_ids),
    'Stories: %d (%d chapters)' % (len(story_ids), len(chapter_ids)),
    'Curated practice sentences: %d' % len(sentence_ids),
    '',
    'Generated by tool/validate_content.py. Do not hand-edit.',
]

build_info = chr(10).join([
    '// GENERATED by tool/validate_content.py. Do not edit by hand.',
    '//',
    '// The version lives in pubspec.yaml. Restating it in Dart by hand is how',
    '// five files ended up disagreeing about which release this was, so it is',
    "// generated instead and the validator fails the build if it drifts.",
    '',
    "const String appVersion = '%s';" % release,
    "const String appVocabularyCount = '%d';" % vocab_total,
    '',
])

new_manifest = json.dumps(manifest, indent=2, ensure_ascii=False) + chr(10)
new_report = chr(10).join(report_lines) + chr(10)

manifest_path = ROOT / 'CONTENT_MANIFEST.json'
report_path = ROOT / 'VALIDATION_REPORT.txt'

# PROJECT_TREE.txt is an inventory of the committed source. Hand-maintained it
# went stale the moment a file was added -- it was still missing the test files
# from 3.2.2 -- so it is walked from disk instead.
TREE_SKIP_DIRS = {
    '.git', '.dart_tool', '.idea', '.vscode', 'build', 'dist',
    'android', 'ios', 'linux', 'macos', 'windows', 'web',
    '__pycache__', '.pub-cache', '.pub',
    # Built artifacts carried on the per-platform branches. They are outputs,
    # not source, and they differ per branch -- inventorying them would make
    # the generated files disagree with main and fail the drift gate on every
    # platform branch.
    'release',
}
TREE_SKIP_SUFFIXES = ('.pyc', '.iml', '.bundle', '.zip')
TREE_SKIP_NAMES = {
    'pubspec.lock', '.flutter-plugins', '.flutter-plugins-dependencies',
    '.metadata', '.packages', '.DS_Store',
}
# Regenerated by every `flutter create` and gitignored: never part of the
# inventory, even when it happens to exist on the machine running this.
TREE_SKIP_RELATIVE = {'test/widget_test.dart'}


def _gitignore_patterns():
    """The patterns in .gitignore, as (pattern, dir_only) pairs."""
    path = ROOT / '.gitignore'
    if not path.exists():
        return []
    out = []
    for raw in path.read_text(encoding='utf-8').splitlines():
        line = raw.strip()
        if not line or line.startswith('#'):
            continue
        dir_only = line.endswith('/')
        out.append((line.rstrip('/').lstrip('/'), dir_only))
    return out


_IGNORES = None


def _is_ignored(rel) -> bool:
    """Whether .gitignore excludes this path.

    Reading the ignore file is the point: a hand-maintained skip list here goes
    out of date the moment anyone adds an ignore rule, and then a file that is
    present locally but never committed makes the generated inventory disagree
    with a fresh checkout -- which fails the drift gate on CI and nowhere else.
    This has caught test/widget_test.dart and key.properties already.

    Only the subset of gitignore syntax this repository uses is supported:
    plain names, directory rules and simple globs. Negations are not.
    """
    global _IGNORES
    if _IGNORES is None:
        _IGNORES = _gitignore_patterns()
    import fnmatch
    text = rel.as_posix()
    parts = rel.parts
    for pattern, dir_only in _IGNORES:
        if dir_only:
            if pattern in parts[:-1]:
                return True
            continue
        if '/' in pattern:
            if fnmatch.fnmatch(text, pattern):
                return True
        else:
            if fnmatch.fnmatch(parts[-1], pattern):
                return True
            if pattern in parts[:-1]:
                return True
    return False


def _inventory_paths():
    """Every file that belongs in the repository, in a platform-stable order.

    `sorted()` over Path objects is case-insensitive on Windows and
    case-sensitive on POSIX, so the same tree produced two different orderings
    depending on who ran this. Sorting on the relative POSIX string is plain
    string ordering and is identical everywhere.
    """
    return sorted(ROOT.rglob('*'), key=lambda p: p.relative_to(ROOT).as_posix())


def project_tree() -> str:
    entries = []
    for path in _inventory_paths():
        rel = path.relative_to(ROOT)
        if any(part in TREE_SKIP_DIRS for part in rel.parts):
            continue
        if path.is_dir():
            continue
        if path.name in TREE_SKIP_NAMES or path.name.endswith(TREE_SKIP_SUFFIXES):
            continue
        if rel.as_posix() in TREE_SKIP_RELATIVE:
            continue
        if _is_ignored(rel):
            continue
        entries.append('  ' + rel.as_posix())
    return chr(10).join(['deutsch-garden/'] + entries) + chr(10)


new_tree = project_tree()
tree_path = ROOT / 'PROJECT_TREE.txt'

# FILE_SHA256SUMS.txt is a tripwire, not a security control: it lives in the
# same tree as the files it hashes, so anyone who can edit a file can edit its
# hash. It is useful for spotting an unintended change, and useless against a
# determined one. Generated here so it cannot silently go stale, which it had.
import hashlib

checksums_path = ROOT / 'FILE_SHA256SUMS.txt'


def file_checksums() -> str:
    lines = []
    for path in _inventory_paths():
        rel = path.relative_to(ROOT)
        if any(part in TREE_SKIP_DIRS for part in rel.parts):
            continue
        if path.is_dir():
            continue
        if path.name in TREE_SKIP_NAMES or path.name.endswith(TREE_SKIP_SUFFIXES):
            continue
        if path.name == 'FILE_SHA256SUMS.txt':
            continue
        if rel.as_posix() in TREE_SKIP_RELATIVE:
            continue
        if _is_ignored(rel):
            continue
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        lines.append('%s  ./%s' % (digest, rel.as_posix()))
    return chr(10).join(lines) + chr(10)


# Computed after the other generated files are written, so it hashes their
# final contents rather than the previous run's.

build_info_path = LIB / 'build_info.dart'

def write_lf(path, text):
    """Write with Unix line endings on every platform.

    `Path.write_text` applies the platform's newline translation, which on
    Windows silently turns every generated file into CRLF. That makes the
    checksum manifest unverifiable with `sha256sum -c` and churns the diff
    depending on who ran the generator.
    """
    with io.open(path, 'w', encoding='utf-8', newline='') as handle:
        handle.write(text)


if '--write' in sys.argv:
    write_lf(manifest_path, new_manifest)
    write_lf(report_path, new_report)
    write_lf(build_info_path, build_info)
    write_lf(tree_path, new_tree)
    # Last: it hashes everything above.
    write_lf(checksums_path, file_checksums())
    print()
    print('Regenerated CONTENT_MANIFEST.json, VALIDATION_REPORT.txt, '
          'lib/build_info.dart, PROJECT_TREE.txt and FILE_SHA256SUMS.txt')
else:
    # In CI the generated files must already be up to date, so a stale commit
    # fails the build instead of silently shipping wrong numbers.
    stale = []
    for path, expected in (
        (manifest_path, new_manifest),
        (report_path, new_report),
        (build_info_path, build_info),
        (tree_path, new_tree),
    ):
        current = path.read_text(encoding='utf-8') if path.exists() else ''
        # The generated date changes daily and is not worth failing over.
        strip = lambda t: re.sub(r'"generated":\s*"[^"]*"', '', t)
        if strip(current) != strip(expected):
            stale.append(path.name)
    if stale:
        print()
        print('GENERATED FILES ARE STALE: ' + ', '.join(stale))
        print('Run: python tool/validate_content.py --write')
        sys.exit(1)
