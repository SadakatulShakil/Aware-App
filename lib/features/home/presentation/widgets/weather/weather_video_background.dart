import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WeatherVideoBackground extends StatefulWidget {
  final String videoUrl;

  /// Fires true the moment the first real video frame is ready to
  /// render, false when the video is torn down. Lets the parent
  /// coordinate scrim/overlay changes with actual video visibility
  /// instead of URL arrival.
  final ValueChanged<bool>? onReadyChanged;

  const WeatherVideoBackground({
    super.key,
    required this.videoUrl,
    this.onReadyChanged,
  });

  @override
  State<WeatherVideoBackground> createState() => _WeatherVideoBackgroundState();
}

class _WeatherVideoBackgroundState extends State<WeatherVideoBackground>
    with WidgetsBindingObserver {
  // Videos bundled as local assets - play instantly, zero network.
  // Any filename NOT in this set falls back to network (future-proof
  // for the server adding new conditions).
  static const _bundledVideos = {
    'ic_rainfall.mp4',
    'ic_lightning.mp4',
  };

  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.videoUrl.isNotEmpty) _initVideo(widget.videoUrl);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _controller;
    if (ctrl == null || !_isReady) return;
    if (state == AppLifecycleState.resumed) {
      if (!ctrl.value.isPlaying) ctrl.play();
    } else if (state == AppLifecycleState.paused) {
      ctrl.pause();
    }
  }

  @override
  void didUpdateWidget(WeatherVideoBackground old) {
    super.didUpdateWidget(old);
    if (widget.videoUrl != old.videoUrl) {
      _disposeController();
      if (widget.videoUrl.isNotEmpty) _initVideo(widget.videoUrl);
    }
  }

  Future<void> _initVideo(String url) async {
    try {
      final fileName = url.split('/').last;

      final VideoPlayerController ctrl;
      if (_bundledVideos.contains(fileName)) {
        ctrl = VideoPlayerController.asset('assets/video/$fileName');
      } else {
        ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      }

      await ctrl.initialize();
      ctrl.setVolume(0.0);
      ctrl.setLooping(true);
      ctrl.play();

      if (mounted) {
        setState(() {
          _controller = ctrl;
          _isReady = true;
        });
        // Notify AFTER the frame so the parent's scrim change is
        // coordinated with actual video visibility, not URL arrival.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onReadyChanged?.call(true);
        });
      } else {
        ctrl.dispose();
      }
    } catch (_) {
      if (mounted) setState(() => _isReady = false);
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    if (_isReady) {
      _isReady = false;
      widget.onReadyChanged?.call(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _isReady ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 350),
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}
