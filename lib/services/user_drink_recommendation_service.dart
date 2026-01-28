import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Service for managing user drink recommendations based on health conditions
/// Similar to UserDishRecommendationService but for drinks
class UserDrinkRecommendationService {
  static final UserDrinkRecommendationService _instance =
      UserDrinkRecommendationService._internal();

  factory UserDrinkRecommendationService() => _instance;

  UserDrinkRecommendationService._internal();

  // Cache data
  Set<int> _drinksToAvoid = {};
  Set<int> _drinksToRecommend = {};
  bool _isLoaded = false;
  DateTime? _lastLoaded;

  // Cache duration: 5 minutes
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Get set of drink IDs that should be avoided
  Set<int> get drinksToAvoid => Set.unmodifiable(_drinksToAvoid);

  /// Get set of drink IDs that are recommended
  Set<int> get drinksToRecommend => Set.unmodifiable(_drinksToRecommend);

  /// Check if a drink should be avoided
  bool shouldAvoidDrink(int drinkId) => _drinksToAvoid.contains(drinkId);

  /// Check if a drink is recommended
  bool isDrinkRecommended(int drinkId) => _drinksToRecommend.contains(drinkId);

  /// Load user drink recommendations from API
  Future<void> loadUserDrinkRecommendations({bool forceRefresh = false}) async {
    // Check cache validity
    if (_isLoaded &&
        !forceRefresh &&
        _lastLoaded != null &&
        DateTime.now().difference(_lastLoaded!) < _cacheDuration) {
      debugPrint('🍹 Using cached drink recommendations');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        debugPrint('No auth token found for drink recommendations');
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/suggestions/user-drink-recommendations',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final drinksAvoid = List<dynamic>.from(data['drinks_to_avoid'] ?? []);
        final drinksRecommend = List<dynamic>.from(
          data['drinks_to_recommend'] ?? [],
        );

        final avoidSet = drinksAvoid
            .map((d) => (d['drink_id'] as num?)?.toInt())
            .whereType<int>()
            .toSet();

        final recommendSet = drinksRecommend
            .map((d) => (d['drink_id'] as num?)?.toInt())
            .whereType<int>()
            .toSet();

        // IMPORTANT: If a drink is in both avoid and recommend (due to different conditions),
        // prioritize AVOID for user safety. Remove conflicts from recommend set.
        final conflicts = avoidSet.intersection(recommendSet);
        if (conflicts.isNotEmpty) {
          debugPrint(
            '⚠️  Conflict detected: ${conflicts.length} drinks are both avoid and recommend',
          );
          debugPrint('   Conflicting drink IDs: $conflicts');
          debugPrint('   → Prioritizing AVOID for safety');
        }

        _drinksToAvoid = avoidSet;
        // Remove conflicts: drinks that are marked to avoid should NOT be in recommend list
        _drinksToRecommend = recommendSet.difference(avoidSet);

        _isLoaded = true;
        _lastLoaded = DateTime.now();

        debugPrint('✅ Loaded user drink recommendations:');
        debugPrint('   Drinks to avoid: ${_drinksToAvoid.length}');
        debugPrint('   Drinks to recommend: ${_drinksToRecommend.length}');
      } else {
        debugPrint(
          'Failed to load drink recommendations: ${response.statusCode} ${response.body}',
        );
        _isLoaded = false;
      }
    } catch (e) {
      debugPrint('Error loading user drink recommendations: $e');
      _isLoaded = false;
    }
  }

  /// Clear cached data
  void clear() {
    _drinksToAvoid.clear();
    _drinksToRecommend.clear();
    _isLoaded = false;
    _lastLoaded = null;
    debugPrint('🧹 Cleared user drink recommendations cache');
  }

  /// Get debug information about current state
  String getDebugInfo() {
    return '''
UserDrinkRecommendationService Debug Info:
  Loaded: $_isLoaded
  Last Loaded: $_lastLoaded
  Drinks to Avoid: ${_drinksToAvoid.length} (${_drinksToAvoid.take(10).join(', ')})
  Drinks to Recommend: ${_drinksToRecommend.length} (${_drinksToRecommend.take(10).join(', ')})
  Cache Valid: ${_isLoaded && _lastLoaded != null && DateTime.now().difference(_lastLoaded!) < _cacheDuration}
''';
  }
}
