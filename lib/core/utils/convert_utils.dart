import 'package:get/get.dart';

import '../services/user_pref_service.dart';

class WeatherUtils {
  static const _en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  static const _bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

  static bool get _isBangla => Get.find<UserPrefService>().isBangla;

  /// Rounds a string value and converts it to localized digits.
  static String roundAndLocalize(String? value) {
    if (value == null || value.isEmpty || value == "-/-") return "-/-";

    String englishValue = value;
    for (int i = 0; i < 10; i++) {
      englishValue = englishValue.replaceAll(_bn[i], _en[i]);
    }

    String cleanValue = englishValue.replaceAll(RegExp(r'[^0-9.]'), '');

    double? parsed = double.tryParse(cleanValue);
    if (parsed == null) return value;

    int rounded = parsed.round();
    String result = rounded.toString();

    if (_isBangla) {
      for (int i = 0; i < 10; i++) {
        result = result.replaceAll(_en[i], _bn[i]);
      }
    }

    return result;
  }

  static String localizeNumbersOnly(String? value) {
    if (value == null || value.isEmpty || value == "-/-") return "-/-";

    String englishValue = value;
    for (int i = 0; i < 10; i++) {
      englishValue = englishValue.replaceAll(_bn[i], _en[i]);
    }

    if (_isBangla) {
      for (int i = 0; i < 10; i++) {
        englishValue = englishValue.replaceAll(_en[i], _bn[i]);
      }
    }

    return englishValue;
  }

  static double? parseLocalizedDouble(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    String englishValue = value;
    for (int i = 0; i < 10; i++) {
      englishValue = englishValue.replaceAll(_bn[i], _en[i]);
    }
    String cleanValue = englishValue.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleanValue);
  }
}
