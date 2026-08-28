/// The little drawing beside a vocabulary card.
///
/// Only the concrete A1–A2 nouns have one. That is not a gap waiting to be
/// filled: *Verantwortung* and *Gelegenheit* cannot be drawn by anyone, and an
/// icon that means nothing in particular is worse than no icon, because the
/// learner spends attention decoding it and gets nothing back.
///
/// The drawings are original SVG authored for this app rather than sourced
/// photographs. Wikimedia's pictures of everyday objects are overwhelmingly
/// CC-BY-SA, and share-alike assets inside an MIT application are a compliance
/// burden with no upside — see `docs/VOCAB_ICONS.md`. A drawing also costs
/// about 1.2 KB instead of 20 and stays sharp at any size.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models.dart';

/// Ids that have an icon on disk.
///
/// Populated once at startup by [loadVocabIconIndex]. Checking a set is what
/// lets the widget decide *before* building whether there is anything to show,
/// instead of every card without a drawing rendering an error placeholder.
final Set<String> _available = <String>{};
bool _indexLoaded = false;

/// Whether [word] has a drawing.
bool hasVocabIcon(GermanWord word) => _available.contains(word.id);

/// Read the manifest once and remember which icons exist.
///
/// The alternative — trying to load each icon and catching the failure — turns
/// a missing file into an exception per card per frame, which is expensive and
/// noisy for the 90% of the deck that will never have a drawing.
Future<void> loadVocabIconIndex(AssetBundle bundle) async {
  if (_indexLoaded) return;
  _indexLoaded = true;
  try {
    final String manifest = await bundle.loadString('AssetManifest.json');
    final RegExp entry = RegExp(r'assets/vocab/(\d+)\.svg');
    for (final RegExpMatch match in entry.allMatches(manifest)) {
      _available.add(match.group(1)!);
    }
  } catch (_) {
    // No manifest, no icons. The app is fully usable without them.
  }
}

@visibleForTesting
void debugSetVocabIcons(Iterable<String> ids) {
  _indexLoaded = true;
  _available
    ..clear()
    ..addAll(ids);
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
    if (!hasVocabIcon(word)) return const SizedBox.shrink();
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
