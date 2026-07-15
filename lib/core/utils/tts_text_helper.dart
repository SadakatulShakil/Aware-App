class TtsTextHelper {
  TtsTextHelper._();

  static String sanitizeTextForBanglaTTS(String text, {required bool isBangla}) {
    if (text.isEmpty) return text;
    String processed = text;
    processed = processed.replaceAllMapped(
      RegExp(r'([০-৯0-9]+)\s*[-–—]\s*([০-৯0-9]+)'),
      (m) => '${m[1]} ${isBangla ? "থেকে" : "to"} ${m[2]}',
    );
    processed = processed.replaceAllMapped(
      RegExp(r'([০-৯0-9]+)(কিমি|মিমি|মি\.মি\.|সে\.|°C|°)'),
      (m) => '${m[1]} ${m[2]}',
    );
    final Map<String, String> abbreviations = {
      'কিমি': 'কিলোমিটার',
      'কি.মি.': 'কিলোমিটার',
      'মিমি': 'মিলিমিটার',
      'মি.মি.': 'মিলিমিটার',
      'সে.': 'সেলসিয়াস',
      '°C': 'ডিগ্রি সেলসিয়াস',
      '°': 'ডিগ্রি',
      '%': 'শতাংশ',
      '(R)': 'Repeat',
    };
    abbreviations.forEach((abbr, fullWord) {
      processed = processed.replaceAll(abbr, fullWord);
    });
    final Map<String, String> phoneticCorrections = {
      'সতর্কতা': 'সতর্ক-তা',
      'পূর্বাভাস': 'পূর্বাভাস',
      'ঘূর্ণিঝড়': 'ঘূর্ণি ঝড়',
      'বজ্রপাত': 'বজ্র পাত',
      'তাপমাত্রা': 'তাপ মাত্রা',
      'আর্দ্রতা': 'আর্দ্রতা',
      'পুন:'  : 'পুনরায় বলছি',
      'খ্রি:'  : 'খ্রিস্টাব্দ',
    };
    phoneticCorrections.forEach((original, corrected) {
      processed = processed.replaceAll(original, corrected);
    });
    processed = processed.replaceAll(RegExp(r'[।/]'), '. ');
    return processed.trim();
  }

  static String getTtsErrorMessage(dynamic error, {required bool isBangla}) {
    final isEnglish = !isBangla;
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('language')) {
      return isEnglish ? 'Language not supported' : 'ভাষা সমর্থিত নয়';
    }
    if (errorString.contains('permission')) {
      return isEnglish ? 'Permission denied' : 'অনুমতি অস্বীকৃত';
    }
    if (errorString.contains('network')) {
      return isEnglish ? 'Network error' : 'নেটওয়ার্ক ত্রুটি';
    }
    return isEnglish ? 'Failed to speak notification' : 'বিজ্ঞপ্তি বলতে ব্যর্থ';
  }
}
