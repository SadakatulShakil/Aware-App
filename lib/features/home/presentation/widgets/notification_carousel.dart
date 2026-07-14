import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../data/models/notification_model.dart';

/// Auto-scrolling notification carousel - BMD style yellow notification
/// ticker. Sourced from the notification API (see HomeRepository.getNotifications);
/// tapping any card opens the full NotificationPage, same as the bell icon.
class NotificationCarousel extends StatefulWidget {
  final List<NotificationModel> notifications;

  const NotificationCarousel({super.key, required this.notifications});

  @override
  State<NotificationCarousel> createState() => _NotificationCarouselState();
}

class _NotificationCarouselState extends State<NotificationCarousel> {
  // A PageView only ever animates toward the numeric page requested, so
  // wrapping the index back to 0 with modulo made it visually rewind
  // through every page instead of continuing forward. Fix: never wrap -
  // keep an unbounded, ever-increasing page index and let the itemBuilder
  // map it back into the list with modulo, so it always advances forward
  // and cycles seamlessly.
  static const int _initialPage = 10000;

  late final PageController _pageController;
  Timer? _timer;
  int _current = _initialPage;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(viewportFraction: 0.94, initialPage: _initialPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.notifications.length < 2) return;
      _current++;
      _pageController.animateToPage(_current,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    if (widget.notifications.isEmpty) return const SizedBox.shrink();

    final activeDot = _current % widget.notifications.length;

    return Column(
      children: [
        SizedBox(
          height: 116.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _NotificationCard(
                notification: widget.notifications[i % widget.notifications.length]),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.notifications.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: activeDot == i ? 18.w : 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: activeDot == i ? c.primary : c.divider,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  // Fixed BMD notification-yellow - this is a notification ticker, not a
  // severity-graded alert, so it never varies by severity.
  static const _accent = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => Get.toNamed(AppRoutes.notifications),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4.w, color: _accent),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.notifications_active_rounded,
                                color: _accent, size: 18.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(notification.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title(c.textPrimary)),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Expanded(
                          child: Text(notification.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(c.textSecondary)),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                              'Update: ${DateFormat('d MMM, hh:mm a').format(notification.updatedAt)}',
                              style: TextStyle(
                                  fontSize: 10.sp, color: c.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
