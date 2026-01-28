import 'package:flutter/material.dart';
import 'package:my_diary/screens/create_drink_screen.dart';
import 'package:my_diary/screens/drink_detail_screen.dart';
import 'package:my_diary/services/drink_service.dart';
import '../config/api_config.dart';

class DrinkGalleryScreen extends StatefulWidget {
  const DrinkGalleryScreen({super.key});

  @override
  State<DrinkGalleryScreen> createState() => _DrinkGalleryScreenState();
}

class _DrinkGalleryScreenState extends State<DrinkGalleryScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _drinks = [];
  List<Map<String, dynamic>> _filtered = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Tất cả', 'icon': Icons.local_drink},
    {'id': 'water', 'name': 'Nước', 'icon': Icons.water_drop},
    {'id': 'tea', 'name': 'Trà', 'icon': Icons.coffee},
    {'id': 'coffee', 'name': 'Cà phê', 'icon': Icons.local_cafe},
    {'id': 'juice', 'name': 'Nước ép', 'icon': Icons.blender},
    {'id': 'smoothie', 'name': 'Sinh tố', 'icon': Icons.icecream},
    {'id': 'milk', 'name': 'Sữa', 'icon': Icons.baby_changing_station},
    {'id': 'herbal', 'name': 'Thảo mộc', 'icon': Icons.eco},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadDrinks();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDrinks() async {
    setState(() => _isLoading = true);
    final drinks = await DrinkService.fetchCatalog();
    if (!mounted) return;
    setState(() {
      _drinks = drinks;
      _filter();
      _isLoading = false;
    });
    _animationController.forward(from: 0);
  }

  void _filter() {
    setState(() {
      _filtered = _drinks.where((drink) {
        final matchesCategory =
            _selectedCategory == 'all' ||
            (drink['category'] ?? '').toString() == _selectedCategory;
        final name = (drink['vietnamese_name'] ?? drink['name'] ?? '')
            .toString()
            .toLowerCase();
        final matchesSearch =
            _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadDrinks,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.blue.shade600,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Công thức nước uống',
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
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _filter();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm đồ uống...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
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
                              color: isSelected ? Colors.white : Colors.blue,
                            ),
                            const SizedBox(width: 6),
                            Text(category['name']),
                          ],
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category['id'];
                          });
                          _filter();
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue.shade600,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: isSelected ? 4 : 1,
                        shadowColor: Colors.blue.shade200,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Không tìm thấy đồ uống')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildDrinkCard(_filtered[index], index),
                    childCount: _filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateDrinkScreen()),
          );
          if (result == true) {
            _loadDrinks();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tạo đồ uống',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildDrinkCard(Map<String, dynamic> drink, int index) {
    final animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index / (_filtered.isEmpty ? 1 : _filtered.length)).clamp(0.0, 1.0),
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    final nutrients = (drink['nutrients'] as Map?) ?? {};
    final kcal = _toDouble(nutrients['ENERC_KCAL']);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => DrinkDetailScreen(
                drinkId: drink['drink_id'] as int,
                initialDrink: drink,
              ),
            ),
          );
          if (result == true) {
            _loadDrinks();
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child:
                        drink['image_url'] != null &&
                            drink['image_url'].toString().isNotEmpty
                        ? Image.network(
                            drink['image_url'].toString().startsWith('http')
                                ? drink['image_url']
                                : '${ApiConfig.baseUrl}${drink['image_url']}',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.blue.shade50,
                                child: const Center(
                                  child: Icon(
                                    Icons.local_drink,
                                    size: 40,
                                    color: Colors.blue,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 120,
                            color: Colors.blue.shade50,
                            child: const Center(
                              child: Icon(
                                Icons.local_drink,
                                size: 40,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            drink['vietnamese_name'] ?? drink['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${kcal.toStringAsFixed(0)}kcal',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Show delete icon for user-owned drinks
            if (drink['is_custom'] == true && drink['user_id'] != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa đồ uống'),
                          content: const Text(
                            'Bạn có chắc muốn xóa đồ uống này?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await DrinkService.deleteCustomDrink(drink['drink_id']);
                        _loadDrinks();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
