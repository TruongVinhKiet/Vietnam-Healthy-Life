import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../services/nutrient_tracking_service.dart';

class PersonalizedRDAScreen extends StatefulWidget {
  const PersonalizedRDAScreen({super.key});

  @override
  PersonalizedRDAScreenState createState() => PersonalizedRDAScreenState();
}

class PersonalizedRDAScreenState extends State<PersonalizedRDAScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<dynamic> vitamins = [];
  List<dynamic> minerals = [];
  List<dynamic> fibers = [];
  List<dynamic> fattyAcids = [];
  Map<String, dynamic> trackingData = {};
  bool isLoading = true;
  String selectedCategory = 'Vitamins';
  int unreadNotifications = 0;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
        );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load real-time tracking data with current progress
      final tracking = await NutrientTrackingService.getDailyTracking();
      trackingData = tracking;

      // Get unread notification count
      try {
        final notifData = await NutrientTrackingService.getNotifications(
          limit: 1,
        );
        unreadNotifications = notifData['unread_count'] ?? 0;
      } catch (e) {
        debugPrint('Error loading notifications: $e');
      }

      // Organize tracking data by nutrient type
      final nutrients = tracking['nutrients'] as List<dynamic>? ?? [];
      vitamins = nutrients
          .where((n) => n['nutrient_type'] == 'vitamin')
          .toList();
      minerals = nutrients
          .where((n) => n['nutrient_type'] == 'mineral')
          .toList();
      // Fiber and fatty acids would need similar tracking endpoints

      setState(() => isLoading = false);
      _mainController.forward();
    } catch (e) {
      debugPrint('Error loading RDA data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAnimatedAppBar(),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          _buildCategorySelector(),
          SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (isLoading)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildNutrientList(),
        ],
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: FitnessAppTheme.nearlyWhite,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Nhu cầu dinh dưỡng',
            style: TextStyle(
              color: FitnessAppTheme.nearlyBlack,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FitnessAppTheme.nearlyWhite, FitnessAppTheme.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                Icon(
                  Icons.analytics_outlined,
                  size: 60,
                  color: FitnessAppTheme.nearlyDarkBlue.withValues(alpha: 0.7),
                ),
                SizedBox(height: 8),
                Text(
                  'Cá nhân hóa cho bạn',
                  style: TextStyle(
                    color: FitnessAppTheme.grey.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('Vitamins', Icons.local_pharmacy_outlined),
                _buildCategoryChip('Minerals', Icons.grain_outlined),
                _buildCategoryChip('Fiber', Icons.eco_outlined),
                _buildCategoryChip('Fatty Acids', Icons.water_drop_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = selectedCategory == category;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = category;
          });
          _cardController.reset();
          _cardController.forward();
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      FitnessAppTheme.nearlyDarkBlue,
                      FitnessAppTheme.nearlyBlue,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? FitnessAppTheme.nearlyDarkBlue.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: isSelected ? 8 : 4,
                offset: Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : FitnessAppTheme.grey,
              ),
              SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : FitnessAppTheme.nearlyBlack,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientList() {
    List<dynamic> currentList;
    switch (selectedCategory) {
      case 'Minerals':
        currentList = minerals;
        break;
      case 'Fiber':
        currentList = fibers;
        break;
      case 'Fatty Acids':
        currentList = fattyAcids;
        break;
      default:
        currentList = vitamins;
    }

    if (currentList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Không có dữ liệu',
            style: TextStyle(color: FitnessAppTheme.grey),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildAnimatedNutrientCard(currentList[index], index);
        }, childCount: currentList.length),
      ),
    );
  }

  Widget _buildAnimatedNutrientCard(dynamic nutrient, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildNutrientCard(nutrient),
    );
  }

  Widget _buildNutrientCard(dynamic nutrient) {
    final name = nutrient['name'] ?? 'Unknown';
    final code = nutrient['code'] ?? '';
    final recommendedDaily = nutrient['recommended_daily'] ?? '0';
    final recommendedForUser =
        nutrient['recommended_for_user'] ?? recommendedDaily;
    final unit = nutrient['unit'] ?? '';
    final description = nutrient['description'] ?? '';

    // Parse values for progress indicator
    double baseValue = double.tryParse(recommendedDaily.toString()) ?? 0;
    double userValue =
        double.tryParse(recommendedForUser.toString()) ?? baseValue;
    double progress = baseValue > 0
        ? (userValue / baseValue).clamp(0.0, 2.0)
        : 1.0;

    Color progressColor = progress > 1.2
        ? FitnessAppTheme.nearlyDarkBlue
        : progress > 0.8
        ? Colors.green
        : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to detail screen
            _showNutrientDetail(nutrient);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor.withValues(alpha: 0.2),
                            progressColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          code.length > 4 ? code.substring(0, 4) : code,
                          style: TextStyle(
                            color: progressColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FitnessAppTheme.nearlyBlack,
                            ),
                          ),
                          if (description.isNotEmpty)
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color: FitnessAppTheme.grey.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: FitnessAppTheme.grey.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nhu cầu chung',
                            style: TextStyle(
                              fontSize: 11,
                              color: FitnessAppTheme.grey.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$recommendedDaily $unit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: FitnessAppTheme.nearlyBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cho bạn',
                            style: TextStyle(
                              fontSize: 11,
                              color: progressColor.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '$userValue $unit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value.clamp(0.0, 1.0),
                        backgroundColor: FitnessAppTheme.grey.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: AlwaysStoppedAnimation(progressColor),
                        minHeight: 6,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNutrientDetail(dynamic nutrient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FitnessAppTheme.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24),
                  children: [
                    Text(
                      nutrient['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: FitnessAppTheme.nearlyBlack,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (nutrient['description'] != null)
                      Text(
                        nutrient['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                    SizedBox(height: 24),
                    _buildInfoRow('Mã chất dinh dưỡng', nutrient['code'] ?? ''),
                    _buildInfoRow('Đơn vị', nutrient['unit'] ?? ''),
                    _buildInfoRow(
                      'Nhu cầu khuyến nghị',
                      '${nutrient['recommended_daily']} ${nutrient['unit']}',
                    ),
                    if (nutrient['recommended_for_user'] != null)
                      _buildInfoRow(
                        'Nhu cầu của bạn',
                        '${nutrient['recommended_for_user']} ${nutrient['unit']}',
                        highlight: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: FitnessAppTheme.grey.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              color: highlight
                  ? FitnessAppTheme.nearlyDarkBlue
                  : FitnessAppTheme.nearlyBlack,
            ),
          ),
        ],
      ),
    );
  }
}
