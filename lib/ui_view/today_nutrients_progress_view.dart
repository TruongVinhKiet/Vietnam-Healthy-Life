import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../services/meal_service.dart';
import '../l10n/app_localizations.dart';

class TodayNutrientsProgressView extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TodayNutrientsProgressView({
    super.key,
    this.animationController,
    this.animation,
  });

  @override
  createState() => _TodayNutrientsProgressViewState();
}

class _TodayNutrientsProgressViewState extends State<TodayNutrientsProgressView>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _todayMeals;

  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }

  Future<void> _loadTodayMeals() async {
    setState(() => _isLoading = true);

    try {
      final meals = await MealService.getTodayMeals();
      setState(() {
        _todayMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading today meals: $e');
      setState(() => _isLoading = false);
    }
  }

  double _getProgress(String nutrientName, String unit) {
    if (_todayMeals == null || _todayMeals!['nutrients'] == null) {
      return 0.0;
    }

    final nutrients = _todayMeals!['nutrients'] as Map<String, dynamic>?;
    if (nutrients == null) return 0.0;

    // Get consumed amount
    final consumed = (nutrients[nutrientName] as num?)?.toDouble() ?? 0.0;

    // Estimated daily targets (you should load from user profile)
    final targets = <String, double>{
      // Vitamins (mg or μg)
      'Vitamin A': 900.0, // μg
      'Vitamin C': 90.0, // mg
      'Vitamin D': 20.0, // μg
      'Vitamin E': 15.0, // mg
      'Vitamin B12': 2.4, // μg
      'Vitamin B6': 1.7, // mg
      'Folate': 400.0, // μg
      
      // Minerals (mg)
      'Calcium': 1000.0,
      'Iron': 18.0,
      'Magnesium': 400.0,
      'Zinc': 11.0,
      'Potassium': 3500.0,
      'Sodium': 2300.0,
      
      // Amino Acids (g)
      'Tryptophan': 0.8,
      'Threonine': 1.5,
      'Isoleucine': 1.9,
      'Leucine': 4.2,
      'Lysine': 3.8,
      'Methionine': 1.9,
      'Phenylalanine': 2.5,
      'Valine': 2.5,
      'Histidine': 1.4,
      
      // Macros
      'Total Fat': 70.0, // g
      'Fiber': 30.0, // g
    };

    final target = targets[nutrientName] ?? 100.0;
    return (consumed / target).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
              0.0,
              30 * (1.0 - widget.animation!.value),
              0.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: 18,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FitnessAppTheme.nearlyBlue,
                      HexColor('#6F56E8'),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withValues(alpha: 0.6),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tiến Độ Dinh Dưỡng Hôm Nay',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Theo dõi vitamin, khoáng chất & dinh dưỡng',
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: _loadTodayMeals,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        )
                      else if (_todayMeals == null)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(context)!.noMealData,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            _buildNutrientsSection(
                              'Vitamins',
                              Icons.local_pharmacy,
                              Colors.orange,
                              [
                                'Vitamin A',
                                'Vitamin C',
                                'Vitamin D',
                                'Vitamin E',
                                'Vitamin B12',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildNutrientsSection(
                              'Khoáng Chất',
                              Icons.diamond_outlined,
                              Colors.cyan,
                              [
                                'Calcium',
                                'Iron',
                                'Magnesium',
                                'Zinc',
                                'Potassium',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildNutrientsSection(
                              'Amino Acids',
                              Icons.science_outlined,
                              Colors.pink,
                              [
                                'Leucine',
                                'Lysine',
                                'Valine',
                                'Isoleucine',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildNutrientsSection(
                              'Khác',
                              Icons.eco_outlined,
                              Colors.green,
                              [
                                'Total Fat',
                                'Fiber',
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientsSection(
    String title,
    IconData icon,
    Color color,
    List<String> nutrients,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...nutrients.map((nutrient) {
            final progress = _getProgress(nutrient, 'mg');
            final percentage = (progress * 100).toInt();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        nutrient,
                        style: const TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress < 0.5
                            ? Colors.red.shade300
                            : progress < 0.8
                                ? Colors.orange.shade300
                                : Colors.green.shade300,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// HexColor helper
class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}
