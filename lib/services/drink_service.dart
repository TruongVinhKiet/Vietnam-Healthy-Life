import 'dart:convert';
import '../config/api_config.dart';

import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DrinkService {
  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, dynamic> _normalizeDrink(Map<String, dynamic> drink) {
    if (drink.containsKey('default_volume_ml')) {
      drink['default_volume_ml'] = _toDouble(drink['default_volume_ml']);
    }
    if (drink.containsKey('hydration_ratio')) {
      drink['hydration_ratio'] = _toDouble(drink['hydration_ratio']);
    }
    if (drink.containsKey('caffeine_mg')) {
      drink['caffeine_mg'] = _toDouble(drink['caffeine_mg']);
    }
    return drink;
  }

  static Future<List<Map<String, dynamic>>> fetchCatalog() async {
    final token = await AuthService.getToken();
    if (token == null) return [];
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/water/catalog'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> drinks = data['drinks'] ?? [];
      return drinks.cast<Map<String, dynamic>>().map(_normalizeDrink).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>?> fetchDetail(int drinkId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/water/detail/$drinkId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['drink'] is Map<String, dynamic>) {
        data['drink'] = _normalizeDrink(data['drink']);
      }
      return data;
    }
    if (res.body.isNotEmpty) {
      return json.decode(res.body);
    }
    return {'error': 'Failed to load drink'};
  }

  static Future<Map<String, dynamic>?> createCustomDrink(
    Map<String, dynamic> payload,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/water/custom-drink'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );
    if (res.statusCode == 201) {
      final data = json.decode(res.body);
      if (data['drink'] is Map<String, dynamic>) {
        data['drink'] = _normalizeDrink(data['drink']);
      }
      return data;
    }
    if (res.body.isNotEmpty) {
      return json.decode(res.body);
    }
    return {'error': 'Failed to create drink'};
  }

  static Future<bool> deleteCustomDrink(int drinkId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/water/custom-drink/$drinkId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }

  static Future<List<Map<String, dynamic>>> adminFetchDrinks({
    bool? isTemplate,
    bool? isPublic,
    String? category,
    String? search,
    int? limit,
    int? offset,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return [];

    final queryParams = <String, String>{
      if (isTemplate != null) 'isTemplate': isTemplate.toString(),
      if (isPublic != null) 'isPublic': isPublic.toString(),
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/admin/drinks',
    ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> drinks = data['drinks'] ?? [];
      return drinks.cast<Map<String, dynamic>>().map(_normalizeDrink).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>?> adminFetchDetail(int drinkId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/drinks/$drinkId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['drink'] is Map<String, dynamic>) {
        data['drink'] = _normalizeDrink(data['drink']);
      }
      return data;
    }
    if (res.body.isNotEmpty) {
      return json.decode(res.body);
    }
    return {'error': 'Failed to load drink'};
  }

  static Future<Map<String, dynamic>?> adminUpsertDrink(
    Map<String, dynamic> payload, {
    int? drinkId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = drinkId == null
        ? Uri.parse('${ApiConfig.baseUrl}/admin/drinks')
        : Uri.parse('${ApiConfig.baseUrl}/admin/drinks/$drinkId');
    final response = await (drinkId == null
        ? http.post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          )
        : http.put(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(payload),
          ));
    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      if (map['drink'] is Map<String, dynamic>) {
        map['drink'] = _normalizeDrink(map['drink']);
      }
      return map;
    }
    if (response.body.isNotEmpty) {
      return json.decode(response.body);
    }
    return {'error': 'Failed to save drink'};
  }

  static Future<bool> adminDeleteDrink(int drinkId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/admin/drinks/$drinkId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200;
  }

  static Future<Map<String, dynamic>?> adminApproveDrink(int drinkId) async {
    final token = await AuthService.getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/admin/drinks/$drinkId/approve'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['drink'] is Map<String, dynamic>) {
        data['drink'] = _normalizeDrink(data['drink']);
      }
      return data;
    }
    if (res.body.isNotEmpty) {
      return json.decode(res.body);
    }
    return {'error': 'Failed to approve drink'};
  }

  static Future<bool> checkNameExists({
    String? name,
    String? vietnameseName,
    int? excludeDrinkId,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) return false;

    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/drinks/check-name')
        .replace(
          queryParameters: {
            if (name != null && name.isNotEmpty) 'name': name,
            if (vietnameseName != null && vietnameseName.isNotEmpty)
              'vietnamese_name': vietnameseName,
            if (excludeDrinkId != null) 'drink_id': excludeDrinkId.toString(),
          },
        );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['exists'] == true;
    }
    return false;
  }
}
