import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/health_condition_model.dart';

class EditHealthConditionScreen extends StatefulWidget {
  final HealthCondition condition;

  const EditHealthConditionScreen({super.key, required this.condition});

  @override
  State<EditHealthConditionScreen> createState() =>
      _EditHealthConditionScreenState();
}

class _EditHealthConditionScreenState extends State<EditHealthConditionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameViController;
  late TextEditingController _nameEnController;
  late TextEditingController _descriptionController;
  late TextEditingController _descriptionViController;
  late TextEditingController _causesController;
  late TextEditingController _treatmentDurationController;
  late TextEditingController _imageUrlController;
  late TextEditingController _articleLinkViController;
  late TextEditingController _articleLinkEnController;
  late TextEditingController _preventionTipsController;
  late TextEditingController _preventionTipsViController;
  late String _selectedCategory;
  late String _selectedSeverity;
  late bool _isChronic;
  bool _isSaving = false;

  final List<String> _categories = [
    'Tim mạch',
    'Chuyển hóa',
    'Gan',
    'Tiêu hóa',
    'Huyết học',
    'Dinh dưỡng',
    'Miễn dịch',
    'Hô hấp',
    'Thần kinh',
    'Nội tiết',
  ];

  @override
  void initState() {
    super.initState();
    _nameViController = TextEditingController(text: widget.condition.nameVi);
    _nameEnController = TextEditingController(text: widget.condition.nameEn);
    _descriptionController = TextEditingController(
      text: widget.condition.description,
    );
    _descriptionViController = TextEditingController(
      text: widget.condition.descriptionVi,
    );
    _causesController = TextEditingController(text: widget.condition.causes);
    _treatmentDurationController = TextEditingController(
      text: widget.condition.treatmentDurationReference,
    );
    _imageUrlController = TextEditingController(
      text: widget.condition.imageUrl,
    );
    _articleLinkViController = TextEditingController(
      text: widget.condition.articleLinkVi,
    );
    _articleLinkEnController = TextEditingController(
      text: widget.condition.articleLinkEn,
    );
    _preventionTipsController = TextEditingController(
      text: widget.condition.preventionTips,
    );
    _preventionTipsViController = TextEditingController(
      text: widget.condition.preventionTipsVi,
    );
    _selectedCategory = widget.condition.category ?? 'Chuyển hóa';
    _selectedSeverity = widget.condition.severityLevel ?? 'moderate';
    _isChronic = widget.condition.isChronic;
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/health/conditions/${widget.condition.conditionId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_vi': _nameViController.text.trim(),
          'name_en': _nameEnController.text.trim(),
          'category': _selectedCategory,
          'description': _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          'description_vi': _descriptionViController.text.trim().isNotEmpty
              ? _descriptionViController.text.trim()
              : null,
          'causes': _causesController.text.trim().isNotEmpty
              ? _causesController.text.trim()
              : null,
          'treatment_duration_reference':
              _treatmentDurationController.text.trim().isNotEmpty
              ? _treatmentDurationController.text.trim()
              : null,
          'image_url': _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          'article_link_vi': _articleLinkViController.text.trim().isNotEmpty
              ? _articleLinkViController.text.trim()
              : null,
          'article_link_en': _articleLinkEnController.text.trim().isNotEmpty
              ? _articleLinkEnController.text.trim()
              : null,
          'prevention_tips': _preventionTipsController.text.trim().isNotEmpty
              ? _preventionTipsController.text.trim()
              : null,
          'prevention_tips_vi':
              _preventionTipsViController.text.trim().isNotEmpty
              ? _preventionTipsViController.text.trim()
              : null,
          'severity_level': _selectedSeverity,
          'is_chronic': _isChronic,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật thông tin bệnh'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        throw Exception('Failed to update: ${response.body}');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa bệnh'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveChanges,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Info Section
            _buildSectionTitle('Thông tin cơ bản', Icons.info),
            const SizedBox(height: 12),

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

            DropdownButtonFormField<String>(
              initialValue: _selectedSeverity,
              decoration: const InputDecoration(
                labelText: 'Mức độ nghiêm trọng',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning),
              ),
              items: const [
                DropdownMenuItem(value: 'mild', child: Text('Nhẹ')),
                DropdownMenuItem(value: 'moderate', child: Text('Trung bình')),
                DropdownMenuItem(value: 'severe', child: Text('Nặng')),
                DropdownMenuItem(
                  value: 'critical',
                  child: Text('Nghiêm trọng'),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedSeverity = value!);
              },
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Bệnh mạn tính'),
              subtitle: const Text('Đánh dấu nếu bệnh cần điều trị dài hạn'),
              value: _isChronic,
              onChanged: (value) {
                setState(() => _isChronic = value);
              },
              secondary: const Icon(Icons.watch_later),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Mô tả & Nguyên nhân', Icons.description),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionViController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tiếng Việt)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tiếng Anh)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _causesController,
              decoration: const InputDecoration(
                labelText: 'Nguyên nhân',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warning_amber),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Điều trị & Phòng ngừa', Icons.medical_services),
            const SizedBox(height: 12),

            TextFormField(
              controller: _treatmentDurationController,
              decoration: const InputDecoration(
                labelText: 'Thời gian điều trị',
                hintText: 'VD: 3-6 tháng, Dài hạn',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _preventionTipsViController,
              decoration: const InputDecoration(
                labelText: 'Cách phòng ngừa (tiếng Việt)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shield),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _preventionTipsController,
              decoration: const InputDecoration(
                labelText: 'Cách phòng ngừa (tiếng Anh)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shield),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Tài nguyên', Icons.link),
            const SizedBox(height: 12),

            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL hình ảnh',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _articleLinkViController,
              decoration: const InputDecoration(
                labelText: 'Bài viết tiếng Việt (URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.article),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _articleLinkEnController,
              decoration: const InputDecoration(
                labelText: 'English Article (URL)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.article),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.red.shade700, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}
