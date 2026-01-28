import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';

/// Vitamins card for home screen — shows top vitamins with consumption % from API
class VitaminView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const VitaminView({super.key, this.animationController, this.animation});

  @override
  State<VitaminView> createState() => _VitaminViewState();

  // Static method to refresh all instances
  static void refreshAll() {
    _refreshNotifier.value = DateTime.now();
  }

  static final ValueNotifier<DateTime> _refreshNotifier =
      ValueNotifier<DateTime>(DateTime.now());
}

class _VitaminViewState extends State<VitaminView> {
  static const List<Map<String, String>> topVitamins = [
    {'code': 'VITD', 'name': 'Vitamin D'},
    {'code': 'VITC', 'name': 'Vitamin C'},
    {'code': 'VITB12', 'name': 'Vitamin B12'},
    {'code': 'VITA', 'name': 'Vitamin A'},
    {'code': 'VITE', 'name': 'Vitamin E'},
    {'code': 'VITB6', 'name': 'Vitamin B6'},
    {'code': 'VITK', 'name': 'Vitamin K'},
    {'code': 'VITB1', 'name': 'Vitamin B1'},
    {'code': 'VITB2', 'name': 'Vitamin B2'},
    {'code': 'VITB9', 'name': 'Vitamin B9'},
  ];

  // Map to store consumption percentages: code -> percentage
  final Map<String, double> _consumptionMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNutrientTracking();
    // Listen to refresh notifications
    VitaminView._refreshNotifier.addListener(_onRefresh);
  }

  @override
  void dispose() {
    VitaminView._refreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _loadNutrientTracking();
  }

  Future<void> _loadNutrientTracking() async {
    try {
      debugPrint('[VitaminView] Loading nutrient tracking data...');
      final nutrients = await AuthService.getDailyNutrientTracking();

      debugPrint(
        '[VitaminView] Received ${nutrients.length} nutrients from API',
      );

      if (!mounted) return;

      setState(() {
        _consumptionMap.clear();

        for (final nutrient in nutrients) {
          if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
              'vitamin') {
            final code = nutrient['nutrient_code'] as String?;
            final percentage = nutrient['percentage'];

            if (code != null && percentage != null) {
              // Convert percentage and clamp at 100%
              final pct = (percentage is num)
                  ? percentage.toDouble()
                  : double.tryParse(percentage.toString()) ?? 0.0;
              _consumptionMap[code] = pct.clamp(0.0, 100.0);
              debugPrint(
                '[VitaminView] $code: ${pct.toStringAsFixed(1)}% -> clamped: ${_consumptionMap[code]!.toStringAsFixed(1)}%',
              );
              
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
          '[VitaminView] Loaded ${_consumptionMap.length} vitamin consumption values',
        );
        _loading = false;
      });
    } catch (e) {
      debugPrint('[VitaminView] Error loading nutrients: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Details navigation is provided by the TitleView external link. No internal Details button here.

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
            top: 8,
            bottom: 8,
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Text(
                                    l10n.topVitamins,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (
                                    int i = 0;
                                    i < topVitamins.length;
                                    i += 2
                                  )
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _vitaminPill(
                                              context,
                                              topVitamins[i]['code']!,
                                              topVitamins[i]['name']!,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: i + 1 < topVitamins.length
                                                ? _vitaminPill(
                                                    context,
                                                    topVitamins[i + 1]['code']!,
                                                    topVitamins[i + 1]['name']!,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 2,
                    bottom: 10,
                  ),
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Text(
                        l10n.tapDetailsToSeeFullVitaminTable,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 10,
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
        ),
      ),
    );
  }

  Widget _vitaminPill(BuildContext context, String code, String name) {
    // color mapping by vitamin code (hex values provided by user)
    const colorMap = {
      'VITA': 0xFFFFA500, // Vitamin A - Orange
      'VITD': 0xFFFFD700, // Vitamin D - Gold
      'VITE': 0xFF32CD32, // Vitamin E - Lime Green
      'VITK': 0xFF006400, // Vitamin K - Dark Green
      'VITC': 0xFFFFA07A, // Vitamin C - Light Salmon
      'VITB1': 0xFF1E90FF, // B1 - Dodger Blue
      'VITB2': 0xFF9370DB, // B2 - Medium Purple
      'VITB3': 0xFFFFD966, // B3 - Light Yellow
      'VITB5': 0xFFC0C0C0, // B5 - Silver
      'VITB6': 0xFF9ACD32, // B6 - Yellow Green
      'VITB7': 0xFFFF69B4, // B7 - Hot Pink
      'VITB9': 0xFF00FA9A, // B9 - Medium Spring Green
      'VITB12': 0xFFDC143C, // B12 - Crimson
    };

    final int hex = colorMap[code] ?? 0xFF8A98E8;
    final color = Color(hex);
    final percentage = _consumptionMap[code] ?? 0.0;

    // Horizontal pill capsule like water bottle lying down
    return SizedBox(
      height: 46,
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(26), // fully rounded ends
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
              // Wave animation fills from bottom (rotated for horizontal pill)
              if (!_loading)
                Positioned.fill(
                  child: WaveView(
                    percentageValue: percentage,
                    primaryColor: color,
                    secondaryColor: color.withAlpha((0.6 * 255).round()),
                    compact: false,
                    showText: false, // Hide percentage text in wave
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

              // Percentage and name label overlay
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Vitamin name on LEFT
                      Flexible(
                        child: Text(
                          name,
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
