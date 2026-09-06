import 'package:speech_to_text/speech_to_text.dart';

const String defaultGermanLocaleId = 'de-DE';

enum GermanLocaleStatus { advertised, enumerationUnavailable, explicitlyAbsent }

class GermanLocaleSelection {
  const GermanLocaleSelection(this.localeId, this.status);

  final String? localeId;
  final GermanLocaleStatus status;
}

GermanLocaleSelection selectGermanLocale(Iterable<LocaleName> locales) {
  final List<LocaleName> advertised = locales.toList(growable: false);
  if (advertised.isEmpty) {
    return const GermanLocaleSelection(
      defaultGermanLocaleId,
      GermanLocaleStatus.enumerationUnavailable,
    );
  }

  LocaleName? selected;
  for (final LocaleName locale in advertised) {
    final String normalized = locale.localeId
        .trim()
        .replaceAll('_', '-')
        .toLowerCase();
    if (normalized == 'de-de') {
      selected = locale;
      break;
    }
  }
  if (selected == null) {
    for (final LocaleName locale in advertised) {
      final String normalized = locale.localeId
          .trim()
          .replaceAll('_', '-')
          .toLowerCase();
      if (normalized == 'de' || normalized.startsWith('de-')) {
        selected = locale;
        break;
      }
    }
  }

  if (selected != null) {
    return GermanLocaleSelection(
      selected.localeId,
      GermanLocaleStatus.advertised,
    );
  }
  return const GermanLocaleSelection(null, GermanLocaleStatus.explicitlyAbsent);
}
