import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences.
class LocalStorageService {
  // We no longer use a static constant for the key,
  // but generate it dynamically
  String _getHistoryKey(String userId) => 'search_history_$userId';

  /// Saves a search query to the local history for a specific user.
  ///
  /// Adds the [query] to the beginning of the list, removing duplicates.
  /// Keeps only the latest 5 entries.
  Future<void> saveSearchQuery(String query, String userId) async {
    if (query.isEmpty || userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = _getHistoryKey(userId);

    List<String> history = prefs.getStringList(key) ?? [];

    // Remove duplicates and insert new query at the beginning.
    history.remove(query);
    history.insert(0, query);

    // Limit history to the last 5 entries.
    if (history.length > 5) {
      history = history.sublist(0, 5);
    }

    await prefs.setStringList(key, history);
  }

  /// Retrieves the search history from local storage for a specific user.
  Future<List<String>> getSearchHistory(String userId) async {
    if (userId.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_getHistoryKey(userId)) ?? [];
  }

  /// Clears the entire search history for a specific user.
  Future<void> clearHistory(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getHistoryKey(userId));
  }
}
