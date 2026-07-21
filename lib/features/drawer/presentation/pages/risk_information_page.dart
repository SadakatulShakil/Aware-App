import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../data/models/static_hazard/hazard_safety_data.dart';

class RiskInformationPage extends StatelessWidget {
  const RiskInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    const hazards = HazardSafetyData.all;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title:
            Text('ঝুঁকির তথ্য / Risk Information', style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: hazards.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, i) {
          final hazard = hazards[i];
          final severityColor = c.severityOf(hazard.severity);
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                color: c.cardBg,
                child: ExpansionTile(
                  leading: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration:
                        BoxDecoration(color: severityColor.withOpacity(0.12), shape: BoxShape.circle),
                    child: Icon(hazard.icon, color: severityColor, size: 22.sp),
                  ),
                  title: Text('${hazard.titleBn} / ${hazard.titleEn}',
                      style: AppTextStyles.title(c.textPrimary)),
                  childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: hazard.tips
                      .map((tip) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.circle, size: 6.r, color: c.textSecondary),
                                SizedBox(width: 8.w),
                                Expanded(
                                    child: Text(tip, style: AppTextStyles.body(c.textPrimary))),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
