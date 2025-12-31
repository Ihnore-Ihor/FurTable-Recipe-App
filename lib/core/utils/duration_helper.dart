import 'package:flutter/widgets.dart';
import 'package:furtable/l10n/app_localizations.dart';

/// Helper class for localized duration formatting.
class DurationHelper {
  /// Formats the given [minutes] into a localized string (e.g., "1d 2h 30m").
  static String format(BuildContext context, int minutes) {
    if (minutes <= 0) return AppLocalizations.of(context)!.selectTime;
    
    final duration = Duration(minutes: minutes);
    final d = duration.inDays;
    final h = duration.inHours % 24;
    final m = duration.inMinutes % 60;
    
    final strDay = AppLocalizations.of(context)!.days;
    final strHour = AppLocalizations.of(context)!.hours;
    final strMin = AppLocalizations.of(context)!.mins;

    String result = '';
    if (d > 0) result += '$d$strDay ';
    if (h > 0) result += '$h$strHour ';
    if (m > 0 || result.isEmpty) result += '$m$strMin';
    
    return result.trim();
  }
}
