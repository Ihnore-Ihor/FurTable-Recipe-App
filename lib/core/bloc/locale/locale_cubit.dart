import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // For PlatformDispatcher

/// Manages the application-wide locale (language), persisting the selection to [SharedPreferences].
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedCode = prefs.getString('language_code');

    if (savedCode != null) {
      // If the user has already manually selected a language.
      emit(Locale(savedCode));
    } else {
      // On the first run, use the system locale.
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
