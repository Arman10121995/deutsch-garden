import 'package:flutter/material.dart';

import 'app_state.dart';
import 'gender_guide.dart';
import 'models.dart';
import 'sentence_audio.dart';
import 'tts_service.dart';
import 'vocab_icon.dart';
import 'vocabulary.dart';
import 'vocabulary_metadata.dart';
import 'word_class_guide.dart';
import 'compound_breakdown.dart';
import 'preposition_visual.dart';
import 'separable_verb_animation.dart';

/// The searchable, all-level reference library.
///
/// This belongs to Explore rather than Profile: it is learning content, not
/// account state. Keeping it in its own file also prevents the app shell from
/// depending on every vocabulary-library implementation detail.
class VocabularyLibraryScreen extends StatefulWidget {
  const VocabularyLibraryScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<VocabularyLibraryScreen> createState() =>
      _VocabularyLibraryScreenState();
}

class _VocabularyLibraryScreenState extends State<VocabularyLibraryScreen> {
  final TextEditingController _search = TextEditingController();
  final TtsService _tts = TtsService();
  String _category = 'All';
  String _level = 'All';
  String _wordClass = 'All';
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    widget.controller.beginStudyActivity('Vocabulary library');
  }

  @override
  void dispose() {
    widget.controller.endStudyActivity('Vocabulary library');
    _search.dispose();
    _tts.stop();
    super.dispose();
  }

  List<GermanWord> _filtered() {
    final String query = _search.text.trim().toLowerCase();
    return vocabulary
        .where((GermanWord word) {
          final bool textMatch =
              query.isEmpty ||
              word.german.toLowerCase().contains(query) ||
              word.english.toLowerCase().contains(query) ||
              word.plural.toLowerCase().contains(query);
          final bool categoryMatch =
              _category == 'All' || word.category == _category;
          final bool levelMatch = _level == 'All' || word.level == _level;
          final bool wordClassMatch =
              _wordClass == 'All' || word.wordClass.label == _wordClass;
          final bool favoriteMatch =
              !_favoritesOnly ||
              (widget.controller.progress[word.id]?.favorite ?? false);
          return textMatch &&
              categoryMatch &&
              levelMatch &&
              wordClassMatch &&
              favoriteMatch;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories =
        <String>{
          'All',
          ...vocabulary.map((GermanWord word) => word.category),
        }.toList()..sort((String a, String b) {
          if (a == 'All') return -1;
          if (b == 'All') return 1;
          return a.compareTo(b);
        });
    final List<GermanWord> words = _filtered();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary library'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Word-class guide',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const WordClassGuideScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Der, die, das ending guide',
            icon: const Icon(Icons.abc_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const GenderGuideScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (BuildContext context, Widget? child) => Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${vocabulary.length} bundled words · A1 to C2'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search German, English or plural',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          DropdownButton<String>(
                            value: _level,
                            items:
                                <String>[
                                  'All',
                                  ...CefrLevel.values.map(
                                    (CefrLevel level) => level.label,
                                  ),
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value == 'All' ? 'All levels' : value,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? value) =>
                                setState(() => _level = value ?? 'All'),
                          ),
                          const SizedBox(width: 14),
                          DropdownButton<String>(
                            value: _wordClass,
                            items:
                                <String>[
                                  'All',
                                  ...GermanWordClass.values.map(
                                    (GermanWordClass value) => value.label,
                                  ),
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value == 'All'
                                          ? 'All word classes'
                                          : value,
                                    ),
                                  );
                                }).toList(),
                            onChanged: (String? value) =>
                                setState(() => _wordClass = value ?? 'All'),
                          ),
                          const SizedBox(width: 14),
                          DropdownButton<String>(
                            value: _category,
                            items: categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? value) =>
                                setState(() => _category = value ?? 'All'),
                          ),
                          const SizedBox(width: 12),
                          FilterChip(
                            label: const Text('Favorites'),
                            selected: _favoritesOnly,
                            onSelected: (bool value) =>
                                setState(() => _favoritesOnly = value),
                          ),
                        ],
                      ),
                    ),
                    Text('${words.length} words'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  itemCount: words.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (BuildContext context, int index) =>
                      _wordTile(context, words[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wordTile(BuildContext context, GermanWord word) {
    final WordProgress progress =
        widget.controller.progress[word.id] ?? WordProgress();
    return Card(
      key: ValueKey<String>('word-${word.id}'),
      child: ExpansionTile(
        leading: VocabVisual(word: word, size: 44),
        title: Text(
          word.displayGerman,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${word.english} · ${word.level} · ${word.wordClass.label} · '
          '${word.category}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              label: progress.masteryLabel,
              child: ExcludeSemantics(
                child: Text(
                  progress.plantIcon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            IconButton(
              tooltip: progress.favorite
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              onPressed: () => widget.controller.toggleFavorite(word.id),
              icon: Icon(progress.favorite ? Icons.star : Icons.star_border),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: WordClassChip(word: word),
          ),
          if (word.nounGender != null) ...<Widget>[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                word.genderEndingComment,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  word.plural == '—' || word.plural.isEmpty
                      ? 'Lexical item'
                      : 'Plural: ${word.plural}',
                ),
              ),
              IconButton(
                tooltip: 'Hear this word in German',
                onPressed: widget.controller.ttsEnabled
                    ? () => _tts.speakGerman(word.displayGerman)
                    : null,
                icon: const Icon(Icons.volume_up_rounded),
              ),
            ],
          ),
          SpeakableSentence(
            text: word.exampleGerman,
            enabled: widget.controller.ttsEnabled,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(word.exampleEnglish),
          ),
          if (hasCompoundBreakdown(word)) ...<Widget>[
            const SizedBox(height: 14),
            CompoundBreakdown(word: word),
          ],
          if (twoWayPrepositionFor(word.german) != null) ...<Widget>[
            const SizedBox(height: 16),
            PrepositionDiagram(preposition: twoWayPrepositionFor(word.german)!),
          ],
          if (isSeparableVerb(word)) ...<Widget>[
            const SizedBox(height: 16),
            SeparableVerbAnimation(word: word),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: LinearProgressIndicator(value: progress.mastery / 5),
              ),
              const SizedBox(width: 12),
              Text('Mastery ${progress.mastery}/5'),
            ],
          ),
        ],
      ),
    );
  }
}
