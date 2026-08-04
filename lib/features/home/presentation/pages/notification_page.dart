import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../../../../app/theme/app_fonts.dart';
import '../../../../app/theme/app_theme_colors.dart';
import '../../../../core/services/user_pref_service.dart';
import '../../../../core/utils/tts_text_helper.dart';
import '../../data/models/notification_model.dart';
import '../controllers/home_controller.dart';

/// Lists fetched notifications - ported from BMD's NotificationPage, scoped
/// to AWARE's actual data (NotificationModel, already mapped from BMD's
/// notification/list API in HomeRepository). Each card has BMD's exact
/// audio-player TTS widget (see _NotificationCardState._buildAudioPlayer).
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

// ════════════════════════════════════════════════════════════════════════
// NOTIFICATION CARD WITH WORKING TTS + PROGRESS
// ════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatefulWidget {
  final NotificationModel notification;
  final AppThemeColors colors;

  const _NotificationCard({required this.notification, required this.colors});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> with WidgetsBindingObserver {
  // Only one card should ever be speaking at a time - starting a new one
  // stops whichever card was previously active (BMD used one FlutterTts
  // per card with no such coordination, which let two cards overlap).
  static _NotificationCardState? _activePlayer;

  late FlutterTts flutterTts;
  // Reactive state - Obx() in build() watches these for efficient UI updates
  final _isPlaying = false.obs;
  final _isPaused = false.obs;
  final _duration = Duration.zero.obs;
  final _position = Duration.zero.obs;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    // 1. Tell Flutter we want to listen to app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _initializeTts();
  }

  @override
  void dispose() {
    // 2. Stop listening when this card is destroyed
    WidgetsBinding.instance.removeObserver(this);

    _progressTimer?.cancel();
    flutterTts.stop();
    if (_activePlayer == this) _activePlayer = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the app goes to the background or is closed
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      if (_isPlaying.value) {
        // 1. Force the native TTS engine to stop instantly
        flutterTts.stop();

        // 2. Reset the play button and slider in the UI
        if (mounted) {
          _isPlaying.value = false;
          _isPaused.value = false;
          _position.value = Duration.zero;
        }
        if (_activePlayer == this) _activePlayer = null;
      }
    }
  }

  void _initializeTts() {
    flutterTts = FlutterTts();
    // AWARE reads language from UserPrefService (not Get.locale like BMD)
    // - re-read fresh here so cards created after a language toggle speak
    // in the right language from the start.
    final bool isBangla = Get.find<UserPrefService>().isBangla;
    flutterTts.setLanguage(isBangla ? 'bn-BD' : 'en-US');
    flutterTts.setSpeechRate(isBangla ? 0.42 : 0.35);
    flutterTts.setVolume(1.0);
    flutterTts.setPitch(isBangla ? 0.95 : 1.0);

    flutterTts.completionHandler = _onSpeechComplete;
    flutterTts.errorHandler = _onTtsError;

    // The native word/range progress callback (setProgressHandler) isn't
    // reliably fired by every Android TTS engine - some never call it at
    // all, which left the slider frozen. A simple timer against the
    // estimated duration (see _startProgressTimer) works everywhere.
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_isPlaying.value || _isPaused.value) return;
      final next = _position.value + const Duration(milliseconds: 200);
      _position.value = next >= _duration.value ? _duration.value : next;
    });
  }

  void _onSpeechComplete() {
    _progressTimer?.cancel();
    if (mounted) {
      _isPlaying.value = false;
      _isPaused.value = false;
      _position.value = Duration.zero;
    }
    if (_activePlayer == this) _activePlayer = null;
  }

  void _onTtsError(dynamic error) {
    _progressTimer?.cancel();
    debugPrint('TTS Error: $error');
    if (mounted) {
      _isPlaying.value = false;
      _isPaused.value = false;
    }
    if (_activePlayer == this) _activePlayer = null;

    final isBangla = Get.find<UserPrefService>().isBangla;
    Get.snackbar(
      isBangla ? 'শোনাতে সমস্যা হয়েছে' : 'Playback Error',
      TtsTextHelper.getTtsErrorMessage(error, isBangla: isBangla),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _speak() async {
    // Guard against double-tap: this flips true synchronously (before any
    // await below), so a second tap landing while setLanguage/setSpeechRate
    // /setPitch are still in flight sees _isPlaying == true and routes to
    // pause instead of calling _speak (and thus flutterTts.speak) again -
    // that race was why playback fired twice.
    if (_isPlaying.value) return;
    final rawText = _getFullText();
    if (rawText.isEmpty) return;

    _isPlaying.value = true;
    _isPaused.value = false;

    // Only one card talks at a time - stop whatever was previously
    // playing (and reset its own UI) before starting this one.
    if (_activePlayer != null && _activePlayer != this) {
      await _activePlayer!._stop();
    }
    _activePlayer = this;

    // Re-read fresh so a language toggle mid-session speaks correctly.
    final isBangla = Get.find<UserPrefService>().isBangla;
    await flutterTts.setLanguage(isBangla ? 'bn-BD' : 'en-US');
    await flutterTts.setSpeechRate(isBangla ? 0.42 : 0.35);
    await flutterTts.setPitch(isBangla ? 0.95 : 1.0);

    final cleanText = TtsTextHelper.sanitizeTextForBanglaTTS(rawText, isBangla: isBangla);

    // Estimate duration (adjust 90 if it finishes too early or too late)
    final estimatedMs = (cleanText.length * 90).round();

    _duration.value = Duration(milliseconds: estimatedMs);
    _position.value = Duration.zero;

    // Flush any stale queued utterance before starting a fresh one.
    await flutterTts.stop();
    _startProgressTimer();
    await flutterTts.speak(cleanText);
  }

  Future<void> _pause() async {
    _progressTimer?.cancel();
    await flutterTts.pause();
    if (mounted) _isPaused.value = true;
  }

  Future<void> _resume() async {
    final isBangla = Get.find<UserPrefService>().isBangla;
    await flutterTts.setLanguage(isBangla ? 'bn-BD' : 'en-US');
    final cleanText =
        TtsTextHelper.sanitizeTextForBanglaTTS(_getFullText(), isBangla: isBangla);
    if (mounted) {
      _isPaused.value = false;
      // flutter_tts has no real resume-from-position on Android - this
      // re-speaks from the start, so the slider must restart too or it'd
      // show a mid-point position while the audio is actually at 0:00.
      _position.value = Duration.zero;
    }
    _startProgressTimer();
    await flutterTts.speak(cleanText);
  }

  Future<void> _stop() async {
    _progressTimer?.cancel();
    await flutterTts.stop();
    if (mounted) {
      _isPlaying.value = false;
      _isPaused.value = false;
      _position.value = Duration.zero;
    }
    if (_activePlayer == this) _activePlayer = null;
  }

  // BMD spoke only title; our NotificationModel also carries message, so
  // both are read when they actually differ. Today the API only exposes
  // a single title field and HomeRepository maps message to that same
  // value (see _toNotification), so speaking both would just read the
  // same sentence twice - collapse to one when they match.
  String _getFullText() {
    final n = widget.notification;
    final title = n.title.trim();
    final message = n.message.trim();
    if (message.isEmpty || message == title) return title;
    return '$title. $message';
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isAlert = widget.notification.severity != 'normal';
    final iconBg = isAlert
        ? Colors.orange.withOpacity(0.12)
        : widget.colors.primary.withOpacity(0.10);
    final iconColor = isAlert ? Colors.orange.shade700 : widget.colors.primary;

    return Container(
      decoration: BoxDecoration(
        color: widget.colors.cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: widget.colors.divider),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      widget.notification.title.isNotEmpty
                          ? widget.notification.title
                          : 'no_title'.tr,
                      style: AppFonts.style(
                          fontSize: 14.sp, color: widget.colors.textPrimary, height: 1.2),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12.sp, color: widget.colors.textSecondary),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('d MMM, hh:mm a').format(widget.notification.updatedAt),
                          style: AppFonts.style(fontSize: 12.sp, color: widget.colors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildAudioPlayer(),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    const accentColor = Color(0xFF00D3B9);

    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _isPlaying.value ? (_isPaused.value ? _resume : _pause) : _speak,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(color: accentColor, shape: BoxShape.circle),
                      child: Icon(
                        _isPlaying.value
                            ? (_isPaused.value ? Icons.play_arrow : Icons.pause)
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4.h,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 12.r),
                        ),
                        child: Slider(
                          value: _position.value.inSeconds.toDouble(),
                          max: _duration.value.inSeconds.toDouble() > 0
                              ? _duration.value.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (_) {},
                          activeColor: accentColor,
                          inactiveColor: accentColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _stop,
                    child: Icon(Icons.replay, color: accentColor, size: 18.sp),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${_formatDuration(_position.value)} / ${_formatDuration(_duration.value)}',
                  style: AppFonts.style(fontSize: 11.sp, color: widget.colors.textSecondary),
                ),
              ),
            ],
          ),
        ));
  }
}
