import 'dart:math';
import 'package:flutter/material.dart';

class AvatarHelper {
  static const List<String> avatars = [
    'assets/images/legoshi_eating_auth.png',
    'assets/images/gohin_empty.png',
    'assets/images/legom_posing.png',
  ];

  static const String defaultAvatar = 'assets/images/legoshi_eating_auth.png';

  // Returns a random avatar path
  static String getRandomAvatar() {
    return avatars[Random().nextInt(avatars.length)];
  }

  // Universal method to get ImageProvider
  static ImageProvider getAvatarProvider(String? path) {
    // If it's a Google link (http), we ignore it and give default (or random could be used logic elsewhere),
    // OR you can allow it, but you said you don't want Google photos.
    if (path == null || path.isEmpty || path.startsWith('http')) {
      return const AssetImage(defaultAvatar);
    }
    return AssetImage(path);
  }
}
