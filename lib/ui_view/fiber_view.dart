// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class FiberView extends StatefulWidget {
  const FiberView({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  });
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  @override
  _FiberViewState createState() => _FiberViewState();
}

class _FiberViewState extends State<FiberView> with TickerProviderStateMixin {
  double percent = 0.0;
  double recommended = 25.0;
  double consumed = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRecommended();
  }

  Future<void> _loadRecommended() async {
    // Load nutrient tracking to get TOTAL_FIBER consumption
    final nutrients = await AuthService.getDailyNutrientTracking();

    double fiberConsumed = 0.0;
    double fiberTarget = 25.0;

    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
          'fiber') {
        final code =
            (nutrient['nutrient_code']?.toString().toUpperCase() ?? '');
        if (code != 'TOTAL_FIBER' && code != 'FIBTG') {
          continue;
        }
        final current = nutrient['current_amount'];
        final target = nutrient['target_amount'];

        if (current != null) {
          fiberConsumed = (current is num)
              ? current.toDouble()
              : double.tryParse(current.toString()) ?? 0.0;
        }

        if (target != null) {
          fiberTarget = (target is num)
              ? target.toDouble()
              : double.tryParse(target.toString()) ?? 25.0;
        }
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      consumed = fiberConsumed;
      recommended = fiberTarget;
      percent = recommended > 0
          ? (consumed / recommended * 100.0).clamp(0.0, 100.0)
          : 0.0;
    });

    // Check if goal is completed (>= 100%)
    if (recommended > 0 && consumed >= recommended) {
      LocalNotificationService().checkAndNotifyProgressCompletion(
        type: 'nutrient',
        name: AppLocalizations.of(context)!.fiber,
        consumed: consumed,
        target: recommended,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
          widget.mainScreenAnimationController ??
          AnimationController(vsync: this),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity:
              widget.mainScreenAnimation ?? const AlwaysStoppedAnimation(1.0),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: 18,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: FitnessAppTheme.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topRight: Radius.circular(68.0),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: FitnessAppTheme.grey.withAlpha((0.2 * 255).round()),
                    offset: const Offset(1.1, 1.1),
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top row with decorative icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.grass,
                          color: Colors.green.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        Icon(
                          Icons.spa,
                          color: Colors.green.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        Icon(
                          Icons.agriculture,
                          color: Colors.green.withValues(alpha: 0.3),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Center: Large circular progress with percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Large circular progress
                            SizedBox(
                              width: 160,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(80),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(76),
                                    child: SizedBox(
                                      width: 152,
                                      height: 152,
                                      child: WaveView(
                                        percentageValue: percent,
                                        primaryColor: const Color(0xFF43A047),
                                        secondaryColor: const Color(0xFF66BB6A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Leaf icon outside circle (top)
                            Positioned(
                              top: -10,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.eco,
                                  size: 32,
                                  color: const Color(0xFF43A047),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Text below circle: consumed/target
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          recommended > 0
                              ? '${consumed.toStringAsFixed(1)} / ${recommended.toStringAsFixed(0)} ${l10n.g}'
                              : l10n.goalNotSet,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: FitnessAppTheme.darkerText,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Bottom decorative icons and info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.local_florist,
                          color: Colors.green.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              children: [
                                Text(
                                  l10n.totalFiber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                                if (recommended > 0 && consumed > recommended)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Icon(
                                      Icons.warning_rounded,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        Icon(
                          Icons.park,
                          color: Colors.green.withValues(alpha: 0.3),
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// A simple leaf-shaped clipper. The path is drawn inside the bounding box and scaled.
class LeafClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // Draw a more natural leaf: tapered tip, smooth shoulders and rounded base
    path.moveTo(w * 0.5, h * 0.05); // tip

    // right edge down to base-right
    path.cubicTo(w * 0.78, h * 0.12, w * 0.95, h * 0.38, w * 0.88, h * 0.6);
    path.cubicTo(w * 0.84, h * 0.72, w * 0.7, h * 0.9, w * 0.5, h * 0.95);

    // left edge back to tip
    path.cubicTo(w * 0.3, h * 0.9, w * 0.16, h * 0.72, w * 0.12, h * 0.6);
    path.cubicTo(w * 0.05, h * 0.38, w * 0.22, h * 0.12, w * 0.5, h * 0.05);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(LeafClipper oldClipper) => false;
}

class LeafOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path path = LeafClipper().getClip(size);

    // subtle drop shadow
    final Paint shadow = Paint()
      ..color = Colors.black.withAlpha((0.06 * 255).round())
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadow);

    // outline stroke
    final Paint outline = Paint()
      ..color = const Color(0xFFE6F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..isAntiAlias = true;
    canvas.drawPath(path, outline);

    // draw central vein and two side veins
    final Paint vein = Paint()
      ..color = const Color.fromRGBO(255, 255, 255, 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..isAntiAlias = true;

    final Path central = Path();
    central.moveTo(size.width * 0.5, size.height * 0.06);
    central.quadraticBezierTo(
      size.width * 0.52,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.95,
    );
    canvas.drawPath(central, vein);

    final Path leftVein = Path();
    leftVein.moveTo(size.width * 0.46, size.height * 0.12);
    leftVein.quadraticBezierTo(
      size.width * 0.33,
      size.height * 0.38,
      size.width * 0.42,
      size.height * 0.7,
    );
    canvas.drawPath(leftVein, vein);

    final Path rightVein = Path();
    rightVein.moveTo(size.width * 0.54, size.height * 0.12);
    rightVein.quadraticBezierTo(
      size.width * 0.67,
      size.height * 0.38,
      size.width * 0.58,
      size.height * 0.7,
    );
    canvas.drawPath(rightVein, vein);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
