import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import '../../models/health_condition_model.dart';
import '../../screens/admin_dish_detail_screen.dart';
import '../../screens/admin_drink_detail_screen.dart';
import '../../screens/admin_user_activity_screen.dart';
import '../../screens/drug_detail_screen.dart';
import '../../screens/health_condition_detail_screen.dart';

class WebAdminChat extends StatefulWidget {
  const WebAdminChat({super.key});

  @override
  State<WebAdminChat> createState() => _WebAdminChatState();
}

class _WebAdminChatState extends State<WebAdminChat> {
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _selectedConversation;
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;

  int? _getUserId(Map<String, dynamic>? conversation) {
    if (conversation == null) return null;
    final rawId = conversation['user_id'] ??
        conversation['userId'] ??
        conversation['uid'] ??
        (conversation['user'] is Map ? conversation['user']['user_id'] : null);
    if (rawId is int) return rawId;
    if (rawId is String) return int.tryParse(rawId);
    if (rawId is double) return rawId.toInt();
    return null;
  }

  Future<void> _openUserActivity() async {
    final conv = _selectedConversation;
    final userId = _getUserId(conv);

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không xác định được người dùng')),
        );
      }
      return;
    }

    final userName =
        (conv?['user_email'] ?? conv?['user_name'] ?? 'User $userId')
            .toString();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserActivityScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _parseTags(String text) {
    final List<Map<String, dynamic>> tags = [];
    final RegExp tagRegex = RegExp(r'@\[([^:]+):(\d+):([^\]]+)\]');
    final matches = tagRegex.allMatches(text);

    for (final match in matches) {
      tags.add({
        'type': match.group(1),
        'id': int.tryParse(match.group(2) ?? '0') ?? 0,
        'name': match.group(3) ?? '',
        'start': match.start,
        'end': match.end,
      });
    }

    return tags;
  }

  Future<void> _navigateToTagDetail(Map<String, dynamic> tag) async {
    final type = tag['type']?.toString() ?? '';
    final id = tag['id'] as int? ?? 0;
    final name = tag['name']?.toString() ?? '';

    if (!mounted) return;

    try {
      if (type == 'dish') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDishDetailScreen(dishId: id),
          ),
        );
      } else if (type == 'drink') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDrinkDetailScreen(drinkId: id),
          ),
        );
      } else if (type == 'drug') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrugDetailScreen(drugId: id, drugName: name),
          ),
        );
      } else if (type == 'healthCondition') {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/health/conditions/$id'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['condition'] != null) {
            final condition = HealthCondition.fromJson(data['condition']);
            final nutrientEffects =
                (data['condition']['nutrient_effects'] as List?)
                        ?.map((e) => NutrientEffect.fromJson(e))
                        .toList() ??
                    [];
            final foodsToAvoid = (data['condition']['foods_to_avoid'] as List?)
                    ?.map((e) => FoodRecommendation.fromJson(e))
                    .toList() ??
                [];
            final foodsToRecommend = ((data['condition']
                            ['foods_to_recommend'] ??
                        data['condition']['food_recommendations']) as List?)
                    ?.map((e) => FoodRecommendation.fromJson(e))
                    .toList() ??
                [];
            final drugs = (data['condition']['drugs'] as List?)
                    ?.map((e) => DrugTreatment.fromJson(e))
                    .toList() ??
                [];

            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthConditionDetailScreen(
                  condition: condition,
                  nutrientEffects: nutrientEffects,
                  foodsToAvoid: foodsToAvoid,
                  foodsToRecommend: foodsToRecommend,
                  drugs: drugs,
                  isAdminView: true,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi mở chi tiết: $e')));
      }
    }
  }

  Widget _buildTextWithTags(String text, {Color? textColor}) {
    final tags = _parseTags(text);
    if (tags.isEmpty) {
      return Text(text, style: TextStyle(color: textColor, fontSize: 14));
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    const Color tagColor = Color(0xFF1B4B91);

    for (final tag in tags) {
      if (tag['start'] > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, tag['start']),
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        );
      }

      spans.add(
        WidgetSpan(
          child: GestureDetector(
            onTap: () => _navigateToTagDetail(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tagColor, width: 1.2),
              ),
              child: Text(
                '@${tag['name']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  backgroundColor: tagColor,
                ),
              ),
            ),
          ),
        ),
      );

      lastIndex = tag['end'];
    }

    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  int? _getConversationId(Map<String, dynamic>? conversation) {
    if (conversation == null) return null;
    final rawId = conversation['admin_conversation_id'] ??
        conversation['conversation_id'] ??
        conversation['conversationId'] ??
        conversation['id'];
    if (rawId is int) return rawId;
    if (rawId is String) {
      final parsed = int.tryParse(rawId);
      if (parsed != null) return parsed;
    }
    if (rawId is double) return rawId.toInt();
    return null;
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/chat/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> rawList = data['conversations'] ?? [];
        setState(() {
          _conversations = rawList.map((conv) {
            final normalized = Map<String, dynamic>.from(conv as Map);
            // Normalize conversation_id to int
            final id = _getConversationId(normalized);
            if (id != null) {
              normalized['admin_conversation_id'] = id;
              normalized['conversation_id'] = id;
            }
            // Normalize unread_count to int
            final unread = normalized['unread_count'];
            if (unread != null) {
              if (unread is String) {
                normalized['unread_count'] = int.tryParse(unread) ?? 0;
              } else if (unread is int) {
                normalized['unread_count'] = unread;
              } else {
                normalized['unread_count'] = 0;
              }
            } else {
              normalized['unread_count'] = 0;
            }
            return normalized;
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages(int conversationId) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      // Ensure conversationId is properly converted to string for URL
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/chat/conversations/${conversationId.toString()}/messages',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(int conversationId) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/chat/conversations/$conversationId/messages',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message': message}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _messageController.clear();
        _loadMessages(conversationId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi tin nhắn: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _selectConversation(Map<String, dynamic> conversation) {
    final conversationId = _getConversationId(conversation);
    if (conversationId != null) {
      setState(() {
        _selectedConversation = conversation;
      });
      _loadMessages(conversationId);
    }
  }

  int _getUnreadCount(Map<String, dynamic> conversation) {
    return conversation['unread_count'] ?? 0;
  }

  String? _resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiConfig.baseUrl}$url';
  }

  Widget _buildUserAvatar(Map<String, dynamic> conv, {bool isHeader = false}) {
    final avatarUrl = _resolveAvatarUrl(conv['avatar_url']?.toString());
    final userEmail = conv['user_email']?.toString() ?? 'U';
    final initial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : 'U';

    return CircleAvatar(
      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
          ? NetworkImage(avatarUrl)
          : null,
      backgroundColor: avatarUrl == null || avatarUrl.isEmpty
          ? (isHeader ? Colors.white : Colors.blue.shade100)
          : null,
      child: avatarUrl == null || avatarUrl.isEmpty
          ? Text(
              initial,
              style: TextStyle(
                color: isHeader ? Colors.blue.shade700 : Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Conversations List
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Hỗ trợ người dùng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadConversations,
                        tooltip: 'Làm mới',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _conversations.isEmpty
                          ? const Center(
                              child: Text('Không có cuộc trò chuyện nào'),
                            )
                          : ListView.builder(
                              itemCount: _conversations.length,
                              itemBuilder: (context, index) {
                                final conversation = _conversations[index];
                                final isSelected = _selectedConversation !=
                                        null &&
                                    _getConversationId(_selectedConversation) ==
                                        _getConversationId(conversation);
                                final unreadCount =
                                    _getUnreadCount(conversation);

                                return ListTile(
                                  selected: isSelected,
                                  leading: _buildUserAvatar(conversation),
                                  title: Text(
                                    conversation['user_email'] ?? 'Người dùng',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(
                                    conversation['subject'] ??
                                        'Hỗ trợ khách hàng',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: unreadCount > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : null,
                                  onTap: () =>
                                      _selectConversation(conversation),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Chat View
          Expanded(
            child: _selectedConversation == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chọn cuộc trò chuyện để xem tin nhắn',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // Chat Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _openUserActivity,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    (_selectedConversation!['user_email'] ??
                                            'U')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _openUserActivity,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedConversation!['user_email'] ??
                                            'Người dùng',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _selectedConversation!['subject'] ??
                                            'Hỗ trợ khách hàng',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _openUserActivity,
                                icon: const Icon(Icons.info_outline),
                                tooltip: 'Chi tiết người dùng',
                              ),
                            ],
                          ),
                        ),
                        // Messages
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _messages.isEmpty
                                  ? const Center(
                                      child: Text('Chưa có tin nhắn nào'),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _messages.length,
                                      itemBuilder: (context, index) {
                                        final message = _messages[index];
                                        final isAdmin =
                                            message['sender_type'] == 'admin';

                                        return Align(
                                          alignment: isAdmin
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 8),
                                            padding: const EdgeInsets.all(12),
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isAdmin
                                                  ? Colors.blue.shade50
                                                  : Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildTextWithTags(
                                                  message['message_text'] ?? '',
                                                  textColor: Colors.black87,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  message['created_at']
                                                          ?.toString()
                                                          .split('T')[0] ??
                                                      '',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                        // Message Input
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tin nhắn...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: _isSending
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send),
                                onPressed: _isSending
                                    ? null
                                    : () {
                                        final conversationId =
                                            _getConversationId(
                                                _selectedConversation);
                                        if (conversationId != null) {
                                          _sendMessage(conversationId);
                                        }
                                      },
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
