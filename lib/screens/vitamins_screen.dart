// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/vitamin_detail_screen.dart';
import 'package:my_diary/widgets/nutrient_grid_card.dart';

class VitaminsScreen extends StatefulWidget {
  const VitaminsScreen({super.key});

  @override
  _VitaminsScreenState createState() => _VitaminsScreenState();
}

class _VitaminsScreenState extends State<VitaminsScreen> {
  List<Map<String, dynamic>>? vitamins;
  bool loading = true;
  Map<String, double> consumptionMap = {}; // Store consumption percentages

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
    });

    // Load vitamins list
    final rows = await AuthService.getVitamins();

    // Load consumption tracking
    final nutrients = await AuthService.getDailyNutrientTracking();
    final Map<String, double> consumption = {};

    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
          'vitamin') {
        final code = nutrient['nutrient_code'] as String?;
        final percentage = nutrient['percentage'];

        if (code != null && percentage != null) {
          final pct = (percentage is num)
              ? percentage.toDouble()
              : double.tryParse(percentage.toString()) ?? 0.0;
          consumption[code] = pct.clamp(0.0, 100.0);
        }
      }
    }

    setState(() {
      vitamins = rows;
      consumptionMap = consumption;
      loading = false;
    });
  }

  Color colorForCode(String code) {
    const map = {
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
    return Color(map[code] ?? 0xFF8A98E8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vitamins'), centerTitle: true),
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
              itemCount: vitamins?.length ?? 0,
              itemBuilder: (ctx, i) {
                final v = vitamins![i];
                final code = (v['code'] ?? '').toString();
                final name = (v['name'] ?? '').toString();

                // Get consumption percentage from tracking API
                double percent = consumptionMap[code] ?? 0.0;

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
                    final id = v['vitamin_id'] is int
                        ? v['vitamin_id'] as int
                        : int.tryParse('${v['vitamin_id']}');
                    final code = v['code']?.toString();
                    if (id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VitaminDetailScreen(
                            vitaminId: id,
                            title: name,
                            code: code,
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
