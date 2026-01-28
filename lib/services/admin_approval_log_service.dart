import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';
import '../config/api_config.dart';

class AdminApprovalLogService {
  static String get baseUrl => '${ApiConfig.baseUrl}/admin';

  static Future<Map<String, dynamic>> listApprovalLogs({
    int? adminId,
    String? itemType,
    int? itemId,
    String? itemName,
    String? action,
    String? startDate,
    String? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token');
    }

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (adminId != null) 'admin_id': adminId.toString(),
      if (itemType != null && itemType.isNotEmpty) 'item_type': itemType,
      if (itemId != null) 'item_id': itemId.toString(),
      if (itemName != null && itemName.isNotEmpty) 'item_name': itemName,
      if (action != null && action.isNotEmpty) 'action': action,
      if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
      if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
    };

    final uri = Uri.parse(
      '$baseUrl/approval-logs',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Failed to load approval logs: ${response.body}');
  }
}
