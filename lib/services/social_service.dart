import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import '../config/api_config.dart';

class SocialService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Community Chat
  static Future<List<Map<String, dynamic>>> getCommunityMessages({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/social/community/messages?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      } else {
        throw Exception(
          'Failed to load community messages: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting community messages: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> postCommunityMessage({
    String? messageText,
    String? imageUrl,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/social/community/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message_text': messageText, 'image_url': imageUrl}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error posting community message: $e');
      rethrow;
    }
  }

  // Message Reactions
  static Future<bool> reactToMessage({
    required String messageType,
    required int messageId,
    required String reactionType,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/social/messages/react'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message_type': messageType,
          'message_id': messageId,
          'reaction_type': reactionType,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to react: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error reacting to message: $e');
      rethrow;
    }
  }

  // Friend Requests
  static Future<Map<String, dynamic>> sendFriendRequest(int receiverId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/social/friends/request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'receiver_id': receiverId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to send friend request');
      }
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getFriendRequests({
    String type = 'received',
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/social/friends/requests?type=$type'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['friend_requests'] ?? []);
      } else if (response.statusCode == 401) {
        return [];
      } else {
        throw Exception(
          'Failed to get friend requests: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting friend requests: $e');
      return [];
    }
  }

  static Future<bool> respondToFriendRequest(
    int requestId,
    String action,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/social/friends/requests/$requestId/respond'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'action': action, // 'accept' or 'reject'
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to respond: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error responding to friend request: $e');
      rethrow;
    }
  }

  // Friends
  static Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/social/friends'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['friends'] ?? []);
      } else if (response.statusCode == 401) {
        return [];
      } else {
        throw Exception('Failed to get friends: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting friends: $e');
      return [];
    }
  }

  // Private Messaging
  static Future<Map<String, dynamic>> getOrCreatePrivateConversation(
    int friendId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/social/conversations/$friendId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get conversation: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting conversation: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getPrivateMessages(
    int conversationId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/social/conversations/$conversationId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      } else {
        throw Exception('Failed to get messages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting private messages: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendPrivateMessage({
    required int conversationId,
    String? messageText,
    String? imageUrl,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('$baseUrl/social/conversations/$conversationId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message_text': messageText, 'image_url': imageUrl}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending private message: $e');
      rethrow;
    }
  }

  // Body Measurements (for friends)
  static Future<List<Map<String, dynamic>>> getUserBodyMeasurements(
    int userId,
  ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('$baseUrl/social/users/$userId/body-measurements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['measurements'] ?? []);
      } else {
        throw Exception(
          'Failed to get body measurements: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting body measurements: $e');
      rethrow;
    }
  }

  static Future<String> uploadImage(
    Uint8List bytes, {
    String folder = 'chat',
    String? mimeType,
    String? filename,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final dataUrl =
        'data:${mimeType ?? 'image/png'};base64,${base64Encode(bytes)}';

    final response = await http.post(
      Uri.parse('$baseUrl/social/upload-image'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'image_data': dataUrl,
        'folder': folder,
        if (filename != null) 'filename': filename,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['imageUrl'] != null) {
        return data['imageUrl'];
      }
      throw Exception('Image URL missing from response');
    } else {
      throw Exception(
        'Failed to upload image: ${response.statusCode} ${response.body}',
      );
    }
  }
}
