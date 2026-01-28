import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/hex_color.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'dart:math' as math;

/// Mediterranean diet view — keeps original visuals but uses profile values
class MediterranesnDietView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const MediterranesnDietView({
    super.key,
    this.animationController,
    this.animation,
  });

  @override
  State<MediterranesnDietView> createState() => _MediterranesnDietViewState();
}

class _MediterranesnDietViewState extends State<MediterranesnDietView> {
  ProfileNotifier? _profileNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.maybeProfile();
    if (_profileNotifier != profile) {
      _profileNotifier?.removeListener(_onProfileChanged);
      _profileNotifier = profile;
      _profileNotifier?.addListener(_onProfileChanged);
    }
  }

  @override
  void dispose() {
    _profileNotifier?.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {
        _checkProgressCompletion();
      });
    }
  }

  /// Kiểm tra và thông báo khi progress đạt 100%
  void _checkProgressCompletion() {
    final profile = context.maybeProfile();
    if (profile == null) return;

    final raw = profile.raw;
    if (raw == null) return;

    final l10n = AppLocalizations.of(context)!;

    final double tdee = profile.tdee ?? 2000.0;
    final double targetCalories = profile.dailyCalorieTarget ?? tdee;
    final int consumedCalories = (raw['today_calories'] as num?)?.toInt() ?? 0;

    // Check calories
    if (targetCalories > 0 && consumedCalories >= targetCalories) {
      LocalNotificationService().checkAndNotifyProgressCompletion(
        type: 'mediterranean',
        name: l10n.calories,
        consumed: consumedCalories.toDouble(),
        target: targetCalories,
      );
    }

    // Check macros
    final proteinTarget =
        profile.dailyProteinTarget ?? (targetCalories * 0.2 / 4);
    final carbTarget = profile.dailyCarbTarget ?? (targetCalories * 0.5 / 4);
    final fatTarget = profile.dailyFatTarget ?? (targetCalories * 0.3 / 9);

    final consumedProtein = (raw['today_protein'] as num?)?.toDouble() ?? 0.0;
    final consumedCarbs = (raw['today_carbs'] as num?)?.toDouble() ?? 0.0;
    final consumedFat = (raw['today_fat'] as num?)?.toDouble() ?? 0.0;

    if (proteinTarget > 0 && consumedProtein >= proteinTarget) {
      LocalNotificationService().checkAndNotifyProgressCompletion(
        type: 'mediterranean',
        name: l10n.protein,
        consumed: consumedProtein,
        target: proteinTarget,
      );
    }

    if (carbTarget > 0 && consumedCarbs >= carbTarget) {
      LocalNotificationService().checkAndNotifyProgressCompletion(
        type: 'mediterranean',
        name: l10n.carbs,
        consumed: consumedCarbs,
        target: carbTarget,
      );
    }

    if (fatTarget > 0 && consumedFat >= fatTarget) {
      LocalNotificationService().checkAndNotifyProgressCompletion(
        type: 'mediterranean',
        name: l10n.fat,
        consumed: consumedFat,
        target: fatTarget,
      );
    }
  }

  // Load fat target from nutrient tracking (same source as FatView)
  Future<double> _loadFatTarget() async {
    try {
      final nutrients = await AuthService.getDailyNutrientTracking();
      for (final nutrient in nutrients) {
        if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
                'fatty_acid' &&
            nutrient['nutrient_code'] == 'TOTAL_FAT') {
          final target = nutrient['target_amount'];
          if (target != null) {
            return (target is num)
                ? target.toDouble()
                : double.tryParse(target.toString()) ?? 60.0;
          }
          break;
        }
      }
    } catch (e) {
      // Fallback to profile value
    }
    return 60.0; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.maybeProfile();

    // Compute targets from profile with safe fallbacks
    final double tdee = profile?.tdee ?? 2000.0;
    final double targetD = profile?.dailyCalorieTarget ?? tdee;

    final anim = widget.animation ?? const AlwaysStoppedAnimation(1.0);
    final a = anim.value;

    // Prefer server-provided today's totals if available (keys may vary by backend)
    int eatenToday = 0;
    // Removed burnedToday as it's no longer needed
    int consumedCarb = 0;
    int consumedProtein = 0;
    int consumedFat = 0;

    // convert to int safely
    int toIntSafe(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    try {
      final raw = profile?.raw;
      if (raw != null) {
        eatenToday = toIntSafe(
          raw['today_calories'] ??
              raw['calories_today'] ??
              raw['today_total_calories'],
        );
        // Removed burnedToday as it's no longer needed
        consumedProtein = toIntSafe(
          raw['today_protein'] ?? raw['protein_today'] ?? 0,
        );
        consumedFat = toIntSafe(raw['today_fat'] ?? raw['fat_today'] ?? 0);
        consumedCarb = toIntSafe(
          raw['today_carbs'] ?? raw['carbs_today'] ?? raw['today_carb'] ?? 0,
        );
      }
    } catch (_) {
      eatenToday = 0;
      // Removed burnedToday as it's no longer needed
      consumedCarb = 0;
      consumedProtein = 0;
      consumedFat = 0;
    }

    final int eatenVal = ((eatenToday) * a).toInt();
    final int leftVal = ((targetD - eatenToday) * a)
        .toInt(); // Removed burnedToday from calculation

    final int carbTarget = (profile?.dailyCarbTarget ?? 120).toInt();
    final int proteinTarget = (profile?.dailyProteinTarget ?? 80).toInt();

    // Load fat target from nutrient tracking (same source as FatView)
    return FutureBuilder<double>(
      future: _loadFatTarget(),
      builder: (context, snapshot) {
        // Use nutrient tracking value if available, otherwise fallback to profile
        final double fatTargetValue = snapshot.hasData
            ? snapshot.data!
            : (profile?.dailyFatTarget ?? 60.0);
        final int fatTarget = fatTargetValue.toInt();

        final int carbLeft = (((carbTarget) - consumedCarb) * a).toInt();
        final int proteinLeft = (((proteinTarget) - consumedProtein) * a)
            .toInt();
        final int fatLeft = (((fatTarget) - consumedFat) * a).toInt();

        // animation controller value for progress bars (safe fallback)
        final double controllerValue = widget.animationController?.value ?? 1.0;

        return FadeTransition(
          opacity: widget.animation ?? const AlwaysStoppedAnimation(1.0),
          child: Transform(
            transform: Matrix4.translationValues(0.0, 20 * (1.0 - a), 0.0),
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
                      color: FitnessAppTheme.grey.withAlpha(
                        (0.2 * 255).round(),
                      ),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                top: 4,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(
                                        context,
                                      )!;
                                      return _statRow(
                                        l10n.eaten,
                                        'assets/fitness_app/eaten.png',
                                        eatenVal,
                                        a,
                                        total: targetD.toInt(),
                                        consumed: eatenToday,
                                      );
                                    },
                                  ),
                                  // Removed "Đã đốt" (burned) section as per requirement
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.white,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100.0),
                                        ),
                                        border: Border.all(
                                          width: 4,
                                          color: FitnessAppTheme.nearlyDarkBlue
                                              .withAlpha((0.2 * 255).round()),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          // Show "Done" if eaten >= target, otherwise show kcal left
                                          if (eatenToday >= targetD)
                                            Builder(
                                              builder: (context) {
                                                final l10n =
                                                    AppLocalizations.of(
                                                      context,
                                                    )!;
                                                return Text(
                                                  l10n.done,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme
                                                        .fontName,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    letterSpacing: 0.0,
                                                    color: FitnessAppTheme
                                                        .nearlyDarkBlue,
                                                  ),
                                                );
                                              },
                                            )
                                          else
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(
                                                begin: 0.0,
                                                end: leftVal.toDouble().clamp(
                                                  0,
                                                  double.infinity,
                                                ),
                                              ),
                                              duration: const Duration(
                                                milliseconds: 700,
                                              ),
                                              builder: (context, value, child) {
                                                return Text(
                                                  '${value.toInt()}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: FitnessAppTheme
                                                        .fontName,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 24,
                                                    letterSpacing: 0.0,
                                                    color: FitnessAppTheme
                                                        .nearlyDarkBlue,
                                                  ),
                                                );
                                              },
                                            ),
                                          const SizedBox(height: 4),
                                          Builder(
                                            builder: (context) {
                                              final l10n = AppLocalizations.of(
                                                context,
                                              )!;
                                              return Text(
                                                l10n.kcalLeft,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      FitnessAppTheme.fontName,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  letterSpacing: 0.0,
                                                  color: FitnessAppTheme.grey
                                                      .withAlpha(
                                                        (0.5 * 255).round(),
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // show progress arc only when there is eaten progress
                                  if (eatenToday > 0)
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: CustomPaint(
                                        painter: CurvePainter(
                                          colors: [
                                            FitnessAppTheme.nearlyDarkBlue,
                                            HexColor('#8A98E8'),
                                            HexColor('#8A98E8'),
                                          ],
                                          // map eaten fraction to angle sweep
                                          // If >= 100%, show full circle (angle = 140)
                                          // Otherwise map 0..100% -> 360..140
                                          angle: (() {
                                            if (targetD <= 0) return 360.0;
                                            final pct = eatenToday / targetD;
                                            if (pct >= 1.0) {
                                              // Full circle when done or over
                                              return 140.0;
                                            }
                                            // Map 0..1 to 360..140 (decreasing angle as progress increases)
                                            return 140 +
                                                (360 - 140) * (1.0 - pct);
                                          })(),
                                        ),
                                        child: const SizedBox(
                                          width: 108,
                                          height: 108,
                                        ),
                                      ),
                                    ),
                                  // Warning icon when overconsume
                                  if (eatenToday > targetD)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(30),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.warning_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 8,
                        bottom: 8,
                      ),
                      child: SizedBox(
                        height: 2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: FitnessAppTheme.background,
                            borderRadius: BorderRadius.all(
                              Radius.circular(4.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 8,
                        bottom: 16,
                      ),
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Row(
                            children: <Widget>[
                              _macroBlock(
                                l10n.carbs,
                                carbLeft,
                                a,
                                HexColor('#87A0E5'),
                                controllerValue,
                                consumed: consumedCarb,
                                target: carbTarget,
                              ),
                              _macroBlock(
                                l10n.protein,
                                proteinLeft,
                                a,
                                HexColor('#F56E98'),
                                controllerValue,
                                consumed: consumedProtein,
                                target: proteinTarget,
                              ),
                              _macroBlock(
                                l10n.fat,
                                fatLeft,
                                a,
                                HexColor('#F1B440'),
                                controllerValue,
                                consumed: consumedFat,
                                target: fatTarget,
                              ),
                            ],
                          );
                        },
                      ),
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

  Widget _statRow(
    String label,
    String asset,
    int value,
    double a, {
    int? total,
    int? consumed,
  }) {
    return Row(
      children: <Widget>[
        Container(
          height: 48,
          width: 2,
          decoration: BoxDecoration(
            color: HexColor('#87A0E5').withAlpha((0.5 * 255).round()),
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: -0.1,
                      color: FitnessAppTheme.grey.withAlpha(
                        (0.5 * 255).round(),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20, height: 20, child: Image.asset(asset)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: (consumed ?? value)),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, val, child) {
                          final display = (total != null)
                              ? '$val / $total'
                              : '$val';
                          return Text(
                            display,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: FitnessAppTheme.darkerText,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Kcal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        letterSpacing: -0.2,
                        color: FitnessAppTheme.grey.withAlpha(
                          (0.7 * 255).round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _macroBlock(
    String title,
    int grams,
    double a,
    Color color,
    double controllerValue, {
    int? consumed,
    int? target,
  }) {
    final barWidth = 70.0;
    // compute progress based on consumed/target when available; fallback to controllerValue
    final double rawProgress = (target != null)
        ? ((consumed ?? 0) / (target > 0 ? target : 1))
        : (controllerValue * 0.6);
    final double progress = rawProgress.isFinite
        ? rawProgress.clamp(0.0, 1.0)
        : 0.0;
    final bool isOverconsumed =
        (consumed != null && target != null && consumed > target);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: FitnessAppTheme.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // Warning icon when overconsumed
              if (isOverconsumed)
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 14,
                ),
            ],
          ),
          const SizedBox(height: 6),
          const SizedBox(height: 6),
          // animated progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 700),
            builder: (context, t, child) {
              final fillW = (barWidth * t).clamp(0.0, barWidth);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.2 * 255).round()),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: fillW,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withAlpha((0.6 * 255).round()),
                              color,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // animated numeric label
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: (consumed ?? 0)),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, val, child) {
                      if (target != null) {
                        if (val >= target) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            l10n.done,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: FitnessAppTheme.grey.withAlpha(
                                (0.7 * 255).round(),
                              ),
                            ),
                          );
                        }
                        return Text(
                          '$val / $target g',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: FitnessAppTheme.grey.withAlpha(
                              (0.5 * 255).round(),
                            ),
                          ),
                        );
                      }
                      final left = (grams - val).clamp(0, grams);
                      return Text(
                        '$left g left',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: FitnessAppTheme.grey.withAlpha(
                            (0.5 * 255).round(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = colors ?? [Colors.white, Colors.white];

    // Calculate sweep angle: when angle=140 (full), sweep=220°; when angle=360 (empty), sweep=0°
    // Formula: sweepAngle = 360 - angle (inverse relationship)
    final sweepAngle = 360.0 - (angle ?? 140.0);

    final shdowPaint = Paint()
      ..color = Colors.black.withAlpha((0.4 * 255).round())
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
      Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
      _degreeToRadians(278),
      _degreeToRadians(sweepAngle),
      false,
      shdowPaint,
    );

    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = SweepGradient(
      startAngle: _degreeToRadians(268),
      endAngle: _degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      _degreeToRadians(278),
      _degreeToRadians(sweepAngle),
      false,
      paint,
    );

    final gradient1 = SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );
    var cPaint = Paint()
      ..shader = gradient1.createShader(rect)
      ..color = Colors.white
      ..strokeWidth = 14 / 2;

    final centerToCircle = size.width / 2;
    canvas.save();
    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(_degreeToRadians((angle ?? 140.0) + 2));
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(Offset(0, 0), 14 / 5, cPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _degreeToRadians(double degree) {
    return (math.pi / 180) * degree;
  }
}
