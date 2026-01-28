import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class FoodService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  /// Search foods by name
  static Future<List<Map<String, dynamic>>> searchFoods(
    String query, {
    int limit = 10,
  }) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
      
      final response = await http.get(
        Uri.parse(
          '$baseUrl/foods?search=${Uri.encodeComponent(query)}&limit=$limit',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['foods'] ?? []);
      }
      debugPrint('Food search failed: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error searching foods: $e');
      return [];
    }
  }

  /// Fetch foods list (supports search & pagination)
  static Future<List<Map<String, dynamic>>> fetchFoods({
    String search = '',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
      final queryParams = [
        'limit=$limit',
        'offset=$offset',
        if (search.trim().isNotEmpty) 'search=${Uri.encodeComponent(search.trim())}',
      ].join('&');

      final response = await http.get(
        Uri.parse('$baseUrl/foods${queryParams.isEmpty ? '' : '?$queryParams'}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['foods'] ?? []);
      }
      debugPrint('Food fetch failed: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      debugPrint('Error fetching foods: $e');
      return [];
    }
  }

  /// Get food details with nutrients
  static Future<Map<String, dynamic>?> getFoodDetails(int foodId) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
      
      final response = await http.get(
        Uri.parse('$baseUrl/foods/$foodId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting food details: $e');
      return null;
    }
  }

  /// Calculate nutrition for a given food and weight
  static Map<String, double> calculateNutrition(
    Map<String, dynamic> food,
    double weightG,
  ) {
    final multiplier = weightG / 100.0;
    final nutrients = food['nutrients'] as List<dynamic>? ?? [];

    double calories = 0;
    double protein = 0;
    double fat = 0;
    double carbs = 0;

    for (final nutrient in nutrients) {
      final name = (nutrient['nutrient_name'] as String?)?.toLowerCase() ?? '';
      final amount =
          ((nutrient['amount_per_100g'] ?? 0) as num).toDouble() * multiplier;

      if (name.contains('energy') || name.contains('calorie')) {
        calories += amount;
      } else if (name.contains('protein')) {
        protein += amount;
      } else if (name.contains('fat') && !name.contains('fatty')) {
        fat += amount;
      } else if (name.contains('carbohydrate') || name.contains('carb')) {
        carbs += amount;
      }
    }

    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  /// Get available nutrients
  static Future<List<Map<String, dynamic>>> listAvailableNutrients() async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : <String, String>{};
      final response = await http.get(
        Uri.parse('$baseUrl/admin/foods/nutrients/available'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['nutrients'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching nutrients: $e');
      return [];
    }
  }
}

