// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/config/api_config.dart';

class AdminAiMealsScreen extends StatefulWidget {
  const AdminAiMealsScreen({super.key});

  @override
  State<AdminAiMealsScreen> createState() => _AdminAiMealsScreenState();
}

class _AdminAiMealsScreenState extends State<AdminAiMealsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await AuthService.adminGetAiMeals(
        accepted: true,
        promoted: null,
        itemType: null,
        search: null,
        limit: 100,
      );
      if (!mounted) return;
      setState(() {
        _meals = items ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _promoteMeal(
    Map<String, dynamic> meal,
    String targetType,
  ) async {
    final id = meal['id'] as int?;
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm vào danh sách chuẩn?'),
        content: Text(
          'Bạn muốn thêm "${meal['item_name'] ?? ''}" vào danh sách ${targetType == 'dish' ? 'món ăn' : 'đồ uống'} chuẩn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final resp = await AuthService.adminPromoteAiMeal(
      id: id,
      targetType: targetType,
    );
    if (!mounted) return;
    if (resp != null && resp['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã tạo ${targetType == 'dish' ? 'món ăn' : 'đồ uống'} từ AI thành công',
          ),
        ),
      );
      _loadMeals();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp?['error']?.toString() ?? 'Không thể promote'),
        ),
      );
    }
  }

  Future<void> _showPromoteDialog(Map<String, dynamic> meal) async {
    final targetType = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn loại'),
        content: const Text('Bạn muốn thêm món này vào danh sách nào?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'dish'),
            child: const Text('Món ăn (Dish)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'drink'),
            child: const Text('Đồ uống (Drink)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
    if (targetType != null && targetType.isNotEmpty) {
      await _promoteMeal(meal, targetType);
    }
  }

  Future<void> _rejectMeal(Map<String, dynamic> meal) async {
    final id = meal['id'] as int?;
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối món này?'),
        content: Text(
          'Bạn có chắc muốn từ chối "${meal['item_name'] ?? ''}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final resp = await AuthService.adminRejectAiMeal(id: id);
    if (!mounted) return;
    if (resp != null && resp['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã từ chối món này'),
        ),
      );
      _loadMeals();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp?['error']?.toString() ?? 'Không thể từ chối'),
        ),
      );
    }
  }

  // Helper function to safely parse numeric value
  double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  // Helper function to get full image URL
  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Normalize path: remove absolute path prefix if exists
    String normalizedPath = imagePath;
    
    // Remove Windows absolute path (e.g., D:\App\new\Project\backend\uploads\...)
    if (normalizedPath.contains('uploads')) {
      final uploadsIndex = normalizedPath.indexOf('uploads');
      normalizedPath = normalizedPath.substring(uploadsIndex);
    }
    
    // Normalize slashes
    normalizedPath = normalizedPath.replaceAll('\\', '/');
    
    // Ensure starts with /uploads
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }
    
    // Add base URL
    return '${ApiConfig.baseUrl}$normalizedPath';
  }

  void _showDetail(Map<String, dynamic> meal) {
    // Map tất cả các nutrient từ các cột của AI_Analyzed_Meals
    final nutrients = <Map<String, String>>[];

    // Macros
    final enercKcal = _parseNum(meal['enerc_kcal']);
    if (enercKcal != null && enercKcal > 0) {
      nutrients.add({
        'name': 'Năng lượng (Calories)',
        'amount': enercKcal.toStringAsFixed(2),
        'unit': 'kcal',
      });
    }
    final procnt = _parseNum(meal['procnt']);
    if (procnt != null && procnt > 0) {
      nutrients.add({
        'name': 'Protein',
        'amount': procnt.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final fat = _parseNum(meal['fat']);
    if (fat != null && fat > 0) {
      nutrients.add({
        'name': 'Chất béo (Total Fat)',
        'amount': fat.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final chocdf = _parseNum(meal['chocdf']);
    if (chocdf != null && chocdf > 0) {
      nutrients.add({
        'name': 'Carbohydrate',
        'amount': chocdf.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final waterMl = _parseNum(meal['water_ml']);
    if (waterMl != null && waterMl > 0) {
      nutrients.add({
        'name': 'Nước',
        'amount': waterMl.toStringAsFixed(2),
        'unit': 'ml',
      });
    }

    // Fiber
    final fibtg = _parseNum(meal['fibtg']);
    if (fibtg != null && fibtg > 0) {
      nutrients.add({
        'name': 'Chất xơ (Total Fiber)',
        'amount': fibtg.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final fibSol = _parseNum(meal['fib_sol']);
    if (fibSol != null && fibSol > 0) {
      nutrients.add({
        'name': 'Chất xơ hòa tan',
        'amount': fibSol.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final fibInsol = _parseNum(meal['fib_insol']);
    if (fibInsol != null && fibInsol > 0) {
      nutrients.add({
        'name': 'Chất xơ không hòa tan',
        'amount': fibInsol.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final fibRs = _parseNum(meal['fib_rs']);
    if (fibRs != null && fibRs > 0) {
      nutrients.add({
        'name': 'Tinh bột kháng',
        'amount': fibRs.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final fibBglu = _parseNum(meal['fib_bglu']);
    if (fibBglu != null && fibBglu > 0) {
      nutrients.add({
        'name': 'Beta-Glucan',
        'amount': fibBglu.toStringAsFixed(2),
        'unit': 'g',
      });
    }

    // Cholesterol
    final cholesterol = _parseNum(meal['cholesterol']);
    if (cholesterol != null && cholesterol > 0) {
      nutrients.add({
        'name': 'Cholesterol',
        'amount': cholesterol.toStringAsFixed(2),
        'unit': 'mg',
      });
    }

    // Vitamins
    final vitaminMap = {
      'vita': 'Vitamin A',
      'vitd': 'Vitamin D',
      'vite': 'Vitamin E',
      'vitk': 'Vitamin K',
      'vitc': 'Vitamin C',
      'vitb1': 'Vitamin B1 (Thiamine)',
      'vitb2': 'Vitamin B2 (Riboflavin)',
      'vitb3': 'Vitamin B3 (Niacin)',
      'vitb5': 'Vitamin B5 (Pantothenic acid)',
      'vitb6': 'Vitamin B6 (Pyridoxine)',
      'vitb7': 'Vitamin B7 (Biotin)',
      'vitb9': 'Vitamin B9 (Folate)',
      'vitb12': 'Vitamin B12 (Cobalamin)',
    };
    for (final entry in vitaminMap.entries) {
      final value = _parseNum(meal[entry.key]);
      if (value != null && value > 0) {
        nutrients.add({
          'name': entry.value,
          'amount': value.toStringAsFixed(2),
          'unit': entry.key == 'vita' || entry.key == 'vitk' || entry.key == 'vitb7' || entry.key == 'vitb9' || entry.key == 'vitb12'
              ? 'µg'
              : entry.key == 'vitd'
                  ? 'IU'
                  : 'mg',
        });
      }
    }

    // Minerals
    final mineralMap = <String, Map<String, String>>{
      'ca': {'name': 'Calcium (Ca)', 'unit': 'mg'},
      'p': {'name': 'Phosphorus (P)', 'unit': 'mg'},
      'mg': {'name': 'Magnesium (Mg)', 'unit': 'mg'},
      'k': {'name': 'Potassium (K)', 'unit': 'mg'},
      'na': {'name': 'Sodium (Na)', 'unit': 'mg'},
      'fe': {'name': 'Iron (Fe)', 'unit': 'mg'},
      'zn': {'name': 'Zinc (Zn)', 'unit': 'mg'},
      'cu': {'name': 'Copper (Cu)', 'unit': 'mg'},
      'mn': {'name': 'Manganese (Mn)', 'unit': 'mg'},
      'i': {'name': 'Iodine (I)', 'unit': 'µg'},
      'se': {'name': 'Selenium (Se)', 'unit': 'µg'},
      'cr': {'name': 'Chromium (Cr)', 'unit': 'µg'},
      'mo': {'name': 'Molybdenum (Mo)', 'unit': 'µg'},
      'f': {'name': 'Fluoride (F)', 'unit': 'mg'},
    };
    for (final entry in mineralMap.entries) {
      final value = _parseNum(meal[entry.key]);
      if (value != null && value > 0) {
        nutrients.add({
          'name': entry.value['name']!,
          'amount': value.toStringAsFixed(2),
          'unit': entry.value['unit']!,
        });
      }
    }

    // Fatty Acids
    final fattyAcidMap = <String, Map<String, String>>{
      'fams': {'name': 'Monounsaturated Fat (MUFA)', 'unit': 'g'},
      'fapu': {'name': 'Polyunsaturated Fat (PUFA)', 'unit': 'g'},
      'fasat': {'name': 'Saturated Fat (SFA)', 'unit': 'g'},
      'fatrn': {'name': 'Trans Fat (total)', 'unit': 'g'},
      'faepa': {'name': 'EPA (Eicosapentaenoic acid)', 'unit': 'g'},
      'fadha': {'name': 'DHA (Docosahexaenoic acid)', 'unit': 'g'},
      'faepa_dha': {'name': 'EPA + DHA (combined)', 'unit': 'g'},
      'fa18_2n6c': {'name': 'Linoleic acid (LA) 18:2 n-6', 'unit': 'g'},
      'fa18_3n3': {'name': 'Alpha-linolenic acid (ALA) 18:3 n-3', 'unit': 'g'},
    };
    for (final entry in fattyAcidMap.entries) {
      final value = _parseNum(meal[entry.key]);
      if (value != null && value > 0) {
        nutrients.add({
          'name': entry.value['name']!,
          'amount': value.toStringAsFixed(2),
          'unit': entry.value['unit']!,
        });
      }
    }

    // Amino Acids
    final aminoAcidMap = <String, Map<String, String>>{
      'amino_his': {'name': 'Histidine', 'unit': 'g'},
      'amino_ile': {'name': 'Isoleucine', 'unit': 'g'},
      'amino_leu': {'name': 'Leucine', 'unit': 'g'},
      'amino_lys': {'name': 'Lysine', 'unit': 'g'},
      'amino_met': {'name': 'Methionine', 'unit': 'g'},
      'amino_phe': {'name': 'Phenylalanine', 'unit': 'g'},
      'amino_thr': {'name': 'Threonine', 'unit': 'g'},
      'amino_trp': {'name': 'Tryptophan', 'unit': 'g'},
      'amino_val': {'name': 'Valine', 'unit': 'g'},
    };
    for (final entry in aminoAcidMap.entries) {
      final value = _parseNum(meal[entry.key]);
      if (value != null && value > 0) {
        nutrients.add({
          'name': entry.value['name']!,
          'amount': value.toStringAsFixed(2),
          'unit': entry.value['unit']!,
        });
      }
    }

    // Other
    final ala = _parseNum(meal['ala']);
    if (ala != null && ala > 0) {
      nutrients.add({
        'name': 'ALA (Alpha-Linolenic Acid)',
        'amount': ala.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final epaDha = _parseNum(meal['epa_dha']);
    if (epaDha != null && epaDha > 0) {
      nutrients.add({
        'name': 'EPA + DHA Combined',
        'amount': epaDha.toStringAsFixed(2),
        'unit': 'g',
      });
    }
    final la = _parseNum(meal['la']);
    if (la != null && la > 0) {
      nutrients.add({
        'name': 'LA (Linoleic Acid)',
        'amount': la.toStringAsFixed(2),
        'unit': 'g',
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          builder: (_, controller) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        meal['item_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Loại: ${meal['item_type'] ?? ''}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chi tiết dinh dưỡng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: nutrients.isEmpty
                      ? const Center(
                          child: Text('Không có dữ liệu dinh dưỡng'),
                        )
                      : ListView.builder(
                          controller: controller,
                          itemCount: nutrients.length,
                          itemBuilder: (_, index) {
                            final n = nutrients[index];
                            return ListTile(
                              dense: true,
                              title: Text(n['name'] ?? ''),
                              trailing: Text(
                                '${n['amount']} ${n['unit'] ?? ''}',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý AI'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeals,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      );
    }
    if (_meals.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Chưa có dữ liệu AI nào được ghi nhận.'),
        ],
      );
    }

    final df = DateFormat('dd/MM/yyyy HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meals.length,
      itemBuilder: (_, index) {
        final meal = _meals[index];
        final promoted = (meal['promoted'] as bool?) ?? false;
        final itemType = (meal['item_type'] ?? 'food').toString();
        final itemName = meal['item_name'] ?? '';
        
        // Check tên: có trong Dish hoặc Drink chưa?
        final existingDishId = meal['existing_dish_id'];
        final existingDrinkId = meal['existing_drink_id'];
        final hasExisting = existingDishId != null || existingDrinkId != null;

        // 5 chất chính
        final kcal = (meal['enerc_kcal'] ?? 0).toString();
        final carb = (meal['chocdf'] ?? 0).toString();
        final protein = (meal['procnt'] ?? 0).toString();
        final fat = (meal['fat'] ?? 0).toString();
        final water = (meal['water_ml'] ?? 0).toString();

        final analyzedAt = meal['analyzed_at']?.toString();
        String timeLabel = '';
        if (analyzedAt != null) {
          final dt = DateTime.tryParse(analyzedAt);
          if (dt != null) {
            timeLabel = df.format(dt.toLocal());
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasExisting ? Colors.green : Colors.red,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với icon và tên
                Row(
                  children: [
                    // Hình ảnh
                    if (meal['image_path'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _getImageUrl(meal['image_path']),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(Icons.image_not_supported),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_not_supported),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                itemType == 'drink'
                                    ? Icons.local_drink_rounded
                                    : Icons.restaurant_rounded,
                                color: itemType == 'drink'
                                    ? Colors.cyan
                                    : Colors.deepOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Check tên: khung xanh/đỏ
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasExisting
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: hasExisting ? Colors.green : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              hasExisting
                                  ? 'Đã có trong cơ sở dữ liệu'
                                  : 'Chưa có trong cơ sở dữ liệu',
                              style: TextStyle(
                                fontSize: 11,
                                color: hasExisting ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (promoted)
                      const Chip(
                        label: Text(
                          'Đã thêm',
                          style: TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.greenAccent,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  timeLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                // 5 chất chính
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildNutrientChip('$kcal kcal', Icons.local_fire_department),
                    _buildNutrientChip('$carb g carb', Icons.grain),
                    _buildNutrientChip('$protein g protein', Icons.fitness_center),
                    _buildNutrientChip('$fat g fat', Icons.opacity),
                    _buildNutrientChip('$water ml nước', Icons.water_drop),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showDetail(meal),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Xem chi tiết'),
                    ),
                    const Spacer(),
                    // Nút ✓ và ✗ chỉ hiện khi chưa promote
                    if (!promoted) ...[
                      IconButton(
                        onPressed: () => _showPromoteDialog(meal),
                        icon: const Icon(Icons.check_circle),
                        color: Colors.green,
                        tooltip: 'Chấp nhận',
                      ),
                      IconButton(
                        onPressed: () => _rejectMeal(meal),
                        icon: const Icon(Icons.cancel),
                        color: Colors.red,
                        tooltip: 'Từ chối',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientChip(String label, IconData icon) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: const TextStyle(fontSize: 12),
    );
  }
}
