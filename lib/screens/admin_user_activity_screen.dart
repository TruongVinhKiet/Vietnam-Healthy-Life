// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/admin_activity_service.dart';

class AdminUserActivityScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const AdminUserActivityScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _AdminUserActivityScreenState createState() =>
      _AdminUserActivityScreenState();
}

class _AdminUserActivityScreenState extends State<AdminUserActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  bool _isLoading = true;
  Map<String, dynamic>? _analytics;
  List<dynamic> _activityLogs = [];
  int _totalLogs = 0;
  String? _error;

  final List<String> _periods = ['24h', '7d', '30d', '90d'];
  final Map<String, String> _periodLabels = {
    '24h': '24 giờ',
    '7d': '7 ngày',
    '30d': '30 ngày',
    '90d': '90 ngày',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final analyticsResponse =
          await AdminActivityService.getUserActivityAnalytics(
            userId: widget.userId,
            period: _selectedPeriod,
          );

      final logsResponse = await AdminActivityService.getUserActivityLogs(
        userId: widget.userId,
        limit: 50,
        offset: 0,
      );

      // Debug logging
      debugPrint('Analytics Response: ${analyticsResponse.toString()}');
      debugPrint(
        'Analytics Data: ${analyticsResponse['analytics']?.toString()}',
      );

      setState(() {
        _analytics = analyticsResponse['analytics'] ?? {};
        _activityLogs = logsResponse['data'] ?? [];
        _totalLogs = logsResponse['total'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics: ${widget.userName}'),
        actions: [
          // Period selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (period) {
              setState(() => _selectedPeriod = period);
              _loadData();
            },
            itemBuilder: (context) => _periods
                .map(
                  (period) => PopupMenuItem(
                    value: period,
                    child: Row(
                      children: [
                        if (period == _selectedPeriod)
                          const Icon(Icons.check, size: 18),
                        if (period == _selectedPeriod) const SizedBox(width: 8),
                        Text(_periodLabels[period] ?? period),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Tổng quan'),
            Tab(icon: Icon(Icons.timeline), text: 'Dòng thời gian'),
            Tab(icon: Icon(Icons.pattern), text: 'Mẫu hoạt động'),
            Tab(icon: Icon(Icons.list), text: 'Nhật ký'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTimelineTab(),
                _buildPatternsTab(),
                _buildLogsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    if (_analytics == null)
      return const Center(child: Text('Đang tải dữ liệu...'));

    final totalActivities = _analytics!['totalActivities'] ?? 0;
    final engagementScore = _analytics!['engagementScore'] ?? 0;
    final actionBreakdown =
        _analytics!['actionBreakdown'] as List<dynamic>? ?? [];

    debugPrint(
      'Overview - Total: $totalActivities, Score: $engagementScore, Breakdown: $actionBreakdown',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Engagement Score Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Điểm Tương Tác',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CircularProgressIndicator(
                            value: engagementScore / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(engagementScore),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$engagementScore',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: _getScoreColor(engagementScore),
                              ),
                            ),
                            Text(
                              _getScoreLabel(engagementScore),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tổng hoạt động: $totalActivities',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Breakdown
          Text(
            'Phân Loại Hoạt Động',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (actionBreakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(actionBreakdown),
                          centerSpaceRadius: 60,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...actionBreakdown.map((item) {
                      final action = item['action'] ?? 'Unknown';
                      final count = item['count'] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getActionColor(action),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getActionLabel(action),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '$count lần',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineTab() {
    if (_analytics == null)
      return const Center(child: Text('Đang tải dữ liệu...'));

    final timeline = _analytics!['timeline'] as List<dynamic>? ?? [];
    debugPrint('Timeline data: $timeline');
    if (timeline.isEmpty) {
      return const Center(child: Text('Không có dữ liệu dòng thời gian'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoạt Động Theo Thời Gian',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < timeline.length) {
                              final bucket = timeline[value.toInt()];
                              final date = DateTime.parse(
                                bucket['time_bucket'],
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _selectedPeriod == '24h'
                                      ? DateFormat('HH:mm').format(date)
                                      : DateFormat('dd/MM').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: timeline.asMap().entries.map((e) {
                          final item = e.value;
                          final countRaw = item['count'] ?? item['count'] ?? 0;
                          final count = countRaw is int
                              ? countRaw
                              : (countRaw is num
                                    ? countRaw.toInt()
                                    : int.tryParse(countRaw.toString()) ?? 0);
                          return FlSpot(e.key.toDouble(), count.toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.1),
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

  Widget _buildPatternsTab() {
    if (_analytics == null)
      return const Center(child: Text('Đang tải dữ liệu...'));

    final hourlyPattern = _analytics!['hourlyPattern'] as List<dynamic>? ?? [];
    final weeklyPattern = _analytics!['weeklyPattern'] as List<dynamic>? ?? [];
    debugPrint('Hourly pattern: $hourlyPattern');
    debugPrint('Weekly pattern: $weeklyPattern');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hourly Pattern
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt Động Theo Giờ',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: hourlyPattern.isEmpty
                            ? 10
                            : hourlyPattern
                                      .map((e) {
                                        final countRaw = e['count'] ?? 0;
                                        return countRaw is int
                                            ? countRaw
                                            : int.tryParse(
                                                    countRaw.toString(),
                                                  ) ??
                                                  0;
                                      })
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble() *
                                  1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${value.toInt()}h',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: hourlyPattern.map((item) {
                          final countRaw = item['count'] ?? 0;
                          final count = countRaw is int
                              ? countRaw
                              : (countRaw is num
                                    ? countRaw.toInt()
                                    : int.tryParse(countRaw.toString()) ?? 0);
                          final hourRaw = item['hour'] ?? 0;
                          final hour = hourRaw is int
                              ? hourRaw
                              : (hourRaw is num
                                    ? hourRaw.toInt()
                                    : int.tryParse(hourRaw.toString()) ?? 0);
                          return BarChartGroupData(
                            x: hour,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: Colors.green,
                                width: 12,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Pattern
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt Động Theo Ngày Trong Tuần',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyPattern.isEmpty
                            ? 10
                            : weeklyPattern
                                      .map((e) {
                                        final countRaw = e['count'] ?? 0;
                                        return countRaw is int
                                            ? countRaw
                                            : int.tryParse(
                                                    countRaw.toString(),
                                                  ) ??
                                                  0;
                                      })
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble() *
                                  1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < weeklyPattern.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      weeklyPattern[value.toInt()]['day'] ?? '',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: weeklyPattern.asMap().entries.map((entry) {
                          final countRaw = entry.value['count'] ?? 0;
                          final count = countRaw is int
                              ? countRaw
                              : (countRaw is num
                                    ? countRaw.toInt()
                                    : int.tryParse(countRaw.toString()) ?? 0);
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: Colors.purple,
                                width: 20,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    if (_activityLogs.isEmpty) {
      return const Center(child: Text('Chưa có log hoạt động'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Tổng: $_totalLogs hoạt động',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _activityLogs.length,
            itemBuilder: (context, index) {
              final log = _activityLogs[index];
              final action = log['action'] ?? 'Unknown';
              final logTime = DateTime.parse(log['log_time']);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getActionColor(action),
                    child: Icon(
                      _getActionIcon(action),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(_getActionLabel(action)),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(logTime),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    List<dynamic> actionBreakdown,
  ) {
    final total = actionBreakdown.fold<int>(0, (sum, item) {
      final count = item['count'];
      final countInt = count is int
          ? count
          : int.tryParse(count.toString()) ?? 0;
      return sum + countInt;
    });

    return actionBreakdown.asMap().entries.map((entry) {
      final item = entry.value;
      final action = item['action'] ?? 'Unknown';
      final countRaw = item['count'] ?? 0;
      final count = countRaw is int
          ? countRaw
          : int.tryParse(countRaw.toString()) ?? 0;
      final percentage = total > 0 ? (count / total * 100) : 0;

      return PieChartSectionData(
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: _getActionColor(action),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 70) return 'Tốt';
    if (score >= 40) return 'Trung bình';
    return 'Cần cải thiện';
  }

  Color _getActionColor(String action) {
    final colors = {
      'login': Colors.blue,
      'logout': Colors.grey,
      'register': Colors.blueAccent,
      'password_changed': Colors.amber,
      'meal_created': Colors.green,
      'meal_entry_created': Colors.green,
      'meal_entry_updated': Colors.lightGreen,
      'meal_entry_deleted': Colors.red,
      'meal_item_deleted': Colors.red,
      'food_searched': Colors.orange,
      'profile_updated': Colors.purple,
      'settings_changed': Colors.teal,
      'water_logged': Colors.cyan,
      'water_deleted': Colors.redAccent,
      'bmr_tdee_recomputed': Colors.indigo,
      'daily_targets_recomputed': Colors.deepPurple,
      'dish_created': Colors.green,
      'dish_updated': Colors.lightGreen,
      'dish_deleted': Colors.red,
      'drink_created': Colors.blue,
      'drink_updated': Colors.lightBlue,
      'drink_deleted': Colors.red,
      'medication_taken': Colors.purple,
      'medication_deleted': Colors.red,
      'body_measurement_recorded': Colors.teal,
      'body_measurement_updated': Colors.tealAccent,
      'body_measurement_deleted': Colors.red,
      'health_condition_added': Colors.orange,
      'health_condition_removed': Colors.red,
    };
    return colors[action] ?? Colors.grey;
  }

  IconData _getActionIcon(String action) {
    final icons = {
      'login': Icons.login,
      'logout': Icons.logout,
      'register': Icons.person_add,
      'password_changed': Icons.lock,
      'meal_created': Icons.restaurant,
      'meal_entry_created': Icons.restaurant,
      'meal_entry_updated': Icons.edit,
      'meal_entry_deleted': Icons.delete,
      'meal_item_deleted': Icons.delete,
      'food_searched': Icons.search,
      'profile_updated': Icons.person,
      'settings_changed': Icons.settings,
      'water_logged': Icons.water_drop,
      'water_deleted': Icons.delete,
      'bmr_tdee_recomputed': Icons.calculate,
      'daily_targets_recomputed': Icons.track_changes,
      'dish_created': Icons.restaurant_menu,
      'dish_updated': Icons.edit,
      'dish_deleted': Icons.delete,
      'drink_created': Icons.local_drink,
      'drink_updated': Icons.edit,
      'drink_deleted': Icons.delete,
      'medication_taken': Icons.medication,
      'medication_deleted': Icons.delete,
      'body_measurement_recorded': Icons.straighten,
      'body_measurement_updated': Icons.edit,
      'body_measurement_deleted': Icons.delete,
      'health_condition_added': Icons.health_and_safety,
      'health_condition_removed': Icons.remove_circle,
    };
    return icons[action] ?? Icons.info;
  }

  String _getActionLabel(String action) {
    final labels = {
      'login': 'Đăng nhập',
      'logout': 'Đăng xuất',
      'register': 'Đăng ký tài khoản',
      'password_changed': 'Đổi mật khẩu',
      'meal_created': 'Tạo bữa ăn',
      'meal_entry_created': 'Thêm món vào bữa ăn',
      'meal_entry_updated': 'Cập nhật món ăn',
      'meal_entry_deleted': 'Xóa món ăn',
      'meal_item_deleted': 'Xóa món khỏi bữa ăn',
      'food_searched': 'Tìm kiếm thực phẩm',
      'profile_updated': 'Cập nhật hồ sơ',
      'settings_changed': 'Thay đổi cài đặt',
      'water_logged': 'Ghi nước uống',
      'water_deleted': 'Xóa ghi chép nước',
      'bmr_tdee_recomputed': 'Tính lại BMR/TDEE',
      'daily_targets_recomputed': 'Tính lại chỉ tiêu',
      'dish_created': 'Tạo món ăn',
      'dish_updated': 'Cập nhật món ăn',
      'dish_deleted': 'Xóa món ăn',
      'drink_created': 'Tạo đồ uống',
      'drink_updated': 'Cập nhật đồ uống',
      'drink_deleted': 'Xóa đồ uống',
      'medication_taken': 'Ghi nhận uống thuốc',
      'medication_deleted': 'Xóa ghi chép thuốc',
      'body_measurement_recorded': 'Ghi nhận đo cơ thể',
      'body_measurement_updated': 'Cập nhật đo cơ thể',
      'body_measurement_deleted': 'Xóa đo cơ thể',
      'health_condition_added': 'Thêm tình trạng sức khỏe',
      'health_condition_removed': 'Xóa tình trạng sức khỏe',
    };
    return labels[action] ?? action;
  }
}
