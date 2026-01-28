import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';

import '../config/api_config.dart';

class AdminDishDetailScreen extends StatefulWidget {
  final int dishId;

  const AdminDishDetailScreen({super.key, required this.dishId});

  @override
  State<AdminDishDetailScreen> createState() => _AdminDishDetailScreenState();
}

class _AdminDishDetailScreenState extends State<AdminDishDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dish;
  List<dynamic> _nutrients = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Chưa đăng nhập';
          _isLoading = false;
        });
        return;
      }

      final dishRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/${widget.dishId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (dishRes.statusCode != 200) {
        setState(() {
          _error = 'Không thể tải chi tiết món ăn (HTTP ${dishRes.statusCode})';
          _isLoading = false;
        });
        return;
      }

      final dishBody = dishRes.body.isNotEmpty ? json.decode(dishRes.body) : {};
      final dishData = dishBody is Map ? dishBody['data'] : null;
      if (dishData is! Map) {
        setState(() {
          _error = 'Dữ liệu món ăn không hợp lệ';
          _isLoading = false;
        });
        return;
      }

      final nutrientsRes = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/dishes/admin/${widget.dishId}/nutrients',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<dynamic> nutrients = [];
      if (nutrientsRes.statusCode == 200) {
        final nutrientsBody = nutrientsRes.body.isNotEmpty
            ? json.decode(nutrientsRes.body)
            : {};
        if (nutrientsBody is Map) {
          nutrients = nutrientsBody['data'] ?? [];
        }
      }

      setState(() {
        _dish = Map<String, dynamic>.from(dishData);
        _nutrients = nutrients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dish = _dish;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết món ăn'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!),
              ),
            )
          : dish == null
          ? const Center(child: Text('Không tìm thấy món ăn'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (dish['vietnamese_name'] ?? dish['name'] ?? '')
                                .toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (dish['category'] != null)
                                _buildChip(
                                  label: dish['category'].toString(),
                                  color: Colors.blue,
                                ),
                              _buildChip(
                                label: dish['is_public'] == true
                                    ? 'Public'
                                    : 'Pending',
                                color: dish['is_public'] == true
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              _buildChip(
                                label: dish['is_template'] == true
                                    ? 'Mẫu'
                                    : 'User',
                                color: dish['is_template'] == true
                                    ? Colors.purple
                                    : Colors.teal,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if ((dish['description'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                            Text(
                              dish['description'].toString(),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIngredientsCard(dish['ingredients']),
                  const SizedBox(height: 12),
                  _buildNutrientsCard(_nutrients),
                ],
              ),
            ),
    );
  }

  Widget _buildIngredientsCard(dynamic ingredientsRaw) {
    final ingredients = ingredientsRaw is List ? ingredientsRaw : const [];

    return Card(
      child: ExpansionTile(
        title: Text('Nguyên liệu (${ingredients.length})'),
        children: ingredients.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Không có nguyên liệu'),
                ),
              ]
            : ingredients.map<Widget>((ing) {
                final m = ing is Map ? ing : const {};
                final name = (m['food_name'] ?? m['name'] ?? '').toString();
                final weight = m['weight_g']?.toString() ?? '';
                final notes = (m['notes'] ?? '').toString();
                return ListTile(
                  title: Text(
                    name.isNotEmpty ? name : 'N/A',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: notes.trim().isEmpty
                      ? null
                      : Text(
                          notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: weight.isEmpty ? null : Text('${weight}g'),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildNutrientsCard(List<dynamic> nutrients) {
    return Card(
      child: ExpansionTile(
        title: Text('Dinh dưỡng (${nutrients.length})'),
        children: nutrients.isEmpty
            ? const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Không có dữ liệu dinh dưỡng'),
                ),
              ]
            : nutrients.map<Widget>((n) {
                final m = n is Map ? n : const {};
                final name = (m['nutrient_name'] ?? m['name'] ?? '').toString();
                final code = (m['nutrient_code'] ?? '').toString();
                final unit = (m['unit'] ?? '').toString();
                final amount = m['amount_per_100g']?.toString() ?? '';

                return ListTile(
                  title: Text(
                    name.isNotEmpty ? name : code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: code.isEmpty
                      ? null
                      : Text(
                          code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  trailing: amount.isEmpty
                      ? null
                      : Text('$amount $unit', maxLines: 1),
                );
              }).toList(),
      ),
    );
  }
}
