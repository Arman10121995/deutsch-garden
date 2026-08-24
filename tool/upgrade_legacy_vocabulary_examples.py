#!/usr/bin/env python3
"""Replace legacy metalinguistic vocabulary examples with sourced pairs.

This maintainer tool deliberately shares the pinned ManyThings/Tatoeba corpus,
tokenisation, sentence cleaning, blocked-word policy and spaCy POS model used by
``generate_vocabulary_6000.py``.  It never writes an invented example.  A card
without a defensible corpus match is retained unchanged and recorded as
``unsourced`` in the attribution TSV.

Run without ``--write`` for a coverage report.  ``--write`` updates only the
two legacy vocabulary files and ``docs/LEGACY_VOCABULARY_ATTRIBUTIONS.tsv``.
Existing IDs and all non-example fields are retained for the 678 placeholder
cards.  The separately requested ``beteiligen`` correction keeps its legacy
headword but narrows the gloss to the reflexive sense demonstrated by its new,
sourced example.
"""
from __future__ import annotations

import argparse
import csv
import importlib.util
import io
import json
from pathlib import Path
import re
import sqlite3
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
EXPANSION = LIB / 'vocabulary_expansion.dart'
EXTRA = LIB / 'vocabulary_extra.dart'
ATTRIBUTIONS = ROOT / 'docs' / 'LEGACY_VOCABULARY_ATTRIBUTIONS.tsv'
PLACEHOLDER_PREFIX = 'Das Lernwort heute ist'


def load_generator():
    path = ROOT / 'tool' / 'generate_vocabulary_6000.py'
    spec = importlib.util.spec_from_file_location('vocabulary_6000', path)
    if spec is None or spec.loader is None:
        raise RuntimeError('cannot load generate_vocabulary_6000.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


GEN = load_generator()


WORDHOARD_TO_SPACY = {
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
LECTOR_TO_WORDHOARD = {
    'noun': 'NOUN',
    'verb': 'VERB',
    'adj': 'ADJ',
    'adv': 'ADV',
    'prep': 'ADP',
    'conj': 'CCONJ',
    'pron': 'PRON',
    'det': 'DET',
    'particle': 'PART',
    'intj': 'INTJ',
    'num': 'NUM',
}
VERB_GLOSS_PREFIXES = (
    'to ', 'can ', 'must ', 'would like', 'to be ', 'to have ',
)
REFLEXIVES = {'sich', 'mich', 'dich', 'uns', 'euch'}
CONTENT_POS = {'NOUN', 'VERB', 'AUX', 'ADJ', 'ADV'}
IGNORED_REQUIREMENTS = {
    'etwas', 'jemand', 'jemanden', 'einen', 'einer', 'eine', 'der', 'die',
    'das', 'den', 'dem', 'des', 'sich',
}
GLOSS_STOP = {
    'a', 'an', 'and', 'as', 'at', 'be', 'by', 'for', 'from', 'in', 'into',
    'of', 'on', 'or', 'something', 'that', 'the', 'this', 'to', 'with',
}

# Human-reviewed sense choices for polysemous words and for source pairs where
# the shortest candidate contains old orthography or a punctuation error.  The
# values are immutable Tatoeba sentence IDs present in the pinned ManyThings
# attribution field; selection still fails closed if a pair disappears.
CURATED_ATTRIBUTION_IDS = {
    'x10017': '#11002760',  # eine Liste machen, not the awkward Sake example
    'x10018': '#518554',    # lexical gehen, not es geht jemandem gut
    'x10056': '#2672038',
    'x10057': '#7796426',
    'x10069': '#9265149',   # temperature, not the colloquial heiße Feger
    'x10083': '#394485',    # adversative conjunction, not modal-particle aber
    'x10091': '#5023563',   # source has correct question punctuation
    'x10101': '#820547',    # arrange an appointment, not reconcile opinions
    'x10108': '#2151754',   # modern spelling lässt
    'x10141': '#5164983',   # modern spelling muss
    'x10150': '#9981588',
    'x10161': '#341725',    # verbal arbeiten an, not the noun Arbeiten
    'x10198': '#1545078',   # on the way, not merely out and about
    'x10208': '#236458',    # source includes the required German comma
    'x10235': '#3851215',   # justify/give reasons, not establish a dynasty
    'x10247': '#12678605',  # avoids the source typo "Tut mit leid"
    'x10251': '#12987195',
    'x10272': '#8886536',   # represent/act for, not stretch one's legs
    'x10283': '#2441520',   # genuinely reflexive sich für etwas entscheiden
    'x10321': '#1972416',   # adversative allerdings without comma misuse
    'x10334': '#12017696',
    'x10337': '#2752086',   # natural German, not a bilingual FAQ quotation
    'x10347': '#7299759',
    'x10357': '#2874160',   # substantiate with evidence, not take a class
    'x10368': '#4052360',   # depict, not constitute a problem
    'x10379': '#9512621',
    'x10392': '#5897434',   # record names and birthplaces, not grasp meaning
    'x10399': '#1682445',   # analytical criticism, not a medical condition
    'x10412': '#7267921',   # avoids a missing relative-clause comma
    'x10413': '#1300171',
    'x10422': '#8836694',   # in principle, not habitually/as a rule
    'x10486': '#1329594',   # facilitate sleep, not the false friend befürworten
}

# The corpus contains the spelling/form but no pair in the card's stated
# sense, or its sole pair is grammatically defective.  Retaining the original
# card is safer than teaching a homograph as if it were the requested sense.
CURATED_UNSAFE_IDS = {
    'x10273',  # sich vor Gericht verantworten != stated "be responsible for"
    'x10286',  # only transitive informieren pairs; no reflexive use
    'x10369',  # mark/label, not characterize
    'x10370',  # vorausgesetzt as conjunction, not presuppose
    'x10399',  # medical sense is natural; sole analytical pair is poor German
    'x10440',  # interrogative "through what", not relative whereby
    'x10493',  # load a dishwasher, not concede/grant
    'x10497',  # corroborate an alibi, not the stated reaffirm sense
    'x10533',  # alleged/suspected, not the legacy gloss presumably
    'x10537',  # Zusammenhang occurs, but not "in this context"
    'x10540',  # temporal while, not however/meanwhile
    'x10561',  # take up time, not make use of
    'x10620',  # sole German source sentence is ungrammatical
    'x10641',  # unharmed, not notwithstanding
    'x10657',  # ungeachtet + noun, not the fixed phrase ungeachtet dessen
    'x10659',  # dative of Zug (train), not the phrase "in the course of"
}


def read_cards(path):
    text = path.read_text(encoding='utf-8')
    return text, [match.groupdict() for match in GEN.CARD_RE.finditer(text)]


def load_wordhoard(path):
    rows = {}
    with io.open(str(path), encoding='utf-8', newline='') as handle:
        for row in csv.DictReader(handle):
            rows.setdefault(row['lemma'].casefold(), []).append(row)
    return rows


def lector_positions(dictionary, lemma):
    rows = dictionary.execute(
        'SELECT DISTINCT pos FROM senses WHERE word = ?',
        (lemma.casefold(),)).fetchall()
    return {LECTOR_TO_WORDHOARD[pos] for (pos,) in rows
            if pos in LECTOR_TO_WORDHOARD}


def positions_for_word(word, wordhoard, dictionary):
    positions = {row['pos'] for row in wordhoard.get(word.casefold(), ())
                 if row['pos'] in WORDHOARD_TO_SPACY}
    positions.update(lector_positions(dictionary, word))
    return positions


def expected_positions(card, focus, wordhoard, dictionary):
    gloss = card['english'].strip().casefold()
    if gloss.startswith(VERB_GLOSS_PREFIXES):
        return {'VERB', 'AUX'}
    positions = positions_for_word(focus, wordhoard, dictionary)
    # Legacy article-less cards intentionally represent non-nouns.  Lector
    # also exposes gerund records for nearly every verb, which must not turn a
    # lowercase verb card into a noun match.
    positions.discard('NOUN')
    if not positions:
        return set(WORDHOARD_TO_SPACY)
    if 'ADJ' in positions and 'ADV' in positions:
        return {'ADJ', 'ADV'}
    return positions


def forms_for(lemma, wordhoard, dictionary):
    forms = {lemma.casefold()}
    for row in wordhoard.get(lemma.casefold(), ()):
        for form, _feature in GEN.split_forms(row.get('forms', '')):
            forms.add(form.casefold())
    rows = dictionary.execute(
        'SELECT inflected_form, type FROM inflections WHERE lemma = ?',
        (lemma.casefold(),)).fetchall()
    ignored_types = {'auxiliary', 'table-tags', 'inflection-template'}
    for form, kind in rows:
        if kind not in ignored_types and GEN.WORD_RE.fullmatch(form):
            forms.add(form.casefold())
    return {form for form in forms if len(form) >= 2}


def phrase_focus(card, phrase_doc, wordhoard, dictionary):
    words = GEN.WORD_RE.findall(card['german'])
    gloss = card['english'].casefold()
    verbish = gloss.startswith(VERB_GLOSS_PREFIXES)
    if verbish:
        for token in reversed(list(phrase_doc)):
            surface_positions = positions_for_word(
                token.text, wordhoard, dictionary)
            positions = positions_for_word(token.lemma_, wordhoard, dictionary)
            positions.update(surface_positions)
            if token.pos_ in {'VERB', 'AUX'} or positions & {'VERB', 'AUX'}:
                # Prefer the written infinitive when it has a lexical verb
                # entry.  The small spaCy model occasionally lemmatises
                # ``vorbereiten`` as the non-word ``vorbereit`` in isolation.
                if surface_positions & {'VERB', 'AUX'}:
                    return token.text.casefold()
                return token.lemma_.casefold()
    candidates = [token for token in phrase_doc
                  if token.pos_ in CONTENT_POS and
                  token.text.casefold() not in IGNORED_REQUIREMENTS]
    if candidates:
        return max(candidates, key=lambda token: len(token.text)).lemma_.casefold()
    return max(words, key=len).casefold()


def build_target(card, nlp, wordhoard, dictionary):
    phrase_doc = nlp(card['german'])
    multiword = len(GEN.WORD_RE.findall(card['german'])) > 1
    focus = (phrase_focus(card, phrase_doc, wordhoard, dictionary)
             if multiword else card['german'].casefold())
    expected = expected_positions(card, focus, wordhoard, dictionary)
    if 'ADJ' in expected:
        # German dictionary adjectives are productively usable adverbially and
        # predicatively; spaCy labels those uninflected uses ADV.  Legacy cards
        # have no separate POS field, so both are valid demonstrations of the
        # same lexical headword.
        expected.add('ADV')
    expected_spacy = set()
    for position in expected:
        expected_spacy.update(WORDHOARD_TO_SPACY.get(position, ()))

    requirements = []
    required_prepositions = set()
    reflexive = False
    if multiword:
        for token in phrase_doc:
            surface = token.text.casefold()
            if surface == 'sich':
                reflexive = True
                continue
            if surface in IGNORED_REQUIREMENTS:
                continue
            if token.pos_ == 'ADP':
                required_prepositions.add(surface)
            elif token.pos_ in CONTENT_POS:
                requirements.append({surface, token.lemma_.casefold()})

    focus_forms = forms_for(focus, wordhoard, dictionary)
    anchor_forms = set(focus_forms)
    # spaCy can analyse a zu-infinitive as the surface rather than its lexical
    # lemma.  Retaining every content token as a possible anchor makes those
    # constructions discoverable; final POS and phrase checks remain strict.
    if multiword:
        for requirement in requirements:
            for value in requirement:
                anchor_forms.update(forms_for(value, wordhoard, dictionary))

    return {
        'card': card,
        'focus': focus,
        'expected': expected,
        'expected_spacy': expected_spacy,
        'focus_forms': focus_forms,
        'forms': anchor_forms,
        'multiword': multiword,
        'requirements': requirements,
        'prepositions': required_prepositions,
        'reflexive': reflexive,
        'options': [],
    }


def gloss_terms(gloss):
    words = {word.casefold() for word in re.findall(r'[A-Za-z]+', gloss)}
    return {word for word in words if len(word) > 2 and word not in GLOSS_STOP}


def english_overlap(gloss, sentence):
    wanted = gloss_terms(gloss)
    have = {word.casefold() for word in re.findall(r'[A-Za-z]+', sentence)}
    overlap = 0
    for word in wanted:
        stem = word[:max(4, len(word) - 3)]
        if any(candidate.startswith(stem) or stem.startswith(candidate[:4])
               for candidate in have if len(candidate) >= 4):
            overlap += 1
    return overlap


def cheap_score(target, german, english, matched_form):
    words = GEN.WORD_RE.findall(german)
    if len(words) < 3 or len(words) > 18:
        return None
    lowered = {word.casefold() for word in words}
    names = {'tom', 'mary', 'maria', 'sami', 'layla', 'boston'}
    if lowered & GEN.BLOCKED or lowered & names:
        return None
    desired = {'A1': 5, 'A2': 7, 'B1': 9, 'B2': 10,
               'C1': 11, 'C2': 12}[target['card']['level']]
    exact = target['card']['german'].casefold()
    literal_bonus = -3 if exact in german.casefold() else 0
    overlap_bonus = -4 * english_overlap(target['card']['english'], english)
    # The German model tags an uninflected predicative/adverbial adjective as
    # ADV.  For an ADJ card, prefer an inflected surface here so the later
    # exact-POS gate sees a genuine attributive adjective instead of filling
    # the small option window with predicative uses it must reject.
    if target['expected'] == {'ADJ'}:
        form_penalty = 4 if matched_form == target['focus'] else 0
    else:
        form_penalty = 0 if matched_form == target['focus'] else 1
    question_penalty = 1 if german.endswith('?') else 0
    return (abs(len(words) - desired) + form_penalty + question_penalty +
            literal_bonus + overlap_bonus, len(german), german)


def add_option(target, option, limit=80):
    options = target['options']
    if any(existing[1] == option[1] for existing in options):
        return
    if len(options) < limit:
        options.append(option)
        options.sort(key=lambda item: item[0])
        return
    if option[0] < options[-1][0]:
        options[-1] = option
        options.sort(key=lambda item: item[0])


def scan_corpus(targets, corpus_path):
    form_index = {}
    for target in targets:
        for form in target['forms']:
            form_index.setdefault(form, []).append(target)
    with io.open(str(corpus_path), encoding='utf-8') as handle:
        for line in handle:
            parts = line.rstrip('\n').split('\t')
            if len(parts) < 3:
                continue
            english, german, attribution = parts[0], parts[1], parts[2]
            if len(german) > 180 or len(english) > 180:
                continue
            seen_targets = set()
            for token in set(GEN.WORD_RE.findall(german.casefold())):
                for target in form_index.get(token, ()):
                    marker = id(target)
                    if marker in seen_targets:
                        continue
                    seen_targets.add(marker)
                    score = cheap_score(target, german, english, token)
                    if score is None:
                        continue
                    add_option(target, (
                        score, german, english, attribution.strip(), token))


def target_matches(target, matched_form, doc):
    if target['multiword']:
        phrase = ' '.join(GEN.WORD_RE.findall(
            target['card']['german'].casefold()))
        sentence = ' '.join(GEN.WORD_RE.findall(doc.text.casefold()))
        if re.search(r'(?<!\w)%s(?!\w)' % re.escape(phrase), sentence):
            # A literal complete lexical chunk is stricter evidence than an
            # inferred head token and avoids model errors on nominalised or
            # fixed prepositional expressions such as ``im Rahmen``.
            return True

    focus_matches = []
    for token in doc:
        if token.text.casefold() not in target['focus_forms']:
            continue
        if target['expected_spacy'] and token.pos_ not in target['expected_spacy']:
            continue
        focus_matches.append(token)
    if not focus_matches:
        if (target['expected'] == {'INTJ'} and
                target['card']['german'].casefold() in {
                    token.text.casefold() for token in doc} and
                doc[0].text.casefold() == target['card']['german'].casefold()):
            # The small model tags sentence-initial greetings inconsistently;
            # exact surface at utterance start is safe for these legacy cards.
            return True
        return False

    if not target['multiword']:
        # As in the 6,000-card generator, every surface form came from the
        # pinned lexical tables; exact surface plus exact POS is sufficient.
        return True

    surfaces = {token.text.casefold() for token in doc}
    lemmas = {token.lemma_.casefold() for token in doc}
    combined = surfaces | lemmas
    for requirement in target['requirements']:
        if not requirement & combined:
            return False
    if target['prepositions'] - combined:
        return False
    if target['reflexive'] and not surfaces & REFLEXIVES:
        return False
    return True


def legacy_validator_matches(card, german_example):
    """Mirror validate_content.py's current headword-in-example check.

    This is diagnostic rather than a linguistic gate: that validator cannot
    recognise flexible multiword chunks (especially reflexive verbs), whereas
    ``target_matches`` checks their full lexical structure.  Reporting the
    mismatch here prevents a sourced repair from creating a surprise in the
    repository's existing validation command.
    """
    def fold(value):
        for umlaut, plain in (('ä', 'a'), ('ö', 'o'), ('ü', 'u'), ('ß', 'ss')):
            value = value.replace(umlaut, plain)
        return value

    stem = fold(card['german'].lower())
    separable = (
        'zusammen', 'zurück', 'wieder', 'unter', 'durch', 'über', 'nach',
        'statt', 'weg', 'vor', 'zu', 'auf', 'aus', 'an', 'ab', 'bei', 'ein',
        'mit', 'los', 'her', 'hin', 'um', 'fest', 'frei', 'teil',
    )
    alternatives = [stem]
    if not card['article']:
        for prefix in separable:
            if stem.startswith(prefix) and len(stem) > len(prefix) + 3:
                alternatives.append(stem[len(prefix):])
                break
    haystack = fold(german_example.lower())
    wanted = []
    for candidate in alternatives:
        for suffix in ('en', 'n', 'e', 'st', 't'):
            if len(candidate) - len(suffix) >= 3 and candidate.endswith(suffix):
                candidate = candidate[:-len(suffix)]
                break
        wanted.append(candidate[:max(3, min(len(candidate), 6))])
    return not wanted or any(value and value in haystack for value in wanted)


def validate_options(targets, nlp):
    unique = sorted({option[1] for target in targets
                     for option in target['options']})
    print('Checking POS/phrase structure in %d candidate sentences' % len(unique))
    docs = {}
    for sentence, doc in zip(
            unique, nlp.pipe(unique, batch_size=512, n_process=1)):
        docs[sentence] = doc
    for target in targets:
        valid = [option for option in target['options']
                 if target_matches(target, option[4], docs[option[1]])]
        valid.sort(key=lambda option: option[0])
        # Retain the full bounded candidate window.  The deterministic pass can
        # then prefer a semantically reviewed or validator-recognisable pair
        # even when a shorter homograph received a better cheap score.
        target['valid'] = valid[:80]


def select_with_ollama(targets, model, batch_size=20):
    """Select only among sourced options; the model cannot author text."""
    try:
        import requests
    except ImportError as exc:
        raise RuntimeError('requests is required for --ollama') from exc

    pending = [target for target in targets if target.get('valid')]
    for start in range(0, len(pending), batch_size):
        batch = pending[start:start + batch_size]
        source = []
        for target in batch:
            source.append({
                'headword': target['card']['german'],
                'gloss': target['card']['english'],
                'expectedPos': sorted(target['expected']),
                'options': [
                    {'german': option[1], 'english': option[2]}
                    for option in target['valid'][:5]
                ],
            })
        prompt = (
            'There are exactly %d input items. For each vocabulary item '
            'choose the zero-based option whose '
            'bilingual sentence demonstrates the given German headword in '
            'the stated English sense. Return -1 only if none is semantically '
            'safe. Never rewrite text. Return exactly compact JSON '
            '{"choices":[...]}, one integer per item, in order. Input: %s'
            % (len(batch), json.dumps(
                source, ensure_ascii=False, separators=(',', ':')))
        )
        payload = {
            'model': model,
            'stream': False,
            'think': False,
            'format': {
                'type': 'object',
                'properties': {
                    'choices': {
                        'type': 'array',
                        'minItems': len(batch),
                        'maxItems': len(batch),
                        'items': {'type': 'integer'},
                    },
                },
                'required': ['choices'],
            },
            'keep_alive': '15m',
            'options': {'temperature': 0, 'num_ctx': 16384,
                        'num_predict': len(batch) * 4 + 20},
            'messages': [
                {'role': 'system', 'content':
                 'You are a meticulous German-English corpus lexicographer. '
                 'Choose only from the supplied source pairs.'},
                {'role': 'user', 'content': prompt},
            ],
        }
        choices = None
        last = ''
        for _attempt in range(3):
            response = requests.post('http://localhost:11434/api/chat',
                                     json=payload, timeout=600)
            response.raise_for_status()
            last = response.json()['message']['content']
            try:
                parsed = json.loads(last)
                candidate = [int(value) for value in parsed['choices']]
                if len(candidate) == len(batch):
                    choices = candidate
                    break
            except (KeyError, TypeError, ValueError, json.JSONDecodeError):
                pass
        if choices is None:
            raise RuntimeError('invalid Ollama selection: %r' % last[:500])
        for target, choice in zip(batch, choices):
            options = target['valid'][:5]
            target['selected'] = options[choice] if 0 <= choice < len(options) else None
        print('Semantic selection: %d/%d' %
              (min(start + len(batch), len(pending)), len(pending)), flush=True)


def select_deterministically(targets):
    for target in targets:
        valid = target.get('valid', ())
        validator_compatible = [
            option for option in valid
            if legacy_validator_matches(target['card'], option[1])
        ]
        # Prefer a pair the repository's current structural validator can
        # recognise.  For flexible lexical chunks there may be no such pair;
        # the strict POS/valency match remains the linguistic source of truth.
        target['selected'] = ((validator_compatible or valid)[0]
                              if valid else None)


def apply_curated_review(targets):
    """Apply the human sense review without ever authoring a new pair."""
    by_id = {target['card']['id']: target for target in targets}
    for card_id in CURATED_UNSAFE_IDS:
        if card_id in by_id:
            by_id[card_id]['selected'] = None
    for card_id, attribution_id in CURATED_ATTRIBUTION_IDS.items():
        target = by_id.get(card_id)
        if target is None:
            raise RuntimeError('curated card is missing: %s' % card_id)
        matches = [option for option in target.get('valid', ())
                   if attribution_id in option[3]]
        if len(matches) != 1:
            raise RuntimeError(
                'expected one curated pair for %s/%s, found %d' %
                (card_id, attribution_id, len(matches)))
        target['selected'] = matches[0]


def dart_string(value):
    return (value.replace('\\', '\\\\').replace("'", "\\'")
            .replace('$', '\\$').replace('\r', ' ').replace('\n', ' '))


def replace_examples(text, replacements):
    def replace(match):
        card = match.groupdict()
        replacement = replacements.get(card['id'])
        if replacement is None:
            return match.group(0)
        old = match.group(0)
        pattern = re.compile(
            r"exampleGerman:\s*'[^']*',\s*"
            r"exampleEnglish:\s*'[^']*'")
        new = ("exampleGerman: '%s', exampleEnglish: '%s'" %
               (dart_string(replacement['german']),
                dart_string(replacement['english'])))
        updated, count = pattern.subn(new, old, count=1)
        if count != 1:
            raise RuntimeError('could not replace examples for %s' % card['id'])
        return updated
    return GEN.CARD_RE.sub(replace, text)


def replace_beteiligen(text, pair):
    pattern = re.compile(
        r"(id:\s*'x10934',\s*article:\s*'',\s*)"
        r"german:\s*'beteiligen',\s*plural:\s*'—',\s*"
        r"english:\s*'[^']*',\s*exampleGerman:\s*'[^']*',\s*"
        r"exampleEnglish:\s*'[^']*'")
    replacement = (
        r"\1german: 'beteiligen', plural: '—', "
        "english: 'to participate in something', "
        "exampleGerman: '%s', exampleEnglish: '%s'" %
        (dart_string(pair['german']), dart_string(pair['english'])))
    updated, count = pattern.subn(replacement, text, count=1)
    if count != 1:
        raise RuntimeError('could not update x10934 beteiligen card')
    return updated


def sourced_beteiligen_pair(corpus_path):
    wanted_attribution_id = '#6910964'
    with io.open(str(corpus_path), encoding='utf-8') as handle:
        for line in handle:
            parts = line.rstrip('\n').split('\t')
            if len(parts) >= 3 and wanted_attribution_id in parts[2]:
                return {'english': GEN.clean_sentence(parts[0], False),
                        'german': GEN.clean_sentence(parts[1], True),
                        'attribution': parts[2].strip(),
                        'matched': 'beteiligen',
                        'expected': 'VERB'}
    raise RuntimeError('pinned beteiligen source pair is missing')


def write_attributions(rows, path=ATTRIBUTIONS):
    header = [
        'card_id', 'german', 'target_gloss', 'status', 'matched_form', 'expected_pos',
        'example_german', 'example_english', 'tatoeba_attribution',
    ]
    with io.open(str(path), 'w', encoding='utf-8', newline='') as handle:
        writer = csv.writer(handle, delimiter='\t', lineterminator='\n')
        writer.writerow(header)
        for row in rows:
            writer.writerow([row.get(column, '') for column in header])


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    parser.add_argument('--ollama', default='', metavar='MODEL',
                        help='select semantic matches with a local model')
    parser.add_argument('--review-tsv', default='', metavar='PATH',
                        help='write the dry-run selection ledger for review')
    args = parser.parse_args()

    cache = Path(tempfile.gettempdir()) / 'deutsch-garden-vocabulary-sources'
    wordhoard_csv, lector_db, tatoeba_tsv = GEN.prepare_sources(cache)
    expansion_text, expansion_cards = read_cards(EXPANSION)
    extra_text, _extra_cards = read_cards(EXTRA)
    placeholders = [card for card in expansion_cards
                    if card['eg'].startswith(PLACEHOLDER_PREFIX)]
    if len(placeholders) != 678:
        raise RuntimeError('expected 678 legacy placeholders, found %d' %
                           len(placeholders))
    x10723 = next(card for card in expansion_cards if card['id'] == 'x10723')
    cards = placeholders + [x10723]

    print('Loading German POS model')
    try:
        import spacy
    except ImportError as exc:
        raise RuntimeError('spacy 3.4 and de_core_news_sm 3.4 are required') from exc
    nlp = spacy.load('de_core_news_sm', disable=['parser', 'ner'])
    dictionary = sqlite3.connect(str(lector_db))
    wordhoard = load_wordhoard(wordhoard_csv)
    targets = [build_target(card, nlp, wordhoard, dictionary)
               for card in cards]
    scan_corpus(targets, tatoeba_tsv)
    validate_options(targets, nlp)
    if args.ollama:
        select_with_ollama(targets, args.ollama)
    else:
        select_deterministically(targets)
    apply_curated_review(targets)

    replacements = {}
    attribution_rows = []
    unsourced = []
    for target in targets:
        card = target['card']
        option = target.get('selected')
        if option is None:
            unsourced.append((card['id'], card['german'], card['english']))
            attribution_rows.append({
                'card_id': card['id'], 'german': card['german'],
                'target_gloss': card['english'], 'status': 'unsourced',
                'expected_pos': ','.join(sorted(target['expected'])),
            })
            continue
        replacements[card['id']] = {
            'german': GEN.clean_sentence(option[1], True),
            'english': GEN.clean_sentence(option[2], False),
        }
        attribution_rows.append({
            'card_id': card['id'], 'german': card['german'],
            'target_gloss': card['english'], 'status': 'sourced',
            'matched_form': option[4],
            'expected_pos': ','.join(sorted(target['expected'])),
            'example_german': GEN.clean_sentence(option[1], True),
            'example_english': GEN.clean_sentence(option[2], False),
            'tatoeba_attribution': option[3],
        })

    beteiligen = sourced_beteiligen_pair(tatoeba_tsv)
    attribution_rows.append({
        'card_id': 'x10934', 'german': 'beteiligen',
        'target_gloss': 'to participate in something',
        'status': 'sourced', 'matched_form': beteiligen['matched'],
        'expected_pos': beteiligen['expected'],
        'example_german': beteiligen['german'],
        'example_english': beteiligen['english'],
        'tatoeba_attribution': beteiligen['attribution'],
    })

    sourced_placeholders = sum(card['id'] in replacements
                               for card in placeholders)
    validator_mismatches = [
        target['card']['id'] for target in targets
        if target['card']['id'] in replacements and not legacy_validator_matches(
            target['card'], replacements[target['card']['id']]['german'])
    ]
    print('Legacy placeholders sourced: %d/678' % sourced_placeholders)
    print('Legacy placeholders unsourced: %d' %
          (678 - sourced_placeholders))
    print('x10723 sourced:', 'x10723' in replacements)
    print('Existing-validator mismatches among sourced cards: %d' %
          len(validator_mismatches))
    if validator_mismatches:
        print('  ' + ', '.join(validator_mismatches))
    if unsourced:
        print('UNSOURCED CARDS')
        by_id = {target['card']['id']: target for target in targets}
        for card_id, german, english in unsourced:
            target = by_id[card_id]
            print('  %s\t%s\t%s\tfocus=%s\tpos=%s\traw=%d\tvalid=%d' % (
                card_id, german, english, target['focus'],
                ','.join(sorted(target['expected'])),
                len(target['options']), len(target.get('valid', ()))))
            if target['options'] and card_id in {
                    'x10001', 'x10074', 'x10161', 'x10174', 'x10275',
                    'x10328', 'x10449', 'x10451', 'x10524', 'x10547',
                    'x10557', 'x10564', 'x10643', 'x10654', 'x10668',
                    'x10673'}:
                print('    first=%s' % target['options'][0][1])

    if args.review_tsv:
        review_path = Path(args.review_tsv)
        write_attributions(attribution_rows, review_path)
        print('Wrote review ledger', review_path)

    if not args.write:
        print('Dry run only; pass --write to update files.')
        dictionary.close()
        return 0

    updated_expansion = replace_examples(expansion_text, replacements)
    updated_extra = replace_beteiligen(extra_text, beteiligen)
    with io.open(str(EXPANSION), 'w', encoding='utf-8', newline='') as handle:
        handle.write(updated_expansion)
    with io.open(str(EXTRA), 'w', encoding='utf-8', newline='') as handle:
        handle.write(updated_extra)
    write_attributions(attribution_rows)
    remaining = updated_expansion.count(PLACEHOLDER_PREFIX)
    print('Wrote', EXPANSION)
    print('Wrote', EXTRA)
    print('Wrote', ATTRIBUTIONS)
    print('Remaining placeholder phrases:', remaining)
    dictionary.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
