// ignore_for_file: use_super_parameters, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import '../config/api_config.dart';

class AdminDrugsScreen extends StatefulWidget {
  const AdminDrugsScreen({super.key});

  @override
  State<AdminDrugsScreen> createState() => _AdminDrugsScreenState();
}

class _AdminDrugsScreenState extends State<AdminDrugsScreen> {
  List<dynamic> drugs = [];
  bool isLoading = true;
  int currentPage = 1;
  int totalPages = 1;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDrugs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async => AuthService.getToken();

  Future<void> _loadDrugs({int page = 1, String search = ''}) async {
    setState(() => isLoading = true);

    try {
      final token = await _getToken();
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
          drugs = data['drugs'] ?? [];
          currentPage = data['pagination']?['page'] ?? 1;
          totalPages = data['pagination']?['totalPages'] ?? 1;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${response.statusCode}')),
          );
        }
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

  Future<void> _showDrugDetails(int drugId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/medications/admin/$drugId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => _DrugDetailsDialog(drugDetails: data['drug']),
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/medications/admin/$drugId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Xóa thuốc thành công')));
        }
        _loadDrugs(page: currentPage, search: searchQuery);
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['error'] ?? 'Lỗi xóa thuốc')),
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

  Future<void> _showAddEditDialog({Map<String, dynamic>? drug}) async {
    await showDialog(
      context: context,
      builder: (context) => _AddEditDrugDialog(
        drug: drug,
        onSaved: () {
          _loadDrugs(page: currentPage, search: searchQuery);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thuốc'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thuốc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    searchQuery = '';
                    _loadDrugs();
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
                _loadDrugs(search: value);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm thuốc'),
        backgroundColor: Colors.deepOrange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: drugs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.medication,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có thuốc nào',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nhấn nút bên dưới để thêm thuốc mới',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: drugs.length,
                          itemBuilder: (context, index) {
                            final drug = drugs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: drug['image_url'] != null
                                    ? Image.network(
                                        drug['image_url'],
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.medication,
                                              size: 40,
                                            ),
                                      )
                                    : const Icon(Icons.medication, size: 40),
                                title: Text(drug['name_vi'] ?? 'N/A'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (drug['generic_name'] != null)
                                      Text(
                                        drug['generic_name'],
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    if (drug['drug_class'] != null)
                                      Text(
                                        drug['drug_class'],
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (drug['condition_count'] != null)
                                      Text(
                                        '${drug['condition_count']} bệnh',
                                        style: TextStyle(
                                          color: Colors.blue[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.info_outline,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _showDrugDetails(drug['drug_id']),
                                      tooltip: 'Chi tiết',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () =>
                                          _showAddEditDialog(drug: drug),
                                      tooltip: 'Sửa',
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteDrug(
                                        drug['drug_id'],
                                        drug['name_vi'] ?? 'thuốc',
                                      ),
                                      tooltip: 'Xóa',
                                    ),
                                  ],
                                ),
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
                              ? () => _loadDrugs(
                                  page: currentPage - 1,
                                  search: searchQuery,
                                )
                              : null,
                        ),
                        Text('Trang $currentPage / $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: currentPage < totalPages
                              ? () => _loadDrugs(
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

// Drug Details Dialog
class _DrugDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> drugDetails;

  const _DrugDetailsDialog({required this.drugDetails});

  @override
  Widget build(BuildContext context) {
    final conditions = drugDetails['conditions'] ?? [];
    final contraindications = drugDetails['contraindications'] ?? [];

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            AppBar(
              title: Text(drugDetails['name_vi'] ?? 'Chi tiết thuốc'),
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
                    if (drugDetails['image_url'] != null)
                      Center(
                        child: Image.network(
                          drugDetails['image_url'],
                          height: 150,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.medication, size: 100),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Tên tiếng Việt', drugDetails['name_vi']),
                    _buildInfoRow('Tên tiếng Anh', drugDetails['name_en']),
                    _buildInfoRow('Tên hoạt chất', drugDetails['generic_name']),
                    _buildInfoRow('Nhóm thuốc', drugDetails['drug_class']),
                    _buildInfoRow('Dạng bào chế', drugDetails['dosage_form']),
                    if (drugDetails['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Mô tả:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    if (drugDetails['description'] != null)
                      Text(drugDetails['description']),
                    if (drugDetails['source_link'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () {
                            // Open link
                          },
                          child: Text(
                            'Nguồn: ${drugDetails['source_link']}',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    const Divider(height: 32),
                    Text(
                      'Điều trị bệnh (${conditions.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (conditions.isEmpty)
                      const Text('Chưa có bệnh nào được liên kết')
                    else
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
                    const Divider(height: 32),
                    Text(
                      'Tác dụng phụ (${contraindications.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (contraindications.isEmpty)
                      const Text('Chưa có tác dụng phụ nào')
                    else
                      ...contraindications.map(
                        (c) => Card(
                          color: c['severity'] == 'severe'
                              ? Colors.red[50]
                              : c['severity'] == 'moderate'
                              ? Colors.orange[50]
                              : Colors.yellow[50],
                          child: ListTile(
                            title: Text(c['nutrient_name'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tránh ${c['avoid_hours_before'] ?? 0}h trước và ${c['avoid_hours_after'] ?? 2}h sau',
                                ),
                                if (c['warning_message_vi'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      c['warning_message_vi'],
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
}

// Add/Edit Drug Dialog - Simplified version
class _AddEditDrugDialog extends StatefulWidget {
  final Map<String, dynamic>? drug;
  final VoidCallback onSaved;

  const _AddEditDrugDialog({this.drug, required this.onSaved});

  @override
  State<_AddEditDrugDialog> createState() => _AddEditDrugDialogState();
}

class _AddEditDrugDialogState extends State<_AddEditDrugDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameViController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _drugClassController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sourceLinkController = TextEditingController();
  final _dosageFormController = TextEditingController();
  bool _isActive = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _conditions = [];
  List<Map<String, dynamic>> _nutrients = [];
  final List<Map<String, dynamic>> _selectedConditions = [];
  final List<Map<String, dynamic>> _selectedContraindications = [];

  @override
  void initState() {
    super.initState();
    if (widget.drug != null) {
      _nameViController.text = widget.drug!['name_vi'] ?? '';
      _nameEnController.text = widget.drug!['name_en'] ?? '';
      _genericNameController.text = widget.drug!['generic_name'] ?? '';
      _drugClassController.text = widget.drug!['drug_class'] ?? '';
      _descriptionController.text = widget.drug!['description'] ?? '';
      _imageUrlController.text = widget.drug!['image_url'] ?? '';
      _sourceLinkController.text = widget.drug!['source_link'] ?? '';
      _dosageFormController.text = widget.drug!['dosage_form'] ?? '';
      _isActive = widget.drug!['is_active'] ?? true;
    }
    _loadConditions();
    _loadNutrients();
  }

  @override
  void dispose() {
    _nameViController.dispose();
    _nameEnController.dispose();
    _genericNameController.dispose();
    _drugClassController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _sourceLinkController.dispose();
    _dosageFormController.dispose();
    super.dispose();
  }

  Future<void> _loadConditions() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/conditions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _conditions = List<Map<String, dynamic>>.from(
            data['conditions'] ?? [],
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading conditions: $e');
    }
  }

  Future<void> _loadNutrients() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/nutrients'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nutrients = List<Map<String, dynamic>>.from(data['nutrients'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error loading nutrients: $e');
    }
  }

  Future<void> _saveDrug() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final token = await AuthService.getToken();
      final payload = {
        'name_vi': _nameViController.text,
        'name_en': _nameEnController.text,
        'generic_name': _genericNameController.text,
        'drug_class': _drugClassController.text,
        'description': _descriptionController.text,
        'image_url': _imageUrlController.text,
        'source_link': _sourceLinkController.text,
        'dosage_form': _dosageFormController.text,
        'is_active': _isActive,
        'condition_ids': _selectedConditions
            .map(
              (c) => {
                'condition_id': c['condition_id'],
                'is_primary': c['is_primary'] ?? false,
                'treatment_notes': c['treatment_notes'],
              },
            )
            .toList(),
        'contraindications': _selectedContraindications
            .map(
              (c) => {
                'nutrient_id': c['nutrient_id'],
                'avoid_hours_before': c['avoid_hours_before'] ?? 0,
                'avoid_hours_after': c['avoid_hours_after'] ?? 2,
                'warning_message_vi': c['warning_message_vi'],
                'warning_message_en': c['warning_message_en'],
                'severity': c['severity'] ?? 'moderate',
              },
            )
            .toList(),
      };

      final url = widget.drug != null
          ? '${ApiConfig.baseUrl}/api/medications/admin/${widget.drug!['drug_id']}'
          : '${ApiConfig.baseUrl}/api/medications/admin';

      final response = widget.drug != null
          ? await http.put(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(payload),
            )
          : await http.post(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: json.encode(payload),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context);
          widget.onSaved();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.drug != null
                    ? 'Cập nhật thuốc thành công'
                    : 'Thêm thuốc thành công',
              ),
            ),
          );
        }
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['error'] ?? 'Lỗi lưu thuốc')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.red.shade50.withValues(alpha: 0.3)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade400],
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
                        widget.drug != null
                            ? Icons.edit_rounded
                            : Icons.add_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.drug != null ? 'Sửa thuốc' : 'Thêm thuốc mới',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      tooltip: 'Đóng',
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
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
                              Colors.red.shade100.withValues(alpha: 0.5),
                              Colors.red.shade50.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.red.shade700,
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
                        controller: _nameViController,
                        decoration: InputDecoration(
                          labelText: 'Tên tiếng Việt *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.medication_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Bắt buộc' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: InputDecoration(
                          labelText: 'Tên tiếng Anh',
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
                              Icons.translate_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _genericNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên hoạt chất',
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
                              Icons.science_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _drugClassController,
                        decoration: InputDecoration(
                          labelText: 'Nhóm thuốc',
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
                        controller: _dosageFormController,
                        decoration: InputDecoration(
                          labelText: 'Dạng bào chế',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.pink.shade400,
                                  Colors.pink.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.medical_services_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        maxLines: 3,
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
                                  Colors.indigo.shade400,
                                  Colors.indigo.shade600,
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
                        controller: _sourceLinkController,
                        decoration: InputDecoration(
                          labelText: 'Nguồn tham khảo',
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
                              Icons.link_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Đang hoạt động'),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      const Divider(height: 32),
                      Text(
                        'Bệnh điều trị',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showConditionSelector(),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm bệnh'),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedConditions.map(
                        (c) => Chip(
                          label: Text(c['name_vi'] ?? ''),
                          onDeleted: () {
                            setState(() {
                              _selectedConditions.remove(c);
                            });
                          },
                        ),
                      ),
                      const Divider(height: 32),
                      Text(
                        'Tác dụng phụ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _showContraindicationSelector(),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm tác dụng phụ'),
                      ),
                      const SizedBox(height: 8),
                      ..._selectedContraindications.map(
                        (c) => Card(
                          child: ListTile(
                            title: Text(c['nutrient_name'] ?? ''),
                            subtitle: Text(
                              'Tránh ${c['avoid_hours_before'] ?? 0}h trước và ${c['avoid_hours_after'] ?? 2}h sau',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _selectedContraindications.remove(c);
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
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
                          colors: [Colors.red.shade500, Colors.red.shade700],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade300.withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveDrug,
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
                                    widget.drug != null
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.drug != null ? 'Cập nhật' : 'Thêm',
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
      ),
    );
  }

  void _showConditionSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn bệnh'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _conditions.length,
            itemBuilder: (context, index) {
              final condition = _conditions[index];
              final isSelected = _selectedConditions.any(
                (c) => c['condition_id'] == condition['condition_id'],
              );
              return CheckboxListTile(
                title: Text(condition['name_vi'] ?? ''),
                subtitle: Text(condition['category'] ?? ''),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedConditions.add({
                        'condition_id': condition['condition_id'],
                        'name_vi': condition['name_vi'],
                        'is_primary': false,
                        'treatment_notes': '',
                      });
                    } else {
                      _selectedConditions.removeWhere(
                        (c) => c['condition_id'] == condition['condition_id'],
                      );
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Xong'),
          ),
        ],
      ),
    );
  }

  void _showContraindicationSelector() {
    final hoursBeforeController = TextEditingController(text: '0');
    final hoursAfterController = TextEditingController(text: '2');
    final warningController = TextEditingController();
    String selectedSeverity = 'moderate';
    Map<String, dynamic>? selectedNutrient;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade600, Colors.orange.shade400],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Thêm tác dụng phụ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'Chất dinh dưỡng cần tránh *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          items: _nutrients
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n,
                                  child: Text(
                                    n['name'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedNutrient = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: hoursBeforeController,
                                decoration: InputDecoration(
                                  labelText: 'Giờ trước',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: hoursAfterController,
                                decoration: InputDecoration(
                                  labelText: 'Giờ sau',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: warningController,
                          decoration: InputDecoration(
                            labelText: 'Thông báo cảnh báo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSeverity,
                          decoration: InputDecoration(
                            labelText: 'Mức độ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'mild',
                              child: Text(
                                'Nhẹ',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'moderate',
                              child: Text(
                                'Trung bình',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'severe',
                              child: Text(
                                'Nghiêm trọng',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSeverity = value ?? 'moderate';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade500,
                              Colors.orange.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedNutrient == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng chọn chất dinh dưỡng',
                                  ),
                                ),
                              );
                              return;
                            }
                            setState(() {
                              _selectedContraindications.add({
                                'nutrient_id': selectedNutrient!['nutrient_id'],
                                'nutrient_name': selectedNutrient!['name'],
                                'avoid_hours_before':
                                    int.tryParse(hoursBeforeController.text) ??
                                    0,
                                'avoid_hours_after':
                                    int.tryParse(hoursAfterController.text) ??
                                    2,
                                'warning_message_vi': warningController.text,
                                'warning_message_en': '',
                                'severity': selectedSeverity,
                              });
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Thêm',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
