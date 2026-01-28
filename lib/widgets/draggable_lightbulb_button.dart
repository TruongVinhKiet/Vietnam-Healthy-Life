import 'package:flutter/material.dart';
import 'package:my_diary/services/smart_suggestion_service.dart';
import 'package:my_diary/screens/smart_suggestions_screen.dart';

class DraggableLightbulbButton extends StatefulWidget {
  const DraggableLightbulbButton({super.key});

  @override
  State<DraggableLightbulbButton> createState() =>
      _DraggableLightbulbButtonState();
}

class _DraggableLightbulbButtonState extends State<DraggableLightbulbButton> {
  double _x = 0.85; // 85% from left (default right side)
  double _y = 0.15; // 15% from top
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final position = await SmartSuggestionService.getLightbulbPosition();
    if (mounted) {
      setState(() {
        _x = position['x'] ?? 0.85;
        _y = position['y'] ?? 0.15;
      });
    }
  }

  Future<void> _savePosition() async {
    await SmartSuggestionService.saveLightbulbPosition(_x, _y);
  }

  void _onTap() {
    // Navigate to Smart Suggestions screen with Hero animation
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SmartSuggestionsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
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
        onTap: _onTap,
        child: Hero(
          tag: 'lightbulb_hero',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDragging
                    ? [Colors.amber.shade400, Colors.orange.shade600]
                    : [Colors.amber.shade300, Colors.orange.shade500],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(
                    alpha: _isDragging ? 0.5 : 0.3,
                  ),
                  blurRadius: _isDragging ? 20 : 15,
                  spreadRadius: _isDragging ? 5 : 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(buttonSize / 2),
                onTap: _onTap,
                child: Center(
                  child: Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 30,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
