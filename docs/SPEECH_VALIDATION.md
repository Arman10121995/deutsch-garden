# Measuring speech feedback with learner recordings

The physical Windows microphone/reference/playback path was checked on
2026-10-19 using ten speaker-verified attempts. The check invalidated the
synthetic acoustic grade mapping: the production lab is now ungraded. One
speaker on one PC does not establish learner accuracy or a pronunciation pass
mark. Detailed measurements and raw recordings remain outside Git.

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

## Native Windows capture

The developer-only `tool/capture_speech.dart` uses the actual `VoiceRecorder`,
bundled Thorsten voice, local playback, optional offline recognizer and acoustic
pipeline. It does not load the learner profile. Build it with the pinned Flutter
SDK, recording the exact source commit (and source hashes for a dirty checkout):

```powershell
flutter build windows --release --target tool/capture_speech.dart --dart-define=DG_VALIDATION_COMMIT=<source-commit>
# Run the built executable with a NEW private output folder, outside Git:
& './build/windows/x64/runner/Release/DeutschGarden.exe' C:/speech-study/windows-pilot
# Resume the SAME folder after closing the capture window:
& './build/windows/x64/runner/Release/DeutschGarden.exe' --resume C:/speech-study/windows-pilot
```

The optional model is an explicit local one-time download. Six quiet prompts,
two ordinary-room repeats, a different-sentence control and a silence control
exercise different failure modes. Room conditions and CEFR level are
self-reported. Ask the speaker to confirm hearing both the reference voice and
their own playback; a successful playback API call is insufficient.

After playback, type what was actually said or explicitly choose the exact-read
shortcut **only if it matches the recording**, then confirm listening and save.
Empty/punctuation-only transcripts cannot enable Save. Editing the transcript
requires fresh confirmation. Recognizer output stays hidden until verification.
The silence control requires confirmation without inventing spoken words.
Closing the window preserves completed attempts and the pending take; resuming
never silently marks an unfinished recording verified. Check `status.json` for
`saved: 10` and `completed: true`. Keep failed/orphaned takes for the audit.

The ten-attempt Windows check confirmed microphone capture, bundled-reference
playback, recorded playback, model inference, verified saving and completion.
It also exposed near-silence amplification and an invalid synthetic score
mapping. The input floor now rejects signal below -80 dBFS RMS before
normalisation/offline recognition; it is a numerical guard, not a general VAD.
The lab keeps timing and recognised-word feedback without acoustic percentage
grades or progression penalties. Raw mapping constants remain unchanged for
reproducibility. Original reports must be retained alongside post-fix replay
results, and saved recognizer output must not be rewritten as if recollected.

This is one-PC functional acceptance. The speaker's verified transcript is not
an independent pronunciation rating. Population calibration, native-speaker
controls, blinded ratings and other physical devices remain unvalidated.

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
  ratings exist;
- recognizer failures, missing status and empty transcripts, plus capture
  version/commit/time and separate silence/wrong-sentence controls. Silence has
  no reference words and is kept outside WER. WER can exceed 100% when many
  words are inserted.

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

Until that evidence exists, the lab remains ungraded. The acoustic percentage
is not shown to learners and neither automatic signal writes a graded review
event. Practice time is preserved. Representative human validation remains
outstanding even though the Windows functional check is complete.
