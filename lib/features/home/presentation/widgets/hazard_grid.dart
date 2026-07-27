import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../hazard/data/models/hazard_entity.dart';

/// 3-col hazard grid, icons + titles sourced from the DDM hazard/list API.
class HazardGrid extends StatelessWidget {
  final List<HazardEntity> hazards;
  final void Function(HazardEntity hazard)? onTap;

  const HazardGrid({super.key, required this.hazards, this.onTap});

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
                    color: c.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: hazard.iconUrl.isEmpty
                      ? Icon(Icons.warning_amber_outlined, color: c.primary, size: 26.sp)
                      : CachedNetworkImage(
                          imageUrl: hazard.iconUrl,
                          fit: BoxFit.contain,
                          width: 26.sp,
                          height: 26.sp,
                          memCacheWidth: (26.sp * 3).round(),
                          memCacheHeight: (26.sp * 3).round(),
                          placeholder: (_, __) => SizedBox(width: 26.sp, height: 26.sp),
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.warning_amber_outlined, color: c.primary, size: 26.sp),
                        ),
                ),
                SizedBox(height: 8.h),
                Text(
                  hazard.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption(c.textPrimary).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
