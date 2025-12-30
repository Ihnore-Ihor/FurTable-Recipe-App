import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:heckofaheic/heckofaheic.dart';

class ImageHelper {
  static const int targetSize = 100 * 1024; // 100 KB

  static Future<Uint8List> compressImage(Uint8List sourceBytes) async {
    Uint8List bytesToCompress = sourceBytes;

    // 1. HEIC -> JPEG
    if (HeckOfAHeic.isHEIC(sourceBytes)) {
      try {
        bytesToCompress = await HeckOfAHeic.convert(
          sourceBytes,
          toType: TargetType.jpeg,
        );
      } catch (e) {
        return sourceBytes;
      }
    }

    // 2. COMPRESS -> WEBP
    int quality = 90;
    int minWidth = 1080;
    
    Uint8List resultBytes = bytesToCompress;

    // Initial pass
    try {
      resultBytes = await FlutterImageCompress.compressWithList(
        bytesToCompress,
        minHeight: minWidth,
        minWidth: minWidth,
        quality: quality,
        format: CompressFormat.webp,
      );
    } catch (_) {}

    // Reduction loop
    while (resultBytes.lengthInBytes > targetSize) {
      if (quality > 50) {
        quality -= 15;
      } else {
        minWidth = (minWidth * 0.8).toInt();
        if (minWidth < 300) break;
      }

      try {
        final compressed = await FlutterImageCompress.compressWithList(
          bytesToCompress,
          minHeight: minWidth,
          minWidth: minWidth,
          quality: quality,
          format: CompressFormat.webp,
        );
        
        if (compressed.isNotEmpty) {
          resultBytes = compressed;
        }
      } catch (e) {
        break;
      }
    }

    return resultBytes;
  }

  // Helper method separate from compressImage
  static bool isImage(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return true; 
  }
}
