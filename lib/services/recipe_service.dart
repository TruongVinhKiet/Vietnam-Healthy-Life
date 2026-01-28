import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class RecipeService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get all user's recipes
  Future<Map<String, dynamic>> getRecipes({
    int page = 1,
    int limit = 20,
    bool? isPublic,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      var url = '$baseUrl/recipes?page=$page&limit=$limit';
      if (isPublic != null) {
        url += '&isPublic=$isPublic';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      throw Exception('Error loading recipes: $e');
    }
  }

  /// Get recipe by ID with full details
  Future<Map<String, dynamic>> getRecipeById(int recipeId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/recipes/$recipeId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Recipe not found');
      }
    } catch (e) {
      throw Exception('Error loading recipe: $e');
    }
  }

  /// Create a new recipe
  Future<Map<String, dynamic>> createRecipe({
    required String recipeName,
    String? description,
    int servings = 1,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? instructions,
    String? imageUrl,
    bool isPublic = false,
    required List<Map<String, dynamic>> ingredients,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/recipes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recipeName': recipeName,
          'description': description,
          'servings': servings,
          'prepTimeMinutes': prepTimeMinutes,
          'cookTimeMinutes': cookTimeMinutes,
          'instructions': instructions,
          'imageUrl': imageUrl,
          'isPublic': isPublic,
          'ingredients': ingredients,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create recipe');
      }
    } catch (e) {
      throw Exception('Error creating recipe: $e');
    }
  }

  /// Update an existing recipe
  Future<Map<String, dynamic>> updateRecipe({
    required int recipeId,
    String? recipeName,
    String? description,
    int? servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? instructions,
    String? imageUrl,
    bool? isPublic,
    List<Map<String, dynamic>>? ingredients,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final body = <String, dynamic>{};
      if (recipeName != null) body['recipeName'] = recipeName;
      if (description != null) body['description'] = description;
      if (servings != null) body['servings'] = servings;
      if (prepTimeMinutes != null) body['prepTimeMinutes'] = prepTimeMinutes;
      if (cookTimeMinutes != null) body['cookTimeMinutes'] = cookTimeMinutes;
      if (instructions != null) body['instructions'] = instructions;
      if (imageUrl != null) body['imageUrl'] = imageUrl;
      if (isPublic != null) body['isPublic'] = isPublic;
      if (ingredients != null) body['ingredients'] = ingredients;

      final response = await http.put(
        Uri.parse('$baseUrl/recipes/$recipeId'),
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
        throw Exception(error['error'] ?? 'Failed to update recipe');
      }
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  /// Delete a recipe
  Future<void> deleteRecipe(int recipeId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.delete(
        Uri.parse('$baseUrl/recipes/$recipeId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete recipe');
      }
    } catch (e) {
      throw Exception('Error deleting recipe: $e');
    }
  }

  /// Add recipe as meal
  Future<Map<String, dynamic>> addRecipeAsMeal({
    required int recipeId,
    required String mealType,
    double servings = 1.0,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/recipes/add-as-meal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recipeId': recipeId,
          'mealType': mealType,
          'servings': servings,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to add recipe as meal');
      }
    } catch (e) {
      throw Exception('Error adding recipe as meal: $e');
    }
  }
}
