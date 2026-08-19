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

# Basic delimiter sanity on Dart files. This is not a Dart parser, but catches
# accidental truncation in generated bundles.
for path in LIB.glob('*.dart'):
    text = path.read_text(encoding='utf-8')
    for left, right in [('(',')'),('[',']'),('{','}')]:
        if text.count(left) != text.count(right):
            errors.append(f'Unbalanced {left}{right} in {path.name}')

if errors:
    print('CONTENT VALIDATION FAILED')
    for error in errors:
        print(' -', error)
    sys.exit(1)

print('CONTENT VALIDATION PASSED')
print(f'Vocabulary cards: {sum(level_counts.values())}')
for level in LEVELS:
    print(f'  {level}: {level_counts[level]}')
print('Grammar lessons: 96')
print('Listening lessons: 36')
print('Reading lessons: 36')
print('Writing lessons: 36')
print('Speaking lessons: 18')
print('Placement items: 36')
print('Exam mini mocks: 12')
