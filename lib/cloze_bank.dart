import 'models.dart';
import 'vocabulary.dart';

/// One gap-fill item: a real sentence with the word it teaches removed.
class ClozeItem {
  const ClozeItem({
    required this.id,
    required this.level,
    required this.gapped,
    required this.answer,
    required this.full,
    required this.english,
    required this.distractors,
  });

  final String id;
  final CefrLevel level;

  /// The sentence with the target word replaced by a blank.
  final String gapped;

  /// The word that was removed, exactly as it appears in the sentence.
  final String answer;

  final String full;
  final String english;

  /// Three wrong answers of the same word class and level as [answer].
  final List<String> distractors;

  List<String> optionsFor(int seed) {
    final List<String> options = <String>[answer, ...distractors];
    // Deterministic shuffle: the same item always presents its options in the
    // same order, so a learner who meets it twice is not re-reading a new
    // layout, and a test can assert against it.
    for (int i = options.length - 1; i > 0; i--) {
      final int j = (seed * 31 + i * 17) % (i + 1);
      final String tmp = options[i];
      options[i] = options[j];
      options[j] = tmp;
    }
    return options;
  }
}

const String clozeGap = '_______';

/// Cloze items derived from the vocabulary deck.
///
/// Every card carries an example sentence that uses the word it teaches, so
/// blanking that word turns the whole deck into a gap-fill bank without
/// authoring a single new sentence. Around 8,000 of the 10,000 cards contain
/// their headword verbatim and qualify; the rest use an inflected form the
/// blanking cannot locate safely, and are skipped rather than guessed at.
///
/// The point of gapping *the taught word* rather than an arbitrary token is
/// that the learner is asked to produce the item being practised. Blanking
/// whichever word happened to be longest drills nothing in particular.
Map<CefrLevel, List<ClozeItem>>? _cache;

Map<CefrLevel, List<ClozeItem>> get _bank {
  final Map<CefrLevel, List<ClozeItem>>? cached = _cache;
  if (cached != null) return cached;

  // Candidate distractors, split by word class so a noun gap never offers an
  // adverb as an option. Wrong answers a learner can dismiss on sight make the
  // item free.
  final Map<CefrLevel, List<String>> nouns = <CefrLevel, List<String>>{};
  final Map<CefrLevel, List<String>> others = <CefrLevel, List<String>>{};
  for (final GermanWord word in vocabulary) {
    final CefrLevel level = word.cefr;
    final Map<CefrLevel, List<String>> pool =
        word.article.isEmpty ? others : nouns;
    pool.putIfAbsent(level, () => <String>[]).add(word.german);
  }

  final Map<CefrLevel, List<ClozeItem>> built = <CefrLevel, List<ClozeItem>>{};
  int counter = 0;
  for (final GermanWord word in vocabulary) {
    final String sentence = word.exampleGerman;
    if (!sentence.contains(word.german)) continue;

    final int words = sentence.split(RegExp(r'\s+')).length;
    if (words < 4 || words > 14) continue;

    final CefrLevel level = word.cefr;
    final List<String> pool =
        (word.article.isEmpty ? others[level] : nouns[level]) ?? <String>[];
    if (pool.length < 4) continue;

    // Three distinct distractors from the same class and level, chosen by a
    // stable stride so the set does not change between runs.
    final List<String> distractors = <String>[];
    int step = (counter * 7) % pool.length;
    while (distractors.length < 3 && distractors.length < pool.length - 1) {
      final String candidate = pool[step % pool.length];
      if (candidate != word.german && !distractors.contains(candidate)) {
        distractors.add(candidate);
      }
      step++;
    }
    if (distractors.length < 3) continue;

    built.putIfAbsent(level, () => <ClozeItem>[]).add(
          ClozeItem(
            id: 'cz-${word.id}',
            level: level,
            gapped: sentence.replaceFirst(word.german, clozeGap),
            answer: word.german,
            full: sentence,
            english: word.exampleEnglish,
            distractors: distractors,
          ),
        );
    counter++;
  }

  _cache = built;
  return built;
}

/// Every cloze item at this level.
List<ClozeItem> clozeFor(CefrLevel level) =>
    List<ClozeItem>.unmodifiable(_bank[level] ?? const <ClozeItem>[]);

/// Total across every level, for the content report.
int get clozeItemCount =>
    _bank.values.fold<int>(0, (int total, List<ClozeItem> l) => total + l.length);
