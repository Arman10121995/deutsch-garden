/// Card translations in languages other than English.
///
/// Every card carries an English gloss as a field, because the deck was
/// authored that way and ten thousand const entries are a readable data table
/// worth keeping. Adding `turkish`, `arabic`, `ukrainian` and `russian`
/// alongside it would mean editing all ten thousand for each language, and
/// leaving most of them empty.
///
/// So a second language is a side table instead: one JSON asset per language,
/// keyed by card id, resolved at lookup and falling back to the English on the
/// card. Adding a language is a data drop and a line in `pubspec.yaml`; it
/// touches no Dart.
///
/// **These are not the interface language.** A learner reading the app in
/// English may want Turkish glosses, and a learner reading it in German
/// certainly does not want German glosses on German cards. The two settings
/// are separate and neither implies the other.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models.dart';

/// A language the deck can be glossed into.
///
/// English is not in here: it is on the card itself and always available.
class GlossLanguage {
  const GlossLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.rightToLeft,
  });

  final String code;
  final String englishName;
  final String nativeName;
  final bool rightToLeft;

  static const List<GlossLanguage> available = <GlossLanguage>[
    GlossLanguage(
      code: 'tr',
      englishName: 'Turkish',
      nativeName: 'Türkçe',
      rightToLeft: false,
    ),
  ];

  static GlossLanguage? byCode(String code) {
    for (final GlossLanguage language in available) {
      if (language.code == code) return language;
    }
    return null;
  }
}

/// Loaded glosses, per language code.
final Map<String, Map<String, String>> _loaded = <String, Map<String, String>>{};
final Map<String, Future<void>> _loading = <String, Future<void>>{};

/// Reads the gloss table for [code] once.
///
/// A missing or unreadable asset leaves the language empty rather than
/// throwing: the learner then sees English, which is the same thing they saw
/// before the language existed.
Future<void> loadGlosses(String code, {AssetBundle? bundle}) {
  if (code.isEmpty || _loaded.containsKey(code)) return Future<void>.value();
  return _loading.putIfAbsent(code, () async {
    try {
      final String raw = await (bundle ?? rootBundle)
          .loadString('assets/glosses/$code.json');
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _loaded[code] = const <String, String>{};
        return;
      }
      _loaded[code] = <String, String>{
        for (final MapEntry<Object?, Object?> entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key! as String: entry.value! as String,
      };
    } catch (error) {
      debugPrint('no glosses for "$code": $error');
      _loaded[code] = const <String, String>{};
    }
  });
}

@visibleForTesting
void debugSetGlosses(String code, Map<String, String> glosses) {
  _loaded[code] = Map<String, String>.from(glosses);
  _loading.remove(code);
}

@visibleForTesting
void debugClearGlosses() {
  _loaded.clear();
  _loading.clear();
}

/// How many cards [code] covers.
int glossCount(String code) => _loaded[code]?.length ?? 0;

/// The gloss for [word] in [code], or null when that language does not cover
/// this card.
///
/// Null rather than the English fallback, so a caller that wants to show both
/// can tell "no translation" from "the translation happens to match".
String? glossFor(GermanWord word, String code) {
  if (code.isEmpty) return null;
  return _loaded[code]?[word.id];
}

/// What to show as the meaning of [word].
///
/// Falls back to the card's English whenever the chosen language does not
/// cover it, which is most of the deck for every language but English. A blank
/// where a meaning should be is worse than a meaning in the wrong language.
String meaningFor(GermanWord word, String code) =>
    glossFor(word, code) ?? word.english;
