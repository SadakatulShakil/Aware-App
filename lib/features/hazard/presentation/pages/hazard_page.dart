import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme_colors.dart';
import '../../../../shared/widgets/bilingual_label.dart';
import '../../../home/presentation/widgets/hazard_grid.dart';
import '../controllers/hazard_controller.dart';

class HazardPage extends GetView<HazardController> {
  const HazardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: BilingualLabel(
          bn: 'দুর্যোগ',
          en: 'Hazards',
          activeColor: c.textPrimary,
          inactiveColor: c.textSecondary,
          activeSize: 18,
          inactiveSize: 13,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
            itemCount: controller.hazards.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) {
              final hazard = controller.hazards[i];
              final severityColor = c.severityOf(hazard.severity);
              final dateStr = DateFormat('d MMM yyyy')
                  .format(DateTime.fromMillisecondsSinceEpoch(hazard.updatedAt));
              final severityLabels = _severityLabels(hazard.severity);
              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: c.cardBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(HazardGrid.iconFor(hazard.hazardKey),
                          color: severityColor, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BilingualLabel(
                            bn: hazard.titleBn,
                            en: hazard.titleEn,
                            activeColor: c.textPrimary,
                            inactiveColor: c.textSecondary,
                            activeSize: 15,
                            inactiveSize: 11,
                          ),
                          SizedBox(height: 2.h),
                          hazard.summary != null
                              ? Text(hazard.summary!,
                                  style: TextStyle(fontSize: 12.sp, color: c.textSecondary))
                              : BilingualLabel(
                                  bn: 'সর্বশেষ আপডেট: $dateStr',
                                  en: 'Last updated: $dateStr',
                                  activeColor: c.textSecondary,
                                  inactiveColor: c.textSecondary,
                                  activeSize: 12,
                                  inactiveSize: 10,
                                ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: BilingualLabel(
                        bn: severityLabels.$1,
                        en: severityLabels.$2,
                        activeColor: severityColor,
                        inactiveColor: severityColor.withOpacity(0.7),
                        activeSize: 11,
                        inactiveSize: 9,
                        activeWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  (String, String) _severityLabels(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'moderate':
        return ('মাঝারি', 'Moderate');
      case 'heavy':
        return ('তীব্র', 'Heavy');
      case 'extreme':
        return ('চরম', 'Extreme');
      default:
        return ('স্বাভাবিক', 'Normal');
    }
  }
}
