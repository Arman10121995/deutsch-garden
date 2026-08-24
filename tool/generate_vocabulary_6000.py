#!/usr/bin/env python3
"""Build the 6,000-card vocabulary expansion from open lexical sources.

This is a maintainer tool, not part of the application runtime.  It combines:

* wordhoard's frequency-ranked German lemmas, gender, inflection and CEFR
  estimates (dataset v0.1.0, CC BY-SA 4.0);
* Lector's German Wiktionary SQLite build for canonical POS and English senses
  (dictionary-de-2026-06-25, CC BY-SA 4.0); and
* German/English Tatoeba sentence pairs distributed by ManyThings (CC BY 2.0
  France).

The source archives are cached in the operating-system temp directory.  The
German spaCy small model checks the target lemma and part of speech in context,
so an adjective surface form cannot accidentally become a verb card.  No model
invents headwords, genders, plurals, translations or example pairs.

Generated data is written to lib/vocabulary_generated.dart, while exact
sentence attribution is kept in docs/VOCABULARY_ATTRIBUTIONS.tsv.  The output
is intentionally deterministic after tool/vocabulary_gloss_cache.json exists.
"""
from __future__ import print_function

import argparse
import csv
import io
import json
import os
from pathlib import Path
import re
import sqlite3
import sys
import tempfile
import urllib.request
import zipfile


ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
DOCS = ROOT / 'docs'
OUTPUT = LIB / 'vocabulary_generated.dart'
ATTRIBUTIONS = DOCS / 'VOCABULARY_ATTRIBUTIONS.tsv'
SENSE_CACHE = ROOT / 'tool' / 'vocabulary_sense_cache.json'
ID_MAP = ROOT / 'tool' / 'vocabulary_id_map.json'
WORDHOARD_URL = (
    'https://github.com/natema/wordhoard/releases/download/v0.1.0/'
    'wordhoard-csv-v0.1.0.zip'
)
LECTOR_URL = (
    'https://github.com/heuwels/lector/releases/download/'
    'dict-de-2026-06-25/dictionary-de.db'
)
TATOEBA_URL = 'https://www.manythings.org/anki/deu-eng.zip'
LEVELS = ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')
# The first four bands are the increments implied by the project's existing
# cumulative breadth plan (650 -> 1,400 -> 2,600 -> 4,200).  The remaining
# advanced bands follow the same roadmap to 6,800 cumulative words at C1 and
# 10,000 at C2.  These are bundled-card inventory targets, not official CEFR
# vocabulary-size claims.
TARGETS = {
    'A1': 650,
    'A2': 750,
    'B1': 1200,
    'B2': 1600,
    'C1': 2600,
    'C2': 3200,
}
ALLOWED_POS = {
    'NOUN', 'VERB', 'AUX', 'ADJ', 'ADV', 'ADP', 'CCONJ', 'SCONJ',
    'PRON', 'DET', 'PART', 'INTJ', 'NUM',
}
DICTIONARY_POS = {
    'NOUN': 'noun',
    'VERB': 'verb',
    'AUX': 'verb',
    'ADJ': 'adj',
    'ADV': 'adv',
    'ADP': 'prep',
    'CCONJ': 'conj',
    'SCONJ': 'conj',
    'PRON': 'pron',
    'DET': 'det',
    'PART': 'particle',
    'INTJ': 'intj',
    'NUM': 'num',
}
SPACY_POS = {
    'NOUN': {'NOUN'},
    'VERB': {'VERB', 'AUX'},
    'AUX': {'VERB', 'AUX'},
    'ADJ': {'ADJ'},
    'ADV': {'ADV'},
    'ADP': {'ADP'},
    'CCONJ': {'CCONJ', 'SCONJ'},
    'SCONJ': {'CCONJ', 'SCONJ'},
    'PRON': {'PRON'},
    'DET': {'DET'},
    'PART': {'PART'},
    'INTJ': {'INTJ'},
    'NUM': {'NUM'},
}
WORD_RE = re.compile(r"[A-Za-zÄÖÜäöüß]+(?:-[A-Za-zÄÖÜäöüß]+)*")
LEMMA_RE = re.compile(r"^[A-Za-zÄÖÜäöüß][A-Za-zÄÖÜäöüß -]*$")
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

# Exclude content that is unsuitable for a general-audience course even when
# it is frequent in subtitle corpora.  Matching is case-folded and whole-word.
BLOCKED = {
    'arsch', 'arschloch', 'bastard', 'fick', 'ficken', 'fotze', 'hure',
    'hurensohn', 'miststück', 'nazi', 'neger', 'scheiße', 'schlampe',
    'schwuchtel', 'vergewaltigen', 'wichser',
}
BLOCKED_ENGLISH = {
    'asshole', 'bastard', 'bitch', 'fuck', 'fucking', 'nazi', 'nigger',
    'rape', 'raped', 'raping', 'slut', 'whore',
}


def download(url, target):
    if target.exists():
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    print('Downloading', url)
    request = urllib.request.Request(
        url, headers={'User-Agent': 'DeutschGarden-content-builder/1.0'})
    with urllib.request.urlopen(request, timeout=120) as source, io.open(
            str(target), 'wb') as destination:
        while True:
            chunk = source.read(1024 * 1024)
            if not chunk:
                break
            destination.write(chunk)


def extract_member(archive, member, target):
    if target.exists():
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(str(archive)) as bundle:
        with bundle.open(member) as source, io.open(
                str(target), 'wb') as destination:
            while True:
                chunk = source.read(1024 * 1024)
                if not chunk:
                    break
                destination.write(chunk)


def prepare_sources(cache_dir):
    wordhoard_zip = cache_dir / 'wordhoard-csv-v0.1.0.zip'
    wordhoard_csv = cache_dir / 'wordhoard-de.csv'
    lector_db = cache_dir / 'dictionary-de.db'
    tatoeba_zip = cache_dir / 'deu-eng.zip'
    tatoeba_tsv = cache_dir / 'deu.txt'
    download(WORDHOARD_URL, wordhoard_zip)
    extract_member(wordhoard_zip, 'wordhoard-de.csv', wordhoard_csv)
    download(LECTOR_URL, lector_db)
    download(TATOEBA_URL, tatoeba_zip)
    extract_member(tatoeba_zip, 'deu.txt', tatoeba_tsv)
    return wordhoard_csv, lector_db, tatoeba_tsv


def existing_cards():
    cards = []
    for path in sorted(LIB.glob('vocabulary*.dart')):
        if path.resolve() == OUTPUT.resolve():
            continue
        cards.extend(m.groupdict() for m in CARD_RE.finditer(
            path.read_text(encoding='utf-8')))
    return cards


def split_forms(value):
    out = []
    for item in value.split(';'):
        if ':' not in item:
            continue
        form, feature = item.rsplit(':', 1)
        form = form.strip()
        if form and WORD_RE.fullmatch(form):
            out.append((form, feature))
    return out


def semantic_glosses(connection, lemma, pos):
    """Return real Wiktionary senses, excluding form-of records."""
    expected = DICTIONARY_POS[pos]
    rows = connection.execute(
        'SELECT gloss FROM senses WHERE word = ? AND pos = ? '
        'ORDER BY sort_order, id', (lemma.lower(), expected)).fetchall()
    rejected_prefixes = (
        'inflection of ', 'alternative form of ', 'alternative spelling of ',
        'plural of ', 'genitive of ', 'dative of ', 'accusative of ',
        'nominative of ', 'comparative of ', 'superlative of ',
        'preterite of ', 'past participle of ', 'present participle of ',
        'imperative of ', 'subjunctive of ', 'synonym of ',
        'feminine equivalent of ', 'masculine equivalent of ',
        'formerly standard spelling of ', 'obsolete spelling of ',
        'nonstandard spelling of ',
    )
    found = []
    for (raw,) in rows:
        gloss = re.sub(r'\s+', ' ', raw.strip())
        folded_gloss = gloss.casefold()
        grammatical_form = (
            re.match(
                r'^(?:first|second|third).*\b'
                r'(?:present|preterite|subjunctive|imperative)\b',
                folded_gloss) or
            re.match(r'^(?:singular|plural) imperative\b', folded_gloss) or
            re.match(
                r'^(?:strong|weak|mixed) '
                r'(?:nominative|accusative|dative|genitive)\b',
                folded_gloss)
        )
        if (not gloss or folded_gloss.startswith(rejected_prefixes) or
                ' standard spelling of ' in folded_gloss or
                grammatical_form):
            continue
        # Very long dictionary notes are correct but poor flashcard fronts.
        if len(gloss) > 140:
            gloss = gloss[:137].rsplit(' ', 1)[0] + '…'
        gloss = clean_sentence(gloss, False)
        if gloss not in found:
            found.append(gloss)
        if len(found) == 6:
            break
    return found


def dictionary_forms(connection, lemma):
    rows = connection.execute(
        'SELECT inflected_form, type FROM inflections WHERE lemma = ?',
        (lemma.lower(),)).fetchall()
    ignored_types = {'auxiliary', 'table-tags', 'inflection-template'}
    return [form for form, kind in rows
            if kind not in ignored_types and WORD_RE.fullmatch(form)]


def canonical_candidate(row, dictionary):
    lemma = row['lemma'].strip()
    pos = row['pos'].strip()
    article = row['gender'].strip()
    level = row['cefr_estimate'].strip()
    forms = split_forms(row.get('forms', ''))

    if (pos not in ALLOWED_POS or level not in LEVELS or
            not LEMMA_RE.fullmatch(lemma) or '�' in lemma or ' ' in lemma):
        return None
    if lemma.casefold() in BLOCKED:
        return None

    plural = '—'
    if pos == 'NOUN':
        if article not in ('der', 'die', 'das'):
            return None
        nominatives = [form for form, feature in forms
                       if feature == 'nom.sg']
        if not nominatives:
            return None
        lemma = nominatives[0]
        # Subtitle abbreviations such as IM are occasionally tagged as nouns.
        if lemma.isupper() and len(lemma) > 1:
            return None
        lemma = lemma[:1].upper() + lemma[1:]
        plurals = [form for form, feature in forms
                   if feature in ('nom.pl', 'pl')]
        if plurals:
            plural = 'die ' + plurals[0]
    else:
        article = ''
        lemma = lemma[:1].lower() + lemma[1:]

    if lemma.casefold() in BLOCKED or not LEMMA_RE.fullmatch(lemma):
        return None

    senses = semantic_glosses(dictionary, lemma, pos)
    if not senses:
        return None

    search_forms = {lemma.casefold()}
    for form in dictionary_forms(dictionary, lemma):
        if len(form) >= 2:
            search_forms.add(form.casefold())

    return {
        'article': article,
        'german': lemma,
        'plural': plural,
        'level': level,
        'pos': pos,
        'english': senses[0],
        'senses': senses,
        'rank': int(row['frequency_rank']),
        'forms': sorted(search_forms, key=lambda item: (-len(item), item)),
    }


def fold(value):
    return (value.casefold().replace('ä', 'a').replace('ö', 'o')
            .replace('ü', 'u').replace('ß', 'ss'))


def validator_stem(german):
    stem = fold(german)
    for suffix in ('en', 'n', 'e', 'st', 't'):
        if len(stem) - len(suffix) >= 3 and stem.endswith(suffix):
            stem = stem[:-len(suffix)]
            break
    return stem[:max(3, min(len(stem), 6))]


def clean_sentence(value, german=False):
    value = re.sub(r'\s+', ' ', value.strip())
    value = value.replace('\\', '/').replace('$', 'dollar')
    value = value.replace("'", '’')
    if german:
        # Tatoeba contains a small number of otherwise useful sentences in
        # pre-1996 spelling.  Normalize the unambiguous high-frequency forms
        # so the app consistently teaches the current orthography.
        spelling = {
            'daß': 'dass', 'Daß': 'Dass',
            'muß': 'muss', 'Muß': 'Muss',
            'laß': 'lass', 'Laß': 'Lass',
            'bißchen': 'bisschen', 'Bißchen': 'Bisschen',
            'gewußt': 'gewusst', 'Gewußt': 'Gewusst',
            'wußte': 'wusste', 'Wußte': 'Wusste',
        }
        value = re.sub(
            r'\b(?:daß|Daß|muß|Muß|laß|Laß|bißchen|Bißchen|'
            r'gewußt|Gewußt|wußte|Wußte)\b',
            lambda match: spelling[match.group(0)], value)
    if german and value.count('"') >= 2 and value.count('"') % 2 == 0:
        opened = False
        chars = []
        for char in value:
            if char == '"':
                chars.append('„' if not opened else '“')
                opened = not opened
            else:
                chars.append(char)
        value = ''.join(chars)
    elif not german and value.count('"') >= 2 and value.count('"') % 2 == 0:
        opened = False
        chars = []
        for char in value:
            if char == '"':
                chars.append('“' if not opened else '”')
                opened = not opened
            else:
                chars.append(char)
        value = ''.join(chars)
    return value


def sentence_score(candidate, german, matched_form, english):
    stripped = german.strip()
    if (not re.match(r'^(?:[A-ZÄÖÜ]|["„‚][A-ZÄÖÜ])', stripped) or
            stripped[-1:] not in '.!?'):
        return None
    words = WORD_RE.findall(german)
    if len(words) < 3 or len(words) > 18:
        return None
    if validator_stem(candidate['german']) not in fold(german):
        return None
    desired = {'A1': 5, 'A2': 7, 'B1': 9, 'B2': 10,
               'C1': 11, 'C2': 12}[candidate['level']]
    names = {
        'tom', 'toms', 'mary', 'marys', 'maria', 'marias',
        'sami', 'samis', 'layla', 'laylas', 'boston',
    }
    lowered = {word.casefold() for word in words}
    english_words = {
        word.casefold() for word in re.findall(r"[A-Za-z]+", english)
    }
    if (lowered & BLOCKED or lowered & names or
            english_words & BLOCKED_ENGLISH):
        return None
    exact_penalty = 0 if matched_form == candidate['german'].casefold() else 2
    question_penalty = 1 if german.endswith('?') else 0
    return abs(len(words) - desired) + exact_penalty + question_penalty


def example_matches_pos(candidate, matched_form, doc):
    """Verify that the matched surface is the intended POS in this sentence."""
    expected = SPACY_POS[candidate['pos']]
    wanted_lemma = candidate['german'].casefold()
    for token in doc:
        if token.text.casefold() != matched_form:
            continue
        if token.pos_ not in expected:
            continue
        if candidate['pos'] == 'ADP':
            # German prepositions normally introduce a nominal/adverbial
            # complement.  This rejects common false positives where spaCy
            # tags a stranded separable prefix ("Hör gut zu") or an imperative
            # particle ("Auf geht's") as ADP.
            following = [item for item in doc[token.i + 1:token.i + 4]
                         if not item.is_punct]
            if (not following or following[0].pos_ in
                    {'VERB', 'AUX', 'CCONJ', 'SCONJ'}):
                continue
        # spaCy occasionally misses imperatives and split verbs.  The surface
        # came from Wiktionary's inflection table, so a POS match is sufficient;
        # a lemma match is preferred but not required.
        if token.lemma_.casefold() == wanted_lemma:
            return True
        if candidate['pos'] in ('VERB', 'AUX'):
            return True
        if candidate['pos'] in ('NOUN', 'ADJ', 'ADV'):
            return fold(token.lemma_) == fold(candidate['german'])
        return True
    return False


def category_for(candidate):
    word = candidate['german'].casefold()
    gloss = candidate['english'].casefold()
    pos = candidate['pos']
    combined = word + ' ' + gloss
    category_tokens = set(re.findall(r'[a-z]+', combined))
    keyword_categories = [
        ('Food', ('food', 'drink', 'meal', 'cook', 'fruit', 'vegetable', 'bread')),
        ('Travel', ('travel', 'journey', 'train', 'flight', 'hotel', 'road', 'vehicle')),
        ('Health', ('health', 'medical', 'disease', 'illness', 'pain', 'doctor')),
        ('Technology', ('computer', 'software', 'digital', 'machine', 'internet', 'data')),
        ('Work', ('work', 'job', 'business', 'office', 'employee', 'employer')),
        ('Study', ('school', 'study', 'student', 'learn', 'university', 'education')),
        ('People', ('person', 'man', 'woman', 'child', 'family', 'friend')),
        ('Home', ('house', 'home', 'room', 'furniture', 'kitchen', 'garden')),
        ('Nature', ('animal', 'plant', 'weather', 'river', 'mountain', 'forest')),
        ('Communication', ('speak', 'say', 'write', 'answer', 'question', 'message')),
        ('Time', ('time', 'day', 'week', 'month', 'year', 'hour')),
        ('Culture', ('music', 'art', 'film', 'book', 'religion', 'tradition')),
        ('Society', ('government', 'politic', 'society', 'law', 'public', 'econom')),
    ]
    for category, keywords in keyword_categories:
        if any(
            token == keyword or (len(keyword) >= 5 and token.startswith(keyword))
            for keyword in keywords for token in category_tokens
        ):
            return category
    if pos in ('VERB', 'AUX'):
        return 'Actions'
    if pos in ('ADJ', 'ADV'):
        return 'Description'
    if pos in ('ADP', 'CCONJ', 'SCONJ', 'PRON', 'DET', 'PART', 'INTJ', 'NUM'):
        return 'Language'
    if (word.endswith(('ung', 'heit', 'keit', 'schaft', 'ismus', 'ität')) or
            any(item in gloss for item in ('concept', 'quality', 'state of',
                                            'process of'))):
        return 'Abstract'
    return 'General'


def select_candidates(wordhoard_csv, lector_db, tatoeba_tsv, current):
    existing_keys = {
        ((card['article'] + ' ' + card['german']).strip().casefold())
        for card in current
    }
    existing_bare = {card['german'].casefold() for card in current}
    counts = {level: sum(card['level'] == level for card in current)
              for level in LEVELS}
    needed = {level: TARGETS[level] - counts[level] for level in LEVELS}
    if any(value < 0 for value in needed.values()):
        raise RuntimeError('A level already exceeds its configured target: %r'
                           % counts)

    candidates = []
    seen = set(existing_keys)
    seen_bare = set(existing_bare)
    dictionary = sqlite3.connect(str(lector_db))
    with io.open(str(wordhoard_csv), encoding='utf-8', newline='') as handle:
        for row in csv.DictReader(handle):
            candidate = canonical_candidate(row, dictionary)
            if candidate is None:
                continue
            key = ((candidate['article'] + ' ' + candidate['german'])
                   .strip().casefold())
            bare = candidate['german'].casefold()
            if key in seen:
                continue
            # One non-noun sense per spelling keeps duplicate POS analyses from
            # becoming visually identical flashcards.
            if not candidate['article'] and bare in seen_bare:
                continue
            seen.add(key)
            seen_bare.add(bare)
            candidates.append(candidate)

    # We only need the most frequent slice.  Keeping a generous multiple lets
    # the sentence-quality filter reject noisy entries without reaching rare
    # subtitle vocabulary.
    pools = {}
    for level in LEVELS:
        level_rows = [item for item in candidates if item['level'] == level]
        level_rows.sort(key=lambda item: item['rank'])
        pools[level] = level_rows[:max(needed[level] * 6, needed[level] + 600)]

    flat = [item for level in LEVELS for item in pools[level]]
    flat_indexes = {id(item): index for index, item in enumerate(flat)}
    form_index = {}
    for index, candidate in enumerate(flat):
        for form in candidate['forms']:
            form_index.setdefault(form, []).append(index)

    # Keep several short, level-appropriate options per headword.  Contextual
    # POS validation happens after this cheap corpus scan, reducing hundreds of
    # thousands of spaCy parses to a much smaller unique sentence set.
    best = [[] for _ in flat]
    with io.open(str(tatoeba_tsv), encoding='utf-8') as handle:
        for line in handle:
            parts = line.rstrip('\n').split('\t')
            if len(parts) < 3:
                continue
            english, german, attribution = parts[0], parts[1], parts[2]
            if len(german) > 180 or len(english) > 180:
                continue
            tokens = {token.casefold() for token in WORD_RE.findall(german)}
            for token in tokens:
                for index in form_index.get(token, ()):
                    candidate = flat[index]
                    score = sentence_score(candidate, german, token, english)
                    if score is None:
                        continue
                    tie_break = (score, len(german), german)
                    options = best[index]
                    if any(option[1] == german for option in options):
                        continue
                    options.append((tie_break, german, english,
                                    attribution.strip(), token))
                    options.sort(key=lambda option: option[0])
                    del options[8:]

    try:
        import spacy
    except ImportError:
        raise RuntimeError(
            'Install spacy 3.4 and de_core_news_sm 3.4 to rebuild vocabulary')
    nlp = spacy.load('de_core_news_sm', disable=['parser', 'ner'])
    unique_sentences = sorted({option[1] for options in best
                               for option in options})
    print('Checking POS in %d candidate example sentences' %
          len(unique_sentences))
    docs = {}
    for sentence, doc in zip(
            unique_sentences,
            nlp.pipe(unique_sentences, batch_size=512, n_process=1)):
        docs[sentence] = doc

    selected = []
    for level in LEVELS:
        with_examples = []
        for candidate in pools[level]:
            index = flat_indexes[id(candidate)]
            matches = []
            for option in best[index]:
                if example_matches_pos(candidate, option[4], docs[option[1]]):
                    matches.append(option)
            if not matches:
                continue
            item = dict(candidate)
            item.pop('forms', None)
            item['_examples'] = [{
                'qualityPenalty': option[0][0],
                'german': clean_sentence(option[1], True),
                'english': clean_sentence(option[2], False),
                'attribution': option[3],
            } for option in matches]
            # The contextual ranker below chooses the example/sense pair.
            item['exampleGerman'] = item['_examples'][0]['german']
            item['exampleEnglish'] = item['_examples'][0]['english']
            item['attribution'] = item['_examples'][0]['attribution']
            item['category'] = category_for(item)
            with_examples.append(item)
        with_examples.sort(key=lambda item: item['rank'])
        chosen = with_examples[:needed[level]]
        if len(chosen) != needed[level]:
            raise RuntimeError('%s needs %d cards but only %d candidates had '
                               'suitable bilingual examples'
                               % (level, needed[level], len(chosen)))
        selected.extend(chosen)
        print('%s: existing %d + generated %d = %d'
              % (level, counts[level], len(chosen), TARGETS[level]))

    if len(current) + len(selected) != sum(TARGETS.values()):
        raise AssertionError('selection did not reach exactly 10,000 cards')
    dictionary.close()
    return selected


def choose_contextual_senses(
        cards, model='sentence-transformers/all-MiniLM-L6-v2'):
    """Choose the best sourced example and authored Wiktionary sense.

    A fixed sentence-embedding model scores only combinations already present
    in the pinned sources.  It cannot generate a headword, translation, or
    example.  The selected indexes are persisted for deterministic rebuilds.
    """
    try:
        import numpy as np
        from sentence_transformers import SentenceTransformer
    except ImportError:
        raise RuntimeError(
            'Install sentence-transformers 2.2.2 to rank contextual senses')

    old_cache = {}
    if SENSE_CACHE.exists():
        cache_payload = json.loads(SENSE_CACHE.read_text(encoding='utf-8'))
        if (isinstance(cache_payload, dict) and
                cache_payload.get('schemaVersion') == 2 and
                cache_payload.get('model') == model):
            old_cache = cache_payload.get('choices', {})

    reusable = {}
    pending = []
    texts = set()
    for card in cards:
        key = '%s|%s|%s' % (card['level'], card['pos'], card['german'])
        card['_senseKey'] = key
        cached = old_cache.get(key)
        examples = card['_examples']
        if isinstance(cached, dict):
            sense_index = cached.get('senseIndex')
            example_german = cached.get('exampleGerman')
            context_score = cached.get('contextScore')
            example_index = next((
                index for index, option in enumerate(examples)
                if option['german'] == example_german), None)
            if (isinstance(sense_index, int) and
                    isinstance(context_score, (int, float)) and
                    example_index is not None and
                    0 <= sense_index < len(card['senses'])):
                reusable[key] = (
                    sense_index, example_index, float(context_score))
                continue
        pending.append(card)
        for sense in card['senses']:
            texts.add('Definition: ' + sense)
        for option in examples:
            texts.add('Meaning in context: ' + option['english'])

    print('Contextual pairs: %d cached, %d to rank' %
          (len(reusable), len(pending)))
    embeddings = {}
    if texts:
        ranker = SentenceTransformer(model)
        ordered_texts = sorted(texts)
        vectors = ranker.encode(
            ordered_texts, batch_size=256, show_progress_bar=True,
            convert_to_numpy=True, normalize_embeddings=True)
        embeddings = dict(zip(ordered_texts, vectors))

    choices = dict(reusable)
    for card in pending:
        sense_vectors = np.stack([
            embeddings['Definition: ' + sense] for sense in card['senses']
        ])
        best_score = None
        best_pair = None
        for example_index, option in enumerate(card['_examples']):
            context_vector = embeddings[
                'Meaning in context: ' + option['english']]
            semantic_scores = sense_vectors.dot(context_vector)
            for sense_index, semantic_score in enumerate(semantic_scores):
                # Prefer simple, level-appropriate sentences when semantic
                # matches are otherwise close.  Earlier corpus options win
                # exact ties, keeping output stable.
                score = (float(semantic_score) -
                         0.012 * min(option['qualityPenalty'], 10) -
                         0.0001 * example_index - 0.00001 * sense_index)
                if best_score is None or score > best_score:
                    best_score = score
                    best_pair = (sense_index, example_index)
        choices[card['_senseKey']] = (
            best_pair[0], best_pair[1], float(best_score))

    cache = {}
    for card in cards:
        key = card.pop('_senseKey')
        sense_index, example_index, context_score = choices[key]
        option = card['_examples'][example_index]
        card['english'] = card['senses'][sense_index]
        card['exampleGerman'] = option['german']
        card['exampleEnglish'] = option['english']
        card['attribution'] = option['attribution']
        card['category'] = category_for(card)
        cache[key] = {
            'senseIndex': sense_index,
            'exampleGerman': option['german'],
            'contextScore': round(context_score, 6),
        }
        card.pop('_examples', None)
        card.pop('senses', None)

    with io.open(str(SENSE_CACHE), 'w', encoding='utf-8',
                 newline='') as handle:
        handle.write(json.dumps({
            'schemaVersion': 2,
            'model': model,
            'choices': cache,
        }, ensure_ascii=False, indent=2, sort_keys=True) + '\n')


def dart_string(value):
    return (value.replace('\\', '\\\\').replace("'", "\\'")
            .replace('$', '\\$').replace('\r', ' ').replace('\n', ' '))


def assign_stable_ids(cards):
    """Preserve generated ID-to-lemma identity across future rebuilds."""
    entries = {}
    if ID_MAP.exists():
        payload = json.loads(ID_MAP.read_text(encoding='utf-8'))
        if payload.get('schemaVersion') != 1:
            raise RuntimeError('Unsupported vocabulary ID map schema')
        entries = dict(payload.get('entries', {}))

    used_ids = set(entries.values())
    numbers = [int(card_id[1:]) for card_id in used_ids
               if re.fullmatch(r'x\d+', card_id)]
    next_number = max([19999] + numbers) + 1
    active_keys = set()
    for card in cards:
        key = '%s|%s' % (card['article'].lower(), card['german'].lower())
        if key in active_keys:
            raise RuntimeError('Duplicate generated ID-map key: %s' % key)
        active_keys.add(key)
        card_id = entries.get(key)
        if card_id is None:
            while 'x%d' % next_number in used_ids:
                next_number += 1
            card_id = 'x%d' % next_number
            next_number += 1
            entries[key] = card_id
            used_ids.add(card_id)
        card['_id'] = card_id

    with io.open(str(ID_MAP), 'w', encoding='utf-8', newline='') as handle:
        handle.write(json.dumps({
            'schemaVersion': 1,
            'reservedStart': 20000,
            'entries': entries,
        }, ensure_ascii=False, indent=2, sort_keys=True) + '\n')


def write_outputs(cards):
    assign_stable_ids(cards)
    header = """// GENERATED by tool/generate_vocabulary_6000.py.
//
// Lexical metadata in this file is adapted from wordhoard v0.1.0 and German
// Wiktionary under CC BY-SA 4.0. Example pairs are from Tatoeba under CC BY
// 2.0 France. See THIRD_PARTY_CONTENT.md and docs/VOCABULARY_ATTRIBUTIONS.tsv.
import 'models.dart';

final List<GermanWord> generatedVocabulary = <GermanWord>[
"""
    lines = [header]
    attribution_lines = [
        'card_id\tgerman\ttatoeba_attribution',
    ]
    for card in cards:
        card_id = card.pop('_id')
        lines.append(
            "  GermanWord(id: '%s', article: '%s', german: '%s', plural: '%s', "
            "english: '%s', exampleGerman: '%s', exampleEnglish: '%s', "
            "category: '%s', level: '%s'),\n" % (
                card_id, dart_string(card['article']),
                dart_string(card['german']), dart_string(card['plural']),
                dart_string(card['english']),
                dart_string(card['exampleGerman']),
                dart_string(card['exampleEnglish']),
                dart_string(card['category']), card['level']))
        attribution_lines.append('%s\t%s\t%s' % (
            card_id, card['german'], card['attribution'].replace('\t', ' ')))
    lines.append('];\n')
    with io.open(str(OUTPUT), 'w', encoding='utf-8', newline='') as handle:
        handle.write(''.join(lines))
    with io.open(str(ATTRIBUTIONS), 'w', encoding='utf-8', newline='') as handle:
        handle.write('\n'.join(attribution_lines) + '\n')
    print('Wrote %d cards to %s' % (len(cards), OUTPUT))
    print('Wrote sentence attribution to %s' % ATTRIBUTIONS)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--select-only', action='store_true')
    parser.add_argument('--selection-json', type=Path,
                        default=Path(tempfile.gettempdir()) /
                        'deutsch-garden-vocabulary-selection.json')
    args = parser.parse_args()

    source_cache = (Path(tempfile.gettempdir()) /
                    'deutsch-garden-vocabulary-sources')
    wordhoard_csv, lector_db, tatoeba_tsv = prepare_sources(source_cache)
    current = existing_cards()
    selected = select_candidates(
        wordhoard_csv, lector_db, tatoeba_tsv, current)
    # Keep a deterministic pre-disambiguation checkpoint.  If a local model
    # is interrupted, the selected inventory remains available for review.
    raw_selection = args.selection_json.with_name(
        args.selection_json.stem + '-raw' + args.selection_json.suffix)
    with io.open(str(raw_selection), 'w', encoding='utf-8',
                 newline='') as handle:
        handle.write(json.dumps(selected, ensure_ascii=False, indent=2) + '\n')
    if not args.select_only:
        choose_contextual_senses(selected)
    selection_text = json.dumps(selected, ensure_ascii=False, indent=2) + '\n'
    with io.open(str(args.selection_json), 'w', encoding='utf-8',
                 newline='') as handle:
        handle.write(selection_text)
    print('Selection saved to', args.selection_json)
    if args.select_only:
        return 0
    write_outputs(selected)
    return 0


if __name__ == '__main__':
    sys.exit(main())
