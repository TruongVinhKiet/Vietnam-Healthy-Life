import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminDrugs extends StatefulWidget {
  const WebAdminDrugs({super.key});

  @override
  State<WebAdminDrugs> createState() => _WebAdminDrugsState();
}

class _WebAdminDrugsState extends State<WebAdminDrugs> {
  List<dynamic> _drugs = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDrugs();
  }

  Future<void> _loadDrugs({int page = 1, String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/medications/admin?page=$page&limit=20${search.isNotEmpty ? '&search=$search' : ''}',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _drugs = data['drugs'] ?? [];
          _currentPage = data['pagination']?['page'] ?? 1;
          _totalPages = data['pagination']?['totalPages'] ?? 1;
          _totalItems = data['pagination']?['total'] ?? 0;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDrugDetails(int drugId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/medications/admin/$drugId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final drug = data['drug'];
        final conditions = drug['conditions'] ?? [];
        final contraindications = drug['contraindications'] ?? [];

        if (mounted) {
          await WebDialog.show(
            context: context,
            title: drug['name_vi'] ?? 'Chi tiết thuốc',
            width: 800,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (drug['image_url'] != null)
                    Center(
                      child: Image.network(
                        drug['image_url'],
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.medication, size: 100),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Tên tiếng Việt', drug['name_vi']),
                  _buildDetailRow('Tên tiếng Anh', drug['name_en']),
                  _buildDetailRow('Tên hoạt chất', drug['generic_name']),
                  _buildDetailRow('Nhóm thuốc', drug['drug_class']),
                  _buildDetailRow('Dạng bào chế', drug['dosage_form']),
                  if (drug['description'] != null) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Mô tả:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(drug['description']),
                  ],
                  if (conditions.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      'Điều trị bệnh (${conditions.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...conditions.map(
                      (c) => Card(
                        child: ListTile(
                          title: Text(c['name_vi'] ?? ''),
                          subtitle: Text(c['category'] ?? ''),
                          trailing: c['is_primary']
                              ? Chip(
                                  label: const Text('Chính'),
                                  backgroundColor: Colors.green[100],
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                  if (contraindications.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      'Tác dụng phụ (${contraindications.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...contraindications.map(
                      (c) => Card(
                        color: c['severity'] == 'severe'
                            ? Colors.red[50]
                            : c['severity'] == 'moderate'
                                ? Colors.orange[50]
                                : Colors.yellow[50],
                        child: ListTile(
                          title: Text(c['nutrient_name'] ?? ''),
                          subtitle: Text(
                            'Tránh ${c['avoid_hours_before'] ?? 0}h trước và ${c['avoid_hours_after'] ?? 2}h sau',
                          ),
                          trailing: Chip(
                            label: Text(c['severity'] ?? 'moderate'),
                            backgroundColor: c['severity'] == 'severe'
                                ? Colors.red[200]
                                : c['severity'] == 'moderate'
                                    ? Colors.orange[200]
                                    : Colors.yellow[200],
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteDrug(int drugId, String drugName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thuốc "$drugName"?'),
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
        Uri.parse('${ApiConfig.baseUrl}/api/medications/admin/$drugId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa thuốc thành công')),
          );
        }
        _loadDrugs(page: _currentPage, search: _searchQuery);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _openDrugFormDialog({Map<String, dynamic>? initial}) async {
    final isEdit = initial != null;
    final nameViController = TextEditingController(
        text: initial != null ? initial['name_vi'] ?? '' : '');
    final nameEnController = TextEditingController(
        text: initial != null ? initial['name_en'] ?? '' : '');
    final genericController = TextEditingController(
        text: initial != null ? initial['generic_name'] ?? '' : '');
    final classController = TextEditingController(
        text: initial != null ? initial['drug_class'] ?? '' : '');
    final dosageFormController = TextEditingController(
        text: initial != null ? initial['dosage_form'] ?? '' : '');
    final descriptionController = TextEditingController(
        text: initial != null ? initial['description']?.toString() ?? '' : '');
    final imageUrlController = TextEditingController(
        text: initial != null ? initial['image_url']?.toString() ?? '' : '');
    bool isActive = initial != null ? (initial['is_active'] != false) : true;

    final formKey = GlobalKey<FormState>();
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Chỉnh sửa thuốc' : 'Thêm thuốc'),
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
                    controller: genericController,
                    decoration: const InputDecoration(
                      labelText: 'Tên hoạt chất',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: classController,
                    decoration: const InputDecoration(
                      labelText: 'Nhóm thuốc',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: dosageFormController,
                    decoration: const InputDecoration(
                      labelText: 'Dạng bào chế',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Đang hoạt động'),
                    value: isActive,
                    onChanged: (v) => setStateDialog(() => isActive = v),
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
                          'name_vi': nameViController.text.trim(),
                          if (nameEnController.text.trim().isNotEmpty)
                            'name_en': nameEnController.text.trim(),
                          if (genericController.text.trim().isNotEmpty)
                            'generic_name': genericController.text.trim(),
                          if (classController.text.trim().isNotEmpty)
                            'drug_class': classController.text.trim(),
                          if (dosageFormController.text.trim().isNotEmpty)
                            'dosage_form': dosageFormController.text.trim(),
                          if (descriptionController.text.trim().isNotEmpty)
                            'description': descriptionController.text.trim(),
                          if (imageUrlController.text.trim().isNotEmpty)
                            'image_url': imageUrlController.text.trim(),
                          'is_active': isActive,
                          // condition_ids và contraindications để rỗng cho web
                          'condition_ids': [],
                          'contraindications': [],
                        };

                        http.Response res;
                        if (isEdit) {
                          final id = initial['drug_id'];
                          res = await http.put(
                            Uri.parse(
                                '${ApiConfig.baseUrl}/api/admin/drugs/$id'),
                            headers: {
                              'Authorization': 'Bearer $token',
                              'Content-Type': 'application/json',
                            },
                            body: json.encode(payload),
                          );
                        } else {
                          res = await http.post(
                            Uri.parse('${ApiConfig.baseUrl}/api/admin/drugs'),
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
                                  ? 'Cập nhật thuốc thành công'
                                  : 'Thêm thuốc thành công'),
                            ),
                          );
                          _loadDrugs(page: _currentPage, search: _searchQuery);
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
      child: WebDataTable<Map<String, dynamic>>(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên tiếng Việt')),
          DataColumn(label: Text('Tên hoạt chất')),
          DataColumn(label: Text('Nhóm thuốc')),
          DataColumn(label: Text('Bệnh')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: _drugs.cast<Map<String, dynamic>>(),
        rowBuilder: (context, drug, index) {
          return DataRow(
            cells: [
              DataCell(Text('${drug['drug_id'] ?? ''}')),
              DataCell(Text(drug['name_vi'] ?? 'N/A')),
              DataCell(Text(drug['generic_name'] ?? 'N/A')),
              DataCell(Text(drug['drug_class'] ?? 'N/A')),
              DataCell(Text('${drug['condition_count'] ?? 0} bệnh')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      onPressed: () => _showDrugDetails(drug['drug_id']),
                      tooltip: 'Chi tiết',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 18, color: Colors.orange),
                      onPressed: () => _openDrugFormDialog(
                        initial: drug.cast<String, dynamic>(),
                      ),
                      tooltip: 'Sửa',
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.delete, size: 18, color: Colors.red),
                      onPressed: () => _deleteDrug(
                        drug['drug_id'],
                        drug['name_vi'] ?? 'thuốc',
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
        onPageChanged: (page) => _loadDrugs(page: page, search: _searchQuery),
        searchHint: 'Tìm kiếm thuốc...',
        onSearch: (query) {
          _searchQuery = query;
          _loadDrugs(search: query);
        },
        actions: [
          ElevatedButton.icon(
            onPressed: () => _openDrugFormDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm thuốc'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
