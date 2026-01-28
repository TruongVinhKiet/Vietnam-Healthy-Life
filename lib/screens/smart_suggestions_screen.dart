import 'package:flutter/material.dart';
import 'package:my_diary/services/smart_suggestion_service.dart';
import 'package:my_diary/widgets/daily_meal_suggestion_tab.dart';
import 'package:my_diary/widgets/missing_nutrients_card.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _context;
  Map<String, dynamic>? _missing;
  List<dynamic> _suggestions = [];
  Set<String> _pinnedIds = {};
  bool _loading = true;
  bool _loadingSuggestions = false;
  bool _loadingMissing = false;
  String _selectedType = 'both';
  int? _selectedLimit = 10;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    // Load context and pinned items
    final contextResult = await SmartSuggestionService.getContext();
    final pinnedResult = await SmartSuggestionService.getPinnedSuggestions();
    setState(() => _loadingMissing = true);
    final missingResult = await SmartSuggestionService.getMissingNutrients();

    if (mounted) {
      setState(() {
        if (contextResult['error'] == null &&
            contextResult['context'] != null) {
          _context = contextResult['context'] as Map<String, dynamic>;
        }

        if (missingResult['error'] == null && missingResult['macros'] != null) {
          _missing = missingResult;
        } else {
          _missing = null;
        }

        if (pinnedResult['error'] == null && pinnedResult['pins'] != null) {
          final pins = pinnedResult['pins'] as List;
          _pinnedIds = pins
              .map((p) => '${p['item_type']}_${p['item_id']}')
              .toSet()
              .cast<String>();
        }

        _loading = false;
        _loadingMissing = false;
      });
    }
  }

  Future<void> _refreshSmartTab() async {
    await _loadData();
    if (_suggestions.isNotEmpty) {
      await _getSuggestions();
    }
  }

  Future<void> _getSuggestions() async {
    setState(() => _loadingSuggestions = true);

    final result = await SmartSuggestionService.getSmartSuggestions(
      type: _selectedType,
      limit: _selectedLimit,
    );

    if (mounted) {
      setState(() {
        if (result['error'] == null && result['suggestions'] != null) {
          _suggestions = result['suggestions'] as List;
          debugPrint(
            '[SmartSuggestions] Received ${_suggestions.length} suggestions',
          );
          debugPrint(
            '[SmartSuggestions] Types: ${_suggestions.map((s) => s['item_type']).toSet()}',
          );
          debugPrint('[SmartSuggestions] Selected type: $_selectedType');
        } else {
          _suggestions = [];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error']?.toString() ?? 'Lỗi tải gợi ý'),
            ),
          );
        }
        _loadingSuggestions = false;
      });
    }
  }

  Future<void> _togglePin(String itemType, int itemId) async {
    final key = '${itemType}_$itemId';
    final isPinned = _pinnedIds.contains(key);

    if (isPinned) {
      final result = await SmartSuggestionService.unpinSuggestion(
        itemType: itemType,
        itemId: itemId,
      );

      if (result['error'] == null) {
        setState(() {
          _pinnedIds.remove(key);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã bỏ ghim')));
        }
      }
    } else {
      final result = await SmartSuggestionService.pinSuggestion(
        itemType: itemType,
        itemId: itemId,
      );

      if (result['error'] == null) {
        setState(() {
          _pinnedIds.add(key);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã ghim gợi ý')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gợi Ý Thông Minh',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.lightbulb), text: 'Gợi Ý Món'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Gợi Ý Ngày'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSmartSuggestionsTab(), const DailyMealSuggestionTab()],
      ),
    );
  }

  Widget _buildSmartSuggestionsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshSmartTab,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildContextSection()),
          SliverToBoxAdapter(
            child: _loadingMissing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : MissingNutrientsCard(
                    macros: _missing?['macros'] as Map<String, dynamic>?,
                    missingNutrients: _missing?['missing_nutrients'] as List?,
                    title: 'Chất còn thiếu trong ngày',
                  ),
          ),
          SliverToBoxAdapter(child: _buildControlPanel()),
          if (_loadingSuggestions)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_suggestions.isEmpty && !_loadingSuggestions)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng thử lại',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildSuggestionsCarousel(),
        ],
      ),
    );
  }

  Widget _buildContextSection() {
    if (_context == null) return const SizedBox.shrink();
    final weather = _context!['weather'] as Map<String, dynamic>?;
    final conditions = _context!['conditions'] as List?;
    final mealPeriod = _context!['mealPeriod'] as String?;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Hiện Tại',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Meal Period
          if (mealPeriod != null)
            _buildInfoRow(
              Icons.restaurant,
              'Bữa ăn',
              _getMealPeriodLabel(mealPeriod),
              Colors.orange,
            ),

          // Weather
          if (weather != null)
            _buildInfoRow(
              _getWeatherIcon(weather['weather']?.toString()),
              'Thời tiết',
              '${weather['temp']?.toStringAsFixed(1) ?? 'N/A'}°C - ${weather['description'] ?? weather['weather'] ?? 'N/A'}',
              Colors.blue,
            ),

          // Health Conditions
          if (conditions != null && conditions.isNotEmpty)
            _buildInfoRow(
              Icons.medical_services,
              'Tình trạng sức khỏe',
              '${conditions.length} bệnh lý đang theo dõi',
              Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Unused method - commented out to avoid warning
  // Widget _buildGapChip(String label, dynamic value, String unit, Color color) {
  //   final numValue = (value is num) ? value.toDouble() : 0.0;
  //   if (numValue <= 0) return const SizedBox.shrink();
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: color.withValues(alpha: 0.1),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: color.withValues(alpha: 0.3)),
  //     ),
  //     child: Text(
  //       '$label: ${numValue.toStringAsFixed(0)} $unit',
  //       style: TextStyle(
  //         color: Color.fromRGBO(
  //           (((color.r * 255.0).round() & 0xff) * 0.7).round(),
  //           (((color.g * 255.0).round() & 0xff) * 0.7).round(),
  //           (((color.b * 255.0).round() & 0xff) * 0.7).round(),
  //           1.0,
  //         ),
  //         fontWeight: FontWeight.w600,
  //         fontSize: 13,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn Gợi Ý',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Type selector
          Row(
            children: [
              _buildTypeChip('Cả hai', 'both', Icons.fastfood),
              const SizedBox(width: 8),
              _buildTypeChip('Món ăn', 'dish', Icons.restaurant),
              const SizedBox(width: 8),
              _buildTypeChip('Đồ uống', 'drink', Icons.local_drink),
            ],
          ),

          const SizedBox(height: 12),

          // Limit selector
          const Text(
            'Số lượng:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLimitChip('5', 5),
              const SizedBox(width: 8),
              _buildLimitChip('10', 10),
              const SizedBox(width: 8),
              _buildLimitChip('Tất cả', null),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loadingSuggestions ? null : _getSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lấy Gợi Ý',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitChip(String label, int? value) {
    final isSelected = _selectedLimit == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedLimit = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsCarousel() {
    // Separate dishes and drinks
    final dishes = _suggestions.where((s) => s['item_type'] == 'dish').toList();
    final drinks = _suggestions
        .where((s) => s['item_type'] == 'drink')
        .toList();
    final showBothSections =
        _selectedType == 'both' && dishes.isNotEmpty && drinks.isNotEmpty;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dishes section
          if (dishes.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.restaurant, color: Colors.orange[700], size: 22),
                  const SizedBox(width: 8),
                  Text(
                    showBothSections
                        ? 'Món Ăn (${dishes.length})'
                        : 'Gợi Ý Cho Bạn (${dishes.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 420,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: dishes.length,
                itemBuilder: (context, index) =>
                    _buildSuggestionCard(dishes[index]),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Drinks section
          if (drinks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.local_drink, color: Colors.blue[700], size: 22),
                  const SizedBox(width: 8),
                  Text(
                    showBothSections
                        ? 'Đồ Uống (${drinks.length})'
                        : 'Gợi Ý Cho Bạn (${drinks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 420,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: drinks.length,
                itemBuilder: (context, index) =>
                    _buildSuggestionCard(drinks[index]),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final itemType = suggestion['item_type'] as String;
    final itemId = suggestion['item_id'] as int;
    final vietnameseName = suggestion['vietnamese_name'] as String?;
    final name = vietnameseName ?? suggestion['name'] as String? ?? 'Unknown';
    final imageUrl = suggestion['image_url'] as String?;
    final score = suggestion['score'] as num? ?? 0;
    final gapFillPercent = suggestion['gap_fill_percent'] as num?;
    final suitabilityPercent = suggestion['suitability_percent'] as num?;
    final nutrients = suggestion['nutrients'] as Map<String, dynamic>?;
    final scoreBreakdown =
        suggestion['score_breakdown'] as Map<String, dynamic>?;

    final key = '${itemType}_$itemId';
    final isPinned = _pinnedIds.contains(key);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPinned ? Border.all(color: Colors.amber, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: isPinned
                ? Colors.amber.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isPinned ? 20 : 15,
            offset: const Offset(0, 8),
            spreadRadius: isPinned ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),

                // Pin button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _togglePin(itemType, itemId),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPinned ? Colors.amber : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        color: isPinned ? Colors.white : Colors.grey[700],
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Type badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: itemType == 'dish' ? Colors.orange : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      itemType == 'dish' ? 'MÓN ĂN' : 'ĐỒ UỐNG',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Match score
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 20),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${((suitabilityPercent ?? (gapFillPercent ?? (score * 100)))).clamp(0, 100).toStringAsFixed(0)}% phù hợp',
                            style: TextStyle(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (gapFillPercent != null)
                            Text(
                              '${gapFillPercent.clamp(0, 100).toStringAsFixed(0)}% bù thiếu',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nutrients
                  if (nutrients != null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (nutrients['protein'] != null &&
                            nutrients['protein'] > 0)
                          _buildNutrientBadge(
                            'P',
                            nutrients['protein'],
                            Colors.amber,
                          ),
                        if (nutrients['carb'] != null && nutrients['carb'] > 0)
                          _buildNutrientBadge(
                            'C',
                            nutrients['carb'],
                            Colors.brown,
                          ),
                        if (nutrients['fat'] != null && nutrients['fat'] > 0)
                          _buildNutrientBadge(
                            'F',
                            nutrients['fat'],
                            Colors.purple,
                          ),
                        if (itemType == 'drink' &&
                            nutrients['water'] != null &&
                            nutrients['water'] > 0)
                          _buildNutrientBadge(
                            'W',
                            nutrients['water'],
                            Colors.blue,
                            unit: 'ml',
                          ),
                      ],
                    ),
                  ],

                  const Spacer(),

                  // Safety & Weather badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[700],
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'An toàn',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (scoreBreakdown?['weather_boost'] != null &&
                          scoreBreakdown!['weather_boost'] > 1.0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getWeatherIcon(
                                  _context?['weather']?['weather']?.toString(),
                                ),
                                color: Colors.blue[700],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Thuận lợi',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: Icon(Icons.restaurant, size: 64, color: Colors.grey[400]),
    );
  }

  Widget _buildNutrientBadge(
    String label,
    num value,
    Color color, {
    String unit = 'g',
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(unit == 'ml' ? 0 : 1)}$unit',
        style: TextStyle(
          color: Color.fromRGBO(
            (((color.r * 255.0).round() & 0xff) * 0.7).round(),
            (((color.g * 255.0).round() & 0xff) * 0.7).round(),
            (((color.b * 255.0).round() & 0xff) * 0.7).round(),
            1.0,
          ),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMealPeriodLabel(String period) {
    switch (period) {
      case 'breakfast':
        return 'Bữa sáng';
      case 'lunch':
        return 'Bữa trưa';
      case 'snack':
        return 'Bữa phụ';
      case 'dinner':
        return 'Bữa tối';
      default:
        return period;
    }
  }

  IconData _getWeatherIcon(String? weather) {
    if (weather == null) return Icons.wb_sunny;
    switch (weather.toLowerCase()) {
      case 'rain':
      case 'drizzle':
        return Icons.water_drop;
      case 'clouds':
        return Icons.cloud;
      case 'clear':
        return Icons.wb_sunny;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }
}
