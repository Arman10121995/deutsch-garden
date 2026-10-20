import 'package:flutter/material.dart';

import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'curriculum_text.dart';
import 'gender_guide.dart';
import 'models.dart';
import 'sentence_audio.dart';
import 'tts_service.dart';
import 'vocab_icon.dart';
import 'vocabulary.dart';
import 'vocabulary_metadata.dart';
import 'vocabulary_text.dart';
import 'vocabulary_search.dart';
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

  bool get _hasFilters =>
      _search.text.isNotEmpty ||
      _category != 'All' ||
      _level != 'All' ||
      _wordClass != 'All' ||
      _favoritesOnly;

  void _resetFilters() => setState(() {
    _search.clear();
    _category = _level = _wordClass = 'All';
    _favoritesOnly = false;
  });

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
    final String query = _search.text;
    return vocabulary
        .where((GermanWord word) {
          final bool textMatch = vocabularyMatchesQuery(
            word,
            query,
            meaning: widget.controller.meaningOf(word),
          );
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
    final AppText text = AppText.of(context);
    final List<String> categories =
        <String>{
          'All',
          ...vocabulary.map((GermanWord word) => word.category),
        }.toList()..sort((String a, String b) {
          if (a == 'All') return -1;
          if (b == 'All') return 1;
          return a.compareTo(b);
        });

    return Scaffold(
      appBar: AppBar(
        title: Text(text.vocabularyLibrary),
        actions: <Widget>[
          IconButton(
            tooltip: text.wordClassGuide,
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const WordClassGuideScreen(),
              ),
            ),
          ),
          IconButton(
            tooltip: text.genderEndingGuide,
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
          builder: (BuildContext context, Widget? child) {
            // Controller changes (favorites, mastery and gloss language) must
            // recalculate the results, not rebuild a captured stale list.
            final List<GermanWord> words = _filtered();
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(text.bundledWordCount(vocabulary.length)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: text.vocabularySearchHint,
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: text.clearSearch,
                                  onPressed: () => setState(_search.clear),
                                  icon: const Icon(Icons.clear),
                                ),
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
                                        value == 'All' ? text.allLevels : value,
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
                                            ? text.allWordClasses
                                            : curriculumText(text, value),
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
                                  child: Text(
                                    value == 'All' ? text.allCategories : value,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) =>
                                  setState(() => _category = value ?? 'All'),
                            ),
                            const SizedBox(width: 12),
                            FilterChip(
                              label: Text(text.favorites),
                              selected: _favoritesOnly,
                              onSelected: (bool value) =>
                                  setState(() => _favoritesOnly = value),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(text.wordResultCount(words.length)),
                          ),
                          if (_hasFilters)
                            Flexible(
                              child: TextButton.icon(
                                onPressed: _resetFilters,
                                icon: const Icon(Icons.filter_alt_off_outlined),
                                label: Text(text.resetFilters),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: words.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(Icons.search_off, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  text.noVocabularyResults,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  text.vocabularySearchHelp,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                          itemCount: words.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 6),
                          itemBuilder: (BuildContext context, int index) =>
                              _wordTile(context, words[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _wordTile(BuildContext context, GermanWord word) {
    final AppText text = AppText.of(context);
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
          <String>[
            widget.controller.meaningOf(word),
            word.level,
            curriculumText(AppText.of(context), word.wordClass.label),
            word.category,
          ].join(' · '),
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
                  ? text.removeFavorite
                  : text.addFavorite,
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
                genderEndingText(AppText.of(context), word),
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
                      ? text.lexicalItem
                      : text.wordPlural(word.plural),
                ),
              ),
              IconButton(
                tooltip: text.hearWord,
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
              Text(text.wordMastery(progress.mastery)),
            ],
          ),
        ],
      ),
    );
  }
}
