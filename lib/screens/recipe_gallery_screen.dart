import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import 'dish_detail_screen.dart';
import 'create_dish_screen.dart';
import '../l10n/app_localizations.dart';
import '../config/api_config.dart';

class RecipeGalleryScreen extends StatefulWidget {
  const RecipeGalleryScreen({super.key});

  @override
  RecipeGalleryScreenState createState() => RecipeGalleryScreenState();
}

class RecipeGalleryScreenState extends State<RecipeGalleryScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _dishes = [];
  List<dynamic> _filteredDishes = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _searchQuery = '';
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Tất cả', 'icon': Icons.restaurant},
    {'id': 'noodle', 'name': 'Món mì/bún', 'icon': Icons.ramen_dining},
    {'id': 'rice', 'name': 'Món cơm', 'icon': Icons.rice_bowl},
    {'id': 'soup', 'name': 'Canh/Súp', 'icon': Icons.soup_kitchen},
    {'id': 'appetizer', 'name': 'Khai vị', 'icon': Icons.tapas},
    {'id': 'main_dish', 'name': 'Món chính', 'icon': Icons.dinner_dining},
    {'id': 'bread', 'name': 'Bánh mì', 'icon': Icons.bakery_dining},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadDishes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);

    try {
      final token = await AuthService.getToken();
      // Load both public template dishes and user's own dishes
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dishes = data['data'] ?? [];
          _filterDishes();
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dishes: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterDishes() {
    setState(() {
      _filteredDishes = _dishes.where((dish) {
        final matchesCategory =
            _selectedCategory == 'all' || dish['category'] == _selectedCategory;
        final matchesSearch =
            _searchQuery.isEmpty ||
            (dish['vietnamese_name'] ?? dish['name'] ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Future<void> _deleteDish(dynamic dish) async {
    final dishId = dish['dish_id'];
    final dishName = dish['vietnamese_name'] ?? dish['name'];

    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.deleteDish);
          },
        ),
        content: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.confirmDeleteDish(dishName));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.cancel);
              },
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.delete);
              },
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/dishes/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('Delete response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 && mounted) {
        setState(() {
          // Remove from local state immediately
          _dishes.removeWhere((d) => d['dish_id'] == dishId);
          _filterDishes();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.dishDeleted(dishName));
              },
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        final errorMsg = response.statusCode == 200
            ? 'Success but no data'
            : 'Status: ${response.statusCode}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(l10n.cannotDeleteDish(errorMsg));
              },
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting dish: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text('${l10n.errorColon} $e');
              },
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.green.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Công Thức Nấu Ăn',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black26)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background gradient pattern
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.1),
                              Colors.white.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterDishes();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món ăn...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['id'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'],
                            size: 18,
                            color: isSelected ? Colors.white : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(category['name']),
                        ],
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category['id'];
                          _filterDishes();
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      elevation: isSelected ? 4 : 1,
                      shadowColor: Colors.green.shade200,
                    ),
                  );
                },
              ),
            ),
          ),

          // Dishes Grid
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredDishes.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Không tìm thấy món ăn',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.90,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildDishCard(_filteredDishes[index], index);
                }, childCount: _filteredDishes.length),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);

          final result = await navigator.push(
            MaterialPageRoute(builder: (context) => const CreateDishScreen()),
          );

          if (result == true && mounted) {
            // Reload dishes after creating new one
            _loadDishes();
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Món ăn đã được tạo! Kiểm tra danh sách của bạn.',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tạo Món Ăn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 4,
      ),
    );
  }

  Widget _buildDishCard(dynamic dish, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index / _filteredDishes.length).clamp(0.0, 1.0),
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DishDetailScreen(dishId: dish['dish_id']),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade200,
                              Colors.green.shade400,
                            ],
                          ),
                        ),
                        child: dish['image_url'] != null
                            ? Image.network(
                                dish['image_url'].toString().startsWith('http')
                                    ? dish['image_url']
                                    : '${ApiConfig.baseUrl}${dish['image_url']}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      // Category Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getCategoryName(dish['category']),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ),
                      // Delete button for user's own dishes
                      if (dish['created_by_user'] != null &&
                          dish['created_by_admin'] == null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _deleteDish(dish),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish['vietnamese_name'] ?? dish['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dish['description'] ?? '',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 10,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dish['serving_size_g']}g',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(String? category) {
    final cat = _categories.firstWhere(
      (c) => c['id'] == category,
      orElse: () => {'name': category ?? 'Khác'},
    );
    return cat['name'];
  }
}
