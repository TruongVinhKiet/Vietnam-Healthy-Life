import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/recipe_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class RecipeBuilderDialog extends StatefulWidget {
  final VoidCallback onRecipeCreated;

  const RecipeBuilderDialog({
    super.key,
    required this.onRecipeCreated,
  });

  @override
  State<RecipeBuilderDialog> createState() => _RecipeBuilderDialogState();
}

class _RecipeBuilderDialogState extends State<RecipeBuilderDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController(
    text: '1',
  );
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final RecipeService _recipeService = RecipeService();
  final List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final envUrl = const String.fromEnvironment('API_URL', defaultValue: '');
      final baseUrl = envUrl.isNotEmpty ? envUrl : ApiConfig.baseUrl;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/foods/search?q=$query&limit=10'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['foods'] ?? []);
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  void _addIngredient(Map<String, dynamic> food) {
    showDialog(
      context: context,
      builder: (context) => _AddIngredientDialog(
        food: food,
        onAdd: (quantity) {
          setState(() {
            _ingredients.add({
              'food_id': food['food_id'] ?? food['id'],
              'food_name': food['name'],
              'quantity_g': quantity,
            });
            _searchController.clear();
            _searchResults = [];
          });
        },
      ),
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công thức')),
      );
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 nguyên liệu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _recipeService.createRecipe(
        recipeName: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        servings: int.tryParse(_servingsController.text) ?? 1,
        ingredients: _ingredients,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã tạo công thức thành công!')),
        );
        widget.onRecipeCreated();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo công thức: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
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
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Tạo công thức mới',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên công thức',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả (tùy chọn)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _servingsController,
                      decoration: InputDecoration(
                        labelText: 'Số khẩu phần',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    // Ingredients section
                    const Text(
                      'Nguyên liệu:',
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search food
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm thực phẩm...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        if (value.length > 2) {
                          _searchFood(value);
                        }
                      },
                    ),
                    if (_isSearching)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: FitnessAppTheme.grey.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final food = _searchResults[index];
                            return ListTile(
                              title: Text(food['name'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _addIngredient(food),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Ingredients list
                    if (_ingredients.isNotEmpty)
                      ..._ingredients.asMap().entries.map((entry) {
                        final index = entry.key;
                        final ing = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.restaurant,
                              color: FitnessAppTheme.nearlyBlue,
                            ),
                            title: Text(ing['food_name']),
                            subtitle: Text('${ing['quantity_g']}g'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _removeIngredient(index),
                            ),
                          ),
                        );
                      }),
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
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FitnessAppTheme.nearlyBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Lưu công thức'),
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
}

class _AddIngredientDialog extends StatefulWidget {
  final Map<String, dynamic> food;
  final Function(double) onAdd;

  const _AddIngredientDialog({
    required this.food,
    required this.onAdd,
  });

  @override
  State<_AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<_AddIngredientDialog> {
  final TextEditingController _quantityController = TextEditingController(
    text: '100',
  );

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm nguyên liệu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.food['name'] ?? '',
            style: const TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(
              labelText: 'Khối lượng (g)',
              border: OutlineInputBorder(),
              suffixText: 'g',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
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
            final quantity = double.tryParse(_quantityController.text) ?? 100;
            Navigator.pop(context);
            widget.onAdd(quantity);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: FitnessAppTheme.nearlyBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
