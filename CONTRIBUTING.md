# Contributing Content

For every new vocabulary or lesson item:

1. assign a unique ID
2. assign exactly one CEFR teaching level
3. keep examples natural and learner-appropriate
4. avoid copying proprietary exam/course content
5. provide valid answer explanations for objective items
6. run `python3 tool/validate_content.py`
7. run `flutter analyze` and `flutter test`

CEFR assignment should be treated as pedagogical classification, not an official certification unless backed by an appropriate language-specific reference source.
