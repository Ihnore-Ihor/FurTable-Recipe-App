// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class SplashHandler {
  static void remove() {
    try {
      final loader = html.document.getElementById('splash-container');
      if (loader != null) {
        loader.style.opacity = '0';
        // Wait for CSS transition (0.5s) then remove from DOM.
        Future.delayed(const Duration(milliseconds: 500), () {
          loader.remove();
        });
      }
    } catch (e) {
      // ignore errors in non-browser environments or if element is missing.
    }
  }
}
