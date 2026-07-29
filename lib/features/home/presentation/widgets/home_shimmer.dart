import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_theme_colors.dart';

/// Shimmer placeholder shaped like a single [OngoingBulletinCarousel] card,
/// shown while `fetchOngoingBulletins()` is in flight.
class BulletinCarouselShimmer extends StatelessWidget {
  const BulletinCarouselShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return SizedBox(
      height: 116.h,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.94,
          child: Shimmer.fromColors(
            baseColor: c.shimmerBase,
            highlightColor: c.shimmerHighlight,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: c.shimmerBase,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for [AlertsGrid] - 8 cards in the same 4-col layout,
/// shown while `fetchAlerts()` is in flight.
class AlertsGridShimmer extends StatelessWidget {
  const AlertsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Shimmer.fromColors(
      baseColor: c.shimmerBase,
      highlightColor: c.shimmerHighlight,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1,
        ),
        itemCount: 8,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: c.shimmerBase,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for [HazardGrid] - 6 cards in the same 3-col layout,
/// shown while `fetchHazards()` is in flight.
class HazardGridShimmer extends StatelessWidget {
  const HazardGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Shimmer.fromColors(
      baseColor: c.shimmerBase,
      highlightColor: c.shimmerHighlight,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.98,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: c.shimmerBase,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}
