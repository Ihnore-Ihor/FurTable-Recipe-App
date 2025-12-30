import 'dart:math';
import 'package:flutter/material.dart';

class AvatarHelper {
  // Генеруємо список із 40 шляху автоматично
  static List<String> get avatars {
    return List.generate(
      40,
      (index) => 'assets/images/profile_pictures/avatar_${index + 1}.jpg',
    );
  }

  // Дефолтна аватарка (перша зі списку)
  static String get defaultAvatar => avatars[0];

  // Випадкова аватарка (для нових юзерів)
  static String getRandomAvatar() {
    return avatars[Random().nextInt(avatars.length)];
  }

  static ImageProvider getAvatarProvider(String? path) {
    // 1. Якщо шляху немає — даємо дефолт
    if (path == null || path.isEmpty) {
      return AssetImage(defaultAvatar);
    }

    // 2. Якщо це Google-фото (http)
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }

    // 3. Якщо це локальний ассет
    // (Тут буде працювати і для старих 'legoshi.png', якщо ви їх не видалили з папки images,
    // і для нових 'avatar_X.jpg')
    return AssetImage(path);
  }
}
