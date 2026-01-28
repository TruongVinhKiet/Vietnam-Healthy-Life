// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/fatty_acid_detail_screen.dart';
import 'package:my_diary/widgets/nutrient_grid_card.dart';

class FatsScreen extends StatefulWidget {
  const FatsScreen({super.key});

  @override
  _FatsScreenState createState() => _FatsScreenState();
}

class _FatsScreenState extends State<FatsScreen> {
  List<Map<String, dynamic>>? fats;
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
    final rows = await AuthService.getFattyAcids();

    // Load nutrient tracking to get consumption percentages
    final nutrients = await AuthService.getDailyNutrientTracking();
    final Map<String, double> consumption = {};

    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
          'fatty_acid') {
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
      fats = rows;
      consumptionMap = consumption;
      loading = false;
    });
  }

  Color colorForCode(String code) {
    const map = {
      'TOTAL_FAT': 0xFFF5B041,
      'SFA': 0xFFE74C3C,
      'MUFA': 0xFF27AE60,
      'PUFA': 0xFF1ABC9C,
      'EPA_DHA': 0xFF3498DB,
      'ALA': 0xFF3498DB,
      'EPA': 0xFF3498DB,
      'DHA': 0xFF3498DB,
      'LA': 0xFFF39C12,
      'TRANS_FAT': 0xFF7F8C8D,
      'CHOLESTEROL': 0xFFC0392B,
    };
    return Color(map[code] ?? 0xFF8A98E8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fat'), centerTitle: true),
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
              itemCount: fats?.length ?? 0,
              itemBuilder: (ctx, i) {
                final v = fats![i];
                final code = (v['code'] ?? '').toString();
                final name = (v['name'] ?? '').toString();

                final double percent = consumptionMap[code] ?? 0.0;

                String subtitle = '';
                if (v.containsKey('recommended_for_user')) {
                  final r = v['recommended_for_user'];
                  if (r is Map && r['value'] != null) {
                    subtitle = '${r['value']} ${r['unit'] ?? ''}';
                  }
                }

                return NutrientGridCard(
                  name: name,
                  subtitle: subtitle,
                  percentage: percent,
                  primaryColor: colorForCode(code),
                  onTap: () {
                    final id = v['fatty_acid_id'] is int
                        ? v['fatty_acid_id'] as int
                        : int.tryParse('${v['fatty_acid_id']}');
                    if (id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FattyAcidDetailScreen(
                            fattyAcidId: id,
                            title: name,
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
