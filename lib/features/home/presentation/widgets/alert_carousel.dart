import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../data/models/alert_model.dart';

/// Auto-scrolling weather alert carousel - BMD style.
class AlertCarousel extends StatefulWidget {
  final List<AlertModel> alerts;

  const AlertCarousel({super.key, required this.alerts});

  @override
  State<AlertCarousel> createState() => _AlertCarouselState();
}

class _AlertCarouselState extends State<AlertCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.alerts.length < 2) return;
      final next = (_current + 1) % widget.alerts.length;
      _pageController.animateToPage(next,
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
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 116.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.alerts.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _AlertCard(alert: widget.alerts[i]),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.alerts.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _current == i ? 18.w : 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: _current == i ? c.primary : c.divider,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final severityColor = c.severityOf(alert.severity);

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4.w, color: severityColor),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign_outlined,
                            color: severityColor, size: 18.sp),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(alert.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title(c.textPrimary)),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Expanded(
                      child: Text(alert.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption(c.textSecondary)),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                          'Update: ${DateFormat('d MMM, hh:mm a').format(alert.updatedAt)}',
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
    );
  }
}
