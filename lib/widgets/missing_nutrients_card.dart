import 'package:flutter/material.dart';

class MissingNutrientsCard extends StatelessWidget {
  final Map<String, dynamic>? macros;
  final List<dynamic>? missingNutrients;
  final String title;

  const MissingNutrientsCard({
    super.key,
    required this.macros,
    required this.missingNutrients,
    this.title = 'Chất còn thiếu trong ngày',
  });

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _fmt(dynamic v) {
    final n = _num(v);
    if (n >= 100) return n.toStringAsFixed(0);
    if (n >= 10) return n.toStringAsFixed(1);
    return n.toStringAsFixed(2);
  }

  Map<String, dynamic>? _macro(String key) {
    final m = macros;
    if (m == null) return null;
    final v = m[key];
    if (v is Map<String, dynamic>) return v;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final kcal = _macro('kcal');
    final protein = _macro('protein');
    final fat = _macro('fat');
    final carb = _macro('carb');
    final water = _macro('water');

    final macroRows = <_MacroRow>[];
    if (kcal != null && _num(kcal['missing']) > 0) {
      macroRows.add(_MacroRow('Kcal', kcal['missing'], kcal['unit'] ?? 'kcal'));
    }
    if (protein != null && _num(protein['missing']) > 0) {
      macroRows.add(
        _MacroRow('Protein', protein['missing'], protein['unit'] ?? 'g'),
      );
    }
    if (fat != null && _num(fat['missing']) > 0) {
      macroRows.add(_MacroRow('Fat', fat['missing'], fat['unit'] ?? 'g'));
    }
    if (carb != null && _num(carb['missing']) > 0) {
      macroRows.add(_MacroRow('Carb', carb['missing'], carb['unit'] ?? 'g'));
    }
    if (water != null && _num(water['missing']) > 0) {
      macroRows.add(
        _MacroRow('Water', water['missing'], water['unit'] ?? 'ml'),
      );
    }

    final deficits = (missingNutrients ?? [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final hasAny = macroRows.isNotEmpty || deficits.isNotEmpty;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: hasAny
                    ? () => _showDetails(context, macroRows, deficits)
                    : null,
                child: const Text('Xem chi tiết'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasAny)
            Text(
              'Bạn đã đạt mục tiêu cho hôm nay.',
              style: TextStyle(color: Colors.green[700]),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < macroRows.length; i++) ...[
                    _buildRow(macroRows[i]),
                    if (i != macroRows.length - 1) const Divider(height: 16),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(_MacroRow r) {
    return Row(
      children: [
        Expanded(
          child: Text(
            r.label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '${_fmt(r.missing)} ${r.unit}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _showDetails(
    BuildContext context,
    List<_MacroRow> macros,
    List<Map<String, dynamic>> deficits,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Chi tiết chất còn thiếu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (macros.isNotEmpty) ...[
                  const Text(
                    'Thông số quan trọng',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  for (final m in macros)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child: Text(m.label)),
                          Text('${_fmt(m.missing)} ${m.unit}'),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                ],
                const Text(
                  'Vi chất còn thiếu',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (deficits.isEmpty)
                  const Text('Không có vi chất thiếu.')
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: deficits.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final n = deficits[index];
                        final name = n['nutrient_name']?.toString() ?? 'N/A';
                        final missing = n['missing_amount'];
                        final unit = n['unit']?.toString() ?? '';
                        final type = n['nutrient_type']?.toString() ?? '';
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (type.isNotEmpty)
                                    Text(
                                      type,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text('${_fmt(missing)} $unit'),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MacroRow {
  final String label;
  final dynamic missing;
  final String unit;

  _MacroRow(this.label, this.missing, this.unit);
}
