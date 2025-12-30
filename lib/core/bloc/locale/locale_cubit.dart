import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // For PlatformDispatcher

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCode = prefs.getString('language_code');

    if (savedCode != null) {
      // Якщо користувач вже обрав мову вручну
      emit(Locale(savedCode));
    } else {
      // Якщо це перший запуск - дивимося на систему
      final systemCode = PlatformDispatcher.instance.locale.languageCode;
      
      if (systemCode == 'uk') {
        emit(const Locale('uk'));
      } else {
        emit(const Locale('en'));
      }
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    emit(Locale(languageCode));
  }
}
