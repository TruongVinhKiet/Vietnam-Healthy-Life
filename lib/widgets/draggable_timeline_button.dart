import 'package:flutter/material.dart';
import 'package:my_diary/screens/timeline_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DraggableTimelineButton extends StatefulWidget {
  const DraggableTimelineButton({super.key});

  @override
  State<DraggableTimelineButton> createState() =>
      _DraggableTimelineButtonState();
}

class _DraggableTimelineButtonState extends State<DraggableTimelineButton> {
  double _x = 0.85;
  double _y = 0.55;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _x = prefs.getDouble('timeline_button_x') ?? 0.85;
          _y = prefs.getDouble('timeline_button_y') ?? 0.55;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _savePosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('timeline_button_x', _x);
      await prefs.setDouble('timeline_button_y', _y);
    } catch (_) {
      // ignore
    }
  }

  void _openTimeline() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TimelineScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
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
        onTap: _openTimeline,
        child: Hero(
          tag: 'timeline-button',
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
                onTap: _openTimeline,
                child: Center(
                  child: Icon(
                    Icons.access_time_rounded,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
