import 'package:deutsch_garden/speech_service.dart';
import 'package:deutsch_garden/speech_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  test('all recognizer end states are terminal', () {
    expect(isTerminalSpeechStatus('done'), isTrue);
    expect(isTerminalSpeechStatus('notListening'), isTrue);
    expect(isTerminalSpeechStatus('doneNoResult'), isTrue);
    expect(isTerminalSpeechStatus(' listening '), isFalse);
  });

  test('prefers advertised de-DE over another German locale', () {
    final selection = selectGermanLocale([
      LocaleName('de-AT', 'Deutsch (Österreich)'),
      LocaleName('de-DE', 'Deutsch (Deutschland)'),
    ]);
    expect(selection.localeId, 'de-DE');
    expect(selection.status, GermanLocaleStatus.advertised);
  });

  test('falls back explicitly when locale enumeration is unavailable', () {
    final selection = selectGermanLocale(const []);
    expect(selection.localeId, 'de-DE');
    expect(selection.status, GermanLocaleStatus.enumerationUnavailable);
  });

  test('reports explicit absence instead of selecting the system locale', () {
    final selection = selectGermanLocale([
      LocaleName('en-US', 'English (United States)'),
    ]);
    expect(selection.localeId, isNull);
    expect(selection.status, GermanLocaleStatus.explicitlyAbsent);
  });

  test(
    'bare German and regional tags are accepted, unrelated prefixes are not',
    () {
      expect(selectGermanLocale([LocaleName('de', 'Deutsch')]).localeId, 'de');
      expect(
        selectGermanLocale([LocaleName('de_CH', 'Deutsch')]).localeId,
        'de_CH',
      );
      expect(
        selectGermanLocale([LocaleName('del', 'Delaware')]).localeId,
        isNull,
      );
    },
  );

  test(
    'dispatches the resolved German locale to the speech platform',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final MethodChannel channel = const MethodChannel(
        'plugin.csdcorp.com/speech_to_text',
      );
      Map<Object?, Object?>? dispatched;
      List<String> advertised = <String>[
        'en-US:English',
        'de-AT:Deutsch (Österreich)',
        'de-DE:Deutsch (Deutschland)',
      ];
      bool enumerationFails = false;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
        switch (call.method) {
          case 'initialize':
            return true;
          case 'locales':
            if (enumerationFails) throw PlatformException(code: 'unavailable');
            return advertised;
          case 'listen':
            dispatched = Map<Object?, Object?>.from(call.arguments as Map);
            return true;
          case 'cancel':
            return null;
          default:
            return null;
        }
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      final service = SpeechService();
      expect(
        await service.listen(
          onTranscript: (_, _) {},
          listenFor: const Duration(seconds: 12),
          pauseFor: const Duration(seconds: 2),
          onDevice: false,
        ),
        isTrue,
      );
      expect(dispatched?['localeId'], 'de-DE');
      expect(dispatched?['listenFor'], 12000);
      expect(dispatched?['pauseFor'], 2000);
      expect(dispatched?['onDevice'], isFalse);
      await service.cancel();

      for (final bool fails in <bool>[false, true]) {
        advertised = <String>[];
        enumerationFails = fails;
        dispatched = null;
        final fallback = SpeechService();
        expect(await fallback.listen(onTranscript: (_, _) {}), isTrue);
        expect(dispatched?['localeId'], 'de-DE');
        expect(dispatched?['onDevice'], isTrue);
        await fallback.cancel();
      }

      advertised = <String>['en-US:English'];
      enumerationFails = false;
      dispatched = null;
      final missing = SpeechService();
      expect(await missing.listen(onTranscript: (_, _) {}), isFalse);
      expect(dispatched, isNull);
      expect(missing.availability, SpeechAvailability.germanUnavailable);
      expect(missing.unavailableReason, contains('German'));

      // A return from system settings must allow a newly installed pack.
      advertised = <String>['de-DE:Deutsch'];
      expect(await missing.listen(onTranscript: (_, _) {}), isTrue);
      expect(dispatched?['localeId'], 'de-DE');
      await missing.cancel();
    },
  );
}
