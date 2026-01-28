// ignore_for_file: library_private_types_in_public_api

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/statistics_service.dart';
import 'package:my_diary/services/ai_analysis_service.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:my_diary/widgets/medication_statistics_card.dart';
import 'package:my_diary/widgets/draggable_lightbulb_button.dart';
import 'package:my_diary/widgets/draggable_chat_button.dart';
import 'package:my_diary/widgets/draggable_timeline_button.dart';
import 'package:my_diary/screens/nutrition_report_screen.dart';
import 'package:my_diary/l10n/app_localizations.dart';

// Period visuals map
const Map<String, Map<String, dynamic>> _periodVisuals = {
  'morning': {'icon': Icons.wb_sunny_outlined, 'color': Color(0xFFFFA726)},
  'afternoon': {'icon': Icons.lunch_dining, 'color': Color(0xFF42A5F5)},
  'snack': {'icon': Icons.icecream_outlined, 'color': Color(0xFFEF5350)},
  'evening': {'icon': Icons.nights_stay_outlined, 'color': Color(0xFF7E57C2)},
};

// Macro ring painter class
class MacroRingPainter extends CustomPainter {
  final double carbs;
  final double protein;
  final double fat;
  final double animationValue;

  MacroRingPainter({
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final startAngle = -pi / 2;
    final total = max(carbs + protein + fat, 0.1);

    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      0,
      2 * pi,
      false,
      backgroundPaint,
    );

    double currentAngle = startAngle;

    void drawSegment(double value, Color color) {
      if (value <= 0) return;
      final sweep = animationValue * (value / total) * 2 * pi;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        ),
        currentAngle,
        sweep,
        false,
        paint,
      );
      currentAngle += sweep;
    }

    drawSegment(carbs, const Color(0xFFFACCCC));
    drawSegment(protein, const Color(0xFFB9E2FF));
    drawSegment(fat, const Color(0xFFFDD9A1));
  }

  @override
  bool shouldRepaint(covariant MacroRingPainter oldDelegate) {
    return oldDelegate.carbs != carbs ||
        oldDelegate.protein != protein ||
        oldDelegate.fat != fat ||
        oldDelegate.animationValue != animationValue;
  }
}

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _summary;
  DateTime _selectedDate = _vietnamToday();
  bool _showDateHistory = false;
  List<Map<String, dynamic>> _dateHistory = [];
  Map<String, dynamic>? _waterPeriodSummary;
  List<Map<String, dynamic>> _aiAnalyzedMeals = [];

  static DateTime _vietnamToday() {
    final utcNow = DateTime.now().toUtc();
    final vnNow = utcNow.add(const Duration(hours: 7));
    return DateTime(vnNow.year, vnNow.month, vnNow.day);
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        debugPrint('[_toDouble] WARNING: Failed to parse "$value" to double');
      }
      return parsed ?? 0;
    }
    debugPrint(
      '[_toDouble] WARNING: Unexpected type ${value.runtimeType} for value: $value',
    );
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    setState(() {
      _isLoading = true;
      _error = null;
      _showDateHistory = false;
    });
    try {
      final results = await Future.wait([
        StatisticsService.getMealPeriodSummary(date: dateStr),
        StatisticsService.getMealHistory(date: dateStr),
        StatisticsService.getWaterPeriodSummary(date: dateStr),
        AiAnalysisService.getAnalyzedMeals(accepted: true, limit: 50),
      ]);
      if (!mounted) return;
      final historyMap = results[1] as Map<String, dynamic>;

      // Lọc AI analyzed meals theo ngày đã chọn (giờ Việt Nam) để tránh hiển thị lẫn ngày khác
      final List<dynamic> rawAiMeals = results[3] as List<dynamic>;
      // Chuẩn hóa ngày được chọn về mốc 00:00 để so sánh
      final selected = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final filteredAiMeals = rawAiMeals
          .where((meal) {
            final analyzedAt = (meal as Map<String, dynamic>)['analyzed_at']
                ?.toString();
            if (analyzedAt == null) return false;
            try {
              final dt = DateTime.parse(analyzedAt);
              // Convert về giờ Việt Nam nếu backend trả UTC
              final vnTime = dt.isUtc ? dt.add(const Duration(hours: 7)) : dt;
              final dateOnly = DateTime(vnTime.year, vnTime.month, vnTime.day);
              return dateOnly == selected;
            } catch (_) {
              return false;
            }
          })
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      final waterData = results[2] as Map<String, dynamic>?;
      debugPrint(
        '[StatisticsScreen] Water data received: total_ml=${waterData?['total_ml']}, goal_ml=${waterData?['goal_ml']}',
      );

      setState(() {
        _summary = results[0] as Map<String, dynamic>?;
        _dateHistory = List<Map<String, dynamic>>.from(
          historyMap['meals'] ?? [],
        );
        _waterPeriodSummary = waterData;
        _aiAnalyzedMeals = filteredAiMeals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDateHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final history = await StatisticsService.getMealHistory(date: dateStr);
      if (!mounted) return;
      setState(() {
        _dateHistory = List<Map<String, dynamic>>.from(history['meals'] ?? []);
        _showDateHistory = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
            children: [
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  _buildAppBar(),
                  Expanded(
                    child: RefreshIndicator(
                      color: FitnessAppTheme.nearlyDarkBlue,
                      onRefresh: _loadSummary,
                      child: _buildBody(),
                    ),
                  ),
                ],
              ),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.cannotLoadStatistics,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FitnessAppTheme.grey,
                        fontFamily: FitnessAppTheme.fontName,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadSummary,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    final periods = List<Map<String, dynamic>>.from(
      _summary?['periods'] ?? const [],
    );

    if (periods.isEmpty) {
      return Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_food_beverage_outlined,
                      color: Color(0xFF667EEA),
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noDataForToday,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.pleaseRecordYourMealsToSeeDetailedStatistics,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        color: FitnessAppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    if (_showDateHistory) {
      return _buildDateHistoryView();
    }

    final periodCards = List<Widget>.generate(
      periods.length,
      (index) => _buildPeriodCard(periods[index], index),
    );

    // Water summary card
    final waterEntries = List<Map<String, dynamic>>.from(
      _waterPeriodSummary?['entries'] ?? const [],
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        ...periodCards,
        const SizedBox(height: 24),
        _buildWaterSummaryCard(waterEntries),
        const SizedBox(height: 24),
        if (_aiAnalyzedMeals.isNotEmpty) ...[
          _buildAiAnalyzedMealsCard(),
          const SizedBox(height: 24),
        ],
        const MedicationStatisticsCard(),
        const SizedBox(height: 24),
        _buildDailyHistoryCard(_dateHistory),
      ],
    );
  }

  Widget _buildWaterSummaryCard(List<Map<String, dynamic>> entries) {
    final goalMl = _toDouble(_waterPeriodSummary?['goal_ml']);
    final totalMl = _toDouble(_waterPeriodSummary?['total_ml']);
    final percentageValue = _waterPeriodSummary?['percentage'];
    final percentage = percentageValue is num
        ? percentageValue.toInt()
        : (percentageValue is String ? int.tryParse(percentageValue) ?? 0 : 0);
    final topNutrients = List<Map<String, dynamic>>.from(
      _waterPeriodSummary?['top_nutrients'] ?? const [],
    );

    const Color accentColor = Color(0xFF2E8BFF);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lượng nước hôm nay',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: FitnessAppTheme.darkerText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalMl.toInt()} ml / ${goalMl.toInt()} ml',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 14,
                          color: FitnessAppTheme.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: FitnessAppTheme.nearlyWhite,
                valueColor: const AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 8,
              ),
            ),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              Text(
                'Chi tiết các lần uống nước',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: FitnessAppTheme.darkerText,
                ),
              ),
              const SizedBox(height: 8),
              // Water entries
              ...entries.take(10).map((entry) {
                final drinkName =
                    entry['drink_name'] ?? entry['name'] ?? 'Nước';
                final amountMl = _toDouble(
                  entry['amount_ml'] ?? entry['amount'],
                );
                final loggedAt = entry['logged_at'];
                String time = '';
                if (loggedAt != null) {
                  try {
                    // Parse datetime and convert to UTC+7 (Vietnam timezone)
                    final dt = DateTime.parse(loggedAt.toString());
                    final vnTime = dt.isUtc
                        ? dt.add(const Duration(hours: 7))
                        : dt;
                    time = DateFormat('HH:mm').format(vnTime);
                  } catch (_) {}
                }
                final nutrients = List<Map<String, dynamic>>.from(
                  entry['nutrients'] ?? [],
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 56,
                        child: Text(
                          time,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: FitnessAppTheme.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drinkName,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: FitnessAppTheme.darkerText,
                              ),
                            ),
                            if (nutrients.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: nutrients.take(3).map((nutrient) {
                                  final name = nutrient['nutrient_name'] ?? '';
                                  final amount = _toDouble(nutrient['amount']);
                                  final unit = nutrient['unit'] ?? '';
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$name: ${amount.toStringAsFixed(1)} $unit',
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontSize: 11,
                                        color: accentColor,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${amountMl.toInt()} ml',
                        style: const TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (topNutrients.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              Text(
                'Chất dinh dưỡng tiêu biểu',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: FitnessAppTheme.darkerText,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topNutrients.take(5).map((nutrient) {
                  final name = nutrient['nutrient_name'] ?? '';
                  final amount = _toDouble(nutrient['amount']);
                  final unit = nutrient['unit'] ?? '';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$name: ${amount.toStringAsFixed(1)} $unit',
                      style: const TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (entries.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Chưa ghi nhận lượng nước',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      color: FitnessAppTheme.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyHistoryCard(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Chưa có ghi nhận chi tiết cho ngày này.',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              color: FitnessAppTheme.grey,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch sử bữa ăn trong ngày',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: FitnessAppTheme.darkerText,
              ),
            ),
            const SizedBox(height: 12),
            ...entries.take(10).map((entry) {
              final createdAt = entry['created_at'];
              String time = '';
              if (createdAt != null) {
                try {
                  time = DateFormat('HH:mm').format(DateTime.parse(createdAt));
                } catch (_) {}
              }
              final mealType = (entry['meal_type'] ?? '').toString();
              final mealName =
                  entry['food_name'] ?? entry['dish_name'] ?? 'Meal';
              final kcal = (entry['calories'] ?? entry['kcal'] ?? 0).toString();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        time,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealName,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            mealType,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 12,
                              color: FitnessAppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text('$kcal kcal'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHistoryView() {
    if (_dateHistory.isEmpty) {
      return Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_food_beverage_outlined,
                      color: Color(0xFF667EEA),
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noDataForThisDate,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

    // Group meals by meal_type and time
    final Map<String, List<Map<String, dynamic>>> groupedMeals = {};
    for (final meal in _dateHistory) {
      final mealType = meal['meal_type'] ?? 'unknown';
      final createdAt = meal['created_at'];
      if (createdAt != null) {
        try {
          final dateTime = DateTime.parse(createdAt);
          final timeStr = DateFormat('HH:mm').format(dateTime);
          final key = '$mealType|$timeStr';
          if (!groupedMeals.containsKey(key)) {
            groupedMeals[key] = [];
          }
          groupedMeals[key]!.add(meal);
        } catch (e) {
          // Ignore parse errors
        }
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: groupedMeals.length,
      itemBuilder: (context, index) {
        final entry = groupedMeals.entries.toList()[index];
        final parts = entry.key.split('|');
        final mealType = parts[0];
        final timeStr = parts.length > 1 ? parts[1] : '';

        final mealTypeLabels = {
          'breakfast': 'Sáng',
          'lunch': 'Trưa',
          'snack': 'Xế',
          'dinner': 'Tối',
        };

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getMealIcon(mealType),
                    color: _getMealColor(mealType),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    mealTypeLabels[mealType] ?? mealType,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  if (timeStr.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: FitnessAppTheme.nearlyDarkBlue.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ...entry.value.map((meal) => _buildMealHistoryItem(meal)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealHistoryItem(Map<String, dynamic> meal) {
    final foodName = meal['food_name'] ?? 'Unknown';
    final weightG = _toDouble(meal['weight_g']);
    final calories = _toDouble(meal['calories']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FitnessAppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${weightG.toStringAsFixed(0)}g • ${calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 12,
                    color: FitnessAppTheme.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'snack':
        return Icons.local_cafe;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.blue;
      case 'snack':
        return Colors.green;
      case 'dinner':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAppBar() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.statistics,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: 1.2,
                        color: FitnessAppTheme.darkerText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    color: FitnessAppTheme.nearlyDarkBlue,
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                          _showDateHistory = false;
                        });
                        _loadSummary();
                      }
                    },
                    tooltip: l10n.selectDate,
                  ),
                  IconButton(
                    icon: Icon(
                      _showDateHistory ? Icons.view_module : Icons.history,
                    ),
                    color: FitnessAppTheme.nearlyDarkBlue,
                    onPressed: () {
                      if (_showDateHistory) {
                        setState(() {
                          _showDateHistory = false;
                        });
                      } else {
                        _loadDateHistory();
                      }
                    },
                    tooltip: _showDateHistory
                        ? l10n.viewOverview
                        : l10n.viewDetailsByDate,
                  ),
                  IconButton(
                    tooltip: l10n.details,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NutritionReportScreen(),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'vi').format(_selectedDate),
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 14,
                  color: FitnessAppTheme.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodCard(Map<String, dynamic> period, int index) {
    try {
      final visuals =
          _periodVisuals[period['key']] ??
          {'icon': Icons.fastfood, 'color': const Color(0xFF667EEA)};

      final entries = List<Map<String, dynamic>>.from(
        period['entries'] ?? const [],
      );
      final topNutrients = List<Map<String, dynamic>>.from(
        period['top_nutrients'] ?? const [],
      );
      final macros = Map<String, dynamic>.from(period['total_macros'] ?? {});
      final totalCalories = _toDouble(macros['calories']);

      final Color accentColor = visuals['color'] as Color;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500 + index * 120),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 20),
              child: child,
            ),
          );
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        visuals['icon'] as IconData,
                        color: accentColor,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            period['label'] ?? '',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: FitnessAppTheme.darkerText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entries.isEmpty
                                ? 'Chưa ghi nhận món ăn'
                                : '${entries.length} món hôm nay',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 13,
                              color: FitnessAppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutQuart,
                        builder: (context, animValue, _) => CustomPaint(
                          painter: MacroRingPainter(
                            carbs: _toDouble(macros['carbs']),
                            protein: _toDouble(macros['protein']),
                            fat: _toDouble(macros['fat']),
                            animationValue: animValue,
                          ),
                          child: Center(
                            child: Text(
                              '${totalCalories.toStringAsFixed(0)}\nkcal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMacroLegend(macros, accentColor: accentColor),
                const SizedBox(height: 16),
                if (topNutrients.isNotEmpty) ...[
                  Text(
                    'Chất dinh dưỡng nổi bật',
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: topNutrients.take(4).map((nutrient) {
                      final amount = _toDouble(nutrient['amount']);
                      if (amount <= 0) return const SizedBox.shrink();
                      return _buildNutrientChip(
                        nutrient,
                        amount,
                        accentColor: accentColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (entries.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Các món đã ăn',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: FitnessAppTheme.darkerText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entries.take(3).map((entry) {
                        final idx = entries.indexOf(entry);
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 400 + (idx * 120)),
                          builder: (context, value, child) =>
                              Opacity(opacity: value, child: child),
                          child: _buildFoodTile(entry),
                        );
                      }),
                      if (entries.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${entries.length - 3} món khác',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              color: FitnessAppTheme.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[StatisticsScreen] Error building period card: $e');
      debugPrint('[StatisticsScreen] Stack trace: $stackTrace');
      debugPrint('[StatisticsScreen] Period data: $period');
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Dữ liệu không hợp lệ',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              period['label'] ?? 'Unknown period',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                color: Colors.red.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMacroLegend(
    Map<String, dynamic> macros, {
    Color accentColor = const Color(0xFF667EEA),
  }) {
    final entries = [
      {
        'label': 'Carb',
        'value': _toDouble(macros['carbs']),
        'color': const Color(0xFFFACCCC),
      },
      {
        'label': 'Protein',
        'value': _toDouble(macros['protein']),
        'color': const Color(0xFFB9E2FF),
      },
      {
        'label': 'Fat',
        'value': _toDouble(macros['fat']),
        'color': const Color(0xFFFDD9A1),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: entries.map((item) {
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      color: FitnessAppTheme.darkerText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${_toDouble(item['value']).toStringAsFixed(1)} g',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  fontSize: 13,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutrientChip(
    Map<String, dynamic> nutrient,
    double amount, {
    Color accentColor = const Color(0xFF667EEA),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            nutrient['nutrient_name'] ?? nutrient['nutrient_code'] ?? '',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              color: FitnessAppTheme.darkerText,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${amount.toStringAsFixed(amount >= 1 ? 1 : 2)} ${nutrient['unit'] ?? ''}',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTile(Map<String, dynamic> entry) {
    final nutrients = List<Map<String, dynamic>>.from(
      entry['nutrients'] ?? const [],
    );
    final nutrientSummary = nutrients
        .take(2)
        .map((nutrient) {
          final amount = _toDouble(nutrient['amount']);
          if (amount <= 0) return '';
          return '${nutrient['nutrient_name'] ?? nutrient['nutrient_code']} '
              '${amount.toStringAsFixed(amount >= 1 ? 1 : 2)}${nutrient['unit'] ?? ''}';
        })
        .where((text) => text.isNotEmpty)
        .join(' • ');

    final DateTime? eatenAt = entry['eaten_at'] != null
        ? DateTime.tryParse(entry['eaten_at'])
        : null;
    final timeLabel = eatenAt != null
        ? DateFormat('HH:mm').format(eatenAt)
        : 'Chưa rõ giờ';

    final macros = Map<String, dynamic>.from(entry['macros'] ?? {});

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: entry['image_url'] != null
                ? Image.network(
                    entry['image_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackFoodIcon(),
                  )
                : _fallbackFoodIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['food_name_vi'] ??
                      entry['food_name'] ??
                      'Món ăn không rõ',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: FitnessAppTheme.darkerText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_toDouble(entry['weight_g']).toStringAsFixed(0)} g • $timeLabel',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 12,
                    color: FitnessAppTheme.grey,
                  ),
                ),
                if (nutrientSummary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    nutrientSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: const Color(0xFF5E60CE),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_toDouble(macros['calories']).toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: const Color(0xFF4A4E69),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_toDouble(macros['protein']).toStringAsFixed(1)} g protein',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 11,
                  color: FitnessAppTheme.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallbackFoodIcon() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFFE0E7FF),
      child: const Icon(Icons.restaurant, color: Color(0xFF667EEA)),
    );
  }

  Widget _buildAiAnalyzedMealsCard() {
    const Color accentColor = Color(0xFF667EEA);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analyzed Meals',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: FitnessAppTheme.darkerText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Phân tích bằng Gemini Vision',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 13,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_aiAnalyzedMeals.length}',
                    style: const TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _aiAnalyzedMeals.length > 5 ? 5 : _aiAnalyzedMeals.length,
              (index) => _buildAiMealItem(_aiAnalyzedMeals[index]),
            ),
            if (_aiAnalyzedMeals.length > 5) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: accentColor),
                  label: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAiMealItem(Map<String, dynamic> meal) {
    final itemName = meal['item_name'] ?? 'Unknown';
    final itemType = meal['item_type'] ?? 'food';
    final confidence = _toDouble(meal['confidence_score']);
    final nutrients = meal['nutrients'] as Map<String, dynamic>? ?? {};
    final calories = _toDouble(nutrients['enerc_kcal']);
    final protein = _toDouble(nutrients['procnt']);
    final waterMl = _toDouble(meal['water_ml']);
    final imagePath = meal['image_path'] as String?;
    final analyzedAt = meal['analyzed_at'] as String?;

    // Parse date
    String timeStr = '';
    if (analyzedAt != null) {
      try {
        final dt = DateTime.parse(analyzedAt);
        timeStr = DateFormat('HH:mm').format(dt);
      } catch (_) {}
    }

    const Color accentColor = Color(0xFF667EEA);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          // Image or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imagePath != null && imagePath.isNotEmpty
                ? Image.network(
                    '${AiAnalysisService.baseUrl}/$imagePath',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAiMealIcon(itemType);
                    },
                  )
                : _buildAiMealIcon(itemType),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: FitnessAppTheme.darkerText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timeStr.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 12,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildAiNutrientChip(
                      '${calories.toStringAsFixed(0)} kcal',
                      Icons.local_fire_department,
                    ),
                    _buildAiNutrientChip(
                      '${protein.toStringAsFixed(1)}g protein',
                      Icons.fitness_center,
                    ),
                    if (waterMl > 0)
                      _buildAiNutrientChip(
                        '${waterMl.toStringAsFixed(0)}ml',
                        Icons.water_drop,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildConfidenceBadge(confidence),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMealIcon(String itemType) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        itemType == 'drink' ? Icons.local_drink : Icons.restaurant,
        color: const Color(0xFF667EEA),
        size: 28,
      ),
    );
  }

  Widget _buildAiNutrientChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF667EEA).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF667EEA)),
          const SizedBox(width: 4),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(double confidence) {
    Color badgeColor;
    String label;
    if (confidence >= 80) {
      badgeColor = Colors.greenAccent;
      label = 'Rất chắc chắn';
    } else if (confidence >= 60) {
      badgeColor = Colors.orangeAccent;
      label = 'Khá chắc chắn';
    } else {
      badgeColor = Colors.redAccent;
      label = 'Ít chắc chắn';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            '$label (${confidence.toStringAsFixed(0)}%)',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 11,
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
