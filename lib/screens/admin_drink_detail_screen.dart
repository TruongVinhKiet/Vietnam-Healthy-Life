import 'package:flutter/material.dart';
import 'package:my_diary/services/drink_service.dart';

class AdminDrinkDetailScreen extends StatefulWidget {
  final int drinkId;

  const AdminDrinkDetailScreen({super.key, required this.drinkId});

  @override
  State<AdminDrinkDetailScreen> createState() => _AdminDrinkDetailScreenState();
}

class _AdminDrinkDetailScreenState extends State<AdminDrinkDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _drink;
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
      final res = await DrinkService.adminFetchDetail(widget.drinkId);
      if (!mounted) return;

      if (res == null) {
        setState(() {
          _error = 'Không thể tải dữ liệu';
          _isLoading = false;
        });
        return;
      }

      if (res['success'] == true && res['drink'] is Map) {
        setState(() {
          _drink = Map<String, dynamic>.from(res['drink'] as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = res['error']?.toString() ?? 'Không thể tải chi tiết đồ uống';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
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
    final drink = _drink;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đồ uống'),
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
          : drink == null
          ? const Center(child: Text('Không tìm thấy đồ uống'))
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
                            (drink['vietnamese_name'] ?? drink['name'] ?? '')
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
                              if (drink['category'] != null)
                                _buildChip(
                                  label: drink['category'].toString(),
                                  color: Colors.blue,
                                ),
                              _buildChip(
                                label: drink['is_public'] == true
                                    ? 'Public'
                                    : 'Pending',
                                color: drink['is_public'] == true
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              _buildChip(
                                label: drink['is_template'] == true
                                    ? 'Mẫu'
                                    : 'User',
                                color: drink['is_template'] == true
                                    ? Colors.purple
                                    : Colors.teal,
                              ),
                              _buildChip(
                                label:
                                    '${drink['default_volume_ml'] ?? 250} ml',
                                color: Colors.cyan,
                              ),
                              _buildChip(
                                label:
                                    'Hydration ${(_toDouble(drink['hydration_ratio']) * 100).toStringAsFixed(0)}%',
                                color: Colors.indigo,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if ((drink['description'] ?? '')
                              .toString()
                              .trim()
                              .isNotEmpty)
                            Text(
                              drink['description'].toString(),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIngredientsCard(drink['ingredients']),
                  const SizedBox(height: 12),
                  _buildNutrientsCard(drink['nutrient_details']),
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
                final name = (m['name'] ?? m['food_name'] ?? '').toString();
                final amount = m['amount_g']?.toString() ?? '';
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
                  trailing: amount.isEmpty ? null : Text('${amount}g'),
                );
              }).toList(),
      ),
    );
  }

  Widget _buildNutrientsCard(dynamic nutrientsRaw) {
    final nutrients = nutrientsRaw is List ? nutrientsRaw : const [];

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
                final name = (m['name'] ?? '').toString();
                final code = (m['nutrient_code'] ?? '').toString();
                final unit = (m['unit'] ?? '').toString();
                final amount = m['amount_per_100ml']?.toString() ?? '';

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
