import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'audio_course_screens.dart';
import 'cloze_bank.dart';
import 'german_text.dart';
import 'grammar_challenge.dart';
import 'lesson_registry.dart';
import 'models.dart';
import 'platform_support.dart';
import 'pronunciation.dart';
import 'radio.dart';
import 'radio_screens.dart';
import 'sentence_bank.dart';
import 'skill_screens.dart';
import 'srs.dart';
import 'stories.dart';
import 'story_screens.dart';
import 'test_screens.dart';
import 'tts_service.dart';

/// Hub for everything that is drilling rather than a lesson: the SRS review
/// queue, four quick games, the mistake bank and the exam section.
class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  CefrLevel? _level;

  CefrLevel get _selected => _level ?? widget.controller.highestUnlockedLevel;

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final CefrLevel level = _selected;
          final int due = widget.controller.dueCount;
          final int mistakes = widget.controller.mistakes.length;
          final int difficult = widget.controller.difficultWords.length;
          final List<LessonRef> dueLessons =
              lessonsForIds(widget.controller.dueActivityIds);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            children: <Widget>[
              Text(
                'Üben',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text('Short, sharp drills — and the exam section.'),
              const SizedBox(height: 16),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: due == 0
                      ? null
                      : () => _open(ReviewSessionScreen(
                            controller: widget.controller,
                          )),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        const Text('🔁', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Review queue',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text(due == 0
                                  ? 'Nothing due right now. Learn new words to fill it.'
                                  : '$due card${due == 1 ? '' : 's'} due • rate your own recall, SM-2 schedules the rest'),
                            ],
                          ),
                        ),
                        if (due > 0) const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Vocabulary was the only thing this app ever scheduled. Grammar,
              // listening, reading, writing and speaking lessons were finished
              // once and never seen again, which is precisely how German case
              // endings and verb governance quietly rot.
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: dueLessons.isEmpty
                      ? null
                      : () => _open(LessonReviewScreen(
                            controller: widget.controller,
                          )),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        const Text('🧠', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Lesson review',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text(dueLessons.isEmpty
                                  ? 'No lessons due. Passed lessons come back on their own schedule.'
                                  : '${dueLessons.length} lesson${dueLessons.length == 1 ? '' : 's'} due • grammar, listening, reading, writing and speaking'),
                            ],
                          ),
                        ),
                        if (dueLessons.isNotEmpty)
                          const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _open(AudioCourseScreen(
                    controller: widget.controller,
                    level: level,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        const Text('🎧',
                            style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Audio course',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text('Day '
                                  '${widget.controller.audioCourseDay(level)} '
                                  '• read the English, say the German in '
                                  'the silence, then hear it • ten new '
                                  'sentences a day with spaced replays'),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  // StoryLibraryScreen is a tab body, not a route: it has no
                  // Scaffold of its own, so pushing it bare leaves its chips
                  // without a Material ancestor.
                  onTap: () => _open(
                    Scaffold(
                      appBar: AppBar(title: const Text('Story library')),
                      body: StoryLibraryScreen(controller: widget.controller),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        const Text('📖', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Story library',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text('${storiesFor(level).length} graded '
                                  'stor${storiesFor(level).length == 1 ? 'y' : 'ies'} '
                                  'at ${level.label} • chapters, glossary '
                                  'and comprehension questions'),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _open(RadioLibraryScreen(
                    controller: widget.controller,
                    level: level,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: <Widget>[
                        const Text('📻', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text('Gartenradio',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 3),
                              Text('${radioFor(level).length} narrated episode'
                                  '${radioFor(level).length == 1 ? '' : 's'} at '
                                  '${level.label} • news, weather, recipes, '
                                  'audio guides, with transcripts'),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CefrLevel.values.map((value) {
                    final bool unlocked =
                        widget.controller.isLevelUnlocked(value);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(value.label),
                        selected: value == level,
                        onSelected: unlocked
                            ? (_) => setState(() => _level = value)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.05,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: <Widget>[
                  _gameTile(
                    emoji: '🃏',
                    title: 'Match pairs',
                    subtitle: 'German ↔ English against the clock',
                    onTap: () => _open(MatchPairsScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '🧱',
                    title: 'Sentence builder',
                    subtitle: 'Rebuild the sentence from a word bank',
                    onTap: () => _open(SentenceBuilderScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '✍️',
                    title: 'Dictation',
                    subtitle: 'Hear it, type it, see the diff',
                    onTap: () => _open(DictationScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '⚡',
                    title: 'Speed review',
                    subtitle: '60 seconds, as many as you can',
                    onTap: () => _open(SpeedReviewScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '🎯',
                    title: 'Der/Die/Das',
                    subtitle: 'Master noun genders & articles',
                    onTap: () => _open(ArticleTrainerScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '⚙️',
                    title: 'Verb lab',
                    subtitle: 'Conjugate verbs across tenses',
                    onTap: () => _open(VerbLabScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '🧩',
                    title: 'Cloze drill',
                    subtitle: 'Fill missing words in context',
                    onTap: () => _open(ClozeDrillScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '🎧',
                    title: 'Shadow lab',
                    subtitle: 'Listen, repeat & score speech',
                    onTap: () => _open(ShadowLabScreen(
                        controller: widget.controller, level: level)),
                  ),
                  _gameTile(
                    emoji: '📐',
                    title: 'Grammar challenges',
                    subtitle: 'Twelve structures, one at a time',
                    onTap: () => _open(
                        GrammarChallengeHubScreen(controller: widget.controller)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: const Text('🩹', style: TextStyle(fontSize: 26)),
                  title: const Text('Mistake bank',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(mistakes == 0
                      ? 'Empty — every wrong answer lands here for targeted review.'
                      : '$mistakes item${mistakes == 1 ? '' : 's'} waiting'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      _open(MistakeBankScreen(controller: widget.controller)),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('🧠', style: TextStyle(fontSize: 26)),
                  title: const Text('Difficult words',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(difficult == 0
                      ? 'No leeches yet. Words you keep forgetting appear here.'
                      : '$difficult word${difficult == 1 ? '' : 's'} keep slipping — write a mnemonic'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _open(
                      DifficultWordsScreen(controller: widget.controller)),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: ListTile(
                  leading: const Text('🎓', style: TextStyle(fontSize: 26)),
                  title: const Text('Tests & exam preparation',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: const Text(
                      'Placement assessment, exam strategies and mini mocks'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      _open(TestHubHostScreen(controller: widget.controller)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _gameTile({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const Spacer(),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps the existing test hub so it can be pushed as its own route.
/// The lessons whose review has come due, across every skill track.
///
/// Deliberately a plain list rather than an auto-advancing session: a grammar
/// lesson, a listening comprehension and a writing task are not
/// interchangeable units the way flashcards are, and pretending otherwise
/// would make the queue feel like a chore. The learner picks.
class LessonReviewScreen extends StatelessWidget {
  const LessonReviewScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson review')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final List<LessonRef> due =
              lessonsForIds(controller.dueActivityIds);
          if (due.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nothing due.\n\n'
                  'Lessons you have passed come back on their own '
                  'schedule, sooner if you found them hard.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: due.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${due.length} lesson${due.length == 1 ? '' : 's'} due. '
                    'Redoing one reschedules it by how well you score.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }
              final LessonRef ref = due[index - 1];
              final ActivityProgress p =
                  controller.progressForActivity(ref.id);
              final int overdueDays =
                  DateTime.now().difference(p.dueAt).inDays;
              return Card(
                child: ListTile(
                  leading: Text(
                    ref.skill.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    ref.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${ref.level.label} • ${ref.skill.label} • '
                    'best ${p.bestScore}%'
                    '${overdueDays > 0 ? ' • $overdueDays day${overdueDays == 1 ? '' : 's'} overdue' : ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => lessonScreenFor(controller, ref),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TestHubHostScreen extends StatelessWidget {
  const TestHubHostScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tests & exam preparation')),
      body: TestHubScreen(controller: controller),
    );
  }
}

// ---------------------------------------------------------------------------
// SM-2 review queue
// ---------------------------------------------------------------------------

class ReviewSessionScreen extends StatefulWidget {
  const ReviewSessionScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  final TtsService _tts = TtsService();
  final FocusNode _keyboardFocus = FocusNode(debugLabel: 'review-shortcuts');
  late List<GermanWord> _queue;
  int _index = 0;
  bool _revealed = false;
  int _graded = 0;

  @override
  void initState() {
    super.initState();
    _queue = widget.controller.reviewWords.take(40).toList();
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    _tts.stop();
    super.dispose();
  }

  /// Desktop keyboard control, the way every serious SRS client works:
  /// space or enter reveals, then 1-4 grade. Reviewing a long queue with the
  /// mouse is the fastest way to make someone stop reviewing.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (_index >= _queue.length) return KeyEventResult.ignored;

    final LogicalKeyboardKey key = event.logicalKey;
    if (!_revealed) {
      if (key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.numpadEnter) {
        setState(() => _revealed = true);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // Not const: LogicalKeyboardKey overrides ==, so it cannot key a const map.
    final Map<LogicalKeyboardKey, ReviewGrade> bindings =
        <LogicalKeyboardKey, ReviewGrade>{
      LogicalKeyboardKey.digit1: ReviewGrade.again,
      LogicalKeyboardKey.numpad1: ReviewGrade.again,
      LogicalKeyboardKey.digit2: ReviewGrade.hard,
      LogicalKeyboardKey.numpad2: ReviewGrade.hard,
      LogicalKeyboardKey.digit3: ReviewGrade.good,
      LogicalKeyboardKey.numpad3: ReviewGrade.good,
      LogicalKeyboardKey.digit4: ReviewGrade.easy,
      LogicalKeyboardKey.numpad4: ReviewGrade.easy,
    };
    final ReviewGrade? grade = bindings[key];
    if (grade != null) {
      _grade(grade);
      return KeyEventResult.handled;
    }
    // Space on a revealed card repeats "Good", matching Anki.
    if (key == LogicalKeyboardKey.space) {
      _grade(ReviewGrade.good);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _grade(ReviewGrade grade) async {
    final GermanWord word = _queue[_index];
    await widget.controller.gradeWord(word, grade);
    if (!mounted) return;
    setState(() {
      _graded += 1;
      _revealed = false;
      _index += 1;
    });
  }

  Future<void> _editMnemonic(GermanWord word) async {
    final TextEditingController input = TextEditingController(
      text: widget.controller.progressFor(word.id).mnemonic,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mnemonic for ${word.displayGerman}'),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'A picture, a rhyme, a story — whatever sticks.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    input.dispose();
    if (result == null) return;
    await widget.controller.setMnemonic(word.id, result);
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty || _index >= _queue.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('🌳', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 12),
                Text(
                  _graded == 0
                      ? 'Nothing due right now.'
                      : 'Queue cleared — $_graded card${_graded == 1 ? '' : 's'} reviewed.',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final GermanWord word = _queue[_index];
    final WordProgress progress = widget.controller.progressFor(word.id);
    return Focus(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Review ${_index + 1}/${_queue.length}'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: _index / _queue.length),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Text(
                      word.displayGerman,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: word.genderColor(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      tooltip: 'Hear this word in German',
                      onPressed: widget.controller.ttsEnabled
                          ? () => _tts.speakGerman(word.displayGerman)
                          : null,
                      icon: const Icon(Icons.volume_up_rounded),
                    ),
                    if (_revealed) ...<Widget>[
                      const Divider(height: 30),
                      Text(word.english,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text(word.exampleGerman, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(word.exampleEnglish,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                      if (progress.mnemonic.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 14),
                        Text('🧠 ${progress.mnemonic}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_revealed)
              FilledButton(
                onPressed: () => setState(() => _revealed = true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(PlatformSupport.isDesktop
                      ? 'Show answer  (space)'
                      : 'Show answer'),
                ),
              )
            else ...<Widget>[
              Row(
                children: ReviewGrade.values.map((grade) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () => _grade(grade),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: <Widget>[
                              Text(grade.emoji),
                              const SizedBox(height: 2),
                              Text(grade.label,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(
                                Sm2Scheduler.previewLabel(
                                  ease: progress.ease,
                                  intervalDays: progress.intervalDays,
                                  reps: progress.reps,
                                  lapses: progress.lapses,
                                  learningStep: progress.learningStep,
                                  grade: grade,
                                ),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _editMnemonic(word),
                icon: const Icon(Icons.psychology_outlined),
                label: Text(progress.mnemonic.isEmpty
                    ? 'Add a mnemonic'
                    : 'Edit mnemonic'),
              ),
              if (PlatformSupport.isDesktop) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  'Keyboard: 1 Again · 2 Hard · 3 Good · 4 Easy · Space repeats Good',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ],
            const SizedBox(height: 20),
            Text(
              'Ease ${progress.ease.toStringAsFixed(2)} • '
              'interval ${progress.intervalDays}d • lapses ${progress.lapses}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Match pairs
// ---------------------------------------------------------------------------

class MatchPairsScreen extends StatefulWidget {
  const MatchPairsScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends State<MatchPairsScreen> {
  static const int pairsPerRound = 6;
  static const int rounds = 3;

  final Random _random = Random();
  final TtsService _tts = TtsService();

  late List<GermanWord> _round;
  late List<String> _left;
  late List<String> _right;
  final Set<String> _solved = <String>{};
  String? _pickedLeft;
  String? _pickedRight;
  bool _wrongFlash = false;
  int _roundIndex = 0;
  int _mistakes = 0;
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _deal();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  void _deal() {
    final List<GermanWord> pool =
        widget.controller.wordsForLevel(widget.level).toList()..shuffle(_random);
    _round = pool.take(pairsPerRound).toList();
    _left = _round.map((word) => word.displayGerman).toList()..shuffle(_random);
    _right = _round.map((word) => word.english).toList()..shuffle(_random);
    _solved.clear();
    _pickedLeft = null;
    _pickedRight = null;
  }

  GermanWord? _wordForGerman(String german) {
    for (final GermanWord word in _round) {
      if (word.displayGerman == german) return word;
    }
    return null;
  }

  Future<void> _check() async {
    final String? left = _pickedLeft;
    final String? right = _pickedRight;
    if (left == null || right == null) return;
    final GermanWord? word = _wordForGerman(left);
    if (word != null && word.english == right) {
      if (widget.controller.ttsEnabled) _tts.speakGerman(word.displayGerman);
      await widget.controller.gradeWord(word, ReviewGrade.good);
      if (!mounted) return;
      setState(() {
        _solved.add(left);
        _solved.add(right);
        _pickedLeft = null;
        _pickedRight = null;
      });
      if (_solved.length >= pairsPerRound * 2) await _nextRound();
      return;
    }
    _mistakes += 1;
    if (word != null) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'match-${word.id}',
          prompt: word.displayGerman,
          correctAnswer: word.english,
          givenAnswer: right,
          source: 'vocabulary',
          level: word.level,
          timestamp: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _wrongFlash = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _wrongFlash = false;
      _pickedLeft = null;
      _pickedRight = null;
    });
  }

  Future<void> _nextRound() async {
    if (_roundIndex + 1 >= rounds) {
      _timer?.cancel();
      final int total = pairsPerRound * rounds;
      final int score =
          (((total - _mistakes).clamp(0, total) / total) * 100).round();
      await widget.controller.recordActivity(
        'game-match-${widget.level.label.toLowerCase()}',
        score: score,
        passingScore: 70,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Runde beendet'),
          content: Text('$score% • $_mistakes mistakes • ${_elapsed}s'),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    if (!mounted) return;
    setState(() {
      _roundIndex += 1;
      _deal();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_round.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match pairs')),
        body: const Center(
          child: Text('Not enough words at this level to build a round.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Match pairs • ${widget.level.label}'),
        actions: <Widget>[
          Center(child: Text('${_elapsed}s')),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_roundIndex + 1) / rounds),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _column(_left, isLeft: true)),
            const SizedBox(width: 10),
            Expanded(child: _column(_right, isLeft: false)),
          ],
        ),
      ),
    );
  }

  Widget _column(List<String> items, {required bool isLeft}) {
    return Column(
      children: items.map((item) {
        final bool solved = _solved.contains(item);
        final bool picked = isLeft ? _pickedLeft == item : _pickedRight == item;
        final ColorScheme scheme = Theme.of(context).colorScheme;
        Color? background;
        if (solved) {
          background = scheme.tertiaryContainer;
        } else if (picked) {
          background = _wrongFlash ? scheme.errorContainer : scheme.primaryContainer;
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: background,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              ),
              onPressed: solved
                  ? null
                  : () {
                      setState(() {
                        if (isLeft) {
                          _pickedLeft = item;
                        } else {
                          _pickedRight = item;
                        }
                      });
                      _check();
                    },
              child: Text(
                item,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Sentence builder
// ---------------------------------------------------------------------------

class SentenceBuilderScreen extends StatefulWidget {
  const SentenceBuilderScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  static const int questionsPerRound = 8;

  final Random _random = Random();
  final TtsService _tts = TtsService();

  late List<PracticeSentence> _items;
  final List<String> _built = <String>[];
  late List<String> _bank;
  int _index = 0;
  int _correct = 0;
  bool? _verdict;

  @override
  void initState() {
    super.initState();
    _items = sentencesFor(widget.level)..shuffle(_random);
    if (_items.length > questionsPerRound) {
      _items = _items.sublist(0, questionsPerRound);
    }
    _resetBank();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _resetBank() {
    if (_items.isEmpty) {
      _bank = <String>[];
      return;
    }
    _built.clear();
    _bank = List<String>.from(_items[_index].tokens)..shuffle(_random);
    _verdict = null;
  }

  Future<void> _check() async {
    final PracticeSentence sentence = _items[_index];
    // Compared through the German normaliser so a stray space or a trailing
    // full stop in the authored sentence cannot fail a correctly built answer.
    final bool right = isGermanAnswerAccepted(_built.join(' '), sentence.german);
    setState(() => _verdict = right);
    if (right) {
      _correct += 1;
      if (widget.controller.ttsEnabled) _tts.speakGerman(sentence.german);
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'build-${sentence.id}',
          prompt: sentence.english,
          correctAnswer: sentence.german,
          givenAnswer: _built.join(' '),
          source: 'grammar',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _next() async {
    if (_index + 1 >= _items.length) {
      final int score = ((_correct / _items.length) * 100).round();
      await widget.controller.recordActivity(
        'game-build-${widget.level.label.toLowerCase()}',
        score: score,
        passingScore: 70,
      );
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _resetBank();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sentence builder')),
        body: const Center(child: Text('No sentences available at this level.')),
      );
    }
    final PracticeSentence sentence = _items[_index];
    final bool? verdict = _verdict;
    return Scaffold(
      appBar: AppBar(
        title: Text('Satzbau • ${widget.level.label}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / _items.length),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
        children: <Widget>[
          Text('Build the German sentence',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(sentence.english,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(minHeight: 90),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _built
                  .asMap()
                  .entries
                  .map((entry) => ActionChip(
                        label: Text(entry.value),
                        onPressed: verdict != null
                            ? null
                            : () => setState(() {
                                  _bank.add(_built.removeAt(entry.key));
                                }),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _bank
                .asMap()
                .entries
                .map((entry) => ActionChip(
                      label: Text(entry.value),
                      onPressed: verdict != null
                          ? null
                          : () => setState(() {
                                _built.add(_bank.removeAt(entry.key));
                              }),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          if (verdict == null)
            FilledButton(
              onPressed: _built.isEmpty ? null : _check,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Check'),
              ),
            )
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(verdict ? 'Richtig! ✅' : 'Nicht ganz.',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Text(sentence.german,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (sentence.focus.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(sentence.focus,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_index + 1 >= _items.length ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dictation
// ---------------------------------------------------------------------------

class DictationScreen extends StatefulWidget {
  const DictationScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends State<DictationScreen> {
  static const int itemsPerRound = 6;

  final Random _random = Random();
  final TtsService _tts = TtsService();
  final TextEditingController _input = TextEditingController();

  late List<PracticeSentence> _items;
  int _index = 0;
  int _scoreTotal = 0;
  PronunciationResult? _result;

  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _items = sentencesFor(widget.level)..shuffle(_random);
    if (_items.length > itemsPerRound) {
      _items = _items.sublist(0, itemsPerRound);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void dispose() {
    _input.dispose();
    _tts.stop();
    super.dispose();
  }

  void _play() {
    if (_items.isEmpty) return;
    if (!widget.controller.ttsEnabled) return;
    _tts.speakGerman(_items[_index].german, rate: _speed);
  }

  Future<void> _check() async {
    final PracticeSentence sentence = _items[_index];
    // The same alignment used for speech: it reports which words were dropped
    // or misspelled instead of a bare right/wrong.
    final PronunciationResult result =
        PronunciationScorer.compare(sentence.german, _input.text);
    _scoreTotal += result.score;
    if (result.score < 80) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'dict-${sentence.id}',
          prompt: 'Dictation: ${sentence.english}',
          correctAnswer: sentence.german,
          givenAnswer: _input.text,
          source: 'dictation',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _result = result);
  }

  Future<void> _next() async {
    if (_index + 1 >= _items.length) {
      final int average = (_scoreTotal / _items.length).round();
      await widget.controller.recordActivity(
        'game-dictation-${widget.level.label.toLowerCase()}',
        score: average,
        passingScore: 70,
      );
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index += 1;
      _result = null;
      _input.clear();
    });
    _play();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dictation')),
        body: const Center(child: Text('No sentences available at this level.')),
      );
    }
    final PracticeSentence sentence = _items[_index];
    final PronunciationResult? result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text('Diktat • ${widget.level.label}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_index + 1) / _items.length),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ChoiceChip(
                label: const Text('0.75x Slow'),
                selected: _speed == 0.75,
                onSelected: (_) => setState(() => _speed = 0.75),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('1.0x Normal'),
                selected: _speed == 1.0,
                onSelected: (_) => setState(() => _speed = 1.0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('1.25x Fast'),
                selected: _speed == 1.25,
                onSelected: (_) => setState(() => _speed = 1.25),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              onPressed: _play,
              icon: const Icon(Icons.replay_rounded),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Text('Play sentence'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _input,
            minLines: 2,
            maxLines: 4,
            enabled: result == null,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Type what you hear…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (result == null)
            FilledButton(
              onPressed: _input.text.trim().isEmpty ? null : _check,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Check'),
              ),
            )
          else ...<Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${result.score}% ${result.stars}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: result.words.map((word) {
                        final ColorScheme scheme = Theme.of(context).colorScheme;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: word.isMatch
                                ? scheme.tertiaryContainer
                                : scheme.errorContainer,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(word.expected),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(sentence.german,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(sentence.english,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _next,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(_index + 1 >= _items.length ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speed review
// ---------------------------------------------------------------------------

class SpeedReviewScreen extends StatefulWidget {
  const SpeedReviewScreen({
    super.key,
    required this.controller,
    required this.level,
  });

  final AppController controller;
  final CefrLevel level;

  @override
  State<SpeedReviewScreen> createState() => _SpeedReviewScreenState();
}

class _SpeedReviewScreenState extends State<SpeedReviewScreen> {
  static const int roundSeconds = 60;

  final Random _random = Random();
  Timer? _timer;
  int _remaining = roundSeconds;
  int _hits = 0;
  int _misses = 0;
  bool _running = true;

  late List<GermanWord> _pool;
  late GermanWord _current;
  late List<String> _options;
  int? _picked;

  @override
  void initState() {
    super.initState();
    _pool = widget.controller.wordsForLevel(widget.level).toList();
    _nextQuestion();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= 1);
      if (_remaining <= 0) _finish();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextQuestion() {
    _pool.shuffle(_random);
    _current = _pool.first;
    final List<String> distractors = _pool
        .where((word) => word.id != _current.id)
        .map((word) => word.english)
        .take(3)
        .toList();
    _options = <String>[_current.english, ...distractors]..shuffle(_random);
    _picked = null;
  }

  Future<void> _pick(int index) async {
    if (!_running || _picked != null) return;
    final bool right = _options[index] == _current.english;
    setState(() => _picked = index);
    if (right) {
      _hits += 1;
      await widget.controller.gradeWord(_current, ReviewGrade.good);
    } else {
      _misses += 1;
      await widget.controller.gradeWord(_current, ReviewGrade.again);
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'speed-${_current.id}',
          prompt: _current.displayGerman,
          correctAnswer: _current.english,
          givenAnswer: _options[index],
          source: 'vocabulary',
          level: _current.level,
          timestamp: DateTime.now(),
        ),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted || !_running) return;
    setState(_nextQuestion);
  }

  Future<void> _finish() async {
    if (!_running) return;
    _running = false;
    _timer?.cancel();
    final int total = _hits + _misses;
    final int score = total == 0 ? 0 : ((_hits / total) * 100).round();
    await widget.controller.recordActivity(
      'game-speed-${widget.level.label.toLowerCase()}',
      score: score,
      passingScore: 70,
    );
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_pool.length < 4) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speed review')),
        body: const Center(
          child: Text('Not enough words at this level for a speed round.'),
        ),
      );
    }
    if (!_running) {
      return Scaffold(
        appBar: AppBar(title: const Text('Speed review')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('⚡', style: TextStyle(fontSize: 54)),
                const SizedBox(height: 10),
                Text('$_hits correct',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w900)),
                Text('$_misses missed'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$_remaining s'),
        actions: <Widget>[
          Center(child: Text('✅ $_hits   ❌ $_misses')),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: _remaining / roundSeconds),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        children: <Widget>[
          Text(
            _current.displayGerman,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: _current.genderColor(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(height: 30),
          ..._options.asMap().entries.map((entry) {
            final bool isCorrect = entry.value == _current.english;
            Color? background;
            if (_picked != null) {
              if (isCorrect) {
                background = Theme.of(context).colorScheme.tertiaryContainer;
              } else if (_picked == entry.key) {
                background = Theme.of(context).colorScheme.errorContainer;
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: background),
                onPressed: () => _pick(entry.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(entry.value, style: const TextStyle(fontSize: 16)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mistake bank and difficult words
// ---------------------------------------------------------------------------

class MistakeBankScreen extends StatefulWidget {
  const MistakeBankScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<MistakeBankScreen> createState() => _MistakeBankScreenState();
}

class _MistakeBankScreenState extends State<MistakeBankScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSource = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sources = <String>[
      'all',
      'vocabulary',
      'grammar',
      'listening',
      'reading',
      'dictation',
      'story',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mistake bank'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear all',
            onPressed: () async {
              final bool? confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear the mistake bank?'),
                  content: const Text(
                      'Every stored mistake is removed. Progress and XP stay.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await widget.controller.clearAllMistakes();
              }
            },
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final List<MistakeEntry> allEntries = widget.controller.mistakes;
          if (allEntries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'Nothing here yet.\n\nEvery wrong answer from vocabulary, '
                  'grammar, stories and dictation lands in this list so you can '
                  'drill exactly what you got wrong.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final query = _searchController.text.trim().toLowerCase();
          final filtered = allEntries.where((entry) {
            final matchesSource = _selectedSource == 'all' ||
                entry.source.toLowerCase() == _selectedSource;
            final matchesQuery = query.isEmpty ||
                entry.prompt.toLowerCase().contains(query) ||
                entry.correctAnswer.toLowerCase().contains(query) ||
                entry.givenAnswer.toLowerCase().contains(query);
            return matchesSource && matchesQuery;
          }).toList();

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search mistakes...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                          tooltip: 'Clear search',
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: sources.map((src) {
                    final label = src[0].toUpperCase() + src.substring(1);
                    final isSelected = _selectedSource == src;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedSource = src);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No mistakes found matching your filter.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final MistakeEntry entry = filtered[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                entry.prompt,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const SizedBox(height: 4),
                                  Text('✅ ${entry.correctAnswer}'),
                                  if (entry.givenAnswer.isNotEmpty)
                                    Text('❌ ${entry.givenAnswer}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${entry.source} • ${entry.level}',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                tooltip: 'Mark as fixed',
                                onPressed: () =>
                                    widget.controller.clearMistake(entry.id),
                                icon: const Icon(Icons.check_circle_outline),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DifficultWordsScreen extends StatelessWidget {
  const DifficultWordsScreen({super.key, required this.controller});

  final AppController controller;

  Future<void> _editMnemonic(BuildContext context, GermanWord word) async {
    final TextEditingController input = TextEditingController(
      text: controller.progressFor(word.id).mnemonic,
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mnemonic for ${word.displayGerman}'),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'A picture, a rhyme, a story — whatever sticks.',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, input.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    input.dispose();
    if (result == null) return;
    await controller.setMnemonic(word.id, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Difficult words')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final List<GermanWord> words = controller.difficultWords;
          if (words.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Text(
                  'No difficult words yet.\n\nA word appears here once you have '
                  'forgotten it four times after learning it. The fix is a '
                  'mnemonic, not another blind repetition.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
            itemCount: words.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final GermanWord word = words[index];
              final WordProgress progress = controller.progressFor(word.id);
              return Card(
                child: ListTile(
                  title: Text(word.displayGerman,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(word.english),
                      const SizedBox(height: 3),
                      Text('Forgotten ${progress.lapses}× • ease '
                          '${progress.ease.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.labelSmall),
                      if (progress.mnemonic.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 4),
                        Text('🧠 ${progress.mnemonic}',
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: 'Mnemonic',
                    onPressed: () => _editMnemonic(context, word),
                    icon: const Icon(Icons.psychology_outlined),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Der/Die/Das Article Trainer
// ---------------------------------------------------------------------------

class ArticleTrainerScreen extends StatefulWidget {
  const ArticleTrainerScreen({super.key, required this.controller, required this.level});

  final AppController controller;
  final CefrLevel level;

  @override
  State<ArticleTrainerScreen> createState() => _ArticleTrainerScreenState();
}

class _ArticleTrainerScreenState extends State<ArticleTrainerScreen> {
  final Random _random = Random();
  late List<GermanWord> _words;
  int _index = 0;
  String? _feedback;
  bool? _correct;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _words = widget.controller
        .wordsForLevel(widget.level)
        .where((w) => w.article.isNotEmpty)
        .toList()..shuffle(_random);
  }

  void _choose(String article) async {
    if (_feedback != null) return;
    final current = _words[_index];
    final bool correct = current.article.toLowerCase() == article.toLowerCase();
    await widget.controller.answer(current, correct: correct);
    if (!correct) {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'art-${current.id}',
          prompt: 'Article for "${current.german}"',
          correctAnswer: '${current.article} ${current.german}',
          givenAnswer: '$article ${current.german}',
          source: 'vocabulary',
          level: current.level,
          timestamp: DateTime.now(),
        ),
      );
    }
    setState(() {
      _correct = correct;
      if (correct) _score += 10;
      _feedback = correct
          ? 'Richtig! ${current.article} ${current.german}'
          : 'Falsch! Correct: ${current.article} ${current.german} (${current.english})';
    });
  }

  void _next() {
    if (_index + 1 >= _words.length) {
      _words.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _feedback = null;
      _correct = null;
    });
  }

  String _genderRuleHint(String word) {
    final lower = word.toLowerCase();
    if (lower.endsWith('ung') || lower.endsWith('heit') || lower.endsWith('keit') || lower.endsWith('schaft') || lower.endsWith('ei')) {
      return 'Grammar Tip: Suffixes -ung, -heit, -keit, -schaft, -ei are feminine (die).';
    }
    if (lower.endsWith('chen') || lower.endsWith('lein') || lower.endsWith('tum') || lower.endsWith('ment')) {
      return 'Grammar Tip: Diminutives -chen, -lein and suffixes -tum, -ment are neuter (das).';
    }
    if (lower.endsWith('ling') || lower.endsWith('or') || lower.endsWith('ismus') || lower.endsWith('ist')) {
      return 'Grammar Tip: Suffixes -ling, -or, -ismus, -ist are masculine (der).';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Der/Die/Das Trainer')),
        body: const Center(child: Text('No nouns found for this level.')),
      );
    }

    final GermanWord word = _words[_index];
    final String tip = _genderRuleHint(word.german);

    return Scaffold(
      appBar: AppBar(
        title: Text('Der/Die/Das • ${widget.level.label}'),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('Score: $_score'),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Text('Choose the correct article:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Text(
                        word.german,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(word.english, style: Theme.of(context).textTheme.titleMedium),
                      if (tip.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(tip, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                        )
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _feedback != null ? null : () => _choose('der'),
                      child: const Text('DER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _feedback != null ? null : () => _choose('die'),
                      child: const Text('DIE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: _feedback != null ? null : () => _choose('das'),
                      child: const Text('DAS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              if (_feedback != null) ...<Widget>[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _correct == true ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_feedback!, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next noun'),
                )
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Verb Conjugation & Tense Lab
// ---------------------------------------------------------------------------

class VerbConjugationItem {
  const VerbConjugationItem({
    required this.verb,
    required this.pronoun,
    required this.tense,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
  });

  final String verb;
  final String pronoun;
  final String tense;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
}

class VerbLabScreen extends StatefulWidget {
  const VerbLabScreen({super.key, required this.controller, required this.level});

  final AppController controller;
  final CefrLevel level;

  @override
  State<VerbLabScreen> createState() => _VerbLabScreenState();
}

class _VerbLabScreenState extends State<VerbLabScreen> {
  final Random _random = Random();
  late List<VerbConjugationItem> _items;
  int _index = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _items = _generateItems();
  }

  List<VerbConjugationItem> _generateItems() {
    return <VerbConjugationItem>[
      const VerbConjugationItem(
        verb: 'sein',
        pronoun: 'wir',
        tense: 'Präsens',
        correctAnswer: 'sind',
        options: <String>['sind', 'seid', 'bin', 'ist'],
        explanation: 'sein in Präsens for wir: wir sind.',
      ),
      const VerbConjugationItem(
        verb: 'haben',
        pronoun: 'du',
        tense: 'Präsens',
        correctAnswer: 'hast',
        options: <String>['hast', 'habe', 'hat', 'haben'],
        explanation: 'haben for du drops -en and adds -st with vowel change: du hast.',
      ),
      const VerbConjugationItem(
        verb: 'werden',
        pronoun: 'er/sie/es',
        tense: 'Präsens',
        correctAnswer: 'wird',
        options: <String>['wird', 'werdet', 'wirst', 'werden'],
        explanation: 'werden has vowel change e->i for er/sie/es: wird.',
      ),
      const VerbConjugationItem(
        verb: 'gehen',
        pronoun: 'ich',
        tense: 'Perfekt',
        correctAnswer: 'bin gegangen',
        options: <String>['bin gegangen', 'habe gegangen', 'ging', 'gehe'],
        explanation: 'gehen indicates motion, taking sein + ge-gang-en.',
      ),
      const VerbConjugationItem(
        verb: 'sprechen',
        pronoun: 'du',
        tense: 'Präsens',
        correctAnswer: 'sprichst',
        options: <String>['sprichst', 'sprechtest', 'sprich', 'sprecht'],
        explanation: 'sprechen is a strong verb with e->i change: du sprichst.',
      ),
      const VerbConjugationItem(
        verb: 'wollen',
        pronoun: 'ich',
        tense: 'Präsens',
        correctAnswer: 'will',
        options: <String>['will', 'wolle', 'wollt', 'willst'],
        explanation: 'Modal verbs have identical 1st/3rd person singular forms: ich will.',
      ),
      const VerbConjugationItem(
        verb: 'können',
        pronoun: 'sie (plural)',
        tense: 'Präteritum',
        correctAnswer: 'konnten',
        options: <String>['konnten', 'könnten', 'kann', 'konntet'],
        explanation: 'können in Präteritum drops umlaut: sie konnten.',
      ),
      const VerbConjugationItem(
        verb: 'fahren',
        pronoun: 'er',
        tense: 'Präsens',
        correctAnswer: 'fährt',
        options: <String>['fährt', 'fahrt', 'fuhren', 'gefahren'],
        explanation: 'fahren changes a->ä in 2nd/3rd person singular: er fährt.',
      ),
    ]..shuffle(_random);
  }

  void _choose(String option) async {
    if (_selected != null) return;
    final item = _items[_index];
    final bool correct = option == item.correctAnswer;
    setState(() {
      _selected = option;
    });
    if (correct) {
      await widget.controller.recordActivity('verb-lab', score: 100);
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'verb-${item.verb}-$_index',
          prompt: '${item.pronoun} (${item.verb} • ${item.tense})',
          correctAnswer: item.correctAnswer,
          givenAnswer: option,
          source: 'grammar',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      _items.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_index];
    return Scaffold(
      appBar: AppBar(title: Text('Verb Lab • ${widget.level.label}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text('Conjugate Verb: ${item.verb.toUpperCase()}', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text('${item.pronoun} [ ________ ]', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Tense: ${item.tense}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...item.options.map((opt) {
                final isSelected = _selected == opt;
                Color? bg;
                if (_selected != null) {
                  if (opt == item.correctAnswer) {
                    bg = Colors.green.withValues(alpha: 0.3);
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.3);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selected != null ? null : () => _choose(opt),
                    child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
              if (_selected != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(item.explanation, style: const TextStyle(fontSize: 13)),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next Verb'),
                ),
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cloze Fill-in-the-Blank Drill
// ---------------------------------------------------------------------------

class ClozeDrillScreen extends StatefulWidget {
  const ClozeDrillScreen({super.key, required this.controller, required this.level});

  final AppController controller;
  final CefrLevel level;

  @override
  State<ClozeDrillScreen> createState() => _ClozeDrillScreenState();
}

class _ClozeDrillScreenState extends State<ClozeDrillScreen> {
  final Random _random = Random();
  late List<ClozeItem> _items;
  int _index = 0;
  String? _targetWord;
  String? _clozeSentence;
  List<String> _options = <String>[];
  String? _selected;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    // The bank gaps the word each sentence teaches, and draws its wrong answers
    // from the same word class and level. The previous version blanked
    // whichever token happened to be longest and offered three random tokens
    // from any sentence, so a noun gap could be answered by eliminating "und"
    // and "ist" -- and it rebuilt that pool on every single question, which is
    // roughly ninety thousand token operations per item now the deck is large.
    _items = clozeFor(widget.level).toList()..shuffle(_random);
    _loadCurrent();
  }

  void _loadCurrent() {
    if (_items.isEmpty) return;
    final ClozeItem item = _items[_index];
    _targetWord = item.answer;
    _clozeSentence = item.gapped;
    _options = item.optionsFor(_index);
  }

  void _choose(String option) async {
    if (_selected != null) return;
    final bool correct = option == _targetWord;
    setState(() {
      _selected = option;
      _correct = correct;
    });
    if (correct) {
      await widget.controller.recordActivity('cloze-${widget.level.label}', score: 100);
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'cloze-${_items[_index].id}',
          prompt: _clozeSentence ?? '',
          correctAnswer: _targetWord ?? '',
          givenAnswer: option,
          source: 'dictation',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      _items.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _selected = null;
      _correct = null;
    });
    _loadCurrent();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cloze Drill')),
        body: const Center(child: Text('No cloze items for this level.')),
      );
    }

    final ClozeItem sentence = _items[_index];
    return Scaffold(
      appBar: AppBar(title: Text('Cloze Drill • ${widget.level.label}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      const Text('Fill in the missing word:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(
                        _clozeSentence ?? '',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(sentence.english, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ..._options.map((opt) {
                final isSelected = _selected == opt;
                Color? bg;
                if (_selected != null) {
                  if (opt == _targetWord) {
                    bg = Colors.green.withValues(alpha: 0.3);
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.3);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selected != null ? null : () => _choose(opt),
                    child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
              if (_selected != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _correct == true ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _correct == true ? 'Richtig! Full sentence: ${sentence.full}' : 'Incorrect. Correct word: $_targetWord\nFull sentence: ${sentence.full}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next Sentence'),
                ),
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TTS Shadowing & Speed Control Lab
// ---------------------------------------------------------------------------

class ShadowLabScreen extends StatefulWidget {
  const ShadowLabScreen({super.key, required this.controller, required this.level});

  final AppController controller;
  final CefrLevel level;

  @override
  State<ShadowLabScreen> createState() => _ShadowLabScreenState();
}

class _ShadowLabScreenState extends State<ShadowLabScreen> {
  final TtsService _tts = TtsService();
  final Random _random = Random();
  final TextEditingController _input = TextEditingController();
  late List<PracticeSentence> _sentences;
  int _index = 0;
  double _speed = 1.0;
  PronunciationResult? _result;

  @override
  void initState() {
    super.initState();
    _sentences = sentencesFor(widget.level).toList()..shuffle(_random);
  }

  @override
  void dispose() {
    _input.dispose();
    _tts.stop();
    super.dispose();
  }

  void _speak() {
    if (_sentences.isEmpty) return;
    _tts.speakGerman(_sentences[_index].german, rate: _speed);
  }

  void _evaluate() async {
    if (_sentences.isEmpty) return;
    final expected = _sentences[_index].german;
    final heard = _input.text.trim();
    final res = PronunciationScorer.compare(expected, heard);
    setState(() => _result = res);
    await widget.controller.recordActivity('shadow-${widget.level.label}', score: res.score);
  }

  void _next() {
    if (_index + 1 >= _sentences.length) {
      _sentences.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _input.clear();
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sentences.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shadowing Lab')),
        body: const Center(child: Text('No practice sentences available.')),
      );
    }

    final sentence = _sentences[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('Shadowing Lab • ${widget.level.label}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        sentence.german,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(sentence.english, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ChoiceChip(
                            label: const Text('0.75x Slow'),
                            selected: _speed == 0.75,
                            onSelected: (_) => setState(() => _speed = 0.75),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('1.0x Normal'),
                            selected: _speed == 1.0,
                            onSelected: (_) => setState(() => _speed = 1.0),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('1.25x Fast'),
                            selected: _speed == 1.25,
                            onSelected: (_) => setState(() => _speed = 1.25),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _speak,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('Listen to Model'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _input,
                decoration: const InputDecoration(
                  labelText: 'Repeat or shadow the sentence:',
                  hintText: 'Type what you hear...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _evaluate,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('Score Shadowing Attempt'),
              ),
              if (_result != null) ...<Widget>[
                const SizedBox(height: 20),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Score: ${_result!.score}% • ${_result!.stars}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(_result!.verdict),
                        const Divider(),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _result!.words.map((w) {
                            final color = w.isMatch
                                ? Colors.green
                                : w.isClose
                                    ? Colors.orange
                                    : Colors.red;
                            return Chip(
                              label: Text(w.expected),
                              backgroundColor: color.withValues(alpha: 0.2),
                              side: BorderSide(color: color),
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _next,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Next Sentence'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grammar Challenge Collections
// ---------------------------------------------------------------------------

/// Picker for the twelve corpus-derived collections in
/// `lib/grammar_challenge.dart`. Each is one confusion -- nominative vs.
/// accusative articles, haben vs. sein, im vs. ins -- rather than one
/// shuffled pile of every rule at once, so a learner can drill exactly the
/// mistake they keep making.
class GrammarChallengeHubScreen extends StatelessWidget {
  const GrammarChallengeHubScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar Challenges')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: GrammarFeature.values.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final GrammarFeature feature = GrammarFeature.values[index];
            final int count = challengesFor(feature).length;
            return Card(
              child: ListTile(
                title: Text(feature.label,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${feature.description}\n$count items'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: count == 0
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => GrammarChallengeDrillScreen(
                              controller: controller,
                              feature: feature,
                            ),
                          ),
                        ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class GrammarChallengeDrillScreen extends StatefulWidget {
  const GrammarChallengeDrillScreen(
      {super.key, required this.controller, required this.feature});

  final AppController controller;
  final GrammarFeature feature;

  @override
  State<GrammarChallengeDrillScreen> createState() =>
      _GrammarChallengeDrillScreenState();
}

class _GrammarChallengeDrillScreenState
    extends State<GrammarChallengeDrillScreen> {
  final Random _random = Random();
  late List<GrammarChallengeItem> _items;
  int _index = 0;
  String? _targetAnswer;
  String? _gapped;
  List<String> _options = <String>[];
  String? _selected;
  bool? _correct;

  @override
  void initState() {
    super.initState();
    _items = challengesFor(widget.feature).toList()..shuffle(_random);
    _loadCurrent();
  }

  void _loadCurrent() {
    if (_items.isEmpty) return;
    final GrammarChallengeItem item = _items[_index];
    _targetAnswer = item.answer;
    _gapped = item.gapped;
    _options = item.optionsFor(_index);
  }

  void _choose(String option) async {
    if (_selected != null) return;
    final bool correct = option == _targetAnswer;
    setState(() {
      _selected = option;
      _correct = correct;
    });
    if (correct) {
      await widget.controller.recordActivity(
          'grammar-challenge-${widget.feature.name}', score: 100);
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: 'gc-${_items[_index].id}',
          prompt: _gapped ?? '',
          correctAnswer: _targetAnswer ?? '',
          givenAnswer: option,
          source: 'grammar',
          level: _items[_index].level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _next() {
    if (_index + 1 >= _items.length) {
      _items.shuffle(_random);
      _index = 0;
    } else {
      _index += 1;
    }
    setState(() {
      _selected = null;
      _correct = null;
    });
    _loadCurrent();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.feature.label)),
        body: const Center(child: Text('No items for this feature yet.')),
      );
    }

    final GrammarChallengeItem item = _items[_index];
    return Scaffold(
      appBar: AppBar(title: Text(widget.feature.label)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.feature.description,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _gapped ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(item.english,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ..._options.map((opt) {
                final isSelected = _selected == opt;
                Color? bg;
                if (_selected != null) {
                  if (opt == _targetAnswer) {
                    bg = Colors.green.withValues(alpha: 0.3);
                  } else if (isSelected) {
                    bg = Colors.red.withValues(alpha: 0.3);
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _selected != null ? null : () => _choose(opt),
                    child: Text(opt,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
              if (_selected != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _correct == true
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _correct == true
                        ? 'Richtig! Full sentence: ${item.full}'
                        : 'Incorrect. Correct answer: $_targetAnswer\nFull sentence: ${item.full}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                ),
              ] else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
