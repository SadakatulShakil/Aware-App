import 'package:aware/core/utils/convert_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../data/models/alert_item_model.dart';

/// 4-col alert count grid, background image per card sourced from the
/// `type` field of the `/alerts` API response (1=normal, 2=warning, 3=danger).
class AlertsGrid extends StatelessWidget {
  final List<AlertItemModel> alerts;

  const AlertsGrid({super.key, required this.alerts});

  static String _backgroundFor(String type) {
    switch (type) {
      case '2':
        return 'assets/svg/warning.svg';
      case '3':
        return 'assets/svg/danger.svg';
      default:
        return 'assets/svg/normal.svg';
    }
  }

  static Color _textColorFor(String type) {
  switch (type) {
        case '2':
          return const Color(0xFFFF767B);
        case '3':
          return const Color(0xFFC22F34);
        default:
          return const Color(0xFF009401);
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
        crossAxisCount: 4,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1,
      ),
      itemCount: alerts.length,
      itemBuilder: (_, i) {
        final alert = alerts[i];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SvgPicture.asset(
                  _backgroundFor(alert.type),
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        alert.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(c.textAlert)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        WeatherUtils.localizeNumbersOnly(alert.value),
                        style: AppTextStyles.heading(_textColorFor(alert.type)).copyWith(fontSize: 20.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
