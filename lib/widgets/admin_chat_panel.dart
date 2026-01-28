import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../models/health_condition_model.dart';
import '../screens/admin_dish_detail_screen.dart';
import '../screens/admin_drink_detail_screen.dart';
import '../screens/admin_user_activity_screen.dart';
import '../screens/drug_detail_screen.dart';
import '../screens/health_condition_detail_screen.dart';

class AdminChatPanel extends StatefulWidget {
  const AdminChatPanel({super.key});

  @override
  State<AdminChatPanel> createState() => _AdminChatPanelState();
}

class _AdminChatPanelState extends State<AdminChatPanel> {
  List<Map<String, dynamic>> _conversations = [];
  Map<String, dynamic>? _selectedConversation;
  int? _selectedConversationId;
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;

  // Navigation: true = show chat view, false = show list view
  bool _showingChatView = false;

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
    final rawId =
        conversation['admin_conversation_id'] ??
        conversation['conversation_id'] ??
        conversation['conversationId'];
    if (rawId is int) return rawId;
    if (rawId is String) return int.tryParse(rawId);
    if (rawId is double) return rawId.toInt();
    return null;
  }

  int? _getUserId(Map<String, dynamic>? conversation) {
    if (conversation == null) return null;
    final rawId =
        conversation['user_id'] ??
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
        builder: (context) =>
            AdminUserActivityScreen(userId: userId, userName: userName),
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
            final foodsToAvoid =
                (data['condition']['foods_to_avoid'] as List?)
                    ?.map((e) => FoodRecommendation.fromJson(e))
                    .toList() ??
                [];
            final foodsToRecommend =
                ((data['condition']['foods_to_recommend'] ??
                            data['condition']['food_recommendations'])
                        as List?)
                    ?.map((e) => FoodRecommendation.fromJson(e))
                    .toList() ??
                [];
            final drugs =
                (data['condition']['drugs'] as List?)
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
      return Text(text, style: TextStyle(color: textColor, fontSize: 15));
    }

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    const Color tagColor = Color(0xFF1B4B91);

    for (final tag in tags) {
      if (tag['start'] > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, tag['start']),
            style: TextStyle(color: textColor, fontSize: 15),
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
                style: TextStyle(
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
          style: TextStyle(color: textColor, fontSize: 15),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
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
        final List<Map<String, dynamic>> rawList =
            List<Map<String, dynamic>>.from(data['conversations'] ?? []);
        setState(() {
          _conversations = rawList.map((conv) {
            final normalized = Map<String, dynamic>.from(conv);
            final id = _getConversationId(normalized);
            if (id != null) {
              normalized['admin_conversation_id'] = id;
            }
            return normalized;
          }).toList();
          _isLoading = false;
        });

        // Preserve selection if possible, but DON'T auto-select first
        final currentId = _selectedConversationId;
        Map<String, dynamic>? newSelection;
        if (currentId != null) {
          newSelection = _conversations.firstWhere(
            (c) => _getConversationId(c) == currentId,
            orElse: () => <String, dynamic>{},
          );
          if (newSelection.isEmpty) newSelection = null;
        }
        // Removed auto-select first conversation
        // User must click to see messages

        if (newSelection != null) {
          final convoId = _getConversationId(newSelection);
          setState(() {
            _selectedConversation = newSelection;
            _selectedConversationId = convoId;
          });
          if (convoId != null) {
            _loadMessages(convoId);
          }
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải conversations: $e')));
      }
    }
  }

  Future<void> _loadMessages(int conversationId) async {
    setState(() => _isLoadingMessages = true);
    try {
      final token = await AuthService.getToken();
      final id = conversationId;
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/chat/conversations/$id/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
          _isLoadingMessages = false;
        });
      } else {
        setState(() => _isLoadingMessages = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Không thể tải tin nhắn (mã ${response.statusCode})',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoadingMessages = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải messages: $e')));
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty ||
        _selectedConversationId == null)
      return;

    setState(() => _isSending = true);
    try {
      final token = await AuthService.getToken();
      final conversationId = _selectedConversationId!;

      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/chat/conversations/$conversationId/messages',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'message': _messageController.text.trim()}),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        await _loadMessages(conversationId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi gửi tin nhắn: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Full-screen chat view with back button
  Widget _buildChatView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Chat Header with Back Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _showingChatView = false;
                      _selectedConversation = null;
                      _selectedConversationId = null;
                      _messages.clear();
                    });
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openUserActivity,
                  child: _buildUserAvatar(
                    _selectedConversation ?? {},
                    isHeader: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openUserActivity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedConversation?['user_email'] ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _selectedConversation?['subject'] ?? 'Hỗ trợ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: _openUserActivity,
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _isLoadingMessages
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyMessagesState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: _selectedConversationId != null && !_isSending,
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
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  mini: true,
                  onPressed: _isSending ? null : _sendMessage,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navigation: if showing chat view, display full-screen chat
    if (_showingChatView && _selectedConversation != null) {
      return _buildChatView();
    }

    // Otherwise show conversations list
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Hỗ trợ người dùng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadConversations,
                ),
              ],
            ),
          ),

          // Conversations List
          Expanded(child: _buildConversationsList()),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Chưa có cuộc hội thoại nào',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conv = _conversations[index];
        final convId = _getConversationId(conv);
        final isSelected =
            _selectedConversationId != null &&
            _selectedConversationId == convId;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedConversation = conv;
              _selectedConversationId = convId;
              _messages = [];
              _showingChatView = true; // Navigate to chat view
            });
            if (convId != null) {
              _loadMessages(convId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Không xác định được cuộc hội thoại này'),
                ),
              );
            }
          },
          child: Container(
            color: isSelected ? Colors.blue.shade50 : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildUserAvatar(conv),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conv['user_email'] ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conv['subject'] ?? 'Hỗ trợ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // unread_count may come as string from backend; coerce safely to int
                (() {
                  final raw = conv['unread_count'];
                  int unread = 0;
                  if (raw is int)
                    unread = raw;
                  else if (raw is double)
                    unread = raw.toInt();
                  else if (raw != null)
                    unread = int.tryParse(raw.toString()) ?? 0;
                  if (unread > 0) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unread.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                })(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyMessagesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          const Text('Chưa có tin nhắn nào trong hội thoại này'),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isAdmin = message['sender_type'] == 'admin';

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: isAdmin
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAdmin ? Colors.blue.shade500 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _buildTextWithTags(
                message['message_text'] ?? '',
                textColor: isAdmin ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['created_at']),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
      if (diff.inDays < 1) return '${diff.inHours} giờ trước';
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
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
}
