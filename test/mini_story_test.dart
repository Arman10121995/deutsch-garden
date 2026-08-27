import 'package:deutsch_garden/mini_story.dart';
import 'package:deutsch_garden/stories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every reader has one complete mini-story drill', () {
    expect(stories, hasLength(60));
    expect(allStoryChapters, hasLength(200));
    expect(miniStoryDrills, hasLength(stories.length));
    expect(
      miniStoryDrills.map((drill) => drill.id).toSet(),
      hasLength(miniStoryDrills.length),
    );
    for (final drill in miniStoryDrills) {
      expect(drill.transcript, hasLength(10), reason: drill.id);
      expect(drill.questions, hasLength(15), reason: drill.id);
      expect(drill.retellPrompts, hasLength(4), reason: drill.id);
      for (final question in drill.questions) {
        expect(question.options.length, greaterThanOrEqualTo(2));
        expect(
          question.correctIndex,
          inInclusiveRange(0, question.options.length - 1),
        );
      }
    }
  });
}
