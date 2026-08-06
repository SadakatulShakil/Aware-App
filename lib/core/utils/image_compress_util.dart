import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Compresses [bytes] to a JPEG under [maxBytes], reducing quality first and
/// falling back to downscaling dimensions if quality alone isn't enough.
/// Best-effort - returns the smallest result achieved even if it's still
/// over the limit (e.g. a very busy/high-detail source image).
Future<Uint8List> compressImageUnderLimit(
  Uint8List bytes, {
  int maxBytes = 100 * 1024,
}) async {
  int quality = 90;
  int minWidth = 1280;
  int minHeight = 1280;

  Uint8List current = await FlutterImageCompress.compressWithList(
    bytes,
    quality: quality,
    minWidth: minWidth,
    minHeight: minHeight,
    format: CompressFormat.jpeg,
  );

  while (current.lengthInBytes > maxBytes && quality > 10) {
    quality -= 15;
    current = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.jpeg,
    );
  }

  while (current.lengthInBytes > maxBytes && minWidth > 240) {
    minWidth = (minWidth * 0.7).round();
    minHeight = (minHeight * 0.7).round();
    current = await FlutterImageCompress.compressWithList(
      bytes,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.jpeg,
    );
  }

  return current;
}
