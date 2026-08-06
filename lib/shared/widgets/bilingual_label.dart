import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_fonts.dart';
import '../../core/services/user_pref_service.dart';

/// Shows only the text matching the app's current language - bn when the
/// app is set to Bangla, en when it's set to English. Never both at once.
class BilingualLabel extends StatelessWidget {
  final String bn;
  final String en;
  final Color activeColor;
  final double activeSize;
  final FontWeight activeWeight;

  const BilingualLabel({
    super.key,
    required this.bn,
    required this.en,
    required this.activeColor,
    this.activeSize = 17,
    this.activeWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = Get.find<UserPrefService>().isBangla;
    final activeText = isBangla ? bn : en;

    return Text(
      activeText,
      overflow: TextOverflow.ellipsis,
      style: AppFonts.style(fontSize: activeSize.sp, fontWeight: activeWeight, color: activeColor),
    );
  }
}
