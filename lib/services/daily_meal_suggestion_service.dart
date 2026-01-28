import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_meal_suggestion.dart';

class DailyMealSuggestionService {
  static String get baseUrl =>
      '${ApiConfig.baseUrl}/api/suggestions/daily-meals';

  static String _vietnamDateString([DateTime? date]) {
    final DateTime vn;
    if (date == null) {
      final utc = DateTime.now().toUtc();
      vn = utc.add(const Duration(hours: 7));
    } else {
      vn = DateTime(date.year, date.month, date.day);
    }
    final y = vn.year.toString().padLeft(4, '0');
    final m = vn.month.toString().padLeft(2, '0');
    final d = vn.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? prefs.getString('token');
  }

  static Future<Map<String, dynamic>> consumeSuggestion({
    DateTime? date,
    String? mealType,
    int? dishId,
    int? drinkId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      if (dishId == null && drinkId == null) {
        return {'error': 'Thiếu dishId hoặc drinkId'};
      }

      final dateStr = _vietnamDateString(date);
      final body = <String, dynamic>{
        'date': dateStr,
        if (mealType != null) 'mealType': mealType,
        if (dishId != null) 'dishId': dishId,
        if (drinkId != null) 'drinkId': drinkId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/consume'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi xóa gợi ý đã chấp nhận'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error consuming: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Generate daily meal suggestions for a specific date
  static Future<Map<String, dynamic>> generateSuggestions({
    DateTime? date,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      final dateStr = _vietnamDateString(date);

      final Map<String, dynamic> body = {'date': dateStr};

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi tạo gợi ý'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error generating: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Get suggestions for a specific date
  static Future<Map<String, dynamic>> getSuggestions({DateTime? date}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      final dateStr = _vietnamDateString(date);

      final response = await http.get(
        Uri.parse('$baseUrl?date=$dateStr'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = data['data'];

        // Parse suggestions and nutrientSummary
        final suggestionsData = responseData['suggestions'] ?? responseData;
        final nutrientSummaryData = responseData['nutrientSummary'];

        final suggestions = DailyMealSuggestions.fromJson({
          ...suggestionsData,
          'nutrientSummary': nutrientSummaryData,
        });
        return {'success': true, 'suggestions': suggestions};
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi tải gợi ý'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error getting: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Accept a suggestion
  static Future<Map<String, dynamic>> acceptSuggestion(int suggestionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$suggestionId/accept'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi chấp nhận gợi ý'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error accepting: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Reject a suggestion and get a new one
  static Future<Map<String, dynamic>> rejectSuggestion(int suggestionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$suggestionId/reject'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi từ chối gợi ý'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error rejecting: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Delete a suggestion
  static Future<Map<String, dynamic>> deleteSuggestion(int suggestionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/$suggestionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi xóa gợi ý'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error deleting: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Get suggestion statistics
  static Future<Map<String, dynamic>> getStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      String url = '$baseUrl/stats';
      final queryParams = <String>[];

      if (startDate != null) {
        queryParams.add('startDate=${_vietnamDateString(startDate)}');
      }
      if (endDate != null) {
        queryParams.add('endDate=${_vietnamDateString(endDate)}');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stats = (data['data'] as List)
            .map((e) => SuggestionStats.fromJson(e))
            .toList();
        return {'success': true, 'stats': stats};
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi tải thống kê'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error getting stats: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Cleanup passed meal suggestions
  static Future<Map<String, dynamic>> cleanupPassedMeals() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'error': 'Chưa đăng nhập'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/cleanup-passed'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final error = jsonDecode(response.body);
        return {'error': error['message'] ?? 'Lỗi dọn dẹp'};
      }
    } catch (e) {
      debugPrint('[DailyMealSuggestionService] Error cleanup: $e');
      return {'error': 'Lỗi kết nối: $e'};
    }
  }

  /// Helper: Get Vietnamese meal type name
  static String getMealTypeName(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Bữa sáng';
      case 'lunch':
        return 'Bữa trưa';
      case 'dinner':
        return 'Bữa tối';
      case 'snack':
        return 'Bữa phụ';
      default:
        return mealType;
    }
  }

  /// Helper: Get meal icon
  static IconData getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}
