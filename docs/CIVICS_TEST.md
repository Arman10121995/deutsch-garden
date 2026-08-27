# Leben in Deutschland and citizenship-test preparation

DeutschGarden contains a complete, offline preparation centre for the German
**Leben in Deutschland (LiD)** and **Einbürgerungstest** question catalogue.
It is a study aid, not an official test centre and not a certificate issuer.

## What is bundled

- 300 general questions
- 10 questions for each of the 16 Bundesländer (160 state questions in the
  complete app catalogue)
- 100 question images
- immediate-feedback practice for the 310 questions relevant to the selected
  Bundesland
- persistent correct-question progress and mistake review
- deterministic 33-question mock generation: 30 general plus 3 state questions
- a 60-minute countdown, answer navigation, unanswered-question handling and a
  complete missed-answer review

The bundled catalogue is **Stand 07.05.2025**. The exact version and source
URLs live in `assets/civics/questions.json`; image hashes and every answer index
are checked by `tool/validate_content.py`.

## Why there are two pass marks

Both outcomes use the same 33-question format, but the legal thresholds are
not the same:

| Outcome | Correct answers required |
| --- | ---: |
| LiD orientation-course test outcome | 15 of 33 |
| Knowledge required for naturalisation | 17 of 33 |

The result screen always shows both bands. A score of 15 or 16 can therefore
show a LiD pass while correctly showing that the citizenship-knowledge
threshold has not been reached.

Official references:

- [Einbürgerungstestverordnung](https://www.gesetze-im-internet.de/einbtestv/BJNR164900008.html)
  — 33 questions, four choices, 60 minutes, 30 general plus 3 state questions,
  and the 17-question citizenship threshold.
- [Anlage 1 to the Einbürgerungstestverordnung](https://www.gesetze-im-internet.de/einbtestv/anlage_1.html)
  — the official question catalogue.
- [Integrationskurstestverordnung § 10](https://www.gesetze-im-internet.de/inttestv/__10.html)
  — the 15-question LiD threshold and the 17-question citizenship-knowledge
  outcome.
- [BAMF information page](https://www.bamf.de/DE/Themen/Integration/ZugewanderteTeilnehmende/Einbuergerung/einbuergerung-node.html)
  — official learner information and access to the test centre.

## Offline and licensing design

No catalogue screen performs a network request. Questions, answers and images
are Flutter assets and work in aeroplane mode. The app records only local
progress in the same exported profile as the rest of DeutschGarden.

The questions are official German material published as Anlage 1 to a federal
regulation. German copyright law § 5 excludes laws and regulations from
copyright protection. The image extraction comes from the MIT-licensed
`vlad-com/leben_in_de` project (Copyright 2026 Vlad); its full notice is bundled
at `assets/civics/NOTICE.md`. The validated text extraction is independently
checked against `YehorAltshuler/bamf-lid-dataset`. DeutschGarden does not bundle
third-party translations or explanations.

## Updating the catalogue

The checked-in assets are generated rather than edited by hand. Both
extraction URLs are pinned to full Git commit hashes, so rerunning an old
release rebuilds the same catalogue rather than following a mutable `main`
branch:

```powershell
python tool/import_civics_catalog.py
python tool/validate_content.py --write
C:\flutter\bin\flutter.bat test test\civics_test.dart
```

The importer refuses to replace the assets unless:

1. the two independent extractions agree on all 460 answer keys;
2. the distribution is exactly 300 general and 10 questions for each state;
3. every named image is present and decodable; and
4. the advertised catalogue date is still 07.05.2025.

If BAMF publishes a new catalogue date, the importer fails deliberately. A
maintainer must compare the changed official source, update the expected date,
review changed answers and then cut a new release. This prevents a quiet
upstream edit from changing a legal-study answer bank during an unrelated
build.

## Assessment limits

- The mock faithfully reproduces selection, timing and scoring mechanics, but
  it is not administered by BAMF or an authorised test centre.
- Passing a DeutschGarden mock has no legal effect.
- Official exemptions, registration, fees, identity checks and certificate
  procedures are outside the app; learners should use current BAMF or local
  authority guidance for those matters.
