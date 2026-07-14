import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_fonts.dart';
import '../../core/services/user_pref_service.dart';

/// Shows both bn and en text side by side, but always makes the CURRENTLY
/// selected language the bigger/bolder one - swaps dynamically instead of
/// always favoring one language regardless of the app's language setting.
class BilingualLabel extends StatelessWidget {
  final String bn;
  final String en;
  final Color activeColor;
  final Color inactiveColor;
  final double activeSize;
  final double inactiveSize;
  final FontWeight activeWeight;

  const BilingualLabel({
    super.key,
    required this.bn,
    required this.en,
    required this.activeColor,
    required this.inactiveColor,
    this.activeSize = 17,
    this.inactiveSize = 12,
    this.activeWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = Get.find<UserPrefService>().isBangla;
    final activeText = isBangla ? bn : en;
    final inactiveText = isBangla ? en : bn;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            activeText,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.style(
                fontSize: activeSize.sp, fontWeight: activeWeight, color: activeColor),
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Text(
              inactiveText,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.style(
                  fontSize: inactiveSize.sp, fontWeight: FontWeight.w400, color: inactiveColor),
            ),
          ),
        ),
      ],
    );
  }
}
