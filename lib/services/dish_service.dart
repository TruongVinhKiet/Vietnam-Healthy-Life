import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

class DishService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dishes/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting dish categories: $e');
      return [];
    }
  }

  static Future<String> uploadDishImage(
    Uint8List bytes, {
    String? mimeType,
    String? filename,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dataUrl =
        'data:${mimeType ?? 'image/png'};base64,${base64Encode(bytes)}';

    final response = await http.post(
      Uri.parse('$baseUrl/dishes/upload-image'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'imageData': dataUrl,
        if (filename != null) 'filename': filename,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['imageUrl'] != null) {
        return data['imageUrl'];
      }
      throw Exception('Image URL missing from response');
    } else {
      throw Exception(
        'Failed to upload image: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get all dishes (public + user's private)
  static Future<List<Map<String, dynamic>>> getDishes({
    String? category,
    String? search,
    bool publicOnly = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      var url = '$baseUrl/dishes?';

      if (publicOnly) url += 'isPublic=true&';
      if (category != null && category.isNotEmpty) {
        url += 'category=$category&';
      }
      if (search != null && search.isNotEmpty) {
        url += 'search=${Uri.encodeComponent(search)}&';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting dishes: $e');
      return [];
    }
  }

  /// Get dish details with ingredients and nutrients
  static Future<Map<String, dynamic>?> getDishDetails(int dishId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/dishes/$dishId'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting dish details: $e');
      return null;
    }
  }

  /// Get dish nutrients
  static Future<List<Map<String, dynamic>>> getDishNutrients(int dishId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/dishes/$dishId/nutrients'),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final nutrients = data['data'] ?? data['nutrients'] ?? [];
        return List<Map<String, dynamic>>.from(nutrients);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting dish nutrients: $e');
      return [];
    }
  }

  /// Create a new dish (user-created)
  static Future<Map<String, dynamic>?> createDish({
    required String name,
    String? vietnameseName,
    String? description,
    String? category,
    double servingSizeG = 100,
    String? imageUrl,
    bool isPublic = false,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/dishes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'vietnamese_name': vietnameseName,
          'description': description,
          'category': category,
          'serving_size_g': servingSizeG,
          'image_url': imageUrl,
          'is_public': isPublic,
          'ingredients': ingredients,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create dish');
      }
    } catch (e) {
      debugPrint('Error creating dish: $e');
      rethrow;
    }
  }

  /// Update an existing dish
  static Future<Map<String, dynamic>?> updateDish({
    required int dishId,
    String? name,
    String? vietnameseName,
    String? description,
    String? category,
    double? servingSizeG,
    String? imageUrl,
    bool? isPublic,
    List<Map<String, dynamic>>? ingredients,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (vietnameseName != null) body['vietnamese_name'] = vietnameseName;
      if (description != null) body['description'] = description;
      if (category != null) body['category'] = category;
      if (servingSizeG != null) body['serving_size_g'] = servingSizeG;
      if (imageUrl != null) body['image_url'] = imageUrl;
      if (isPublic != null) body['is_public'] = isPublic;
      if (ingredients != null) body['ingredients'] = ingredients;

      final response = await http.put(
        Uri.parse('$baseUrl/dishes/$dishId'),
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
        throw Exception(error['error'] ?? 'Failed to update dish');
      }
    } catch (e) {
      debugPrint('Error updating dish: $e');
      rethrow;
    }
  }

  /// Delete a dish
  static Future<bool> deleteDish(int dishId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('$baseUrl/dishes/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting dish: $e');
      return false;
    }
  }

  /// Get user's custom dishes
  static Future<List<Map<String, dynamic>>> getUserDishes() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/dishes/user/my-dishes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting user dishes: $e');
      return [];
    }
  }

  /// Check if dish name already exists
  static Future<bool> checkNameExists({
    String? name,
    String? vietnameseName,
    int? excludeDishId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return false;

      final uri = Uri.parse('$baseUrl/dishes/check-name').replace(
        queryParameters: {
          if (name != null && name.isNotEmpty) 'name': name,
          if (vietnameseName != null && vietnameseName.isNotEmpty)
            'vietnamese_name': vietnameseName,
          if (excludeDishId != null) 'dish_id': excludeDishId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking dish name: $e');
      return false;
    }
  }
}
