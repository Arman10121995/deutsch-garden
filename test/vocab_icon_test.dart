import 'dart:io';

import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/vocab_icon.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

GermanWord wordWithId(String id) =>
    vocabulary.firstWhere((GermanWord w) => w.id == id);

void main() {
  group('the icon index', () {
    testWidgets('loads the real binary asset manifest used by Flutter builds',
        (WidgetTester tester) async {
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);

      expect(hasVocabIcon(wordWithId('001')), isTrue);
    });

    testWidgets('finds every drawing that ships, not just the ones whose id '
        'happens to be numeric', (WidgetTester tester) async {
      // Asserting one known id proved too weak: the ids are a mix of `001`
      // and `x10743`, and a digits-only pattern in the loader left 368 of the
      // 478 drawings undiscovered while a single-id assertion stayed green.
      // Every file on disk has to come back, or the count says how many did.
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);

      final Directory dir = Directory('assets/vocab');
      if (!dir.existsSync()) return;
      final List<String> shipped = dir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.svg'))
          .map((File f) => f.uri.pathSegments.last.replaceAll('.svg', ''))
          .toList();

      final Map<String, GermanWord> byId = <String, GermanWord>{
        for (final GermanWord w in vocabulary) w.id: w,
      };
      final List<String> invisible = <String>[
        for (final String id in shipped)
          if (byId[id] != null && !hasVocabIcon(byId[id]!)) id,
      ];

      expect(invisible, isEmpty,
          reason: '${invisible.length} of ${shipped.length} shipped drawings '
              'are on disk but invisible to the app, starting with '
              '${invisible.take(5).toList()}');
    });

    test('an unknown card has no icon rather than a broken one', () {
      debugSetVocabIcons(<String>{'001'});
      expect(hasVocabIcon(wordWithId('001')), isTrue);
      expect(hasVocabIcon(wordWithId('002')), isFalse);
    });
  });

  group('VocabIcon', () {
    testWidgets('draws nothing at all when the word has no icon',
        (WidgetTester tester) async {
      // Deliberately nothing, not a grey placeholder: most of the deck is
      // abstract and will never have a drawing, and a column of empty squares
      // reads worse than a column of plain words.
      debugSetVocabIcons(const <String>{});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: VocabIcon(word: wordWithId('001'))),
      ));
      expect(find.byType(SvgPicture), findsNothing);
      final Size size = tester.getSize(find.byType(VocabIcon));
      expect(size, Size.zero);
    });

    testWidgets('renders the drawing when there is one',
        (WidgetTester tester) async {
      debugSetVocabIcons(<String>{'001'});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: VocabIcon(word: wordWithId('001'), size: 40)),
      ));
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });

  group('VocabVisual', () {
    testWidgets('gives an unillustrated word a structural vector visual',
        (WidgetTester tester) async {
      debugSetVocabIcons(const <String>{});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: VocabVisual(word: wordWithId('001'), size: 48)),
      ));
      expect(tester.getSize(find.byType(VocabVisual)), const Size(48, 48));
      expect(
        find.descendant(
          of: find.byType(VocabVisual),
          matching: find.byType(Icon),
        ),
        findsOneWidget,
      );
      expect(find.text('der'), findsOneWidget);
    });

    testWidgets('can hide a noun gender while the article is being tested',
        (WidgetTester tester) async {
      debugSetVocabIcons(const <String>{});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VocabVisual(
            word: wordWithId('001'),
            size: 48,
            revealGrammar: false,
          ),
        ),
      ));
      expect(find.text('der'), findsNothing);
    });
  });

  group('the line icons', () {
    testWidgets('a verb with no drawing still gets a pictogram',
        (WidgetTester tester) async {
      debugResetVocabIcons();
      await loadVocabIconIndex(rootBundle);

      // schlafen. Not a thing, so there is no drawing of it; a bed pictogram
      // is the honest form.
      final GermanWord verb = wordWithId('x10027');
      expect(hasVocabIcon(verb), isFalse);
      expect(hasVocabLineIcon(verb), isTrue);
      expect(hasAnyVocabImage(verb), isTrue);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: VocabIcon(word: verb, size: 40)),
      ));
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('a drawing wins over a pictogram when a word has both',
        (WidgetTester tester) async {
      debugSetVocabIcons(<String>{'001'}, lineIds: <String>{'001'});
      expect(hasVocabIcon(wordWithId('001')), isTrue);
      expect(hasVocabLineIcon(wordWithId('001')), isTrue);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: VocabIcon(word: wordWithId('001'), size: 40)),
      ));
      // One image, not two stacked.
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    test('every shipped line icon keeps its attribution', () {
      final Directory dir = Directory('assets/vocab_line');
      if (!dir.existsSync()) return;
      final List<File> files = dir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.svg'))
          .toList();
      expect(files, isNotEmpty);
      for (final File file in files) {
        final String svg = file.readAsStringSync();
        expect(svg, contains('MIT'),
            reason: '${file.path} is third-party and must say so');
        expect(svg, contains('viewBox="0 0 64 64"'));
        expect(svg.contains('<image'), isFalse);
      }
    });

    test('the licence text ships beside them', () {
      final File licence = File('assets/vocab_line/LICENSE-tabler.txt');
      if (!Directory('assets/vocab_line').existsSync()) return;
      expect(licence.existsSync(), isTrue);
      expect(licence.readAsStringSync(), contains('MIT License'));
    });
  });

  group('the shipped icons', () {
    test('every file matches a real card and shares the 64x64 grid', () {
      final Directory dir = Directory('assets/vocab');
      if (!dir.existsSync()) return;

      final Set<String> ids = <String>{for (final GermanWord w in vocabulary) w.id};
      final List<File> files = dir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.svg'))
          .toList();

      expect(files, isNotEmpty, reason: 'the directory exists but is empty');

      for (final File file in files) {
        final String id =
            file.uri.pathSegments.last.replaceAll('.svg', '');
        expect(ids, contains(id),
            reason: '$id.svg matches no vocabulary card');

        final String svg = file.readAsStringSync();
        expect(svg, contains('viewBox="0 0 64 64"'),
            reason: '$id.svg is off the shared grid');
        // The provenance guarantee: original drawing, nothing fetched.
        expect(svg.contains('<image'), isFalse,
            reason: '$id.svg embeds a raster someone else made');
        expect(svg.replaceAll('http://www.w3.org/2000/svg', ''),
            isNot(contains('http')),
            reason: '$id.svg reaches out to the network');
      }
    });

    test('icons are drawn only for words that can be drawn', () {
      final Directory dir = Directory('assets/vocab');
      if (!dir.existsSync()) return;

      // Concrete A1/A2 nouns are the target. An icon on a C2 abstract noun
      // would mean someone drew a picture of Verantwortung, which is a claim
      // worth catching.
      final Map<String, GermanWord> byId = <String, GermanWord>{
        for (final GermanWord w in vocabulary) w.id: w,
      };
      for (final FileSystemEntity f in dir.listSync()) {
        if (!f.path.endsWith('.svg')) continue;
        final String id = f.uri.pathSegments.last.replaceAll('.svg', '');
        final GermanWord? word = byId[id];
        if (word == null) continue;
        expect(<String>['A1', 'A2'], contains(word.level.toUpperCase()),
            reason: '${word.german} is ${word.level}, above the drawable set');
        expect(<String>['der', 'die', 'das'], contains(word.article),
            reason: '${word.german} is not a noun');
      }
    });
  });
}
