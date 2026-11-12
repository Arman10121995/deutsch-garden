import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/app.dart';
import 'package:deutsch_garden/backup.dart';
import 'package:deutsch_garden/ui_feedback.dart';
import 'package:deutsch_garden/ui_sound_player.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class FakeSoundOutput implements UiSoundOutput {
  final heard = <UiFeedbackEvent>[];
  Completer<void>? preparation;
  Completer<void>? stopping;
  bool fails = false;
  int stops = 0, disposals = 0;
  @override
  Future<void> play(UiFeedbackEvent event, bool Function() mayPlay) async {
    if (fails) throw StateError('audio unavailable');
    await preparation?.future;
    if (mayPlay()) heard.add(event);
  }

  @override
  Future<void> stop() async {
    stops++;
    await stopping?.future;
  }

  @override
  Future<void> dispose() async {
    disposals++;
  }
}

class FeedbackTrackingController extends AppController {
  final requested = <UiFeedbackEvent>[];
  @override
  void requestFeedback(UiFeedbackEvent event) {
    requested.add(event);
    super.requestFeedback(event);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => AppController.debounceWrites = true);

  test(
    'click bursts do not cut off a completion cue or queue old effects',
    () async {
      final output = FakeSoundOutput();
      var now = DateTime(2026, 11, 11);
      final player = UiSoundPlayer(output: output, now: () => now);
      addTearDown(player.dispose);
      await player.play(UiFeedbackEvent.click);
      await player.play(UiFeedbackEvent.click);
      await player.play(UiFeedbackEvent.complete);
      await player.play(UiFeedbackEvent.click);
      await player.play(UiFeedbackEvent.failure);
      expect(output.heard, [UiFeedbackEvent.click, UiFeedbackEvent.complete]);
      now = now.add(const Duration(seconds: 1));
      await player.play(UiFeedbackEvent.success);
      expect(output.heard.last, UiFeedbackEvent.success);
    },
  );

  test('turning sound off cancels a request still preparing', () async {
    final output = FakeSoundOutput()..preparation = Completer<void>();
    final player = UiSoundPlayer(output: output);
    final pending = player.play(UiFeedbackEvent.success);
    player.enabled = false;
    output.preparation!.complete();
    await pending;
    await player.play(UiFeedbackEvent.complete);
    expect(output.heard, isEmpty);
    await player.dispose();
    await player.play(UiFeedbackEvent.success);
    expect(output.disposals, 1);
  });

  test(
    'slow preparation cannot let an old cue overwrite a newer answer',
    () async {
      final output = FakeSoundOutput()..preparation = Completer<void>();
      final player = UiSoundPlayer(output: output);
      addTearDown(player.dispose);
      final first = player.play(UiFeedbackEvent.click);
      await Future<void>.delayed(Duration.zero);
      final second = player.play(UiFeedbackEvent.success);
      final third = player.play(UiFeedbackEvent.failure);
      output.preparation!.complete();
      await Future.wait([first, second, third]);
      expect(output.heard, [UiFeedbackEvent.failure]);
    },
  );

  test(
    'microphone startup drains effects, suppresses late playback, and keeps concurrent captures quiet',
    () async {
      final output = FakeSoundOutput()..preparation = Completer<void>();
      final player = UiSoundPlayer(output: output);
      addTearDown(player.dispose);
      final pending = player.play(UiFeedbackEvent.complete);
      final first = Object(), second = Object();
      addTearDown(() {
        UiFeedbackCaptureGate.end(first);
        UiFeedbackCaptureGate.end(second);
      });
      output.stopping = Completer<void>();
      bool quiet = false;
      final hold = UiFeedbackCaptureGate.begin(first).then((_) => quiet = true);
      await Future<void>.delayed(Duration.zero);
      expect(UiFeedbackCaptureGate.active.value, isTrue);
      expect(quiet, isFalse);
      output.stopping!.complete();
      await hold;
      output.preparation!.complete();
      await pending;
      await UiFeedbackCaptureGate.begin(second);
      UiFeedbackCaptureGate.end(first);
      await player.play(UiFeedbackEvent.success);
      expect(output.heard, isEmpty);
      UiFeedbackCaptureGate.end(second);
      await player.play(UiFeedbackEvent.success);
      expect(output.heard, [UiFeedbackEvent.success]);
    },
  );

  test('an unavailable sound device is harmless', () async {
    final output = FakeSoundOutput()..fails = true;
    final player = UiSoundPlayer(output: output);
    await expectLater(player.play(UiFeedbackEvent.complete), completes);
    await player.dispose();
  });

  test(
    'effect preferences persist and merge locally, independently of speech',
    () async {
      final c = AppController();
      await c.load();
      addTearDown(c.dispose);
      c.ttsEnabled = true;
      final events = <UiFeedbackEvent>[];
      c.uiFeedback = events.add;
      await c.setUiSoundsEnabled(false);
      await c.answer(vocabulary.first, correct: false);
      expect(events, isEmpty);
      expect(c.totalWrong, 1);
      final restored = AppController();
      await restored.load();
      addTearDown(restored.dispose);
      expect(restored.uiSoundsEnabled, isFalse);
      expect(restored.ttsEnabled, isTrue);
      final merged = ProgressBackup.merge(restored.toBackupJson(), {
        'uiSoundsEnabled': true,
      });
      expect(merged['uiSoundsEnabled'], isFalse);
      await c.setUiSoundsEnabled(true);
      expect(events, [UiFeedbackEvent.click]);
      await c.recordActivity('test-feedback', score: 100);
      expect(events.last, UiFeedbackEvent.complete);
      await c.recordActivity('test-feedback', score: 20);
      expect(events.last, UiFeedbackEvent.failure);
    },
  );

  test('cosmetic callback failure cannot lose a graded result', () async {
    final c = AppController();
    await c.load();
    addTearDown(c.dispose);
    c.uiFeedback = (_) => throw StateError('optional effect failed');
    await c.recordActivity('saved-despite-audio', score: 80);
    expect(c.progressForActivity('saved-despite-audio').completed, isTrue);
    final restored = AppController();
    await restored.load();
    addTearDown(restored.dispose);
    expect(restored.progressForActivity('saved-despite-audio').bestScore, 80);
  });

  test('every bundled effect is a short, non-silent, quiet PCM waveform', () {
    for (final event in UiFeedbackEvent.values) {
      final bytes = File('assets/sounds/${event.name}.wav').readAsBytesSync();
      final data = ByteData.sublistView(bytes);
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
      expect(data.getUint16(22, Endian.little), 1);
      expect(data.getUint32(24, Endian.little), 22050);
      expect(data.getUint16(34, Endian.little), 16);
      expect(data.getUint32(40, Endian.little), bytes.length - 44);
      final seconds = (bytes.length - 44) / 44100;
      expect(seconds, inInclusiveRange(.025, .55));
      final samples = [
        for (int i = 44; i < bytes.length; i += 2)
          data.getInt16(i, Endian.little).abs(),
      ];
      expect(
        samples.reduce((a, b) => a > b ? a : b),
        inInclusiveRange(1000, 6000),
      );
    }
  });

  testWidgets(
    'initial startup is silent while route navigation requests click feedback',
    (tester) async {
      final c = FeedbackTrackingController();
      await c.load();
      addTearDown(c.dispose);
      c.onboardingDone = true;
      c.uiSoundsEnabled =
          false; // Test routing without a physical audio device.
      await tester.pumpWidget(DeutschGardenApp(controller: c));
      await tester.pumpAndSettle();
      expect(c.requested, isEmpty);
      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Route')),
        ),
      );
      await tester.pumpAndSettle();
      expect(c.requested, [UiFeedbackEvent.click]);
      nav.pop();
      await tester.pumpAndSettle();
      expect(c.requested, [UiFeedbackEvent.click, UiFeedbackEvent.click]);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
