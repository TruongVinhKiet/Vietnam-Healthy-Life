import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';

/// Minerals card for home screen — shows top minerals with consumption % from API
class MineralView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const MineralView({super.key, this.animationController, this.animation});

  @override
  State<MineralView> createState() => _MineralViewState();

  // Static method to refresh all instances
  static void refreshAll() {
    _refreshNotifier.value = DateTime.now();
  }

  static final ValueNotifier<DateTime> _refreshNotifier =
      ValueNotifier<DateTime>(DateTime.now());
}

class _MineralViewState extends State<MineralView> {
  static const List<Map<String, String>> topMinerals = [
    {'code': 'MIN_CA', 'name': 'Calcium (Ca)'},
    {'code': 'MIN_P', 'name': 'Phosphorus (P)'},
    {'code': 'MIN_MG', 'name': 'Magnesium (Mg)'},
    {'code': 'MIN_K', 'name': 'Potassium (K)'},
    {'code': 'MIN_NA', 'name': 'Sodium (Na)'},
    {'code': 'MIN_FE', 'name': 'Iron (Fe)'},
  ];

  final Map<String, double> _consumptionMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNutrientTracking();
    // Listen to refresh notifications
    MineralView._refreshNotifier.addListener(_onRefresh);
  }

  @override
  void dispose() {
    MineralView._refreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _loadNutrientTracking();
  }

  Future<void> _loadNutrientTracking() async {
    try {
      debugPrint('[MineralView] Loading nutrient tracking data...');
      final nutrients = await AuthService.getDailyNutrientTracking();

      debugPrint(
        '[MineralView] Received ${nutrients.length} nutrients from API',
      );

      if (!mounted) return;

      setState(() {
        _consumptionMap.clear();

        for (final nutrient in nutrients) {
          if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
              'mineral') {
            final code = nutrient['nutrient_code'] as String?;
            final percentage = nutrient['percentage'];

            if (code != null && percentage != null) {
              final pct = (percentage is num)
                  ? percentage.toDouble()
                  : double.tryParse(percentage.toString()) ?? 0.0;
              _consumptionMap[code] = pct.clamp(0.0, 100.0);
              debugPrint('[MineralView] $code: ${pct.toStringAsFixed(1)}%');
              
              // Check if goal is completed (>= 100%)
              if (pct >= 100.0) {
                final nutrientName = nutrient['nutrient_name']?.toString() ?? code;
                final currentAmount = nutrient['current_amount'] as num?;
                final targetAmount = nutrient['target_amount'] as num?;
                
                if (currentAmount != null && targetAmount != null) {
                  LocalNotificationService().checkAndNotifyProgressCompletion(
                    type: 'nutrient',
                    name: nutrientName,
                    consumed: currentAmount.toDouble(),
                    target: targetAmount.toDouble(),
                  );
                }
              }
            }
          }
        }

        debugPrint(
          '[MineralView] Loaded ${_consumptionMap.length} mineral consumption values',
        );
        _loading = false;
      });
    } catch (e) {
      debugPrint('[MineralView] Error loading nutrients: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final anim = widget.animation ?? const AlwaysStoppedAnimation(1.0);
    final a = anim.value;

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
                  color: FitnessAppTheme.grey.withAlpha((0.2 * 255).round()),
                  offset: const Offset(1.1, 1.1),
                  blurRadius: 10.0,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Text(
                                    l10n.topMinerals,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  for (
                                    int i = 0;
                                    i < topMinerals.length;
                                    i += 2
                                  )
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _mineralPill(
                                              context,
                                              topMinerals[i]['code']!,
                                              topMinerals[i]['name']!,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: i + 1 < topMinerals.length
                                                ? _mineralPill(
                                                    context,
                                                    topMinerals[i + 1]['code']!,
                                                    topMinerals[i + 1]['name']!,
                                                  )
                                                : const SizedBox(),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // right area intentionally left empty to match other cards' balance
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
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
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
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              l10n.tapDetailsToSeeFullMineralsTable,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontSize: 12,
                                color: FitnessAppTheme.grey.withAlpha(
                                  (0.8 * 255).round(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mineralPill(BuildContext context, String code, String name) {
    // color mapping by mineral code
    const colorMap = {
      'MIN_CA': 0xFF1E90FF, // Calcium - DodgerBlue
      'MIN_P': 0xFF9370DB, // Phosphorus - MediumPurple
      'MIN_MG': 0xFF00CED1, // Magnesium - DarkTurquoise
      'MIN_K': 0xFFFF8C00, // Potassium - DarkOrange
      'MIN_NA': 0xFFB22222, // Sodium - FireBrick
      'MIN_FE': 0xFF8B4513, // Iron - SaddleBrown
      'MIN_ZN': 0xFFDAA520,
      'MIN_CU': 0xFFCD5C5C,
      'MIN_MN': 0xFF6A5ACD,
      'MIN_I': 0xFF20B2AA,
      'MIN_SE': 0xFF708090,
      'MIN_CR': 0xFFB0C4DE,
      'MIN_MO': 0xFF2E8B57,
      'MIN_F': 0xFF4682B4,
    };

    final int hex = colorMap[code] ?? 0xFF8A98E8;
    final color = Color(hex);
    final percentage = _consumptionMap[code] ?? 0.0;

    // Horizontal pill capsule like vitamins
    return SizedBox(
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: color.withAlpha((0.3 * 255).round()),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.08 * 255).round()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Wave animation
              if (!_loading)
                Positioned.fill(
                  child: WaveView(
                    percentageValue: percentage,
                    primaryColor: color,
                    secondaryColor: color.withAlpha((0.6 * 255).round()),
                    compact: false,
                    showText: false,
                  ),
                ),

              // Loading indicator
              if (_loading)
                Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),

              // Mineral symbol and percentage overlay
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mineral symbol on LEFT (without MIN_ prefix)
                      Flexible(
                        child: Text(
                          code.replaceAll('MIN_', ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: percentage > 50
                                ? FitnessAppTheme.white
                                : FitnessAppTheme.darkerText,
                            shadows: percentage > 50
                                ? [
                                    Shadow(
                                      offset: const Offset(0.5, 0.5),
                                      blurRadius: 1.5,
                                      color: Colors.black.withAlpha(
                                        (0.3 * 255).round(),
                                      ),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Percentage on RIGHT
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: percentage > 50
                              ? FitnessAppTheme.white
                              : color,
                          shadows: percentage > 50
                              ? [
                                  Shadow(
                                    offset: const Offset(0.5, 0.5),
                                    blurRadius: 2.0,
                                    color: Colors.black.withAlpha(
                                      (0.4 * 255).round(),
                                    ),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
