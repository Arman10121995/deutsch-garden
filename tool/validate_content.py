#!/usr/bin/env python3
"""Source-level content integrity checks that do not require Flutter/Dart."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
LEVELS = ['A1','A2','B1','B2','C1','C2']
errors = []


def read(name):
    return (LIB / name).read_text(encoding='utf-8')

# Vocabulary integrity in the two data files.
vocab_text = read('vocabulary.dart') + '\n' + read('vocabulary_expansion.dart')
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
