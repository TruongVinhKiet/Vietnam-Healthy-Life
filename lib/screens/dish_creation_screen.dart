// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import '../config/api_config.dart';

class DishCreationScreen extends StatefulWidget {
  final int? dishId; // null for create, non-null for edit
  final bool isAdmin; // true if called from admin dashboard

  const DishCreationScreen({super.key, this.dishId, this.isAdmin = false});

  @override
  State<DishCreationScreen> createState() => _DishCreationScreenState();
}

class _DishCreationScreenState extends State<DishCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vietnameseNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _imageUrlController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'noodle',
    'rice',
    'sandwich',
    'soup',
    'appetizer',
    'dessert',
    'drink',
    'test',
    'other',
  ];

  final Map<String, String> _categoryNames = {
    'noodle': 'Món bún/phở',
    'rice': 'Món cơm',
    'sandwich': 'Bánh mì/sandwich',
    'soup': 'Món súp',
    'appetizer': 'Khai vị',
    'dessert': 'Tráng miệng',
    'drink': 'Đồ uống',
    'test': 'Test/Reference',
    'other': 'Khác',
  };

  List<Map<String, dynamic>> _ingredients = [];
  bool _isLoading = false;
  bool _isPublic = true;

  Future<String?> _getToken() async {
    return await AuthService.getToken();
  }

  // Map database category to dropdown key
  String? _mapCategoryFromDb(String? dbCategory) {
    if (dbCategory == null) return null;

    // Check if category is already a key
    if (_categories.contains(dbCategory)) return dbCategory;

    // Map display name back to key
    final entry = _categoryNames.entries.firstWhere(
      (e) => e.value == dbCategory,
      orElse: () => const MapEntry('other', 'Khác'),
    );
    return entry.key;
  }

  // Map dropdown key to database value (display name)
  String? _mapCategoryToDb(String? key) {
    if (key == null) return null;
    return _categoryNames[key] ?? key;
  }

  // Safe parse to double from various types
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Calculated macros
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalFat = 0;
  double _totalCarbs = 0;

  @override
  void initState() {
    super.initState();
    if (widget.dishId != null) {
      _loadDish();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vietnameseNameController.dispose();
    _descriptionController.dispose();
    _servingSizeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadDish() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();

      // Use appropriate endpoint for admin vs user
      final endpoint = widget.isAdmin
          ? '${ApiConfig.baseUrl}/dishes/admin/${widget.dishId}'
          : '${ApiConfig.baseUrl}/dishes/${widget.dishId}';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        setState(() {
          _nameController.text = data['name'] ?? '';
          _vietnameseNameController.text = data['vietnamese_name'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _servingSizeController.text = (data['serving_size_g'] ?? 100)
              .toString();
          _imageUrlController.text = data['image_url'] ?? '';
          _selectedCategory = _mapCategoryFromDb(data['category']);
          _isPublic = data['is_public'] ?? true;

          // Load ingredients
          _ingredients = (data['ingredients'] as List)
              .map(
                (ing) => {
                  'dish_ingredient_id': ing['dish_ingredient_id'],
                  'food_id': ing['food_id'],
                  'food_name': ing['food_name'],
                  'weight_g': _parseDouble(ing['weight_g']) ?? 0.0,
                  'notes': ing['notes'] ?? '',
                },
              )
              .toList();

          // Load macros
          final macros = data['macros'] ?? {};
          _totalCalories = _parseDouble(macros['calories_per_100g']) ?? 0.0;
          _totalProtein = _parseDouble(macros['protein_per_100g']) ?? 0.0;
          _totalFat = _parseDouble(macros['fat_per_100g']) ?? 0.0;
          _totalCarbs = _parseDouble(macros['carbs_per_100g']) ?? 0.0;

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Không thể tải món ăn')));
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

  Future<void> _searchFood() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FoodSearchDialog(isAdmin: widget.isAdmin),
    );

    if (result != null) {
      _showAddIngredientDialog(result);
    }
  }

  void _showAddIngredientDialog(Map<String, dynamic> food) {
    final weightController = TextEditingController(text: '100');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm: ${food['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Khối lượng (g)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                setState(() {
                  _ingredients.add({
                    'food_id': food['food_id'],
                    'food_name': food['name'],
                    'weight_g': weight,
                    'notes': notesController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveDish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 nguyên liệu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _getToken();

      // Step 1: Create/Update dish
      final dishData = {
        'name': _nameController.text,
        'vietnameseName': _vietnameseNameController.text,
        'description': _descriptionController.text,
        'category': _mapCategoryToDb(_selectedCategory),
        'servingSizeG': double.parse(_servingSizeController.text),
        'imageUrl': _imageUrlController.text.isEmpty
            ? null
            : _imageUrlController.text,
        'isPublic': _isPublic,
      };

      http.Response dishResponse;
      int dishId;

      if (widget.dishId == null) {
        // Create new dish
        final createEndpoint = widget.isAdmin
            ? '${ApiConfig.baseUrl}/dishes/admin/create'
            : '${ApiConfig.baseUrl}/dishes';
        dishResponse = await http.post(
          Uri.parse(createEndpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(dishData),
        );
      } else {
        // Update existing dish
        final updateEndpoint = widget.isAdmin
            ? '${ApiConfig.baseUrl}/dishes/admin/${widget.dishId}'
            : '${ApiConfig.baseUrl}/dishes/${widget.dishId}';
        dishResponse = await http.put(
          Uri.parse(updateEndpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(dishData),
        );
      }

      if (dishResponse.statusCode == 200 || dishResponse.statusCode == 201) {
        final dishResult = json.decode(dishResponse.body);
        dishId = dishResult['data']['dish_id'];

        // Step 2: Add ingredients
        for (var i = 0; i < _ingredients.length; i++) {
          final ingredient = _ingredients[i];

          // Skip if this is an edit and ingredient already exists
          if (ingredient['dish_ingredient_id'] != null) continue;

          final ingredientEndpoint = widget.isAdmin
              ? '${ApiConfig.baseUrl}/dishes/admin/$dishId/ingredients'
              : '${ApiConfig.baseUrl}/dishes/$dishId/ingredients';

          await http.post(
            Uri.parse(ingredientEndpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'foodId': ingredient['food_id'],
              'weightG': ingredient['weight_g'],
              'notes': ingredient['notes'],
              'displayOrder': i,
            }),
          );
        }

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.dishId == null
                    ? 'Tạo món ăn thành công!'
                    : 'Cập nhật món ăn thành công!',
              ),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        final error = json.decode(dishResponse.body);
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['message'] ?? 'Lỗi không xác định')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dishId == null ? 'Tạo món ăn mới' : 'Chỉnh sửa món'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thông tin cơ bản',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _vietnameseNameController,
                              decoration: const InputDecoration(
                                labelText: 'Tên món (Tiếng Việt) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.restaurant),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập tên món';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Tên món (English)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.translate),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Loại món *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(_categoryNames[category]!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Vui lòng chọn loại món';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _servingSizeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Khẩu phần (gram) *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                                suffixText: 'g',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập khẩu phần';
                                }
                                final number = double.tryParse(value);
                                if (number == null || number <= 0) {
                                  return 'Khẩu phần phải > 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Mô tả',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: const InputDecoration(
                                labelText: 'URL hình ảnh',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.image),
                                hintText: 'https://...',
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Công khai'),
                              subtitle: const Text(
                                'Cho phép người khác xem món này',
                              ),
                              value: _isPublic,
                              onChanged: (value) {
                                setState(() => _isPublic = value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Ingredients Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Nguyên liệu',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _searchFood,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Thêm'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_ingredients.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(32),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Chưa có nguyên liệu nào',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _ingredients.length,
                                itemBuilder: (context, index) {
                                  final ingredient = _ingredients[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
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
                                      title: Text(
                                        ingredient['food_name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Khối lượng: ${ingredient['weight_g']}g',
                                          ),
                                          if (ingredient['notes'] != null &&
                                              ingredient['notes'].isNotEmpty)
                                            Text(
                                              'Ghi chú: ${ingredient['notes']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _removeIngredient(index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Nutrition Summary (if editing)
                    if (widget.dishId != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dinh dưỡng (100g)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildNutrientCard(
                                    'Calories',
                                    _totalCalories,
                                    'kcal',
                                    Colors.orange,
                                  ),
                                  _buildNutrientCard(
                                    'Protein',
                                    _totalProtein,
                                    'g',
                                    Colors.red,
                                  ),
                                  _buildNutrientCard(
                                    'Fat',
                                    _totalFat,
                                    'g',
                                    Colors.yellow[700]!,
                                  ),
                                  _buildNutrientCard(
                                    'Carbs',
                                    _totalCarbs,
                                    'g',
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveDish,
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.dishId == null ? 'Tạo món ăn' : 'Lưu thay đổi',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNutrientCard(
    String label,
    double value,
    String unit,
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
          child: Icon(Icons.donut_small, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Food Search Dialog
class _FoodSearchDialog extends StatefulWidget {
  final bool isAdmin;

  const _FoodSearchDialog({required this.isAdmin});

  @override
  State<_FoodSearchDialog> createState() => _FoodSearchDialogState();
}

class _FoodSearchDialogState extends State<_FoodSearchDialog> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _allFoods = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAllFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAllFoods() async {
    setState(() => _isSearching = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/foods?limit=100'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allFoods = data['foods'] ?? [];
          _searchResults = _allFoods; // Show all initially
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<String?> _getToken() async {
    return await AuthService.getToken();
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return;

    setState(() => _isSearching = true);

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/foods?search=${Uri.encodeComponent(query)}&limit=20',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['foods'] ?? [];
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tìm thực phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập tên thực phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                // Cancel previous timer
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                // Set new timer for debounce
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  if (value.isEmpty) {
                    setState(() => _searchResults = _allFoods);
                  } else if (value.length >= 2) {
                    // Filter from loaded foods first, then search API if needed
                    final filtered = _allFoods
                        .where(
                          (food) => food['name']
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()),
                        )
                        .toList();

                    if (filtered.isNotEmpty) {
                      setState(() => _searchResults = filtered);
                    } else {
                      // If no local results, search API
                      _performSearch(value);
                    }
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isEmpty
                                ? Icons.search
                                : Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Nhập ít nhất 2 ký tự\nVí dụ: "thịt", "bò", "gà"'
                                : 'Không tìm thấy "${_searchController.text}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        final foodName = food['name'] as String;
                        final category = food['category'] as String?;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.green[700],
                              ),
                            ),
                            title: Text(
                              foodName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: category != null
                                ? Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                            trailing: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.green,
                            ),
                            onTap: () {
                              Navigator.pop(context, {
                                'food_id': food['food_id'],
                                'name': foodName,
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}
