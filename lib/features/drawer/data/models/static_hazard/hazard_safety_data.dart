import 'package:flutter/material.dart';

import '../../../../home/presentation/widgets/hazard_grid.dart';

class HazardSafetyInfo {
  final String hazardKey;
  final String titleBn;
  final String titleEn;
  final String severity;
  final List<String> tips;

  const HazardSafetyInfo({
    required this.hazardKey,
    required this.titleBn,
    required this.titleEn,
    required this.severity,
    required this.tips,
  });

  IconData get icon => HazardGrid.iconFor(hazardKey);
}

/// Static safety-tip reference shown on the Risk Information page.
/// Independent of the live HazardEntity feed on Home - this is general
/// preparedness guidance, not a current-alert status.
class HazardSafetyData {
  HazardSafetyData._();

  static const all = <HazardSafetyInfo>[
    HazardSafetyInfo(
      hazardKey: 'flood',
      titleBn: 'বন্যা',
      titleEn: 'Flood',
      severity: 'heavy',
      tips: [
        'উঁচু স্থানে সরে যান এবং প্রয়োজনীয় জিনিসপত্র প্রস্তুত রাখুন — Move to higher ground and keep essentials ready.',
        'বন্যার পানিতে হাঁটা বা গাড়ি চালানো এড়িয়ে চলুন — Avoid walking or driving through flood water.',
        'সরকারি সতর্কবার্তা ও রেডিও/টিভি আপডেট অনুসরণ করুন — Follow official alerts and radio/TV updates.',
      ],
    ),
    HazardSafetyInfo(
      hazardKey: 'cyclone',
      titleBn: 'ঘূর্ণিঝড়',
      titleEn: 'Cyclone',
      severity: 'extreme',
      tips: [
        'ঘরের বাইরের ঢিলা জিনিসপত্র সুরক্ষিত করুন — Secure loose outdoor objects before the storm.',
        'নির্দেশ পেলে নিকটস্থ সাইক্লোন শেল্টারে চলে যান — Move to the nearest cyclone shelter if advised.',
        'বিশুদ্ধ পানি ও শুকনো খাবার মজুত রাখুন — Store safe drinking water and dry food.',
      ],
    ),
    HazardSafetyInfo(
      hazardKey: 'lightning',
      titleBn: 'বজ্রপাত',
      titleEn: 'Lightning',
      severity: 'moderate',
      tips: [
        'খোলা মাঠ ও একক লম্বা গাছ এড়িয়ে চলুন — Avoid open fields and tall isolated trees.',
        'বজ্রপাতের সময় ঘরের ভেতরে অবস্থান করুন — Stay indoors during a lightning storm.',
        'কর্ডযুক্ত ফোন ও বৈদ্যুতিক যন্ত্র ব্যবহার এড়িয়ে চলুন — Avoid corded phones and electrical appliances.',
      ],
    ),
    HazardSafetyInfo(
      hazardKey: 'flash_flood',
      titleBn: 'আকস্মিক বন্যা',
      titleEn: 'Flash Flood',
      severity: 'heavy',
      tips: [
        'ভারী বৃষ্টির সময় পাহাড়ি ঢল ও নদী তীরবর্তী নিচু এলাকা এড়িয়ে চলুন — Avoid low-lying areas near hills/rivers during heavy rain.',
        'পানি বাড়তে দেখলে সঙ্গে সঙ্গে উঁচু স্থানে চলে যান — Move to higher ground immediately if water starts rising.',
        'প্লাবিত রাস্তা পার হওয়া থেকে বিরত থাকুন — Do not attempt to cross flooded roads.',
      ],
    ),
    HazardSafetyInfo(
      hazardKey: 'landslide',
      titleBn: 'ভূমিধস',
      titleEn: 'Landslide',
      severity: 'heavy',
      tips: [
        'ভারী বৃষ্টির পর মাটি বা দেয়ালে ফাটল দেখা দিলে সতর্ক হোন — Watch for new cracks in ground or walls after heavy rain.',
        'সতর্কবার্তা পেলে সঙ্গে সঙ্গে এলাকা ত্যাগ করুন — Evacuate immediately if a landslide warning is issued.',
        'বর্ষাকালে খাড়া পাহাড়ি ঢাল এড়িয়ে চলুন — Avoid steep hill slopes during the monsoon season.',
      ],
    ),
    HazardSafetyInfo(
      hazardKey: 'earthquake',
      titleBn: 'ভূমিকম্প',
      titleEn: 'Earthquake',
      severity: 'extreme',
      tips: [
        'নিচু হয়ে, আড়াল নিয়ে, শক্ত কিছু ধরে রাখুন — Drop, cover, and hold on.',
        'জানালা ও ভারী আসবাবপত্র থেকে দূরে থাকুন — Stay away from windows and heavy furniture.',
        'কম্পন থামার পর নিরাপদ হলে খোলা জায়গায় চলে যান — Move to open space after the shaking stops, if safe.',
      ],
    ),
  ];
}
