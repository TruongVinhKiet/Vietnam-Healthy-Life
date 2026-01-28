import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminDishes extends StatefulWidget {
  const WebAdminDishes({super.key});

  @override
  State<WebAdminDishes> createState() => _WebAdminDishesState();
}

class _WebAdminDishesState extends State<WebAdminDishes> {
  List<dynamic> _dishes = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  final int _currentPage = 1;
  final int _totalPages = 1;
  String _searchQuery = '';
  String? _selectedCategory;
  bool? _filterTemplate;
  bool? _filterPublic;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadDishes(), _loadCategories()]);
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
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

      if (_filterPublic != null) {
        queryParams['isPublic'] = _filterPublic.toString();
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
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final token = await AuthService.getToken();
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

  Future<void> _showDishDetails(int dishId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
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
          await WebDialog.show(
            context: context,
            title: 'Chi tiết món ăn',
            width: 800,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['vietnamese_name'] ?? data['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (data['name'] != null)
                    Text(
                      data['name'],
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 16),
                        label: Text(data['category'] ?? 'N/A'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.scale, size: 16),
                        label: Text('${data['serving_size_g']}g'),
                      ),
                      Chip(
                        avatar: Icon(
                          data['is_template'] ? Icons.star : Icons.person,
                          size: 16,
                        ),
                        label: Text(
                          data['is_template'] ? 'Món mẫu' : 'Người dùng tạo',
                        ),
                      ),
                    ],
                  ),
                  if (data['description'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      data['description'],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                  if (nutrients.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Thông tin dinh dưỡng (per 100g)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...nutrients.take(10).map((nutrient) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(nutrient['nutrient_name'] ?? 'N/A'),
                              Text(
                                '${nutrient['amount_per_100g']} ${nutrient['unit'] ?? ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
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

  Future<void> _deleteDish(int dishId, String dishName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa món "$dishName"?'),
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
    if (!mounted) return;
    // Show dialog offering soft or hard delete
    final choice = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa món ăn'),
        content: Text('Bạn muốn xóa món "$dishName" bằng cách nào?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'soft'),
            child: const Text('Xóa mềm'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'hard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa cứng'),
          ),
        ],
      ),
    );

    if (choice == null) return; // cancelled

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Không có token đăng nhập'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Choose endpoint: soft -> /dishes/admin/:id, hard -> /dishes/admin/:id/hard
      final uri = Uri.parse(
        choice == 'hard'
            ? '${ApiConfig.baseUrl}/dishes/admin/$dishId/hard'
            : '${ApiConfig.baseUrl}/dishes/admin/$dishId',
      );

      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          final msg = choice == 'hard'
              ? 'Đã xóa vĩnh viễn món ăn'
              : 'Đã xóa món ăn (mềm)';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadDishes();
      } else {
        String errorMessage = 'Lỗi không xác định';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map) {
            errorMessage =
                (errorBody['message'] ?? errorBody['error'] ?? errorMessage)
                    .toString();
          } else if (errorBody is String) {
            errorMessage = errorBody;
          }
        } catch (_) {
          final plain = response.body;
          if (plain.trim().isNotEmpty && plain.length < 1000)
            errorMessage = plain;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa món ăn: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return;
  }

  Future<void> _approveDish(int dishId, String dishName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt món ăn'),
        content: Text('Bạn có chắc muốn phê duyệt món "$dishName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Không có token đăng nhập'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId/approve'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã phê duyệt món ăn'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadDishes();
      } else {
        String errorMessage = 'Lỗi không xác định';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody is Map) {
            errorMessage =
                (errorBody['message'] ?? errorBody['error'] ?? errorMessage)
                    .toString();
          } else if (errorBody is String) {
            errorMessage = errorBody;
          }
        } catch (_) {
          final plain = response.body;
          if (plain.trim().isNotEmpty && plain.length < 1000) {
            errorMessage = plain;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi phê duyệt: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openDishFormDialog({Map<String, dynamic>? initial}) async {
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    final vnNameController =
        TextEditingController(text: initial?['vietnamese_name'] ?? '');
    final nameController = TextEditingController(text: initial?['name'] ?? '');
    final categoryController =
        TextEditingController(text: initial?['category'] ?? '');
    final imageUrlController =
        TextEditingController(text: initial?['image_url'] ?? '');
    final descriptionController =
        TextEditingController(text: initial?['description'] ?? '');
    bool isTemplate = initial?['is_template'] ?? false;
    final isEdit = initial != null;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Chỉnh sửa món ăn' : 'Thêm món ăn'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: vnNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên tiếng Việt *',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên tiếng Anh',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Món mẫu (template)'),
                    value: isTemplate,
                    onChanged: (v) => setStateDialog(() => isTemplate = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Ảnh (URL)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setStateDialog(() => saving = true);
                      try {
                        final token = await AuthService.getToken();
                        if (token == null) {
                          throw Exception('Không có token đăng nhập');
                        }

                        final payload = <String, dynamic>{
                          'name': nameController.text.trim().isEmpty
                              ? vnNameController.text.trim()
                              : nameController.text.trim(),
                          'vietnamese_name': vnNameController.text.trim(),
                          'is_template': isTemplate,
                        };
                        if (categoryController.text.trim().isNotEmpty) {
                          payload['category'] = categoryController.text.trim();
                        }
                        if (descriptionController.text.trim().isNotEmpty) {
                          payload['description'] =
                              descriptionController.text.trim();
                        }
                        if (imageUrlController.text.trim().isNotEmpty) {
                          payload['image_url'] = imageUrlController.text.trim();
                        }

                        http.Response res;
                        if (isEdit) {
                          final id = initial['dish_id'];
                          res = await http.put(
                            Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$id'),
                            headers: {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json',
                            },
                            body: json.encode(payload),
                          );
                        } else {
                          res = await http.post(
                            Uri.parse(
                                '${ApiConfig.baseUrl}/dishes/admin/create'),
                            headers: {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json',
                            },
                            body: json.encode(payload),
                          );
                        }

                        if (!mounted || !ctx.mounted) return;
                        if (res.statusCode == 200 || res.statusCode == 201) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit
                                  ? 'Cập nhật món ăn thành công'
                                  : 'Thêm món ăn thành công'),
                            ),
                          );
                          _loadDishes();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Lưu thất bại: ${res.statusCode} ${res.body}'),
                            ),
                          );
                          setStateDialog(() => saving = false);
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                        setStateDialog(() => saving = false);
                      }
                    },
              child: Text(isEdit ? 'Lưu' : 'Tạo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Loại món',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Tất cả'),
                        ),
                        ..._categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat['category'],
                            child: Text('${cat['category']} (${cat['count']})'),
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
                      initialValue: _filterTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Loại',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Món mẫu'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Người dùng tạo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _filterTemplate = value);
                        _loadDishes();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      initialValue: _filterPublic,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Public'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Chờ duyệt'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _filterPublic = value);
                        _loadDishes();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Table
          Expanded(
            child: WebDataTable<Map<String, dynamic>>(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Loại')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Danh mục')),
                DataColumn(label: Text('Nguyên liệu')),
                DataColumn(label: Text('Thao tác')),
              ],
              rows: _dishes.cast<Map<String, dynamic>>(),
              rowBuilder: (context, dish, index) {
                final bool isPublic = dish['is_public'] == true;
                final bool isPendingUserDish =
                    dish['created_by_user'] != null && isPublic == false;

                return DataRow(
                  cells: [
                    DataCell(Text('${dish['dish_id'] ?? ''}')),
                    DataCell(Text(
                      dish['vietnamese_name'] ?? dish['name'] ?? 'N/A',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            dish['is_template'] ? Icons.star : Icons.person,
                            size: 16,
                            color: dish['is_template']
                                ? Colors.orange
                                : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dish['is_template'] ? 'Mẫu' : 'User',
                            style: TextStyle(
                              fontSize: 12,
                              color: dish['is_template']
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPublic ? Icons.public : Icons.schedule,
                            size: 16,
                            color: isPublic ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPublic ? 'Public' : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: isPublic ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(dish['category'] ?? 'N/A')),
                    DataCell(Text('${dish['ingredient_count'] ?? 0} NL')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPendingUserDish)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green,
                              ),
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                              onPressed: () => _approveDish(
                                dish['dish_id'],
                                dish['vietnamese_name'] ??
                                    dish['name'] ??
                                    'món ăn',
                              ),
                              tooltip: 'Phê duyệt',
                            ),
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () => _showDishDetails(dish['dish_id']),
                            tooltip: 'Xem chi tiết',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 18, color: Colors.orange),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () => _openDishFormDialog(
                              initial: dish.cast<String, dynamic>(),
                            ),
                            tooltip: 'Sửa',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            onPressed: () => _deleteDish(
                              dish['dish_id'],
                              dish['vietnamese_name'] ??
                                  dish['name'] ??
                                  'món ăn',
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
              totalItems: _dishes.length,
              onPageChanged: null,
              searchHint: 'Tìm kiếm món ăn...',
              onSearch: (query) {
                _searchQuery = query;
                _loadDishes();
              },
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _openDishFormDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
