import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AminoService {
  // Keep same base as AuthService
  static String get _baseUrl => ApiConfig.baseUrl;

  // Note: requests are unauthenticated by default; backend will return per-user recommended only when
  // an Authorization header is present. This keeps the client simple; add auth headers later if needed.
  static Future<List<Map<String, dynamic>>?> getAminoAcids({int? top}) async {
    final uri = Uri.parse(
      '$_baseUrl/amino_acids${top != null ? '?top=$top' : ''}',
    );
    try {
      final res = await http.get(uri);
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

  static Future<Map<String, dynamic>?> getAminoById(int id) async {
    final uri = Uri.parse('$_baseUrl/amino_acids/$id');
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
