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
