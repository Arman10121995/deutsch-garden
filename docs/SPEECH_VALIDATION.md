# Measuring speech feedback with learner recordings

The acoustic score is still calibrated against synthetic speech. The optional
recognizer has not been evaluated on learner German. This document and
`tool/evaluate_speech.dart` make that evaluation repeatable; they do not supply
the missing recordings or establish a pass mark.

## Collect the evidence

Use short sentences from the speaking lab, including umlauts, long vowels,
compounds, endings and different word orders. Include learners at different
levels and with different first languages, plus native-speaker controls. Keep
both quiet and realistic noisy microphone conditions, and record the device,
reference voice, app commit and recognizer/model version with the corpus.
Use speaker aliases, keep consented recordings outside the repository, and
never commit participant audio or identifying information.

Save each learner recording and the app's synthesized target as PCM16 WAV,
mono or stereo, at the original sample rate. The tool accepts 8–96 kHz and
clips up to 30 seconds. Export the recognizer's raw output, including an empty
string when recognition fails; do not silently drop failures.

A human must transcribe **what was actually said**, including word omissions,
insertions and wrong words. This is `referenceTranscript`. `targetText` is the
sentence requested by the app and spoken in `referenceWav`. They can differ.
Comparing ASR with the target would count learner mistakes as recognition
errors and obscure the very false rejections this evaluation needs to find.

For acoustic validation, have independent German-speaking raters listen
without seeing the app's score. Define and record the rating rubric before
scoring. Retain separate ratings and disagreements in the private corpus;
`humanScore` may contain their agreed/mean 0–100 rating or be omitted. A
missing human rating stays missing in the report. Synthetic tones used in
unit tests are pipeline checks, never learner evidence.

## Run the local measurement

Copy `tool/speech_corpus.example.json` outside the checkout and fill in real
recording paths and transcripts. WAV paths are relative to the manifest and
use forward slashes. Run from the app checkout with its pinned Dart SDK:

```powershell
& 'C:\flutter\bin\dart.bat' run tool/evaluate_speech.dart C:/speech-study/corpus.json > C:/speech-study/report.json
if ($LASTEXITCODE -ne 0) { throw 'Speech evaluation failed' }
```

The tool uses the app's actual resampling, silence trimming, level
normalization, MFCC extractor, DTW distance and score mapping. It reports:

- word error rate, substitutions, deletions and insertions against the human
  transcript; casing and punctuation are normalized, umlauts and ß are kept;
- exact transcripts, raw acoustic distance, score and tempo ratio per clip;
- corpus WER weighted by reference-word count, rather than averaging the
  percentages of short and long sentences;
- separate summaries by speaker, level and recording condition;
- human-rated sample count and descriptive mean absolute score error when
  ratings exist. WER can exceed 100% when many words are inserted.

The runner does not execute a recognizer, synthesize a reference, download a
model, upload audio or change the app's scoring thresholds. It measures
previously collected outputs. Run the same recordings with each candidate
recognizer/voice and keep each manifest and report tied to its app commit.

## Before changing scoring or making an accuracy claim

Inspect errors per speaker and condition, especially clearly intelligible
speech receiving a low score, silence, and the wrong sentence receiving a
high score. Report the corpus composition, failure count and human-rater
agreement alongside any aggregate. Use speakers held out from calibration
for acceptance; utterances from one speaker are not independent people.
Choose a threshold from those recordings and its false-rejection behavior,
not from synthetic signals or one attractive corpus average.

Until that evidence exists, the transcript remains a second opinion and is
not blended into the activity score. Human validation remains outstanding.
