import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class MealTemplateService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get all user's templates
  Future<Map<String, dynamic>> getTemplates({
    String? mealType,
    bool favoritesOnly = false,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      var url = '$baseUrl/meal-templates?';
      if (mealType != null) url += 'mealType=$mealType&';
      if (favoritesOnly) url += 'favoritesOnly=true';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load templates');
      }
    } catch (e) {
      throw Exception('Error loading templates: $e');
    }
  }

  /// Get template by ID
  Future<Map<String, dynamic>> getTemplateById(int templateId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/meal-templates/$templateId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Template not found');
      }
    } catch (e) {
      throw Exception('Error loading template: $e');
    }
  }

  /// Create a new template
  Future<Map<String, dynamic>> createTemplate({
    required String templateName,
    String? description,
    required String mealType,
    bool isFavorite = false,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/meal-templates'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'templateName': templateName,
          'description': description,
          'mealType': mealType,
          'isFavorite': isFavorite,
          'items': items,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create template');
      }
    } catch (e) {
      throw Exception('Error creating template: $e');
    }
  }

  /// Save current meal as template
  Future<Map<String, dynamic>> saveCurrentMealAsTemplate({
    required String templateName,
    String? description,
    required String mealType,
    String? date,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/meal-templates/save-current'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'templateName': templateName,
          'description': description,
          'mealType': mealType,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to save template');
      }
    } catch (e) {
      throw Exception('Error saving template: $e');
    }
  }

  /// Update a template
  Future<Map<String, dynamic>> updateTemplate({
    required int templateId,
    String? templateName,
    String? description,
    String? mealType,
    bool? isFavorite,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{};
      if (templateName != null) body['templateName'] = templateName;
      if (description != null) body['description'] = description;
      if (mealType != null) body['mealType'] = mealType;
      if (isFavorite != null) body['isFavorite'] = isFavorite;
      if (items != null) body['items'] = items;

      final response = await http.put(
        Uri.parse('$baseUrl/meal-templates/$templateId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update template');
      }
    } catch (e) {
      throw Exception('Error updating template: $e');
    }
  }

  /// Delete a template
  Future<void> deleteTemplate(int templateId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('$baseUrl/meal-templates/$templateId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete template');
      }
    } catch (e) {
      throw Exception('Error deleting template: $e');
    }
  }

  /// Apply template (add all items as meals)
  Future<Map<String, dynamic>> applyTemplate(int templateId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/meal-templates/apply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'templateId': templateId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to apply template');
      }
    } catch (e) {
      throw Exception('Error applying template: $e');
    }
  }
}
