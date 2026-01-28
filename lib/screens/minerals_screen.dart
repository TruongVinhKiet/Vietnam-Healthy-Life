// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/mineral_detail_screen.dart';
import 'package:my_diary/widgets/nutrient_grid_card.dart';

class MineralsScreen extends StatefulWidget {
  const MineralsScreen({super.key});

  @override
  _MineralsScreenState createState() => _MineralsScreenState();
}

class _MineralsScreenState extends State<MineralsScreen> {
  List<Map<String, dynamic>>? minerals;
  Map<String, double> consumptionMap = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
    });
    final rows = await AuthService.getMinerals();

    // Load nutrient tracking to get consumption percentages
    final nutrients = await AuthService.getDailyNutrientTracking();
    final Map<String, double> consumption = {};
    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
          'mineral') {
        final code = nutrient['nutrient_code'] as String?;
        final pct = nutrient['percentage'];
        if (code != null && pct != null) {
          final percentage = pct is double
              ? pct
              : double.tryParse(pct.toString()) ?? 0.0;
          // Clamp at 100%
          consumption[code] = percentage.clamp(0.0, 100.0);
        }
      }
    }

    setState(() {
      minerals = rows;
      consumptionMap = consumption;
      loading = false;
    });
  }

  Color colorForCode(String code) {
    const map = {
      'CA': 0xFF1E90FF,
      'P': 0xFF9370DB,
      'MG': 0xFF00CED1,
      'K': 0xFFFF8C00,
      'NA': 0xFFB22222,
      'FE': 0xFF8B4513,
      'ZN': 0xFFDAA520,
      'CU': 0xFFCD5C5C,
      'MN': 0xFF6A5ACD,
      'I': 0xFF20B2AA,
      'SE': 0xFF708090,
      'CR': 0xFFB0C4DE,
      'MO': 0xFF2E8B57,
      'F': 0xFF4682B4,
    };
    return Color(map[code] ?? 0xFF8A98E8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minerals'), centerTitle: true),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: minerals?.length ?? 0,
              itemBuilder: (ctx, i) {
                final v = minerals![i];
                final code = (v['code'] ?? '').toString();
                final name = (v['name'] ?? '').toString();

                final mineralCode = 'MIN_$code';
                final double percent = consumptionMap[mineralCode] ?? 0.0;

                String subtitle = '';
                if (v.containsKey('recommended_for_user')) {
                  final r = v['recommended_for_user'];
                  if (r is Map && r['value'] != null) {
                    subtitle = '${r['value']} ${r['unit'] ?? ''}';
                  }
                } else if (v['recommended_daily'] != null) {
                  subtitle = '${v['recommended_daily']} ${v['unit'] ?? ''}';
                }

                return NutrientGridCard(
                  name: name,
                  subtitle: subtitle,
                  percentage: percent,
                  primaryColor: colorForCode(code),
                  onTap: () {
                    final id = v['mineral_id'] is int
                        ? v['mineral_id'] as int
                        : int.tryParse('${v['mineral_id']}');
                    if (id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MineralDetailScreen(
                            mineralId: id,
                            title: name,
                            code: mineralCode,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
