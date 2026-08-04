import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_fonts.dart';
import '../../../../../app/theme/app_theme_colors.dart';
import '../../../../../core/utils/convert_utils.dart';

/// Weather info block rendered directly on top of the shared header card's
/// video/photo background (no background of its own): condition tag, big
/// temp + icon halo, feels-like row with the incident-report action, then
/// a High/Low/Rain stat strip.
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

  static const _highColor = Color(0xFFFFB27A);
  static const _lowColor = Color(0xFF7FC8FF);
  static const _rainColor = Color(0xFF6FE0D0);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final p = AppThemeColors.of(isDark);
    final Color mainTextColor = p.weatherCardText;
    final Color subTextColor = mainTextColor.withOpacity(0.78);

    final displayTemp = WeatherUtils.roundAndLocalize(temp);
    final displayMax = WeatherUtils.roundAndLocalize(tempMax);
    final displayMin = WeatherUtils.roundAndLocalize(tempMin);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeTag(mainTextColor),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(displayTemp,
                      style: AppFonts.style(
                          fontSize: 56.sp,
                          fontWeight: FontWeight.w800,
                          color: mainTextColor,
                          height: 0.9,
                          letterSpacing: -1.2)),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 2.w),
                    child: Text('temp_unit_full'.tr,
                        style: AppFonts.style(
                            fontSize: 20.sp, color: subTextColor, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              _buildIconHalo(),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thermostat_outlined, size: 13.r, color: subTextColor),
                  SizedBox(width: 4.w),
                  Text('$feelsLike ${'temp_unit_short'.tr}',
                      style: AppFonts.style(
                          fontSize: 12.sp, fontWeight: FontWeight.w600, color: subTextColor)),
                ],
              ),
              _buildIncidentReportButton(context, mainTextColor),
            ],
          ),
          SizedBox(height: 5.h),
          _buildDivider(),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _statChip(
                  assetIcon: 'assets/svg/high_temp.svg',
                  value: '$displayMax$tempUnit',
                  accent: _highColor,
                  textColor: mainTextColor,
                ),
              ),
              _statDivider(),
              Expanded(
                child: _statChip(
                  assetIcon: 'assets/svg/low_temp.svg',
                  value: '$displayMin$tempUnit',
                  accent: _lowColor,
                  textColor: mainTextColor,
                ),
              ),
              _statDivider(),
              Expanded(
                child: _statChip(
                  icon: Icons.water_drop_rounded,
                  value: rainMin == rainMax
                      ? '$rainMin $rainUnit'
                      : '$rainMin-$rainMax $rainUnit',
                  accent: _rainColor,
                  textColor: mainTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag(Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(color: textColor.withOpacity(0.9), shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Text(type.replaceAll('\n', ' '),
              style: AppFonts.style(color: textColor, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildIconHalo() {
    return Container(
      width: 70.r,
      height: 70.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.white.withOpacity(0.20), Colors.white.withOpacity(0.0)],
        ),
      ),
      child: Center(
        child: Image.network(
          icon,
          height: 60.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              'https://usf.bmd.gov.bd/src/weather_icon/ic_partly_cloudy.png',
              height: 60.h,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.22),
            Colors.white.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _statDivider() {
    return Container(width: 1, height: 22.h, color: Colors.white.withOpacity(0.16));
  }

  Widget _statChip({
    String? assetIcon,
    IconData? icon,
    required String value,
    required Color accent,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 22.r,
          height: 22.r,
          decoration: BoxDecoration(color: accent.withOpacity(0.20), shape: BoxShape.circle),
          child: Center(
            child: assetIcon != null
                ? SvgPicture.asset(assetIcon, width: 11.r, colorFilter: ColorFilter.mode(accent, BlendMode.srcIn))
                : Icon(icon, size: 12.r, color: accent),
          ),
        ),
        SizedBox(width: 5.h),
        Text(value,
            style: AppFonts.style(color: textColor, fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildIncidentReportButton(BuildContext context, Color textColor) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.incidentReport),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.report_outlined, size: 13.r, color: textColor),
            SizedBox(width: 5.w),
            Text('incident_report'.tr,
                style: AppFonts.style(fontSize: 11.sp, color: textColor, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
