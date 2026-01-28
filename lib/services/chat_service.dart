import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';

class ChatService {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    return envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
  }

  // ============================================================
  // CHATBOT METHODS
  // ============================================================

  /// Get or create chatbot conversation
  static Future<Map<String, dynamic>?> getChatbotConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        debugPrint('No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/chat/chatbot/conversation'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns { conversation: {...} }
        return data['conversation'];
      } else {
        debugPrint('Error response: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error getting chatbot conversation: $e');
      return null;
    }
  }

  /// Get messages for chatbot conversation
  static Future<List<Map<String, dynamic>>> getChatbotMessages(
    int conversationId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/chat/chatbot/conversation/$conversationId/messages',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting chatbot messages: $e');
      return [];
    }
  }

  /// Send text message to chatbot
  static Future<Map<String, dynamic>?> sendChatbotMessage(
    int conversationId,
    String message,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/chat/chatbot/conversation/$conversationId/message'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error sending chatbot message: $e');
      return null;
    }
  }

  /// Analyze food image
  static Future<Map<String, dynamic>?> analyzeFoodImage(
    int conversationId,
    XFile imageFile,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return null;

      // Read image as bytes and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
          '$baseUrl/chat/chatbot/conversation/$conversationId/analyze-image',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'image': base64Image,
          'filename':
              imageFile.name, // Include original filename for mock matching
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Error response: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error analyzing food image: $e');
      return null;
    }
  }

  /// Approve or reject nutrition analysis
  static Future<Map<String, dynamic>?> approveNutrition(
    int messageId,
    bool approved,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return null;

      final response = await http.post(
        Uri.parse('$baseUrl/chat/chatbot/message/$messageId/approve'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'approved': approved}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error approving nutrition: $e');
      return null;
    }
  }

  // ============================================================
  // ADMIN CHAT METHODS
  // ============================================================

  /// Get or create admin conversation
  static Future<Map<String, dynamic>?> getAdminConversation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) {
        debugPrint('No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/chat/admin-chat/conversation'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns { conversation: {...} }
        return data['conversation'];
      } else {
        debugPrint('Error response: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error getting admin conversation: $e');
      return null;
    }
  }

  /// Get messages for admin conversation
  static Future<List<Map<String, dynamic>>> getAdminMessages(
    int conversationId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/chat/admin-chat/conversation/$conversationId/messages',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting admin messages: $e');
      return [];
    }
  }

  /// Send message to admin
  static Future<Map<String, dynamic>?> sendAdminMessage(
    int conversationId,
    String message, {
    String? imageUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return null;

      final response = await http.post(
        Uri.parse(
          '$baseUrl/chat/admin-chat/conversation/$conversationId/message',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payload = data is Map<String, dynamic>
            ? (data['message'] ?? data)
            : data;
        if (payload is Map<String, dynamic>) {
          return payload;
        }
        return {'message': payload};
      }
      return null;
    } catch (e) {
      debugPrint('Error sending admin message: $e');
      return null;
    }
  }

  /// Get unread admin messages count
  static Future<int> getUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('$baseUrl/chat/admin-chat/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}
