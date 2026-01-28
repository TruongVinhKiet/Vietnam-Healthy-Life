import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/recipe_service.dart';
import 'package:my_diary/widgets/recipe_builder_dialog.dart';
import '../config/api_config.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final RecipeService _recipeService = RecipeService();
  List<Map<String, dynamic>> _recipes = [];
  bool _isLoading = true;
  final int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    try {
      final result = await _recipeService.getRecipes(page: _currentPage);
      setState(() {
        _recipes = List<Map<String, dynamic>>.from(result['recipes'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text('${l10n.recipeLoadError}: $e');
            },
          )),
        );
      }
    }
  }

  Future<void> _deleteRecipe(int recipeId) async {
    try {
      await _recipeService.deleteRecipe(recipeId);
      _loadRecipes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.recipeDeleted);
            },
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text('${l10n.recipeDeleteError}: $e');
            },
          )),
        );
      }
    }
  }

  Future<void> _addRecipeAsMeal(int recipeId, double servings) async {
    try {
      await _recipeService.addRecipeAsMeal(
        recipeId: recipeId,
        servings: servings,
        mealType: 'lunch',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.recipeAddedToMeal);
            },
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text('${l10n.recipeAddToMealError}: $e');
            },
          )),
        );
      }
    }
  }

  void _showAddRecipeDialog() {
    showDialog(
      context: context,
      builder: (context) => RecipeBuilderDialog(
        onRecipeCreated: () {
          Navigator.pop(context);
          _loadRecipes();
        },
      ),
    );
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) async {
    try {
      final details = await _recipeService.getRecipeById(recipe['recipe_id']);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => _RecipeDetailsDialog(
          recipe: details,
          onAddAsMeal: (servings) => _addRecipeAsMeal(
            recipe['recipe_id'],
            servings,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải chi tiết: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Công Thức Nấu Ăn',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: FitnessAppTheme.nearlyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recipes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRecipes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(_recipes[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRecipeDialog,
        backgroundColor: FitnessAppTheme.nearlyBlue,
        icon: const Icon(Icons.add),
        label: const Text(
          'Tạo công thức',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: FitnessAppTheme.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có công thức nào',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: FitnessAppTheme.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo công thức để lưu món ăn yêu thích',
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 14,
              color: FitnessAppTheme.grey.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddRecipeDialog,
            icon: const Icon(Icons.add),
            label: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.createFirstRecipe);
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: FitnessAppTheme.nearlyBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final totalCalories = recipe['total_calories'] ?? 0;
    final servings = recipe['servings'] ?? 1;
    final caloriesPerServing = (totalCalories / servings).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FitnessAppTheme.nearlyBlue,
                          FitnessAppTheme.nearlyBlue.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['recipe_name'] ?? '',
                          style: const TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$servings khẩu phần • $caloriesPerServing kcal/phần',
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontSize: 12,
                            color: FitnessAppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'add',
                        child: Row(
                          children: [
                            const Icon(Icons.add_circle_outline),
                            const SizedBox(width: 8),
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return Text(l10n.addToMeal);
                              },
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Row(
                              children: [
                                const Icon(Icons.delete_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDelete(recipe['recipe_id']);
                      } else if (value == 'add') {
                        _showAddAsMealDialog(recipe);
                      }
                    },
                  ),
                ],
              ),
              if (recipe['description'] != null) ...[
                const SizedBox(height: 12),
                Text(
                  recipe['description'],
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontSize: 13,
                    color: FitnessAppTheme.grey.withValues(alpha: 0.8),
                  ),
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

  void _confirmDelete(int recipeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa công thức'),
        content: const Text('Bạn có chắc muốn xóa công thức này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecipe(recipeId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAsMealDialog(Map<String, dynamic> recipe) {
    final servingsController = TextEditingController(
      text: '1',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm vào bữa ăn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${recipe['recipe_name']}'),
            const SizedBox(height: 16),
            TextField(
              controller: servingsController,
              decoration: const InputDecoration(
                labelText: 'Số khẩu phần',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final servings = double.tryParse(servingsController.text) ?? 1;
              Navigator.pop(context);
              _addRecipeAsMeal(recipe['recipe_id'], servings);
            },
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.add);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final Function(double) onAddAsMeal;

  const _RecipeDetailsDialog({
    required this.recipe,
    required this.onAddAsMeal,
  });

  @override
  State<_RecipeDetailsDialog> createState() => _RecipeDetailsDialogState();
}

class _RecipeDetailsDialogState extends State<_RecipeDetailsDialog> {
  Set<int> _restrictedFoodIds = {};
  bool _isRecipeRestricted = false;
  bool _detailsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestrictedFoods();
  }

  Future<void> _loadRestrictedFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      if (token == null) {
        setState(() => _detailsLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/user/restricted-foods'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = List<dynamic>.from(data['restricted_foods'] ?? []);
        final restrictedIds = list.map((e) => e['food_id'] as int).toSet();
        
        final ingredients = List<Map<String, dynamic>>.from(
          widget.recipe['ingredients'] ?? [],
        );
        final isRestricted = ingredients.any(
          (ing) => restrictedIds.contains(ing['food_id']),
        );
        
        setState(() {
          _restrictedFoodIds = restrictedIds;
          _isRecipeRestricted = isRestricted;
          _detailsLoading = false;
        });
      } else {
        setState(() => _detailsLoading = false);
      }
    } catch (e) {
      setState(() => _detailsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = List<Map<String, dynamic>>.from(
      widget.recipe['ingredients'] ?? [],
    );
    final servings = widget.recipe['servings'] ?? 1;
    final totalCalories = widget.recipe['total_calories'] ?? 0;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FitnessAppTheme.nearlyBlue,
                    FitnessAppTheme.nearlyBlue.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.recipe['recipe_name'] ?? '',
                      style: const TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _detailsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats
                          Row(
                            children: [
                              _buildStatChip(
                                Icons.restaurant_menu,
                                '$servings khẩu phần',
                                Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                Icons.local_fire_department,
                                '${(totalCalories / servings).toStringAsFixed(0)} kcal',
                                Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Nguyên liệu:',
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...ingredients.map((ing) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.fiber_manual_record,
                                      size: 8,
                                      color: FitnessAppTheme.nearlyBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${ing['food_name']}',
                                      style: const TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${ing['quantity_g']}g',
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontSize: 13,
                                        color: FitnessAppTheme.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FitnessAppTheme.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isRecipeRestricted
                          ? () {
                              final restrictedIngredients = ingredients
                                  .where((ing) => _restrictedFoodIds.contains(ing['food_id']))
                                  .map((ing) => ing['food_name'])
                                  .join(', ');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Công thức này chứa thực phẩm bạn cần tránh: $restrictedIngredients',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          : () {
                              Navigator.pop(context);
                                      widget.onAddAsMeal(1);
                            },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm vào bữa ăn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecipeRestricted
                            ? Colors.grey.shade400
                            : FitnessAppTheme.nearlyBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
