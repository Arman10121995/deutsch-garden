#!/usr/bin/env python3
from pathlib import Path
import json, re
ROOT=Path(__file__).resolve().parents[1]
text=(ROOT/'lib/vocabulary.dart').read_text()+(ROOT/'lib/vocabulary_expansion.dart').read_text()
levels={lv:len(re.findall(r"level:\s*'"+lv+r"'",text)) for lv in ['A1','A2','B1','B2','C1','C2']}
report={
  'release':'3.0.0',
  'generated':'2026-08-19',
  'vocabulary_by_level':levels,
  'vocabulary_total':sum(levels.values()),
  'grammar_lessons':96,
  'listening_lessons':36,
  'reading_lessons':36,
  'writing_lessons':36,
  'speaking_lessons':18,
  'placement_items':36,
  'exam_mini_mocks':12,
  'note':'Lexical breadth targets are pedagogical planning targets, not official CEFR word-count thresholds.'
}
(ROOT/'CONTENT_MANIFEST.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2,ensure_ascii=False))
