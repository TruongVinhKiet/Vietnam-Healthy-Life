import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class MealSelectionDialog extends StatefulWidget {
  final Map<String, int> currentCounts;

  const MealSelectionDialog({Key? key, required this.currentCounts})
    : super(key: key);

  @override
  State<MealSelectionDialog> createState() => _MealSelectionDialogState();
}

class _MealSelectionDialogState extends State<MealSelectionDialog> {
  late Map<String, int> dishCounts;
  late Map<String, int> drinkCounts;

  @override
  void initState() {
    super.initState();
    dishCounts = {
      'breakfast': widget.currentCounts['breakfastDishCount'] ?? 1,
      'lunch': widget.currentCounts['lunchDishCount'] ?? 1,
      'dinner': widget.currentCounts['dinnerDishCount'] ?? 1,
      'snack': widget.currentCounts['snackDishCount'] ?? 1,
    };
    drinkCounts = {
      'breakfast': widget.currentCounts['breakfastDrinkCount'] ?? 1,
      'lunch': widget.currentCounts['lunchDrinkCount'] ?? 1,
      'dinner': widget.currentCounts['dinnerDrinkCount'] ?? 1,
      'snack': widget.currentCounts['snackDrinkCount'] ?? 0,
    };
  }

  String _getMealName(String mealType) {
    final l10n = AppLocalizations.of(context)!;
    switch (mealType) {
      case 'breakfast':
        return l10n.breakfast;
      case 'lunch':
        return l10n.lunch;
      case 'dinner':
        return l10n.dinner;
      case 'snack':
        return l10n.snack;
      default:
        return mealType;
    }
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: Colors.orange),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.chooseMealCountsTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.chooseMealCountsSubtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ...['breakfast', 'lunch', 'dinner', 'snack'].map((mealType) {
                return _buildMealSection(mealType);
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final result = <String, int>{
              'breakfastDishCount': dishCounts['breakfast']!,
              'lunchDishCount': dishCounts['lunch']!,
              'dinnerDishCount': dishCounts['dinner']!,
              'snackDishCount': dishCounts['snack']!,
              'breakfastDrinkCount': drinkCounts['breakfast']!,
              'lunchDrinkCount': drinkCounts['lunch']!,
              'dinnerDrinkCount': drinkCounts['dinner']!,
              'snackDrinkCount': drinkCounts['snack']!,
            };
            Navigator.pop(context, result);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }

  Widget _buildMealSection(String mealType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getMealIcon(mealType), size: 18, color: Colors.orange),
                const SizedBox(width: 6),
                Text(
                  _getMealName(mealType),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildCounter(
                    label: AppLocalizations.of(context)!.mealLabel,
                    value: dishCounts[mealType]!,
                    onChanged: (val) {
                      setState(() {
                        dishCounts[mealType] = val;
                      });
                    },
                    icon: Icons.restaurant,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCounter(
                    label: AppLocalizations.of(context)!.drinkLabel,
                    value: drinkCounts[mealType]!,
                    onChanged: (val) {
                      setState(() {
                        drinkCounts[mealType] = val;
                      });
                    },
                    icon: Icons.local_drink,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter({
    required String label,
    required int value,
    required Function(int) onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: IconButton(
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: color,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
            Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Flexible(
              child: IconButton(
                onPressed: value < 2 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: value < 2 ? color : Colors.grey,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
