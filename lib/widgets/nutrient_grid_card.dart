import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/ui_view/wave_view.dart';

/// A grid card for displaying nutrients with consumption tracking
class NutrientGridCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final double percentage;
  final Color primaryColor;
  final VoidCallback onTap;

  const NutrientGridCard({
    super.key,
    required this.name,
    this.subtitle,
    required this.percentage,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular progress with wave
              SizedBox(
                width: 72,
                height: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: WaveView(
                    percentageValue: percentage,
                    primaryColor: primaryColor,
                    secondaryColor: primaryColor.withAlpha((0.6 * 255).round()),
                    compact: true,
                    showText: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Name
              Text(
                name,
                style: const TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Subtitle
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
