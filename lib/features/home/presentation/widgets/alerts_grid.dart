import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/alert_item_model.dart';

/// 4-col alert count grid, background color per card sourced from the
/// `/alerts` API response.
class AlertsGrid extends StatelessWidget {
  final List<AlertItemModel> alerts;

  const AlertsGrid({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1,
      ),
      itemCount: alerts.length,
      itemBuilder: (_, i) {
        final alert = alerts[i];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: alert.color,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                alert.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption(Colors.white).copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4.h),
              Text(
                alert.value,
                style: AppTextStyles.heading(Colors.white).copyWith(fontSize: 20.sp),
              ),
            ],
          ),
        );
      },
    );
  }
}
