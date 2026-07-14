import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../app/theme/app_fonts.dart';
import '../../../../../app/theme/app_theme_colors.dart';
import '../../../../../core/utils/convert_utils.dart';

/// Ported 1:1 from BMD's BaseWeatherCard - type tag, big temp, feels-like,
/// HT/LT/rainfall overlay bar. The BMD survey feedback button is removed
/// (BMD-only feature, not part of AWARE).
class BaseWeatherCard extends StatelessWidget {
  final String temp;
  final String tempMax;
  final String tempMin;
  final String rainMin;
  final String rainMax;
  final String rainUnit;
  final String feelsLike;
  final String type;
  final String tempUnit;
  final bool isBangla;

  const BaseWeatherCard({
    super.key,
    required this.temp,
    required this.tempMax,
    required this.tempMin,
    required this.rainMin,
    required this.rainMax,
    required this.rainUnit,
    required this.feelsLike,
    required this.type,
    required this.tempUnit,
    required this.isBangla,
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
                    color: tagBackground, borderRadius: BorderRadius.circular(4.r)),
                child: Text(type.replaceAll('\n', ' '),
                    style: TextStyle(color: mainTextColor, fontSize: 13.sp)),
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(displayTemp,
                      style: AppFonts.style(
                          fontSize: 62.sp,
                          fontWeight: FontWeight.bold,
                          color: mainTextColor,
                          height: 0.8)),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
                    child: Text(isBangla ? '°সে' : '°C',
                        style: TextStyle(
                            fontSize: 24.sp, color: mainTextColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text('$feelsLike ${isBangla ? 'সে' : 'C'}',
                  style: AppFonts.style(
                      fontSize: 14.sp, fontWeight: FontWeight.w700, color: mainTextColor)),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
            decoration:
                BoxDecoration(color: cardBackground, borderRadius: BorderRadius.circular(8.r)),
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
