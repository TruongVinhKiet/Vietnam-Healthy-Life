// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import '../config/api_config.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  Map<String, dynamic>? settingsStats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettingsStats();
  }

  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _loadSettingsStats() async {
    setState(() => isLoading = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/settings/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          settingsStats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tùy biến ứng dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettingsStats,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettingsStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thống kê sử dụng',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // Theme Distribution
                    _buildStatsCard(
                      'Chế độ giao diện',
                      Icons.palette,
                      Colors.blue,
                      settingsStats?['theme_distribution'] ?? [],
                      (item) => item['theme'] ?? 'unknown',
                    ),

                    const SizedBox(height: 16),

                    // Language Distribution
                    _buildStatsCard(
                      'Ngôn ngữ',
                      Icons.language,
                      Colors.green,
                      settingsStats?['language_distribution'] ?? [],
                      (item) => _getLanguageName(item['language']),
                    ),

                    const SizedBox(height: 16),

                    // Seasonal UI Stats
                    _buildStatsCard(
                      'Giao diện theo mùa',
                      Icons.ac_unit,
                      Colors.orange,
                      settingsStats?['seasonal_ui_stats'] ?? [],
                      (item) => item['seasonal_ui_enabled'] == true
                          ? 'Đã bật'
                          : 'Đã tắt',
                    ),

                    const SizedBox(height: 16),

                    // Weather Stats
                    _buildStatsCard(
                      'Giao diện theo thời tiết',
                      Icons.wb_sunny,
                      Colors.amber,
                      settingsStats?['weather_stats'] ?? [],
                      (item) =>
                          item['weather_enabled'] == true ? 'Đã bật' : 'Đã tắt',
                    ),

                    const SizedBox(height: 16),

                    // Popular Cities
                    if ((settingsStats?['popular_cities'] ?? [])
                        .isNotEmpty) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_city,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Thành phố phổ biến (weather)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              ...(settingsStats!['popular_cities'] as List).map(
                                (city) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(city['weather_city'] ?? 'N/A'),
                                      Chip(
                                        label: Text(
                                          '${city['count']} người dùng',
                                        ),
                                        backgroundColor: Colors.purple[50],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Feature Management
                    Text(
                      'Quản lý tính năng',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      'Chế độ giao diện',
                      'Quản lý các chế độ: Sáng, Tối, Tự động',
                      Icons.dark_mode,
                      Colors.indigo,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng quản lý chế độ đang phát triển',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      'Ngôn ngữ',
                      'Quản lý ngôn ngữ: Tiếng Việt, English',
                      Icons.translate,
                      Colors.teal,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng quản lý ngôn ngữ đang phát triển',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      'Giao diện mùa',
                      'Tùy chỉnh hiệu ứng theo 4 mùa (lá rụng, tuyết rơi...)',
                      Icons.calendar_month,
                      Colors.green,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng quản lý giao diện mùa đang phát triển',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      'Thời tiết realtime',
                      'Cấu hình API weather và giao diện động',
                      Icons.cloud,
                      Colors.blue,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tính năng quản lý weather đang phát triển',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsCard(
    String title,
    IconData icon,
    Color color,
    List<dynamic> data,
    String Function(dynamic) labelExtractor,
  ) {
    // Helper to safely parse count (can be String or int from backend)
    int parseCount(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final total = data.fold<int>(
      0,
      (sum, item) => sum + parseCount(item['count']),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (data.isEmpty)
              const Text('Chưa có dữ liệu')
            else
              ...data.map((item) {
                final count = parseCount(item['count']);
                final percentage = total > 0 ? (count / total * 100) : 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(labelExtractor(item)),
                          Text(
                            '$count (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        color: color,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  String _getLanguageName(String? code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return code ?? 'unknown';
    }
  }
}
