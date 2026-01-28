import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/ui_view/wave_view.dart';

class FattyAcidDetailScreen extends StatefulWidget {
  final int fattyAcidId;
  final String title;
  final String? code;
  
  const FattyAcidDetailScreen({
    super.key,
    required this.fattyAcidId,
    required this.title,
    this.code,
  });

  @override
  State<FattyAcidDetailScreen> createState() => _FattyAcidDetailScreenState();
}

class _FattyAcidDetailScreenState extends State<FattyAcidDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  double currentPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    
    // Load fatty acid details
    final res = await AuthService.getFattyAcidById(widget.fattyAcidId);
    
    // Load nutrient tracking to get consumption percentage
    // Note: Fatty acids are not yet in the tracking function, so this will return 0%
    final nutrients = await AuthService.getDailyNutrientTracking();
    double percentage = 0.0;
    
    // Get the fatty acid code
    final code = widget.code ?? res?['code'];
    
    if (code != null) {
      for (final nutrient in nutrients) {
        if (nutrient['nutrient_code'] == code && 
            (nutrient['nutrient_type']?.toString().toLowerCase() ?? '') == 'fatty_acid') {
          final pct = nutrient['percentage'];
          if (pct != null) {
            final value = pct is double ? pct : double.tryParse(pct.toString()) ?? 0.0;
            percentage = value.clamp(0.0, 100.0);
            break;
          }
        }
      }
    }
    
    if (!mounted) return;
    setState(() {
      data = res;
      currentPercentage = percentage;
      loading = false;
    });
  }

  Color _getFatColor(String? code) {
    if (code == null) return const Color(0xFF8A98E8);
    
    // Fatty acid color mapping (from fat_view.dart)
    const colorMap = {
      'OMEGA3': 0xFF4FC3F7,
      'OMEGA6': 0xFFFFB74D,
      'SATURATED': 0xFFEF5350,
      'UNSATURATED': 0xFF66BB6A,
    };
    
    return Color(colorMap[code] ?? 0xFF8A98E8);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final v = data;
    if (v == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy dữ liệu')),
      );
    }

    final fatName = v['name']?.toString() ?? widget.title;
    final fatCode = v['code']?.toString() ?? '';
    final color = _getFatColor(fatCode);
    
    final foods = ((v['foods'] as List?) ?? const [])
        .map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v)))
        .cast<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Header with circular wave meter
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withAlpha((0.8 * 255).round()),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      
                      // Circular wave meter
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.2 * 255).round()),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: WaveView(
                              percentageValue: currentPercentage,
                              primaryColor: color,
                              secondaryColor: color.withAlpha((0.7 * 255).round()),
                              compact: false,
                              showText: false,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Percentage display
                      Text(
                        '${currentPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Summary text
                      Text(
                        currentPercentage >= 100.0
                            ? 'Daily goal achieved!'
                            : currentPercentage == 0.0
                                ? 'Not yet tracked'
                                : '${(100.0 - currentPercentage).toStringAsFixed(0)}% to reach goal',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 13,
                          color: Colors.white.withAlpha((0.9 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                fatName,
                style: const TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info section
                _buildSection(
                  'Thông tin',
                  Column(
                    children: [
                      if (fatCode.isNotEmpty)
                        _buildInfoRow('Mã', fatCode),
                      _buildInfoRow('Nhóm', 'Fat / Fatty acids'),
                      if (v['unit'] != null)
                        _buildInfoRow('Đơn vị', v['unit'].toString()),
                      if (v['recommended_daily'] != null)
                        _buildInfoRow(
                          'RDA',
                          '${v['recommended_daily']} ${v['unit'] ?? ''}',
                        ),
                      if (v['recommended_for_user'] != null &&
                          v['recommended_for_user']['value'] != null)
                        _buildInfoRow(
                          'Khuyến nghị cá nhân',
                          '${v['recommended_for_user']['value']} ${v['recommended_for_user']['unit'] ?? ''}',
                        ),
                    ],
                  ),
                ),
                
                // Benefits section
                if (v['benefits'] != null && v['benefits'].toString().isNotEmpty)
                  _buildSection(
                    'Lợi ích',
                    Text(
                      v['benefits'].toString(),
                      style: const TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 14,
                        color: FitnessAppTheme.darkText,
                        height: 1.5,
                      ),
                    ),
                  )
                else if (v['description'] != null)
                  _buildSection(
                    'Mô tả',
                    Text(
                      v['description'].toString(),
                      style: const TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 14,
                        color: FitnessAppTheme.darkText,
                        height: 1.5,
                      ),
                    ),
                  ),
                
                // Foods section
                if (foods.isNotEmpty)
                  _buildSection(
                    'Nguồn thực phẩm',
                    Column(
                      children: foods.map((food) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              food['food_name']?.toString() ?? '',
                              style: const TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              '${food['amount_per_100g'] ?? ''} ${v['unit'] ?? ''} / 100g',
                              style: const TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                
                // Contraindications section
                if (v['contraindications'] != null &&
                    (v['contraindications'] as List).isNotEmpty)
                  _buildSection(
                    'Chống chỉ định',
                    Column(
                      children: (v['contraindications'] as List).map((item) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.red.shade50,
                          child: ListTile(
                            leading: Icon(Icons.warning, color: Colors.red.shade700),
                            title: Text(
                              item.toString(),
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                color: Colors.red.shade900,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FitnessAppTheme.darkerText,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 14,
              color: FitnessAppTheme.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FitnessAppTheme.darkerText,
            ),
          ),
        ],
      ),
    );
  }
}
