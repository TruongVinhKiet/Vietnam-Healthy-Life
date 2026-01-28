import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/meal_template_service.dart';

class MealTemplatesScreen extends StatefulWidget {
  const MealTemplatesScreen({super.key});

  @override
  State<MealTemplatesScreen> createState() => _MealTemplatesScreenState();
}

class _MealTemplatesScreenState extends State<MealTemplatesScreen> {
  final MealTemplateService _templateService = MealTemplateService();
  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final result = await _templateService.getTemplates();
      setState(() {
        _templates = List<Map<String, dynamic>>.from(
          result['templates'] ?? [],
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải mẫu bữa ăn: $e')),
        );
      }
    }
  }

  Future<void> _deleteTemplate(int templateId) async {
    try {
      await _templateService.deleteTemplate(templateId);
      _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa mẫu bữa ăn')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa mẫu: $e')),
        );
      }
    }
  }

  Future<void> _applyTemplate(int templateId) async {
    try {
      await _templateService.applyTemplate(templateId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm mẫu bữa ăn vào nhật ký!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi áp dụng mẫu: $e')),
        );
      }
    }
  }

  void _showTemplateDetails(Map<String, dynamic> template) async {
    try {
      final details = await _templateService.getTemplateById(
        template['template_id'],
      );
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _TemplateDetailsDialog(
          template: details,
          onApply: () => _applyTemplate(template['template_id']),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải chi tiết: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Mẫu Bữa Ăn',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: FitnessAppTheme.nearlyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTemplates,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(_templates[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: FitnessAppTheme.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có mẫu bữa ăn nào',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FitnessAppTheme.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lưu các bữa ăn yêu thích để sử dụng lại',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 14,
              color: FitnessAppTheme.grey.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final timesUsed = template['times_used'] ?? 0;
    final isFavorite = template['is_favorite'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showTemplateDetails(template),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple,
                          Colors.purple.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template['template_name'] ?? '',
                                style: const TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isFavorite)
                              const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Đã dùng $timesUsed lần',
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontSize: 12,
                            color: FitnessAppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'apply',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 8),
                            Text('Áp dụng mẫu'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDelete(template['template_id']);
                      } else if (value == 'apply') {
                        _applyTemplate(template['template_id']);
                      }
                    },
                  ),
                ],
              ),
              if (template['description'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  template['description'],
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 13,
                    color: FitnessAppTheme.grey.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(int templateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mẫu bữa ăn'),
        content: const Text('Bạn có chắc muốn xóa mẫu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTemplate(templateId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TemplateDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onApply;

  const _TemplateDetailsDialog({
    required this.template,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(
      template['items'] ?? [],
    );

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple,
                    Colors.purple.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      template['template_name'] ?? '',
                      style: const TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatChip(
                          Icons.restaurant_menu,
                          '${items.length} món',
                          Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          Icons.replay,
                          '${template['times_used'] ?? 0} lần',
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Các món ăn:',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item['food_name']}',
                                style: const TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${item['portion_g']}g',
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontSize: 13,
                                  color: FitnessAppTheme.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FitnessAppTheme.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onApply();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Áp dụng mẫu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
