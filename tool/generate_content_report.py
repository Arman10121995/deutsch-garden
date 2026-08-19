#!/usr/bin/env python3
"""Regenerate CONTENT_MANIFEST.json from the bundled Dart sources.

Every number is counted from the source rather than typed in, so the manifest
cannot drift away from what the app actually ships.
"""
import json
import re
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
LOWER = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2']


def read(name):
    return (LIB / name).read_text(encoding='utf-8')


def count(pattern, text):
    return len(re.findall(pattern, text))


vocab = read('vocabulary.dart') + read('vocabulary_expansion.dart')
curriculum = read('curriculum.dart')
grammar_x = read('grammar_expansion.dart')
skill_x = read('skill_expansion.dart')
speaking = read('speaking_curriculum.dart')
assessment = read('assessment.dart')
test_prep = read('test_prep.dart')
conversation = read('conversation.dart')
stories = read('stories.dart')
sentences = read('sentence_bank.dart')
achievements = read('achievements.dart')

levels = {lv: count(r"level:\s*'" + lv + r"'", vocab) for lv in LEVELS}

scenario_ids = re.findall(r"\bid: '(cv-[a-z0-9-]+)'", conversation)
free_talk_ids = re.findall(r"\bid: '(ft-[a-z0-9-]+)'", conversation)
story_ids = re.findall(r"\bid: '(st-[a-z0-9]+-\d+)',", stories)
chapter_ids = re.findall(r"\bid: '(st-[a-z0-9]+-\d+-c\d+)'", stories)

report = {
    'release': re.search(r'^version:\s*(\S+)', (ROOT / 'pubspec.yaml').read_text(encoding='utf-8'), re.MULTILINE).group(1),
    'generated': date.today().isoformat(),
    'vocabulary_by_level': levels,
    'vocabulary_total': sum(levels.values()),
    'grammar_lessons': count(r"GrammarLesson\(\s*id:", curriculum) + count(r"_GrammarSpec\('", grammar_x),
    'listening_lessons': count(r"ListeningLesson\(", curriculum) + count(r"ListeningLesson\(", skill_x),
    'reading_lessons': count(r"ReadingLesson\(", curriculum) + count(r"ReadingLesson\(", skill_x),
    'writing_lessons': count(r"WritingLesson\(", curriculum) + count(r"WritingLesson\(", skill_x),
    'speaking_lessons': count(r"SpeakingLesson\(id:", speaking),
    'placement_items': count(r"PlacementQuestion\(id:", assessment),
    'exam_mini_mocks': count(r"ExamPracticeSet\(id:", test_prep),
    'conversation_scenarios': len(scenario_ids),
    'conversation_scenarios_by_level': {
        lv: len([i for i in scenario_ids if i.startswith(f'cv-{low}-')])
        for low, lv in zip(LOWER, LEVELS)
    },
    'free_talk_prompts': len(free_talk_ids),
    'stories': len(story_ids),
    'story_chapters': len(chapter_ids),
    'stories_by_level': {
        lv: len([i for i in story_ids if i.startswith(f'st-{low}-')])
        for low, lv in zip(LOWER, LEVELS)
    },
    'curated_practice_sentences': len(re.findall(r"\bid: '(ps-[a-z0-9-]+)'", sentences)),
    'achievements': count(r"Achievement\(id:", achievements),
    'daily_quests_in_pool': count(r"DailyQuest\(id:", achievements),
    'note': (
        'Lexical breadth targets are pedagogical planning targets, not official '
        'CEFR word-count thresholds. Speaking feedback is produced by an '
        'on-device rule-based evaluator, not a language model or an acoustic '
        'pronunciation scorer.'
    ),
}

(ROOT / 'CONTENT_MANIFEST.json').write_text(
    json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8'
)
print(json.dumps(report, indent=2, ensure_ascii=False))
