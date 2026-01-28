// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import 'admin_nutrient_form_screen.dart';
import 'admin_nutrient_detail_screen.dart';
import '../config/api_config.dart';

class AdminNutrientsScreen extends StatefulWidget {
  const AdminNutrientsScreen({super.key});

  @override
  State<AdminNutrientsScreen> createState() => _AdminNutrientsScreenState();
}

class _AdminNutrientsScreenState extends State<AdminNutrientsScreen> {
  List<dynamic> nutrients = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNutrients();
  }

  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _loadNutrients({String search = ''}) async {
    setState(() => isLoading = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/nutrients?limit=100&search=$search',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nutrients = data['nutrients'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _showNutrientFoods(int nutrientId, String nutrientName) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/nutrients/$nutrientId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => _NutrientFoodsDialog(
            nutrientName: nutrientName,
            foods: data['foods'] ?? [],
            unit: data['nutrient']['unit'] ?? '',
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chất dinh dưỡng'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm chất dinh dưỡng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery = '';
                    _loadNutrients();
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) {
                searchQuery = value;
                _loadNutrients(search: value);
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : nutrients.isEmpty
          ? const Center(child: Text('Không có chất dinh dưỡng nào'))
          : ListView.builder(
              itemCount: nutrients.length,
              itemBuilder: (context, index) {
                final nutrient = nutrients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: _NutrientAvatar(
                      imageUrl: (nutrient['image_url'] ?? '').toString(),
                    ),
                    title: Text(nutrient['name'] ?? 'N/A'),
                    subtitle: Text(
                      'Mã: ${nutrient['nutrient_code'] ?? 'N/A'} | Đơn vị: ${nutrient['unit'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'foods') {
                          _showNutrientFoods(
                            nutrient['nutrient_id'],
                            nutrient['name'],
                          );
                        } else if (value == 'edit') {
                          final changed = await showDialog<bool>(
                            context: context,
                            builder: (_) =>
                                AdminNutrientFormScreen(nutrient: nutrient),
                          );
                          if (changed == true) {
                            _loadNutrients(search: searchQuery);
                          }
                        } else if (value == 'delete') {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Xóa chất dinh dưỡng'),
                              content: Text(
                                'Bạn có chắc muốn xóa "${nutrient['name']}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final res = await AuthService.adminDeleteNutrient(
                              nutrient['nutrient_id'] as int,
                            );
                            if (!context.mounted) return;
                            if (res != null && res['error'] == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã xóa thành công'),
                                ),
                              );
                              _loadNutrients(search: searchQuery);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Xóa thất bại: ${res?['error'] ?? 'Lỗi không xác định'}',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'foods',
                          child: ListTile(
                            leading: Icon(
                              Icons.restaurant_menu,
                              color: Colors.green,
                            ),
                            title: Text('Xem thực phẩm chứa chất này'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit, color: Colors.orange),
                            title: Text('Chỉnh sửa'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Xóa'),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final changed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AdminNutrientDetailScreen(
                          nutrientId: nutrient['nutrient_id'] as int,
                          nutrientName: nutrient['name']?.toString() ?? '',
                        ),
                      );
                      if (changed == true) {
                        _loadNutrients(search: searchQuery);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showDialog<bool>(
            context: context,
            builder: (_) => const AdminNutrientFormScreen(),
          );
          if (created == true) {
            _loadNutrients(search: searchQuery);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm chất'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

class _NutrientFoodsDialog extends StatelessWidget {
  final String nutrientName;
  final List<dynamic> foods;
  final String unit;

  const _NutrientFoodsDialog({
    required this.nutrientName,
    required this.foods,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title: Text('$nutrientName - Top thực phẩm'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: foods.isEmpty
                  ? const Center(
                      child: Text('Không có thực phẩm nào chứa chất này'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        final amount = food['amount_per_100g'];
                        final rank = index + 1;

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRankColor(rank),
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(food['name'] ?? 'N/A'),
                            subtitle: Text(
                              food['category'] ?? 'Chưa phân loại',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                '$amount $unit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Hiển thị ${foods.length} thực phẩm (đơn vị: $unit / 100g)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }
}

class _NutrientAvatar extends StatelessWidget {
  final String imageUrl;
  const _NutrientAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    if (hasImage) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.transparent,
      );
    }
    return const CircleAvatar(child: Icon(Icons.science));
  }
}
