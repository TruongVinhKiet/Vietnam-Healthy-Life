import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/ui_view/wave_view.dart';
import 'package:my_diary/fitness_app_theme.dart';

class VitaminDetailScreen extends StatefulWidget {
  final int vitaminId;
  final String title;
  final String? code; // Add code parameter for tracking
  
  const VitaminDetailScreen({
    super.key,
    required this.vitaminId,
    required this.title,
    this.code,
  });

  @override
  State<VitaminDetailScreen> createState() => _VitaminDetailScreenState();
}

class _VitaminDetailScreenState extends State<VitaminDetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  double currentPercentage = 0.0;

  // Vitamin color mapping (same as home screen)
  static const colorMap = {
    'VITA': 0xFFFFA500,
    'VITD': 0xFFFFD700,
    'VITE': 0xFF32CD32,
    'VITK': 0xFF006400,
    'VITC': 0xFFFFA07A,
    'VITB1': 0xFF1E90FF,
    'VITB2': 0xFF9370DB,
    'VITB3': 0xFFFFD966,
    'VITB5': 0xFFC0C0C0,
    'VITB6': 0xFF9ACD32,
    'VITB7': 0xFFFF69B4,
    'VITB9': 0xFF00FA9A,
    'VITB12': 0xFFDC143C,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    
    debugPrint('[VitaminDetail] Loading vitamin ${widget.vitaminId}, code: ${widget.code}');
    
    // Load vitamin details
    final res = await AuthService.getVitaminById(widget.vitaminId);
    debugPrint('[VitaminDetail] Vitamin data loaded: ${res?['name']}, code from API: ${res?['code']}');
    
    // Load consumption tracking
    final nutrients = await AuthService.getDailyNutrientTracking();
    debugPrint('[VitaminDetail] Received ${nutrients.length} nutrients from tracking API');
    
    if (!mounted) return;
    
    double percentage = 0.0;
    final code = widget.code ?? res?['code'];
    debugPrint('[VitaminDetail] Using code: $code');
    
    if (code != null) {
      for (final nutrient in nutrients) {
        if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') == 'vitamin' && 
            nutrient['nutrient_code'] == code) {
          final pct = nutrient['percentage'];
          debugPrint('[VitaminDetail] Found matching nutrient: $code = $pct%');
          if (pct is num) {
            percentage = pct.toDouble();
          } else if (pct != null) {
            percentage = double.tryParse(pct.toString()) ?? 0.0;
          }
          break;
        }
      }
    }
    
    debugPrint('[VitaminDetail] Raw percentage: $percentage%, clamped: ${percentage.clamp(0.0, 100.0)}%');
    
    setState(() {
      data = res;
      currentPercentage = percentage.clamp(0.0, 100.0);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = data;
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (v == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy dữ liệu')),
      );
    }

    final code = widget.code ?? v['code'] as String?;
    final int hex = code != null ? (colorMap[code] ?? 0xFF8A98E8) : 0xFF8A98E8;
    final color = Color(hex);

    final chips = <Widget>[];
    if (v['code'] != null) chips.add(Chip(label: Text('Mã: ${v['code']}')));
    if (v['unit'] != null) chips.add(Chip(label: Text('Đơn vị: ${v['unit']}')));
    if (v['recommended_daily'] != null) {
      chips.add(
        Chip(label: Text('RDA: ${v['recommended_daily']} ${v['unit'] ?? ''}')),
      );
    }
    if (v['recommended_for_user'] != null &&
        v['recommended_for_user']['value'] != null) {
      chips.add(
        Chip(
          label: Text(
            'Khuyến nghị cá nhân: ${v['recommended_for_user']['value']} ${v['recommended_for_user']['unit'] ?? ''}',
          ),
        ),
      );
    }

    final foods = ((v['foods'] as List?) ?? const [])
        .map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v)))
        .cast<Map<String, dynamic>>()
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                v['name']?.toString() ?? widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withAlpha((0.8 * 255).round()),
                      color.withAlpha((0.4 * 255).round()),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Prevent overflow
                  children: [
                    const SizedBox(height: 50), // Reduced from 60
                    
                    // Large circular wave meter (like water detail)
                    SizedBox(
                      width: 140, // Reduced from 160
                      height: 140, // Reduced from 160
                      child: Container(
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 5, // Reduced from 6
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha((0.15 * 255).round()),
                              blurRadius: 10, // Reduced from 12
                              offset: const Offset(0, 3), // Reduced from 4
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: WaveView(
                            percentageValue: currentPercentage,
                            primaryColor: color,
                            secondaryColor: color.withAlpha((0.6 * 255).round()),
                            compact: false,
                            showText: false, // Hide built-in text
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12), // Reduced from 16
                    
                    // Current consumption summary with actual percentage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.3 * 255).round()),
                        borderRadius: BorderRadius.circular(18), // Reduced from 20
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${currentPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 22, // Reduced from 24
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2), // Reduced from 4
                          Text(
                            currentPercentage >= 100 
                                ? 'Daily goal achieved!'
                                : '${(100 - currentPercentage).toStringAsFixed(0)}% to reach goal',
                            style: const TextStyle(
                              fontSize: 11, // Reduced from 12
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info chips
                  if (chips.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Benefits section
                  if (v['benefits'] != null && v['benefits'].toString().isNotEmpty) ...[
                    _buildSection(
                      context,
                      title: 'Lợi ích',
                      icon: Icons.info_outline,
                      color: Colors.blue,
                      child: Text(v['benefits'].toString()),
                    ),
                    const SizedBox(height: 16),
                  ] else if (v['description'] != null) ...[
                    _buildSection(
                      context,
                      title: 'Mô tả',
                      icon: Icons.info_outline,
                      color: Colors.blue,
                      child: Text(v['description'].toString()),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Foods section
                  _buildSection(
                    context,
                    title: 'Thực phẩm chứa nhiều',
                    icon: Icons.restaurant_menu,
                    color: Colors.green,
                    child: foods.isEmpty
                        ? const Text('Không có dữ liệu thực phẩm')
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: foods.length,
                            separatorBuilder: (_, __) => const Divider(height: 12),
                            itemBuilder: (context, index) {
                              final f = foods[index];
                              final rank = index + 1;
                              final name = (f['name'] ?? '').toString();
                              final unit = (f['unit'] ?? '').toString();
                              final amt = f['amount'] ?? f['amount_per_100g'];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getRankColor(rank),
                                  child: Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(name),
                                trailing: Text(
                                  amt != null ? '$amt $unit' : unit,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  // Contraindications
                  if (v['contraindications'] != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      title: 'Chống chỉ định',
                      icon: Icons.warning_amber_rounded,
                      color: Colors.orange,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in v['contraindications'] as List)
                            Chip(
                              label: Text(
                                c is Map && c['condition_name'] != null
                                    ? c['condition_name'].toString()
                                    : c.toString(),
                              ),
                              backgroundColor: Colors.orange.shade50,
                            ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }
}

