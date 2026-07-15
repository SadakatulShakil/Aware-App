import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../data/models/notification_model.dart';

/// Notification ticker living inside the collapsing weather header - ported
/// 1:1 from BMD Abohawa's NotificationCarousel (see
/// weather_home_page.dart's _buildFullHeaderContent).
class HeaderNotificationCarousel extends StatelessWidget {
  final List<NotificationModel> notifications;

  const HeaderNotificationCarousel({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    // A single item has nothing to cycle to - autoplay/infinite-scroll on a
    // 1-item carousel just silently repeats the same card.
    final bool canCycle = notifications.length > 1;

    return IntrinsicHeight(
      child: CarouselSlider.builder(
        itemCount: notifications.length,
        options: CarouselOptions(
          aspectRatio: 16 / 2.4,
          autoPlay: canCycle,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 600),
          autoPlayCurve: Curves.easeInOut,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
          viewportFraction: 0.91,
          enableInfiniteScroll: canCycle,
          padEnds: true,
        ),
        itemBuilder: (context, index, realIndex) {
          return _NotificationCard(notification: notifications[index]);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  // BMD's appAlertSevere - fixed accent for the header ticker card.
  static const _severeAlert = Color(0xFFFFA500);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.notifications),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _severeAlert,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => Get.toNamed(AppRoutes.notifications),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 6.w,
                      top: 8.h,
                      bottom: 6.h,
                      right: 40.w,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 18.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppFonts.style(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.45,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12.r),
                          bottomRight: Radius.circular(10.r),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 12.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
