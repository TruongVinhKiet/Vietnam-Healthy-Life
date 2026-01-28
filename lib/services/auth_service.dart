import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  static String get _baseUrl => ApiConfig.baseUrl;
  static const _tokenKey = 'auth_token';
  static const _userRoleKey = 'user_role'; // 'user' or 'admin'
  static const _notifLastSeenKey = 'notif_last_seen_at';

  static Future<Map<String, dynamic>?> register({
    required String fullName,
    required String email,
    required String password,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) async {
    // Build request body (URI is constructed from _baseUrl below)
    final body = {
      'full_name': fullName,
      'email': email,
      'password': password,
      'age': age,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
    }..removeWhere((k, v) => v == null);

    final uri = Uri.parse('$_baseUrl/auth/register');
    try {
      final res = await http.post(
        uri,
        body: json.encode(body),
        headers: {'Content-Type': 'application/json'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201 || res.statusCode == 200) {
        // Do NOT auto-save token on register; require user to login explicitly
        return data;
      }
      // return parsed error body when available
      return data.isNotEmpty ? data : {'error': 'Đăng ký thất bại'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  // Request unlock code for blocked account (by email/identifier)
  static Future<Map<String, dynamic>?> requestUnlockCode({
    required String identifier,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/unlock/request');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Request unlock failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> confirmUnlockCode({
    required String identifier,
    required String code,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/unlock/confirm');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'identifier': identifier, 'code': code}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Confirm unlock failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> login({
    required String identifier,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    try {
      final res = await http.post(
        uri,
        body: json.encode({'identifier': identifier, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        if (data['token'] != null) {
          await _saveToken(data['token']);
          await _saveUserRole('user'); // Mark as regular user
        }
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Đăng nhập thất bại'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Complete MFA login by verifying OTP with a temporary token returned from /auth/login
  static Future<Map<String, dynamic>?> loginMfaVerify({
    required String tempToken,
    required String otp,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login/mfa/verify');
    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'temp_token': tempToken, 'otp': otp}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        if (data['token'] != null) {
          await _saveToken(data['token']);
          await _saveUserRole('user'); // Mark as regular user after MFA
        }
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'MFA verify failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Submit an unblock request when login is blocked. No auth token required.
  /// Body: { identifier, message }
  static Future<Map<String, dynamic>?> submitUnblockRequest({
    required String identifier,
    String? message,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/unblock-request');
    try {
      final res = await http.post(
        uri,
        body: json.encode({
          'identifier': identifier,
          if (message != null) 'message': message,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201 || res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Gửi yêu cầu gỡ chặn thất bại'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> adminLogin({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/admin/login');
    try {
      final res = await http.post(
        uri,
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        if (data['token'] != null) {
          await _saveToken(data['token']);
          await _saveUserRole('admin'); // Mark as admin
        }
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Đăng nhập thất bại'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> adminRegister({
    required String username,
    required String password,
    required String accessCode,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/admin/register');
    try {
      final res = await http.post(
        uri,
        body: json.encode({
          'username': username,
          'password': password,
          'access_code': accessCode,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Đăng ký admin thất bại'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> adminVerify({
    required String username,
    required String code,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/admin/verify');
    try {
      final res = await http.post(
        uri,
        body: json.encode({'username': username, 'code': code}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Xác thực thất bại'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> me() async {
    final token = await _getToken();
    if (token == null) return null;
    // Always pass Vietnam "today" so backend /auth/me uses the same day
    // definition as water logging and statistics.
    final todayVn = _vietnamDateString();
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me?date=$todayVn');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return json.decode(res.body)['user'];
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>?> getVitamins({int? top}) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/vitamins${top != null ? '?top=$top' : ''}',
    );
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        final data = res.body.isNotEmpty ? json.decode(res.body) : [];
        if (data is List) return List<Map<String, dynamic>>.from(data);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getVitaminById(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/vitamins/$id');
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getFibers({int? top}) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/fibers${top != null ? '?top=$top' : ''}',
    );
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        final data = res.body.isNotEmpty ? json.decode(res.body) : [];
        if (data is List) return List<Map<String, dynamic>>.from(data);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFiberById(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/fibers/$id');
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getMinerals({int? top}) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/minerals${top != null ? '?top=$top' : ''}',
    );
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        final data = res.body.isNotEmpty ? json.decode(res.body) : [];
        if (data is List) return List<Map<String, dynamic>>.from(data);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMineralById(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/minerals/$id');
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getFattyAcids({int? top}) async {
    final token = await _getToken();
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/fatty-acids${top != null ? '?top=$top' : ''}',
    );
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        final data = res.body.isNotEmpty ? json.decode(res.body) : [];
        if (data is List) return List<Map<String, dynamic>>.from(data);
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getFattyAcidById(int id) async {
    final token = await _getToken();
    final uri = Uri.parse('$_baseUrl/fatty-acids/$id');
    try {
      final res = await http.get(
        uri,
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create a meal with items. `items` is a list of maps: { 'food_id': int, 'weight_g': double }
  static Future<Map<String, dynamic>?> createMeal({
    String? mealType,
    String? mealDate,
    List<Map<String, dynamic>>? items,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/meals');
    final body = <String, dynamic>{
      if (mealType != null) 'meal_type': mealType,
      if (mealDate != null) 'meal_date': mealDate,
      if (items != null) 'items': items,
    };
    try {
      final res = await http.post(
        uri,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201 || res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Create meal failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Admin bulk import foods. Body: { foods: [ { name, category, nutrients: [{ nutrient_code, name, unit, amount_per_100g }] } ] }
  static Future<Map<String, dynamic>?> adminBulkImportFoods(
    List<Map<String, dynamic>> foods,
  ) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/import-foods');
    final body = {'foods': foods};
    try {
      final res = await http.post(
        uri,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Import failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Lấy danh sách AI analyzed meals cho admin (Quản lý AI)
  static Future<List<Map<String, dynamic>>?> adminGetAiMeals({
    bool? accepted,
    bool? promoted,
    String? itemType,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final token = await _getToken();
    if (token == null) return null;
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (accepted != null) query['accepted'] = '$accepted';
    if (promoted != null) query['promoted'] = '$promoted';
    if (itemType != null) query['item_type'] = itemType;
    if (search != null && search.isNotEmpty) query['search'] = search;
    final uri = Uri.parse('$_baseUrl/admin/ai-meals')
        .replace(queryParameters: query);
    try {
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is Map && data['meals'] is List) {
          return List<Map<String, dynamic>>.from(data['meals']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Promote một AI meal thành Dish/Drink chính thức
  static Future<Map<String, dynamic>?> adminPromoteAiMeal({
    required int id,
    required String targetType, // 'dish' | 'drink'
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/admin/ai-meals/$id/promote');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'target_type': targetType}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Promote AI meal failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> adminRejectAiMeal({
    required int id,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/admin/ai-meals/$id/reject');
    try {
      final res = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Reject AI meal failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static String _vietnamDateString() {
    final utcNow = DateTime.now().toUtc();
    final vnNow = utcNow.add(const Duration(hours: 7));
    return vnNow.toIso8601String().split('T').first;
  }

  /// Log water intake in milliliters. Returns today's aggregated totals (including total_water and last_drink_at) or error.
  static Future<Map<String, dynamic>?> logWater({
    required double amountMl,
    String? date,
    int? drinkId,
    double? hydrationRatio,
    String? drinkName,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/water');
    final body = <String, dynamic>{'amount_ml': amountMl};
    // Always send a Vietnam-date string so backend can align all water tables
    // (WaterLog, DailySummary, statistics) to the same “today” definition.
    body['date'] = date ?? _vietnamDateString();
    if (drinkId != null) body['drink_id'] = drinkId;
    if (hydrationRatio != null) body['hydration_ratio'] = hydrationRatio;
    if (drinkName != null) body['drink_name'] = drinkName;
    if (notes != null && notes.isNotEmpty) body['notes'] = notes;
    try {
      final res = await http.post(
        uri,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201 || res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Log water failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> getSettings() async {
    final token = await _getToken();
    if (token == null) return null;
    final uri = Uri.parse('${ApiConfig.baseUrl}/settings');
    try {
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get per-day per-meal targets. Returns { date, targets: [ { meal_type, target_kcal, target_carbs, target_protein, target_fat } ] }
  static Future<Map<String, dynamic>?> getMealTargets({String? date}) async {
    final token = await _getToken();
    if (token == null) return null;
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/meal-targets${date != null ? '?date=$date' : ''}',
    );
    try {
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> putMealTargets({
    required String date,
    required List<Map<String, dynamic>> targets,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/meal-targets');
    try {
      final res = await http.put(
        uri,
        body: json.encode({'date': date, 'targets': targets}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Update failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Create a meal entry using the new meal_entries API (food_id, weight_g). Returns { entry_id, nutrients }
  static Future<Map<String, dynamic>?> postMealEntry({
    required String mealType,
    required int foodId,
    required double weightG,
    String? date,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/meal-entries');
    final body = {
      if (date != null) 'entry_date': date,
      'meal_type': mealType,
      'food_id': foodId,
      'weight_g': weightG,
    };
    try {
      final res = await http.post(
        uri,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201 || res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Create entry failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> updateSettings(
    Map<String, dynamic> payload,
  ) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/settings');
    try {
      final res = await http.put(
        uri,
        body: json.encode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Update failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> refreshWeather({String? city}) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/settings/weather/refresh');
    final body = <String, dynamic>{if (city != null) 'city': city};
    try {
      final res = await http.post(
        uri,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Refresh failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>?> updateProfile({
    String? fullName,
    String? email,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? avatarUrl,
    String? activityLevel,
    String? dietType,
    String? allergies,
    String? healthGoals,
    String? goalType,
    double? goalWeight,
    double? activityFactor,
    double? bmr,
    double? tdee,
    double? dailyCalorieTarget,
    double? dailyProteinTarget,
    double? dailyFatTarget,
    double? dailyCarbTarget,
    double? dailyWaterTarget,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    final body = {
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (dietType != null) 'diet_type': dietType,
      if (allergies != null) 'allergies': allergies,
      if (healthGoals != null) 'health_goals': healthGoals,
      if (goalType != null) 'goal_type': goalType,
      if (goalWeight != null) 'goal_weight': goalWeight,
      if (activityFactor != null) 'activity_factor': activityFactor,
      if (bmr != null) 'bmr': bmr,
      if (tdee != null) 'tdee': tdee,
      if (dailyCalorieTarget != null)
        'daily_calorie_target': dailyCalorieTarget,
      if (dailyProteinTarget != null)
        'daily_protein_target': dailyProteinTarget,
      if (dailyFatTarget != null) 'daily_fat_target': dailyFatTarget,
      if (dailyCarbTarget != null) 'daily_carb_target': dailyCarbTarget,
      if (dailyWaterTarget != null) 'daily_water_target': dailyWaterTarget,
    };
    try {
      final res = await http.put(
        uri,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Update failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Request server to recompute BMR/TDEE and daily targets for the authenticated user
  static Future<Map<String, dynamic>?> recomputeTargets() async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me/recompute-targets');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) {
        return data;
      }
      return data.isNotEmpty ? data : {'error': 'Recompute failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  /// Request server to recompute only daily calorie/macros targets (does not change BMR/TDEE)
  static Future<Map<String, dynamic>?> recomputeDailyTargets() async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/auth/me/recompute-daily-targets',
    );
    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Recompute failed'};
    } catch (e) {
      return {'error': 'Network error: ${e.toString()}'};
    }
  }

  // ===== Notifications & Security (placeholders for backend integration) =====
  /// Fetch recent account-related notifications. Expected response: [{ type, message, at }]
  static Future<List<Map<String, dynamic>>?> getNotifications() async {
    final token = await _getToken();
    if (token == null) return null;
    final uri = Uri.parse('$_baseUrl/auth/notifications');
    try {
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = res.body.isNotEmpty ? json.decode(res.body) : {};
        if (data is Map && data['notifications'] is List) {
          return List<Map<String, dynamic>>.from(data['notifications']);
        }
      }
      // Fallback: try to build minimal notifications from /auth/me
      final meData = await me();
      if (meData != null) {
        final items = <Map<String, dynamic>>[];
        // last_login not present in /me currently; if added later, include it
        if (meData['last_login'] != null) {
          items.add({
            'type': 'last_login',
            'message': 'Lần đăng nhập gần nhất',
            'at': meData['last_login'],
          });
        }
        return items;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Two-factor authentication
  static Future<Map<String, dynamic>?> getTwoFactorStatus() async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/2fa/status');
    try {
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return {'error': 'Failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> enableTwoFactor({
    required String password,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/2fa/enable');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'current_password': password}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data; // expected: { otpauth_url }
      return data.isNotEmpty ? data : {'error': 'Enable 2FA failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> verifyTwoFactor({
    required String otp,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/2fa/verify');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'otp': otp}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Verify 2FA failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> disableTwoFactor({
    required String password,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/2fa/disable');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'current_password': password}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Disable 2FA failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Password change via email OTP
  static Future<Map<String, dynamic>?> requestPasswordChangeCode() async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/password/change/request');
    try {
      final res = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200 || res.statusCode == 201) return data;
      return data.isNotEmpty ? data : {'error': 'Request code failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> confirmPasswordChange({
    required String code,
    required String newPassword,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/password/change/confirm');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'code': code, 'new_password': newPassword}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Confirm failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Security settings such as account lock threshold
  static Future<Map<String, dynamic>?> updateSecuritySettings({
    required int lockThreshold,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/auth/security');
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'lock_threshold': lockThreshold}),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty
          ? data
          : {'error': 'Update security settings failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
  }

  // ===== Notifications read state (client-side) =====
  static Future<void> markNotificationsSeenNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _notifLastSeenKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<DateTime?> getNotificationsLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_notifLastSeenKey);
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  static bool hasUnseenNotificationsLocal(
    List<Map<String, dynamic>> items,
    DateTime? lastSeenUtc,
  ) {
    if (items.isEmpty) return false;
    DateTime? maxAt;
    for (final m in items) {
      final at = m['at']?.toString();
      if (at == null) continue;
      final dt = DateTime.tryParse(at);
      if (dt == null) continue;
      final utc = dt.isUtc ? dt : dt.toUtc();
      if (maxAt == null || utc.isAfter(maxAt)) maxAt = utc;
    }
    if (maxAt == null) return false;
    if (lastSeenUtc == null) return true; // never seen before
    return maxAt.isAfter(lastSeenUtc);
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Public method for getting token
  static Future<String?> getToken() async {
    return _getToken();
  }

  // Save user role
  static Future<void> _saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // ===== Admin Nutrients CRUD =====
  static Future<Map<String, dynamic>?> adminCreateNutrient({
    required String name,
    String? nutrientCode,
    String? unit,
    String? group,
    String? imageUrl,
    String? benefits,
    List<String>? contraindications,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/admin/nutrients');
    final body = <String, dynamic>{
      'name': name,
      if (nutrientCode != null && nutrientCode.isNotEmpty)
        'nutrient_code': nutrientCode,
      if (unit != null && unit.isNotEmpty) 'unit': unit,
      if (group != null && group.isNotEmpty) 'group_name': group,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      if (benefits != null && benefits.isNotEmpty) 'benefits': benefits,
      if (contraindications != null) 'contraindications': contraindications,
    };
    try {
      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 201 || res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Create nutrient failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> adminUpdateNutrient({
    required int nutrientId,
    String? name,
    String? nutrientCode,
    String? unit,
    String? group,
    String? imageUrl,
    String? benefits,
    List<String>? contraindications,
  }) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/admin/nutrients/$nutrientId');
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (nutrientCode != null) 'nutrient_code': nutrientCode,
      if (unit != null) 'unit': unit,
      if (group != null) 'group_name': group,
      if (imageUrl != null) 'image_url': imageUrl,
      if (benefits != null) 'benefits': benefits,
      if (contraindications != null) 'contraindications': contraindications,
    };
    try {
      final res = await http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      if (res.statusCode == 200) return data;
      return data.isNotEmpty ? data : {'error': 'Update nutrient failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> adminDeleteNutrient(
    int nutrientId,
  ) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/admin/nutrients/$nutrientId');
    try {
      final res = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        return {'success': true};
      }
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      return data.isNotEmpty ? data : {'error': 'Delete nutrient failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> adminGetNutrientDetail(
    int nutrientId,
  ) async {
    final token = await _getToken();
    if (token == null) return {'error': 'Not authenticated'};
    final uri = Uri.parse('$_baseUrl/admin/nutrients/$nutrientId');
    try {
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      final data = res.body.isNotEmpty
          ? json.decode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};
      return data.isNotEmpty ? data : {'error': 'Fetch nutrient failed'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get daily nutrient tracking data (vitamins, minerals with consumption %)
  /// Returns list of nutrients with current_amount, target_amount, percentage
  static Future<List<Map<String, dynamic>>> getDailyNutrientTracking({
    String? date,
  }) async {
    final token = await _getToken();
    if (token == null) {
      debugPrint('[AuthService] No token found for nutrient tracking');
      return [];
    }

    final queryParams = date != null ? '?date=$date' : '';
    final uri = Uri.parse('$_baseUrl/nutrients/tracking/daily$queryParams');

    try {
      debugPrint('[AuthService] Calling nutrient tracking API: $uri');
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('[AuthService] Nutrient tracking response: ${res.statusCode}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        debugPrint(
          '[AuthService] Response data: ${json.encode(data).substring(0, 200)}...',
        );

        if (data is Map &&
            data['success'] == true &&
            data['nutrients'] is List) {
          final nutrients = List<Map<String, dynamic>>.from(data['nutrients']);
          debugPrint('[AuthService] Returning ${nutrients.length} nutrients');
          return nutrients;
        }
      } else {
        debugPrint('[AuthService] Error response: ${res.body}');
      }
      return [];
    } catch (e) {
      debugPrint('[AuthService] Exception in nutrient tracking: $e');
      return [];
    }
  }
}
