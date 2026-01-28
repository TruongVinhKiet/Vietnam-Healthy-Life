import 'dart:convert';
import '../config/api_config.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';

class StatisticsService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  /// Always derive "today" using Vietnam time (UTC+7) regardless of device TZ.
  static String _vietnamDateString() {
    final utcNow = DateTime.now().toUtc();
    final vnNow = utcNow.add(const Duration(hours: 7));
    return vnNow.toIso8601String().split('T').first;
  }

  static Future<Map<String, dynamic>> getMealPeriodSummary({
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? _vietnamDateString();
      final response = await http.get(
        Uri.parse('$baseUrl/meal-history/period-summary?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('[StatisticsService] Received data: ${data.keys}');
        debugPrint(
          '[StatisticsService] Periods count: ${(data['periods'] as List?)?.length ?? 0}',
        );
        if (data['periods'] != null) {
          final periods = data['periods'] as List;
          for (var period in periods) {
            debugPrint(
              '[StatisticsService] Period: ${period['key']} - ${period['label']} - entries: ${(period['entries'] as List?)?.length ?? 0}',
            );
          }
        }
        return data;
      }

      debugPrint(
        '[StatisticsService] Error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch statistics');
    } catch (e) {
      debugPrint('[StatisticsService] getMealPeriodSummary error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMealHistory({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? _vietnamDateString();
      final response = await http.get(
        Uri.parse('$baseUrl/meal-history?date=$targetDate&limit=100'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      }

      debugPrint(
        '[StatisticsService] Error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch meal history');
    } catch (e) {
      debugPrint('[StatisticsService] getMealHistory error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWaterTimeline({String? date}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');
      final targetDate = date ?? _vietnamDateString();
      final response = await http.get(
        Uri.parse('$baseUrl/water/timeline?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['timeline'] as Map<String, dynamic>? ?? {};
      }
      debugPrint(
        '[StatisticsService] Water timeline error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch water timeline');
    } catch (e) {
      debugPrint('[StatisticsService] getWaterTimeline error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getWaterPeriodSummary({
    String? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final targetDate = date ?? _vietnamDateString();
      final response = await http.get(
        Uri.parse('$baseUrl/water/period-summary?date=$targetDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('[StatisticsService] Water period data: ${data.keys}');
        debugPrint(
          '[StatisticsService] Water total_ml: ${data['total_ml']}, goal_ml: ${data['goal_ml']}, entries: ${(data['entries'] as List?)?.length ?? 0}',
        );
        return data;
      }

      debugPrint(
        '[StatisticsService] Water period error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to fetch water period summary');
    } catch (e) {
      debugPrint('[StatisticsService] getWaterPeriodSummary error: $e');
      rethrow;
    }
  }
}
