/// Interactive, local-only Windows acceptance capture using the app's actual
/// recorder, offline recognizer, bundled voice and acoustic scorer.
/// Does not load AppController, learning preferences, or an online account.
/// See docs/SPEECH_VALIDATION.md. Raw participant audio must never be committed.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:deutsch_garden/acoustic_scorer.dart';
import 'package:deutsch_garden/asr.dart';
import 'package:deutsch_garden/asr_io.dart';
import 'package:deutsch_garden/build_info.dart';
import 'package:deutsch_garden/neural_tts.dart';
import 'package:deutsch_garden/voice_recorder.dart';
import 'package:flutter/material.dart';

import 'evaluate_speech.dart' as measurement;
import 'speech_transcript_form.dart';

class CapturePrompt {
  const CapturePrompt(
    this.id,
    this.target, {
    this.condition = 'quiet',
    this.say,
    this.silence = false,
  });
  final String id, target, condition;
  final String? say;
  final bool silence;
}

const capturePrompts = [
  CapturePrompt('quiet-01', 'Fünf grüne Bücher liegen neben der Tür.'),
  CapturePrompt('quiet-02', 'Die Straße führt über die Brücke zum Bahnhof.'),
  CapturePrompt('quiet-03', 'Morgen möchte ich früher mit dem Zug fahren.'),
  CapturePrompt(
    'quiet-04',
    'Gestern habe ich meiner Nachbarin beim Einkaufen geholfen.',
  ),
  CapturePrompt(
    'quiet-05',
    'Obwohl der Termin verschoben wurde, sind alle Unterlagen fertig.',
  ),
  CapturePrompt(
    'quiet-06',
    'Die Entscheidung hätte gründlicher begründet werden müssen.',
  ),
  CapturePrompt(
    'room-01',
    'Fünf grüne Bücher liegen neben der Tür.',
    condition: 'ordinary room, self-reported',
  ),
  CapturePrompt(
    'room-02',
    'Morgen möchte ich früher mit dem Zug fahren.',
    condition: 'ordinary room, self-reported',
  ),
  CapturePrompt(
    'wrong-sentence',
    'Der Zug kommt um acht Uhr an.',
    say: 'Die Katze schläft auf dem Sofa.',
  ),
  CapturePrompt('silence', 'Der Zug kommt um acht Uhr an.', silence: true),
];

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final resume = args.length == 2 && args.first == '--resume';
  if (args.length > 1 && !resume) {
    throw ArgumentError(
      'Usage: capture_speech [output-folder] or --resume output-folder',
    );
  }
  final output = args.isEmpty
      ? await Directory.systemTemp.createTemp('deutsch-garden-speech-')
      : Directory(args.last).absolute;
  await output.create(recursive: true);
  if (!resume && await File('${output.path}/corpus.json').exists()) {
    throw StateError(
      'This folder already contains a speech corpus. Choose a new folder to preserve the previous session.',
    );
  }
  runApp(
    MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: SpeechCapture(output: output, resume: resume),
    ),
  );
}

class SpeechCapture extends StatefulWidget {
  const SpeechCapture({super.key, required this.output, this.resume = false});
  final Directory output;
  final bool resume;
  @override
  State<SpeechCapture> createState() => _SpeechCaptureState();
}

class _SpeechCaptureState extends State<SpeechCapture> {
  final recorder = VoiceRecorder();
  final player = AudioPlayer();
  final transcript = TextEditingController();
  late final recognizer = SherpaSpeechRecogniser(
    root: Directory('${widget.output.path}/model-cache'),
  );
  final clips = <Map<String, Object?>>[];
  final controls = <Map<String, Object?>>[];
  final sourceSessions = <Map<String, Object?>>[];
  String? recoveryPath;
  Map<String, dynamic>? previousSession;
  bool busy = true, ready = false, recording = false, reviewed = false;
  int index = 0, attempt = 0;
  double level = -120;
  String status = 'Preparing the microphone and offline models…';
  String learnerLevel = 'not reported';
  Map<String, Object?>? pending;
  CapturePrompt get prompt => capturePrompts[index];
  bool get done => index == capturePrompts.length;

  @override
  void initState() {
    super.initState();
    unawaited(prepare());
  }

  Future<void> persist({bool? reportedBusy}) async {
    final document = <String, Object?>{
      'protocol': 'windows-physical-pilot-v1',
      'appVersion': const String.fromEnvironment(
        'DG_VALIDATION_VERSION',
        defaultValue: appVersion,
      ),
      'appCommit': const String.fromEnvironment(
        'DG_VALIDATION_COMMIT',
        defaultValue: 'unrecorded working tree',
      ),
      'captureTool': 'tool/capture_speech.dart',
      'device': 'Windows physical microphone; default audio input',
      'os': Platform.operatingSystemVersion,
      'recognizer':
          'NVIDIA German FastConformer hybrid large PC int8; sherpa-onnx; ${SherpaSpeechRecogniser.modelUrl}',
      'referenceVoice': 'bundled Thorsten (narrator), rate 1.0',
      'transcriptVerification': 'speaker self-review; no independent rater',
      'sourceSessions': sourceSessions,
      'clips': clips,
      'controls': controls,
    };
    await File('${widget.output.path}/corpus.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(document),
      flush: true,
    );
    await File('${widget.output.path}/status.json').writeAsString(
      jsonEncode({
        'processId': pid,
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'ready': ready,
        'busy': reportedBusy ?? busy,
        'recording': recording,
        'completed': done,
        'saved': clips.length + controls.length,
        'total': capturePrompts.length,
        'status': status,
        'output': widget.output.path,
      }),
      flush: true,
    );
    await File('${widget.output.path}/session.json').writeAsString(
      jsonEncode({
        'pending': pending,
        'draftTranscript': transcript.text,
        'learnerLevel': learnerLevel,
      }),
      flush: true,
    );
  }

  Future<void> restore() async {
    final previous =
        jsonDecode(
              await File('${widget.output.path}/corpus.json').readAsString(),
            )
            as Map<String, dynamic>;
    if (previous['protocol'] != 'windows-physical-pilot-v1') {
      throw StateError(
        'This folder uses a different collection protocol. It was left unchanged.',
      );
    }
    previousSession = previous;
    clips.addAll(
      (previous['clips'] as List).map(
        (r) => Map<String, Object?>.from(r as Map),
      ),
    );
    controls.addAll(
      (previous['controls'] as List? ?? []).map(
        (r) => Map<String, Object?>.from(r as Map),
      ),
    );
    final savedIds = [...clips, ...controls].map((r) => r['id']).toSet();
    index = clips.length + controls.length;
    if (index > capturePrompts.length ||
        savedIds.length != index ||
        !capturePrompts.take(index).every((p) => savedIds.contains(p.id))) {
      throw StateError(
        'Saved prompts are inconsistent; the corpus was left unchanged.',
      );
    }
    sourceSessions.addAll(
      (previous['sourceSessions'] as List? ?? []).map(
        (r) => Map<String, Object?>.from(r as Map),
      ),
    );
    sourceSessions.add({
      for (final key in ['appVersion', 'appCommit']) key: previous[key],
    });
    final stateFile = File('${widget.output.path}/session.json');
    if (await stateFile.exists()) {
      final state =
          jsonDecode(await stateFile.readAsString()) as Map<String, dynamic>;
      learnerLevel = state['learnerLevel'] as String? ?? 'not reported';
      if (!done &&
          state['pending'] is Map &&
          state['pending']['id'] == prompt.id) {
        pending = Map<String, Object?>.from(state['pending'] as Map);
        transcript.text = state['draftTranscript'] as String? ?? '';
      }
    }
    // Recover an unsaved v1 take as unverified audio, never as a transcript.
    final recordings = Directory('${widget.output.path}/recordings');
    if (await recordings.exists()) {
      final directories = await recordings
          .list()
          .where((p) => p is Directory)
          .toList();
      for (final dir in directories) {
        final n =
            int.tryParse(
              dir.path.split(Platform.pathSeparator).last.split('-').last,
            ) ??
            0;
        attempt = math.max(attempt, n);
      }
      if (!done && pending == null) {
        final takes =
            directories
                .where(
                  (d) => d.path
                      .split(Platform.pathSeparator)
                      .last
                      .startsWith('${prompt.id}-'),
                )
                .toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        if (takes.isNotEmpty) {
          final file = File('${takes.last.path}/learner-utterance.wav');
          if (await file.exists()) recoveryPath = file.path;
        }
      }
    }
  }

  Future<void> prepare() async {
    bool mayPersist = false;
    try {
      if (widget.resume) await restore();
      mayPersist = true;
      await persist();
      if (!await recorder.initialise()) {
        throw StateError(recorder.unavailableReason);
      }
      if (!await NeuralTts.instance.initialise()) {
        throw StateError('The bundled German reference voice did not load.');
      }
      if (!(await recognizer.status()).isReady) {
        await for (final progress in recognizer.install()) {
          if (!mounted) return;
          setState(
            () => status = progress.progress == null
                ? 'Preparing offline German recognizer: ${progress.state.name}'
                : 'Downloading offline German model: ${(progress.progress! * 100).round()}%',
          );
          if (progress.state == AsrModelState.failed) {
            throw StateError(progress.message);
          }
        }
      }
      if (!(await recognizer.status()).isReady) {
        throw StateError('The offline recognizer is not ready.');
      }
      ready = true;
      if (recoveryPath != null) {
        await analyseRecording(
          recoveryPath!,
          captureCommit: previousSession?['appCommit'] as String?,
          captureVersion: previousSession?['appVersion'] as String?,
        );
      }
      status = done
          ? 'Finished. All ten verified checks are saved.'
          : pending != null
          ? 'Your previous take is ready for review. Listen, verify what you said, and save.'
          : 'Ready. Record only when you are ready to read the displayed prompt.';
    } catch (error) {
      status = 'Preparation failed: $error';
    } finally {
      if (mounted) setState(() => busy = false);
      if (mayPersist) await persist();
    }
  }

  Future<void> playFile(String path) async {
    if (busy || recording) return;
    setState(() => busy = true);
    try {
      final finished = player.onPlayerComplete.first;
      await player.play(DeviceFileSource(path));
      await finished.timeout(const Duration(seconds: 30));
    } catch (error) {
      status = 'Playback failed: $error';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> hearReference() async {
    if (busy || recording || done) return;
    setState(() => busy = true);
    String? path;
    try {
      path = await NeuralTts.instance.synthesiseToFile(prompt.target);
    } finally {
      if (mounted) setState(() => busy = false);
    }
    if (path != null) await playFile(path);
  }

  Future<void> start() async {
    if (busy || recording || done || pending != null) return;
    setState(() => busy = true);
    try {
      await player.stop();
      final dir = '${widget.output.path}/recordings/${prompt.id}-${++attempt}';
      final started = await recorder.start(
        dir,
        onLevel: (db) {
          if (mounted) setState(() => level = db);
        },
        onSpeechEnd: (_) {
          unawaited(stop());
        },
        maximumDuration: const Duration(seconds: 20),
        noSpeechTimeout: const Duration(seconds: 6),
      );
      if (!started) {
        throw StateError('${recorder.unavailableReason} ${recorder.lastError}');
      }
      recording = true;
      status = prompt.silence
          ? 'Recording silence control. Stay quiet for six seconds.'
          : 'Recording. Read the sentence; then pause or press Stop.';
    } catch (error) {
      status = 'Recording failed: $error';
    } finally {
      if (mounted) setState(() => busy = false);
      await persist();
    }
  }

  Future<void> analyseRecording(
    String path, {
    String? captureCommit,
    String? captureVersion,
  }) async {
    final wave = measurement.readValidationWave(await File(path).readAsBytes());
    final watch = Stopwatch()..start();
    final recognition = await recognizer.transcribeFile(path);
    watch.stop();
    final reference = await NeuralTts.instance.synthesiseToFile(prompt.target);
    if (reference == null) {
      throw StateError('No reference audio was produced.');
    }
    final referenceCopy = '${File(path).parent.path}/reference.wav';
    if (!await File(referenceCopy).exists()) {
      await File(reference).copy(referenceCopy);
    }
    final acoustic = await const AcousticPronunciationScorer().score(
      targetGerman: prompt.target,
      recordingPath: path,
    );
    double squares = 0, peak = 0;
    int clipped = 0;
    for (final sample in wave.samples) {
      squares += sample * sample;
      peak = math.max(peak, sample.abs());
      if (sample.abs() >= 0.98) clipped++;
    }
    final rms = math.sqrt(squares / wave.samples.length);
    pending = {
      'id': prompt.id,
      'captureAppCommit':
          captureCommit ??
          const String.fromEnvironment(
            'DG_VALIDATION_COMMIT',
            defaultValue: 'unrecorded working tree',
          ),
      'captureAppVersion':
          captureVersion ??
          const String.fromEnvironment(
            'DG_VALIDATION_VERSION',
            defaultValue: appVersion,
          ),
      'capturedAt': (await File(path).lastModified()).toUtc().toIso8601String(),
      'speakerId': 'speaker-01',
      'level': learnerLevel,
      'condition': prompt.condition,
      'targetText': prompt.target,
      'recognizerTranscript': recognition.text,
      'recognizerOk': recognition.ok,
      'recognizerError': recognition.error,
      'recognizerMilliseconds': watch.elapsedMilliseconds,
      'learnerWav': path
          .substring(widget.output.path.length + 1)
          .replaceAll('\\', '/'),
      'referenceWav': referenceCopy
          .substring(widget.output.path.length + 1)
          .replaceAll('\\', '/'),
      'sampleRate': wave.sampleRate,
      'seconds': wave.samples.length / wave.sampleRate,
      'rmsDbfs': rms == 0 ? -120 : 20 * math.log(rms) / math.ln10,
      'peak': peak,
      'clippedFraction': clipped / wave.samples.length,
      'acousticScore': acoustic == null || acoustic.isEmpty
          ? null
          : acoustic.score,
      'acousticDistance': acoustic == null || acoustic.isEmpty
          ? null
          : acoustic.distance,
      'humanScore': null,
      'control': prompt.silence
          ? 'silence'
          : prompt.say == null
          ? null
          : 'wrong sentence',
    };
    reviewed = false;
    transcript.clear();
    status =
        'Listen to your recording, verify what you actually said, then save. The recognizer output stays hidden until your transcript is saved.';
  }

  Future<void> stop() async {
    if (busy || !recording) return;
    setState(() {
      busy = true;
      recording = false;
      status = 'Transcribing and measuring locally…';
    });
    try {
      final path = await recorder.stop();
      if (path == null) {
        throw StateError('No usable recording was returned. Try again.');
      }
      await analyseRecording(path);
    } catch (error) {
      status = 'Capture failed: $error';
    } finally {
      if (mounted) setState(() => busy = false);
      await persist();
    }
  }

  Future<void> save() async {
    if (busy || pending == null || !reviewed) return;
    if (!prompt.silence &&
        measurement.transcriptWords(transcript.text).isEmpty) {
      setState(
        () => status =
            'Enter what you actually said, or use the exact-reading shortcut after listening.',
      );
      return;
    }
    setState(() => busy = true);
    final clip = {
      ...pending!,
      'referenceTranscript': transcript.text.trim(),
      'transcriptVerifiedBySpeaker': true,
    };
    final collection = prompt.silence ? controls : clips;
    collection.add(
      prompt.silence ? {...clip, 'silenceConfirmedBySpeaker': true} : clip,
    );
    final recognized = pending!['recognizerTranscript'];
    index++;
    status = done
        ? 'Finished. All recordings and verified transcripts are saved locally. You can close this window.'
        : 'Saved. Recognizer returned: "$recognized". Continue with the next prompt.';
    try {
      await persist(reportedBusy: false);
      pending = null;
      reviewed = false;
      transcript.clear();
    } catch (error) {
      index--;
      collection.removeLast();
      status = 'Saving failed; this attempt is still available. $error';
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  void dispose() {
    unawaited(recorder.dispose());
    unawaited(recognizer.dispose());
    unawaited(player.dispose());
    transcript.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('DeutschGarden — private Windows speech check'),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (!ready)
              const Text(
                'This test does not open your learning profile. Audio and transcripts stay in the private folder shown below. Only press Record when ready. Use a headset if possible.',
              ),
            if (!ready) const SizedBox(height: 8),
            if (!ready)
              const Text(
                'An offline German model (~105 MB, NVIDIA/k2-fsa, CC-BY-4.0) is prepared once. Recording and recognition then stay local.',
              ),
            const SizedBox(height: 12),
            if (!ready || done)
              SelectableText(
                widget.output.path,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 20),
            Text(status, style: Theme.of(context).textTheme.titleMedium),
            if (busy) const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              '${clips.length + controls.length} / ${capturePrompts.length} saved',
            ),
            if (!done && pending == null) ...[
              DropdownButtonFormField<String>(
                initialValue: learnerLevel,
                decoration: const InputDecoration(
                  labelText: 'Self-reported German level (optional)',
                ),
                items: [
                  for (final l in [
                    'not reported',
                    'A1',
                    'A2',
                    'B1',
                    'B2',
                    'C1',
                    'C2',
                  ])
                    DropdownMenuItem(value: l, child: Text(l)),
                ],
                onChanged: busy || recording || pending != null
                    ? null
                    : (v) => setState(() => learnerLevel = v!),
              ),
              const SizedBox(height: 16),
              Text(
                prompt.silence
                    ? 'Silence control: do not speak.'
                    : 'Read this aloud:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SelectableText(
                prompt.silence
                    ? 'Stay quiet until recording stops (six seconds).'
                    : prompt.say ?? prompt.target,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (prompt.say != null)
                Text(
                  'Negative control. The requested app target is different: ${prompt.target}',
                ),
              if (prompt.condition.startsWith('ordinary'))
                const Text(
                  'Use your ordinary room condition. Do not invent or add noise; the condition is self-reported.',
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: busy || recording || !ready
                        ? null
                        : hearReference,
                    child: const Text('Hear app target'),
                  ),
                  FilledButton(
                    onPressed: busy || !ready || pending != null
                        ? null
                        : recording
                        ? stop
                        : start,
                    child: Text(recording ? 'Stop recording' : 'Record'),
                  ),
                ],
              ),
              if (recording) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: ((level + 60) / 60).clamp(0, 1)),
                Text('Input level: ${level.toStringAsFixed(1)} dBFS'),
              ],
            ],
            if (pending != null) ...[
              const Divider(height: 32),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => playFile(
                            '${widget.output.path}/${pending!['learnerWav']}',
                          ),
                    child: const Text('Listen to my recording'),
                  ),
                ],
              ),
              SpeechTranscriptForm(
                readingText: prompt.say ?? prompt.target,
                silence: prompt.silence,
                transcript: transcript,
                busy: busy,
                reviewed: reviewed,
                onReviewed: (value) => setState(() => reviewed = value),
                onSave: save,
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            pending = null;
                            reviewed = false;
                            transcript.clear();
                            status =
                                'Ready to retry. Previous raw take is retained privately.';
                          }),
                    child: const Text('Retry this prompt'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'This is a one-speaker device check, not pronunciation calibration. No independent human score is fabricated and no pass threshold is changed.',
            ),
          ],
        ),
      ),
    ),
  );
}
