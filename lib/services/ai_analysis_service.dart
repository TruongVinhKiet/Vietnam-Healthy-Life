import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

/// Service để phân tích hình ảnh thức ăn/đồ uống bằng AI
class AiAnalysisService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Helper to safely convert dynamic value to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// Model cho 1 món ăn/đồ uống được phân tích
  static Map<String, dynamic> _parseItem(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'item_name': json['item_name'] ?? '',
      'item_type': json['item_type'] ?? 'food', // food | drink
      'confidence_score': _toDouble(json['confidence_score']),
      'estimated_volume_ml': _toDouble(json['estimated_volume_ml']),
      'estimated_weight_g': _toDouble(json['estimated_weight_g']),
      'water_ml': _toDouble(json['water_ml']),
      'image_path': json['image_path'] ?? '',
      'nutrients': json['nutrients'] ?? _emptyNutrients(),
      'accepted': json['accepted'] ?? false,
      'analyzed_at': json['analyzed_at'],
    };
  }

  /// Nutrients mặc định (76 + water)
  static Map<String, double> _emptyNutrients() {
    return {
      'enerc_kcal': 0,
      'procnt': 0,
      'fat': 0,
      'chocdf': 0,
      'fibtg': 0,
      'fib_sol': 0,
      'fib_insol': 0,
      'fib_rs': 0,
      'fib_bglu': 0,
      'cholesterol': 0,
      'vita': 0,
      'vitd': 0,
      'vite': 0,
      'vitk': 0,
      'vitc': 0,
      'vitb1': 0,
      'vitb2': 0,
      'vitb3': 0,
      'vitb5': 0,
      'vitb6': 0,
      'vitb7': 0,
      'vitb9': 0,
      'vitb12': 0,
      'ca': 0,
      'p': 0,
      'mg': 0,
      'k': 0,
      'na': 0,
      'fe': 0,
      'zn': 0,
      'cu': 0,
      'mn': 0,
      'i': 0,
      'se': 0,
      'cr': 0,
      'mo': 0,
      'f': 0,
      'fams': 0,
      'fapu': 0,
      'fasat': 0,
      'fatrn': 0,
      'faepa': 0,
      'fadha': 0,
      'faepa_dha': 0,
      'fa18_2n6c': 0,
      'fa18_3n3': 0,
      'amino_his': 0,
      'amino_ile': 0,
      'amino_leu': 0,
      'amino_lys': 0,
      'amino_met': 0,
      'amino_phe': 0,
      'amino_thr': 0,
      'amino_trp': 0,
      'amino_val': 0,
      'ala': 0,
      'epa_dha': 0,
      'la': 0,
    };
  }

  /// Phân tích hình ảnh
  ///
  /// Returns: `List<Map<String, dynamic>>` - Danh sách các món được phân tích
  static Future<List<Map<String, dynamic>>> analyzeImage(
    File imageFile, {
    String? originalFilename,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse('$baseUrl/api/analyze-image');

    try {
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Thêm file ảnh with original filename if available
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
          filename:
              originalFilename, // Use original filename for mock data matching
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['items'] as List)
            .map((item) => _parseItem(item as Map<String, dynamic>))
            .toList();
        return items;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Không thể phân tích hình ảnh');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Chấp nhận kết quả phân tích
  static Future<Map<String, dynamic>?> acceptAnalysis(int mealId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse('$baseUrl/api/ai-analyzed-meals/$mealId/accept');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['today'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Không thể chấp nhận meal');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Từ chối kết quả phân tích (xóa)
  static Future<bool> rejectAnalysis(int mealId) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse('$baseUrl/api/ai-analyzed-meals/$mealId');

    try {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Không thể xóa meal');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Lấy danh sách meals đã phân tích
  static Future<List<Map<String, dynamic>>> getAnalyzedMeals({
    bool? accepted,
    int limit = 50,
    int offset = 0,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Chưa đăng nhập');

    var uri = Uri.parse('$baseUrl/api/ai-analyzed-meals');

    // Build query params
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (accepted != null) {
      queryParams['accepted'] = accepted.toString();
    }

    uri = uri.replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = (data['meals'] as List)
            .map((meal) => _parseItem(meal as Map<String, dynamic>))
            .toList();
        return meals;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Không thể lấy danh sách meals');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Format nutrients để hiển thị
  /// Trả về Map với key/value cho UI
  static Map<String, String> formatNutrientsForDisplay(
    Map<String, dynamic> nutrients,
  ) {
    final result = <String, String>{};

    // Main nutrients
    if (nutrients['enerc_kcal'] != null && nutrients['enerc_kcal'] > 0) {
      result['Calories'] = '${nutrients['enerc_kcal'].toStringAsFixed(1)} kcal';
    }
    if (nutrients['procnt'] != null && nutrients['procnt'] > 0) {
      result['Protein'] = '${nutrients['procnt'].toStringAsFixed(1)} g';
    }
    if (nutrients['chocdf'] != null && nutrients['chocdf'] > 0) {
      result['Carbs'] = '${nutrients['chocdf'].toStringAsFixed(1)} g';
    }
    if (nutrients['fat'] != null && nutrients['fat'] > 0) {
      result['Fat'] = '${nutrients['fat'].toStringAsFixed(1)} g';
    }

    return result;
  }

  /// Get all nutrients (76) formatted
  static Map<String, String> formatAllNutrients(
    Map<String, dynamic> nutrients,
  ) {
    final result = <String, String>{};

    nutrients.forEach((key, value) {
      if (value != null && value > 0) {
        final name = _getNutrientDisplayName(key);
        final unit = _getNutrientUnit(key);
        result[name] = '${value.toStringAsFixed(2)} $unit';
      }
    });

    return result;
  }

  static String _getNutrientDisplayName(String code) {
    const names = {
      'enerc_kcal': 'Calories',
      'procnt': 'Protein',
      'fat': 'Tổng chất béo',
      'chocdf': 'Carbohydrate',
      'fibtg': 'Chất xơ',
      'cholesterol': 'Cholesterol',
      'vita': 'Vitamin A',
      'vitd': 'Vitamin D',
      'vite': 'Vitamin E',
      'vitk': 'Vitamin K',
      'vitc': 'Vitamin C',
      'vitb1': 'Vitamin B1',
      'vitb2': 'Vitamin B2',
      'vitb3': 'Vitamin B3',
      'vitb5': 'Vitamin B5',
      'vitb6': 'Vitamin B6',
      'vitb7': 'Vitamin B7',
      'vitb9': 'Vitamin B9',
      'vitb12': 'Vitamin B12',
      'ca': 'Calcium',
      'p': 'Phosphorus',
      'mg': 'Magnesium',
      'k': 'Potassium',
      'na': 'Sodium',
      'fe': 'Iron',
      'zn': 'Zinc',
      'cu': 'Copper',
      'mn': 'Manganese',
      'i': 'Iodine',
      'se': 'Selenium',
      'cr': 'Chromium',
      'mo': 'Molybdenum',
      'f': 'Fluoride',
      // Minerals với prefix MIN_
      'min_ca': 'Calcium',
      'min_p': 'Phosphorus',
      'min_mg': 'Magnesium',
      'min_k': 'Potassium',
      'min_na': 'Sodium',
      'min_fe': 'Iron',
      'min_zn': 'Zinc',
      'min_cu': 'Copper',
      'min_mn': 'Manganese',
      'min_i': 'Iodine',
      'min_se': 'Selenium',
      'min_cr': 'Chromium',
      'min_mo': 'Molybdenum',
      'min_f': 'Fluoride',
      // Amino Acids
      'amino_his': 'Histidine',
      'amino_ile': 'Isoleucine',
      'amino_leu': 'Leucine',
      'amino_lys': 'Lysine',
      'amino_met': 'Methionine',
      'amino_phe': 'Phenylalanine',
      'amino_thr': 'Threonine',
      'amino_trp': 'Tryptophan',
      'amino_val': 'Valine',
      // Fiber
      'fib_sol': 'Soluble Fiber',
      'fib_insol': 'Insoluble Fiber',
      'fib_rs': 'Resistant Starch',
      'fib_bglu': 'Beta-Glucan',
      // Fatty Acids
      'fams': 'Monounsaturated Fat',
      'fapu': 'Polyunsaturated Fat',
      'fasat': 'Saturated Fat',
      'fatrn': 'Trans Fat',
      'faepa': 'EPA',
      'fadha': 'DHA',
      'fa18_3n3': 'Omega-3 (ALA)',
      'fa18_2n6c': 'Omega-6 (LA)',
      'ala': 'ALA',
      'water_ml': 'Water',
    };

    return names[code.toLowerCase()] ?? code.toUpperCase();
  }

  static String _getNutrientUnit(String code) {
    if (code == 'enerc_kcal') return 'kcal';
    if (code.startsWith('vit')) {
      if (code == 'vita' ||
          code == 'vitk' ||
          code == 'vitb7' ||
          code == 'vitb9' ||
          code == 'vitb12') {
        return 'µg';
      }
      if (code == 'vitd') return 'IU';
      return 'mg';
    }
    if (code.startsWith('amino_')) return 'g';
    if (code == 'i' || code == 'se' || code == 'cr' || code == 'mo')
      return 'µg';
    if (code == 'cholesterol' || code.length == 2) return 'mg'; // minerals
    return 'g';
  }
}
