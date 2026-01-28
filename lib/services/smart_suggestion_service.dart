import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartSuggestionService {
  static String _vietnamDateString() {
    final utcNow = DateTime.now().toUtc();
    final vnNow = utcNow.add(const Duration(hours: 7));
    return vnNow.toIso8601String().split('T').first;
  }

  static String _dateOnlyString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Get smart suggestions
  /// type: 'dish', 'drink', or 'both'
  /// limit: 5, 10, or null (all)
  static Future<Map<String, dynamic>> getSmartSuggestions({
    String type = 'both',
    int? limit,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      var url = '${ApiConfig.baseUrl}/api/smart-suggestions/smart?type=$type';
      if (limit != null) {
        url += '&limit=$limit';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {
        'error': 'Failed to get suggestions',
        'status': response.statusCode,
      };
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getMissingNutrients({
    DateTime? date,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      final dateStr = date != null
          ? _dateOnlyString(date)
          : _vietnamDateString();

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/smart-suggestions/missing?date=$dateStr',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {
        'error': 'Failed to get missing nutrients',
        'status': response.statusCode,
      };
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get user context (weather, gaps, conditions, meal period)
  static Future<Map<String, dynamic>> getContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/smart-suggestions/context'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {'error': 'Failed to get context', 'status': response.statusCode};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Pin a suggestion
  static Future<Map<String, dynamic>> pinSuggestion({
    required String itemType,
    required int itemId,
    String? mealPeriod,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/smart-suggestions/pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'item_type': itemType,
          'item_id': itemId,
          if (mealPeriod != null) 'meal_period': mealPeriod,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {'error': 'Failed to pin', 'status': response.statusCode};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Unpin a suggestion
  static Future<Map<String, dynamic>> unpinSuggestion({
    required String itemType,
    required int itemId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/smart-suggestions/pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'item_type': itemType, 'item_id': itemId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {'error': 'Failed to unpin', 'status': response.statusCode};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get pinned suggestions
  static Future<Map<String, dynamic>> getPinnedSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/smart-suggestions/pinned'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {'error': 'Failed to get pinned', 'status': response.statusCode};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Set food preference (allergy, dislike, favorite)
  static Future<Map<String, dynamic>> setFoodPreference({
    required int foodId,
    required String preferenceType,
    int intensity = 3,
    String? notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/smart-suggestions/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'food_id': foodId,
          'preference_type': preferenceType,
          'intensity': intensity,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {
        'error': 'Failed to set preference',
        'status': response.statusCode,
      };
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Get food preferences
  static Future<Map<String, dynamic>> getFoodPreferences({
    String? preferenceType,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return {'error': 'Not authenticated'};
      }

      var url = '${ApiConfig.baseUrl}/api/smart-suggestions/preferences';
      if (preferenceType != null) {
        url += '?preference_type=$preferenceType';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      return {
        'error': 'Failed to get preferences',
        'status': response.statusCode,
      };
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Update lightbulb button position
  static Future<bool> saveLightbulbPosition(double x, double y) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('lightbulb_x', x);
      await prefs.setDouble('lightbulb_y', y);

      // Also save to backend
      final token = prefs.getString('auth_token');
      if (token != null) {
        await http.put(
          Uri.parse('${ApiConfig.baseUrl}/api/settings'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'lightbulb_x': x, 'lightbulb_y': y}),
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get lightbulb button position
  static Future<Map<String, double>> getLightbulbPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'x': prefs.getDouble('lightbulb_x') ?? 0.85,
        'y': prefs.getDouble('lightbulb_y') ?? 0.15,
      };
    } catch (e) {
      return {'x': 0.85, 'y': 0.15};
    }
  }

  /// Unpin a suggestion when user adds it to meal
  static Future<void> unpinOnAdd({
    required String itemType,
    required int itemId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return;

      // Call backend to unpin
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/smart-suggestions/pin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'item_type': itemType, 'item_id': itemId}),
      );
    } catch (e) {
      // Silently fail - this is not critical
    }
  }
}
