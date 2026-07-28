import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_fonts.dart';
import '../../../../../app/theme/app_theme_colors.dart';
import '../../../../../core/utils/convert_utils.dart';

/// Ported 1:1 from BMD's BaseWeatherCard - type tag, big temp, feels-like,
/// HT/LT/rainfall overlay bar. BMD's survey feedback button is replaced
/// with an "Incident Report" button (same position/style).
class BaseWeatherCard extends StatelessWidget {
  final String temp;
  final String icon;
  final String tempMax;
  final String tempMin;
  final String rainMin;
  final String rainMax;
  final String rainUnit;
  final String feelsLike;
  final String type;
  final String tempUnit;

  const BaseWeatherCard({
    super.key,
    required this.temp,
    required this.icon,
    required this.tempMax,
    required this.tempMin,
    required this.rainMin,
    required this.rainMax,
    required this.rainUnit,
    required this.feelsLike,
    required this.type,
    required this.tempUnit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppThemeColors.of(isDark);
    final Color mainTextColor = p.weatherCardText;
    final Color cardBackground = p.weatherCardOverlay;
    final Color tagBackground = p.weatherCardTagBg;

    final displayTemp = WeatherUtils.roundAndLocalize(temp);
    final displayMax = WeatherUtils.roundAndLocalize(tempMax);
    final displayMin = WeatherUtils.roundAndLocalize(tempMin);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white24
                        : Colors.black.withValues(alpha: .30), borderRadius: BorderRadius.circular(4.r)),
                child: Text(type.replaceAll('\n', ' '),
                    style: TextStyle(color: mainTextColor, fontSize: 13.sp)),
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(displayTemp,
                          style: AppFonts.style(
                              fontSize: 62.sp,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                              height: 0.8)),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
                        child: Text('temp_unit_full'.tr,
                            style: TextStyle(
                                fontSize: 24.sp,
                                color: mainTextColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  Image.network(
                    icon,
                    height: 55.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://usf.bmd.gov.bd/src/weather_icon/ic_partly_cloudy.png',
                        height: 55.h,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('$feelsLike ${'temp_unit_short'.tr}',
                      style: AppFonts.style(
                          fontSize: 14.sp, fontWeight: FontWeight.w700, color: mainTextColor)),
                  _buildIncidentReportButton(context),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
            decoration:
                BoxDecoration(color: isDark
                    ? Colors.white24
                    : Colors.black.withValues(alpha: .30), borderRadius: BorderRadius.circular(8.r)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _smallInfo('assets/svg/high_temp.svg', displayMax),
                    const Text(' / ', style: TextStyle(color: Colors.white)),
                    _smallInfo('assets/svg/low_temp.svg', displayMin),
                  ],
                ),
                Container(width: 1, height: 14.h, color: Colors.white.withOpacity(0.2)),
                Row(
                  children: [
                    Icon(Icons.cloudy_snowing, size: 18.r, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      rainMin == rainMax ? '$rainMin $rainUnit' : '$rainMin - $rainMax $rainUnit',
                      style: AppFonts.style(
                          color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildIncidentReportButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.incidentReport),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white54, width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.report_outlined, size: 14.r, color: Colors.white),
            SizedBox(width: 6.w),
            Text('incident_report'.tr,
                style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _smallInfo(String icon, String val) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 14.r),
        SizedBox(width: 4.w),
        Text('$val$tempUnit',
            style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
