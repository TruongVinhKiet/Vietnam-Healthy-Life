import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UserDishRecommendationService {
  static final UserDishRecommendationService _instance =
      UserDishRecommendationService._internal();
  factory UserDishRecommendationService() => _instance;
  UserDishRecommendationService._internal();

  Set<int> _dishesToAvoid = {};
  Set<int> _dishesToRecommend = {};
  bool _isLoaded = false;
  DateTime? _lastLoaded;

  Set<int> get dishesToAvoid => _dishesToAvoid;
  Set<int> get dishesToRecommend => _dishesToRecommend;
  bool get isLoaded => _isLoaded;

  /// Load user's dish recommendations based on their health conditions
  Future<void> loadUserDishRecommendations({bool forceRefresh = false}) async {
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
          '${ApiConfig.baseUrl}/api/suggestions/user-dish-recommendations',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final dishesToAvoidList =
            data['dishes_to_avoid'] as List<dynamic>? ?? [];
        final dishesToRecommendList =
            data['dishes_to_recommend'] as List<dynamic>? ?? [];

        // API returns array of objects like [{dish_id: 64, dish_name: 'Phở bò', ...}, ...]
        final avoidSet = dishesToAvoidList
            .map(
              (item) => (item is Map ? item['dish_id'] as int? : item as int?),
            )
            .whereType<int>()
            .toSet();

        final recommendSet = dishesToRecommendList
            .map(
              (item) => (item is Map ? item['dish_id'] as int? : item as int?),
            )
            .whereType<int>()
            .toSet();

        // IMPORTANT: If a dish is in both avoid and recommend (due to different conditions),
        // prioritize AVOID for user safety. Remove conflicts from recommend set.
        final conflicts = avoidSet.intersection(recommendSet);
        if (conflicts.isNotEmpty) {
          debugPrint(
            '⚠️  Conflict detected: ${conflicts.length} dishes are both avoid and recommend',
          );
          debugPrint('   Conflicting dish IDs: $conflicts');
          debugPrint('   → Prioritizing AVOID for safety');
        }

        _dishesToAvoid = avoidSet;
        // Remove conflicts: dishes that are marked to avoid should NOT be in recommend list
        _dishesToRecommend = recommendSet.difference(avoidSet);

        _isLoaded = true;
        _lastLoaded = DateTime.now();

        debugPrint('✅ Loaded user dish recommendations:');
        debugPrint('   Dishes to avoid: ${_dishesToAvoid.length}');
        debugPrint('   Dishes to recommend: ${_dishesToRecommend.length}');
      } else {
        debugPrint(
          'Failed to load dish recommendations: ${response.statusCode} ${response.body}',
        );
        _isLoaded = false;
      }
    } catch (e) {
      debugPrint('Error loading user dish recommendations: $e');
      _isLoaded = false;
    }
  }

  /// Clear cached data
  void clear() {
    _dishesToAvoid.clear();
    _dishesToRecommend.clear();
    _isLoaded = false;
    _lastLoaded = null;
    debugPrint('🧹 Cleared user dish recommendations cache');
  }

  /// Force reload recommendations
  Future<void> reload() async {
    clear();
    await loadUserDishRecommendations(forceRefresh: true);
  }

  /// Check if a dish should be avoided
  bool shouldAvoidDish(int dishId) => _dishesToAvoid.contains(dishId);

  /// Check if a dish is recommended
  bool isDishRecommended(int dishId) => _dishesToRecommend.contains(dishId);

  /// Get debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'isLoaded': _isLoaded,
      'lastLoaded': _lastLoaded?.toIso8601String(),
      'dishesToAvoidCount': _dishesToAvoid.length,
      'dishesToRecommendCount': _dishesToRecommend.length,
      'dishesToAvoidSample': _dishesToAvoid.take(5).toList(),
      'dishesToRecommendSample': _dishesToRecommend.take(5).toList(),
    };
  }
}
