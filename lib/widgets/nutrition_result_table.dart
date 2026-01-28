import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:my_diary/fitness_app_theme.dart';

class NutritionResultTable extends StatelessWidget {
  final String foodName;
  final double confidence;
  final List<Map<String, dynamic>> nutrients;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isLoading;
  final bool showActions;

  const NutritionResultTable({
    super.key,
    required this.foodName,
    required this.confidence,
    required this.nutrients,
    required this.onApprove,
    required this.onReject,
    this.isLoading = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    // Configuration for macros + water with icons
    final macroConfig = {
      'ENERC_KCAL': {
        'label': 'Calories',
        'unit': 'kcal',
        'color': const Color(0xFFFFB347),
        'icon': Icons.local_fire_department,
      },
      'PROCNT': {
        'label': 'Protein',
        'unit': 'g',
        'color': const Color(0xFF56CCF2),
        'icon': Icons.fitness_center,
      },
      'CHOCDF': {
        'label': 'Carbs',
        'unit': 'g',
        'color': const Color(0xFFFF9A9E),
        'icon': Icons.bakery_dining,
      },
      'FAT': {
        'label': 'Fat',
        'unit': 'g',
        'color': const Color(0xFFF2994A),
        'icon': Icons.water_drop,
      },
      'WATER': {
        'label': 'Water',
        'unit': 'ml',
        'color': const Color(0xFF4FC3F7),
        'icon': Icons.opacity,
      },
    };

    final List<Map<String, dynamic>> macroItems = [];
    final List<Map<String, dynamic>> detailedNutrients = [];

    // Separate macros+water from detailed nutrients
    for (final entry in nutrients) {
      final code = (entry['nutrient_code'] ?? entry['code'])
          ?.toString()
          .toUpperCase();
      if (code != null && macroConfig.containsKey(code)) {
        final cfg = macroConfig[code]!;
        macroItems.add({
          'label': cfg['label'],
          'unit': cfg['unit'],
          'color': cfg['color'],
          'icon': cfg['icon'],
          'amount': entry['amount'] ?? entry['value'],
        });
      } else {
        detailedNutrients.add(entry);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với tên món ăn
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: FitnessAppTheme.fontName,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.accuracy((confidence * 100).round()),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 13,
                              fontFamily: FitnessAppTheme.fontName,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (macroItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: macroItems
                    .map((macro) => _buildMacroChip(macro))
                    .toList(),
              ),
            ),
          ],
          // Bảng dinh dưỡng
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.nutritionComposition,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    fontFamily: FitnessAppTheme.fontName,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Header row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                AppLocalizations.of(context)!.nutrient,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontFamily: FitnessAppTheme.fontName,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                AppLocalizations.of(context)!.amount,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontFamily: FitnessAppTheme.fontName,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nutrient rows
                      ...detailedNutrients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final nutrient = entry.value;
                        final isLast = index == detailedNutrients.length - 1;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? Colors.white
                                : Colors.grey.shade50,
                            border: Border(
                              bottom: isLast
                                  ? BorderSide.none
                                  : BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  nutrient['nutrient_name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF34495E),
                                    fontFamily: FitnessAppTheme.fontName,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${nutrient['amount']} ${nutrient['unit']}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF27AE60),
                                    fontFamily: FitnessAppTheme.fontName,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          if (showActions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.close, size: 22),
                      label: Text(
                        AppLocalizations.of(context)!.reject,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: FitnessAppTheme.fontName,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.check, size: 22),
                      label: Text(
                        isLoading
                            ? AppLocalizations.of(context)!.saving
                            : AppLocalizations.of(context)!.accept,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: FitnessAppTheme.fontName,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(Map<String, dynamic> macro) {
    final amount = macro['amount'];
    final unit = macro['unit'] ?? '';
    final display = amount != null ? '$amount $unit' : '--';
    final icon = macro['icon'] as IconData?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (macro['color'] as Color).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (macro['color'] as Color).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: (macro['color'] as Color)),
            const SizedBox(width: 8),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                macro['label'] ?? '',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: (macro['color'] as Color).withValues(alpha: 0.8),
                  fontFamily: FitnessAppTheme.fontName,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                display,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (macro['color'] as Color),
                  fontFamily: FitnessAppTheme.fontName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
