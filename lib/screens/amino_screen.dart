// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/services/amino_service.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/screens/amino_detail_screen.dart';
import 'package:my_diary/widgets/nutrient_grid_card.dart';

class AminoScreen extends StatefulWidget {
  const AminoScreen({super.key});

  @override
  _AminoScreenState createState() => _AminoScreenState();
}

class _AminoScreenState extends State<AminoScreen> {
  List<Map<String, dynamic>>? amino;
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
    final rows = await AminoService.getAminoAcids();

    // Load nutrient tracking to get consumption percentages
    final nutrients = await AuthService.getDailyNutrientTracking();
    final Map<String, double> consumption = {};

    for (final nutrient in nutrients) {
      if ((nutrient['nutrient_type']?.toString().toLowerCase() ?? '') ==
          'amino_acid') {
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
      amino = rows;
      consumptionMap = consumption;
      loading = false;
    });
  }

  Color _colorForCode(String code) {
    const map = {
      'HIS': 0xFFB58ED9,
      'ILE': 0xFFA8E6A3,
      'LEU': 0xFFE76F51,
      'LYS': 0xFF4CC9F0,
      'MET': 0xFFF6D55C,
      'PHE': 0xFFF4A7B9,
      'THR': 0xFF76D7C4,
      'TRP': 0xFF6A5ACD,
      'VAL': 0xFFFFB570,
    };
    return Color(map[code] ?? 0xFF8A98E8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Essential amino acids'),
        centerTitle: true,
      ),
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
              itemCount: amino?.length ?? 0,
              itemBuilder: (ctx, i) {
                final v = amino![i];
                final code = (v['code'] ?? '').toString();
                final name = (v['name'] ?? '').toString();

                final double percent = consumptionMap[code] ?? 0.0;

                String subtitle = '';
                if (v.containsKey('user_recommended')) {
                  final r = v['user_recommended'];
                  if (r is Map && r['recommended'] != null) {
                    subtitle = '${r['recommended']} ${r['unit'] ?? ''}';
                  }
                }

                return NutrientGridCard(
                  name: name,
                  subtitle: subtitle,
                  percentage: percent,
                  primaryColor: _colorForCode(code),
                  onTap: () {
                    final id = v['id'] is int
                        ? v['id'] as int
                        : int.tryParse('${v['id']}');
                    if (id != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AminoDetailScreen(aminoId: id, title: name),
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
