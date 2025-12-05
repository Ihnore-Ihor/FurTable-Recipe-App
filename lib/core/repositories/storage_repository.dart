import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageRepository {
  // Отримуємо клієнт Supabase
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Метод завантаження
  Future<String> uploadImageBytes(Uint8List data, String folder) async {
    try {
      // 1. Генеруємо унікальну назву файлу (наприклад: "a1b2-c3d4.jpg")
      final String fileName = '${_uuid.v4()}.jpg';
      final String path = fileName; // В корінь бакета

      // 2. Завантажуємо файл у бакет 'recipe_images'
      await _supabase.storage
          .from('recipe_images')
          .uploadBinary(
            path,
            data,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // Перезаписати, якщо існує (малоймовірно з uuid)
            ),
          );

      // 3. Отримуємо публічне посилання на файл
      final String publicUrl = _supabase.storage
          .from('recipe_images')
          .getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
