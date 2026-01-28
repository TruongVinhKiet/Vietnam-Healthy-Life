import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import '../models/daily_meal_suggestion.dart';

class SuggestionCard extends StatelessWidget {
  final DailyMealSuggestion suggestion;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isLoading;

  const SuggestionCard({
    Key? key,
    required this.suggestion,
    this.onTap,
    this.isSelected = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: suggestion.isAccepted
            ? const BorderSide(color: Colors.green, width: 2)
            : isSelected
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (onTap != null && !isLoading) ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (suggestion.imageUrl != null &&
                  suggestion.imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      suggestion.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Icon(
                            suggestion.isDish
                                ? Icons.restaurant_menu
                                : Icons.local_drink,
                            color: Colors.grey[500],
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Header: Name + Type Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      suggestion.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTypeBadge(l10n),
                ],
              ),
              const SizedBox(height: 8),

              // Score + Portions
              Row(
                children: [
                  Icon(Icons.star, size: 18, color: suggestion.getScoreColor()),
                  const SizedBox(width: 4),
                  Text(
                    '${suggestion.score.toStringAsFixed(0)}/100',
                    style: TextStyle(
                      color: suggestion.getScoreColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    suggestion.isDish
                        ? Icons.restaurant_menu
                        : Icons.local_drink,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    suggestion.portionLabel,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description (if exists)
              if (suggestion.description != null &&
                  suggestion.description!.isNotEmpty) ...[
                Text(
                  suggestion.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 8),

              // Action Buttons
              if (suggestion.isAccepted) _buildAcceptedBanner(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(AppLocalizations l10n) {
    final bool isDish = suggestion.dishId != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDish ? Colors.orange[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDish ? Colors.orange : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDish ? Icons.restaurant : Icons.local_drink,
            size: 14,
            color: isDish ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            isDish ? l10n.mealLabel : l10n.drinkLabel,
            style: TextStyle(
              fontSize: 12,
              color: isDish ? Colors.orange : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedBanner(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.acceptedNote,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
