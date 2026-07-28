import 'package:aware/core/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_fonts.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/utils/convert_utils.dart';
import '../../../../features/drawer/presentation/widgets/app_drawer.dart';
import '../../../../shared/widgets/bilingual_label.dart';
import '../controllers/home_controller.dart';
import '../widgets/hazard_grid.dart';
import '../widgets/header_notification_carousel.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/ongoing_bulletin_carousel.dart';
import '../widgets/weather/base_weather_card.dart';
import '../widgets/weather/weather_video_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final HomeController controller = Get.find<HomeController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final RxBool _videoReady = false.obs;

  // The header photo (dark gradient overlay) sits behind the status bar
  // until the header collapses to the plain scaffold background - icons
  // must stay light over the photo regardless of app theme, matching
  // headerText always being white (see AppThemeColors.headerText).
  bool _headerCollapsed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onScroll() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final carouselHeight = controller.notifications.isNotEmpty ? 56.h : 0.h;
    final maxExtent = 215.h + carouselHeight + statusBarHeight;
    final minExtent = 56.h + statusBarHeight;
    final t = (_scrollController.offset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final collapsed = t > 0.6;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
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
          statusBarIconBrightness: !_headerCollapsed
              ? Brightness.light
              : (isDark ? Brightness.light : Brightness.dark),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          backgroundColor: colors.scaffoldBg,
          drawer: const AppDrawer(),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.scaffoldGradientTop, colors.scaffoldGradientBottom],
                begin: Alignment.
                topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: RefreshIndicator(
              onRefresh: controller.onRefresh,
              edgeOffset: collapsedHeaderHeight,
              child: CustomScrollView(
                controller: _scrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _WeatherHeaderDelegate(
                      statusBarHeight: statusBarHeight,
                      background: _buildHeaderBackground(isNight),
                      colors: colors,
                      hasCarousel: controller.notifications.isNotEmpty,
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
                        Obx(() {
                          if (controller.isOngoingBulletinsLoading.value &&
                              controller.ongoingBulletins.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(colors, 'চলমান বুলেটিন', 'Ongoing Bulletin'),
                                SizedBox(height: 10.h),
                                const BulletinCarouselShimmer(),
                                SizedBox(height: 20.h),
                              ],
                            );
                          }
                          if (controller.ongoingBulletins.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(colors, 'চলমান বুলেটিন', 'Ongoing Bulletin'),
                              SizedBox(height: 10.h),
                              OngoingBulletinCarousel(
                                  bulletins: controller.ongoingBulletins.toList()),
                              SizedBox(height: 20.h),
                            ],
                          );
                        }),
                        _sectionTitle(colors, 'দুর্যোগ পরিস্থিতি', 'Hazards'),
                        SizedBox(height: 10.h),
                        Obx(() {
                          if (controller.isHazardsLoading.value && controller.hazards.isEmpty) {
                            return const HazardGridShimmer();
                          }
                          return HazardGrid(
                            hazards: controller.hazards.toList(),
                            onTap: (hazard) {
                              if (hazard.url.isEmpty) return;
                              final currentLang = Get.find<UserPrefService>().appLanguage;
                              Get.toNamed(AppRoutes.hazardDetails, arguments: {
                                'title': hazard.localizedTitle(currentLang),
                                'url': hazard.url,
                              });
                            },
                          );
                        }),
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
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: controller.openLocationSelector,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final name = controller.currentLocationName.value;
                    if (name.isEmpty) return const SizedBox.shrink();
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 220.w),
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.style(
                                fontSize: fontSize, color: titleColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: titleColor, size: 20.r),
                      ],
                    );
                  }),
                  Obx(() {
                    final current = controller.forecast.value?.result?.current;
                    final weekday = current?.weekday ?? '';
                    final date = current?.date ?? '';
                    // Same "empty comma" problem as the name row above -
                    // don't show ", " before there's actually a date.
                    if (weekday.isEmpty && date.isEmpty) return const SizedBox.shrink();
                    return Text(
                      "$weekday, $date",
                      style: AppFonts.style(fontSize: 11.sp, color: subtitleColor),
                    );
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E9E),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(Icons.menu, color: titleColor, size: 20.r),
                    )),
              ),
            ),
          ),
          Positioned(
            right: 10.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.notifications),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E9E),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.notifications_active_outlined, color: titleColor, size: 20.r),
                      )))
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullHeaderContent(AppThemeColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Obx(() {
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
          // does not - without it the no-data card could flash while that
          // fetch is still in flight.
          final stillResolving = controller.isForecastLoading.value ||
              controller.isLocationUpdating.value ||
              (controller.lat.value.isEmpty && controller.isSyncingLocation.value);
          if (stillResolving) {
            return _buildHeaderLoading(controller.lat.value.isEmpty);
          }
          return _buildNoDataCard();
        }),
        _buildCarouselAlert(),
      ],
    );
  }

  Widget _buildCarouselAlert() {
    return Obx(() {
      final notifications = controller.notifications;
      if (notifications.isEmpty) return const SizedBox.shrink();
      return HeaderNotificationCarousel(notifications: notifications.toList());
    });
  }

  Widget _buildHeaderLoading(bool isResolvingLocation) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          lottie.Lottie.asset('assets/json/loading_anim.json', width: 70.r, height: 70.r, repeat: true),
          SizedBox(height: 8.h),
          Text(
            (isResolvingLocation ? 'resolving_location' : 'loading_weather').tr,
            style: AppFonts.style(fontSize: 14.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    final current = controller.forecast.value?.result?.current;
    final daily = controller.forecast.value?.result?.daily;
    final firstDaily = (daily != null && daily.isNotEmpty) ? daily.first : null;
    final currentMaxTemp = firstDaily?.temp?.valMax ?? '0';
    final currentMinTemp = firstDaily?.temp?.valMin ?? '0';
    if (current == null) return const SizedBox.shrink();

    return Obx(() {
      final liveType = controller.liveWeatherType.value;
      final displayType = liveType.isNotEmpty ? liveType : (current.type ?? 'N/A');

      final liveTemp = controller.liveTemp.value;
      final liveFeelsLike = controller.liveFeelsLike.value;
      final liveRainfall = controller.liveRainfall.value;

      final displayTemp = liveRainfall.isNotEmpty ? liveTemp : (current.temp?.valAvg ?? '0');
      final displayFeelsLike = WeatherUtils.roundAndLocalize(
          liveRainfall.isNotEmpty ? liveFeelsLike : current.feels);
      final displayRain =
          liveRainfall.isNotEmpty ? WeatherUtils.roundAndLocalize(liveRainfall) : null;

      final liveIcon = controller.liveWeatherIcon.value;
      final forecastIcon = current.icon ?? 'N/A';
      final displayIcon = liveIcon.isNotEmpty ? liveIcon : forecastIcon;

      return BaseWeatherCard(
        temp: displayTemp,
        icon: "${ApiEndpoints.baseIconUrl}/$displayIcon",
        tempMax: currentMaxTemp,
        tempMin: currentMinTemp,
        tempUnit: current.tempUnit ?? '°C',
        rainMin: displayRain ?? current.rf?.valMin ?? '0',
        rainMax: displayRain ?? current.rf?.valMax ?? '0',
        rainUnit: current.rfUnit ?? 'mm',
        feelsLike: '${'feels_like_label'.tr} $displayFeelsLike°',
        type: displayType,
      );
    });
  }

  Widget _buildLocationBanner(AppThemeColors colors) {
    return Obx(() {
      final serviceOn = controller.locationServiceEnabled.value;
      final permissionGranted = controller.locationPermissionGranted.value;
      final isUpdating = controller.isLocationUpdating.value;

      if (serviceOn && permissionGranted) return const SizedBox.shrink();

      final String message;
      final String buttonLabel;
      final Color bannerColor;
      final IconData bannerIcon;

      if (!permissionGranted) {
        message = 'banner_allow_location'.tr;
        buttonLabel = 'allow'.tr;
        bannerColor = Colors.blue.shade700;
        bannerIcon = Icons.location_off_outlined;
      } else {
        message = 'banner_turn_on_location'.tr;
        buttonLabel = 'enable'.tr;
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
    return BilingualLabel(
      bn: bn,
      en: en,
      activeColor: c.textPrimary,
      inactiveColor: c.textSecondary,
      activeSize: 17,
      inactiveSize: 12,
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 32.r),
          SizedBox(height: 8.h),
          Text(
            'no_data_available'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                AppFonts.style(fontWeight: FontWeight.bold, fontSize: 15.sp, color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            'check_internet_connection'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.style(fontSize: 11.sp, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: controller.retryLoadingData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.92),
              foregroundColor: Colors.black87,
              elevation: 0,
              minimumSize: Size(0, 32.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 6.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            ),
            child: Text('retry'.tr,
                style: AppFonts.style(fontWeight: FontWeight.w700, fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSwitchingLoader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          lottie.Lottie.asset('assets/json/loading_anim.json', width: 70.r, height: 70.r, repeat: true),
          SizedBox(height: 8.h),
          Text(
            'switching_location'.tr,
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
  final bool hasCarousel;

  _WeatherHeaderDelegate({
    required this.statusBarHeight,
    required this.background,
    required this.colors,
    required this.pinnedRowBuilder,
    required this.fullContentBuilder,
    required this.hasCarousel,
  });

  @override
  double get maxExtent {
    final carouselHeight = hasCarousel ? 56.h : 0.h;
    return 215.h + carouselHeight + statusBarHeight;
  }

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
        colors != oldDelegate.colors ||
        hasCarousel != oldDelegate.hasCarousel;
  }
}
