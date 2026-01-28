import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../../services/auth_service.dart';
import '../../services/food_service.dart';
import '../../config/api_config.dart';

class WebAdminFoods extends StatefulWidget {
  const WebAdminFoods({super.key});

  @override
  State<WebAdminFoods> createState() => _WebAdminFoodsState();
}

class _WebAdminFoodsState extends State<WebAdminFoods> {
  List<dynamic> _foods = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods({int page = 1, String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/admin/foods?page=$page&limit=20&search=$search',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            _foods = data['foods'] ?? [];
            _currentPage = data['pagination']?['page'] ?? 1;
            _totalPages = data['pagination']?['totalPages'] ?? 1;
            _totalItems = data['pagination']?['total'] ?? 0;
            _isLoading = false;
          });
        } on FormatException catch (fe) {
          // Received non-JSON (likely an HTML error page). Surface a friendly message.
          debugPrint(
              'Unexpected non-JSON response when loading foods: ${fe.message}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Lỗi: server trả về dữ liệu không hợp lệ')),
            );
          }
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSearch(String query) async {
    _searchQuery = query;
    await _loadFoods(page: 1, search: query);
  }

  Future<void> _showFoodDetails(Map<String, dynamic> food) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/foods/${food['food_id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        await showDialog(
          context: context,
          builder: (context) =>
              _WebFoodDetailsDialog(foodDetails: data as Map<String, dynamic>),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
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
        _loadFoods(page: _currentPage, search: _searchQuery);
      } else {
        // Try to decode error message safely
        String message = 'Không thể xóa thực phẩm';
        try {
          final body = json.decode(response.body);
          if (body is Map && body['error'] != null) {
            message = body['error'].toString();
          } else if (body is Map && body['message'] != null) {
            message = body['message'].toString();
          }
        } catch (_) {
          // response not JSON - fall back to plain body text if short
          final plain = response.body;
          if (plain.trim().isNotEmpty && plain.length < 500) message = plain;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $message')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _openFoodFormDialog({Map<String, dynamic>? initial}) async {
    Map<String, dynamic>? payload = initial;
    if (initial != null && initial['food_id'] != null) {
      final detail = await _fetchFoodDetail(initial['food_id'] as int);
      if (detail != null) {
        payload = Map<String, dynamic>.from(detail['food'] ?? detail);
        payload['nutrients'] = detail['nutrients'];
      }
    }
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => _WebAddEditFoodDialog(
        food: payload,
        onSaved: () {
          _loadFoods(page: _currentPage, search: _searchQuery);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchFoodDetail(int foodId) async {
    try {
      final token = await AuthService.getToken();
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: WebDataTable<Map<String, dynamic>>(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Danh mục')),
          DataColumn(label: Text('Khẩu phần')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: _foods.cast<Map<String, dynamic>>(),
        rowBuilder: (context, food, index) {
          return DataRow(
            cells: [
              DataCell(Text('${food['food_id'] ?? ''}')),
              DataCell(Text(food['name'] ?? 'N/A')),
              DataCell(Text(food['category'] ?? 'Chưa phân loại')),
              DataCell(Text('${food['serving_size_g'] ?? 0}g')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: () => _showFoodDetails(food),
                      tooltip: 'Xem chi tiết',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 18, color: Colors.orange),
                      onPressed: () => _openFoodFormDialog(
                        initial: food.cast<String, dynamic>(),
                      ),
                      tooltip: 'Chỉnh sửa',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _deleteFood(
                        food['food_id'],
                        food['name'] ?? 'thực phẩm',
                      ),
                      tooltip: 'Xóa',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        isLoading: _isLoading,
        currentPage: _currentPage,
        totalPages: _totalPages,
        totalItems: _totalItems,
        onPageChanged: (page) => _loadFoods(page: page, search: _searchQuery),
        searchHint: 'Tìm kiếm thực phẩm...',
        onSearch: _handleSearch,
        actions: [
          ElevatedButton.icon(
            onPressed: () => _openFoodFormDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Rich Food Details Dialog (web) ======

class _WebFoodDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> foodDetails;

  const _WebFoodDetailsDialog({required this.foodDetails});

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
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'] ?? 'Chi tiết thực phẩm',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (food['category'] != null)
                          Text(
                            food['category'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (food['image_url'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              food['image_url'],
                              height: 140,
                              width: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.restaurant, size: 80),
                            ),
                          )
                        else
                          Container(
                            height: 140,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              size: 80,
                              color: Colors.green,
                            ),
                          ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Danh mục',
                                  food['category'] ?? 'Chưa phân loại'),
                              _buildInfoRow(
                                'Khẩu phần mặc định',
                                '${food['serving_size_g'] ?? 100} g',
                              ),
                              if (food['description'] != null) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Mô tả',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  food['description'],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                      const Divider(height: 32),
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
                      const Divider(height: 32),
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
          SizedBox(width: 130, child: Text('$label:')),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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

// ====== Rich Add/Edit Food Dialog (web) ======

class _WebAddEditFoodDialog extends StatefulWidget {
  final Map<String, dynamic>? food;
  final VoidCallback onSaved;

  const _WebAddEditFoodDialog({this.food, required this.onSaved});

  @override
  State<_WebAddEditFoodDialog> createState() => _WebAddEditFoodDialogState();
}

class _WebAddEditFoodDialogState extends State<_WebAddEditFoodDialog> {
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

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = await AuthService.getToken();

      // Prepare nutrients data
      final nutrients = _selectedNutrients
          .map<Map<String, dynamic>?>((nutrient) {
            final amount = double.tryParse(
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
        'category':
            _categoryController.text.isEmpty ? null : _categoryController.text,
        'image_url':
            _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
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
        width: 650,
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
            // Header
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
                      // Basic Info
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
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Nutrients
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
                                  controller: _nutrientAmountControllers[
                                      nutrient['nutrient_id']],
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
            // Footer
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
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveFood,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(widget.food != null ? 'Cập nhật' : 'Thêm'),
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
