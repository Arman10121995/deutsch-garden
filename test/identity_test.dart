import 'dart:convert';
import 'dart:typed_data';

import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String kStateKey = 'deutsch_garden_state_v4';
const String kAvatarKey = 'deutsch_garden_avatar_v1';

Uint8List pngOf(int width, int height) {
  final img.Image image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(120, 90, 200));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppController> boot() async {
    final AppController c = AppController();
    addTearDown(c.dispose);
    await c.load();
    return c;
  }

  group('preparing an avatar', () {
    test('shrinks a large picture to the stored edge', () {
      final AvatarResult result = prepareAvatar(pngOf(1600, 1200));
      expect(result.ok, isTrue);
      final img.Image out = img.decodePng(result.bytes!)!;
      expect(out.width, avatarMaxEdge);
      expect(out.height, avatarMaxEdge);
    });

    test('squares a portrait from the centre rather than the top', () {
      // Cropping from the top takes the top of someone's head off.
      final AvatarResult result = prepareAvatar(pngOf(400, 1000));
      final img.Image out = img.decodePng(result.bytes!)!;
      expect(out.width, out.height);
    });

    test('leaves a small picture alone rather than upscaling it', () {
      final AvatarResult result = prepareAvatar(pngOf(64, 64));
      final img.Image out = img.decodePng(result.bytes!)!;
      expect(out.width, 64);
    });

    test('explains itself rather than throwing on a file that is not an image',
        () {
      final AvatarResult result =
          prepareAvatar(Uint8List.fromList(utf8.encode('this is a text file')));
      expect(result.ok, isFalse);
      expect(result.error, contains('not an image'));
    });

    test('refuses an empty file', () {
      expect(prepareAvatar(Uint8List(0)).ok, isFalse);
    });
  });

  group('the email field', () {
    test('accepts an ordinary address and an empty one', () {
      expect(looksLikeEmail('someone@example.com'), isTrue);
      expect(looksLikeEmail(''), isTrue, reason: 'the field is optional');
      expect(looksLikeEmail('   '), isTrue);
    });

    test('catches the typo worth catching', () {
      expect(looksLikeEmail('someone-at-example.com'), isFalse);
      expect(looksLikeEmail('someone@example'), isFalse);
    });

    test('does not reject valid addresses a strict pattern would', () {
      // Nothing is ever sent to it, so a false rejection is the only failure
      // that costs the learner anything.
      expect(looksLikeEmail('first.last+tag@sub.example.co.uk'), isTrue);
      expect(looksLikeEmail("o'brien@example.ie"), isTrue);
    });
  });

  group('through the controller', () {
    test('name and email round-trip', () async {
      final AppController c = await boot();
      await c.setIdentity(name: '  Arman  ', email: ' a@b.co ');
      expect(c.learnerName, 'Arman', reason: 'trimmed');
      expect(c.learnerEmail, 'a@b.co');
      await c.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();
      expect(second.learnerName, 'Arman');
      expect(second.learnerEmail, 'a@b.co');
    });

    test('the avatar is stored outside the profile blob', () async {
      final AppController c = await boot();
      await c.setAvatar(prepareAvatar(pngOf(300, 300)).bytes);
      await c.flushSave();

      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      final Map<String, dynamic> profile =
          jsonDecode((await prefs.getString(kStateKey))!)
              as Map<String, dynamic>;
      expect(profile.containsKey('avatar'), isFalse,
          reason: 'a picture carried through every re-encode of the profile '
              'would undo much of what debouncing the writes bought');
      expect(await prefs.getString(kAvatarKey), isNotNull);
    });

    test('the avatar survives a restart and can be removed', () async {
      final AppController first = await boot();
      await first.setAvatar(prepareAvatar(pngOf(300, 300)).bytes);
      await first.flushSave();

      final AppController second = AppController();
      addTearDown(second.dispose);
      await second.load();
      expect(second.avatar, isNotNull);

      await second.setAvatar(null);
      final AppController third = AppController();
      addTearDown(third.dispose);
      await third.load();
      expect(third.avatar, isNull);
    });

    test('a corrupt stored avatar costs the picture, not the profile',
        () async {
      final SharedPreferencesAsync prefs = SharedPreferencesAsync();
      await prefs.setString(kAvatarKey, 'this is not base64 !!!');
      final AppController c = await boot();
      expect(c.avatar, isNull);
      expect(c.ready, isTrue, reason: 'the profile still loaded');
    });

    test('identity is empty by default, and that is a normal state', () async {
      final AppController c = await boot();
      expect(c.learnerName, isEmpty);
      expect(c.learnerEmail, isEmpty);
      expect(c.avatar, isNull);
    });
  });
}
