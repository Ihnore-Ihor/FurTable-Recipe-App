import 'dart:math';
import 'package:flutter/material.dart';

/// Helper class for managing and providing user avatars.
class AvatarHelper {
  // Automatically generate a list of 40 avatar paths.
  static List<String> get avatars {
    return List.generate(
      40,
      (index) => 'assets/images/profile_pictures/avatar_${index + 1}.jpg',
    );
  }

  // Default avatar (the first one in the list).
  static String get defaultAvatar => avatars[0];

  // Random avatar (for new users).
  static String getRandomAvatar() {
    return avatars[Random().nextInt(avatars.length)];
  }

  static ImageProvider getAvatarProvider(String? path) {
    // 1. If the path is null or empty, return the default avatar.
    if (path == null || path.isEmpty) {
      return AssetImage(defaultAvatar);
    }

    // 2. If it's a Google photo (starts with http).
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    // 3. If it's a local asset.
    // Works for both legacy assets and the new avatar series.
    return AssetImage(path);
  }
}
