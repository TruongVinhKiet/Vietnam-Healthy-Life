import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import '../../services/drink_service.dart';
import '../../fitness_app_theme.dart';

class WebAdminDashboard extends StatefulWidget {
  const WebAdminDashboard({super.key});

  @override
  State<WebAdminDashboard> createState() => _WebAdminDashboardState();
}

class _WebAdminDashboardState extends State<WebAdminDashboard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? stats;
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> categoryData = {};
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _loadAllData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => isLoading = true);
    await Future.wait<void>([
      _loadStats(),
      _loadFoodCategories(),
      _loadDishCategories(),
      _loadDrinkCategories(),
      _loadNutrientCategories(),
      _loadHealthConditionCategories(),
      _loadDrugCategories(),
    ]);
    if (mounted) {
      setState(() => isLoading = false);
      _controller.forward();
    }
  }

  Future<void> _loadStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/dashboard/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _loadFoodCategories() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await _loadAndGroupCategories(
      uri: Uri.parse('${ApiConfig.baseUrl}/admin/foods?page=1&limit=500'),
      listKey: 'foods',
      categoryKeyCandidates: const ['category'],
      resultKey: 'foods',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> _loadDishCategories() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await _loadAndGroupCategories(
      uri: Uri.parse('${ApiConfig.baseUrl}/dishes/admin/all'),
      listKey: 'data',
      categoryKeyCandidates: const ['category'],
      resultKey: 'dishes',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> _loadDrinkCategories() async {
    final drinks = await DrinkService.adminFetchDrinks();
    final grouped = _groupByCategory(
      drinks,
      categoryKeyCandidates: const ['category', 'drink_type'],
    );
    setState(() => categoryData['drinks'] = grouped);
  }

  Future<void> _loadNutrientCategories() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await _loadAndGroupCategories(
      uri: Uri.parse('${ApiConfig.baseUrl}/admin/nutrients?limit=500'),
      listKey: 'nutrients',
      categoryKeyCandidates: const ['category', 'type', 'group'],
      resultKey: 'nutrients',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> _loadHealthConditionCategories() async {
    await _loadAndGroupCategories(
      uri: Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
      listKey: 'conditions',
      categoryKeyCandidates: const ['category'],
      resultKey: 'health_conditions',
    );
  }

  Future<void> _loadDrugCategories() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    await _loadAndGroupCategories(
      uri: Uri.parse('${ApiConfig.baseUrl}/api/medications/admin?page=1&limit=500'),
      listKey: 'drugs',
      categoryKeyCandidates: const ['drug_class', 'category', 'drug_type'],
      resultKey: 'drugs',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> _loadAndGroupCategories({
    required Uri uri,
    required String listKey,
    required List<String> categoryKeyCandidates,
    required String resultKey,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = List<Map<String, dynamic>>.from(
          data[listKey] ?? (data is List ? data : []),
        );
        final grouped = _groupByCategory(
          list,
          categoryKeyCandidates: categoryKeyCandidates,
        );
        setState(() => categoryData[resultKey] = grouped);
      } else {
        setState(() => categoryData[resultKey] = []);
      }
    } catch (_) {
      setState(() => categoryData[resultKey] = []);
    }
  }

  List<Map<String, dynamic>> _groupByCategory(
    List<Map<String, dynamic>> items, {
    required List<String> categoryKeyCandidates,
  }) {
    final map = <String, int>{};
    for (final item in items) {
      String category = 'Khác';
      for (final key in categoryKeyCandidates) {
        final value = item[key];
        if (value != null && value.toString().isNotEmpty) {
          category = value.toString();
          break;
        }
      }
      map[category] = (map[category] ?? 0) + 1;
    }
    // Giới hạn số lượng category hiển thị để tránh quá chật chội,
    // các category còn lại sẽ gộp vào "Khác".
    final sortedEntries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const maxCategories = 11; // 11 category + 1 "Khác" nếu cần
    if (sortedEntries.length <= maxCategories) {
      return sortedEntries
          .map((e) => {'category': e.key, 'count': e.value})
          .toList();
    }

    final mainEntries = sortedEntries.take(maxCategories).toList();
    final otherCount =
        sortedEntries.skip(maxCategories).fold<int>(0, (sum, e) => sum + e.value);

    return [
      ...mainEntries.map((e) => {'category': e.key, 'count': e.value}),
      {'category': 'Khác', 'count': otherCount},
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || stats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Bar Chart - Thống kê số lượng
          _buildQuantityBarChart(),
          const SizedBox(height: 24),

          // Category Pie Charts - Row 1
          _buildCategoryChartsRow([
            {'title': 'Thực phẩm', 'key': 'foods', 'color': Colors.green},
            {'title': 'Món ăn', 'key': 'dishes', 'color': Colors.teal},
          ]),
          const SizedBox(height: 24),

          // Category Pie Charts - Row 2
          _buildCategoryChartsRow([
            {'title': 'Đồ uống', 'key': 'drinks', 'color': Colors.cyan},
            {
              'title': 'Chất dinh dưỡng',
              'key': 'nutrients',
              'color': Colors.orange
            },
          ]),
          const SizedBox(height: 24),

          // Category Pie Charts - Row 3
          _buildCategoryChartsRow([
            {
              'title': 'Bệnh lý',
              'key': 'health_conditions',
              'color': Colors.red
            },
            {'title': 'Thuốc', 'key': 'drugs', 'color': Colors.purple},
          ]),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final statItems = [
      {
        'title': 'Tổng người dùng',
        'value': stats!['total_users'] ?? 0,
        'icon': Icons.people_alt_rounded,
        'color': Colors.teal.shade600,
        'gradient': [Colors.teal.shade400, Colors.teal.shade600],
      },
      {
        'title': 'Thực phẩm',
        'value': stats!['total_foods'] ?? 0,
        'icon': Icons.eco_rounded,
        'color': Colors.green.shade600,
        'gradient': [Colors.green.shade400, Colors.green.shade600],
      },
      {
        'title': 'Món ăn',
        'value': stats!['total_dishes'] ?? 0,
        'icon': Icons.restaurant_rounded,
        'color': Colors.lightGreen.shade600,
        'gradient': [Colors.lightGreen.shade400, Colors.lightGreen.shade600],
      },
      {
        'title': 'Đồ uống',
        'value': stats!['total_drinks'] ?? 0,
        'icon': Icons.local_cafe_rounded,
        'color': Colors.cyan.shade600,
        'gradient': [Colors.cyan.shade400, Colors.cyan.shade600],
      },
      {
        'title': 'Chất dinh dưỡng',
        'value': stats!['total_nutrients'] ?? 0,
        'icon': Icons.auto_awesome_rounded,
        'color': Colors.amber.shade600,
        'gradient': [Colors.amber.shade400, Colors.amber.shade600],
      },
      {
        'title': 'Bệnh lý',
        'value': stats!['total_health_conditions'] ?? 0,
        'icon': Icons.favorite_rounded,
        'color': Colors.pink.shade400,
        'gradient': [Colors.pink.shade300, Colors.pink.shade500],
      },
      {
        'title': 'Thuốc',
        'value': stats!['total_drugs'] ?? 0,
        'icon': Icons.medical_services_rounded,
        'color': Colors.deepPurple.shade400,
        'gradient': [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
      },
      {
        'title': 'Hoạt động hôm nay',
        'value': stats!['today_meals'] ?? 0,
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.orange.shade600,
        'gradient': [Colors.orange.shade400, Colors.orange.shade600],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return FadeTransition(
          opacity: _fadeAnimation,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: item['gradient'] as List<Color>,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (item['color'] as Color).withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {},
                        splashColor: Colors.white.withValues(alpha: 0.1),
                        highlightColor: Colors.white.withValues(alpha: 0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item['value'].toString(),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.0,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontSize: 13,
                                        color: Colors.white
                                            .withValues(alpha: 0.95),
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuantityBarChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê số lượng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            'Người dùng',
                            'Thực phẩm',
                            'Món ăn',
                            'Đồ uống',
                            'Chất DD',
                            'Bệnh lý',
                            'Thuốc',
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_users'] ?? 0).toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_foods'] ?? 0).toDouble(),
                          color: Colors.green,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_dishes'] ?? 0).toDouble(),
                          color: Colors.teal,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_drinks'] ?? 0).toDouble(),
                          color: Colors.cyan,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_nutrients'] ?? 0).toDouble(),
                          color: Colors.orange,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 5,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_health_conditions'] ?? 0)
                              .toDouble(),
                          color: Colors.red,
                          width: 20,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 6,
                      barRods: [
                        BarChartRodData(
                          toY: (stats!['total_drugs'] ?? 0).toDouble(),
                          color: Colors.purple,
                          width: 20,
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
    );
  }

  Widget _buildCategoryChartsRow(List<Map<String, dynamic>> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildCategoryPieChart(
              item['title'] as String,
              item['key'] as String,
              item['color'] as Color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryPieChart(String title, String key, Color color) {
    final data = categoryData[key] ?? [];
    final total = data.fold<int>(
      0,
      (sum, item) => sum + ((item['count'] ?? 0) as int),
    );

    if (total == 0 || data.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Chưa có dữ liệu'),
            ],
          ),
        ),
      );
    }

    // Define a list of unique colors for chart segments
    final List<Color> uniqueColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.amber,
      Colors.pink,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.lime,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.yellow,
      Colors.grey,
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 260,
              child: Row(
                children: [
                  // Biểu đồ tròn
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        // Không vẽ text bên trong để tránh rối, chỉ dùng legend bên phải
                        sections: data.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final count = (item['count'] ?? 0) as int;
                          return PieChartSectionData(
                            value: count.toDouble(),
                            title: '',
                            color: uniqueColors[index % uniqueColors.length],
                            radius: 60,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  // Legend cuộn dọc để không bị overflow
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          final category = item['category'] ?? 'Khác';
                          final count = (item['count'] ?? 0) as int;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        uniqueColors[index % uniqueColors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    category,
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
