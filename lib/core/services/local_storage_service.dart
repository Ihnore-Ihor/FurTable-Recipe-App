import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences.
class LocalStorageService {
  static const _historyKey = 'search_history';

  /// Saves a search query to the local history.
  ///
  /// Adds the [query] to the beginning of the list, removing duplicates.
  /// Keeps only the latest 5 entries.
  Future<void> saveSearchQuery(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_historyKey) ?? [];

    // Remove duplicates and insert new query at the beginning.
    history.remove(query);
    history.insert(0, query);

    // Limit history to the last 5 entries.
    if (history.length > 5) {
      history = history.sublist(0, 5);
    }

    await prefs.setStringList(_historyKey, history);
  }

  /// Retrieves the search history from local storage.
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  /// Clears the entire search history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
