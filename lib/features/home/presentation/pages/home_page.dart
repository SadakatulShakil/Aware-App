import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../../../app/theme/app_fonts.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/utils/convert_utils.dart';
import '../controllers/home_controller.dart';
import '../widgets/alert_carousel.dart';
import '../widgets/hazard_grid.dart';
import '../widgets/weather/base_weather_card.dart';
import '../widgets/weather/weather_video_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final HomeController controller = Get.find<HomeController>();

  /// True only when the live video has real frames on screen. The header
  /// scrim switches on THIS - never on URL arrival - otherwise the
  /// lighter video-scrim shows over the bright day image for ~400ms
  /// while the video initializes (visible brightness pulse).
  final RxBool _videoReady = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final isNight = now.hour < 6 || now.hour > 18;

    return Obx(() {
      if (!controller.isLoaded.value) {
        return _buildLoading();
      }

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final colors = AppThemeColors.of(isDark);
      final statusBarHeight = MediaQuery.of(context).padding.top;
      final collapsedHeaderHeight = 56.h + statusBarHeight;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: colors.scaffoldBg,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.scaffoldGradientTop, colors.scaffoldGradientBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: RefreshIndicator(
              onRefresh: controller.onRefresh,
              edgeOffset: collapsedHeaderHeight,
              child: CustomScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _WeatherHeaderDelegate(
                      statusBarHeight: statusBarHeight,
                      background: _buildHeaderBackground(isNight),
                      colors: colors,
                      pinnedRowBuilder: (t) => _buildPinnedRow(t, colors),
                      fullContentBuilder: () => _buildFullHeaderContent(colors),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildLocationBanner(colors)),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      12.h,
                      16.w,
                      MediaQuery.of(context).padding.bottom + 110.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _sectionTitle(colors, 'জরুরি সতর্কবার্তা', 'Emergency Alerts'),
                        SizedBox(height: 10.h),
                        AlertCarousel(alerts: controller.alerts),
                        SizedBox(height: 20.h),
                        _sectionTitle(colors, 'দুর্যোগ পরিস্থিতি', 'Hazards'),
                        SizedBox(height: 10.h),
                        HazardGrid(
                          hazards: controller.hazards,
                          onTap: (hazard) {
                            // TODO: hazard details page - phase 2
                          },
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildHeaderBackground(bool isNight) {
    return Obx(() {
      final videoUrl = controller.liveVideoUrl.value;
      final hasVideo = videoUrl.isNotEmpty;
      final videoVisible = hasVideo && _videoReady.value;

      if (!hasVideo && _videoReady.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _videoReady.value = false);
      }

      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isNight ? 'assets/night.jpg' : 'assets/day.jpg',
              fit: BoxFit.cover,
            ),
          ),
          if (hasVideo)
            Positioned.fill(
              child: WeatherVideoBackground(
                key: ValueKey(videoUrl),
                videoUrl: videoUrl,
                onReadyChanged: (ready) => _videoReady.value = ready,
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: videoVisible
                        ? [
                            Colors.black.withOpacity(0.50),
                            Colors.black.withOpacity(0.15),
                            Colors.black.withOpacity(0.20),
                          ]
                        : [
                            Colors.black.withOpacity(isNight ? 0.55 : 0.72),
                            Colors.black.withOpacity(isNight ? 0.25 : 0.42),
                            Colors.black.withOpacity(isNight ? 0.65 : 0.78),
                          ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPinnedRow(double t, AppThemeColors colors) {
    final fontSize = 18.sp - (18.sp - 16.sp) * t;
    final titleColor = Color.lerp(colors.headerText, colors.textPrimary, t)!;
    final subtitleColor = Color.lerp(colors.headerSecondaryText, colors.textSecondary, t)!;

    return SizedBox(
      height: 56.h,
      width: double.infinity,
      child: Center(
        child: GestureDetector(
          onTap: controller.openLocationSelector,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 220.w),
                    child: Obx(() => Text(
                          controller.currentLocationName.value,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.style(
                              fontSize: fontSize, color: titleColor, fontWeight: FontWeight.w600),
                        )),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: titleColor, size: 20.r),
                ],
              ),
              Obx(() {
                final current = controller.forecast.value?.result?.current;
                return Text(
                  "${current?.weekday ?? ''}, ${current?.date ?? ''}",
                  style: AppFonts.style(fontSize: 11.sp, color: subtitleColor),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullHeaderContent(AppThemeColors colors) {
    return Obx(() {
      if (controller.isLocationSwitching.value) {
        return _buildLocationSwitchingLoader();
      }
      if (controller.forecast.value != null) {
        if (controller.isLiveWeatherLoading.value) {
          return Stack(
            children: [
              _buildWeatherCard(),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: SizedBox(
                  width: 30.r,
                  height: 30.r,
                  child: lottie.Lottie.asset('assets/json/loading_anim.json', repeat: true),
                ),
              ),
            ],
          );
        }
        return _buildWeatherCard();
      }
      return _buildNoDataCard();
    });
  }

  Widget _buildWeatherCard() {
    final current = controller.forecast.value?.result?.current;
    final daily = controller.forecast.value?.result?.daily;
    final firstDaily = (daily != null && daily.isNotEmpty) ? daily.first : null;
    final currentMaxTemp = firstDaily?.temp?.valMax ?? '0';
    final currentMinTemp = firstDaily?.temp?.valMin ?? '0';
    if (current == null) return const SizedBox.shrink();

    return Obx(() {
      final isBangla = controller.userService.isBangla;
      final liveType = controller.liveWeatherType.value;
      final displayType = liveType.isNotEmpty ? liveType : (current.type ?? 'N/A');

      final liveTemp = controller.liveTemp.value;
      final liveFeelsLike = controller.liveFeelsLike.value;
      final liveRainfall = controller.liveRainfall.value;

      final displayTemp = liveTemp.isNotEmpty ? liveTemp : (current.temp?.valAvg ?? '0');
      final displayFeelsLike = WeatherUtils.roundAndLocalize(
          liveFeelsLike.isNotEmpty ? liveFeelsLike : current.feels);
      final displayRain =
          liveRainfall.isNotEmpty ? WeatherUtils.roundAndLocalize(liveRainfall) : null;

      final feelsLabel = isBangla ? 'অনুভূত হচ্ছে' : 'Feels like';

      return BaseWeatherCard(
        temp: displayTemp,
        tempMax: currentMaxTemp,
        tempMin: currentMinTemp,
        tempUnit: current.tempUnit ?? '°C',
        rainMin: displayRain ?? current.rf?.valMin ?? '0',
        rainMax: displayRain ?? current.rf?.valMax ?? '0',
        rainUnit: current.rfUnit ?? 'mm',
        feelsLike: '$feelsLabel $displayFeelsLike°',
        type: displayType,
        isBangla: isBangla,
      );
    });
  }

  Widget _buildLocationBanner(AppThemeColors colors) {
    return Obx(() {
      final isBangla = controller.userService.isBangla;
      final serviceOn = controller.locationServiceEnabled.value;
      final permissionGranted = controller.locationPermissionGranted.value;
      final isUpdating = controller.isLocationUpdating.value;

      if (serviceOn && permissionGranted) return const SizedBox.shrink();

      final String message;
      final String buttonLabel;
      final Color bannerColor;
      final IconData bannerIcon;

      if (!permissionGranted) {
        message = isBangla
            ? 'সঠিক আবহাওয়া দেখতে অবস্থান অনুমতি দিন'
            : 'Allow location to see weather for your area';
        buttonLabel = isBangla ? 'অনুমতি দিন' : 'Allow';
        bannerColor = Colors.blue.shade700;
        bannerIcon = Icons.location_off_outlined;
      } else {
        message = isBangla
            ? 'সঠিক আবহাওয়া দেখতে লোকেশন চালু করুন'
            : 'Turn on location for accurate local weather';
        buttonLabel = isBangla ? 'চালু করুন' : 'Enable';
        bannerColor = Colors.orange.shade700;
        bannerIcon = Icons.location_disabled_outlined;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        color: bannerColor.withOpacity(0.92),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(bannerIcon, color: Colors.white, size: 18.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(message,
                  style: AppFonts.style(color: Colors.white, fontSize: 12.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            SizedBox(width: 8.w),
            if (isUpdating)
              SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else
              GestureDetector(
                onTap: controller.requestLocationFromBanner,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white54),
                  ),
                  child: Text(buttonLabel,
                      style: AppFonts.style(
                          color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () {
                controller.locationPermissionGranted.value = true;
                controller.locationServiceEnabled.value = true;
              },
              child: Icon(Icons.close, color: Colors.white70, size: 16.r),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(AppThemeColors c, String bn, String en) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(bn, style: AppTextStyles.sectionTitle(c.textPrimary)),
        SizedBox(width: 6.w),
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Text(en, style: AppTextStyles.caption(c.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: lottie.Lottie.asset('assets/json/loading_anim.json', width: 100.r, repeat: true),
      ),
    );
  }

  Widget _buildNoDataCard() {
    final isBangla = controller.userService.isBangla;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 50.r),
          SizedBox(height: 12.h),
          Text(
            isBangla ? 'কোন তথ্য পাওয়া যায়নি' : 'No Data Available',
            style:
                AppFonts.style(fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white),
          ),
          Text(
            isBangla
                ? 'অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন'
                : 'Please check your internet connection to load data',
            style: AppFonts.style(fontSize: 14.sp, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          ElevatedButton(
            onPressed: controller.onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            ),
            child: Text(isBangla ? 'পুনরায় চেষ্টা করুন' : 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSwitchingLoader() {
    final isBangla = controller.userService.isBangla;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          lottie.Lottie.asset('assets/json/loading_anim.json', width: 70.r, height: 70.r, repeat: true),
          SizedBox(height: 8.h),
          Text(
            isBangla ? 'লোকেশন পরিবর্তন হচ্ছে...' : 'Switching location...',
            style: AppFonts.style(fontSize: 14.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// COLLAPSING WEATHER HEADER DELEGATE
// ─────────────────────────────────────────────────────────────────────────

class _WeatherHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double statusBarHeight;
  final Widget background;
  final AppThemeColors colors;
  final Widget Function(double t) pinnedRowBuilder;
  final Widget Function() fullContentBuilder;

  _WeatherHeaderDelegate({
    required this.statusBarHeight,
    required this.background,
    required this.colors,
    required this.pinnedRowBuilder,
    required this.fullContentBuilder,
  });

  @override
  double get maxExtent => 215.h + statusBarHeight;

  @override
  double get minExtent => 56.h + statusBarHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(child: background),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors.headerGradientColors,
                stops: colors.headerGradientStops,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: colors.scaffoldGradientTop.withOpacity((t * 1.1).clamp(0.0, 1.0)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 48.h,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.scaffoldBg.withOpacity(0.001),
                    colors.scaffoldBg.withOpacity(isDark ? 1.0 : 0.88),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: statusBarHeight,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              pinnedRowBuilder(t),
              Opacity(
                opacity: (1.0 - t * 1.6).clamp(0.0, 1.0),
                child: IgnorePointer(
                  ignoring: t > 0.5,
                  child: Transform.translate(
                    offset: Offset(0, -shrinkOffset * 0.5),
                    child: fullContentBuilder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _WeatherHeaderDelegate oldDelegate) {
    return statusBarHeight != oldDelegate.statusBarHeight ||
        background != oldDelegate.background ||
        colors != oldDelegate.colors;
  }
}
