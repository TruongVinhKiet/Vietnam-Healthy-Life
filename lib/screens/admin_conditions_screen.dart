// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import '../config/api_config.dart';

class AdminConditionsScreen extends StatefulWidget {
  const AdminConditionsScreen({super.key});

  @override
  State<AdminConditionsScreen> createState() => _AdminConditionsScreenState();
}

class _AdminConditionsScreenState extends State<AdminConditionsScreen> {
  List<String> conditions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _loadConditions() async {
    setState(() => isLoading = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/conditions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          conditions = List<String>.from(data['conditions'] ?? []);
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

  Future<void> _showConditionDetails(String conditionName) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/conditions/${Uri.encodeComponent(conditionName)}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => _ConditionDetailsDialog(conditionData: data),
          );
        }
      }
    } catch (e) {
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
      appBar: AppBar(title: const Text('Quản lý bệnh')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conditions.isEmpty
          ? const Center(child: Text('Không có bệnh nào trong hệ thống'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: conditions.length,
              itemBuilder: (context, index) {
                final condition = conditions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.health_and_safety, color: Colors.white),
                    ),
                    title: Text(
                      condition,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showConditionDetails(condition),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng thêm bệnh mới đang phát triển'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ConditionDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> conditionData;

  const _ConditionDetailsDialog({required this.conditionData});

  @override
  Widget build(BuildContext context) {
    final conditionName = conditionData['condition_name'] ?? 'N/A';
    final nutrientEffects = conditionData['nutrient_effects'] ?? [];
    final recommendedFoods = conditionData['recommended_foods'] ?? [];
    final avoidFoods = conditionData['foods_to_avoid'] ?? [];

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title: Text(conditionName),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nutrient Effects Section
                    if (nutrientEffects.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Ảnh hưởng chất dinh dưỡng',
                        Icons.science,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      ...nutrientEffects.map((effect) {
                        final isIncrease = effect['effect_type'] == 'increase';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: Icon(
                              isIncrease
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: isIncrease ? Colors.green : Colors.red,
                            ),
                            title: Text(effect['nutrient_name'] ?? 'N/A'),
                            subtitle: Text(
                              effect['impact_note'] ?? '',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Text(
                              '${isIncrease ? '+' : ''}${effect['impact_percent'] ?? 0}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncrease ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 32),
                    ],

                    // Recommended Foods Section
                    if (recommendedFoods.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Thực phẩm nên dùng',
                        Icons.recommend,
                        Colors.green,
                      ),
                      const SizedBox(height: 8),
                      ...recommendedFoods.map(
                        (food) => Card(
                          color: Colors.green[50],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            title: Text(food['food_name'] ?? 'N/A'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food['category'] ?? ''),
                                if (food['note'] != null &&
                                    food['note'].toString().isNotEmpty)
                                  Text(
                                    food['note'],
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 32),
                    ],

                    // Foods to Avoid Section
                    if (avoidFoods.isNotEmpty) ...[
                      _buildSectionHeader(
                        'Thực phẩm cần tránh',
                        Icons.block,
                        Colors.red,
                      ),
                      const SizedBox(height: 8),
                      ...avoidFoods.map(
                        (food) => Card(
                          color: Colors.red[50],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            title: Text(food['food_name'] ?? 'N/A'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(food['category'] ?? ''),
                                if (food['note'] != null &&
                                    food['note'].toString().isNotEmpty)
                                  Text(
                                    food['note'],
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (nutrientEffects.isEmpty &&
                        recommendedFoods.isEmpty &&
                        avoidFoods.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Chưa có thông tin chi tiết cho bệnh này',
                          ),
                        ),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
