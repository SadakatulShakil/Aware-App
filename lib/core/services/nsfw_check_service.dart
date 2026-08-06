import 'dart:typed_data';

import 'package:nsfw_detector_flutter/nsfw_detector_flutter.dart';

import '../utils/app_logger.dart';

/// Result of an on-device nudity / misleading-image check.
///
/// [ran] is false when the detector could not run at all (e.g. unsupported
/// platform, model failed to load, corrupt image) - callers should fail
/// open in that case (treat [isSafe] as true) but tell the user the
/// automatic check was skipped, rather than silently blocking uploads.
class NsfwCheckResult {
  final bool isSafe;
  final double score;
  final bool ran;

  const NsfwCheckResult({required this.isSafe, required this.score, required this.ran});

  const NsfwCheckResult.unavailable()
      : isSafe = true,
        score = 0,
        ran = false;
}

/// Thin wrapper around nsfw_detector_flutter (on-device TFLite NSFW model).
/// Single gateway so the rest of the app never touches the plugin directly -
/// keeps init/dispose and failure handling in one place.
class NsfwCheckService {
  NsfwCheckService._();

  static final NsfwCheckService instance = NsfwCheckService._();

  bool _initialized = false;
  bool _unavailable = false;

  Future<void> _ensureInitialized() async {
    if (_initialized || _unavailable) return;
    try {
      await NsfwDetector.initialize();
      _initialized = true;
    } catch (e, st) {
      AppLogger.e('NSFW detector failed to initialize - checks will be skipped', e, st);
      _unavailable = true;
    }
  }

  Future<NsfwCheckResult> checkBytes(Uint8List bytes) async {
    await _ensureInitialized();
    if (_unavailable) return const NsfwCheckResult.unavailable();

    try {
      final result = await NsfwDetector.instance.detectNSFWFromBytes(bytes);
      if (result == null) return const NsfwCheckResult.unavailable();
      return NsfwCheckResult(
        isSafe: result.classification == NsfwClassification.safe,
        score: result.score,
        ran: true,
      );
    } catch (e, st) {
      AppLogger.e('NSFW detection failed for this image', e, st);
      return const NsfwCheckResult.unavailable();
    }
  }
}
