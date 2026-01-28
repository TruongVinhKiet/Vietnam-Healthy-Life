import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';

/// Essential amino acids card for home screen — shows top amino acids and a Detail action
class AminoView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const AminoView({super.key, this.animationController, this.animation});

  @override
  State<AminoView> createState() => _AminoViewState();

  // Static method to refresh all instances
  static void refreshAll() {
    _refreshNotifier.value = DateTime.now();
  }

  static final ValueNotifier<DateTime> _refreshNotifier =
      ValueNotifier<DateTime>(DateTime.now());
}

class _AminoViewState extends State<AminoView> {
  Map<String, double> consumptionMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTracking();
    // Listen to refresh notifications
    AminoView._refreshNotifier.addListener(_onRefresh);
  }

  @override
  void dispose() {
    AminoView._refreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }

  void _onRefresh() {
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    try {
      debugPrint('[AminoView] Loading nutrient tracking data...');
      final nutrients = await AuthService.getDailyNutrientTracking();

      debugPrint(
        '[AminoView] Received ${nutrients.length} nutrients from API',
      );

      if (!mounted) return;

      setState(() {
        consumptionMap.clear();

        for (final nutrient in nutrients) {
          if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
              'amino_acid') {
            String? code = nutrient['nutrient_code']?.toString();
            final percentage = nutrient['percentage'];

            if (code != null) {
              code = code.toUpperCase();
              if (code.startsWith('AMINO_')) {
                code = code.substring(6);
              }
            }

            if (code != null && percentage != null) {
              final pct = (percentage is num)
                  ? percentage.toDouble()
                  : double.tryParse(percentage.toString()) ?? 0.0;
              consumptionMap[code] = pct.clamp(0.0, 100.0);
              debugPrint(
                '[AminoView] $code: ${pct.toStringAsFixed(1)}% -> clamped: ${consumptionMap[code]!.toStringAsFixed(1)}%',
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
          '[AminoView] Loaded ${consumptionMap.length} amino acid consumption values',
        );
        loading = false;
      });
    } catch (e) {
      debugPrint('[AminoView] Error loading nutrients: $e');
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // top six to show on home
  static const List<Map<String, String>> topAmino = [
    {'code': 'LEU', 'name': 'Leucine'},
    {'code': 'LYS', 'name': 'Lysine'},
    {'code': 'VAL', 'name': 'Valine'},
    {'code': 'ILE', 'name': 'Isoleucine'},
    {'code': 'MET', 'name': 'Methionine'},
    {'code': 'TRP', 'name': 'Tryptophan'},
  ];

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
                              Text(
                                'Essential amino acids',
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: FitnessAppTheme.darkerText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  for (int i = 0; i < topAmino.length; i += 2)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _aminoPill(
                                              context,
                                              topAmino[i]['code']!,
                                              topAmino[i]['name']!,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: i + 1 < topAmino.length
                                                ? _aminoPill(
                                                    context,
                                                    topAmino[i + 1]['code']!,
                                                    topAmino[i + 1]['name']!,
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
                              l10n.tapDetailsToSeeFullAminoAcidTable,
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

  Widget _aminoPill(BuildContext context, String code, String name) {
    const colorMap = {
      'HIS': 0xFFB58ED9,
      'ILE': 0xFFA8E6A3,
      'LEU': 0xFFE76F51,
      'LYS': 0xFF4CC9F0,
      'MET': 0xFFF6D55C,
      'PHE': 0xFFF4A7B9,
      'THR': 0xFF76D7C4,
      'TRP': 0xFF6A5ACD,
      'VAL': 0xFFFFB570,
    };

    final int hex = colorMap[code] ?? 0xFF8A98E8;
    final color = Color(hex);
    final percentage = consumptionMap[code] ?? 0.0;

    // Horizontal pill capsule like vitamins and minerals
    return SizedBox(
      height: 52,
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
              // Wave animation fills from bottom
              if (!loading)
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
              if (loading)
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

              // Amino acid code and percentage overlay
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left side: Amino acid code
                    Text(
                      code,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: percentage >= 50
                            ? Colors.white
                            : FitnessAppTheme.darkerText,
                      ),
                    ),

                    // Right side: Percentage
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: percentage >= 50 ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
