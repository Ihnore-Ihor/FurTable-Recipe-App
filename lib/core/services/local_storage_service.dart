import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  // Initialize at startup
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Search History ---
  String _getHistoryKey(String userId) => 'search_history_$userId';

  /// Saves a search query to the local history for a specific user.
  ///
  /// Adds the [query] to the beginning of the list, removing duplicates.
  /// Keeps only the latest 5 entries.
  Future<void> saveSearchQuery(String query, String userId) async {
    if (query.isEmpty || userId.isEmpty) return;
    // Use the initialized _prefs or fall back to getting instance (safety)
    final prefs = _prefs ?? await SharedPreferences.getInstance();
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
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getStringList(_getHistoryKey(userId)) ?? [];
  }

  /// Clears the entire search history for a specific user.
  Future<void> clearHistory(String userId) async {
    if (userId.isEmpty) return;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.remove(_getHistoryKey(userId));
  }

  // --- CACHE SETTINGS ---
  static const String _keyEnableCache = 'enable_cache';
  static const String _keyAutoClear = 'auto_clear_cache';

  bool get isCacheEnabled => _prefs?.getBool(_keyEnableCache) ?? true;
  bool get isAutoClearEnabled => _prefs?.getBool(_keyAutoClear) ?? false;

  Future<void> setCacheEnabled(bool value) async => await _prefs?.setBool(_keyEnableCache, value);
  Future<void> setAutoClearEnabled(bool value) async => await _prefs?.setBool(_keyAutoClear, value);
}
