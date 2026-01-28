import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UserFoodRecommendationService {
  static final UserFoodRecommendationService _instance =
      UserFoodRecommendationService._internal();
  factory UserFoodRecommendationService() => _instance;
  UserFoodRecommendationService._internal();

  Set<int> _foodsToAvoid = {};
  Set<int> _foodsToRecommend = {};
  bool _isLoaded = false;
  DateTime? _lastLoaded;

  Set<int> get foodsToAvoid => _foodsToAvoid;
  Set<int> get foodsToRecommend => _foodsToRecommend;
  bool get isLoaded => _isLoaded;

  /// Load user's food recommendations based on their health conditions
  Future<void> loadUserFoodRecommendations({bool forceRefresh = false}) async {
    // Cache for 5 minutes
    if (_isLoaded &&
        !forceRefresh &&
        _lastLoaded != null &&
        DateTime.now().difference(_lastLoaded!) < const Duration(minutes: 5)) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _isLoaded = false;
        return;
      }

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/suggestions/user-food-recommendations',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final foodsToAvoidList = data['foods_to_avoid'] as List<dynamic>? ?? [];
        final foodsToRecommendList =
            data['foods_to_recommend'] as List<dynamic>? ?? [];

        // API returns array of objects like [{food_id: 1, name_vi: 'Mật ong', ...}, ...]
        final avoidSet = foodsToAvoidList
            .map(
              (item) => (item is Map ? item['food_id'] as int? : item as int?),
            )
            .whereType<int>()
            .toSet();

        final recommendSet = foodsToRecommendList
            .map(
              (item) => (item is Map ? item['food_id'] as int? : item as int?),
            )
            .whereType<int>()
            .toSet();

        // IMPORTANT: If a food is in both avoid and recommend (due to different conditions),
        // prioritize AVOID for user safety. Remove conflicts from recommend set.
        final conflicts = avoidSet.intersection(recommendSet);
        if (conflicts.isNotEmpty) {
          debugPrint(
            '⚠️  Conflict detected: ${conflicts.length} foods are both avoid and recommend',
          );
          debugPrint('   Conflicting food IDs: $conflicts');
          debugPrint('   → Prioritizing AVOID for safety');
        }

        _foodsToAvoid = avoidSet;
        _foodsToRecommend = recommendSet.difference(
          avoidSet,
        ); // Remove conflicts

        _isLoaded = true;
        _lastLoaded = DateTime.now();

        // Debug print
        debugPrint('🔴 UserFoodRecommendationService loaded:');
        debugPrint('   Foods to avoid: $_foodsToAvoid');
        debugPrint('   Foods to recommend: $_foodsToRecommend');
      } else {
        _isLoaded = false;
      }
    } catch (e) {
      _isLoaded = false;
      // Silent fail - food recommendations are optional
    }
  }

  /// Check if a food should be avoided
  bool shouldAvoidFood(int foodId) {
    return _foodsToAvoid.contains(foodId);
  }

  /// Check if a food is recommended
  bool isFoodRecommended(int foodId) {
    return _foodsToRecommend.contains(foodId);
  }

  /// Get warning message for a food
  String? getWarningMessage(int foodId) {
    if (shouldAvoidFood(foodId)) {
      return 'Thực phẩm này không phù hợp với tình trạng sức khỏe của bạn';
    }
    return null;
  }

  /// Get recommendation message for a food
  String? getRecommendationMessage(int foodId) {
    if (isFoodRecommended(foodId)) {
      return 'Thực phẩm được khuyến nghị cho bạn';
    }
    return null;
  }

  /// Clear cache
  void clearCache() {
    _foodsToAvoid.clear();
    _foodsToRecommend.clear();
    _isLoaded = false;
    _lastLoaded = null;
  }

  /// Refresh recommendations
  Future<void> refresh() async {
    await loadUserFoodRecommendations(forceRefresh: true);
  }
}
