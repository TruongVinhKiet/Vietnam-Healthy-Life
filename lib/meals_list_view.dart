// ignore_for_file: library_private_types_in_public_api

import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/models/meals_list_data.dart';
import 'package:my_diary/hex_color.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/widgets/add_meal_dialog.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:my_diary/ui_view/vitamin_view.dart';
import 'package:my_diary/ui_view/mineral_view.dart';
import 'package:my_diary/ui_view/amino_view.dart';
import 'package:my_diary/ui_view/fat_view.dart';
import 'package:flutter/material.dart';

class MealsListView extends StatefulWidget {
  const MealsListView({
    super.key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  });

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<MealsListData> mealsListData = MealsListData.tabIconsList;
  ProfileNotifier? _profileNotifier;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    // defer loading settings/profile until after first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettingsAndCompute();
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = context.maybeProfile();
    if (_profileNotifier != prov) {
      // remove from old
      _profileNotifier?.removeListener(_onProfileChanged);
      _profileNotifier = prov;
      _profileNotifier?.addListener(_onProfileChanged);
    }
  }

  void _onProfileChanged() {
    // recompute per-meal numbers when profile updates
    _loadSettingsAndCompute();
  }

  Future<void> _loadSettingsAndCompute() async {
    try {
      final settings = await AuthService.getSettings();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final mealTargetsResp = await AuthService.getMealTargets(date: today);
      List<dynamic>? targetsFromApi;
      if (mealTargetsResp != null && mealTargetsResp['targets'] != null) {
        targetsFromApi = List<dynamic>.from(mealTargetsResp['targets']);
      }
      if (!mounted) return;
      final prov = context.maybeProfile();

      final dailyCalories = prov?.dailyCalorieTarget ?? 0.0;
      final dailyCarbs = prov?.dailyCarbTarget ?? 0.0;
      final dailyProtein = prov?.dailyProteinTarget ?? 0.0;
      final dailyFat = prov?.dailyFatTarget ?? 0.0;

      // If the API returned explicit per-meal targets for today, prefer those values. Otherwise fall back to percentage-based settings.
      // mealTargetsMap may contain either a full target object (map with target_kcal/carbs/protein/fat)
      // returned by the API, or numeric percentage values read from settings (25.0 etc.).
      final mealTargetsMap = <String, dynamic>{};
      if (targetsFromApi != null) {
        for (final t in targetsFromApi) {
          try {
            final mt = (t['meal_type'] as String).toLowerCase();
            final obj = <String, double>{
              'target_kcal': ((t['target_kcal'] ?? 0) as num).toDouble(),
              'target_carbs': ((t['target_carbs'] ?? 0) as num).toDouble(),
              'target_protein': ((t['target_protein'] ?? 0) as num).toDouble(),
              'target_fat': ((t['target_fat'] ?? 0) as num).toDouble(),
            };
            // Use localized meal names
            if (mt == 'breakfast') {
              mealTargetsMap[AppLocalizations.of(context)!.breakfast] = obj;
            }
            if (mt == 'lunch') {
              mealTargetsMap[AppLocalizations.of(context)!.lunch] = obj;
            }
            if (mt == 'snack') {
              mealTargetsMap[AppLocalizations.of(context)!.snack] = obj;
            }
            if (mt == 'dinner') {
              mealTargetsMap[AppLocalizations.of(context)!.dinner] = obj;
            }
          } catch (e) {
            // ignore parse errors
          }
        }
      }
      // if no per-day targets returned, fall back to percentage-based settings
      if (mealTargetsMap.isEmpty) {
        final bPct = settings != null && settings['meal_pct_breakfast'] != null
            ? (settings['meal_pct_breakfast'] as num).toDouble()
            : 25.0;
        final lPct = settings != null && settings['meal_pct_lunch'] != null
            ? (settings['meal_pct_lunch'] as num).toDouble()
            : 35.0;
        final sPct = settings != null && settings['meal_pct_snack'] != null
            ? (settings['meal_pct_snack'] as num).toDouble()
            : 10.0;
        final dPct = settings != null && settings['meal_pct_dinner'] != null
            ? (settings['meal_pct_dinner'] as num).toDouble()
            : 30.0;
        // Use localized strings as keys
        final l10n = AppLocalizations.of(context)!;
        mealTargetsMap.addAll({
          l10n.breakfast: bPct,
          l10n.lunch: lPct,
          l10n.snack: sPct,
          l10n.dinner: dPct,
        });
      }

      // update mealsListData with computed recommendations when kacl==0 or contains 'Recommend'
      // Map meal titles to localized strings for lookup
      final l10n = AppLocalizations.of(context)!;
      final mealTitleMap = {
        'Breakfast': l10n.breakfast,
        'Lunch': l10n.lunch,
        'Snack': l10n.snack,
        'Dinner': l10n.dinner,
      };

      for (var item in mealsListData) {
        // Get localized title for lookup
        final localizedTitle = mealTitleMap[item.titleTxt] ?? item.titleTxt;
        // pctMap may either contain percentages (e.g., 25.0) or precomputed kcal values when returned by API.
        final raw = mealTargetsMap[localizedTitle];
        double kcal = 0.0;
        double carbs = 0.0;
        double protein = 0.0;
        double fat = 0.0;
        if (raw != null) {
          if (raw is Map) {
            // API returned full targets for this meal
            kcal = (raw['target_kcal'] as num).toDouble();
            carbs = (raw['target_carbs'] as num).toDouble();
            protein = (raw['target_protein'] as num).toDouble();
            fat = (raw['target_fat'] as num).toDouble();
          } else if (raw is num) {
            // raw is a percentage value from settings
            final factor = raw.toDouble() / 100.0;
            kcal = (dailyCalories * factor).roundToDouble();
            carbs = (dailyCarbs * factor).roundToDouble();
            protein = (dailyProtein * factor).roundToDouble();
            fat = (dailyFat * factor).roundToDouble();
          }
        }
        // round to integers for display
        final ikcal = kcal.round();
        final ic = carbs.round();
        final ip = protein.round();
        final ifat = fat.round();

        // prefer dynamic recommended text for items that currently show 'Recommend' or have kacl==0
        if (item.kacl == 0 ||
            (item.meals != null &&
                item.meals!.any(
                  (s) => s.toLowerCase().contains('recommend'),
                ))) {
          item.kacl = ikcal;
          item.meals = <String>[
            'Recommend:',
            '$ikcal kcal',
            '$ic g carbs',
            '$ip g protein',
            '$ifat g fat',
          ];
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      // ignore loading errors silently
    }
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mainScreenAnimationController == null ||
        widget.mainScreenAnimation == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        // responsive item width computed from screen width so 4 cards fill the frame
        final screenWidth = MediaQuery.of(context).size.width;
        final totalPadding = 16.0 + 16.0;
        final gap = 12.0;
        final columns = 4.0;
        final available = screenWidth - totalPadding - (gap * (columns - 1));
        final itemWidth = (available / columns).clamp(120.0, screenWidth);

        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - widget.mainScreenAnimation!.value),
              0.0,
            ),
            // compute card width and height so the 4 cards can grow to show all content
            // itemWidth computed above, derive a proportional height to avoid overflow
            // increase multiplier and clamps to give more vertical room for multi-line Recommend text
            child: SizedBox(
              height: (itemWidth * 1.8).clamp(280.0, 600.0),
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  right: 16,
                  left: 16,
                ),
                itemCount: mealsListData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count = mealsListData.length > 10
                      ? 10
                      : mealsListData.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animationController!,
                          curve: Interval(
                            (1 / count) * index,
                            1.0,
                            curve: Curves.fastOutSlowIn,
                          ),
                        ),
                      );
                  animationController?.forward();

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == mealsListData.length - 1 ? 0 : gap,
                    ),
                    child: MealsView(
                      mealsListData: mealsListData[index],
                      animation: animation,
                      animationController: animationController!,
                      cardWidth: itemWidth,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class MealsView extends StatelessWidget {
  const MealsView({
    super.key,
    this.mealsListData,
    this.animationController,
    this.animation,
    this.cardWidth,
  });

  final MealsListData? mealsListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final double? cardWidth;

  @override
  Widget build(BuildContext context) {
    if (animationController == null ||
        animation == null ||
        mealsListData == null) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              100 * (1.0 - animation!.value),
              0.0,
              0.0,
            ),
            child: SizedBox(
              width: cardWidth ?? 150,
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      // Show recommend dialog when tapping card with recommend data
                      if (mealsListData!.meals != null &&
                          mealsListData!.meals!.any(
                            (s) => s.toLowerCase().contains('recommend'),
                          )) {
                        // Parse recommendations data
                        final recommendations = mealsListData!.meals!;
                        String? kcalValue;
                        String? carbsValue;
                        String? proteinValue;
                        String? fatValue;

                        for (final line in recommendations) {
                          final lowerLine = line.toLowerCase();
                          if (lowerLine.contains('kcal')) {
                            kcalValue = line
                                .replaceAll('Recommend:', '')
                                .trim();
                          } else if (lowerLine.contains('carbs')) {
                            carbsValue = line;
                          } else if (lowerLine.contains('protein')) {
                            proteinValue = line;
                          } else if (lowerLine.contains('fat')) {
                            fatValue = line;
                          }
                        }

                        showDialog(
                          context: context,
                          barrierColor: Colors.black54,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.white, Colors.blue.shade50],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header with icon and title
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade600,
                                          Colors.blue.shade400,
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.restaurant_menu,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            'Khuyến nghị dinh dưỡng',
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Content
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        // Calories card
                                        if (kcalValue != null)
                                          _buildNutrientCard(
                                            icon: Icons.local_fire_department,
                                            iconColor: Colors.orange,
                                            title: 'Calories',
                                            value: kcalValue,
                                            gradient: [
                                              Colors.orange.shade50,
                                              Colors.orange.shade100,
                                            ],
                                          ),
                                        const SizedBox(height: 12),
                                        // Carbs card
                                        if (carbsValue != null)
                                          _buildNutrientCard(
                                            icon: Icons.breakfast_dining,
                                            iconColor: Colors.amber,
                                            title: 'Carbs',
                                            value: carbsValue,
                                            gradient: [
                                              Colors.amber.shade50,
                                              Colors.amber.shade100,
                                            ],
                                          ),
                                        const SizedBox(height: 12),
                                        // Protein card
                                        if (proteinValue != null)
                                          _buildNutrientCard(
                                            icon: Icons.fitness_center,
                                            iconColor: Colors.red,
                                            title: 'Protein',
                                            value: proteinValue,
                                            gradient: [
                                              Colors.red.shade50,
                                              Colors.red.shade100,
                                            ],
                                          ),
                                        const SizedBox(height: 12),
                                        // Fat card
                                        if (fatValue != null)
                                          _buildNutrientCard(
                                            icon: Icons.water_drop,
                                            iconColor: Colors.blue,
                                            title: 'Fat',
                                            value: fatValue,
                                            gradient: [
                                              Colors.blue.shade50,
                                              Colors.blue.shade100,
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Close button
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 24,
                                      right: 24,
                                      bottom: 24,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: const Text(
                                          'Đóng',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 8,
                        right: 8,
                        bottom: 12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: HexColor(
                                mealsListData!.endColor,
                              ).withAlpha((0.6 * 255).round()),
                              offset: const Offset(1.1, 4.0),
                              blurRadius: 8.0,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(mealsListData!.startColor),
                              HexColor(mealsListData!.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(54.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 64,
                            left: 16,
                            right: 16,
                            bottom: 12,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Builder(
                                builder: (context) {
                                  final l10n = AppLocalizations.of(context)!;
                                  final mealTitleMap = {
                                    'Breakfast': l10n.breakfast,
                                    'Lunch': l10n.lunch,
                                    'Snack': l10n.snack,
                                    'Dinner': l10n.dinner,
                                  };
                                  final localizedTitle =
                                      mealTitleMap[mealsListData!.titleTxt] ??
                                      mealsListData!.titleTxt;
                                  return Text(
                                    localizedTitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                      color: FitnessAppTheme.white,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 4,
                                  ),
                                  // If this meals list is a "Recommend" block, don't render it twice here.
                                  // The dedicated Recommend area below will show the 4-info lines.
                                  child:
                                      (mealsListData!.meals != null &&
                                          mealsListData!.meals!.any(
                                            (s) => s.toLowerCase().contains(
                                              'recommend',
                                            ),
                                          ))
                                      ? const SizedBox.shrink()
                                      : SingleChildScrollView(
                                          child: Text(
                                            mealsListData!.meals!.join('\n'),
                                            style: TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 11,
                                              height: 1.15,
                                              letterSpacing: 0.2,
                                              color: FitnessAppTheme.white,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  if (mealsListData!.meals != null &&
                                      mealsListData!.meals!.any(
                                        (s) => s.toLowerCase().contains(
                                          'recommend',
                                        ),
                                      ))
                                    const SizedBox.shrink()
                                  else
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              mealsListData!.kacl.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 22,
                                                letterSpacing: 0.2,
                                                color: FitnessAppTheme.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 2,
                                            ),
                                            child: Text(
                                              'kcal',
                                              style: TextStyle(
                                                fontFamily:
                                                    FitnessAppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                letterSpacing: 0.2,
                                                color: FitnessAppTheme.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // placeholder to keep spacing when we overlay the big '+' button
                                  const SizedBox(width: 32, height: 64),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Big '+' button anchored to bottom-right of the card. Kept as Positioned so it won't overflow the rounded container.
                  Positioned(
                    bottom: 20,
                    right: 12,
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: AuthService.getSettings(),
                      builder: (context, snapshot) {
                        // Check if meal time is allowed (UTC+7)
                        final now = DateTime.now().toUtc().add(
                          const Duration(hours: 7),
                        );
                        final currentTime = TimeOfDay(
                          hour: now.hour,
                          minute: now.minute,
                        );
                        final settings = snapshot.data;

                        // Get meal time from settings
                        String? mealTimeStr;
                        final mealType = mealsListData!.titleTxt.toLowerCase();
                        if (mealType == 'breakfast') {
                          mealTimeStr =
                              settings?['meal_time_breakfast']?.toString() ??
                              '07:00';
                        } else if (mealType == 'lunch') {
                          mealTimeStr =
                              settings?['meal_time_lunch']?.toString() ??
                              '11:00';
                        } else if (mealType == 'snack') {
                          mealTimeStr =
                              settings?['meal_time_snack']?.toString() ??
                              '13:00';
                        } else if (mealType == 'dinner') {
                          mealTimeStr =
                              settings?['meal_time_dinner']?.toString() ??
                              '18:00';
                        }

                        // Parse meal time
                        TimeOfDay? mealTime;
                        bool isAllowed = true;
                        if (mealTimeStr != null) {
                          final parts = mealTimeStr.split(':');
                          if (parts.length >= 2) {
                            final hour = int.tryParse(parts[0]);
                            final minute = int.tryParse(parts[1]);
                            if (hour != null && minute != null) {
                              mealTime = TimeOfDay(hour: hour, minute: minute);
                              final mealDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                mealTime.hour,
                                mealTime.minute,
                              );
                              final endDateTime = mealDateTime.add(
                                const Duration(hours: 4),
                              );
                              final currentDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                currentTime.hour,
                                currentTime.minute,
                              );

                              isAllowed =
                                  currentDateTime.isAfter(
                                    mealDateTime.subtract(
                                      const Duration(minutes: 1),
                                    ),
                                  ) &&
                                  currentDateTime.isBefore(endDateTime);
                            }
                          }
                        }

                        return GestureDetector(
                          onTap: isAllowed
                              ? () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final prov = context.maybeProfile();

                                  final result =
                                      await showModalBottomSheet<dynamic>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (ctx) => MealQuickAddSheet(
                                          mealType: mealsListData!.titleTxt,
                                        ),
                                      );

                                  if (!context.mounted) return;
                                  if (result == null) return;

                                  if (result == true ||
                                      (result is Map &&
                                          result['success'] == true)) {
                                    if (prov != null) {
                                      try {
                                        await prov.loadProfile();
                                      } catch (_) {}
                                    }

                                    VitaminView.refreshAll();
                                    MineralView.refreshAll();
                                    AminoView.refreshAll();
                                    FatView.refreshAll();

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Đã thêm món ăn thành công!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    return;
                                  }

                                  if (result is! Map) return;

                                  final foodId = result['food_id'] as int?;
                                  final weightG = result['weight_g'] as double?;

                                  if (foodId == null ||
                                      weightG == null ||
                                      weightG <= 0) {
                                    // Silently skip invalid data
                                    return;
                                  }

                                  // Create meal via API
                                  final mealResult =
                                      await AuthService.createMeal(
                                        mealType: mealsListData!.titleTxt
                                            .toLowerCase(),
                                        items: [
                                          {
                                            'food_id': foodId,
                                            'weight_g': weightG,
                                          },
                                        ],
                                      );

                                  if (!context.mounted) return;

                                  if (mealResult == null ||
                                      mealResult['error'] != null) {
                                    final err = mealResult != null
                                        ? mealResult['error']
                                        : 'Lỗi mạng';
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Không thể tạo meal: $err',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // Update profile with today's totals
                                  if (prov != null &&
                                      mealResult['today'] != null) {
                                    prov.applyTodayTotals(mealResult['today']);
                                  }

                                  // Refresh all nutrient views
                                  VitaminView.refreshAll();
                                  MineralView.refreshAll();
                                  AminoView.refreshAll();
                                  FatView.refreshAll();

                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Đã thêm món ăn thành công!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              : () {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final endHour = mealTime != null
                                      ? (mealTime.hour + 4) % 24
                                      : 0;
                                  final endMinute = mealTime?.minute ?? 0;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Bạn chưa đến giờ ăn buổi ${mealsListData!.titleTxt}. Thời gian cho phép: $mealTimeStr - ${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}',
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isAllowed
                                  ? const Color(0xFF2E8BFF)
                                  : const Color(
                                      0xFF2E8BFF,
                                    ).withValues(alpha: 0.3),
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
                              child: Icon(
                                Icons.add,
                                color: isAllowed
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                size: 26,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyWhite.withAlpha(
                          (0.2 * 255).round(),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 8,
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(mealsListData!.imagePath),
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

  Widget _buildNutrientCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
