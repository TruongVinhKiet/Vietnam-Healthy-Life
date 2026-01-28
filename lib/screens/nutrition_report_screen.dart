import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import '../fitness_app_theme.dart';
import '../services/nutrient_tracking_service.dart';
import '../widgets/profile_provider.dart';
import 'package:path_provider/path_provider.dart';

class NutritionReportScreen extends StatefulWidget {
  const NutritionReportScreen({super.key});

  @override
  State<NutritionReportScreen> createState() => _NutritionReportScreenState();
}

class _NutritionReportScreenState extends State<NutritionReportScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _report;
  final GlobalKey _reportKey = GlobalKey();
  late TabController _tabController;

  // Modern pastel color palette (Basic tab)
  static const Color _mintGreen = Color(0xFF7FD8BE);
  static const Color _freshGreen = Color(0xFF4ECDC4);
  static const Color _warmOrange = Color(0xFFFFB347);
  static const Color _lightGray = Color(0xFFF5F5F5);
  static const Color _softGray = Color(0xFFE8E8E8);

  // Professional Medical color palette
  static const Color _clinicalBlueGreen = Color(0xFF2C7A7B);
  static const Color _darkTeal = Color(0xFF1A5F5F);
  static const Color _slateGray = Color(0xFF475569);
  static const Color _deficientGray = Color(0xFFE2E8F0);
  static const Color _optimalGreen = Color(0xFF86EFAC);
  static const Color _excessiveRed = Color(0xFFFCA5A5);
  static const Color _baselineGray = Color(0xFFCBD5E1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await NutrientTrackingService.getComprehensiveReport();
      if (!mounted) return;
      setState(() {
        _report = data;
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

  /// Detailed nutrient rows (vitamin, mineral, amino, fiber, fatty_acid, ...)
  List<dynamic> get _nutrients =>
      _report?['intake'] as List<dynamic>? ?? const [];

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, dd MMMM yyyy', 'vi').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: FitnessAppTheme.darkerText),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Báo cáo dinh dưỡng',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: FitnessAppTheme.darkerText,
              ),
            ),
            Text(
              today,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 12,
                color: FitnessAppTheme.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
            tooltip: 'Làm mới',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: FitnessAppTheme.darkerText,
          unselectedLabelColor: FitnessAppTheme.grey,
          indicatorColor: _freshGreen,
          labelStyle: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Cơ bản'),
            Tab(text: 'Chuyên nghiệp chuẩn y khoa'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : RepaintBoundary(
              key: _reportKey,
              child: TabBarView(
                controller: _tabController,
                children: [_buildBasicTab(), _buildProfessionalTab()],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: _tabController.index == 0
                    ? _freshGreen
                    : _clinicalBlueGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              onPressed: _exportReport,
              icon: const Icon(Icons.download),
              label: const Text('Tải báo cáo về máy'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicTab() {
    return Container(
      color: _lightGray,
      child: RefreshIndicator(
        onRefresh: _loadReport,
        color: _freshGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: [
            _buildDailyProgressChart(),
            const SizedBox(height: 24),
            _buildWaterSection(),
            const SizedBox(height: 16),
            _buildGroupSection(
              title: 'Vitamin',
              icon: Icons.local_pharmacy_outlined,
              type: 'vitamin',
            ),
            const SizedBox(height: 16),
            _buildGroupSection(
              title: 'Khoáng chất (Minerals)',
              icon: Icons.grain_outlined,
              type: 'mineral',
            ),
            const SizedBox(height: 16),
            _buildGroupSection(
              title: 'Amino acids',
              icon: Icons.biotech_outlined,
              type: 'amino_acid',
            ),
            const SizedBox(height: 16),
            _buildGroupSection(
              title: 'Chất xơ (Fiber)',
              icon: Icons.eco_outlined,
              type: 'fiber',
            ),
            const SizedBox(height: 16),
            _buildGroupSection(
              title: 'Chất béo (Fatty acids)',
              icon: Icons.water_drop_outlined,
              type: 'fatty_acid',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalTab() {
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: _loadReport,
        color: _clinicalBlueGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            _buildRadarChart(),
            const SizedBox(height: 32),
            _buildDetailedMetrics(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Build Radar Chart (Spider Chart) with 8 nutrient groups
  Widget _buildRadarChart() {
    // Calculate average percentage for each nutrient group
    final groups = <String, double>{};

    // Group nutrients
    final macros = _nutrients
        .where(
          (n) => ['calories', 'protein', 'fat', 'carbs'].any(
            (code) =>
                (n['nutrient_code']?.toString().toLowerCase() ?? '').contains(
                  code,
                ) ||
                (n['nutrient_name']?.toString().toLowerCase() ?? '').contains(
                  code,
                ),
          ),
        )
        .toList();

    final electrolytes = _nutrients
        .where(
          (n) =>
              ['sodium', 'potassium', 'chloride', 'magnesium', 'calcium'].any(
                (name) => (n['nutrient_name']?.toString().toLowerCase() ?? '')
                    .contains(name),
              ),
        )
        .toList();

    final bVitamins = _nutrients
        .where(
          (n) =>
              (n['nutrient_type']?.toString() ?? '') == 'vitamin' &&
              (n['nutrient_code']?.toString().toUpperCase() ?? '').contains(
                'B',
              ),
        )
        .toList();

    final fatSolubleVitamins = _nutrients
        .where(
          (n) =>
              (n['nutrient_type']?.toString() ?? '') == 'vitamin' &&
              ['A', 'D', 'E', 'K'].any(
                (v) => (n['nutrient_code']?.toString().toUpperCase() ?? '')
                    .contains(v),
              ),
        )
        .toList();

    final traceMinerals = _nutrients
        .where(
          (n) =>
              (n['nutrient_type']?.toString() ?? '') == 'mineral' &&
              ['zinc', 'iron', 'copper', 'manganese', 'selenium', 'iodine'].any(
                (name) => (n['nutrient_name']?.toString().toLowerCase() ?? '')
                    .contains(name),
              ),
        )
        .toList();

    final fiber = _nutrients
        .where((n) => (n['nutrient_type']?.toString() ?? '') == 'fiber')
        .toList();

    final aminoAcids = _nutrients
        .where((n) => (n['nutrient_type']?.toString() ?? '') == 'amino_acid')
        .toList();

    final fattyAcids = _nutrients
        .where((n) => (n['nutrient_type']?.toString() ?? '') == 'fatty_acid')
        .toList();

    // Calculate average percentage for each group
    double avgPct(List<dynamic> items) {
      if (items.isEmpty) return 0.0;
      final sum = items.fold<double>(
        0.0,
        (sum, n) => sum + _num(n['percentage']),
      );
      return (sum / items.length).clamp(0.0, 200.0);
    }

    groups['Macros'] = avgPct(macros);
    groups['Electrolytes'] = avgPct(electrolytes);
    groups['B-Vitamins'] = avgPct(bVitamins);
    groups['Fat-soluble\nVitamins'] = avgPct(fatSolubleVitamins);
    groups['Trace\nMinerals'] = avgPct(traceMinerals);
    groups['Fiber'] = avgPct(fiber);
    groups['Amino\nAcids'] = avgPct(aminoAcids);
    groups['Fatty\nAcids'] = avgPct(fattyAcids);

    final groupNames = groups.keys.toList();
    final values = groups.values.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Cân bằng dinh dưỡng',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _slateGray,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Show medical info dialog
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _clinicalBlueGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: _clinicalBlueGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Baseline WHO 100%',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              color: _slateGray.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 320,
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                radarBorderData: BorderSide(color: _baselineGray, width: 2),
                tickBorderData: BorderSide(color: _baselineGray, width: 1),
                gridBorderData: BorderSide(color: _baselineGray, width: 1),
                titlePositionPercentageOffset: 0.15,
                tickCount: 5,
                ticksTextStyle: TextStyle(
                  color: _slateGray.withValues(alpha: 0.6),
                  fontSize: 9,
                ),
                radarBackgroundColor: Colors.transparent,
                titleTextStyle: TextStyle(
                  color: _slateGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: groupNames[index],
                    angle: angle,
                    positionPercentageOffset: 0.15,
                  );
                },
                dataSets: [
                  // Baseline 100% (light gray octagon)
                  RadarDataSet(
                    fillColor: Colors.transparent,
                    borderColor: _baselineGray,
                    borderWidth: 2,
                    dataEntries: List.generate(
                      8,
                      (_) => const RadarEntry(value: 100),
                    ),
                  ),
                  // Current intake (mint green polygon)
                  RadarDataSet(
                    fillColor: _mintGreen.withValues(alpha: 0.3),
                    borderColor: _clinicalBlueGreen,
                    borderWidth: 2.5,
                    dataEntries: values.map((value) {
                      // Normalize to 0-200 scale (percentage)
                      return RadarEntry(value: value.clamp(0.0, 200.0));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build detailed precision metrics with Scientific Bullet Graphs
  Widget _buildDetailedMetrics() {
    // Sort nutrients by percentage for better visualization
    final sortedNutrients = List<Map<String, dynamic>>.from(_nutrients);
    sortedNutrients.sort((a, b) {
      final pctA = _num(a['percentage']); // Use real percentage for sorting
      final pctB = _num(b['percentage']);
      return pctB.compareTo(pctA);
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Chỉ số chi tiết',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _slateGray,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Show medical info dialog
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _clinicalBlueGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: _clinicalBlueGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...sortedNutrients.take(20).map((n) {
            final name = n['nutrient_name'] ?? n['code'] ?? '';
            final unit = n['unit'] ?? '';
            final current = _num(n['current_amount']);
            final target = _num(n['target_amount']);
            // Calculate REAL percentage (unclamped) for text display
            final realPct = target > 0 ? (current / target * 100) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildScientificBulletGraph(
                name: name.toString(),
                current: current,
                target: target,
                unit: unit,
                percentage: realPct, // Pass real percentage (unclamped)
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build Scientific Bullet Graph with 3 medical zones
  Widget _buildScientificBulletGraph({
    required String name,
    required double current,
    required double target,
    required String unit,
    required double percentage, // Real percentage (unclamped)
  }) {
    // Calculate positions (0-200% range for visual bar)
    final maxValue = target * 2.0; // 200% of target for visual scale
    final clampedPct = percentage.clamp(0.0, 200.0); // Clamp for visual only
    final clampedCurrent = (target * clampedPct / 100).clamp(0.0, maxValue);
    final currentPosition = (clampedCurrent / maxValue).clamp(
      0.0,
      1.2,
    ); // Allow slight overflow visual
    final targetPosition = (target / maxValue).clamp(0.0, 1.0);

    // Determine color based on percentage ranges
    Color indicatorColor;
    Color badgeColor;
    bool showOverflowArrow = false;

    if (percentage <= 120) {
      // Normal range (0-120%): Dark Teal
      indicatorColor = _darkTeal;
      badgeColor = _clinicalBlueGreen;
    } else if (percentage <= 200) {
      // High range (120-200%): Warning Orange
      indicatorColor = _warmOrange;
      badgeColor = _warmOrange;
    } else if (percentage <= 300) {
      // Extreme range (200-300%): Danger Red
      indicatorColor = Colors.red.shade700;
      badgeColor = Colors.red.shade700;
      showOverflowArrow = true;
    } else {
      // Toxic/Overflow (>300%): Deep Purple/Dark Red
      indicatorColor = Colors.purple.shade900;
      badgeColor = Colors.purple.shade900;
      showOverflowArrow = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scientific data label (Roboto Mono font)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$name: ${current.toStringAsFixed(1)}$unit / ${target.toStringAsFixed(1)}$unit',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _slateGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(0)}%', // Show REAL percentage
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                  if (showOverflowArrow) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 12, color: badgeColor),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Bullet graph
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final visualPosition = currentPosition.clamp(
              0.0,
              1.0,
            ); // Clamp visual bar to fit UI
            final isOverflow = currentPosition > 1.0;

            return SizedBox(
              height: 24,
              child: Stack(
                children: [
                  // Background with 3 zones
                  Row(
                    children: [
                      // Deficient zone (0-80%)
                      Expanded(
                        flex: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _deficientGray,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              bottomLeft: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Optimal zone (80-120%)
                      Expanded(
                        flex: 20,
                        child: Container(
                          color: _optimalGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      // Excessive zone (>120%)
                      Expanded(
                        flex: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _excessiveRed.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Actual intake indicator (color changes based on percentage)
                  Positioned(
                    left: barWidth * visualPosition,
                    child: Stack(
                      children: [
                        Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            color: indicatorColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Overflow arrow indicator
                        if (isOverflow)
                          Positioned(
                            right: -8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: indicatorColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 100% Target tick mark (bold vertical black line)
                  Positioned(
                    left: barWidth * targetPosition,
                    child: Container(width: 2, height: 24, color: Colors.black),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              'Không thể tải báo cáo',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                color: FitnessAppTheme.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build cumulative area chart showing nutrient intake over time (6 AM - 10 PM)
  Widget _buildDailyProgressChart() {
    final profile = context.maybeProfile();
    final raw = profile?.raw ?? const <String, dynamic>{};

    final kcal = _num(raw['today_calories']);
    final kcalTarget = profile?.dailyCalorieTarget ?? 2000.0;
    final protein = _num(raw['today_protein']);
    final proteinTarget = profile?.dailyProteinTarget ?? 140.0;
    final carbs = _num(raw['today_carbs']);
    final carbsTarget = profile?.dailyCarbTarget ?? 280.0;
    final fat = _num(raw['today_fat']);
    final fatTarget = profile?.dailyFatTarget ?? 62.0;

    // Calculate overall progress percentage (weighted average)
    final kcalPct = kcalTarget > 0
        ? (kcal / kcalTarget * 100).clamp(0.0, 100.0)
        : 0.0;
    final proteinPct = proteinTarget > 0
        ? (protein / proteinTarget * 100).clamp(0.0, 100.0)
        : 0.0;
    final carbsPct = carbsTarget > 0
        ? (carbs / carbsTarget * 100).clamp(0.0, 100.0)
        : 0.0;
    final fatPct = fatTarget > 0
        ? (fat / fatTarget * 100).clamp(0.0, 100.0)
        : 0.0;

    // Weighted average: calories 50%, protein 20%, carbs 20%, fat 10%
    final overallProgress =
        (kcalPct * 0.5 + proteinPct * 0.2 + carbsPct * 0.2 + fatPct * 0.1)
            .clamp(0.0, 100.0);

    // Generate hourly data points (6 AM = 6, 10 PM = 22)
    final now = DateTime.now();
    final currentHour = now.hour;
    final spots = <FlSpot>[];

    for (int hour = 6; hour <= 22; hour++) {
      double progress = 0.0;
      if (hour < currentHour) {
        progress = overallProgress * (hour - 6) / (currentHour - 6);
      } else if (hour == currentHour) {
        progress = overallProgress;
      } else {
        progress = overallProgress;
      }
      spots.add(FlSpot((hour - 6).toDouble(), progress.clamp(0.0, 100.0)));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiến độ hôm nay',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: FitnessAppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng hợp dinh dưỡng theo thời gian',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 13,
              color: FitnessAppTheme.grey,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: _softGray,
                    strokeWidth: 1,
                    dashArray: value == 100 ? [5, 5] : null,
                  ),
                ),
                minY: 0,
                maxY: 100,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: FitnessAppTheme.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        final hour = (value.toInt() + 6);
                        if (hour % 4 == 0 && hour <= 22) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '$hour:00',
                              style: TextStyle(
                                fontSize: 10,
                                color: FitnessAppTheme.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    barWidth: 3,
                    color: _freshGreen,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _mintGreen.withValues(alpha: 0.4),
                          _mintGreen.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildModernChip('Kcal', kcal, kcalTarget, 'kcal'),
              _buildModernChip('Protein', protein, proteinTarget, 'g'),
              _buildModernChip('Carb', carbs, carbsTarget, 'g'),
              _buildModernChip('Fat', fat, fatTarget, 'g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernChip(
    String label,
    double current,
    double target,
    String unit,
  ) {
    final pct = target > 0 ? (current / target * 100).clamp(0.0, 100.0) : 0.0;
    final color = pct >= 100 ? _freshGreen : _mintGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 11,
              color: FitnessAppTheme.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)} $unit',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: FitnessAppTheme.darkerText,
            ),
          ),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSection({
    required String title,
    required IconData icon,
    required String type,
  }) {
    final items = _nutrients
        .where((n) => (n['nutrient_type']?.toString() ?? '') == type)
        .toList();

    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _softGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: FitnessAppTheme.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$title • Chưa có dữ liệu cho hôm nay',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 13,
                  color: FitnessAppTheme.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _mintGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _freshGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: FitnessAppTheme.darkerText,
                      ),
                    ),
                    Text(
                      '${items.length} chất • % so với khuyến nghị',
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
          const SizedBox(height: 20),
          ...items.take(10).map((n) {
            final name = n['nutrient_name'] ?? n['code'] ?? '';
            final pct = _num(n['percentage']).clamp(0.0, 200.0);
            final unit = n['unit'] ?? '';
            final current = _num(n['current_amount']);
            final target = _num(n['target_amount']);

            final barColor = pct <= 100 ? _freshGreen : _warmOrange;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBulletChart(
                name: name.toString(),
                current: current,
                target: target,
                unit: unit,
                percentage: pct,
                color: barColor,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build horizontal rounded progress bar (Bullet Chart) for Basic tab
  Widget _buildBulletChart({
    required String name,
    required double current,
    required double target,
    required String unit,
    required double percentage,
    required Color color,
  }) {
    final progress = (percentage / 100).clamp(0.0, 2.0);
    final displayProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FitnessAppTheme.darkerText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${current.toStringAsFixed(1)}/${target.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 12,
                color: FitnessAppTheme.grey,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: _softGray,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: displayProgress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (progress > 1.0)
                Positioned(
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _warmOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaterSection() {
    final profile = context.maybeProfile();
    final raw = profile?.raw ?? const <String, dynamic>{};

    final water = _num(raw['today_water']);
    final waterTarget = _num(raw['daily_water_target']);
    final pct = NutrientTrackingService.calculateProgress(water, waterTarget);
    final color = pct <= 100 ? _freshGreen : _warmOrange;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.water_drop_outlined, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nước uống hôm nay',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: FitnessAppTheme.darkerText,
                      ),
                    ),
                    Text(
                      'So sánh với mục tiêu nước mỗi ngày',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 12,
                        color: FitnessAppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${water.toStringAsFixed(0)} / ${waterTarget.toStringAsFixed(0)} ml',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: FitnessAppTheme.darkerText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: _softGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (pct / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  Future<void> _exportReport() async {
    try {
      final boundary =
          _reportKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'nutrition_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu báo cáo PNG tại: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể xuất báo cáo: $e')));
    }
  }
}
