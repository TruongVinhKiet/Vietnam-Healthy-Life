import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

class MealService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  /// Add a dish to a meal
  static Future<Map<String, dynamic>?> addDishToMeal({
    required String mealType, // 'breakfast', 'lunch', 'dinner', 'snack'
    required int dishId,
    required double weightG,
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/meals/add-dish'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mealType': mealType,
          'dishId': dishId,
          'weightG': weightG,
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Add dish error response: ${response.statusCode} - ${response.body}');
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to add dish to meal');
      }
    } catch (e) {
      debugPrint('Error adding dish to meal: $e');
      rethrow;
    }
  }

  /// Add a food to a meal
  static Future<Map<String, dynamic>?> addFoodToMeal({
    required String mealType,
    required int foodId,
    required double weightG,
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/meals/add-food'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'mealType': mealType,
          'foodId': foodId,
          'weightG': weightG,
          'date': date ?? DateTime.now().toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Add food error response: ${response.statusCode} - ${response.body}');
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to add food to meal');
      }
    } catch (e) {
      debugPrint('Error adding food to meal: $e');
      rethrow;
    }
  }

  /// Get today's meals summary
  static Future<Map<String, dynamic>> getTodayMeals({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/meals/today?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {
        'breakfast': {'consumed': 0, 'target': 0},
        'lunch': {'consumed': 0, 'target': 0},
        'dinner': {'consumed': 0, 'target': 0},
        'snack': {'consumed': 0, 'target': 0},
      };
    } catch (e) {
      debugPrint('Error getting today meals: $e');
      return {};
    }
  }

  /// Get meal details for a specific meal type and date
  static Future<Map<String, dynamic>> getMealDetails({
    required String mealType,
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? DateTime.now().toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/meals/details?mealType=$mealType&date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint('Error getting meal details: $e');
      return {};
    }
  }

  /// Remove a meal item
  static Future<bool> removeMealItem(int mealItemId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('$baseUrl/meals/items/$mealItemId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error removing meal item: $e');
      return false;
    }
  }

  /// Calculate nutrients from dish or food
  static Future<Map<String, dynamic>> calculateNutrients({
    int? dishId,
    int? foodId,
    required double weightG,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{
        'weightG': weightG,
      };
      if (dishId != null) body['dishId'] = dishId;
      if (foodId != null) body['foodId'] = foodId;

      final response = await http.post(
        Uri.parse('$baseUrl/meals/calculate-nutrients'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      debugPrint('Error calculating nutrients: $e');
      return {};
    }
  }
}
