# Content QA

The project includes both Flutter tests and a Python source-level validator.

## Required invariants

- vocabulary IDs are unique
- all vocabulary levels are A1–C2
- noun articles, when present, are der/die/das
- every CEFR level has at least 120 bundled vocabulary cards in v3
- every CEFR level has at least 16 grammar lessons
- every CEFR level has 6 listening, 6 reading, 6 writing and 3 speaking lessons
- every CEFR band has exactly 6 placement items covering all four tested domains
- every CEFR level has exactly 2 exam mini mocks
- choice-question correct indices are within option bounds
- the civics catalogue has 300 general questions and 10 for every Bundesland
- all civics answer indices, image paths and SHA-256 hashes are valid
- Gartenradio resolves to 120 runtime episodes with six checkpoint blocks each

Run:

```bash
python3 tool/validate_content.py
```

Then, on a Flutter-capable machine:

```bash
flutter analyze
flutter test
```

## 3.1 additions

Automated gates now cover the new content as well:

| Check | Where |
| --- | --- |
| Role-play, prompt, story, chapter and sentence ID uniqueness | `tool/validate_content.py` |
| Per-level minimums (2 role-plays, 2 prompts, 1 story, 5 curated sentences) | `tool/validate_content.py` |
| Every chapter has a parent story | `tool/validate_content.py` |
| Delimiter balance after stripping strings and comments | `tool/validate_content.py` |
| **Every model answer passes its own dialogue step** | `test/conversation_test.dart` |
| Every step defines enough keywords to satisfy its own `requiredHits` | `test/conversation_test.dart` |
| Every story question has a valid `correctIndex` and an explanation | `test/content_test.dart` |
| Every practice sentence round-trips through its word-bank tokens | `test/content_test.dart` |
| Daily quests are deterministic per day and never repeat within a day | `test/content_test.dart` |
| The completionist achievement target tracks the real chapter count | `test/content_test.dart` |

The model-answer check is the most valuable of these. Authored keyword lists
drift away from authored model answers silently; running every model answer
through the real evaluator caught three steps where the app would have rejected
its own reference answer.

## 3.11 addition: activity id namespaces

Every lesson, story chapter, role-play and radio episode records itself against
its own id, and all of those records live in one map in the profile. Two pieces
of content sharing an id therefore share a completion flag, a best score and a
review schedule.

That was not hypothetical. Gartenradio shipped with ids like `gr-a1-04` — the
same namespace the grammar lessons use — and **21 of the 53 episodes collided
with a real grammar lesson** for three releases. Nothing looked broken: both
screens worked, both recorded a score, and the score went to the same key.
Passing a grammar lesson silently marked a radio episode complete.

Prefixes are now reserved per content type and enforced in both directions:

| Check | Where |
| --- | --- |
| No id is claimed by two content types | `tool/validate_content.py` |
| No file mints ids in a prefix that is not its own | `tool/validate_content.py` |
| Episode ids are disjoint from grammar ids, at runtime | `test/radio_screens_test.dart` |
| Old radio records migrate where unambiguous, and are left alone where not | `test/radio_screens_test.dart` |

| Prefix | Content |
| --- | --- |
| `gr-` | grammar lessons |
| `li-`, `lx-` | listening lessons |
| `re-`, `rx-` | reading lessons |
| `wr-`, `wx-`, `ws-` | writing lessons and reader retellings |
| `sp-` | speaking lessons |
| `rd-` | Gartenradio episodes |
| `cv-` | role-plays |
| `ms-` | mini-story drills |
| `ft-` | free-talk prompts |
| `ps-` | curated practice sentences |

The gate was verified by putting the bug back: restoring one episode to
`gr-a1-04` fails the validator with the file, the id and the owning namespace
named. A gate that has never been seen to fail is not known to work.

## Civics catalogue gate

`tool/import_civics_catalog.py` refuses an upstream import unless two
independent catalogue extractions agree on every answer key and the inventory
is exactly 460 questions. The normal content validator then rechecks the
checked-in result without using the network:

| Check | Where |
| --- | --- |
| 300 general + 160 state questions | `tool/validate_content.py` |
| all 16 Bundesländer, exactly 10 questions each | `tool/validate_content.py` |
| four distinct options and one answer index in range | Python + Flutter tests |
| unique question ids and exact scope/state pairing | Python + Flutter tests |
| 100 declared images, no extras or omissions | Python + Flutter tests |
| every image SHA-256 matches the imported manifest | `tool/validate_content.py` |
| mock selection is 30 general + 3 selected-state questions | `test/civics_test.dart` |
| LiD 15/33 and citizenship 17/33 remain distinct | `test/civics_test.dart` |
| progress, mistakes and last result survive profile round-trip | `test/civics_test.dart` |

The importer was observed rejecting a malformed upstream extraction of
question 171 before the validated source was made canonical. That failure is
why the two-source design is kept rather than trusting one scrape.
