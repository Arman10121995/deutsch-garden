// Helpers for driving a vocabulary learn session in widget tests.
//
// A learn session introduces its new words in small groups: two or three
// cards, then a question on each. Tests that only care about the questions
// step through the cards with these instead of knowing the group size.
import 'package:deutsch_garden/models.dart';
import 'package:deutsch_garden/quiz_distractors.dart';
import 'package:flutter_test/flutter_test.dart';

const String nextWordLabel = 'Next word';
const String testMeLabel = 'Got it — test me';

/// The option text a card's meaning is shown as.
String optionLabel(GermanWord word) => shortOptionLabel(word.english);

bool onCard(WidgetTester tester) => find.text('NEW WORD').evaluate().isNotEmpty;

Future<void> tapText(WidgetTester tester, String label) async {
  final Finder target = find.text(label).first;
  await tester.ensureVisible(target);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(target);
  await tester.pumpAndSettle();
}

/// Steps through new-word cards until a question is on screen.
Future<void> passCards(WidgetTester tester) async {
  for (int guard = 0; guard < 6 && onCard(tester); guard++) {
    await tapText(
      tester,
      find.text(nextWordLabel).evaluate().isNotEmpty
          ? nextWordLabel
          : testMeLabel,
    );
  }
}

/// The word the question on screen asks about, among [words].
GermanWord askedWord(WidgetTester tester, List<GermanWord> words) =>
    words.firstWhere(
      (GermanWord word) => find.text(word.displayGerman).evaluate().isNotEmpty,
    );
