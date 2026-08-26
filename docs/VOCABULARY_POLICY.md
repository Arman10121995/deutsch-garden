# Vocabulary Policy

## No universal official CEFR word counts

CEFR describes communicative proficiency. It does not define a universal table such as “A1 = X words, C2 = Y words”. Language-specific Reference Level Descriptions can identify forms, words and grammar associated with levels, and exam providers may publish their own lower-level word lists.

For that reason DeutschGarden does not label any arbitrary number as an “official CEFR vocabulary requirement”.

## Current bundled inventory

| Level | Bundled cards |
|---|---:|
| A1 | 650 |
| A2 | 860 |
| B1 | 1,452 |
| B2 | 1,667 |
| C1 | 2,424 |
| C2 | 2,947 |
| **Total** | **10,000** |

The counts are level-specific training cards, not cumulative vocabulary-size claims.

## Internal cumulative breadth planning targets

The curriculum metadata uses the following **pedagogical planning targets**, explicitly non-official:

| Reached level | Internal cumulative lexical breadth target |
|---|---:|
| A1 | 650 |
| A2 | 1,400 |
| B1 | 2,600 |
| B2 | 4,200 |
| C1 | 6,800 |
| C2 | 10,000 |

These figures are used as curriculum-design goals, not pass/fail certification thresholds. The bundled inventory now reaches the 10,000-card planning target, but that does not turn the level labels into an official CEFR measurement.

## How the app avoids padding the number

Mass-assigning dictionary entries to CEFR levels by frequency alone creates
false precision. Every shipped card must include a distinct lemma or phrase, a
usable German example, an English translation and structurally valid metadata.
The validator rejects duplicates, placeholder examples and malformed forms.

Level assignment still depends on meaning, register, collocation, grammatical
behaviour and communicative context. A conservative lower-level rescue records
429 explicit human judgement calls in `tool/relevel_a1_b1.py`; it is not a
claim that all 10,000 cards have been psychometrically calibrated.

## Lower-level benchmarking

Goethe-Institut publishes vocabulary/word-list resources for A1, A2 and B1. They are useful benchmarks for lower-level exam preparation. DeutschGarden does not copy those lists wholesale; its bundled content is independently authored.
