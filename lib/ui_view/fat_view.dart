// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class FatView extends StatefulWidget {
  const FatView({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  });
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  @override
  _FatViewState createState() => _FatViewState();
  
  // Static method to refresh all instances
  static void refreshAll() {
    _refreshNotifier.value = DateTime.now();
  }
  
  static final ValueNotifier<DateTime> _refreshNotifier = ValueNotifier<DateTime>(DateTime.now());
}

class _FatViewState extends State<FatView> with TickerProviderStateMixin {
  double percent = 0.0;
  double recommended = 70.0; // default placeholder (g)
  double consumed = 0.0;
  bool _appliedProfileSnapshot = false;

  @override
  void initState() {
    super.initState();
    _loadRecommended();
    // Listen to refresh notifications
    FatView._refreshNotifier.addListener(_onRefresh);
  }
  
  @override
  void dispose() {
    FatView._refreshNotifier.removeListener(_onRefresh);
    super.dispose();
  }
  
  void _onRefresh() {
    _loadRecommended();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_appliedProfileSnapshot) {
      _appliedProfileSnapshot = true;
      _applyProfileSnapshot();
    }
  }

  Future<void> _loadRecommended() async {
    // Load nutrient tracking to get TOTAL_FAT consumption
    final nutrients = await AuthService.getDailyNutrientTracking();

    double fatConsumed = 0.0;
    double fatTarget = 70.0;

    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
              'fatty_acid' &&
          nutrient['nutrient_code'] == 'TOTAL_FAT') {
        final current = nutrient['current_amount'];
        final target = nutrient['target_amount'];

        if (current != null) {
          fatConsumed = (current is num)
              ? current.toDouble()
              : double.tryParse(current.toString()) ?? 0.0;
        }

        if (target != null) {
          fatTarget = (target is num)
              ? target.toDouble()
              : double.tryParse(target.toString()) ?? 70.0;
        }
        break;
      }
    }

    if (!mounted) return;

    setState(() {
      consumed = fatConsumed;
      recommended = fatTarget;
      percent = recommended > 0
          ? (consumed / recommended * 100.0).clamp(0.0, 100.0)
          : 0.0;
    });
    
    // Check if goal is completed (>= 100%)
    if (recommended > 0 && consumed >= recommended) {
      LocalNotificationService().checkAndNotifyProgressCompletion(
        type: 'nutrient',
        name: 'Fat',
        consumed: consumed,
        target: recommended,
      );
    }

    // Ensure UI reflects freshest profile totals (e.g., after adding meal)
    _applyProfileSnapshot();
  }

  void _applyProfileSnapshot() {
    final profile = context.maybeProfile();
    if (profile == null) return;

    double? todayFat;
    final raw = profile.raw;
    if (raw != null && raw.containsKey('today_fat')) {
      todayFat = _parseDouble(raw['today_fat']);
    }
    
    // Priority: Use recommended from nutrient tracking (UserFattyAcidRequirement)
    // This ensures consistency with Mediterranean diet which also uses the same source
    // Only fallback to profile.dailyFatTarget if nutrient tracking doesn't have a value
    // Note: recommended is already set from _loadRecommended() which gets it from nutrient tracking

    if (todayFat == null && recommended <= 0) return;

    setState(() {
      if (todayFat != null) consumed = todayFat;
      // Keep recommended from nutrient tracking (already set in _loadRecommended)
      // Only update if we don't have a value from nutrient tracking
      if (recommended <= 0) {
        recommended = profile.dailyFatTarget ??
            _parseDouble(raw?['daily_fat_target']) ??
            70.0;
      }
      percent = recommended > 0
          ? (consumed / recommended * 100.0).clamp(0.0, 100.0)
          : 0.0;
    });
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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
                          Icons.oil_barrel,
                          color: Colors.orange.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        Icon(
                          Icons.restaurant_menu,
                          color: Colors.orange.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        Icon(
                          Icons.set_meal,
                          color: Colors.orange.withValues(alpha: 0.3),
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
                                        primaryColor: const Color(0xFFF5B041),
                                        secondaryColor: const Color(0xFFF39C12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avocado icon outside circle (top)
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
                                child: const Text(
                                  '🥑',
                                  style: TextStyle(fontSize: 32),
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
                          '${consumed.toStringAsFixed(1)} / ${recommended.toStringAsFixed(0)} ${l10n.g}',
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
                          Icons.local_dining,
                          color: Colors.orange.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Column(
                              children: [
                                Text(
                                  l10n.fat,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: FitnessAppTheme.darkerText,
                                  ),
                                ),
                                if (consumed > recommended)
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
                          Icons.fastfood,
                          color: Colors.orange.withValues(alpha: 0.3),
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
