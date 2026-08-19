import 'package:deutsch_garden/platform_support.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('every target platform maps to a named AppPlatform', () {
    const Map<TargetPlatform, AppPlatform> expected =
        <TargetPlatform, AppPlatform>{
      TargetPlatform.android: AppPlatform.android,
      TargetPlatform.iOS: AppPlatform.ios,
      TargetPlatform.macOS: AppPlatform.macos,
      TargetPlatform.windows: AppPlatform.windows,
      TargetPlatform.linux: AppPlatform.linux,
    };
    expected.forEach((target, app) {
      debugDefaultTargetPlatformOverride = target;
      expect(PlatformSupport.current, app);
      expect(PlatformSupport.displayName, isNotEmpty);
    });
  });

  test('desktop is exactly macOS, Windows and Linux', () {
    const Map<TargetPlatform, bool> expected = <TargetPlatform, bool>{
      TargetPlatform.macOS: true,
      TargetPlatform.windows: true,
      TargetPlatform.linux: true,
      TargetPlatform.android: false,
      TargetPlatform.iOS: false,
    };
    expected.forEach((target, isDesktop) {
      debugDefaultTargetPlatformOverride = target;
      expect(PlatformSupport.isDesktop, isDesktop, reason: '$target');
    });
  });

  test('Linux is the one platform with neither speech plugin', () {
    // flutter_tts and speech_to_text both declare android/ios/macos/windows/web
    // and no linux. If either ever ships a Linux implementation this test
    // should be revisited along with the fallback in system_tts_io.dart.
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(PlatformSupport.hasPluginTts, isFalse);
    expect(PlatformSupport.hasSpeechRecognition, isFalse);
    expect(PlatformSupport.usesCommandLineTts, isTrue);

    for (final TargetPlatform target in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      debugDefaultTargetPlatformOverride = target;
      expect(PlatformSupport.hasPluginTts, isTrue, reason: '$target');
      expect(PlatformSupport.hasSpeechRecognition, isTrue, reason: '$target');
      expect(PlatformSupport.usesCommandLineTts, isFalse, reason: '$target');
    }
  });

  test('capability notes never leave the learner without an explanation', () {
    for (final TargetPlatform target in TargetPlatform.values) {
      debugDefaultTargetPlatformOverride = target;
      expect(PlatformSupport.ttsNote.trim(), isNotEmpty, reason: '$target');
      expect(PlatformSupport.speechRecognitionNote.trim(), isNotEmpty,
          reason: '$target');
    }
  });

  test('the Linux note names the packages that fix silent audio', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(PlatformSupport.ttsNote, contains('espeak-ng'));
    expect(PlatformSupport.speechRecognitionNote, contains('typed'));
  });
}
