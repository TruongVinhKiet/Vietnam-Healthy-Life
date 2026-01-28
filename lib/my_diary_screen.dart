// ignore_for_file: library_private_types_in_public_api

import 'package:my_diary/ui_view/body_measurement.dart';
import 'package:my_diary/ui_view/glass_view.dart';
import 'package:my_diary/ui_view/mediterranean_diet_view.dart';
import 'package:my_diary/ui_view/recipe_gallery_card_view.dart';
import 'package:my_diary/ui_view/drink_gallery_card_view.dart';
import 'package:my_diary/ui_view/health_condition_card_view.dart';
import 'package:my_diary/ui_view/nutrition_overview_view.dart';
import 'package:my_diary/ui_view/title_view.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/meals_list_view.dart';
import 'package:my_diary/water_view.dart';
import 'package:my_diary/widgets/nutrient_notifications_widget.dart';
import 'package:my_diary/services/nutrient_tracking_service.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:my_diary/screens/recipes_screen.dart';
import 'package:my_diary/screens/meal_templates_screen.dart';
import 'package:my_diary/widgets/draggable_chat_button.dart';
import 'package:my_diary/widgets/draggable_lightbulb_button.dart';
import 'package:my_diary/widgets/draggable_timeline_button.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:my_diary/l10n/app_localizations.dart';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({super.key, this.animationController});

  final AnimationController? animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  Animation<double>? topBarAnimation;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  List<Widget> listViews = <Widget>[];
  int _mealsReloadKey = 0;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Reload profile khi vào màn hình để đảm bảo reset đúng UTC+7
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.maybeProfile();
      profile?.loadProfile();
    });

    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController!,
        curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn),
      ),
    );

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    // start realtime clock
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          _now = now;
        });
      }
    });

    addAllListData();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  String _monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month.clamp(1, 12)];
  }

  String _formatNow(DateTime dt) {
    final day = dt.day;
    final month = _monthName(dt.month);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$day $month • $h:$m';
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
    }
    return null;
  }

  void addAllListData() {
    // rebuild listViews so UI can refresh when settings/profile change
    listViews.clear();
    const int count = 10; // Tăng từ 9 lên 10

    // Recipe Gallery Card - New
    listViews.add(
      TitleView(
        titleTxt: 'Công Thức Nấu Ăn',
        subTxt: 'Khám phá',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / count) * 0, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      RecipeGalleryCardView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 0.5,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );
    // TitleView for Drink Recipes
    listViews.add(
      TitleView(
        titleTxt: 'Công Thức Nước Uống',
        subTxt: 'Khám phá',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 0.52,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );
    // Drink Gallery Card - New (Công thức nước uống)
    listViews.add(
      DrinkGalleryCardView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 0.55,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );

    // TitleView for Health Condition Explore
    listViews.add(
      TitleView(
        titleTxt: 'Khám phá bệnh',
        subTxt: 'Tìm hiểu',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 0.57,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );

    // Health Condition Card - New (Khám phá bệnh)
    listViews.add(
      HealthConditionCardView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 0.58,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return TitleView(
            titleTxt: l10n.bodyMeasurement,
            subTxt: l10n.today,
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval(
                  (1 / count) * 0.6,
                  1.0,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            ),
            animationController: widget.animationController!,
          );
        },
      ),
    );

    listViews.add(
      BodyMeasurementView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 0.7,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );

    listViews.add(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return TitleView(
            titleTxt: l10n.mediterraneanDiet,
            subTxt: l10n.details,
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval(
                  (1 / count) * 1,
                  1.0,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            ),
            animationController: widget.animationController!,
          );
        },
      ),
    );
    listViews.add(
      MediterranesnDietView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 1.5,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );

    // Meals today section — moved here after Mediterranean diet
    listViews.add(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return TitleView(
            titleTxt: l10n.mealsToday,
            subTxt: l10n.customize,
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval(
                  (1 / count) * 1.1,
                  1.0,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            ),
            animationController: widget.animationController!,
            onTap: () async {
              // show customize dialog to edit meal distribution percentages
              final settings = await AuthService.getSettings();
              if (!context.mounted) return;
              final breakfast =
                  (settings != null && settings['meal_pct_breakfast'] != null)
                  ? settings['meal_pct_breakfast'].toString()
                  : '25';
              final lunch =
                  (settings != null && settings['meal_pct_lunch'] != null)
                  ? settings['meal_pct_lunch'].toString()
                  : '35';
              final snack =
                  (settings != null && settings['meal_pct_snack'] != null)
                  ? settings['meal_pct_snack'].toString()
                  : '10';
              final dinner =
                  (settings != null && settings['meal_pct_dinner'] != null)
                  ? settings['meal_pct_dinner'].toString()
                  : '30';

              final bCtrl = TextEditingController(text: breakfast);
              final lCtrl = TextEditingController(text: lunch);
              final sCtrl = TextEditingController(text: snack);
              final dCtrl = TextEditingController(text: dinner);

              // Get meal times from settings
              final breakfastTime =
                  (settings != null && settings['meal_time_breakfast'] != null)
                  ? settings['meal_time_breakfast'].toString()
                  : '07:00';
              final lunchTime =
                  (settings != null && settings['meal_time_lunch'] != null)
                  ? settings['meal_time_lunch'].toString()
                  : '11:00';
              final snackTime =
                  (settings != null && settings['meal_time_snack'] != null)
                  ? settings['meal_time_snack'].toString()
                  : '13:00';
              final dinnerTime =
                  (settings != null && settings['meal_time_dinner'] != null)
                  ? settings['meal_time_dinner'].toString()
                  : '18:00';

              final btCtrl = TextEditingController(text: breakfastTime);
              final ltCtrl = TextEditingController(text: lunchTime);
              final stCtrl = TextEditingController(text: snackTime);
              final dtCtrl = TextEditingController(text: dinnerTime);

              final result = await showDialog<bool>(
                context: context,
                builder: (ctx) {
                  final l10n = AppLocalizations.of(ctx)!;
                  return AlertDialog(
                    title: Text(l10n.customizeMealDistribution),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Breakfast
                          _buildMealSection(
                            ctx,
                            l10n.breakfast,
                            Icons.wb_sunny,
                            Colors.orange,
                            bCtrl,
                            btCtrl,
                            '07:00',
                          ),
                          const SizedBox(height: 16),
                          // Lunch
                          _buildMealSection(
                            ctx,
                            l10n.lunch,
                            Icons.restaurant,
                            Colors.blue,
                            lCtrl,
                            ltCtrl,
                            '11:00',
                          ),
                          const SizedBox(height: 16),
                          // Snack
                          _buildMealSection(
                            ctx,
                            l10n.snack,
                            Icons.local_cafe,
                            Colors.green,
                            sCtrl,
                            stCtrl,
                            '13:00',
                          ),
                          const SizedBox(height: 16),
                          // Dinner
                          _buildMealSection(
                            ctx,
                            l10n.dinner,
                            Icons.dinner_dining,
                            Colors.purple,
                            dCtrl,
                            dtCtrl,
                            '18:00',
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          final b = double.tryParse(bCtrl.text.trim()) ?? 0.0;
                          final l = double.tryParse(lCtrl.text.trim()) ?? 0.0;
                          final s = double.tryParse(sCtrl.text.trim()) ?? 0.0;
                          final d = double.tryParse(dCtrl.text.trim()) ?? 0.0;
                          final sum = b + l + s + d;
                          if ((sum - 100.0).abs() > 0.01) {
                            // small tolerance
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(l10n.percentagesMustSumTo100),
                              ),
                            );
                            return;
                          }

                          // Validate time format (HH:mm)
                          final timeRegex = RegExp(
                            r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$',
                          );
                          if (!timeRegex.hasMatch(btCtrl.text.trim()) ||
                              !timeRegex.hasMatch(ltCtrl.text.trim()) ||
                              !timeRegex.hasMatch(stCtrl.text.trim()) ||
                              !timeRegex.hasMatch(dtCtrl.text.trim())) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(l10n.timeFormatMustBeHHmm),
                              ),
                            );
                            return;
                          }

                          // Validate meal time spacing (scientific/healthy schedule)
                          final bt = _parseTime(btCtrl.text.trim());
                          final lt = _parseTime(ltCtrl.text.trim());
                          final st = _parseTime(stCtrl.text.trim());
                          final dt = _parseTime(dtCtrl.text.trim());

                          int toMinutes(TimeOfDay? t) =>
                              (t?.hour ?? 0) * 60 + (t?.minute ?? 0);

                          final bMin = toMinutes(bt);
                          final lMin = toMinutes(lt);
                          final sMin = toMinutes(st);
                          final dMin = toMinutes(dt);

                          String? warning;
                          const minGapMinutes = 120;
                          if (!(bMin < lMin && lMin < sMin && sMin < dMin)) {
                            warning =
                                'Giờ các bữa ăn cần theo thứ tự trong ngày: Sáng < Trưa < Phụ < Tối.';
                          } else if ((lMin - bMin) < minGapMinutes ||
                              (sMin - lMin) < minGapMinutes ||
                              (dMin - sMin) < minGapMinutes) {
                            warning =
                                'Giờ các bữa ăn đang quá sát nhau. Vui lòng đặt các bữa cách nhau ít nhất 2 giờ để đảm bảo tiêu hoá và hấp thu.';
                          }

                          if (warning != null) {
                            await showDialog<void>(
                              context: ctx,
                              builder: (c) {
                                return AlertDialog(
                                  title: const Text('Giờ ăn chưa hợp lý'),
                                  content: Text(warning!),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(c).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          // save to backend settings
                          final payload = {
                            'meal_pct_breakfast': double.parse(
                              b.toStringAsFixed(2),
                            ),
                            'meal_pct_lunch': double.parse(
                              l.toStringAsFixed(2),
                            ),
                            'meal_pct_snack': double.parse(
                              s.toStringAsFixed(2),
                            ),
                            'meal_pct_dinner': double.parse(
                              d.toStringAsFixed(2),
                            ),
                            'meal_time_breakfast': btCtrl.text.trim(),
                            'meal_time_lunch': ltCtrl.text.trim(),
                            'meal_time_snack': stCtrl.text.trim(),
                            'meal_time_dinner': dtCtrl.text.trim(),
                          };
                          final res = await AuthService.updateSettings(payload);
                          // Guard using the dialog context, not the outer State's context
                          if (!ctx.mounted) return;
                          if (res == null || res['error'] != null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${l10n.failedToSave}: ${res != null ? res['error'] : l10n.network}',
                                ),
                              ),
                            );
                            return;
                          }

                          // Update meal time notifications
                          try {
                            final breakfastTime = _parseTime(
                              btCtrl.text.trim(),
                            );
                            final lunchTime = _parseTime(ltCtrl.text.trim());
                            final snackTime = _parseTime(stCtrl.text.trim());
                            final dinnerTime = _parseTime(dtCtrl.text.trim());

                            await LocalNotificationService()
                                .updateMealTimeNotifications(
                                  breakfast: breakfastTime,
                                  lunch: lunchTime,
                                  snack: snackTime,
                                  dinner: dinnerTime,
                                );
                          } catch (e) {
                            debugPrint(
                              'Error updating meal time notifications: $e',
                            );
                          }

                          if (!ctx.mounted) return;

                          Navigator.of(ctx).pop(true);
                        },
                        child: Text(l10n.save),
                      ),
                    ],
                  );
                },
              );

              if (result == true && mounted) {
                // refresh UI by rebuilding list data
                setState(() {
                  _mealsReloadKey++;
                  addAllListData();
                });
              }
            },
          );
        },
      ),
    );

    listViews.add(
      MealsListView(
        key: ValueKey<int>(_mealsReloadKey),
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 1.15,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        mainScreenAnimationController: widget.animationController,
      ),
    );

    // Water section — moved after Meals
    listViews.add(
      Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return TitleView(
            titleTxt: l10n.water,
            subTxt: l10n.aquaSmartBottle,
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval(
                  (1 / count) * 1.2,
                  1.0,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            ),
            animationController: widget.animationController!,
          );
        },
      ),
    );

    listViews.add(
      WaterView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 1.3,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
      ),
    );

    // Nutrition Overview (Vitamins, Minerals, Amino Acids, Fat, Fiber) — moved after Water
    listViews.add(
      NutritionOverviewView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval(
              (1 / count) * 1.4,
              1.0,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );
    listViews.add(
      GlassView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: widget.animationController!,
            curve: Interval((1 / count) * 8, 1.0, curve: Curves.fastOutSlowIn),
          ),
        ),
        animationController: widget.animationController!,
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    String mealName,
    IconData icon,
    Color color,
    TextEditingController percentCtrl,
    TextEditingController timeCtrl,
    String defaultTime,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                mealName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Percentage selector - Dropdown 1-100
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${l10n.percentage}:',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  initialValue:
                      double.tryParse(
                        percentCtrl.text.replaceAll('%', '').trim(),
                      )?.toInt() ??
                      25,
                  decoration: InputDecoration(
                    suffixText: '%',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: List.generate(100, (index) => index + 1)
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value%'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      percentCtrl.text = value.toString();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time picker
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '${l10n.timeUtc7}:',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                flex: 3,
                child: TextField(
                  controller: timeCtrl,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.access_time, size: 20),
                    hintText: defaultTime,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onTap: () async {
                    final time = timeCtrl.text.trim();
                    TimeOfDay? initialTime;
                    if (time.isNotEmpty) {
                      final parts = time.split(':');
                      if (parts.length >= 2) {
                        final hour = int.tryParse(parts[0]);
                        final minute = int.tryParse(parts[1]);
                        if (hour != null && minute != null) {
                          initialTime = TimeOfDay(hour: hour, minute: minute);
                        }
                      }
                    }
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: initialTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      timeCtrl.text =
                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final seasonNotifier = SeasonEffectNotifier.maybeOf(context);

    return SeasonEffect(
      currentDate: seasonNotifier?.selectedDate ?? DateTime.now(),
      enabled: seasonNotifier?.enabled ?? true,
      child: Container(
        color: (seasonNotifier?.hasBackground ?? false)
            ? Colors.transparent
            : Theme.of(context).scaffoldBackgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: <Widget>[
              getMainListViewUI(),
              getAppBarUI(),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
              // Draggable chat button
              const DraggableChatButton(),
              // Draggable lightbulb button for smart suggestions
              const DraggableLightbulbButton(),
              const DraggableTimelineButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top:
                  AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController?.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: widget.animationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                  0.0,
                  30 * (1.0 - topBarAnimation!.value),
                  0.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.white.withAlpha(
                      (topBarOpacity * 255).round(),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: FitnessAppTheme.grey.withAlpha(
                          ((0.4 * topBarOpacity) * 255).round(),
                        ),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16 - 8.0 * topBarOpacity,
                          bottom: 12 - 8.0 * topBarOpacity,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.menu,
                                  color: FitnessAppTheme.grey,
                                  size: 20,
                                ),
                                offset: const Offset(0, 40),
                                onSelected: (value) {
                                  if (value == 'recipes') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RecipesScreen(),
                                      ),
                                    );
                                  } else if (value == 'templates') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MealTemplatesScreen(),
                                      ),
                                    );
                                  } else if (value == 'season') {
                                    final notifier =
                                        SeasonEffectNotifier.maybeOf(context);
                                    notifier?.toggleEffect();
                                    setState(() {});
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'recipes',
                                    child: Row(
                                      children: const [
                                        Icon(Icons.restaurant_menu, size: 20),
                                        SizedBox(width: 12),
                                        Text('Công thức nấu ăn'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'templates',
                                    child: Row(
                                      children: const [
                                        Icon(Icons.bookmark, size: 20),
                                        SizedBox(width: 12),
                                        Text('Mẫu bữa ăn'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'season',
                                    child: Row(
                                      children: [
                                        Icon(
                                          SeasonEffectNotifier.maybeOf(
                                                    context,
                                                  )?.enabled ??
                                                  true
                                              ? Icons.blur_on
                                              : Icons.blur_off,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          SeasonEffectNotifier.maybeOf(
                                                    context,
                                                  )?.enabled ??
                                                  true
                                              ? 'Tắt hiệu ứng mùa'
                                              : 'Bật hiệu ứng mùa',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.health_and_safety,
                                      size: 24,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'VietNam Healthy Life',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16 + 4 - 4 * topBarOpacity,
                                          letterSpacing: 0.5,
                                          color: Colors.green.shade800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                                onTap: () {},
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: FitnessAppTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                            // Notification Icon with Badge
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NutrientNotificationsWidget(),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        Icons.notifications_outlined,
                                        color: FitnessAppTheme.grey,
                                        size: 22,
                                      ),
                                      // Badge for unread notifications
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: FutureBuilder<Map<String, dynamic>>(
                                          future:
                                              NutrientTrackingService.getNotifications(
                                                limit: 1,
                                              ),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const SizedBox();
                                            }
                                            final unreadCount =
                                                snapshot
                                                    .data?['unread_count'] ??
                                                0;
                                            if (unreadCount == 0) {
                                              return const SizedBox();
                                            }
                                            return Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                unreadCount > 9
                                                    ? '9+'
                                                    : '$unreadCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
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
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: FitnessAppTheme.grey,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    _formatNow(_now),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(32.0),
                                ),
                                onTap: () {},
                                child: Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: FitnessAppTheme.grey,
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
            );
          },
        ),
      ],
    );
  }
}
