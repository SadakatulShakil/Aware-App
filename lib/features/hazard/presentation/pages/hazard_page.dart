import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../shared/widgets/bilingual_label.dart';
import '../../data/models/hazard_entity.dart';
import '../controllers/hazard_controller.dart';

class HazardPage extends GetView<HazardController> {
  const HazardPage({super.key});

  void _openHazard(HazardEntity hazard) {
    if (hazard.url.isEmpty) return;
    final currentLang = Get.find<UserPrefService>().appLanguage;
    Get.toNamed(AppRoutes.hazardDetails, arguments: {
      'title': hazard.localizedTitle(currentLang),
      'url': hazard.url,
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final currentLang = Get.find<UserPrefService>().appLanguage;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: BilingualLabel(
          bn: 'দুর্যোগ',
          en: 'Hazards',
          activeColor: c.textPrimary,
          activeSize: 18,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h + MediaQuery.of(context).padding.bottom),
            itemCount: controller.hazards.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (_, i) {
              final hazard = controller.hazards[i];
              final dateStr = DateFormat('d MMM yyyy')
                  .format(DateTime.fromMillisecondsSinceEpoch(hazard.updatedAt));
              return InkWell(
                onTap: () => _openHazard(hazard),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
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
                          color: c.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: hazard.iconUrl.isEmpty
                            ? Icon(Icons.warning_amber_outlined, color: c.primary, size: 24.sp)
                            : CachedNetworkImage(
                                imageUrl: hazard.iconUrl,
                                fit: BoxFit.contain,
                                width: 24.sp,
                                height: 24.sp,
                                memCacheWidth: (24.sp * 3).round(),
                                memCacheHeight: (24.sp * 3).round(),
                                placeholder: (_, __) => SizedBox(width: 24.sp, height: 24.sp),
                                errorWidget: (_, __, ___) => Icon(Icons.warning_amber_outlined,
                                    color: c.primary, size: 24.sp),
                              ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hazard.localizedTitle(currentLang),
                                style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: c.textPrimary)),
                            SizedBox(height: 2.h),
                            BilingualLabel(
                              bn: 'সর্বশেষ আপডেট: $dateStr',
                              en: 'Last updated: $dateStr',
                              activeColor: c.textSecondary,
                              activeSize: 12,
                            ),
                          ],
                        ),
                      ),
                      if (hazard.url.isNotEmpty)
                        Icon(Icons.chevron_right, color: c.textSecondary),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
