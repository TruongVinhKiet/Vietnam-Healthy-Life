import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/health_condition_model.dart';
import 'health_condition_detail_screen.dart';
import '../fitness_app_theme.dart';

class AdminHealthConditionsScreen extends StatefulWidget {
  const AdminHealthConditionsScreen({super.key});

  @override
  State<AdminHealthConditionsScreen> createState() =>
      _AdminHealthConditionsScreenState();
}

class _AdminHealthConditionsScreenState
    extends State<AdminHealthConditionsScreen> {
  List<dynamic> _conditions = [];
  bool _isLoading = true;
  int _totalConditions = 0;

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
        // Backend trả về {success: true, conditions: [...]}
        final conditions = data['conditions'] ?? data;
        final conditionsList = (conditions is List) ? conditions : [];

        setState(() {
          _conditions = conditionsList;
          _totalConditions = conditionsList.length;
          _isLoading = false;
        });
      } else {
        debugPrint(
          'Failed to load conditions: ${response.statusCode} ${response.body}',
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading conditions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh sách: $e')));
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateConditionDialog(onCreated: _loadConditions),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tình trạng sức khỏe'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[400]!, Colors.red[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng số bệnh trong hệ thống',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalConditions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Conditions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conditions.isEmpty
                ? const Center(child: Text('Chưa có bệnh nào trong hệ thống'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conditions.length,
                    itemBuilder: (context, index) {
                      final condition = _conditions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(
                              condition['category'],
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            condition['name_vi'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    condition['category'],
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  condition['category'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getCategoryColor(
                                      condition['category'],
                                    ),
                                  ),
                                ),
                              ),
                              if (condition['description'] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  condition['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () async {
                            // Fetch full condition details first
                            try {
                              final response = await http.get(
                                Uri.parse(
                                  '${ApiConfig.baseUrl}/health/conditions/${condition['condition_id']}',
                                ),
                              );

                              if (!context.mounted) return;

                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                final fullCondition = data['condition'];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HealthConditionDetailScreen(
                                      condition: HealthCondition.fromJson(
                                        fullCondition,
                                      ),
                                      isAdminView: true,
                                      nutrientEffects:
                                          (data['condition']['nutrient_effects']
                                                      as List<dynamic>? ??
                                                  [])
                                              .map(
                                                (n) =>
                                                    NutrientEffect.fromJson(n),
                                              )
                                              .toList(),
                                      foodsToAvoid:
                                          (data['condition']['foods_to_avoid']
                                                      as List<dynamic>? ??
                                                  [])
                                              .map(
                                                (f) =>
                                                    FoodRecommendation.fromJson(
                                                      f,
                                                    ),
                                              )
                                              .toList(),
                                      foodsToRecommend:
                                          (data['condition']['food_recommendations']
                                                      as List<dynamic>? ??
                                                  [])
                                              .map(
                                                (f) =>
                                                    FoodRecommendation.fromJson(
                                                      f,
                                                    ),
                                              )
                                              .toList(),
                                      drugs:
                                          (data['condition']['drugs']
                                                      as List<dynamic>? ??
                                                  [])
                                              .map(
                                                (d) =>
                                                    DrugTreatment.fromJson(d),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ).then((_) => _loadConditions());
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm bệnh', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// Edit Condition Dialog
class _EditConditionDialog extends StatefulWidget {
  final dynamic condition;
  final VoidCallback onUpdated;

  const _EditConditionDialog({
    required this.condition,
    required this.onUpdated,
  });

  @override
  _EditConditionDialogState createState() => _EditConditionDialogState();
}

class _EditConditionDialogState extends State<_EditConditionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameViController;
  late final TextEditingController _nameEnController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _causesController;
  late final TextEditingController _treatmentDurationController;
  late String _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = [
    'Tim mạch',
    'Chuyển hóa',
    'Gan',
    'Tiêu hóa',
    'Huyết học',
    'Dinh dưỡng',
    'Miễn dịch',
  ];

  @override
  void initState() {
    super.initState();
    _nameViController = TextEditingController(
      text: widget.condition['name_vi'],
    );
    _nameEnController = TextEditingController(
      text: widget.condition['name_en'],
    );
    _descriptionController = TextEditingController(
      text: widget.condition['description'] ?? '',
    );
    _causesController = TextEditingController(
      text: widget.condition['causes'] ?? '',
    );
    _treatmentDurationController = TextEditingController(
      text: widget.condition['treatment_duration_reference'] ?? '',
    );
    _selectedCategory = widget.condition['category'] ?? 'Chuyển hóa';
  }

  @override
  void dispose() {
    _nameViController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _causesController.dispose();
    _treatmentDurationController.dispose();
    super.dispose();
  }

  Future<void> _saveCondition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('auth_token');

      if (adminToken == null) {
        throw Exception('Chưa đăng nhập');
      }

      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/health/conditions/${widget.condition['condition_id']}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
        body: json.encode({
          'name_vi': _nameViController.text.trim(),
          'name_en': _nameEnController.text.trim(),
          'category': _selectedCategory,
          'description': _descriptionController.text.trim(),
          'causes': _causesController.text.trim(),
          'treatment_duration_reference': _treatmentDurationController.text
              .trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pop(context);
        widget.onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật bệnh thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Cập nhật thất bại: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Sửa thông tin bệnh',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                TextFormField(
                  controller: _nameViController,
                  decoration: const InputDecoration(
                    labelText: 'Tên tiếng Việt *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_hospital),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bắt buộc nhập' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameEnController,
                  decoration: const InputDecoration(
                    labelText: 'Tên tiếng Anh *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bắt buộc nhập' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả bệnh',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _causesController,
                  decoration: const InputDecoration(
                    labelText: 'Nguyên nhân',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _treatmentDurationController,
                  decoration: const InputDecoration(
                    labelText:
                        'Thời gian điều trị (VD: "3-6 tháng", "Dài hạn")',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.schedule),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveCondition,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '💾 Lưu thay đổi',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Create Condition Dialog
class _CreateConditionDialog extends StatefulWidget {
  final VoidCallback onCreated;

  const _CreateConditionDialog({required this.onCreated});

  @override
  State<_CreateConditionDialog> createState() => _CreateConditionDialogState();
}

class _CreateConditionDialogState extends State<_CreateConditionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameViController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionViController = TextEditingController();
  final _causesController = TextEditingController();
  final _treatmentDurationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _articleLinkViController = TextEditingController();
  final _articleLinkEnController = TextEditingController();
  final _preventionTipsController = TextEditingController();
  final _preventionTipsViController = TextEditingController();
  String _selectedCategory = 'Chuyển hóa';
  String _selectedSeverity = 'moderate';
  bool _isChronic = false;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _nutrientsIncrease = [];
  final List<Map<String, dynamic>> _nutrientsDecrease = [];
  List<dynamic> _allNutrients = [];

  final List<String> _categories = [
    'Tim mạch',
    'Chuyển hóa',
    'Gan',
    'Tiêu hóa',
    'Huyết học',
    'Dinh dưỡng',
    'Miễn dịch',
  ];

  @override
  void initState() {
    super.initState();
    _loadNutrients();
  }

  Future<void> _loadNutrients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminToken = prefs.getString('auth_token');

      if (adminToken == null) {
        debugPrint('No admin token found');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/nutrients?limit=1000'),
        headers: {'Authorization': 'Bearer $adminToken'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _allNutrients = data['nutrients'] ?? [];
        });
      } else {
        debugPrint(
          'Failed to load nutrients: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error loading nutrients: $e');
    }
  }

  Future<void> _saveCondition() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_vi': _nameViController.text.trim(),
          'name_en': _nameEnController.text.trim(),
          'category': _selectedCategory,
          'description': _descriptionController.text.trim(),
          'causes': _causesController.text.trim(),
          'treatment_duration_reference': _treatmentDurationController.text
              .trim(),
          'image_url': _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          'article_link_vi': _articleLinkViController.text.trim().isNotEmpty
              ? _articleLinkViController.text.trim()
              : null,
          'article_link_en': _articleLinkEnController.text.trim().isNotEmpty
              ? _articleLinkEnController.text.trim()
              : null,
          'prevention_tips_vi':
              _preventionTipsViController.text.trim().isNotEmpty
              ? _preventionTipsViController.text.trim()
              : null,
          'severity_level': _selectedSeverity,
          'is_chronic': _isChronic,
        }),
      );

      if (response.statusCode == 201) {
        final createdCondition = json.decode(response.body);
        final conditionId = createdCondition['condition_id'];

        // Add nutrient effects (increase)
        for (var nutrient in _nutrientsIncrease) {
          await http.post(
            Uri.parse(
              '${ApiConfig.baseUrl}/health/conditions/$conditionId/nutrient-effects',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nutrient_id': nutrient['nutrient_id'],
              'adjustment_percent': nutrient['percent'],
            }),
          );
        }

        // Add nutrient effects (decrease)
        for (var nutrient in _nutrientsDecrease) {
          await http.post(
            Uri.parse(
              '${ApiConfig.baseUrl}/health/conditions/$conditionId/nutrient-effects',
            ),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'nutrient_id': nutrient['nutrient_id'],
              'adjustment_percent': nutrient['percent'],
            }),
          );
        }

        if (!mounted) return;
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm bệnh mới thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to create condition: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
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
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.red.shade50.withValues(alpha: 0.3)],
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
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Thêm bệnh mới',
                      style: TextStyle(
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
                              Icons.local_hospital_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _nameEnController,
                        decoration: InputDecoration(
                          labelText: 'Tên tiếng Anh *',
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
                              Icons.language_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Bắt buộc nhập' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Danh mục *',
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
                              Icons.category_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategory = value!);
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Mô tả bệnh',
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
                              Icons.description_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _causesController,
                        decoration: InputDecoration(
                          labelText: 'Nguyên nhân',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.amber.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _treatmentDurationController,
                        decoration: InputDecoration(
                          labelText: 'Thời gian điều trị (VD: "3-6 tháng")',
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
                              Icons.schedule_rounded,
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
                          labelText: 'Link hình ảnh',
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
                              Icons.image_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _articleLinkViController,
                        decoration: InputDecoration(
                          labelText: 'Link bài viết tiếng Việt',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan.shade400,
                                  Colors.cyan.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.article_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _articleLinkEnController,
                        decoration: InputDecoration(
                          labelText: 'Link bài viết tiếng Anh',
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
                              Icons.article_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _preventionTipsViController,
                        decoration: InputDecoration(
                          labelText: 'Phòng ngừa (tiếng Việt)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.lightGreen.shade400,
                                  Colors.lightGreen.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.tips_and_updates_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSeverity,
                        decoration: InputDecoration(
                          labelText: 'Mức độ nghiêm trọng',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.deepOrange.shade400,
                                  Colors.deepOrange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.priority_high_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'mild', child: Text('Nhẹ')),
                          DropdownMenuItem(
                            value: 'moderate',
                            child: Text('Trung bình'),
                          ),
                          DropdownMenuItem(
                            value: 'severe',
                            child: Text('Nặng'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSeverity = value!);
                        },
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CheckboxListTile(
                          title: const Text('Bệnh mạn tính'),
                          subtitle: const Text(
                            'Đánh dấu nếu bệnh cần điều trị dài hạn',
                          ),
                          value: _isChronic,
                          onChanged: (value) {
                            setState(() => _isChronic = value ?? false);
                          },
                          secondary: Container(
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
                              Icons.update_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Nutrients Increase Section
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
                              Icons.arrow_upward_rounded,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chất cần tăng cường',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: Colors.green.shade700,
                              ),
                              onPressed: _addNutrientIncrease,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._nutrientsIncrease.map((nutrient) {
                        final index = _nutrientsIncrease.indexOf(nutrient);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  nutrient['name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: nutrient['percent'].toString(),
                                  decoration: InputDecoration(
                                    labelText: '%',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _nutrientsIncrease[index]['percent'] =
                                        int.tryParse(value) ?? 0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _nutrientsIncrease.removeAt(index),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      // Nutrients Decrease Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade100.withValues(alpha: 0.5),
                              Colors.orange.shade50.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chất cần hạn chế',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: Colors.orange.shade700,
                              ),
                              onPressed: _addNutrientDecrease,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._nutrientsDecrease.map((nutrient) {
                        final index = _nutrientsDecrease.indexOf(nutrient);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  nutrient['name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: nutrient['percent'].toString(),
                                  decoration: InputDecoration(
                                    labelText: '%',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _nutrientsDecrease[index]['percent'] =
                                        int.tryParse(value) ?? 0;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _nutrientsDecrease.removeAt(index),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Food Recommendations Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Thực phẩm nên ăn/tránh sẽ được thêm sau khi tạo bệnh',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.w500,
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
                      onPressed: _isSaving ? null : _saveCondition,
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
                                const Icon(
                                  Icons.save_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Lưu',
                                  style: TextStyle(
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

  void _addNutrientIncrease() {
    if (_allNutrients.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        String? selectedNutrientId;
        int percent = 20;
        return AlertDialog(
          title: const Text('Chọn chất dinh dưỡng cần tăng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Chất dinh dưỡng'),
                items: _allNutrients.map((n) {
                  return DropdownMenuItem(
                    value: n['nutrient_id'].toString(),
                    child: Text(n['name'] ?? 'N/A'),
                  );
                }).toList(),
                onChanged: (value) => selectedNutrientId = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '20',
                decoration: const InputDecoration(labelText: 'Tăng %'),
                keyboardType: TextInputType.number,
                onChanged: (value) => percent = int.tryParse(value) ?? 20,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedNutrientId != null) {
                  final nutrient = _allNutrients.firstWhere(
                    (n) => n['nutrient_id'].toString() == selectedNutrientId,
                  );
                  setState(() {
                    _nutrientsIncrease.add({
                      'nutrient_id': nutrient['nutrient_id'],
                      'name': nutrient['name'],
                      'percent': percent,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _addNutrientDecrease() {
    if (_allNutrients.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        String? selectedNutrientId;
        int percent = -20;
        return AlertDialog(
          title: const Text('Chọn chất dinh dưỡng cần hạn chế'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Chất dinh dưỡng'),
                items: _allNutrients.map((n) {
                  return DropdownMenuItem(
                    value: n['nutrient_id'].toString(),
                    child: Text(n['name'] ?? 'N/A'),
                  );
                }).toList(),
                onChanged: (value) => selectedNutrientId = value,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '-20',
                decoration: const InputDecoration(labelText: 'Giảm %'),
                keyboardType: TextInputType.number,
                onChanged: (value) => percent = int.tryParse(value) ?? -20,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedNutrientId != null) {
                  final nutrient = _allNutrients.firstWhere(
                    (n) => n['nutrient_id'].toString() == selectedNutrientId,
                  );
                  setState(() {
                    _nutrientsDecrease.add({
                      'nutrient_id': nutrient['nutrient_id'],
                      'name': nutrient['name'],
                      'percent': percent,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameViController.dispose();
    _nameEnController.dispose();
    _descriptionController.dispose();
    _descriptionViController.dispose();
    _causesController.dispose();
    _treatmentDurationController.dispose();
    _imageUrlController.dispose();
    _articleLinkViController.dispose();
    _articleLinkEnController.dispose();
    _preventionTipsController.dispose();
    _preventionTipsViController.dispose();
    super.dispose();
  }
}
