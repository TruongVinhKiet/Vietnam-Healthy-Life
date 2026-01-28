import 'dart:math' as math;
import 'package:my_diary/fitness_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import '../config/api_config.dart';

class BodyMeasurementView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const BodyMeasurementView({
    super.key,
    this.animationController,
    this.animation,
  });

  @override
  State<BodyMeasurementView> createState() => _BodyMeasurementViewState();
}

class _BodyMeasurementViewState extends State<BodyMeasurementView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _loading = true;
  Map<String, dynamic>? _measurement;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    );
    _loadMeasurement();
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadMeasurement() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/body-measurement/latest'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _measurement = data['measurement'];
            _loading = false;
          });
          _scoreAnimationController.reset();
          _scoreAnimationController.forward();
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('[BodyMeasurement] Error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return const Color(0xFF00E676); // Green - Perfect
    if (score >= 7) return const Color(0xFF76FF03); // Light Green - Good
    if (score >= 5) return const Color(0xFFFFD600); // Yellow - Normal
    if (score >= 3) return const Color(0xFFFF6D00); // Orange - Warning
    return const Color(0xFFDD2C00); // Red - Critical
  }

  String _getScoreLabel(int score) {
    final l10n = AppLocalizations.of(context)!;
    if (score >= 9) return l10n.perfect;
    if (score >= 7) return l10n.good;
    if (score >= 5) return l10n.normal;
    if (score >= 3) return l10n.needAttention;
    return l10n.needImprovement;
  }

  String _getCategoryText(String? category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'severely_underweight':
        return l10n.severelyUnderweight;
      case 'underweight':
      case 'mild_underweight':
        return l10n.underweight;
      case 'normal':
      case 'optimal':
        return l10n.normal;
      case 'normal_high':
        return l10n.slightlyOverweight;
      case 'overweight':
        return l10n.overweight;
      case 'obese_class_1':
      case 'obese_class_2':
      case 'obese_class_3':
        return l10n.obese;
      default:
        return l10n.notDetermined;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - widget.animation!.value),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 18,
              ),
              child: GestureDetector(
                onTap: () {
                  // Tap to refresh
                  _loadMeasurement();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FitnessAppTheme.white,
                        FitnessAppTheme.white.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                      topRight: Radius.circular(68.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 16.0,
                      ),
                    ],
                  ),
                  child: _loading
                      ? _buildLoadingState()
                      : (_measurement == null
                            ? _buildEmptyState()
                            : _buildContent()),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(40.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Icon(
            Icons.monitor_weight_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noMeasurements,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 16,
              color: FitnessAppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Parse values from database (may be strings or numbers)
    final weightKg = double.parse(_measurement!['weight_kg'].toString());
    final heightCm = double.parse(_measurement!['height_cm'].toString());
    final bmi = double.parse(_measurement!['bmi'].toString());
    final score =
        int.tryParse(_measurement!['bmi_score']?.toString() ?? '5') ?? 5;
    final category = _measurement!['bmi_category'] as String?;
    final measurementDate = _measurement!['measurement_date'] as String?;

    // Convert weight to lbs for display
    final weightLbs = (weightKg * 2.20462).toStringAsFixed(1);

    return Column(
      children: <Widget>[
        // Header with weight and date
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Left: Weight in lbs and kg
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Text(
                          l10n.weight,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 0.2,
                            color: FitnessAppTheme.grey.withValues(alpha: 0.8),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            weightLbs,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                              color: FitnessAppTheme.nearlyDarkBlue,
                            ),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 6,
                                bottom: 6,
                              ),
                              child: Text(
                                l10n.lbs,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: FitnessAppTheme.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyDarkBlue.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${weightKg.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: FitnessAppTheme.nearlyDarkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Date info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: FitnessAppTheme.grey.withValues(alpha: 0.6),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(measurementDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 11,
                          color: FitnessAppTheme.grey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FitnessAppTheme.grey.withValues(alpha: 0.0),
                  FitnessAppTheme.grey.withValues(alpha: 0.2),
                  FitnessAppTheme.grey.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),

        // BMI Score Circle and Stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: <Widget>[
              // Left: Height & BMI
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return _buildStatItem(
                          '${heightCm.toStringAsFixed(0)} cm',
                          l10n.height,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return _buildStatItem(
                          '${bmi.toStringAsFixed(1)} ${l10n.bmi}',
                          _getCategoryText(category),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Center: BMI Score Circle
              _buildScoreCircle(score),

              const SizedBox(width: 20),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: FitnessAppTheme.darkText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontSize: 12,
            color: FitnessAppTheme.grey.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(int score) {
    final color = _getScoreColor(score);
    final label = _getScoreLabel(score);

    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final animatedScore = (score * _scoreAnimation.value).toInt();

        return SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated circular progress
              CustomPaint(
                size: const Size(120, 120),
                painter: _ScoreCirclePainter(
                  score: animatedScore,
                  color: color,
                  progress: _scoreAnimation.value,
                ),
              ),

              // Score text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$animatedScore',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: FitnessAppTheme.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Today';
    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays == 0) {
        return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${dt.day}/${dt.month}/${dt.year}';
      }
    } catch (e) {
      return 'Today';
    }
  }
}

class _ScoreCirclePainter extends CustomPainter {
  final int score;
  final Color color;
  final double progress;

  _ScoreCirclePainter({
    required this.score,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    // Score arc
    final scorePaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.6), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 10.0) * 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      scorePaint,
    );

    // Glow effect
    if (progress > 0.8) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreCirclePainter oldDelegate) =>
      oldDelegate.score != score ||
      oldDelegate.color != color ||
      oldDelegate.progress != progress;
}
