import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../config/api_config.dart';

class WebAdminHealthConditions extends StatefulWidget {
  const WebAdminHealthConditions({super.key});

  @override
  State<WebAdminHealthConditions> createState() =>
      _WebAdminHealthConditionsState();
}

class _WebAdminHealthConditionsState extends State<WebAdminHealthConditions> {
  List<dynamic> _conditions = [];
  bool _isLoading = true;
  int _totalConditions = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conditions = data['conditions'] ?? data;
        final conditionsList = (conditions is List) ? conditions : [];

        setState(() {
          _conditions = conditionsList;
          _totalConditions = conditionsList.length;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Tim mạch':
        return Colors.red;
      case 'Chuyển hóa':
        return Colors.orange;
      case 'Gan':
        return Colors.brown;
      case 'Tiêu hóa':
        return Colors.green;
      case 'Huyết học':
        return Colors.purple;
      case 'Dinh dưỡng':
        return Colors.blue;
      case 'Miễn dịch':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showConditionDetails(Map<String, dynamic> condition) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/health/conditions/${condition['condition_id']}',
        ),
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        final fullCondition = data['condition'];

        await WebDialog.show(
          context: context,
          title: fullCondition['name_vi'] ?? 'Chi tiết bệnh',
          width: 800,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      avatar: Icon(
                        Icons.medical_services,
                        size: 16,
                        color: _getCategoryColor(fullCondition['category']),
                      ),
                      label: Text(fullCondition['category'] ?? 'N/A'),
                      backgroundColor:
                          _getCategoryColor(fullCondition['category'])
                              .withValues(alpha: 0.1),
                    ),
                    if (fullCondition['severity_level'] != null)
                      Chip(
                        label: Text(fullCondition['severity_level']),
                      ),
                    if (fullCondition['is_chronic'] == true)
                      const Chip(
                        label: Text('Mạn tính'),
                        backgroundColor: Colors.orange,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (fullCondition['description'] != null) ...[
                  const Text(
                    'Mô tả:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(fullCondition['description']),
                  const SizedBox(height: 16),
                ],
                if (fullCondition['causes'] != null) ...[
                  const Text(
                    'Nguyên nhân:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(fullCondition['causes']),
                  const SizedBox(height: 16),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _openConditionFormDialog({Map<String, dynamic>? initial}) async {
    final isEdit = initial != null;
    final nameViController = TextEditingController(
        text: initial != null ? initial['name_vi'] ?? '' : '');
    final nameEnController = TextEditingController(
        text: initial != null ? initial['name_en'] ?? '' : '');
    final categoryController = TextEditingController(
        text: initial != null ? initial['category']?.toString() ?? '' : '');
    final severityController = TextEditingController(
        text:
            initial != null ? initial['severity_level']?.toString() ?? '' : '');
    bool isChronic = initial != null ? (initial['is_chronic'] == true) : false;
    final descriptionController = TextEditingController(
        text: initial != null ? initial['description']?.toString() ?? '' : '');
    final causesController = TextEditingController(
        text: initial != null ? initial['causes']?.toString() ?? '' : '');
    final imageUrlController = TextEditingController(
        text: initial != null ? initial['image_url']?.toString() ?? '' : '');

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Chỉnh sửa bệnh lý' : 'Thêm bệnh lý'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameViController,
                    decoration: const InputDecoration(
                      labelText: 'Tên tiếng Việt *',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameEnController,
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
                  TextFormField(
                    controller: severityController,
                    decoration: const InputDecoration(
                      labelText: 'Mức độ (severity_level)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Mạn tính'),
                    value: isChronic,
                    onChanged: (v) => setStateDialog(() => isChronic = v),
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: causesController,
                    decoration: const InputDecoration(
                      labelText: 'Nguyên nhân',
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
                        final payload = <String, dynamic>{
                          'name_vi': nameViController.text.trim(),
                          if (nameEnController.text.trim().isNotEmpty)
                            'name_en': nameEnController.text.trim(),
                          if (categoryController.text.trim().isNotEmpty)
                            'category': categoryController.text.trim(),
                          if (descriptionController.text.trim().isNotEmpty)
                            'description': descriptionController.text.trim(),
                          if (causesController.text.trim().isNotEmpty)
                            'causes': causesController.text.trim(),
                          if (severityController.text.trim().isNotEmpty)
                            'severity_level': severityController.text.trim(),
                          'is_chronic': isChronic,
                          if (imageUrlController.text.trim().isNotEmpty)
                            'image_url': imageUrlController.text.trim(),
                        };

                        http.Response res;
                        if (isEdit) {
                          final id = initial['condition_id'];
                          res = await http.put(
                            Uri.parse(
                                '${ApiConfig.baseUrl}/health/conditions/$id'),
                            headers: const {
                              'Content-Type': 'application/json',
                            },
                            body: json.encode(payload),
                          );
                        } else {
                          res = await http.post(
                            Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
                            headers: const {
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
                                  ? 'Cập nhật bệnh lý thành công'
                                  : 'Thêm bệnh lý thành công'),
                            ),
                          );
                          _loadConditions();
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
    final filteredConditions = _searchQuery.isEmpty
        ? _conditions
        : _conditions.where((condition) {
            final name = (condition['name_vi'] ?? '').toString().toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats Card
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng số bệnh trong hệ thống',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalConditions',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
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
                DataColumn(label: Text('Danh mục')),
                DataColumn(label: Text('Mức độ')),
                DataColumn(label: Text('Thao tác')),
              ],
              rows: filteredConditions.cast<Map<String, dynamic>>(),
              rowBuilder: (context, condition, index) {
                return DataRow(
                  cells: [
                    DataCell(Text('${condition['condition_id'] ?? ''}')),
                    DataCell(Text(condition['name_vi'] ?? 'N/A')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(condition['category'])
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          condition['category'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(condition['category']),
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(condition['severity_level'] ?? 'N/A')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            onPressed: () => _showConditionDetails(condition),
                            tooltip: 'Xem chi tiết',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 18, color: Colors.orange),
                            onPressed: () => _openConditionFormDialog(
                              initial: condition.cast<String, dynamic>(),
                            ),
                            tooltip: 'Chỉnh sửa',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              isLoading: _isLoading,
              currentPage: 1,
              totalPages: 1,
              totalItems: filteredConditions.length,
              searchHint: 'Tìm kiếm bệnh lý...',
              onSearch: (query) {
                setState(() => _searchQuery = query);
              },
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _openConditionFormDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
