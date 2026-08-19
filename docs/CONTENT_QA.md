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
