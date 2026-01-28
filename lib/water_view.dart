import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/fitness_app_theme.dart';
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/services/drink_service.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/config/api_config.dart';
import 'package:my_diary/services/user_drink_recommendation_service.dart';
import 'package:my_diary/services/smart_suggestion_service.dart';
import 'package:my_diary/services/daily_meal_suggestion_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class WaterView extends StatefulWidget {
  const WaterView({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  });

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _WaterViewState createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> with TickerProviderStateMixin {
  bool _openingSheet = false;

  // ignore: unused_element
  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.maybeProfile();

    int consumedMl = 0;
    try {
      final raw = profile?.raw;
      final v = raw == null
          ? null
          : (raw['today_water_ml'] ?? raw['today_water'] ?? raw['total_water']);
      if (v != null) {
        if (v is num) {
          consumedMl = v.toInt();
        } else {
          consumedMl = int.tryParse(v.toString()) ?? 0;
        }
      }
    } catch (_) {}

    int dailyGoalMl = 0;
    try {
      final raw = profile?.raw;
      if (raw != null && raw.containsKey('daily_water_target')) {
        final v = raw['daily_water_target'];
        if (v is num) {
          dailyGoalMl = v.toInt();
        } else {
          dailyGoalMl = int.tryParse(v.toString()) ?? 0;
        }
      }
    } catch (_) {}

    if (dailyGoalMl <= 0) {
      final double tdee = profile?.tdee ?? 2000.0;
      final double weight = profile?.weightKg ?? 70.0;
      final afRaw = profile?.raw != null
          ? profile!.raw!['activity_factor']
          : null;
      double af = 1.2;
      if (afRaw is num) {
        af = afRaw.toDouble();
      } else if (afRaw != null) {
        af = double.tryParse(afRaw.toString()) ?? af;
      }
      double dailyGoal = (tdee * 1.0) + (weight * 5.0 * (af - 1.2));
      if (!dailyGoal.isFinite || dailyGoal <= 0) {
        dailyGoal = 2000.0;
      }
      dailyGoalMl = dailyGoal.round();
    }

    final percent = dailyGoalMl > 0
        ? (consumedMl / dailyGoalMl * 100.0).clamp(0.0, 100.0)
        : 0.0;

    final String goalLiters = (dailyGoalMl / 1000.0).toStringAsFixed(1);

    return AnimatedBuilder(
      animation:
          widget.mainScreenAnimationController ??
          AnimationController(vsync: this, duration: Duration.zero),
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation ?? AlwaysStoppedAnimation(1.0),
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - (widget.mainScreenAnimation?.value ?? 1.0)),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 18,
              ),
              child: Stack(
                children: [
                  // Use the same framed container style as Mediterranean/BodyMeasurement for consistency
                  Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Left: consumed
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$consumedMl',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context)!;
                                    return Text(
                                      l10n.ofDailyGoal('$goalLiters L'),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Right: pill + controls (styling adjusted to match screenshots)
                          SizedBox(
                            width: 110,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Pill with wave and centered percentage overlay
                                // Match the circular size used in Mediterranean/Body measurement (100x100)
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: FitnessAppTheme.white,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: const Color(0xFFE6F0FF),
                                        width: 4,
                                      ), // distinct pill border color
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(
                                            (0.04 * 255).round(),
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // the animated wave view (keeps original animation)
                                          Positioned.fill(
                                            child: WaveView(
                                              percentageValue: percent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Floating plus button positioned top-right over the card
                  Positioned(
                    right: 18,
                    top: 12,
                    child: GestureDetector(
                      onTap: _openingSheet
                          ? null
                          : () async {
                              setState(() => _openingSheet = true);
                              final result = await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) =>
                                    WaterQuickAddSheet(profile: profile),
                              );
                              if (result == true && profile != null) {
                                try {
                                  await profile.loadProfile();
                                } catch (_) {}
                              }
                              if (mounted) {
                                setState(() => _openingSheet = false);
                              }
                            },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E8BFF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.16 * 255).round(),
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _openingSheet
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WaterQuickAddSheet extends StatefulWidget {
  final ProfileNotifier? profile;
  const WaterQuickAddSheet({super.key, this.profile});

  @override
  State<WaterQuickAddSheet> createState() => _WaterQuickAddSheetState();
}

class _WaterQuickAddSheetState extends State<WaterQuickAddSheet> {
  final _drinkRecommendationService = UserDrinkRecommendationService();
  Set<int> _restrictedDrinkIds = {};
  Set<int> _recommendedDrinkIds = {};
  Set<int> _pinnedDrinkIds = {}; // NEW: Pinned drink IDs
  Set<int> _acceptedDailyMealDrinkIds =
      {}; // Accepted drink suggestions for today
  // ignore: unused_field
  bool _loadingRecommendations = true;

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  double _hydrationForDrink(Map<String, dynamic> drink) {
    final ratio = _toDouble(drink['hydration_ratio']);
    if (ratio <= 0 || !ratio.isFinite) return 1.0;
    return ratio.clamp(0.0, 1.2);
  }

  late Future<List<Map<String, dynamic>>> _catalogFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _catalogFuture = DrinkService.fetchCatalog();
    _loadRecommendations();
    _loadPinnedDrinks();
    _loadAcceptedDailyMealDrinks();

    _searchController.addListener(() {
      final value = _searchController.text;
      if (value == _searchQuery) return;
      setState(() {
        _searchQuery = value;
      });
    });
  }

  Future<void> _loadRecommendations() async {
    try {
      debugPrint('🔍 WaterQuickAddSheet: Loading drink recommendations...');
      await _drinkRecommendationService.loadUserDrinkRecommendations();
      if (mounted) {
        setState(() {
          _restrictedDrinkIds = _drinkRecommendationService.drinksToAvoid;
          _recommendedDrinkIds = _drinkRecommendationService.drinksToRecommend;
          _loadingRecommendations = false;
        });
        debugPrint('✅ WaterQuickAddSheet: Loaded recommendations');
        debugPrint('   Restricted drinks: $_restrictedDrinkIds');
        debugPrint('   Recommended drinks: $_recommendedDrinkIds');
      }
    } catch (e) {
      // Silently fail - recommendations are optional
      debugPrint('❌ WaterQuickAddSheet: Error loading recommendations: $e');
      if (mounted) {
        setState(() => _loadingRecommendations = false);
      }
    }
  }

  Future<void> _loadPinnedDrinks() async {
    try {
      debugPrint('📌 WaterQuickAddSheet: Loading pinned drinks...');
      final result = await SmartSuggestionService.getPinnedSuggestions();

      if (result['error'] != null) {
        debugPrint('⚠️ Error loading pinned drinks: ${result['error']}');
        return;
      }

      final pins = List<Map<String, dynamic>>.from(result['pins'] ?? []);
      final Set<int> pinnedDrinks = {};

      for (var pin in pins) {
        final itemType = pin['item_type'] as String?;
        final itemId = pin['item_id'] as int?;

        if (itemType == 'drink' && itemId != null) {
          pinnedDrinks.add(itemId);
        }
      }

      if (mounted) {
        setState(() {
          _pinnedDrinkIds = pinnedDrinks;
        });
        debugPrint(
          '✅ Loaded ${_pinnedDrinkIds.length} pinned drinks: $_pinnedDrinkIds',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading pinned drinks: $e');
    }
  }

  Future<void> _loadAcceptedDailyMealDrinks() async {
    try {
      debugPrint(
        '🍹 WaterQuickAddSheet: Loading accepted daily meal drinks...',
      );
      final result = await DailyMealSuggestionService.getSuggestions(
        date: DateTime.now(),
      );

      if (result['error'] != null) {
        debugPrint('⚠️ Error loading daily meal drinks: ${result['error']}');
        return;
      }

      if (result['suggestions'] == null) return;

      final suggestions = result['suggestions'];
      final Set<int> acceptedDrinks = {};

      // Get all accepted drink suggestions for all meals today
      final allSuggestions = [
        ...(suggestions.breakfast ?? []),
        ...(suggestions.lunch ?? []),
        ...(suggestions.dinner ?? []),
        ...(suggestions.snack ?? []),
      ];

      for (var suggestion in allSuggestions) {
        if (suggestion.isAccepted == true && suggestion.drinkId != null) {
          acceptedDrinks.add(suggestion.drinkId!);
        }
      }

      if (mounted) {
        setState(() {
          _acceptedDailyMealDrinkIds = acceptedDrinks;
        });
        debugPrint(
          '✅ Loaded ${acceptedDrinks.length} accepted daily meal drinks: $acceptedDrinks',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading accepted daily meal drinks: $e');
    }
  }

  Future<bool> _showRestrictionWarning(Map<String, dynamic> drink) async {
    final drinkName =
        drink['vietnamese_name'] ?? drink['name'] ?? 'Đồ uống này';

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(child: Text('Cảnh báo sức khỏe')),
              ],
            ),
            content: Text(
              'Đồ uống "$drinkName" không được khuyến khích dựa trên tình trạng sức khỏe của bạn.\n\n'
              'Bạn có chắc chắn muốn tiếp tục?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Tiếp tục'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _defaultVolumeForDrink(Map<String, dynamic> drink) {
    final v = _toDouble(drink['default_volume_ml']);
    return v > 0 ? v : 250.0;
  }

  double? _hydrationRatioFromWaterNutrient(Map<String, dynamic> drink) {
    final nutrients = (drink['nutrients'] as Map?) ?? {};
    final possibleKeys = <String>[
      'WATER',
      'water',
      'H2O',
      'WATER_G',
      'WATER_ML',
    ];
    double waterAmount = 0.0;

    for (final k in possibleKeys) {
      if (nutrients.containsKey(k)) {
        waterAmount = _toDouble(nutrients[k]);
        break;
      }
    }

    if (waterAmount > 0) {
      final defaultVol = _defaultVolumeForDrink(drink);
      double waterPer100ml = waterAmount;
      if (waterPer100ml > 150 && defaultVol > 0) {
        waterPer100ml = (waterAmount * 100.0) / defaultVol;
      }
      final ratio = (waterPer100ml / 100.0);
      if (ratio.isFinite && ratio > 0) {
        return ratio.clamp(0.0, 1.2);
      }
    }

    return null;
  }

  Future<double> _resolveHydrationRatio(Map<String, dynamic> drink) async {
    final direct = _hydrationRatioFromWaterNutrient(drink);
    if (direct != null) return direct;

    final drinkId = drink['drink_id'] as int?;
    if (drinkId != null) {
      try {
        final detail = await DrinkService.fetchDetail(drinkId);
        final rawDrink =
            (detail?['drink'] as Map<String, dynamic>?) ??
            (detail?['data'] as Map<String, dynamic>?) ??
            (detail?['drink_detail'] as Map<String, dynamic>?) ??
            <String, dynamic>{};

        final nutrientDetails = rawDrink['nutrient_details'] as List?;
        if (nutrientDetails != null) {
          for (final row in nutrientDetails) {
            if (row is! Map) continue;
            final code = (row['nutrient_code'] ?? '').toString().toUpperCase();
            final name = (row['name'] ?? '').toString().toLowerCase();
            final nutrientId = row['nutrient_id'];

            final isWater =
                code == 'WATER' ||
                code == 'H2O' ||
                name.contains('water') ||
                nutrientId == 75;
            if (!isWater) continue;

            final waterPer100ml = _toDouble(row['amount_per_100ml']);
            if (waterPer100ml <= 0) continue;
            final ratio = (waterPer100ml / 100.0);
            if (ratio.isFinite && ratio > 0) {
              return ratio.clamp(0.0, 1.2);
            }
          }
        }
      } catch (_) {
        // ignore
      }
    }

    return _hydrationForDrink(drink);
  }

  Future<void> _logWater({
    required double amount,
    int? drinkId,
    double? hydrationRatio,
    String? drinkName,
  }) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final result = await AuthService.logWater(
      amountMl: amount,
      drinkId: drinkId,
      hydrationRatio: hydrationRatio,
      drinkName: drinkName,
    );
    setState(() => _submitting = false);
    if (result == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.cannotConnectToServer);
            },
          ),
        ),
      );
      return;
    }
    if (result.containsKey('error')) {
      messenger.showSnackBar(
        SnackBar(content: Text(result['error'].toString())),
      );
      return;
    }

    // Unpin from smart suggestions if this drink was pinned
    if (drinkId != null) {
      await SmartSuggestionService.unpinOnAdd(
        itemType: 'drink',
        itemId: drinkId,
      );
    }

    if (drinkId != null && _acceptedDailyMealDrinkIds.contains(drinkId)) {
      await DailyMealSuggestionService.consumeSuggestion(
        date: DateTime.now(),
        drinkId: drinkId,
      );
    }

    final today = result['today'] as Map<String, dynamic>?;
    if (today != null) {
      widget.profile?.applyTodayTotals(today);
      if (today['last_drink_at'] != null) {
        widget.profile?.setTodayLastDrink(today['last_drink_at'].toString());
      }

      // Check if water goal is completed
      final consumedMl = (today['total_water'] as num?)?.toDouble() ?? 0.0;
      final targetMl = (today['daily_water_target'] as num?)?.toDouble() ?? 0.0;
      if (targetMl > 0) {
        await LocalNotificationService().checkAndNotifyProgressCompletion(
          type: 'water',
          name: AppLocalizations.of(context)!.water,
          consumed: consumedMl,
          target: targetMl,
        );
      }
    }

    // Show local notification
    await LocalNotificationService().notifyWaterAdded(amount, drinkName);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                      l10n.recordWaterIntake,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildSearchField(),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _catalogFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.errorLoadingList(
                                  snapshot.error.toString(),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      final drinks = snapshot.data ?? [];
                      final query = _searchQuery.trim().toLowerCase();
                      final filteredDrinks = query.isEmpty
                          ? drinks
                          : drinks.where((drink) {
                              final name =
                                  (drink['vietnamese_name'] ??
                                          drink['name'] ??
                                          '')
                                      .toString()
                                      .toLowerCase();
                              final category = (drink['category'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              return name.contains(query) ||
                                  category.contains(query);
                            }).toList();

                      if (filteredDrinks.isEmpty) {
                        return Center(
                          child: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(l10n.noDrinkRecipesYet);
                            },
                          ),
                        );
                      }
                      return ListView(
                        controller: scrollController,
                        children: [
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
                                l10n.selectDrinkToRecord,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                          ...filteredDrinks.map((drink) {
                            final id = drink['drink_id'] as int;
                            final hydration = (_hydrationForDrink(drink) * 100)
                                .toStringAsFixed(0);

                            // Check if drink is restricted, recommended, or pinned
                            final isRestricted = _restrictedDrinkIds.contains(
                              id,
                            );
                            final isRecommended = _recommendedDrinkIds.contains(
                              id,
                            );
                            final isPinned = _pinnedDrinkIds.contains(id);
                            final isAcceptedSuggestion =
                                _acceptedDailyMealDrinkIds.contains(id);

                            return Container(
                              decoration: isPinned
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: Colors.amber,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                  : isAcceptedSuggestion
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: Colors.yellow.shade700,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    )
                                  : null,
                              child: Opacity(
                                opacity: isRestricted ? 0.4 : 1.0,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: _submitting
                                      ? null
                                      : () async {
                                          if (isRestricted) {
                                            final proceed =
                                                await _showRestrictionWarning(
                                                  drink,
                                                );
                                            if (!proceed) return;
                                          }

                                          final amountMl =
                                              _defaultVolumeForDrink(drink);
                                          final hydrationRatio =
                                              await _resolveHydrationRatio(
                                                drink,
                                              );

                                          await _logWater(
                                            amount: amountMl,
                                            drinkId: id,
                                            hydrationRatio: hydrationRatio,
                                            drinkName:
                                                drink['vietnamese_name'] ??
                                                drink['name'],
                                          );
                                        },
                                  child: ListTile(
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: FitnessAppTheme.nearlyBlue
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: FitnessAppTheme.nearlyBlue
                                              .withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child:
                                            (drink['image_url'] != null &&
                                                drink['image_url']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? Image.network(
                                                drink['image_url']
                                                        .toString()
                                                        .startsWith('http')
                                                    ? drink['image_url']
                                                    : '${ApiConfig.baseUrl}${drink['image_url']}',
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Icon(
                                                      Icons.local_drink,
                                                      size: 22,
                                                      color:
                                                          FitnessAppTheme.grey,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.local_drink,
                                                size: 22,
                                                color: FitnessAppTheme.grey,
                                              ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            drink['vietnamese_name'] ??
                                                drink['name'] ??
                                                '',
                                            style: TextStyle(
                                              color: isRestricted
                                                  ? Colors.red.shade700
                                                  : null,
                                              fontWeight: isRecommended
                                                  ? FontWeight.bold
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        if (isRestricted)
                                          Icon(
                                            Icons.warning,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          )
                                        else if (isRecommended)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green.shade700,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    subtitle: Builder(
                                      builder: (context) {
                                        final l10n = AppLocalizations.of(
                                          context,
                                        )!;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.hydrationPercent(
                                                hydration.toString(),
                                              ),
                                            ),
                                            if (isAcceptedSuggestion)
                                              Text(
                                                l10n.acceptedNote,
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            if (isRestricted)
                                              Text(
                                                'Không khuyến khích - Có thể ảnh hưởng tình trạng sức khỏe',
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              )
                                            else if (isRecommended)
                                              Text(
                                                'Khuyến khích - Tốt cho sức khỏe',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    tileColor: isRecommended
                                        ? Colors.green.shade50
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm đồ uống',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}
