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
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models.dart';

/// Ids that have an icon on disk.
///
/// Populated once at startup by [loadVocabIconIndex]. Checking a set is what
/// lets the widget decide *before* building whether there is anything to show,
/// instead of every card without a drawing rendering an error placeholder.
final Set<String> _available = <String>{};
Future<void>? _loadFuture;

/// Whether [word] has a drawing.
bool hasVocabIcon(GermanWord word) => _available.contains(word.id);

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
    for (final String asset in manifest.listAssets()) {
      final RegExpMatch? match = entry.firstMatch(asset);
      if (match != null) _available.add(match.group(1)!);
    }
  } catch (_) {
    // No manifest, no icons. The app is fully usable without them.
  }
}

@visibleForTesting
void debugSetVocabIcons(Iterable<String> ids) {
  _loadFuture = Future<void>.value();
  _available
    ..clear()
    ..addAll(ids);
}

@visibleForTesting
void debugResetVocabIcons() {
  _loadFuture = null;
  _available.clear();
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
