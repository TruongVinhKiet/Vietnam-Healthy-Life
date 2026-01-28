// ignore_for_file: use_super_parameters, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/food_service.dart';
import '../config/api_config.dart';

class AdminFoodsScreen extends StatefulWidget {
  const AdminFoodsScreen({super.key});

  @override
  State<AdminFoodsScreen> createState() => _AdminFoodsScreenState();
}

class _AdminFoodsScreenState extends State<AdminFoodsScreen> {
  List<dynamic> foods = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _loadFoods({int page = 1, String search = ''}) async {
    setState(() => isLoading = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/foods?page=$page&limit=20&search=$search',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          foods = data['foods'];
          currentPage = data['pagination']['page'];
          totalPages = data['pagination']['totalPages'];
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

  Future<void> _showFoodDetails(int foodId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/foods/$foodId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => _FoodDetailsDialog(foodDetails: data),
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

  Future<void> _deleteFood(int foodId, String foodName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thực phẩm "$foodName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/foods/$foodId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa thực phẩm thành công')),
          );
        }
        _loadFoods(page: currentPage, search: searchQuery);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? food}) async {
    Map<String, dynamic>? payload = food;
    if (food != null && food['food_id'] != null) {
      final detail = await _fetchFoodDetail(food['food_id'] as int);
      if (detail != null) {
        payload = Map<String, dynamic>.from(detail['food'] ?? detail);
        payload['nutrients'] = detail['nutrients'];
      }
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => _AddEditFoodDialog(
        food: payload,
        onSaved: () {
          _loadFoods(page: currentPage, search: searchQuery);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchFoodDetail(int foodId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/foods/$foodId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching food detail: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thực phẩm'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thực phẩm...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery = '';
                    _loadFoods();
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
                _loadFoods(search: value);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm thực phẩm'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: foods.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có thực phẩm nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nhấn nút bên dưới để thêm thực phẩm mới',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: foods.length,
                          itemBuilder: (context, index) {
                            final food = foods[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: food['image_url'] != null
                                    ? Image.network(
                                        food['image_url'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.restaurant,
                                              size: 32,
                                            ),
                                      )
                                    : const Icon(Icons.restaurant, size: 32),
                                title: Text(
                                  food['name'] ?? 'N/A',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  food['category'] ?? 'Chưa phân loại',
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _showAddEditDialog(food: food),
                                      tooltip: 'Sửa',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _deleteFood(
                                        food['food_id'],
                                        food['name'] ?? 'thực phẩm',
                                      ),
                                      tooltip: 'Xóa',
                                    ),
                                  ],
                                ),
                                onTap: () => _showFoodDetails(food['food_id']),
                              ),
                            );
                          },
                        ),
                ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: currentPage > 1
                              ? () => _loadFoods(
                                  page: currentPage - 1,
                                  search: searchQuery,
                                )
                              : null,
                        ),
                        Text('Trang $currentPage / $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () => _loadFoods(
                                  page: currentPage + 1,
                                  search: searchQuery,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _FoodDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> foodDetails;

  const _FoodDetailsDialog({required this.foodDetails});

  @override
  Widget build(BuildContext context) {
    final food = foodDetails['food'];
    final nutrients = foodDetails['nutrients'] ?? [];

    // Categorize nutrients
    final macros = nutrients
        .where(
          (n) => [
            'PROCNT',
            'FAT',
            'CHOCDF',
            'ENERC_KCAL',
          ].contains(n['nutrient_code']),
        )
        .toList();
    final vitamins = nutrients
        .where(
          (n) =>
              (n['nutrient_name'] as String).toLowerCase().contains('vitamin'),
        )
        .toList();
    final minerals = nutrients
        .where((n) => !macros.contains(n) && !vitamins.contains(n))
        .toList();

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title: Text(food['name'] ?? 'Chi tiết thực phẩm'),
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
                    if (food['image_url'] != null)
                      Center(
                        child: Image.network(
                          food['image_url'],
                          height: 150,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.restaurant, size: 100),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Danh mục', food['category'] ?? 'N/A'),
                    const Divider(height: 32),
                    if (macros.isNotEmpty) ...[
                      const Text(
                        'Dinh dưỡng chính (trên 100g)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...macros.map(
                        (n) => _buildNutrientRow(
                          n['nutrient_name'],
                          n['amount_per_100g'],
                          n['unit'],
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                    if (vitamins.isNotEmpty) ...[
                      const Text(
                        'Vitamin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...vitamins.map(
                        (n) => _buildNutrientRow(
                          n['nutrient_name'],
                          n['amount_per_100g'],
                          n['unit'],
                        ),
                      ),
                      const Divider(height: 24),
                    ],
                    if (minerals.isNotEmpty) ...[
                      const Text(
                        'Khoáng chất & Khác',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...minerals.map(
                        (n) => _buildNutrientRow(
                          n['nutrient_name'],
                          n['amount_per_100g'],
                          n['unit'],
                        ),
                      ),
                    ],
                    if (nutrients.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('Chưa có thông tin dinh dưỡng'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:')),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String name, dynamic amount, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Text(
            '${amount ?? 0} $unit',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Add/Edit Food Dialog
class _AddEditFoodDialog extends StatefulWidget {
  final Map<String, dynamic>? food;
  final VoidCallback onSaved;

  const _AddEditFoodDialog({this.food, required this.onSaved});

  @override
  State<_AddEditFoodDialog> createState() => _AddEditFoodDialogState();
}

class _AddEditFoodDialogState extends State<_AddEditFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _servingController = TextEditingController(text: '100');
  bool _isSaving = false;
  List<Map<String, dynamic>> _availableNutrients = [];
  final List<Map<String, dynamic>> _selectedNutrients = [];
  final Map<int, TextEditingController> _nutrientAmountControllers = {};
  int? _selectedNutrientId;

  @override
  void initState() {
    super.initState();
    if (widget.food != null) {
      _nameController.text = widget.food!['name'] ?? '';
      _categoryController.text = widget.food!['category'] ?? '';
      _imageUrlController.text = widget.food!['image_url'] ?? '';
      _servingController.text =
          widget.food!['serving_size_g']?.toString() ?? '100';
      final nutrients = widget.food!['nutrients'] as List<dynamic>? ?? [];
      for (final nutrient in nutrients) {
        final id = nutrient['nutrient_id'] as int?;
        if (id != null) {
          final controller = TextEditingController(
            text: (nutrient['amount_per_100g'] ?? 0).toString(),
          );
          _nutrientAmountControllers[id] = controller;
          _selectedNutrients.add({
            'nutrient_id': id,
            'nutrient_name': nutrient['nutrient_name'] ?? nutrient['name'],
            'unit': nutrient['unit'],
          });
        }
      }
    }
    _fetchAvailableNutrients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    for (var controller in _nutrientAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchAvailableNutrients() async {
    final nutrients = await FoodService.listAvailableNutrients();
    if (!mounted) return;
    setState(() {
      _availableNutrients = nutrients;
    });
  }

  void _addNutrient(int nutrientId) {
    if (_selectedNutrients.any((entry) => entry['nutrient_id'] == nutrientId)) {
      return;
    }
    final nutrient = _availableNutrients.firstWhere(
      (entry) => entry['nutrient_id'] == nutrientId,
      orElse: () => {},
    );
    final controller = TextEditingController();
    _nutrientAmountControllers[nutrientId] = controller;
    setState(() {
      _selectedNutrients.add({
        'nutrient_id': nutrientId,
        'nutrient_name': nutrient['name'],
        'unit': nutrient['unit'],
      });
      _selectedNutrientId = null;
    });
  }

  void _removeNutrient(int nutrientId) {
    setState(() {
      _selectedNutrients.removeWhere(
        (entry) => entry['nutrient_id'] == nutrientId,
      );
      _nutrientAmountControllers[nutrientId]?.dispose();
      _nutrientAmountControllers.remove(nutrientId);
    });
  }

  Future<void> _savFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = await AuthService.getToken();

      // Prepare nutrients data
      final nutrients = _selectedNutrients
          .map<Map<String, dynamic>?>((nutrient) {
            final amount =
                double.tryParse(
                  _nutrientAmountControllers[nutrient['nutrient_id']]?.text ??
                      '',
                ) ??
                0;
            if (amount <= 0) return null;
            return {
              'nutrient_id': nutrient['nutrient_id'],
              'amount_per_100g': amount,
            };
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      final body = {
        'name': _nameController.text,
        'category': _categoryController.text.isEmpty
            ? null
            : _categoryController.text,
        'image_url': _imageUrlController.text.isEmpty
            ? null
            : _imageUrlController.text,
        'serving_size_g':
            double.tryParse(_servingController.text.trim()) ?? 100,
        'nutrients': nutrients,
      };

      if (widget.food != null) {
        body['food_id'] = widget.food!['food_id'];
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/foods'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      setState(() => _isSaving = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.food != null
                    ? 'Cập nhật thực phẩm thành công'
                    : 'Thêm thực phẩm thành công',
              ),
            ),
          );
          widget.onSaved();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${response.body}')));
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 550,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.green.shade50.withValues(alpha: 0.3)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.food != null
                          ? Icons.edit_rounded
                          : Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.food != null
                          ? 'Sửa thực phẩm'
                          : 'Thêm thực phẩm mới',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade100.withValues(alpha: 0.5),
                              Colors.green.shade50.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Thông tin cơ bản',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên thực phẩm *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên thực phẩm';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Danh mục',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.category_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL hình ảnh',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.image_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _servingController,
                        decoration: InputDecoration(
                          labelText: 'Khẩu phần mặc định (g)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.purple.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.scale_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade100.withValues(alpha: 0.5),
                              Colors.teal.shade50.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.science_rounded,
                              color: Colors.teal.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Dinh dưỡng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _selectedNutrientId,
                              isExpanded: true,
                              items: _availableNutrients
                                  .where(
                                    (nutrient) => !_selectedNutrients.any(
                                      (selected) =>
                                          selected['nutrient_id'] ==
                                          nutrient['nutrient_id'],
                                    ),
                                  )
                                  .map(
                                    (nutrient) => DropdownMenuItem<int>(
                                      value: nutrient['nutrient_id'] as int,
                                      child: Text(
                                        '${nutrient['name']} (${nutrient['unit'] ?? ''})',
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              decoration: const InputDecoration(
                                labelText: 'Chọn chất',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                isDense: true,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              onChanged: (value) =>
                                  setState(() => _selectedNutrientId = value),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _selectedNutrientId == null
                                ? null
                                : () => _addNutrient(_selectedNutrientId!),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              '+ Thêm',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._selectedNutrients.map(
                        (nutrient) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      _nutrientAmountControllers[nutrient['nutrient_id']],
                                  decoration: InputDecoration(
                                    labelText:
                                        '${nutrient['nutrient_name']} (${nutrient['unit'] ?? ''})',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removeNutrient(
                                  nutrient['nutrient_id'] as int,
                                ),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500, Colors.green.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savFood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.food != null
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.food != null ? 'Cập nhật' : 'Thêm',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
