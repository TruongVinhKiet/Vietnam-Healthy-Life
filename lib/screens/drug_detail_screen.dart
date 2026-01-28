import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../config/api_config.dart';
import '../models/drug_model.dart';
import '../models/health_condition_model.dart';
import 'health_condition_detail_screen.dart';

/// Comprehensive Drug Detail Screen
class DrugDetailScreen extends StatefulWidget {
  final int drugId;
  final String drugName;

  const DrugDetailScreen({
    super.key,
    required this.drugId,
    required this.drugName,
  });

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  Drug? _drug;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDrugDetails();
  }

  Future<void> _loadDrugDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/drugs/${widget.drugId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['drug'] != null) {
          setState(() {
            _drug = Drug.fromJson(data['drug']);
            _isLoading = false;
          });
        } else {
          throw Exception(data['error'] ?? 'Không tìm thấy thông tin thuốc');
        }
      } else {
        throw Exception('Lỗi tải dữ liệu: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getDrugClassColor() {
    final drugClass = _drug?.drugClass?.toLowerCase() ?? '';
    if (drugClass.contains('vitamin') || drugClass.contains('dinh dưỡng')) {
      return Colors.orange;
    } else if (drugClass.contains('kháng sinh') ||
        drugClass.contains('antibiotic')) {
      return Colors.red.shade700;
    } else if (drugClass.contains('đau') ||
        drugClass.contains('pain') ||
        drugClass.contains('analgesic')) {
      return Colors.blue;
    } else if (drugClass.contains('đái tháo đường') ||
        drugClass.contains('diabetes')) {
      return Colors.green;
    } else if (drugClass.contains('tim mạch') ||
        drugClass.contains('cardiovascular')) {
      return Colors.pink;
    }
    return Colors.purple;
  }

  String _getDrugClassIcon() {
    final drugClass = _drug?.drugClass?.toLowerCase() ?? '';
    if (drugClass.contains('vitamin')) return '💊';
    if (drugClass.contains('kháng sinh')) return '🦠';
    if (drugClass.contains('tiêm')) return '💉';
    if (drugClass.contains('đái tháo đường')) return '🩺';
    if (drugClass.contains('tim mạch')) return '❤️';
    return '🧪';
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _navigateToCondition(int conditionId, String nameVi) async {
    // Show loading while fetching condition details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/conditions/$conditionId'),
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['condition'] != null) {
          final condition = HealthCondition.fromJson(data['condition']);
          final nutrientEffects =
              (data['condition']['nutrient_effects'] as List?)
                  ?.map((e) => NutrientEffect.fromJson(e))
                  .toList() ??
              [];
          final foodsToAvoid =
              (data['condition']['foods_to_avoid'] as List?)
                  ?.map((e) => FoodRecommendation.fromJson(e))
                  .toList() ??
              [];
          final foodsToRecommend =
              (data['condition']['foods_to_recommend'] as List?)
                  ?.map((e) => FoodRecommendation.fromJson(e))
                  .toList() ??
              [];
          final drugs =
              (data['condition']['drugs'] as List?)
                  ?.map((e) => DrugTreatment.fromJson(e))
                  .toList() ??
              [];

          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthConditionDetailScreen(
                condition: condition,
                nutrientEffects: nutrientEffects,
                foodsToAvoid: foodsToAvoid,
                foodsToRecommend: foodsToRecommend,
                drugs: drugs,
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin bệnh')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if still showing
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : _buildDetailView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải thông tin thuốc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Lỗi không xác định',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDrugDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    if (_drug == null) return const SizedBox();

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfoCard(),
              if (_drug!.indicationsVi != null)
                _buildSection(
                  icon: Icons.medical_services,
                  title: 'Chỉ định',
                  child: Text(
                    _drug!.indicationsVi!,
                    style: const TextStyle(height: 1.6),
                  ),
                ),
              if (_drug!.dosageAdultVi != null)
                _buildSection(
                  icon: Icons.medical_information,
                  title: 'Liều dùng',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '👨 Người lớn:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_drug!.dosageAdultVi!),
                      if (_drug!.dosagePediatricVi != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '👶 Trẻ em:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_drug!.dosagePediatricVi!),
                      ],
                    ],
                  ),
                ),
              if (_drug!.mechanismOfActionVi != null)
                _buildSection(
                  icon: Icons.science,
                  title: 'Cơ chế tác dụng',
                  child: Text(
                    _drug!.mechanismOfActionVi!,
                    style: const TextStyle(height: 1.6),
                  ),
                ),
              if (_drug!.interactions != null &&
                  _drug!.interactions!.isNotEmpty)
                _buildSection(
                  icon: Icons.warning_amber,
                  title: 'Tương tác thuốc (${_drug!.interactions!.length})',
                  child: _buildInteractionsContent(),
                ),
              if (_drug!.sideEffects != null && _drug!.sideEffects!.isNotEmpty)
                _buildSection(
                  icon: Icons.health_and_safety,
                  title: 'Tác dụng phụ (${_drug!.sideEffects!.length})',
                  child: _buildSideEffectsContent(),
                ),
              if (_drug!.contraindicationsVi != null)
                _buildSection(
                  icon: Icons.block,
                  title: 'Chống chỉ định',
                  child: Text(
                    _drug!.contraindicationsVi!,
                    style: const TextStyle(height: 1.6),
                  ),
                ),
              if (_drug!.warningsVi != null)
                _buildSection(
                  icon: Icons.warning,
                  title: 'Cảnh báo',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_drug!.blackBoxWarningVi != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.warning, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'CẢNH BÁO QUAN TRỌNG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(_drug!.blackBoxWarningVi!),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        _drug!.warningsVi!,
                        style: const TextStyle(height: 1.6),
                      ),
                    ],
                  ),
                ),
              if (_drug!.overdoseSymptomsVi != null ||
                  _drug!.overdoseTreatmentVi != null)
                _buildSection(
                  icon: Icons.emergency,
                  title: 'Quá liều & Xử lý',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_drug!.overdoseSymptomsVi != null) ...[
                        const Text(
                          '🚨 Triệu chứng:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_drug!.overdoseSymptomsVi!),
                      ],
                      if (_drug!.overdoseTreatmentVi != null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '🏥 Xử trí:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_drug!.overdoseTreatmentVi!),
                      ],
                    ],
                  ),
                ),
              if (_drug!.pregnancyNotesVi != null ||
                  _drug!.lactationNotesVi != null)
                _buildSection(
                  icon: Icons.pregnant_woman,
                  title: 'Thai kỳ & Cho con bú',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_drug!.pregnancyCategory != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'FDA Category: ${_drug!.pregnancyCategory}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (_drug!.pregnancyNotesVi != null) ...[
                        const Text(
                          '🤰 Thai kỳ:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_drug!.pregnancyNotesVi!),
                      ],
                      if (_drug!.lactationNotesVi != null) ...[
                        const SizedBox(height: 12),
                        const Text(
                          '🤱 Cho con bú:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_drug!.lactationNotesVi!),
                      ],
                    ],
                  ),
                ),
              if (_drug!.storageConditionsVi != null)
                _buildSection(
                  icon: Icons.storage,
                  title: 'Điều kiện bảo quản',
                  child: Text(
                    _drug!.storageConditionsVi!,
                    style: const TextStyle(height: 1.6),
                  ),
                ),
              if (_drug!.articleLinkVi != null || _drug!.articleLinkEn != null)
                _buildSection(
                  icon: Icons.article,
                  title: 'Tài liệu tham khảo',
                  child: Column(
                    children: [
                      if (_drug!.articleLinkVi != null)
                        InkWell(
                          onTap: () => _launchURL(_drug!.articleLinkVi),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.link, color: Colors.blue),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Bài viết tiếng Việt',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        ),
                      if (_drug!.articleLinkEn != null) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _launchURL(_drug!.articleLinkEn),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.language, color: Colors.green),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'International Article',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_drug!.relatedConditions != null &&
                  _drug!.relatedConditions!.isNotEmpty)
                _buildSection(
                  icon: Icons.healing,
                  title:
                      'Điều trị các bệnh (${_drug!.relatedConditions!.length})',
                  child: _buildRelatedConditionsContent(),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: _getDrugClassColor(),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.drugName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_drug?.imageUrl != null && _drug!.imageUrl!.isNotEmpty)
              Image.network(
                _drug!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildGradientBackground(),
              )
            else
              _buildGradientBackground(),
            Positioned(
              bottom: 80,
              right: 20,
              child: Text(
                _getDrugClassIcon(),
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_getDrugClassColor().withValues(alpha: 0.7), _getDrugClassColor()],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_drug!.brandNameVi != null)
              _buildInfoRow('Tên thương mại', _drug!.brandNameVi!),
            if (_drug!.genericName != null)
              _buildInfoRow('Hoạt chất', _drug!.genericName!),
            if (_drug!.drugClass != null)
              Row(
                children: [
                  const Text(
                    'Nhóm thuốc: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDrugClassColor().withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getDrugClassColor()),
                      ),
                      child: Text(
                        _drug!.drugClass!,
                        style: TextStyle(
                          color: _getDrugClassColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (_drug!.strength != null)
              _buildInfoRow('Hàm lượng', _drug!.strength!),
            if (_drug!.dosageForm != null)
              _buildInfoRow('Dạng bào chế', _drug!.dosageForm!),
            if (_drug!.packaging != null)
              _buildInfoRow('Quy cách', _drug!.packaging!),
            if (_drug!.descriptionVi != null) ...[
              const Divider(height: 24),
              const Text(
                'Mô tả:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(_drug!.descriptionVi!, style: const TextStyle(height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: _getDrugClassColor()),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        initiallyExpanded:
            title.contains('Chỉ định') || title.contains('Liều dùng'),
        children: [Padding(padding: const EdgeInsets.all(16), child: child)],
      ),
    );
  }

  Widget _buildInteractionsContent() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _drug!.interactions!.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final interaction = _drug!.interactions![index];
        Color severityColor = interaction.severity == 'major'
            ? Colors.red
            : interaction.severity == 'moderate'
            ? Colors.orange
            : Colors.yellow.shade700;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: severityColor, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: severityColor.withValues(alpha: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    interaction.interactionType == 'drug'
                        ? Icons.medication
                        : interaction.interactionType == 'food'
                        ? Icons.restaurant
                        : Icons.healing,
                    color: severityColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      interaction.interactsWith,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (interaction.descriptionVi != null) ...[
                const SizedBox(height: 8),
                Text(interaction.descriptionVi!),
              ],
              if (interaction.managementVi != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '✅ ${interaction.managementVi!}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideEffectsContent() {
    final seriousEffects = _drug!.sideEffects!
        .where((e) => e.isSerious)
        .toList();
    final commonEffects = _drug!.sideEffects!
        .where((e) => !e.isSerious)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (seriousEffects.isNotEmpty) ...[
          const Text(
            '🚨 Nghiêm trọng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          ...seriousEffects.map(
            (e) => _buildSideEffectItem(e, isSerious: true),
          ),
        ],
        if (commonEffects.isNotEmpty) ...[
          if (seriousEffects.isNotEmpty) const SizedBox(height: 20),
          const Text(
            '💊 Thường gặp',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          ...commonEffects.map((e) => _buildSideEffectItem(e)),
        ],
      ],
    );
  }

  Widget _buildSideEffectItem(DrugSideEffect effect, {bool isSerious = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSerious ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSerious ? Colors.red.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  effect.effectNameVi,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (effect.frequency != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    effect.frequencyLabel,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
          if (effect.descriptionVi != null) ...[
            const SizedBox(height: 6),
            Text(effect.descriptionVi!, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildRelatedConditionsContent() {
    final primaryConditions = _drug!.relatedConditions!
        .where((c) => c.isPrimary)
        .toList();
    final secondaryConditions = _drug!.relatedConditions!
        .where((c) => !c.isPrimary)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (primaryConditions.isNotEmpty) ...[
          const Text(
            '⭐ Chỉ định chính',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...primaryConditions.map(
            (c) => _buildConditionCard(c, isPrimary: true),
          ),
        ],
        if (secondaryConditions.isNotEmpty) ...[
          if (primaryConditions.isNotEmpty) const SizedBox(height: 16),
          const Text(
            '💊 Chỉ định phụ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          ...secondaryConditions.map((c) => _buildConditionCard(c)),
        ],
      ],
    );
  }

  Widget _buildConditionCard(
    RelatedCondition condition, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: () =>
          _navigateToCondition(condition.conditionId, condition.nameVi),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.red.shade50 : Colors.pink.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? Colors.red.shade300 : Colors.pink.shade200,
            width: isPrimary ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                image: condition.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(condition.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: condition.imageUrl == null
                  ? const Icon(Icons.healing, size: 30, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          condition.nameVi,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Chính',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (condition.category != null)
                    Text(
                      condition.category!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
