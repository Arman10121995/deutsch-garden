import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/asr.dart';
import 'package:deutsch_garden/asr_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// A recogniser that answers however the test needs, without a model or a
/// network.
class FakeRecogniser implements SpeechRecogniser {
  FakeRecogniser({
    this.state = AsrModelState.absent,
    this.transcript = 'ich heiße Anna',
    this.installFails = false,
  });

  AsrModelState state;
  String transcript;
  bool installFails;
  int transcribeCalls = 0;
  bool removed = false;

  @override
  bool get isSupported => state != AsrModelState.unsupported;

  @override
  int get approximateDownloadBytes => 105 * 1024 * 1024;

  @override
  String get attribution => 'NVIDIA … CC-BY-4.0 … learner speech will be worse';

  @override
  Future<AsrModelStatus> status() async => AsrModelStatus(state: state);

  @override
  Stream<AsrModelStatus> install() async* {
    yield const AsrModelStatus(
      state: AsrModelState.downloading,
      receivedBytes: 5,
      totalBytes: 10,
    );
    if (installFails) {
      yield const AsrModelStatus(
        state: AsrModelState.failed,
        message: 'The model could not be installed: no route to host',
      );
      return;
    }
    state = AsrModelState.ready;
    yield const AsrModelStatus(state: AsrModelState.ready);
  }

  @override
  Future<void> remove() async {
    removed = true;
    state = AsrModelState.absent;
  }

  @override
  Future<AsrResult> transcribe(List<double> samples, int sampleRate) async =>
      AsrResult(text: transcript, ok: true);

  @override
  Future<AsrResult> transcribeFile(String path) async {
    transcribeCalls += 1;
    return AsrResult(text: transcript, ok: true);
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // testWidgets rejects a pending Timer, and it checks before tearDown runs.
    // None of these tests are about when the write happens.
    AppController.debounceWrites = false;
  });

  tearDown(() => AppController.debounceWrites = true);

  AppController controllerWith(FakeRecogniser asr) {
    final AppController controller = AppController()..recogniser = asr;
    return controller;
  }

  group('the speaking lab without a model', () {
    test('is the default, and asking for a transcript yields nothing',
        () async {
      final FakeRecogniser asr = FakeRecogniser();
      final AppController controller = controllerWith(asr);
      await controller.refreshAsrStatus();

      expect(controller.asrUsable, isFalse);
      expect(await controller.transcribeRecording('/tmp/clip.wav'), isEmpty);
      expect(asr.transcribeCalls, 0,
          reason: 'nothing should reach a recogniser that has no model');
    });

    test('an unsupported platform is not offered the download', () async {
      final AppController controller =
          controllerWith(FakeRecogniser(state: AsrModelState.unsupported));
      await controller.refreshAsrStatus();
      expect(controller.asrStatus.state, AsrModelState.unsupported);
      expect(controller.asrUsable, isFalse);
    });
  });

  group('with a model installed', () {
    test('a recording comes back as words', () async {
      final AppController controller =
          controllerWith(FakeRecogniser(state: AsrModelState.ready));
      await controller.refreshAsrStatus();
      expect(controller.asrUsable, isTrue);
      expect(await controller.transcribeRecording('/tmp/clip.wav'),
          'ich heiße Anna');
    });

    test('turning the transcript off stops it without deleting the model',
        () async {
      // A learner whose accent the model reads badly should be able to stop
      // reading its opinion without paying for the download twice.
      final FakeRecogniser asr = FakeRecogniser(state: AsrModelState.ready);
      final AppController controller = controllerWith(asr);
      await controller.refreshAsrStatus();

      await controller.setAsrFeedbackEnabled(false);
      expect(await controller.transcribeRecording('/tmp/clip.wav'), isEmpty);
      expect(asr.transcribeCalls, 0);
      expect(asr.removed, isFalse);
      expect(controller.asrStatus.isReady, isTrue);
    });

    test('a failed transcription is empty rather than thrown', () async {
      final AppController controller = controllerWith(
        _FailingRecogniser()..state = AsrModelState.ready,
      );
      await controller.refreshAsrStatus();
      expect(await controller.transcribeRecording('/tmp/clip.wav'), isEmpty);
    });

    test('removing it goes back to absent', () async {
      final FakeRecogniser asr = FakeRecogniser(state: AsrModelState.ready);
      final AppController controller = controllerWith(asr);
      await controller.refreshAsrStatus();
      await controller.removeAsrModel();
      expect(asr.removed, isTrue);
      expect(controller.asrStatus.state, AsrModelState.absent);
      expect(controller.asrUsable, isFalse);
    });
  });

  group('the setting survives a restart', () {
    test('off stays off', () async {
      final AppController first =
          controllerWith(FakeRecogniser(state: AsrModelState.ready));
      await first.load();
      await first.setAsrFeedbackEnabled(false);
      await first.flushSave();

      final AppController second =
          controllerWith(FakeRecogniser(state: AsrModelState.ready));
      await second.load();
      expect(second.asrFeedbackEnabled, isFalse);
    });

    test('a profile written before the setting existed defaults to on',
        () async {
      final AppController controller =
          controllerWith(FakeRecogniser(state: AsrModelState.ready));
      await controller.load();
      expect(controller.asrFeedbackEnabled, isTrue);
    });
  });

  group('the settings card', () {
    Future<void> pumpCard(WidgetTester tester, AppController controller) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ListView(
            children: <Widget>[AsrModelCard(controller: controller)],
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('states the cost, the licence and the caveat before the button',
        (WidgetTester tester) async {
      // All three are what the learner is agreeing to. A download button that
      // does not say "105 MB" is not consent.
      final AppController controller = controllerWith(FakeRecogniser());
      await pumpCard(tester, controller);

      expect(find.textContaining('105 MB'), findsOneWidget);
      expect(find.textContaining('CC-BY-4.0'), findsOneWidget);
      expect(find.textContaining('learner speech will be worse'),
          findsOneWidget);
      expect(find.textContaining('only thing in the whole app that uses the '
          'internet'), findsOneWidget);
      expect(find.text('Download the speech model'), findsOneWidget);
    });

    testWidgets('an unsupported platform is shown no card at all',
        (WidgetTester tester) async {
      final AppController controller =
          controllerWith(FakeRecogniser(state: AsrModelState.unsupported));
      await pumpCard(tester, controller);
      expect(find.byType(Card), findsNothing);
      expect(find.text('Download the speech model'), findsNothing);
    });

    testWidgets('downloading swaps the button for the transcript switch',
        (WidgetTester tester) async {
      final AppController controller = controllerWith(FakeRecogniser());
      await pumpCard(tester, controller);

      await tester.tap(find.text('Download the speech model'));
      await tester.pumpAndSettle();

      expect(controller.asrStatus.isReady, isTrue);
      expect(find.text('Download the speech model'), findsNothing);
      expect(find.text('Show the transcript'), findsOneWidget);
      expect(find.text('Remove the model'), findsOneWidget);
    });

    testWidgets('a failed download says so and leaves the button',
        (WidgetTester tester) async {
      final AppController controller =
          controllerWith(FakeRecogniser(installFails: true));
      await pumpCard(tester, controller);

      await tester.tap(find.text('Download the speech model'));
      await tester.pumpAndSettle();

      expect(find.textContaining('no route to host'), findsOneWidget);
      expect(find.text('Download the speech model'), findsOneWidget,
          reason: 'a learner whose download failed must be able to retry');
    });

    testWidgets('removing asks first, and says what is kept',
        (WidgetTester tester) async {
      final FakeRecogniser asr = FakeRecogniser(state: AsrModelState.ready);
      final AppController controller = controllerWith(asr);
      await pumpCard(tester, controller);

      await tester.tap(find.text('Remove the model'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('keeps scoring your pronunciation either way'),
        findsOneWidget,
      );

      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
      expect(asr.removed, isFalse);
    });
  });
}

class _FailingRecogniser extends FakeRecogniser {
  @override
  Future<AsrResult> transcribeFile(String path) async =>
      const AsrResult.failed('the recording could not be read');
}
