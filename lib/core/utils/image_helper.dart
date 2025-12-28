import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:heckofaheic/heckofaheic.dart';

class ImageHelper {
  // Goal: 100 KB
  static const int targetSize = 100 * 1024; 

  static Future<Uint8List> compressImage(Uint8List sourceBytes) async {
    Uint8List bytesToCompress = sourceBytes;

    // 1. HEIC Conversion (if needed)
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

    // 2. Smart compression
    int quality = 90;
    int minWidth = 1080; // Start with Full HD
    
    Uint8List resultBytes = bytesToCompress;

    // Initial attempt to convert to WebP to unify format
    try {
      resultBytes = await FlutterImageCompress.compressWithList(
        bytesToCompress,
        minHeight: minWidth,
        minWidth: minWidth,
        quality: quality,
        format: CompressFormat.webp,
      );
    } catch (_) {}

    // Loop: While size > 100KB
    while (resultBytes.lengthInBytes > targetSize) {
      // Strategy: First reduce quality. If quality is already low - cut size.
      
      if (quality > 50) {
        quality -= 15; // Quickly reduce quality
      } else {
        // If quality is already 50%, and file is still big -> reduce image size
        minWidth = (minWidth * 0.8).toInt(); // -20% size
        if (minWidth < 300) break; // Don't go smaller than 300px (avatar)
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
        print("Compression error: $e");
        break; // Exit to avoid hanging
      }
    }

    return resultBytes;
  }

  static bool isImage(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return true; 
  }
}
