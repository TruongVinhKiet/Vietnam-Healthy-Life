import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/health_condition_model.dart';
import 'health_condition_detail_screen.dart';

class HealthConditionExploreScreen extends StatefulWidget {
  const HealthConditionExploreScreen({super.key});

  @override
  State<HealthConditionExploreScreen> createState() =>
      _HealthConditionExploreScreenState();
}

class _HealthConditionExploreScreenState
    extends State<HealthConditionExploreScreen>
    with SingleTickerProviderStateMixin {
  List<HealthCondition> _allConditions = [];
  List<HealthCondition> _filteredConditions = [];
  List<String> _categories = ['Tất cả'];
  String _selectedCategory = 'Tất cả';
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadConditions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConditions() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conditionsData = data['conditions'] ?? data;
        final conditionsList = (conditionsData is List) ? conditionsData : [];

        final conditions = conditionsList
            .map(
              (json) => HealthCondition.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        // Extract unique categories
        final categoriesSet = <String>{'Tất cả'};
        for (var condition in conditions) {
          if (condition.category != null && condition.category!.isNotEmpty) {
            categoriesSet.add(condition.category!);
          }
        }

        setState(() {
          _allConditions = conditions;
          _filteredConditions = conditions;
          _categories = categoriesSet.toList();
          _isLoading = false;
        });

        _animationController.forward();
      } else {
        debugPrint('Failed to load conditions: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading conditions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tải danh sách: $e')));
      }
    }
  }

  void _filterConditions() {
    setState(() {
      _filteredConditions = _allConditions.where((condition) {
        final matchesCategory =
            _selectedCategory == 'Tất cả' ||
            condition.category == _selectedCategory;
        final matchesSearch =
            _searchQuery.isEmpty ||
            condition.nameVi.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            condition.nameEn.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Tim mạch':
        return Colors.red;
      case 'Chuyển hóa':
        return Colors.orange;
      case 'Gan':
        return Colors.brown;
      case 'Tiêu hóa':
        return Colors.green;
      case 'Huyết học':
        return Colors.pink;
      case 'Dinh dưỡng':
        return Colors.amber;
      case 'Miễn dịch':
        return Colors.blue;
      case 'Hô hấp':
        return Colors.teal;
      case 'Thần kinh':
        return Colors.purple;
      case 'Nội tiết':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openConditionDetail(HealthCondition condition) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/health/conditions/${condition.conditionId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final conditionData = data['condition'];

        final nutrientEffects =
            (conditionData['nutrient_effects'] as List<dynamic>?)
                ?.map(
                  (json) =>
                      NutrientEffect.fromJson(json as Map<String, dynamic>),
                )
                .toList() ??
            [];

        final foodsToAvoid =
            (conditionData['foods_to_avoid'] as List<dynamic>?)
                ?.map(
                  (json) =>
                      FoodRecommendation.fromJson(json as Map<String, dynamic>),
                )
                .toList() ??
            [];

        final foodsToRecommend =
            (conditionData['food_recommendations'] as List<dynamic>?)
                ?.map(
                  (json) =>
                      FoodRecommendation.fromJson(json as Map<String, dynamic>),
                )
                .toList() ??
            [];

        final drugs =
            (conditionData['drugs'] as List<dynamic>?)
                ?.map(
                  (json) =>
                      DrugTreatment.fromJson(json as Map<String, dynamic>),
                )
                .toList() ??
            [];

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthConditionDetailScreen(
                condition: condition,
                nutrientEffects: nutrientEffects,
                foodsToAvoid: foodsToAvoid,
                foodsToRecommend: foodsToRecommend,
                drugs: drugs,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade400],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Khám phá bệnh',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm bệnh...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.red.shade400,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                    _filterConditions();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                          _filterConditions();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter
              if (_categories.length > 1)
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                            _filterConditions();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: _getCategoryColor(
                            category == 'Tất cả' ? null : category,
                          ).withValues(alpha: 0.2),
                          checkmarkColor: _getCategoryColor(
                            category == 'Tất cả' ? null : category,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? _getCategoryColor(
                                    category == 'Tất cả' ? null : category,
                                  )
                                : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? _getCategoryColor(
                                    category == 'Tất cả' ? null : category,
                                  )
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Conditions Grid
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      )
                    : _filteredConditions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy bệnh nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _filteredConditions.length,
                        itemBuilder: (context, index) {
                          final condition = _filteredConditions[index];
                          final animation = Tween<double>(begin: 0, end: 1)
                              .animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    (index / _filteredConditions.length) * 0.5,
                                    ((index + 1) / _filteredConditions.length) *
                                            0.5 +
                                        0.5,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: _buildConditionCard(condition),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionCard(HealthCondition condition) {
    final categoryColor = _getCategoryColor(condition.category);

    return GestureDetector(
      onTap: () => _openConditionDetail(condition),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or Icon Header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withValues(alpha: 0.7)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child:
                  condition.imageUrl != null && condition.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.network(
                        condition.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.local_hospital,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.local_hospital,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Badge
                    if (condition.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          condition.category!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Name
                    Text(
                      condition.nameVi,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Chronic Badge
                    if (condition.isChronic)
                      Row(
                        children: [
                          Icon(
                            Icons.update,
                            size: 14,
                            color: Colors.purple.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mạn tính',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w500,
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
    );
  }
}
