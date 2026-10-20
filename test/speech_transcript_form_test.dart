import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/speech_transcript_form.dart';

void main() {
  testWidgets(
    'Save requires actual words and verification resets after edits',
    (tester) async {
      final transcript = TextEditingController();
      addTearDown(transcript.dispose);
      bool reviewed = false;
      final saved = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SpeechTranscriptForm(
                readingText: 'Fünf grüne Bücher liegen neben der Tür.',
                silence: false,
                transcript: transcript,
                busy: false,
                reviewed: reviewed,
                onReviewed: (v) => setState(() => reviewed = v),
                onSave: () => saved.add(transcript.text),
              ),
            ),
          ),
        ),
      );
      FilledButton saveButton() =>
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton().onPressed, isNull);
      expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile))
            .onChanged,
        isNull,
      );
      expect(find.textContaining('Type your transcript'), findsOneWidget);
      await tester.tap(find.text('I said exactly the displayed sentence'));
      await tester.pump();
      expect(transcript.text, 'Fünf grüne Bücher liegen neben der Tür.');
      expect(saveButton().onPressed, isNull);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      expect(saveButton().onPressed, isNotNull);
      await tester.tap(find.byType(FilledButton));
      expect(saved, ['Fünf grüne Bücher liegen neben der Tür.']);
      await tester.enterText(find.byType(TextField), 'Andere Wörter.');
      await tester.pump();
      expect(reviewed, isFalse);
      expect(saveButton().onPressed, isNull);
      await tester.enterText(find.byType(TextField), '...');
      await tester.pump();
      expect(
        tester
            .widget<CheckboxListTile>(find.byType(CheckboxListTile))
            .onChanged,
        isNull,
      );
    },
  );

  testWidgets('silence needs confirmation without inventing spoken words', (
    tester,
  ) async {
    final transcript = TextEditingController();
    addTearDown(transcript.dispose);
    bool reviewed = false;
    int saves = 0;
    Widget view(bool busy) => MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SpeechTranscriptForm(
            readingText: 'unused target',
            silence: true,
            transcript: transcript,
            busy: busy,
            reviewed: reviewed,
            onReviewed: (v) => setState(() => reviewed = v),
            onSave: () => saves++,
          ),
        ),
      ),
    );
    await tester.pumpWidget(view(false));
    expect(find.byType(TextField), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    expect(saves, 1);
    expect(transcript.text, isEmpty);
    await tester.pumpWidget(view(true));
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
