#!/usr/bin/env python3
"""Source-level content integrity checks that do not require Flutter/Dart."""
from pathlib import Path
import hashlib
import io
import json
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

# Ids whose example the mechanical check cannot match but a human has verified.
EXAMPLE_EXCEPTIONS = set()
_exceptions_file = ROOT / 'tool' / 'example_check_exceptions.txt'
if _exceptions_file.exists():
    for _line in _exceptions_file.read_text(encoding='utf-8').splitlines():
        _line = _line.split('#')[0].strip()
        if _line:
            EXAMPLE_EXCEPTIONS.add(_line)
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
        if 'Das Lernwort heute ist' in eg:
            fail(card, 'placeholder example is forbidden')
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

        # Candidate stems the example is allowed to match. German makes this
        # harder than a substring test suggests:
        #
        #   - reflexive verbs are listed as "sich erinnern an" but appear as
        #     "erinnere mich an", so the sich and the governed preposition have
        #     to come off before matching;
        #   - separable verbs split, and take a ge- infix in the participle:
        #     nachweisen -> nachgewiesen, darstellen -> dargestellt;
        #   - strong verbs change their stem vowel: entscheiden -> entschieden,
        #     weisen -> gewiesen, ergeben -> ergibt.
        #
        # Rather than build a morphology engine, this collects every plausible
        # stem and passes if any one of them appears. Entries where even that
        # fails are listed in tool/example_check_exceptions.txt after a human
        # has read them.
        SEPARABLE = ('zusammen', 'gegenüber', 'entgegen', 'zurück', 'wieder',
                     'vorbei', 'unter', 'durch', 'über', 'nach', 'statt',
                     'voran', 'fort', 'dar', 'weg', 'vor', 'auf', 'aus', 'ein',
                     'ab', 'an', 'bei', 'mit', 'los', 'her', 'hin', 'um', 'zu',
                     'fest', 'frei', 'teil', 'heraus', 'herein', 'hinaus')
        FUNCTION_WORDS = {
            'sich', 'etwas', 'jemanden', 'jemandem', 'an', 'auf', 'von', 'für',
            'mit', 'vor', 'in', 'im', 'dem', 'den', 'der', 'die', 'das', 'zu',
            'über', 'um', 'aus', 'bei', 'nach', 'diesem', 'dieser', 'einen',
            'einem', 'eine', 'ein', 'als', 'zum', 'zur', 'ins', 'am', 'auch',
        }

        def strip_ending(value: str) -> str:
            for suffix in ('en', 'n', 'e', 'st', 't'):
                if len(value) - len(suffix) >= 3 and value.endswith(suffix):
                    return value[: -len(suffix)]
            return value

        def ablaut_variants(value: str) -> list:
            """Stem-vowel changes German strong verbs actually make.

            Each occurrence is substituted separately: the stem vowel of
            ergeben is the second e, so replacing only the first would give
            irgeb rather than the ergib that ergibt needs.
            """
            out = [value]
            if len(value) < 4:
                return out
            for source, target in (('ei', 'ie'), ('ie', 'ei'), ('ie', 'o'),
                                   ('e', 'i'), ('e', 'a'), ('e', 'o'),
                                   ('i', 'a'), ('a', 'u')):
                index = value.find(source)
                while index != -1:
                    out.append(value[:index] + target
                               + value[index + len(source):])
                    index = value.find(source, index + 1)
            return out

        folded = fold(german.lower())

        # Very short lemmas -- ja, an, da, na -- cannot be checked this way:
        # any three-letter stem occurs by chance, and any shorter one is not a
        # stem at all. Skip rather than pretend.
        if len(folded.replace(' ', '')) < 4:
            continue

        words = [w for w in folded.split() if w not in FUNCTION_WORDS]
        if not words:
            # A phrase made entirely of function words -- zum einen, als auch.
            # The phrase itself is what has to appear.
            if folded not in fold(eg.lower()):
                fail(card, 'German example does not contain the phrase')
            continue

        roots = []
        for word in words:
            roots.append(word)
            for prefix in SEPARABLE:
                if word.startswith(prefix) and len(word) > len(prefix) + 3:
                    roots.append(word[len(prefix):])
                    break

        wanted = set()
        for root in roots:
            # Both the whole root and the ending-stripped stem: Mann must stay
            # matchable as "mann", not be reduced to "man" and then discarded
            # for being too short.
            for form in (root, strip_ending(root)):
                for variant in ablaut_variants(form):
                    if len(variant) >= 3:
                        wanted.add(variant[:6])
                        wanted.add(variant[:4])

        haystack = fold(eg.lower())
        if wanted and not any(w in haystack for w in wanted):
            if card['id'] not in EXAMPLE_EXCEPTIONS:
                fail(card,
                     'German example does not use the word. If the example is '
                     'right and the check is wrong, add the id to '
                     'tool/example_check_exceptions.txt')

    return len(cards)


# Vocabulary integrity across every split vocabulary source file.
vocabulary_paths = sorted(LIB.glob('vocabulary*.dart'))
vocab_text = chr(10).join(
    path.read_text(encoding='utf-8') for path in vocabulary_paths)
vocab_cards = [match.groupdict() for match in CARD_RE.finditer(vocab_text)]
level_counts = {
    level: sum(card['level'] == level for card in vocab_cards)
    for level in LEVELS
}
# Every level must carry enough material to be worth studying, but the split
# between them is a pedagogical judgement, not a quota to be filled.
#
# This used to demand an exact distribution -- 650/750/1200/1600/2600/3200 --
# which is what produced a deck where 62 percent of the words sat at C1 and C2
# and everyday nouns such as der Hausschluessel were filed under C2 to make the
# numbers come out. Because the app gates content by level, that put words a
# beginner needs behind five levels of progression. A floor keeps every level
# populated without forcing a word to be mislabelled.
MINIMUM_PER_LEVEL = 400
MINIMUM_TOTAL = 6000

for level in LEVELS:
    if level_counts[level] < MINIMUM_PER_LEVEL:
        errors.append(
            '%s holds only %d cards; every level needs at least %d.'
            % (level, level_counts[level], MINIMUM_PER_LEVEL))
if sum(level_counts.values()) < MINIMUM_TOTAL:
    errors.append(
        'The deck holds %d cards; at least %d are expected.'
        % (sum(level_counts.values()), MINIMUM_TOTAL))
checked_cards = check_vocabulary(vocab_text, errors)

curriculum = read('curriculum.dart')
grammar_x = read('grammar_expansion.dart')
skill_x = read('skill_expansion.dart')
speaking = read('speaking_curriculum.dart')
assessment = read('assessment.dart')
test_prep = read('test_prep.dart')

expected_grammar = {
    'A1': 34, 'A2': 34, 'B1': 34,
    'B2': 34, 'C1': 34, 'C2': 37,
}
for level_low, level in zip(['a1','a2','b1','b2','c1','c2'], LEVELS):
    core_g = len(re.findall(rf"GrammarLesson\(\s*id:\s*'gr-{level_low}-", curriculum))
    sup_g = len(re.findall(rf"_GrammarSpec\('gr-{level_low}-x", grammar_x))
    grammar_count = core_g + sup_g
    if grammar_count != expected_grammar[level]:
        errors.append(
            f'{level} grammar count must be {expected_grammar[level]}, '
            f'found {grammar_count}')

    core_l = len(re.findall(rf"ListeningLesson\(\s*id:\s*'li-{level_low}-", curriculum))
    sup_l = len(re.findall(rf"ListeningLesson\(\s*id:\s*'lx-{level_low}-", skill_x))
    core_r = len(re.findall(rf"ReadingLesson\(\s*id:\s*'re-{level_low}-", curriculum))
    sup_r = len(re.findall(rf"ReadingLesson\(\s*id:\s*'rx-{level_low}-", skill_x))
    core_w = len(re.findall(rf"WritingLesson\(\s*id:\s*'wr-{level_low}-", curriculum))
    sup_w = len(re.findall(rf"WritingLesson\(\s*id:\s*'wx-{level_low}-", skill_x))
    sp = len(re.findall(rf"SpeakingLesson\(\s*id:\s*'sp-{level_low}-", speaking))
    pl = len(re.findall(rf"PlacementQuestion\(\s*id:\s*'pl-{level_low}-", assessment))
    mocks = len(re.findall(rf"ExamPracticeSet\(\s*id:\s*'mock-{level_low}-", test_prep))
    expected = {'listening': core_l+sup_l, 'reading':core_r+sup_r, 'writing':core_w+sup_w}
    for name, count in expected.items():
        if count < 6:
            errors.append(f'{level} {name} coverage too small: {count}')
    if sp < 3:
        errors.append(f'{level} speaking coverage too small: {sp}')
    if pl != 10:
        errors.append(f'{level} placement item count must be 10, found {pl}')
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
# Role-plays are split across files like the stories and radio scripts.
conversation = ''.join(
    path.read_text(encoding='utf-8')
    for path in sorted(LIB.glob('conversation*.dart'))
    if path.name != 'conversation_engine.dart'
    and path.name != 'conversation_screens.dart')
# Stories are split across files the same way the radio scripts are, so
# count across all of them. Reading only stories.dart hid a whole
# collection here exactly as it hid a batch of radio episodes.
stories_src = ''.join(
    path.read_text(encoding='utf-8')
    for path in sorted(LIB.glob('stories*.dart')))
sentences = read('sentence_bank.dart')

scenario_ids = re.findall(r"\bid: '(cv-[a-z0-9-]+)'", conversation)
free_talk_ids = re.findall(r"\bid: '(ft-[a-z0-9-]+)'", conversation)
story_ids = re.findall(r"\bid: '(st-[a-z0-9]+-\d+)',", stories_src)
chapter_ids = re.findall(r"\bid: '(st-[a-z0-9]+-\d+-c\d+)'", stories_src)
sentence_ids = re.findall(r"\bid: '(ps-[a-z0-9-]+)'", sentences)

# The expansion stores seven reviewable bilingual beats per story and derives
# chapter ids at runtime. Keep the target explicit in source and verify the
# resulting objects in Flutter tests; the static gate still accounts for every
# derived chapter in release metadata.
story_expansion = read('stories_expansion.dart')
generated_chapter_counts = [
    int(value) for value in re.findall(
        r'chapterCount:\s*(\d+)', story_expansion)
]
generated_chapter_total = sum(generated_chapter_counts)
story_chapter_total = len(chapter_ids) + generated_chapter_total

conversation_runtime = read('conversation.dart')
story_interview_match = re.search(
    r'const int storyInterviewTarget\s*=\s*(\d+)', conversation_runtime)
story_interview_total = (
    int(story_interview_match.group(1)) if story_interview_match else 0
)
scenario_total = len(scenario_ids) + story_interview_total

if len(story_ids) != 60:
    errors.append('Reader library has %d stories; expected 60.' % len(story_ids))
if story_chapter_total != 200:
    errors.append(
        'Reader library has %d chapters; expected 200.' % story_chapter_total
    )
if len(generated_chapter_counts) != 39:
    errors.append(
        'Reader expansion has %d seeds; expected 39.'
        % len(generated_chapter_counts)
    )
# Sixty authored role-plays, and the story interviews are extra rather than
# part of the sixty. Asserting the total alone let the authored count sit at
# twenty-three while the headline read sixty.
if len(scenario_ids) != 60:
    errors.append(
        'Conversation library has %d authored role-plays; expected 60. '
        '(Story interviews are counted separately and there are %d of them.)'
        % (len(scenario_ids), story_interview_total)
    )
if scenario_total != 60 + story_interview_total:
    errors.append(
        'Role-play total is %d but should be the 60 authored plus the %d '
        'story interviews.' % (scenario_total, story_interview_total)
    )

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

# Titles have to be distinct too, not just ids.
#
# Two A2 role-plays shipped as "Beim Arzt" -- different scenarios, different
# ids, same name in the same level list, so the library offered the learner the
# same label twice with no way to tell which was which. Ids being unique says
# nothing about whether a human can navigate the result.
def _titles_in(*sources):
    found = []
    for src in sources:
        found.extend(re.findall(r"\btitle: '([^']+)'", src))
    return found


for _label, _sources in [
    ('role-play', (conversation,)),
    ('story', (stories_src,)),
]:
    _titles = _titles_in(*_sources)
    _dupes = sorted({t for t in _titles if _titles.count(t) > 1})
    if _dupes:
        errors.append(
            'Duplicate %s titles: %s. Two entries with one name are '
            'indistinguishable in the library, whatever their ids say.'
            % (_label, _dupes[:10])
        )

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
#
# One known blind spot: a quoted string nested inside a `${...}` interpolation
# inside another string. The stripper closes the outer string at the inner
# quote and the counts go wrong on code that compiles fine. That has come up
# exactly once, in a conditional built inline in a widget, and the honest fix
# was to lift the expression into a named local -- so the failure message says
# that rather than pretending the file is corrupt.
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
            errors.append(
                f'Unbalanced {left}{right} in {path.name}. Either the file is '
                'truncated, or it contains a string interpolation with a '
                'nested quoted string inside it -- the stripper above cannot '
                'follow that, and neither can a reader. Lift the expression '
                'into a local variable rather than silencing this.'
            )

# ---------------------------------------------------------------------------
# Activity id namespaces.
#
# Every lesson, story chapter, role-play and radio episode records itself
# against its own id, and all of those records share one map in the profile.
# An id used by two pieces of content is therefore not a cosmetic clash: the
# two share a completion flag, a best score and a review schedule, so passing
# one marks the other done.
#
# This is not hypothetical. Gartenradio shipped with ids like `gr-a1-04`, the
# same shape the grammar lessons use, and twenty-one of the fifty-three
# episodes collided with a real grammar lesson for three releases. Nothing
# looked wrong: both screens worked, both recorded a score, and the score went
# to the same key. Radio moved to `rd-` in 3.11.0.
#
# Prefixes are therefore reserved per content type, and a file may only mint
# ids in its own namespace.
# ---------------------------------------------------------------------------
ID_NAMESPACES = [
    ('grammar lessons', ('gr-',),
     ['curriculum.dart', 'grammar_expansion.dart']),
    ('listening lessons', ('li-', 'lx-'),
     ['curriculum.dart', 'skill_expansion.dart']),
    ('reading lessons', ('re-', 'rx-'),
     ['curriculum.dart', 'skill_expansion.dart']),
    ('writing lessons', ('wr-', 'wx-', 'ws-'),
     ['curriculum.dart', 'skill_expansion.dart', 'writing_extra.dart',
      'story_writing.dart']),
    ('speaking lessons', ('sp-',), ['speaking_curriculum.dart']),
    ('radio episodes', ('rd-',),
     ['radio_a1.dart', 'radio_a2.dart', 'radio_b1.dart', 'radio_c.dart',
      'radio_episodes.dart', 'radio_a1_more.dart', 'radio_a2_more.dart',
      'radio_b1_more.dart', 'radio_b2_more.dart', 'radio_c1_more.dart',
      'radio_c2_more.dart']),
    ('role-plays', ('cv-',), ['conversation.dart', 'conversation_extra.dart']),
    ('practice sentences', ('ps-',), ['sentence_bank.dart']),
    ('free-talk prompts', ('ft-',), ['conversation.dart']),
]

_ID = re.compile(r"id: ?'([^']+)'")
_POSITIONAL = re.compile(r"_GrammarSpec\('([^']+)'")

_owner = {}
for _label, _prefixes, _files in ID_NAMESPACES:
    for _name in _files:
        _path = LIB / _name
        if not _path.exists():
            continue
        _text = _path.read_text(encoding='utf-8')
        _found = set(_ID.findall(_text)) | set(_POSITIONAL.findall(_text))
        for _id in _found:
            if not _id.startswith(_prefixes):
                continue
            _previous = _owner.get(_id)
            if _previous is not None and _previous != _label:
                errors.append(
                    'Activity id %r is used by both %s and %s. They would '
                    'share one progress record: passing either marks both '
                    'complete. Give one of them its own prefix.'
                    % (_id, _previous, _label)
                )
            _owner[_id] = _label

# And the reverse: a file minting ids in a namespace that is not its own. That
# is how the radio collision happened -- the episodes were not wrong about
# their own numbering, they were wrong about their prefix.
_RESERVED = {}
for _label, _prefixes, _files in ID_NAMESPACES:
    for _prefix in _prefixes:
        _RESERVED.setdefault(_prefix, set()).add(_label)

for _label, _prefixes, _files in ID_NAMESPACES:
    for _name in _files:
        _path = LIB / _name
        if not _path.exists():
            continue
        _text = _path.read_text(encoding='utf-8')
        _found = set(_ID.findall(_text)) | set(_POSITIONAL.findall(_text))
        for _id in _found:
            for _prefix, _owners in _RESERVED.items():
                if not _id.startswith(_prefix):
                    continue
                if _label in _owners:
                    continue
                # Shared files legitimately hold several types; only complain
                # when this file is not listed for that namespace at all.
                if any(_name in _f for _l, _p, _f in ID_NAMESPACES
                       if _prefix in _p):
                    continue
                errors.append(
                    '%s mints %r, but the %r prefix belongs to %s.'
                    % (_name, _id, _prefix, ' / '.join(sorted(_owners)))
                )

# ---------------------------------------------------------------------------
# Vocabulary icons.
#
# Every icon is original drawing authored for this app, which is the whole
# reason they are SVG rather than sourced photographs: Wikimedia's images of
# everyday objects are overwhelmingly CC-BY-SA, and shipping share-alike assets
# inside an MIT app is a compliance burden nobody wants to carry. A drawing has
# no third party to credit.
#
# So the checks here are mostly about keeping that true. An icon that reached
# out to a remote URL, or embedded a raster someone else made, would quietly
# undo both the offline guarantee and the clean-licence guarantee.
# ---------------------------------------------------------------------------
ICON_DIR = ROOT / 'assets' / 'vocab'
_ICON_FORBIDDEN = [
    ('<image', 'embeds a raster <image>'),
    ('<script', 'contains a <script>'),
    ('<foreignObject', 'contains a <foreignObject>'),
    ('http://', 'references a remote URL'),
    ('https://', 'references a remote URL'),
    ('<!ENTITY', 'declares an XML entity'),
]

if ICON_DIR.is_dir():
    _card_ids = {c['id'] for c in vocab_cards}
    _icons = sorted(ICON_DIR.glob('*.svg'))
    _icon_ids = set()
    _icon_digest_owner = {}
    for _icon in _icons:
        _stem = _icon.stem
        _text = _icon.read_text(encoding='utf-8')
        _icon_ids.add(_stem)

        _digest = hashlib.sha256(_text.strip().encode('utf-8')).hexdigest()
        if _digest in _icon_digest_owner:
            errors.append(
                'assets/vocab/%s.svg exactly duplicates %s.svg; distinct '
                'words need distinct semantic cues.'
                % (_stem, _icon_digest_owner[_digest])
            )
        else:
            _icon_digest_owner[_digest] = _stem

        if _stem not in _card_ids:
            errors.append(
                'assets/vocab/%s.svg does not match any vocabulary card id.'
                % _stem
            )
        if 'viewBox="0 0 64 64"' not in _text:
            errors.append(
                'assets/vocab/%s.svg is not on the shared 0 0 64 64 grid, so '
                'it will not line up with the others.' % _stem
            )
        for _needle, _why in _ICON_FORBIDDEN:
            # xmlns declarations are the one legitimate http:// in an SVG.
            _probe = _text.replace('http://www.w3.org/2000/svg', '')
            _probe = _probe.replace('http://www.w3.org/1999/xlink', '')
            if _needle.lower() in _probe.lower():
                errors.append(
                    'assets/vocab/%s.svg %s, which breaks the offline and '
                    'clean-provenance guarantees.' % (_stem, _why)
                )
        if len(_text.encode('utf-8')) > 6144:
            errors.append(
                'assets/vocab/%s.svg is %d bytes; icons are capped at 6144 so '
                'the whole set stays about a megabyte.'
                % (_stem, len(_text.encode('utf-8')))
            )

    # Declared or not shipped: Flutter asset directories are opt-in, and a
    # directory full of icons that nobody declared is a silent no-op.
    _pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    if _icons and 'assets/vocab/' not in _pubspec:
        errors.append(
            '%d vocabulary icons exist but assets/vocab/ is not declared in '
            'pubspec.yaml, so none of them would be bundled.' % len(_icons)
        )
    if len(_icons) < 950:
        errors.append(
            'Only %d authored vocabulary SVGs remain; expected at least 950.'
            % len(_icons)
        )

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

# ---------------------------------------------------------------------------
# Official Leben-in-Deutschland / citizenship-test catalogue.
#
# This is learner-facing legal/civics content with one objectively correct
# choice per question. A missing image, a shifted answer index or one omitted
# Bundesland would make practice actively misleading, so validate the checked-
# in generated assets independently of the Dart loader.
# ---------------------------------------------------------------------------
CIVICS_ROOT = ROOT / 'assets' / 'civics'
CIVICS_FILE = CIVICS_ROOT / 'questions.json'
CIVICS_STATE_CODES = {
    'BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV',
    'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH',
}
civics_general_total = 0
civics_state_total = 0
civics_state_count = 0
civics_image_total = 0

if not CIVICS_FILE.exists():
    errors.append('assets/civics/questions.json is missing.')
else:
    try:
        civics = json.loads(CIVICS_FILE.read_text(encoding='utf-8'))
        metadata = civics.get('metadata', {})
        states = civics.get('states', [])
        questions = civics.get('questions', [])
        state_codes = {state.get('code') for state in states}
        civics_state_count = len(states)
        if metadata.get('catalogStand') != '07.05.2025':
            errors.append(
                'Civics catalogue version changed; review the official '
                'source and importer before accepting it.'
            )
        for commit_key in ('validatedTextCommit', 'licensedImageCommit'):
            if not re.fullmatch(r'[0-9a-f]{40}',
                                str(metadata.get(commit_key, ''))):
                errors.append('Civics source commit %s is not pinned.'
                              % commit_key)
        for source_key in ('validatedTextExtraction',
                           'licensedImageExtraction'):
            if '/main/' in str(metadata.get(source_key, '')):
                errors.append('Civics source %s follows mutable main.'
                              % source_key)
        if state_codes != CIVICS_STATE_CODES or len(states) != 16:
            errors.append('Civics catalogue must define all 16 Bundesländer.')
        if len(questions) != 460:
            errors.append(
                'Civics catalogue has %d questions; expected 460.'
                % len(questions)
            )

        seen_civics_ids = set()
        declared_images = set()
        state_question_counts = {code: 0 for code in CIVICS_STATE_CODES}
        for question in questions:
            question_id = question.get('id', '')
            if not question_id or question_id in seen_civics_ids:
                errors.append('Civics question id %r is empty or duplicated.'
                              % question_id)
            seen_civics_ids.add(question_id)
            options = question.get('options', [])
            if len(options) != 4 or len(set(options)) != 4:
                errors.append('%s must have four distinct options.'
                              % question_id)
            answer = question.get('correctIndex')
            if not isinstance(answer, int) or answer not in range(4):
                errors.append('%s has an invalid correctIndex.' % question_id)
            if not str(question.get('question', '')).strip():
                errors.append('%s has empty question text.' % question_id)

            scope = question.get('scope')
            state_code = question.get('stateCode')
            if scope == 'general' and state_code is None:
                civics_general_total += 1
            elif scope == 'state' and state_code in CIVICS_STATE_CODES:
                civics_state_total += 1
                state_question_counts[state_code] += 1
            else:
                errors.append('%s has an invalid scope/state pair.'
                              % question_id)

            for image in question.get('images', []):
                asset = image.get('asset', '')
                relative = asset.replace('/', str(Path('/')))
                image_path = ROOT / relative
                if asset in declared_images:
                    errors.append('Civics image %s is referenced twice.' % asset)
                declared_images.add(asset)
                if not image_path.is_file():
                    errors.append('%s references missing image %s.'
                                  % (question_id, asset))
                    continue
                digest = hashlib.sha256(image_path.read_bytes()).hexdigest()
                if digest != image.get('sha256'):
                    errors.append('%s has a changed image hash.' % question_id)

        if civics_general_total != 300 or civics_state_total != 160:
            errors.append(
                'Civics distribution is %d general + %d state; expected '
                '300 + 160.' % (civics_general_total, civics_state_total)
            )
        for code, amount in state_question_counts.items():
            if amount != 10:
                errors.append('%s has %d state questions; expected 10.'
                              % (code, amount))
        image_dir = CIVICS_ROOT / 'images'
        actual_images = {
            path.relative_to(ROOT).as_posix()
            for path in image_dir.glob('*') if path.is_file()
        }
        civics_image_total = len(actual_images)
        if actual_images != declared_images:
            errors.append(
                'Civics image inventory differs from questions.json '
                '(%d declared, %d on disk).'
                % (len(declared_images), len(actual_images))
            )
        if not (CIVICS_ROOT / 'NOTICE.md').is_file():
            errors.append('Civics catalogue provenance notice is missing.')
        third_party_notice = ROOT / 'THIRD_PARTY_NOTICES.md'
        if (not third_party_notice.is_file() or
                'assets/civics/NOTICE.md' not in
                third_party_notice.read_text(encoding='utf-8')):
            errors.append('Root third-party notices omit the civics assets.')
    except (OSError, ValueError, TypeError) as exc:
        errors.append('Could not validate civics catalogue: %s' % exc)

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
story_writing_text = read('story_writing.dart')
story_writing_match = re.search(
    r'const int storyWritingTarget\s*=\s*(\d+)', story_writing_text)
story_writing_total = (
    int(story_writing_match.group(1)) if story_writing_match else 0
)
writing_total = (count(r"WritingLesson\(", curriculum)
                 + count(r"WritingLesson\(", skill_x)
                 + count(r"WritingLesson\(", read('writing_extra.dart'))
                 + story_writing_total)
if writing_total != 120:
    errors.append('Writing library has %d tasks; expected 120.' % writing_total)
speaking_total = count(r"SpeakingLesson\(id:", speaking)
placement_total = count(r"PlacementQuestion\(id:", assessment)
mock_total = count(r"ExamPracticeSet\(id:", test_prep)

# Fifty-three episodes are hand-authored seeds; the long-form builder extends
# those and creates the remaining 67 from validated, level-matched vocabulary.
# Counting constructor literals therefore under-reports the runtime library.
# Parse the explicit level targets and let the Dart tests verify the generated
# runtime objects, scripts and checkpoint distribution.
radio_target_text = read('radio_longform.dart')
radio_targets = {
    level.upper(): int(amount)
    for level, amount in re.findall(
        r'CefrLevel\.(a1|a2|b1|b2|c1|c2):\s*(\d+)',
        radio_target_text)
}
if set(radio_targets) != set(LEVELS):
    errors.append('Gartenradio must declare one target for every CEFR level.')
radio_total = sum(radio_targets.values())

radio_seed_files = [
    'radio_a1.dart', 'radio_a2.dart', 'radio_b1.dart', 'radio_c.dart',
]
radio_seed_text = ''.join(read(name) for name in radio_seed_files)
radio_seed_total = count(r"RadioEpisode\(", radio_seed_text)
radio_ids = re.findall(r"id: '(rd-[^']+)'", radio_seed_text)
if len(radio_ids) != radio_seed_total:
    errors.append(
        'Every hand-authored Gartenradio seed must have an rd- episode id.'
    )
if len(radio_ids) != len(set(radio_ids)):
    errors.append('Duplicate Gartenradio episode ids.')
if radio_seed_total > radio_total:
    errors.append('Gartenradio targets are below the hand-authored seed count.')

if errors:
    print('CONTENT VALIDATION FAILED')
    for error in errors:
        print(' -', error)
    sys.exit(1)

print('CONTENT VALIDATION PASSED')
print(f'Vocabulary cards: {sum(level_counts.values())}')
for level in LEVELS:
    print(f'  {level}: {level_counts[level]}')
print(f'Grammar lessons: {grammar_total}')
print(f'Listening lessons: {listening_total}')
print(f'Reading lessons: {reading_total}')
# Counts that mix authored and derived items report both halves.
#
# Three exercise formats are built on top of the 60 written stories: mini-story
# drills, guided writing retellings and story interviews. That is a good way to
# get several kinds of practice out of one authored corpus, and each generator
# says so in its own file. What it must not do is quietly inflate a headline
# number -- 120 writing tasks reads as 120 independent prompts, and it is 46 of
# those plus 74 retellings of chapters the learner has already read. Splitting
# the number is the difference between a format and a claim.

print(f'Writing lessons: {writing_total} ({writing_total - story_writing_total} authored + {story_writing_total} guided story retellings)')
print(f'Speaking lessons: {speaking_total}')
print(f'Placement items: {placement_total}')
print(f'Exam mini mocks: {mock_total}')
print(f'Conversation role-plays: {scenario_total} ({len(scenario_ids)} authored + {story_interview_total} story interviews)')
print(f'Free-talk prompts: {len(free_talk_ids)}')
print(f'Stories: {len(story_ids)} ({story_chapter_total} chapters)')
print(f'Mini-story drills: {len(story_ids)} (one derived from each story)')
print(f'Curated practice sentences: {len(sentence_ids)}')
print(f'Gartenradio episodes: {radio_total}')
print(
    'Civics questions: %d general + %d state across %d states (%d images)'
    % (civics_general_total, civics_state_total,
       civics_state_count, civics_image_total)
)


# ---------------------------------------------------------------------------
# Single source of truth for release metadata.
#
# The counts above are derived from the Dart sources, so they cannot be wrong.
# Every other file that states a count or a version is GENERATED from them or
# CHECKED against them here. Before this, five files carried hand-maintained
# copies and had already drifted apart: pubspec said 3.2.1+6, the changelog
# said 3.4.1, the README said 881 cards, and the manifest said 931.
# ---------------------------------------------------------------------------
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
    ('vocabulary cards', vocab_total, r'\*\*([\d,.]+) bundled vocabulary cards\*\*'),
    ('grammar lessons', grammar_total, r'\*\*([\d,.]+) grammar lessons\*\*'),
    ('listening lessons', listening_total, r'\*\*([\d,.]+) listening lessons\*\*'),
    ('reading lessons', reading_total, r'\*\*([\d,.]+) reading lessons\*\*'),
    ('writing lessons', writing_total, r'\*\*([\d,.]+) writing lessons\*\*'),
    ('speaking lessons', speaking_total, r'\*\*([\d,.]+) speaking lessons\*\*'),
    ('curated sentences', len(sentence_ids), r'\*\*([\d,.]+) curated practice sentences\*\*'),
    ('stories', len(story_ids), r'\*\*([\d,.]+) graded stories'),
    ('Gartenradio episodes', radio_total, r'\*\*([\d,.]+) narrated Gartenradio episodes\*\*'),
    ('official civics questions', civics_general_total + civics_state_total,
     r'\*\*([\d,.]+) official civics questions\*\*'),
]:
    found = re.search(pattern, readme)
    # Strip thousands separators before comparing. A README that writes
    # 10,000 must still be checked -- a pattern that quietly fails to
    # match turns the gate green while it has stopped looking.
    if not found:
        drift.append('README is missing the checked %s count.' % label)
    elif int(found.group(1).replace(',', '').replace('.', '')) != actual:
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
    'conversation_scenarios': scenario_total,
    'free_talk_prompts': len(free_talk_ids),
    'stories': len(story_ids),
    'story_chapters': story_chapter_total,
    'mini_story_drills': len(story_ids),
    'curated_practice_sentences': len(sentence_ids),
    'radio_episodes': radio_total,
    'civics_general_questions': civics_general_total,
    'civics_state_questions': civics_state_total,
    'civics_states': civics_state_count,
    'civics_images': civics_image_total,
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
    'Writing lessons: %d (%d authored + %d guided story retellings)'
    % (writing_total, writing_total - story_writing_total,
       story_writing_total),
    'Speaking lessons: %d' % speaking_total,
    'Placement items: %d' % placement_total,
    'Exam mini mocks: %d' % mock_total,
    'Conversation role-plays: %d (%d authored + %d story interviews)'
    % (scenario_total, len(scenario_ids), story_interview_total),
    'Free-talk prompts: %d' % len(free_talk_ids),
    'Stories: %d (%d chapters)' % (len(story_ids), story_chapter_total),
    'Mini-story drills: %d (one derived from each story)' % len(story_ids),
    'Curated practice sentences: %d' % len(sentence_ids),
    'Gartenradio episodes: %d' % radio_total,
    'Civics questions: %d general + %d state across %d states (%d images)'
    % (civics_general_total, civics_state_total,
       civics_state_count, civics_image_total),
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
    """The patterns in every .gitignore, with the directory they belong to.

    Git permits nested ignore files. Reading only the root file made a local
    checkout disagree with a fresh CI checkout when an editor or hosted-tool
    directory supplied its own ignore rules.
    """
    out = []
    ignore_files = sorted(ROOT.rglob('.gitignore'),
                          key=lambda path: path.relative_to(ROOT).as_posix())
    for path in ignore_files:
        base = path.parent.relative_to(ROOT)
        for raw in path.read_text(encoding='utf-8').splitlines():
            line = raw.strip()
            if not line or line.startswith('#'):
                continue
            dir_only = line.endswith('/')
            out.append((base, line.rstrip('/').lstrip('/'), dir_only))
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
    for base, pattern, dir_only in _IGNORES:
        if base == Path('.'):
            candidate = rel
        elif base == rel or base in rel.parents:
            candidate = rel.relative_to(base)
        else:
            continue
        candidate_parts = candidate.parts
        candidate_text = candidate.as_posix()
        # Git's **/* means every file below this ignore file, including the
        # ignore file itself. fnmatch intentionally does not match a one-part
        # path with that pattern, so handle the repository's rule explicitly.
        if pattern == '**/*':
            return True
        if dir_only:
            if pattern in candidate_parts[:-1]:
                return True
            continue
        if '/' in pattern:
            if fnmatch.fnmatch(candidate_text, pattern):
                return True
        else:
            if fnmatch.fnmatch(candidate_parts[-1], pattern):
                return True
            if pattern in candidate_parts[:-1]:
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
