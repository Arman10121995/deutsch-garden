import 'package:flutter/material.dart';

import 'app_state.dart';
import 'mini_story.dart';
import 'mini_story_screens.dart';
import 'models.dart';
import 'pronunciation.dart';
import 'sentence_audio.dart';
import 'stories.dart';
import 'tts_service.dart';
import 'vocabulary.dart';
import 'dart:math';
import 'answer_shuffle.dart';

/// Library of graded readers, grouped by CEFR level.
class StoryLibraryScreen extends StatefulWidget {
  const StoryLibraryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<StoryLibraryScreen> createState() => _StoryLibraryScreenState();
}

class _StoryLibraryScreenState extends State<StoryLibraryScreen> {
  CefrLevel? _level;

  CefrLevel get _selected => _level ?? widget.controller.highestUnlockedLevel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final CefrLevel level = _selected;
          final List<Story> list = storiesFor(level);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            children: <Widget>[
              Text(
                'Geschichten',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${stories.length} graded stories • tap any word to look it up '
                'and send it to your review deck.',
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: CefrLevel.values.map((value) {
                    final bool unlocked = widget.controller.isLevelUnlocked(
                      value,
                    );
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
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: widget.controller.storyProgress(level),
                minHeight: 8,
                borderRadius: BorderRadius.circular(99),
              ),
              const SizedBox(height: 6),
              Text(
                '${(widget.controller.storyProgress(level) * 100).round()}% of '
                '${level.label} chapters finished',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              if (list.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('No stories bundled for this level yet.'),
                  ),
                ),
              ...list.map((story) => _storyCard(context, story)),
            ],
          );
        },
      ),
    );
  }

  Widget _storyCard(BuildContext context, Story story) {
    final int done = story.chapters
        .where((chapter) => widget.controller.isChapterDone(chapter.id))
        .length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => StoryDetailScreen(
                controller: widget.controller,
                story: story,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(story.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        story.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        story.blurb,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: story.chapters.isEmpty
                            ? 0
                            : done / story.chapters.length,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$done/${story.chapters.length} chapters • '
                        '${story.wordCount} words • ~${story.minutes} min',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({
    super.key,
    required this.controller,
    required this.story,
  });

  final AppController controller;
  final Story story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${story.emoji} ${story.title}')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: <Widget>[
            Text(
              story.titleEnglish,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(story.blurb),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                leading: const Icon(Icons.record_voice_over_rounded),
                title: const Text(
                  'Mini-story drill',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Listen · read · 15 circling questions · retell',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => MiniStoryDrillScreen(
                      controller: controller,
                      drill: miniStoryFor(story),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...story.chapters.asMap().entries.map((entry) {
              final int index = entry.key;
              final StoryChapter chapter = entry.value;
              final bool done = controller.isChapterDone(chapter.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: done
                          ? const Icon(Icons.check_rounded)
                          : Text('${index + 1}'),
                    ),
                    title: Text(
                      chapter.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${chapter.titleEnglish} • ${chapter.wordCount} words',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => StoryReaderScreen(
                          controller: controller,
                          story: story,
                          chapterIndex: index,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// The reader itself: German text, optional parallel translation, tap-a-word
/// lookup and a listen-through button.
class StoryReaderScreen extends StatefulWidget {
  const StoryReaderScreen({
    super.key,
    required this.controller,
    required this.story,
    required this.chapterIndex,
  });

  final AppController controller;
  final Story story;
  final int chapterIndex;

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final TtsService _tts = TtsService();
  late bool _parallel;
  double _fontSize = 17;

  StoryChapter get _chapter => widget.story.chapters[widget.chapterIndex];

  @override
  void initState() {
    super.initState();
    _parallel = !widget.controller.immersionMode;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _listenAll() async {
    await _tts.speakGerman(_chapter.lines.map((line) => line.german).join(' '));
  }

  Future<void> _addToDeck(GermanWord word) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    await widget.controller.markSeen(word);
    if (!(widget.controller.progress[word.id]?.favorite ?? false)) {
      await widget.controller.toggleFavorite(word.id);
    }
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text('${word.displayGerman} added to your review deck'),
      ),
    );
  }

  StoryGloss? _findGloss(String normalized) {
    for (final StoryGloss candidate in _chapter.glossary) {
      final String glossNormal = PronunciationScorer.normalize(
        candidate.german,
      );
      if (glossNormal == normalized || glossNormal.contains(normalized)) {
        return candidate;
      }
    }
    return null;
  }

  GermanWord? _findWord(String normalized) {
    for (final GermanWord word in vocabulary) {
      if (PronunciationScorer.normalize(word.german) == normalized) return word;
    }
    return null;
  }

  void _lookUp(String rawWord) {
    final String cleaned = rawWord.replaceAll(
      RegExp(r'^[^A-Za-zÄÖÜäöüß]+|[^A-Za-zÄÖÜäöüß]+$'),
      '',
    );
    if (cleaned.isEmpty) return;
    final String normalized = PronunciationScorer.normalize(cleaned);

    final StoryGloss? gloss = _findGloss(normalized);
    final GermanWord? match = _findWord(normalized);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    match?.displayGerman ?? cleaned,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Read this passage aloud in German',
                  onPressed: () => _tts.speakGerman(cleaned),
                  icon: const Icon(Icons.volume_up_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (gloss != null) ...<Widget>[
              Text(gloss.english, style: const TextStyle(fontSize: 16)),
              if (gloss.note.isNotEmpty) ...<Widget>[
                const SizedBox(height: 6),
                Text(gloss.note, style: Theme.of(context).textTheme.bodySmall),
              ],
            ] else if (match != null) ...<Widget>[
              Text(match.english, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              SpeakableSentence(
                text: match.exampleGerman,
                enabled: widget.controller.ttsEnabled,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ] else
              const Text(
                'Not in this chapter\'s glossary. Inflected forms often differ '
                'from the dictionary entry — try the base form in the word list.',
              ),
            const SizedBox(height: 18),
            if (match != null)
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _addToDeck(match);
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Add to my review deck'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final StoryChapter chapter = _chapter;
    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
        actions: <Widget>[
          IconButton(
            tooltip: _parallel ? 'German only' : 'Show translation',
            onPressed: () => setState(() => _parallel = !_parallel),
            icon: Icon(
              _parallel ? Icons.translate_rounded : Icons.translate_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Listen to the chapter',
            onPressed: widget.controller.ttsEnabled ? _listenAll : null,
            icon: const Icon(Icons.headphones_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Aa', style: Theme.of(context).textTheme.labelLarge),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 14,
                  max: 26,
                  divisions: 6,
                  label: _fontSize.round().toString(),
                  onChanged: (value) => setState(() => _fontSize = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...chapter.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    children: line.german.split(' ').map((token) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _lookUp(token),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          child: Text(
                            token,
                            style: TextStyle(fontSize: _fontSize, height: 1.45),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_parallel) ...<Widget>[
                    const SizedBox(height: 3),
                    Text(
                      line.english,
                      style: TextStyle(
                        fontSize: _fontSize - 3,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Glossar',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  ...chapter.glossary.map(
                    (gloss) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(
                              gloss.german,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(flex: 5, child: Text(gloss.english)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => StoryQuizScreen(
                  controller: widget.controller,
                  chapter: chapter,
                  level: widget.story.level,
                ),
              ),
            ),
            icon: const Icon(Icons.quiz_outlined),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Comprehension check'),
            ),
          ),
        ],
      ),
    );
  }
}

class StoryQuizScreen extends StatefulWidget {
  const StoryQuizScreen({
    super.key,
    required this.controller,
    required this.chapter,
    required this.level,
  });

  final AppController controller;
  final StoryChapter chapter;
  final CefrLevel level;

  @override
  State<StoryQuizScreen> createState() => _StoryQuizScreenState();
}

class _StoryQuizScreenState extends State<StoryQuizScreen> {
  int _index = 0;
  int _correct = 0;
  int? _picked;
  bool _done = false;


  /// Fixed once per sitting, so the option order is stable while a question is
  /// on screen and different next time. See lib/answer_shuffle.dart.
  final int _shuffleSalt = Random().nextInt(0x7fffffff);

  ChoiceQuestion get _question {
    final ChoiceQuestion raw = widget.chapter.questions[_index];
    return raw.shuffled(seededFor(raw.prompt, _shuffleSalt));
  }

  Future<void> _pick(int index) async {
    if (_picked != null) return;
    setState(() => _picked = index);
    final bool right = index == _question.correctIndex;
    if (right) {
      _correct += 1;
    } else {
      await widget.controller.addMistake(
        MistakeEntry(
          id: '${widget.chapter.id}-q$_index',
          prompt: _question.prompt,
          correctAnswer: _question.options[_question.correctIndex],
          givenAnswer: _question.options[index],
          source: 'story',
          level: widget.level.label,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _next() async {
    if (_index + 1 >= widget.chapter.questions.length) {
      final int score = widget.chapter.questions.isEmpty
          ? 0
          : ((_correct / widget.chapter.questions.length) * 100).round();
      await widget.controller.recordStoryChapter(
        widget.chapter.id,
        score: score,
      );
      if (!mounted) return;
      setState(() => _done = true);
      return;
    }
    setState(() {
      _index += 1;
      _picked = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chapter.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapter.title)),
        body: const Center(child: Text('No questions for this chapter.')),
      );
    }
    if (_done) {
      final int score = ((_correct / widget.chapter.questions.length) * 100)
          .round();
      return Scaffold(
        appBar: AppBar(title: Text(widget.chapter.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  score >= 70 ? '🎉' : '📖',
                  style: const TextStyle(fontSize: 54),
                ),
                const SizedBox(height: 12),
                Text(
                  '$score%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text('$_correct of ${widget.chapter.questions.length} correct'),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to the story'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ChoiceQuestion question = _question;
    final int? picked = _picked;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / widget.chapter.questions.length,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: <Widget>[
          Text(
            question.prompt,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          ...question.options.asMap().entries.map((entry) {
            final bool isCorrect = entry.key == question.correctIndex;
            final bool isPicked = picked == entry.key;
            Color? background;
            if (picked != null && isCorrect) {
              background = Theme.of(context).colorScheme.tertiaryContainer;
            } else if (isPicked) {
              background = Theme.of(context).colorScheme.errorContainer;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(backgroundColor: background),
                onPressed: picked == null ? () => _pick(entry.key) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          }),
          if (picked != null) ...<Widget>[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(question.explanation),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _next,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _index + 1 >= widget.chapter.questions.length
                      ? 'Finish'
                      : 'Next question',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
