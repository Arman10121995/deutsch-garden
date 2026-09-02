/// The little drawing beside a vocabulary card.
///
/// A curated set of nouns, actions and properties have a semantic picture.
/// That is not a promise to illustrate every abstraction:
/// *Verantwortung* and *Gelegenheit* cannot be drawn unambiguously, and an icon
/// that means nothing in particular is worse than no icon.
///
/// The drawings are original SVG authored for this app rather than sourced
/// photographs. Wikimedia's pictures of everyday objects are overwhelmingly
/// CC-BY-SA, and share-alike assets inside an MIT application are a compliance
/// burden with no upside — see `docs/VOCAB_ICONS.md`. A drawing also costs
/// about 1.2 KB instead of 20 and stays sharp at any size.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models.dart';
import 'moving_pictogram.dart';
import 'vocab_motion.dart';
import 'vocabulary_metadata.dart';
import 'vocab_emoji.dart';

/// Ids that have an icon on disk.
///
/// Populated once at startup by [loadVocabIconIndex]. Checking a set is what
/// lets the widget decide *before* building whether there is anything to show,
/// instead of every card without a drawing rendering an error placeholder.
final Set<String> _available = <String>{};

/// Ids that have a line icon rather than a drawing.
///
/// Verbs and adjectives are not things, and drawing "to arrive" as a scene
/// invents a story the word does not tell. A pictogram is the honest form for
/// them, and redrawing a pictogram vocabulary that already exists under MIT
/// would be work for its own sake -- see assets/vocab_line/LICENSE-tabler.txt.
final Set<String> _availableLine = <String>{};
Future<void>? _loadFuture;

/// Original AI-assisted illustrations generated specifically for
/// DeutschGarden, keyed by the exact German lemma they depict.
///
/// Lemma keys deliberately let one honest picture serve duplicate cards whose
/// stable ids differ. Only concrete actions with an unambiguous scene belong
/// here; abstract words continue to use the structural visual below.
const Map<String, String> generatedVocabIllustrations = <String, String>{
  'gehen': 'assets/vocab_generated/gehen.png',
  'laufen': 'assets/vocab_generated/laufen.png',
  'springen': 'assets/vocab_generated/springen.png',
  'schwimmen': 'assets/vocab_generated/schwimmen.png',
  'schlafen': 'assets/vocab_generated/schlafen.png',
  'kochen': 'assets/vocab_generated/kochen.png',
  'lesen': 'assets/vocab_generated/lesen.png',
  'schreiben': 'assets/vocab_generated/schreiben.png',
  'trinken': 'assets/vocab_generated/trinken.png',
  'öffnen': 'assets/vocab_generated/öffnen.png',
  'schließen': 'assets/vocab_generated/schließen.png',
  'sitzen': 'assets/vocab_generated/sitzen.png',
  'stehen': 'assets/vocab_generated/stehen.png',
  'tragen': 'assets/vocab_generated/tragen.png',
  'werfen': 'assets/vocab_generated/werfen.png',
  'lachen': 'assets/vocab_generated/lachen.png',
  'kaufen': 'assets/vocab_generated/kaufen.png',
  'bezahlen': 'assets/vocab_generated/bezahlen.png',
  'fragen': 'assets/vocab_generated/fragen.png',
  'antworten': 'assets/vocab_generated/antworten.png',
  'helfen': 'assets/vocab_generated/helfen.png',
  'warten': 'assets/vocab_generated/warten.png',
  'suchen': 'assets/vocab_generated/suchen.png',
  'finden': 'assets/vocab_generated/finden.png',
  'reisen': 'assets/vocab_generated/reisen.png',
  'telefonieren': 'assets/vocab_generated/telefonieren.png',
  'lernen': 'assets/vocab_generated/lernen.png',
  'arbeiten': 'assets/vocab_generated/arbeiten.png',
  'feiern': 'assets/vocab_generated/feiern.png',
  'treffen': 'assets/vocab_generated/treffen.png',
  'krank': 'assets/vocab_generated/krank.png',
  'gesund': 'assets/vocab_generated/gesund.png',
};

String? generatedVocabIllustrationFor(GermanWord word) =>
    generatedVocabIllustrations[word.german.trim().toLowerCase()];

bool hasGeneratedVocabIllustration(GermanWord word) =>
    generatedVocabIllustrationFor(word) != null;

/// Whether [word] has a drawing.
bool hasVocabIcon(GermanWord word) => _available.contains(word.id);

/// Whether [word] has a line pictogram.
bool hasVocabLineIcon(GermanWord word) => _availableLine.contains(word.id);

/// Whether this card has an emoji standing in for a drawing.
///
/// The third and cheapest tier. See tool/build_vocab_emoji.py: these come
/// from Unicode's own German annotation set, cost no bundle bytes and carry
/// no licence, and they exist for cards nobody has drawn and probably never
/// will -- a B2 learner meeting *Nashorn* gets a rhinoceros instead of a
/// coloured rectangle saying "noun".
bool hasVocabEmoji(GermanWord word) => vocabEmoji.containsKey(word.id);

/// The emoji for a card, or empty.
String vocabEmojiFor(GermanWord word) => vocabEmoji[word.id] ?? '';

/// Whether [word] has any bundled image at all.
bool hasAnyVocabImage(GermanWord word) =>
    hasGeneratedVocabIllustration(word) ||
    hasVocabIcon(word) ||
    hasVocabLineIcon(word) ||
    hasVocabEmoji(word);

/// Read the manifest once and remember which icons exist.
///
/// The alternative — trying to load each icon and catching the failure — turns
/// a missing file into an exception per card per frame, which is expensive and
/// noisy for the 90% of the deck that will never have a drawing.
Future<void> loadVocabIconIndex(AssetBundle bundle) =>
    _loadFuture ??= _loadVocabIconIndex(bundle);

Future<void> _loadVocabIconIndex(AssetBundle bundle) async {
  try {
    // AssetManifest.json was removed from non-web Flutter builds and replaced
    // by AssetManifest.bin (AssetManifest.bin.json on web). The framework API
    // selects and decodes the correct representation on every platform.
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      bundle,
    );
    // The id is the whole file name, whatever shape it has. Matching a
    // narrower pattern here is how 368 of the 478 drawings went missing once
    // already: the ids are a mix of `001` and `x10743`, and a digits-only
    // pattern silently kept the first kind and dropped the second.
    final RegExp entry = RegExp(r'^assets/vocab/([^/]+)\.svg$');
    final RegExp line = RegExp(r'^assets/vocab_line/([^/]+)\.svg$');
    for (final String asset in manifest.listAssets()) {
      final RegExpMatch? match = entry.firstMatch(asset);
      if (match != null) {
        _available.add(match.group(1)!);
        continue;
      }
      final RegExpMatch? lineMatch = line.firstMatch(asset);
      if (lineMatch != null) _availableLine.add(lineMatch.group(1)!);
    }
  } catch (_) {
    // No manifest, no icons. The app is fully usable without them.
  }
}

@visibleForTesting
void debugSetVocabIcons(Iterable<String> ids, {Iterable<String>? lineIds}) {
  _loadFuture = Future<void>.value();
  _available
    ..clear()
    ..addAll(ids);
  _availableLine
    ..clear()
    ..addAll(lineIds ?? const <String>[]);
}

@visibleForTesting
void debugResetVocabIcons() {
  _loadFuture = null;
  _available.clear();
  _availableLine.clear();
}

/// The drawing for [word], or nothing at all.
///
/// Returns a zero-size box rather than a placeholder when there is no icon:
/// a grey square next to every abstract noun would be a worse page than one
/// with no pictures on it.
class VocabIcon extends StatelessWidget {
  const VocabIcon({super.key, required this.word, this.size = 44});

  final GermanWord word;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String? generated = generatedVocabIllustrationFor(word);
    if (generated != null) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.18),
          child: Image.asset(
            generated,
            width: size,
            height: size,
            fit: BoxFit.cover,
            semanticLabel: word.english,
          ),
        ),
      );
    }
    if (!hasVocabIcon(word)) {
      if (hasVocabLineIcon(word)) {
        // Line icons carry no colour of their own -- they are strokes in
        // currentColor -- so they take the text colour and sit correctly on
        // either theme without a second copy.
        return SizedBox(
          width: size,
          height: size,
          child: MovingPictogram(
            motion: vocabMotions[word.id] ?? VocabMotion.none,
            size: size,
            child: SvgPicture.asset(
              'assets/vocab_line/${word.id}.svg',
              width: size,
              height: size,
              colorFilter: ColorFilter.mode(
                DefaultTextStyle.of(context).style.color ??
                    Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
              semanticsLabel: word.english,
            ),
          ),
        );
      }
      if (hasVocabEmoji(word)) {
        // Drawn by the device's own font, so there is nothing to ship and
        // nothing to attribute. Sized to the same box as an icon so a list
        // of mixed tiers still lines up.
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              vocabEmojiFor(word),
              // 0.8 rather than the full box: an emoji glyph carries its own
              // padding, and matching the nominal size makes it read larger
              // than the SVGs beside it.
              style: TextStyle(fontSize: size * 0.8),
              semanticsLabel: word.english,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/vocab/${word.id}.svg',
        width: size,
        height: size,
        // The drawings carry their own colours, so no tint is applied. They
        // are legible on both themes because every palette entry was picked
        // to be — a white fridge gets a dark outline for exactly this reason.
        semanticsLabel: word.english,
      ),
    );
  }
}

/// A visual is available for every card.
///
/// Reviewed words keep their authored semantic drawing. Everything
/// else receives a deliberately structural vector tile: category pictogram,
/// part of speech, and noun article colour where applicable. That is more
/// honest than pretending an arbitrary stock picture depicts an abstract verb
/// or conjunction, while still giving every card a distinct visual anchor.
class VocabVisual extends StatelessWidget {
  const VocabVisual({
    super.key,
    required this.word,
    this.size = 44,
    this.revealGrammar = true,
  });

  final GermanWord word;
  final double size;
  final bool revealGrammar;

  @override
  Widget build(BuildContext context) {
    if (hasAnyVocabImage(word)) return VocabIcon(word: word, size: size);

    final GermanWordClass wordClass = word.wordClass;
    final Color accent = _accentFor(context, word, revealGender: revealGrammar);
    return Semantics(
      image: true,
      label: '${word.english}; ${word.grammarLabel}',
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            border: Border.all(color: accent.withValues(alpha: 0.55)),
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                _categoryIcon(word.category, wordClass),
                color: accent,
                size: size * 0.43,
              ),
              Positioned(
                left: size * 0.06,
                right: size * 0.06,
                bottom: size * 0.035,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    wordClass.shortLabel,
                    style: TextStyle(
                      color: accent,
                      fontSize: size * 0.16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              if (revealGrammar && word.article.isNotEmpty)
                Positioned(
                  right: size * 0.04,
                  top: size * 0.04,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size * 0.06,
                      vertical: size * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: word.genderColor(Theme.of(context).brightness),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      word.article,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WordClassChip extends StatelessWidget {
  const WordClassChip({super.key, required this.word});

  final GermanWord word;

  @override
  Widget build(BuildContext context) {
    final Color accent = _accentFor(context, word);
    return Tooltip(
      message: word.wordClass.learningNote,
      child: Chip(
        avatar: Icon(_wordClassIcon(word.wordClass), size: 17, color: accent),
        label: Text(word.grammarLabel),
        side: BorderSide(color: accent.withValues(alpha: 0.45)),
        backgroundColor: accent.withValues(alpha: 0.10),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

Color _accentFor(
  BuildContext context,
  GermanWord word, {
  bool revealGender = true,
}) {
  if (revealGender && word.article.isNotEmpty) {
    return word.genderColor(Theme.of(context).brightness);
  }
  switch (word.wordClass) {
    case GermanWordClass.noun:
      return const Color(0xFF546E7A);
    case GermanWordClass.verb:
      return const Color(0xFFEF6C00);
    case GermanWordClass.adjective:
      return const Color(0xFF7B1FA2);
    case GermanWordClass.adjectiveAdverb:
      return const Color(0xFF6A1B9A);
    case GermanWordClass.adverb:
      return const Color(0xFF00897B);
    case GermanWordClass.pronoun:
      return const Color(0xFF1976D2);
    case GermanWordClass.preposition:
      return const Color(0xFF795548);
    case GermanWordClass.conjunction:
      return const Color(0xFF3949AB);
    case GermanWordClass.number:
      return const Color(0xFF388E3C);
    case GermanWordClass.expression:
      return const Color(0xFFC2185B);
    case GermanWordClass.other:
      return Theme.of(context).colorScheme.outline;
  }
}

IconData _wordClassIcon(GermanWordClass wordClass) {
  switch (wordClass) {
    case GermanWordClass.noun:
      return Icons.inventory_2_outlined;
    case GermanWordClass.verb:
      return Icons.directions_run_rounded;
    case GermanWordClass.adjective:
      return Icons.palette_outlined;
    case GermanWordClass.adjectiveAdverb:
      return Icons.compare_rounded;
    case GermanWordClass.adverb:
      return Icons.speed_rounded;
    case GermanWordClass.pronoun:
      return Icons.person_outline_rounded;
    case GermanWordClass.preposition:
      return Icons.compare_arrows_rounded;
    case GermanWordClass.conjunction:
      return Icons.link_rounded;
    case GermanWordClass.number:
      return Icons.numbers_rounded;
    case GermanWordClass.expression:
      return Icons.format_quote_rounded;
    case GermanWordClass.other:
      return Icons.text_fields_rounded;
  }
}

IconData _categoryIcon(String category, GermanWordClass wordClass) {
  final String value = category.toLowerCase();
  if (value.contains('food')) return Icons.restaurant_rounded;
  if (value.contains('travel') || value.contains('transport')) {
    return Icons.directions_transit_rounded;
  }
  if (value.contains('home') || value.contains('housing')) {
    return Icons.home_rounded;
  }
  if (value.contains('work') || value.contains('business')) {
    return Icons.work_outline_rounded;
  }
  if (value.contains('health') || value.contains('body')) {
    return Icons.health_and_safety_outlined;
  }
  if (value.contains('nature') || value.contains('environment')) {
    return Icons.park_outlined;
  }
  if (value.contains('people') || value.contains('family')) {
    return Icons.people_outline_rounded;
  }
  if (value.contains('education') || value.contains('academic')) {
    return Icons.school_outlined;
  }
  if (value.contains('communication') || value.contains('media')) {
    return Icons.chat_bubble_outline_rounded;
  }
  if (value.contains('time')) return Icons.schedule_rounded;
  if (value.contains('technology')) return Icons.devices_rounded;
  if (value.contains('law') ||
      value.contains('politic') ||
      value.contains('administration')) {
    return Icons.account_balance_outlined;
  }
  return _wordClassIcon(wordClass);
}
