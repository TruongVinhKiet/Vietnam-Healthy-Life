import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/api_config.dart';

class AdminActivityService {
  static String get baseUrl => '${ApiConfig.baseUrl}/admin';

  /// Get activity logs for a specific user
  static Future<Map<String, dynamic>> getUserActivityLogs({
    required int userId,
    String? startDate,
    String? endDate,
    String? action,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (action != null) queryParams['action'] = action;

      final uri = Uri.parse('$baseUrl/users/$userId/activity')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load activity logs: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading activity logs: $e');
    }
  }

  /// Get analytics for a specific user
  static Future<Map<String, dynamic>> getUserActivityAnalytics({
    required int userId,
    String period = '7d',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final uri = Uri.parse('$baseUrl/users/$userId/activity/analytics')
          .replace(queryParameters: {'period': period});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load analytics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading analytics: $e');
    }
  }

  /// Log user activity manually
  static Future<Map<String, dynamic>> logUserActivity({
    required int userId,
    required String action,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/activity'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'action': action}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to log activity: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error logging activity: $e');
    }
  }

  /// Get platform activity overview
  static Future<Map<String, dynamic>> getPlatformActivityOverview({
    String period = '7d',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final uri = Uri.parse('$baseUrl/activity/overview')
          .replace(queryParameters: {'period': period});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load platform overview: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading platform overview: $e');
    }
  }
}
