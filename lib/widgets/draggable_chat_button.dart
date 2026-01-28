import 'package:flutter/material.dart';
import 'package:my_diary/services/chat_service.dart';
import 'package:my_diary/services/social_service.dart';
import 'package:my_diary/screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraggableChatButton extends StatefulWidget {
  const DraggableChatButton({super.key});

  @override
  State<DraggableChatButton> createState() => _DraggableChatButtonState();
}

class _DraggableChatButtonState extends State<DraggableChatButton> {
  double _x = 0.85; // 85% from left (default right side)
  double _y = 0.35; // 35% from top (below lightbulb)
  bool _isDragging = false;
  int _unreadCount = 0;
  int _unreadFriends = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosition();
    _loadUnreadCount();
  }

  Future<void> _loadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _x = prefs.getDouble('chat_button_x') ?? 0.85;
          _y = prefs.getDouble('chat_button_y') ?? 0.35;
        });
      }
    } catch (e) {
      // Use defaults
    }
  }

  Future<void> _savePosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('chat_button_x', _x);
      await prefs.setDouble('chat_button_y', _y);
    } catch (e) {
      // Ignore save errors
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await ChatService.getUnreadCount();
      int friendRequestsCount = 0;
      try {
        final requests = await SocialService.getFriendRequests(
          type: 'received',
        );
        friendRequestsCount = requests.length;
      } catch (e) {
        // Ignore errors
      }

      if (mounted) {
        setState(() {
          _unreadCount = count;
          _unreadFriends = friendRequestsCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openChat() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ChatScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 350),
          ),
        )
        .then((_) {
          // Reload unread count when returning from chat
          _loadUnreadCount();
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final buttonSize = 56.0;

    return Positioned(
      left: _x * (screenSize.width - buttonSize),
      top: _y * (screenSize.height - buttonSize),
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _x =
                (_x * (screenSize.width - buttonSize) + details.delta.dx) /
                (screenSize.width - buttonSize);
            _y =
                (_y * (screenSize.height - buttonSize) + details.delta.dy) /
                (screenSize.height - buttonSize);

            // Clamp values
            _x = _x.clamp(0.0, 1.0);
            _y = _y.clamp(0.0, 1.0);
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
          _savePosition();
        },
        onTap: _openChat,
        child: Hero(
          tag: 'chat-button',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isDragging
                    ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                    : [
                        const Color(0xFF667EEA).withValues(alpha: 0.95),
                        const Color(0xFF764BA2).withValues(alpha: 0.95),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF667EEA,
                  ).withValues(alpha: _isDragging ? 0.5 : 0.4),
                  blurRadius: _isDragging ? 16 : 12,
                  spreadRadius: _isDragging ? 3 : 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(buttonSize / 2),
                onTap: _openChat,
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    if (!_isLoading && (_unreadCount > 0 || _unreadFriends > 0))
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            (_unreadCount + _unreadFriends) > 99
                                ? '99+'
                                : '${_unreadCount + _unreadFriends}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
