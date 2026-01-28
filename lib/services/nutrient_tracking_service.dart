import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class NutrientTrackingService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Return yyyy-MM-dd in Vietnam time (UTC+7) to keep daily resets consistent.
  static String _vietnamDateString() {
    final utcNow = DateTime.now().toUtc();
    final vnNow = utcNow.add(const Duration(hours: 7));
    return vnNow.toIso8601String().split('T').first;
  }

  // Get authentication token from storage
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get daily nutrient tracking with current progress
  static Future<Map<String, dynamic>> getDailyTracking({String? date}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/nutrients/tracking/daily?date=${date ?? _vietnamDateString()}',
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load tracking data');
      }
    } catch (e) {
      debugPrint('Error getting daily tracking: $e');
      rethrow;
    }
  }

  // Get nutrient breakdown with food sources
  static Future<Map<String, dynamic>> getNutrientBreakdown({
    String? date,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/nutrients/tracking/breakdown?date=${date ?? _vietnamDateString()}',
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load breakdown');
      }
    } catch (e) {
      debugPrint('Error getting nutrient breakdown: $e');
      rethrow;
    }
  }

  // Check for deficiencies and create notifications
  static Future<Map<String, dynamic>> checkDeficiencies({String? date}) async {
    try {
      final headers = await _getHeaders();
      final body =
          json.encode({'date': date ?? _vietnamDateString()});

      final response = await http.post(
        Uri.parse('$baseUrl/nutrients/tracking/check-deficiencies'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check deficiencies');
      }
    } catch (e) {
      debugPrint('Error checking deficiencies: $e');
      rethrow;
    }
  }

  // Get nutrient notifications
  static Future<Map<String, dynamic>> getNotifications({int limit = 50}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        // User not logged in, return empty notifications
        return {'notifications': [], 'unread_count': 0};
      }
      
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/nutrients/tracking/notifications?limit=$limit',
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Unauthorized - return empty
        return {'notifications': [], 'unread_count': 0};
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      // Silently return empty instead of printing error repeatedly
      return {'notifications': [], 'unread_count': 0};
    }
  }

  // Mark notification as read
  static Future<bool> markNotificationRead(int notificationId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse(
          '$baseUrl/nutrients/tracking/notifications/$notificationId/read',
        ),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking notification read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  static Future<bool> markAllNotificationsRead() async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/nutrients/tracking/notifications/read-all'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
      return false;
    }
  }

  // Get nutrient summary for home screen
  static Future<Map<String, dynamic>> getSummary({String? date}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/nutrients/tracking/summary?date=${date ?? _vietnamDateString()}',
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load summary');
      }
    } catch (e) {
      debugPrint('Error getting summary: $e');
      rethrow;
    }
  }

  // Get comprehensive report
  static Future<Map<String, dynamic>> getComprehensiveReport({
    String? date,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/nutrients/tracking/report?date=${date ?? _vietnamDateString()}',
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        // API wraps payload inside { success, report }
        if (data.containsKey('report') && data['report'] is Map) {
          return Map<String, dynamic>.from(data['report'] as Map);
        }
        return data;
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      debugPrint('Error getting report: $e');
      rethrow;
    }
  }

  // Update tracking after meal changes
  static Future<bool> updateTracking({String? date}) async {
    try {
      final headers = await _getHeaders();
      final body = date != null ? json.encode({'date': date}) : '{}';

      final response = await http.post(
        Uri.parse('$baseUrl/nutrients/tracking/update'),
        headers: headers,
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating tracking: $e');
      return false;
    }
  }

  // Helper: Calculate progress percentage
  static double calculateProgress(double current, double target) {
    if (target <= 0) return 0.0;
    return (current / target * 100).clamp(0.0, 100.0);
  }

  // Helper: Get color for progress percentage
  static Color getProgressColor(double percentage) {
    if (percentage >= 100) {
      return const Color(0xFF87D068); // Green - achieved
    } else if (percentage >= 70) {
      return const Color(0xFFFFB74D); // Orange - good progress
    } else if (percentage >= 50) {
      return const Color(0xFF64B5F6); // Blue - moderate
    } else if (percentage >= 25) {
      return const Color(0xFFFFA726); // Deep orange - warning
    } else {
      return const Color(0xFFE57373); // Red - critical
    }
  }

  // Helper: Format nutrient amount
  static String formatAmount(double amount, String unit) {
    if (amount < 1) {
      return '${amount.toStringAsFixed(2)} $unit';
    } else if (amount < 10) {
      return '${amount.toStringAsFixed(1)} $unit';
    } else {
      return '${amount.round()} $unit';
    }
  }
}

