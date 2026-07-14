import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../../../app/theme/app_fonts.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../data/models/notification_model.dart';
import '../controllers/home_controller.dart';

/// Lists fetched notifications - ported from BMD's NotificationPage, scoped
/// to AWARE's actual data (NotificationModel, already mapped from BMD's
/// notification/list API in HomeRepository). No TTS playback - BMD-only.
class NotificationPage extends GetView<HomeController> {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    // Always refresh on open so the list reflects the latest server state.
    controller.fetchNotifications();

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: AppBar(
        backgroundColor: c.scaffoldBg,
        title: Text('notifications'.tr,
            style: AppFonts.style(fontSize: 18.sp, fontWeight: FontWeight.bold, color: c.textPrimary)),
      ),
      body: Obx(() {
        if (controller.isNotificationsLoading.value && controller.notifications.isEmpty) {
          return Center(
            child: lottie.Lottie.asset('assets/json/loading_anim.json', width: 80.r),
          );
        }

        if (controller.notificationsLoadError.value && controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 50.r, color: Colors.red.shade300),
                SizedBox(height: 10.h),
                Text('failed_to_load'.tr, style: AppFonts.style(color: c.textSecondary)),
                TextButton(
                  onPressed: controller.fetchNotifications,
                  child: Text('retry'.tr, style: AppFonts.style(color: c.primary)),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 60.r, color: c.textSecondary),
                SizedBox(height: 10.h),
                Text('no_notifications'.tr,
                    style: AppFonts.style(fontSize: 16.sp, color: c.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) =>
                _NotificationCard(notification: controller.notifications[i], colors: c),
          ),
        );
      }),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final AppThemeColors colors;

  const _NotificationCard({required this.notification, required this.colors});

  @override
  Widget build(BuildContext context) {
    final isAlert = notification.severity != 'normal';
    final iconBg = isAlert ? Colors.orange.withOpacity(0.12) : colors.primary.withOpacity(0.10);
    final iconColor = isAlert ? Colors.orange.shade700 : colors.primary;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.divider),
      ),
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(
              isAlert ? Icons.warning_amber_rounded : Icons.notifications_active_outlined,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAlert)
                  Container(
                    margin: EdgeInsets.only(bottom: 4.h),
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('alert'.tr,
                        style: AppFonts.style(
                            fontSize: 10.sp,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w600)),
                  ),
                Text(
                  notification.title.isNotEmpty ? notification.title : 'no_title'.tr,
                  style: AppFonts.style(fontSize: 14.sp, color: colors.textPrimary, height: 1.2),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12.sp, color: colors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('d MMM, hh:mm a').format(notification.updatedAt),
                      style: AppFonts.style(fontSize: 12.sp, color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
