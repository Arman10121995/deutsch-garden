# ADR 001: universal vocabulary visuals and integrated retrieval practice

- **Status:** Accepted
- **Date:** 2026-08-29
- **Release:** 3.24.0

## Context

DeutschGarden has 10,000 vocabulary cards and a 72-unit guided course. Two
problems remained after the content expansion:

1. 480 concrete nouns could use an honest semantic drawing, while thousands of
   verbs, modifiers, function words and abstract nouns could not. Rendering no
   visual made the experience inconsistent; manufacturing literal pictures for
   abstract language would be misleading and would create a large asset-review
   burden.
2. Matching, sentence building and dictation existed as good practice engines,
   but lived primarily in Explore. A learner following Learn could complete a
   unit without being sent through those retrieval modes.

The app must remain offline, MIT licensed, compatible with saved activity ids
and buildable from one Flutter codebase.

## Options considered

### One semantic image for every card

Rejected. Many lexical items have no unambiguous visual referent. Ten thousand
individually sourced or generated pictures would also require semantic,
licensing, bias and accessibility review. Asset size is acceptable; false or
unreviewable teaching cues are not.

### Images only where authored, blank state elsewhere

Rejected. It preserves semantic honesty but makes most of the advanced deck
look unfinished and does not help learners distinguish grammatical role.

### Semantic drawings plus structural vector fallback

Accepted. Concrete words retain authored SVGs. Every other card receives a
deterministic vector made from information the app can state reliably:
category, explicit word class and noun gender. Text labels accompany colour and
shape so the design does not depend on colour perception.

### Duplicate the practice engines inside the course

Rejected. A second implementation would drift in scoring, accessibility and
saved progress.

### Route unit-specific steps into the existing engines

Accepted. Each unit gets one finite practice step that reuses the existing
matching, sentence-builder or dictation screen with a unique activity id.

## Decision

- `vocabulary_metadata.dart` is the one classification layer for word class and
  productive noun-ending clues.
- `vocab_icon.dart` renders authored SVGs when present and otherwise renders the
  structural vector. `revealGrammar` controls whether an exercise may expose
  article/gender information.
- The guide screens explain classification and ending clues, including
  exceptions. Rules are phrased probabilistically, never as guarantees.
- `course.dart` deterministically rotates one integrated retrieval step per
  unit. The step id includes the unit id and therefore cannot collide with
  another unit or with an open-ended Explore session.
- Completion remains stored through the existing `ActivityProgress` model; no
  profile migration or parallel course-state database is introduced.

## Consequences

### Positive

- Every card has a coherent visual and explicit grammatical identity without
  pretending abstract language has a literal picture.
- The article trainer can withhold answer-bearing cues before recall.
- The guided path now alternates explanation, input, production and retrieval
  without asking learners to leave Learn and choose a game.
- Existing scoring, accessibility and persistence code remains shared.

### Trade-offs

- Structural visuals aid recognition and organisation; they do not depict word
  meaning. The UI and documentation must keep that distinction clear.
- Word-class inference over a legacy deck is deterministic but not equivalent
  to a manually tagged linguistic corpus. Tests require every card to receive
  a specific label, and future manual corrections should be recorded as
  explicit overrides.
- Only one retrieval mode is required per unit to preserve the 7–9 activity
  core. The full practice labs remain optional in Explore.

## Verification

Tests require complete visual/class coverage, no gender leakage before an
article answer, unique unit practice ids, exactly one integrated retrieval step
per unit, and unchanged course gating. The content validator checks every SVG's
id, dimensions, size and absence of embedded/network resources.
