import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
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
        title: Text('দুর্যোগ / Hazards',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
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
                          Text('${hazard.titleBn} (${hazard.titleEn})',
                              style: AppTextStyles.title(c.textPrimary)),
                          SizedBox(height: 2.h),
                          Text(
                              hazard.summary ??
                                  'সর্বশেষ আপডেট: ${DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(hazard.updatedAt))}',
                              style:
                                  AppTextStyles.caption(c.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                          (hazard.severity ?? 'Normal').capitalizeFirst!,
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: severityColor)),
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
}
