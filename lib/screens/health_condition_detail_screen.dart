import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/health_condition_model.dart';
import 'drug_detail_screen.dart';
import 'edit_health_condition_screen.dart';

class HealthConditionDetailScreen extends StatefulWidget {
  final HealthCondition condition;
  final List<NutrientEffect> nutrientEffects;
  final List<FoodRecommendation> foodsToAvoid;
  final List<FoodRecommendation> foodsToRecommend;
  final List<DrugTreatment> drugs;
  final bool isAdminView;

  const HealthConditionDetailScreen({
    super.key,
    required this.condition,
    this.nutrientEffects = const [],
    this.foodsToAvoid = const [],
    this.foodsToRecommend = const [],
    this.drugs = const [],
    this.isAdminView = false,
  });

  @override
  State<HealthConditionDetailScreen> createState() =>
      _HealthConditionDetailScreenState();
}

class _HealthConditionDetailScreenState
    extends State<HealthConditionDetailScreen> {
  Color _getSeverityColor() {
    switch (widget.condition.severityLevel) {
      case 'mild':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      case 'severe':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityLabel() {
    switch (widget.condition.severityLevel) {
      case 'mild':
        return 'Nhẹ';
      case 'moderate':
        return 'Trung bình';
      case 'severe':
        return 'Nặng';
      case 'critical':
        return 'Nghiêm trọng';
      default:
        return 'Không xác định';
    }
  }

  IconData _getSeverityIcon() {
    switch (widget.condition.severityLevel) {
      case 'mild':
        return Icons.healing;
      case 'moderate':
        return Icons.medical_services;
      case 'severe':
        return Icons.warning;
      case 'critical':
        return Icons.dangerous;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar với hình ảnh
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.condition.nameVi,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.condition.imageUrl != null &&
                      widget.condition.imageUrl!.isNotEmpty)
                    Image.network(
                      widget.condition.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getSeverityColor(),
                              _getSeverityColor().withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getSeverityColor(),
                            _getSeverityColor().withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Edit button for admin
              if (widget.isAdminView)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHealthConditionScreen(
                          condition: widget.condition,
                        ),
                      ),
                    );
                    if (!context.mounted) return;
                    if (result == true) {
                      // Reload the screen if changes were saved
                      Navigator.pop(context, true);
                    }
                  },
                  tooltip: 'Chỉnh sửa',
                ),
              // Badge cho chronic/severe
              if (widget.condition.isChronic)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    avatar: const Icon(
                      Icons.update,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Mạn tính',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.9),
                    padding: const EdgeInsets.all(4),
                  ),
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity & Category Info
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getSeverityColor().withValues(alpha: 0.1),
                        _getSeverityColor().withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getSeverityColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getSeverityIcon(),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mức độ: ${_getSeverityLabel()}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getSeverityColor(),
                              ),
                            ),
                            if (widget.condition.category != null)
                              Text(
                                'Danh mục: ${widget.condition.category}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Description Section
                if (widget.condition.descriptionVi != null &&
                    widget.condition.descriptionVi!.isNotEmpty)
                  _buildSection(
                    title: 'Tổng quan',
                    icon: Icons.description,
                    color: Colors.blue,
                    child: Text(
                      widget.condition.descriptionVi!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),

                // Causes Section
                if (widget.condition.causes != null &&
                    widget.condition.causes!.isNotEmpty)
                  _buildSection(
                    title: 'Nguyên nhân',
                    icon: Icons.warning_amber,
                    color: Colors.orange,
                    child: Text(
                      widget.condition.causes!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),

                // Prevention Tips Section
                if (widget.condition.preventionTipsVi != null &&
                    widget.condition.preventionTipsVi!.isNotEmpty)
                  _buildSection(
                    title: 'Phòng ngừa',
                    icon: Icons.shield,
                    color: Colors.green,
                    child: Text(
                      widget.condition.preventionTipsVi!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),

                // Treatment Duration
                if (widget.condition.treatmentDurationReference != null &&
                    widget.condition.treatmentDurationReference!.isNotEmpty)
                  _buildSection(
                    title: 'Thời gian điều trị',
                    icon: Icons.schedule,
                    color: Colors.teal,
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.teal[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.condition.treatmentDurationReference!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Article Links
                if ((widget.condition.articleLinkVi != null &&
                        widget.condition.articleLinkVi!.isNotEmpty) ||
                    (widget.condition.articleLinkEn != null &&
                        widget.condition.articleLinkEn!.isNotEmpty))
                  _buildSection(
                    title: 'Tài liệu tham khảo',
                    icon: Icons.article,
                    color: Colors.indigo,
                    child: Column(
                      children: [
                        if (widget.condition.articleLinkVi != null &&
                            widget.condition.articleLinkVi!.isNotEmpty)
                          InkWell(
                            onTap: () =>
                                _launchUrl(widget.condition.articleLinkVi!),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.language,
                                    color: Colors.indigo[700],
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Bài viết tiếng Việt',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new,
                                    color: Colors.indigo[700],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.condition.articleLinkVi != null &&
                            widget.condition.articleLinkVi!.isNotEmpty &&
                            widget.condition.articleLinkEn != null &&
                            widget.condition.articleLinkEn!.isNotEmpty)
                          const SizedBox(height: 8),
                        if (widget.condition.articleLinkEn != null &&
                            widget.condition.articleLinkEn!.isNotEmpty)
                          InkWell(
                            onTap: () =>
                                _launchUrl(widget.condition.articleLinkEn!),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.public, color: Colors.blue[700]),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'English Article',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.open_in_new,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // Nutrient Effects Section
                if (widget.nutrientEffects.isNotEmpty)
                  _buildSection(
                    title: 'Điều chỉnh dinh dưỡng',
                    icon: Icons.analytics,
                    color: Colors.amber,
                    child: Column(
                      children: widget.nutrientEffects.map((effect) {
                        final isIncrease = effect.adjustmentPercent > 0;
                        final color = isIncrease ? Colors.green : Colors.orange;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isIncrease
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: color.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  effect.nutrientNameVi ?? effect.nutrientName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: color.shade900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.shade700,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${isIncrease ? '+' : ''}${effect.adjustmentPercent.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Foods to Avoid
                if (widget.foodsToAvoid.isNotEmpty)
                  _buildSection(
                    title: 'Thực phẩm cần tránh',
                    icon: Icons.block,
                    color: Colors.red,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.foodsToAvoid.map((food) {
                        return Chip(
                          avatar: const Icon(
                            Icons.no_food,
                            size: 18,
                            color: Colors.red,
                          ),
                          label: Text(
                            food.foodNameVi ?? food.foodName ?? 'N/A',
                          ),
                          backgroundColor: Colors.red.shade50,
                          side: BorderSide(color: Colors.red.shade200),
                        );
                      }).toList(),
                    ),
                  ),

                // Foods to Recommend
                if (widget.foodsToRecommend.isNotEmpty)
                  _buildSection(
                    title: 'Thực phẩm nên ăn',
                    icon: Icons.restaurant,
                    color: Colors.green,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.foodsToRecommend.map((food) {
                        return Chip(
                          avatar: const Icon(
                            Icons.check_circle,
                            size: 18,
                            color: Colors.green,
                          ),
                          label: Text(
                            food.foodNameVi ?? food.foodName ?? 'N/A',
                          ),
                          backgroundColor: Colors.green.shade50,
                          side: BorderSide(color: Colors.green.shade200),
                        );
                      }).toList(),
                    ),
                  ),

                // Drugs Section
                if (widget.drugs.isNotEmpty)
                  _buildSection(
                    title: 'Thuốc điều trị',
                    icon: Icons.medication,
                    color: Colors.purple,
                    child: Column(
                      children: widget.drugs.map((drug) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: drug.isPrimary
                                    ? Colors.purple
                                    : Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.medication,
                                color: drug.isPrimary
                                    ? Colors.white
                                    : Colors.purple.shade700,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  drug.nameVi,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (drug.isPrimary) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Chính',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: drug.treatmentNotesVi != null
                                ? Text(drug.treatmentNotesVi!)
                                : null,
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DrugDetailScreen(
                                    drugId: drug.drugId,
                                    drugName: drug.nameVi,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
