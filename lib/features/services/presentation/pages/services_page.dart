import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../data/models/service_model.dart';
import '../controllers/service_controller.dart';

class ServicesPage extends GetView<ServiceController> {
  const ServicesPage({super.key});

  void _openService(ServiceModel service) {
    if (service.url.isEmpty) return;
    Get.toNamed(AppRoutes.hazardDetails, arguments: {
      'title': service.displayTitle.replaceAll('\n', ' '),
      'url': service.url,
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        title: Text('সেবাসমূহ / Services',
            style: AppTextStyles.sectionTitle(c.textPrimary)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.services.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.services.isEmpty) {
          return Center(
            child: Text('no_data'.tr, style: AppTextStyles.body(c.textSecondary)),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.6,
            ),
            itemCount: controller.services.length,
            itemBuilder: (_, i) {
              final service = controller.services[i];
              return InkWell(
                onTap: () => _openService(service),
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.cardBg,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      service.iconUrl.isEmpty
                          ? Icon(Icons.widgets_outlined, color: c.primary, size: 28.sp)
                          : CachedNetworkImage(
                              imageUrl: service.iconUrl,
                              fit: BoxFit.contain,
                              width: 28.sp,
                              height: 28.sp,
                              memCacheWidth: (28.sp * 3).round(),
                              memCacheHeight: (28.sp * 3).round(),
                              placeholder: (_, __) => SizedBox(width: 28.sp, height: 28.sp),
                              errorWidget: (_, __, ___) =>
                                  Icon(Icons.widgets_outlined, color: c.primary, size: 28.sp),
                            ),
                      SizedBox(height: 8.h),
                      Text(
                        service.displayTitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title(c.textPrimary),
                      ),
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
