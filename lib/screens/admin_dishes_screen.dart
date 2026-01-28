// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/dish_creation_screen.dart';
import '../config/api_config.dart';
import '../fitness_app_theme.dart';

class AdminDishesScreen extends StatefulWidget {
  const AdminDishesScreen({super.key});

  @override
  State<AdminDishesScreen> createState() => _AdminDishesScreenState();
}

class _AdminDishesScreenState extends State<AdminDishesScreen> {
  List<dynamic> _dishes = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _filterTemplate;
  final TextEditingController _searchController = TextEditingController();

  // Statistics
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getAdminToken() async => AuthService.getToken();

  Future<void> _loadInitialData() async {
    await Future.wait([_loadDishes(), _loadCategories(), _loadStatistics()]);
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getAdminToken();
      final queryParams = <String, String>{};

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }
      if (_selectedCategory != null) {
        queryParams['category'] = _selectedCategory!;
      }
      if (_filterTemplate != null) {
        queryParams['isTemplate'] = _filterTemplate.toString();
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/dishes/admin/all',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dishes = data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải danh sách món ăn')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final token = await _getAdminToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/categories'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categories = data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final token = await _getAdminToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/stats/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stats = data['data'] ?? {};
        });
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  Future<void> _showDishDetails(int dishId) async {
    try {
      final token = await _getAdminToken();

      // Load dish details
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        // Load nutrients
        final nutrientsResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId/nutrients'),
          headers: {'Authorization': 'Bearer $token'},
        );
        List<dynamic> nutrients = [];
        if (nutrientsResponse.statusCode == 200) {
          final nutrientsData = json.decode(nutrientsResponse.body);
          nutrients = nutrientsData['data'] ?? [];
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) =>
                _DishDetailsDialog(dish: data, nutrients: nutrients),
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

  Future<void> _editDish(int dishId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DishCreationScreen(dishId: dishId, isAdmin: true),
      ),
    );

    if (result == true) {
      _loadDishes();
      _loadStatistics();
    }
  }

  Future<void> _deleteDish(int dishId, String dishName, bool hardDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hardDelete ? 'Xác nhận xóa vĩnh viễn' : 'Xác nhận xóa'),
        content: Text(
          hardDelete
              ? 'Bạn có chắc muốn XÓA VĨNH VIỄN món "$dishName"?\nHành động này không thể hoàn tác!'
              : 'Bạn có chắc muốn xóa món "$dishName"?\n(Món sẽ được ẩn khỏi danh sách công khai)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(hardDelete ? 'Xóa vĩnh viễn' : 'Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _getAdminToken();
      final uri = hardDelete
          ? '${ApiConfig.baseUrl}/dishes/admin/$dishId/hard?hard=true'
          : '${ApiConfig.baseUrl}/dishes/$dishId';

      final response = await http.delete(
        Uri.parse(uri),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                hardDelete ? 'Đã xóa vĩnh viễn món ăn' : 'Đã xóa món ăn',
              ),
            ),
          );
        }
        _loadDishes();
        _loadStatistics();
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['message'] ?? 'Không thể xóa món ăn')),
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

  Future<void> _recalculateNutrients(int dishId) async {
    try {
      final token = await _getAdminToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dishes/$dishId/recalculate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tính lại dinh dưỡng thành công')),
          );
        }
        _loadDishes();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tính lại dinh dưỡng')),
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

  Future<void> _createNewDish() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DishCreationScreen(isAdmin: true),
      ),
    );

    if (result == true) {
      _loadDishes();
      _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý món ăn'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Statistics Card
          if (_stats.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Tổng món',
                    _stats['total_dishes']?.toString() ?? '0',
                    Icons.restaurant_menu,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Món mẫu',
                    _stats['template_dishes']?.toString() ?? '0',
                    Icons.star,
                    Colors.orange,
                  ),
                  _buildStatItem(
                    'Người dùng tạo',
                    _stats['user_dishes']?.toString() ?? '0',
                    Icons.person,
                    Colors.purple,
                  ),
                  _buildStatItem(
                    'Lượt ghi nhận',
                    _stats['total_logs']?.toString() ?? '0',
                    Icons.analytics,
                    Colors.green,
                  ),
                ],
              ),
            ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món ăn...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                              _loadDishes();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (value) {
                    setState(() => _searchQuery = value);
                    _loadDishes();
                  },
                ),
                const SizedBox(height: 12),
                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Loại món',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Tất cả',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ..._categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat['category'],
                              child: Text(
                                '${cat['category']} (${cat['count']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                          _loadDishes();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<bool?>(
                        isExpanded: true,
                        initialValue: _filterTemplate,
                        decoration: const InputDecoration(
                          labelText: 'Loại',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'Tất cả',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                              'Món mẫu',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(
                              'Người dùng tạo',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _filterTemplate = value);
                          _loadDishes();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dishes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _dishes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có món ăn nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dishes.length,
                    itemBuilder: (context, index) {
                      final dish = _dishes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: dish['is_template']
                                ? Colors.orange[100]
                                : Colors.blue[100],
                            child: Icon(
                              dish['is_template']
                                  ? Icons.star
                                  : Icons.restaurant,
                              color: dish['is_template']
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                          ),
                          title: Text(
                            dish['vietnamese_name'] ?? dish['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dish['name'] != null)
                                Text(
                                  dish['name'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.category,
                                    size: 13,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      dish['category'] ?? 'N/A',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.fastfood,
                                    size: 13,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${dish['ingredient_count'] ?? 0} NL',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 13,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${dish['unique_users'] ?? 0} người',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.analytics,
                                    size: 13,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${dish['times_logged'] ?? 0} lượt',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('Xem chi tiết'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Chỉnh sửa'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'recalculate',
                                child: Row(
                                  children: [
                                    Icon(Icons.refresh),
                                    SizedBox(width: 8),
                                    Text('Tính lại dinh dưỡng'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'hard-delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa vĩnh viễn',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              final dishId = dish['dish_id'];
                              final dishName =
                                  dish['vietnamese_name'] ?? dish['name'];

                              switch (value) {
                                case 'view':
                                  _showDishDetails(dishId);
                                  break;
                                case 'edit':
                                  _editDish(dishId);
                                  break;
                                case 'recalculate':
                                  _recalculateNutrients(dishId);
                                  break;
                                case 'delete':
                                  _deleteDish(dishId, dishName, false);
                                  break;
                                case 'hard-delete':
                                  _deleteDish(dishId, dishName, true);
                                  break;
                              }
                            },
                          ),
                          onTap: () => _showDishDetails(dish['dish_id']),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewDish,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Tạo món mới'),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Dish Details Dialog
class _DishDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> dish;
  final List<dynamic> nutrients;

  const _DishDetailsDialog({required this.dish, required this.nutrients});

  @override
  State<_DishDetailsDialog> createState() => _DishDetailsDialogState();
}

class _DishDetailsDialogState extends State<_DishDetailsDialog> {
  final Map<String, bool> _expandedGroups = {
    'Macros': true,
    'Vitamins': false,
    'Minerals': false,
    'Amino acids': false,
    'Dietary Fiber': false,
    'Fat / Fatty acids': false,
  };

  @override
  Widget build(BuildContext context) {
    final ingredients = widget.dish['ingredients'] as List? ?? [];
    final dish = widget.dish;

    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish['vietnamese_name'] ?? dish['name'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (dish['name'] != null)
                          Text(
                            dish['name'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Basic Info
              if (dish['description'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    dish['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.category,
                    dish['category'] ?? 'N/A',
                    Colors.blue,
                  ),
                  _buildInfoChip(
                    Icons.scale,
                    '${dish['serving_size_g']}g',
                    Colors.green,
                  ),
                  _buildInfoChip(
                    dish['is_template'] ? Icons.star : Icons.person,
                    dish['is_template'] ? 'Món mẫu' : 'Tùy chỉnh',
                    dish['is_template'] ? Colors.orange : Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Nutrition Facts
              const Text(
                'Thông tin dinh dưỡng (per 100g)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (widget.nutrients.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Chưa có thông tin dinh dưỡng'),
                  ),
                )
              else
                ..._buildNutrientGroups(),

              const SizedBox(height: 24),

              // Ingredients
              const Text(
                'Nguyên liệu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ingredients.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Không có nguyên liệu'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final ing = ingredients[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(ing['food_name'] ?? 'N/A'),
                            subtitle: Text('${ing['weight_g']}g'),
                            trailing:
                                ing['notes'] != null && ing['notes'].isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(ing['notes'])),
                                      );
                                    },
                                  )
                                : null,
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

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withAlpha(51),
    );
  }

  List<Widget> _buildNutrientGroups() {
    // Group nutrients by group_name
    Map<String, List<dynamic>> groupedNutrients = {
      'Macros': [],
      'Vitamins': [],
      'Minerals': [],
      'Amino acids': [],
      'Dietary Fiber': [],
      'Fat / Fatty acids': [],
    };

    for (var nutrient in widget.nutrients) {
      final groupName = nutrient['group_name'] ?? 'Macros';
      if (groupedNutrients.containsKey(groupName)) {
        groupedNutrients[groupName]!.add(nutrient);
      } else {
        groupedNutrients['Macros']!.add(nutrient);
      }
    }

    // Sort nutrients within each group
    groupedNutrients.forEach((key, value) {
      value.sort(
        (a, b) => (a['nutrient_name'] ?? '').toString().compareTo(
          (b['nutrient_name'] ?? '').toString(),
        ),
      );
    });

    List<Widget> widgets = [];

    groupedNutrients.forEach((groupName, nutrients) {
      if (nutrients.isEmpty) return;

      final isExpanded = _expandedGroups[groupName] ?? false;

      widgets.add(
        Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedGroups[groupName] = !isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getGroupNameInVietnamese(groupName),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${nutrients.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 8),
              ...nutrients.map((nutrient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nutrient['nutrient_name'] ?? 'N/A',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                      Text(
                        '${_formatNutrientValue(nutrient['amount_per_100g'])} ${nutrient['unit'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ],
        ),
      );

      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }

  String _getGroupNameInVietnamese(String groupName) {
    const Map<String, String> translations = {
      'Macros': 'Năng lượng & Dinh dưỡng đa lượng',
      'Vitamins': 'Vitamin',
      'Minerals': 'Khoáng chất',
      'Amino acids': 'Axit amin',
      'Dietary Fiber': 'Chất xơ',
      'Fat / Fatty acids': 'Chất béo & Axit béo',
    };
    return translations[groupName] ?? groupName;
  }

  String _formatNutrientValue(dynamic value) {
    if (value == null) return '0';
    final numValue = double.tryParse(value.toString()) ?? 0;
    if (numValue == numValue.toInt()) {
      return numValue.toInt().toString();
    }
    return numValue.toStringAsFixed(2);
  }
}
