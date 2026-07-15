import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/models/ongoing_bulletin_model.dart';

/// Auto-scrolling carousel for DDM's ongoing bulletins - tapping a card
/// launches that bulletin's own report/PDF `link`.
class OngoingBulletinCarousel extends StatefulWidget {
  final List<OngoingBulletinModel> bulletins;

  const OngoingBulletinCarousel({super.key, required this.bulletins});

  @override
  State<OngoingBulletinCarousel> createState() => _OngoingBulletinCarouselState();
}

class _OngoingBulletinCarouselState extends State<OngoingBulletinCarousel> {

  static const int _initialPage = 10000;

  late final PageController _pageController;
  Timer? _timer;
  int _current = _initialPage;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(viewportFraction: 0.94, initialPage: _initialPage);
    _maybeStartAutoScroll();
  }

  @override
  void didUpdateWidget(covariant OngoingBulletinCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Item count can change between builds (e.g. cache had 1, API returned
    // 3) - re-evaluate whether the timer/PageView should be running.
    if (widget.bulletins.length != oldWidget.bulletins.length) {
      _maybeStartAutoScroll();
    }
  }

  // With exactly 1 item there is nothing to cycle to, so no timer is
  // created at all (previously it ticked every 4s doing nothing).
  void _maybeStartAutoScroll() {
    if (widget.bulletins.length < 2) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    if (_timer != null) return; // already running
    _current = _initialPage;
    if (_pageController.hasClients) _pageController.jumpToPage(_initialPage);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.bulletins.length < 2) return;
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

  Future<void> _openLink(String link) async {
    if (kDebugMode) {
      print('Opening bulletin link: $link');
    }
    if (link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok) await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      AppLogger.e('Failed to launch bulletin link: $link', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    if (widget.bulletins.isEmpty) return const SizedBox.shrink();

    if (widget.bulletins.length == 1) {
      final bulletin = widget.bulletins.first;
      return SizedBox(
        height: 116.h,
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.94,
            child: _BulletinCard(
              bulletin: bulletin,
              onTap: () => _openLink(bulletin.link),
            ),
          ),
        ),
      );
    }

    final activeDot = _current % widget.bulletins.length;

    return Column(
      children: [
        SizedBox(
          height: 116.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              final bulletin = widget.bulletins[i % widget.bulletins.length];
              return _BulletinCard(
                bulletin: bulletin,
                onTap: () => _openLink(bulletin.link),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.bulletins.length,
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

class _BulletinCard extends StatelessWidget {
  final OngoingBulletinModel bulletin;
  final VoidCallback onTap;

  const _BulletinCard({required this.bulletin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppThemeColors.of(Theme.of(context).brightness == Brightness.dark);
    final hasLink = bulletin.link.isNotEmpty;

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
          onTap: hasLink ? onTap : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4.w, color: c.primary),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.article_outlined, color: c.primary, size: 18.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(bulletin.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.title(c.textPrimary)),
                            ),
                            if (hasLink)
                              Icon(Icons.open_in_new, color: c.textSecondary, size: 14.sp),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Expanded(
                          child: Text(
                              bulletin.message.isNotEmpty ? bulletin.message : bulletin.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption(c.textSecondary)),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                              'Update: ${DateFormat('d MMM, hh:mm a').format(bulletin.lastUpdate)}',
                              style: TextStyle(fontSize: 10.sp, color: c.textSecondary)),
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
