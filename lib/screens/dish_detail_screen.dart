import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../config/api_config.dart';

class DishDetailScreen extends StatefulWidget {
  final int dishId;

  const DishDetailScreen({super.key, required this.dishId});

  @override
  DishDetailScreenState createState() => DishDetailScreenState();
}

class DishDetailScreenState extends State<DishDetailScreen> {
  Map<String, dynamic>? _dish;
  List<dynamic> _ingredients = [];
  List<dynamic> _nutrients = [];
  bool _isLoading = true;
  Set<int> _restrictedFoodIds = {};
  bool _isDishRestricted = false;
  final Map<String, bool> _expandedGroups = {
    'Macros': true,
    'Vitamins': false,
    'Minerals': false,
    'Amino acids': false,
    'Dietary Fiber': false,
    'Fat / Fatty acids': false,
  };

  @override
  void initState() {
    super.initState();
    _loadRestrictedFoods();
    _loadDishDetails();
  }

  Future<void> _loadRestrictedFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/user/restricted-foods'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = List<dynamic>.from(data['restricted_foods'] ?? []);
        setState(() {
          _restrictedFoodIds = list.map((e) => e['food_id'] as int).toSet();
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadDishDetails() async {
    setState(() => _isLoading = true);

    try {
      final token = await AuthService.getToken();

      // Load dish info
      final dishResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/${widget.dishId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Load nutrients
      final nutrientsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/${widget.dishId}/nutrients'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (dishResponse.statusCode == 200) {
        final dishData = json.decode(dishResponse.body);
        setState(() {
          _dish = dishData['data'];
          _ingredients = _dish?['ingredients'] ?? [];
          // Check if any ingredient is restricted
          _isDishRestricted = _ingredients.any(
            (ing) => _restrictedFoodIds.contains(ing['food_id']),
          );
        });

        if (nutrientsResponse.statusCode == 200) {
          final nutrientsData = json.decode(nutrientsResponse.body);
          setState(() {
            _nutrients = nutrientsData['data'] ?? [];
          });
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading dish details: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.dishDetail);
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_dish == null) {
      return Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.dishDetail);
            },
          ),
        ),
        body: Center(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.dishNotFound);
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _dish!['vietnamese_name'] ?? _dish!['name'] ?? '',
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                ),
              ),
              background: _dish!['image_url'] != null
                  ? Image.network(
                      _dish!['image_url'].toString().startsWith('http')
                          ? _dish!['image_url']
                          : '${ApiConfig.baseUrl}${_dish!['image_url']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.green.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade300,
                            Colors.green.shade500,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Card
                if (_dish!['description'] != null)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Mô tả',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_dish!['description']),
                        ],
                      ),
                    ),
                  ),

                // Info Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.restaurant_menu,
                          label: 'Khẩu phần',
                          value: '${_dish!['serving_size_g']}g',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.category,
                          label: 'Danh mục',
                          value: _dish!['category'] ?? 'N/A',
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Ingredients
                if (_ingredients.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_basket,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Nguyên liệu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ..._ingredients.map((ingredient) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ingredient['food_name'] ?? 'N/A',
                                    ),
                                  ),
                                  Text(
                                    '${ingredient['weight_g']}g',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                // Nutrition Facts
                if (_nutrients.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [..._buildNutrientGroups()],
                      ),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isDishRestricted
            ? () {
                final restrictedIngredients = _ingredients
                    .where((ing) => _restrictedFoodIds.contains(ing['food_id']))
                    .map((ing) => ing['food_name'])
                    .join(', ');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Món này chứa thực phẩm bạn cần tránh: $restrictedIngredients',
                    ),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng sẽ được cập nhật sớm!'),
                  ),
                );
              },
        icon: const Icon(Icons.add),
        label: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.addToMeal);
          },
        ),
        backgroundColor: _isDishRestricted
            ? Colors.grey.shade400
            : Colors.green.shade600,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNutrientGroups() {
    // Group nutrients by group_name
    Map<String, List<dynamic>> groupedNutrients = {
      'Macros': [],
      'Vitamins': [],
      'Minerals': [],
      'Amino acids': [],
      'Dietary Fiber': [],
      'Fat / Fatty acids': [],
    };

    for (var nutrient in _nutrients) {
      final groupName = nutrient['group_name'] ?? 'Macros';
      if (groupedNutrients.containsKey(groupName)) {
        groupedNutrients[groupName]!.add(nutrient);
      } else {
        // For ungrouped nutrients (Calories, Protein, Carbs)
        groupedNutrients['Macros']!.add(nutrient);
      }
    }

    // Sort nutrients within each group
    groupedNutrients.forEach((key, value) {
      value.sort(
        (a, b) => (a['nutrient_name'] ?? '').toString().compareTo(
          (b['nutrient_name'] ?? '').toString(),
        ),
      );
    });

    List<Widget> widgets = [];

    groupedNutrients.forEach((groupName, nutrients) {
      if (nutrients.isEmpty) return;

      final isExpanded = _expandedGroups[groupName] ?? false;

      widgets.add(
        Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedGroups[groupName] = !isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getGroupNameInVietnamese(groupName),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${nutrients.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 8),
              ...nutrients.map((nutrient) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          nutrient['nutrient_name'] ?? 'N/A',
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                      Text(
                        '${_formatNutrientValue(nutrient['amount_per_100g'])} ${nutrient['unit'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ],
        ),
      );

      widgets.add(const SizedBox(height: 8));
    });

    return widgets;
  }

  String _getGroupNameInVietnamese(String groupName) {
    const Map<String, String> translations = {
      'Macros': 'Năng lượng & Dinh dưỡng',
      'Vitamins': 'Vitamin',
      'Minerals': 'Khoáng chất',
      'Amino acids': 'Axit amin',
      'Dietary Fiber': 'Chất xơ',
      'Fat / Fatty acids': 'Chất béo & Axit béo',
    };
    return translations[groupName] ?? groupName;
  }

  String _formatNutrientValue(dynamic value) {
    if (value == null) return '0';
    final numValue = double.tryParse(value.toString()) ?? 0;
    if (numValue == numValue.toInt()) {
      return numValue.toInt().toString();
    }
    return numValue.toStringAsFixed(2);
  }
}
