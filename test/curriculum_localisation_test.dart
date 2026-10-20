import 'package:deutsch_garden/app_state.dart';
import 'package:deutsch_garden/course.dart';
import 'package:deutsch_garden/course_screens.dart';
import 'package:deutsch_garden/curriculum.dart';
import 'package:deutsch_garden/curriculum_meta.dart';
import 'package:deutsch_garden/curriculum_text.dart';
import 'package:deutsch_garden/gender_guide.dart';
import 'package:deutsch_garden/grammar_tables.dart';
import 'package:deutsch_garden/l10n/app_localizations.dart';
import 'package:deutsch_garden/learning_path.dart';
import 'package:deutsch_garden/learning_path_text.dart';
import 'package:deutsch_garden/lesson_registry.dart';
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/skill_screens.dart';
import 'package:deutsch_garden/vocabulary.dart';
import 'package:deutsch_garden/vocabulary_metadata.dart';
import 'package:deutsch_garden/vocabulary_text.dart';
import 'package:deutsch_garden/word_class_guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'media_games_localisation_test.dart' show host, boot, press;

void narrow(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUp(() {
    AppController.debounceWrites = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  tearDown(() => AppController.debounceWrites = true);
  final en = lookupAppText(const Locale('en'));
  final de = lookupAppText(const Locale('de'));

  test('every lesson, unit and outcome has both catalog translations', () {
    expect(allLessons, hasLength(417));
    expect(courseUnits, hasLength(72));
    for (final source in [
      ...allLessons.map((l) => l.title),
      ...courseUnits.expand((u) => [u.title, u.canDo]),
    ]) {
      for (final t in [en, de]) {
        expect(curriculumTranslation(t, source), isNotNull, reason: source);
        expect(curriculumText(t, source).trim(), isNotEmpty, reason: source);
      }
    }
    expect(
      curriculumText(de, allLessons.first.title),
      'Präsens und Verbposition',
    );
    expect(
      curriculumText(en, 'Nacherzählung: Berlin · Ankunft'),
      'Retelling: Berlin · Ankunft',
    );
    expect(
      curriculumText(de, 'Nacherzählung: Berlin · Ankunft'),
      'Nacherzählung: Berlin · Ankunft',
    );
    expect(lessonForId('gr-a1-01')!.title, 'Present tense & verb position');
  });

  test(
    'all reference titles, notes and English column labels are translated',
    () {
      const germanColumns = {
        'sein',
        'haben',
        'machen',
        'können',
        'müssen',
        'wollen',
        'werden',
        'du',
        'er/sie/es',
      };
      for (final table in grammarReferenceTables) {
        for (final source in [
          table.title,
          table.note,
          ...table.columns.where((c) => !germanColumns.contains(c)),
        ]) {
          expect(curriculumTranslation(de, source), isNotNull, reason: source);
        }
      }
      for (final level in levelCoverage) {
        for (final source in [
          level.focus,
          ...level.grammarFocus,
          level.examFocus,
        ]) {
          expect(curriculumTranslation(de, source), isNotNull, reason: source);
        }
      }
      for (final c in GermanWordClass.values) {
        for (final source in [c.label, c.shortLabel, c.learningNote]) {
          expect(curriculumTranslation(de, source), isNotNull, reason: source);
        }
      }
      for (final rule in genderEndingRules) {
        expect(curriculumTranslation(de, rule.note), isNotNull);
      }
      expect(curriculumText(de, 'Nominative'), 'Nominativ');
      expect(
        curriculumText(de, 'No article shows it'),
        'Kein Artikel zeigt das Signal',
      );
      expect(
        curriculumText(de, 'Ich habe gearbeitet.'),
        'Ich habe gearbeitet.',
      );
    },
  );

  test('gender hints preserve exceptions and the actual learned article', () {
    final madchen = vocabulary.firstWhere((w) => w.german == 'Mädchen');
    expect(grammarLabelText(de, madchen), 'Nomen · Neutrum (das)');
    expect(genderEndingText(de, madchen), contains('Endung -chen'));
    final exception = vocabulary.firstWhere((w) => w.german == 'Erlaubnis');
    expect(genderEndingText(de, exception), contains('Ausnahme: -nis'));
    expect(genderEndingText(de, exception), contains('die Erlaubnis'));
    expect(genderEndingText(en, exception), contains('Exception: -nis'));
  });

  test('computed review and checkpoint titles translate nested metadata', () {
    final lesson = allLessons.first;
    final review = LearningPathAction(
      id: 'review-${lesson.id}',
      kind: LearningPathActionKind.lessonReview,
      title: lesson.title,
      subtitle: '',
      estimatedMinutes: 5,
      lesson: lesson,
    );
    expect(review.localizedTitle(de), contains('Präsens und Verbposition'));
    final unit = courseUnits.first;
    final step = unit.steps.firstWhere((s) => s.kind == CourseStepKind.grammar);
    expect(courseStepTitle(de, unit, step), 'Personalpronomen');
    expect(unit.title, 'Saying who you are');
    expect(step.route, 'gr-a1-x01');
  });

  testWidgets('word-class guide expands every group at 320px and 150% text', (
    tester,
  ) async {
    narrow(tester);
    await tester.pumpWidget(
      host(const WordClassGuideScreen(), locale: 'de', scale: 1.5),
    );
    await tester.pumpAndSettle();
    expect(find.text(de.wordClassGuide), findsOneWidget);
    for (final c in GermanWordClass.values.where(
      (c) => vocabulary.any((w) => w.wordClass == c),
    )) {
      await press(tester, curriculumText(de, c.label));
      await tester.pumpAndSettle();
      expect(find.text(curriculumText(de, c.learningNote)), findsOneWidget);
      expect(tester.takeException(), isNull, reason: c.name);
    }
  });

  testWidgets(
    'gender guide keeps rules and exceptions readable with large German text',
    (tester) async {
      narrow(tester);
      await tester.pumpWidget(
        host(const GenderGuideScreen(), locale: 'de', scale: 1.5),
      );
      await tester.pumpAndSettle();
      for (final rule in [
        for (final gender in NounGender.values)
          ...genderEndingRules.where((r) => r.gender == gender),
      ]) {
        await tester.scrollUntilVisible(
          find.text(curriculumText(de, rule.note)),
          140,
        );
        expect(tester.takeException(), isNull);
      }
      await tester.scrollUntilVisible(find.text(de.guideGenderExceptions), 140);
      expect(tester.takeException(), isNull);
    },
  );

  for (final level in CefrLevel.values) {
    testWidgets('${level.label} reference tables fit a narrow German screen', (
      tester,
    ) async {
      narrow(tester);
      await tester.pumpWidget(
        host(
          GrammarTablesScreen(initialLevel: level, ttsEnabled: false),
          locale: 'de',
          scale: 1.5,
        ),
      );
      await tester.pumpAndSettle();
      for (final table in grammarReferenceTables.where(
        (t) => t.level == level,
      )) {
        await tester.scrollUntilVisible(
          find.text(curriculumText(de, table.note)),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        expect(tester.takeException(), isNull, reason: table.id);
      }
    });
  }

  testWidgets('an open lesson title follows a live locale switch', (
    tester,
  ) async {
    final controller = await boot(AppController());
    final locale = ValueNotifier(const Locale('en'));
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, value, child) => MaterialApp(
          locale: value,
          supportedLocales: AppText.supportedLocales,
          localizationsDelegates: AppText.localizationsDelegates,
          home: GrammarLessonScreen(
            controller: controller,
            lesson: grammarFor(CefrLevel.a1).first,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Present tense & verb position'), findsOneWidget);
    locale.value = const Locale('de');
    await tester.pumpAndSettle();
    expect(find.text('Präsens und Verbposition'), findsOneWidget);
    expect(find.text('Ich lerne Deutsch.'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'handbook searches localized titles as well as original content',
    (tester) async {
      final controller = await boot(AppController());
      await tester.pumpWidget(
        host(GrammarHandbookScreen(controller: controller), locale: 'de'),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Verbposition');
      await tester.pumpAndSettle();
      expect(find.text('Präsens und Verbposition'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('course unit presents its German title and can-do outcome', (
    tester,
  ) async {
    narrow(tester);
    final controller = await boot(AppController());
    final unit = courseUnits.first;
    await tester.pumpWidget(
      host(
        CourseUnitScreen(controller: controller, unit: unit),
        locale: 'de',
        scale: 1.5,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sagen, wer du bist'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(curriculumText(de, unit.canDo)),
      140,
    );
    expect(tester.takeException(), isNull);
  });
}
