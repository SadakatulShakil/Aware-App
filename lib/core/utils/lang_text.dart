import 'app_logger.dart';

/// bn/en pair used by per-feature title fallback maps (see hazard_entity.dart
/// / service_model.dart) - keyed by item id, consulted only when the API's
/// title language doesn't match what was requested.
typedef LangPair = ({String bn, String en});

/// Unicode Bengali block - conjuncts, vowel signs and digits all fall inside it.
bool containsBangla(String s) => s.runes.any((r) => r >= 0x0980 && r <= 0x09FF);

/// Picks the title to show for [currentLang] ('bn' | 'en').
///
/// The DDM API is meant to localize titles via Accept-Language, but its WAF
/// currently ignores that header (for Dart's TLS stack) and always returns
/// Bangla. This detects the mismatch per item by inspecting the API title's
/// script rather than trusting the header, and substitutes [mapBn]/[mapEn]
/// only when the API's title is in the wrong script - so a correct-language
/// API title always wins, and the fallback map stops being used the moment
/// the backend starts honoring the header again, with no code change.
String resolveTitle({
  required String apiTitle,
  required String currentLang,
  required String? mapBn,
  required String? mapEn,
}) {
  final apiIsBangla = containsBangla(apiTitle);
  final wantBangla = currentLang == 'bn';

  if (wantBangla && !apiIsBangla && apiTitle.trim().isNotEmpty && mapBn != null && mapBn.isNotEmpty) {
    return mapBn;
  }
  if (!wantBangla && apiIsBangla && mapEn != null && mapEn.isNotEmpty) {
    return mapEn;
  }
  if (apiTitle.trim().isNotEmpty) return apiTitle;
  return (wantBangla ? mapBn : mapEn) ?? apiTitle;
}

final Set<String> _warnedMissingFallbackKeys = {};

/// Logs once per id that [feature]'s fallback map has no entry for [id] -
/// resolveTitle still degrades gracefully to the raw API title, but a
/// missing entry means a new backend item needs to be added to the map.
void warnMissingTitleFallback(String feature, String id, String apiTitle, String currentLang) {
  final key = '$feature:$id';
  if (!_warnedMissingFallbackKeys.add(key)) return;
  AppLogger.w('No $feature title fallback for id=$id (apiTitle="$apiTitle", '
      'currentLang=$currentLang) - extend the fallback map if this is a new backend item.');
}
