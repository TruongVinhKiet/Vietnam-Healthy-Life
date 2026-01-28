// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/fiber_detail_screen.dart';
import 'package:my_diary/widgets/nutrient_grid_card.dart';

class FibersScreen extends StatefulWidget {
  const FibersScreen({super.key});

  @override
  _FibersScreenState createState() => _FibersScreenState();
}

class _FibersScreenState extends State<FibersScreen> {
  List<Map<String, dynamic>>? fibers;
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
    final rows = await AuthService.getFibers();

    // Load nutrient tracking to get consumption percentages
    final nutrients = await AuthService.getDailyNutrientTracking();
    final Map<String, double> consumption = {};

    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
          'fiber') {
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
      fibers = rows;
      consumptionMap = consumption;
      loading = false;
    });
  }

  Color colorForCode(String code) {
    const map = {
      'TOTAL_FIBER': 0xFF4CAF50,
      'SOLUBLE_FIBER': 0xFF42A5F5,
      'INSOLUBLE_FIBER': 0xFF8D6E63,
      'RESISTANT_STARCH': 0xFFFBC02D,
      'BETA_GLUCAN': 0xFFFFA726,
    };
    return Color(map[code] ?? 0xFF8A98E8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dietary Fiber'), centerTitle: true),
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
              itemCount: fibers?.length ?? 0,
              itemBuilder: (ctx, i) {
                final v = fibers![i];
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
                    final id = v['fiber_id'] is int
                        ? v['fiber_id'] as int
                        : int.tryParse('${v['fiber_id']}');
                    if (id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              FiberDetailScreen(fiberId: id, title: name),
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
