import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../hazard/data/models/hazard_entity.dart';

/// 3x2 hazard grid per the sketch:
/// Flood | Cyclone | Lightning / Flash Flood | Landslide | Earthquake
class HazardGrid extends StatelessWidget {
  final List<HazardEntity> hazards;
  final void Function(HazardEntity hazard)? onTap;

  const HazardGrid({super.key, required this.hazards, this.onTap});

  static IconData iconFor(String key) {
    switch (key) {
      case 'flood':
        return Icons.flood_outlined;
      case 'cyclone':
        return Icons.cyclone_outlined;
      case 'lightning':
        return Icons.bolt_outlined;
      case 'flash_flood':
        return Icons.waves_outlined;
      case 'landslide':
        return Icons.landslide_outlined;
      case 'earthquake':
        return Icons.crisis_alert_outlined;
      default:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.98,
      ),
      itemCount: hazards.length,
      itemBuilder: (_, i) {
        final hazard = hazards[i];
        final severityColor = c.severityOf(hazard.severity);
        return InkWell(
          onTap: () => onTap?.call(hazard),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              color: c.cardBg,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconFor(hazard.hazardKey),
                      color: severityColor, size: 26.sp),
                ),
                SizedBox(height: 8.h),
                Text(hazard.titleBn,
                    style: AppTextStyles.caption(c.textPrimary)
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(hazard.titleEn,
                    style: TextStyle(
                        fontSize: 10.sp, color: c.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }
}
