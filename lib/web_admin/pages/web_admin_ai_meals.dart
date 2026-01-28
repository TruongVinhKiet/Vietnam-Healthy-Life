import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import '../components/web_dialog.dart';

class WebAdminAiMeals extends StatefulWidget {
  const WebAdminAiMeals({super.key});

  @override
  State<WebAdminAiMeals> createState() => _WebAdminAiMealsState();
}

class _WebAdminAiMealsState extends State<WebAdminAiMeals> {
  List<dynamic> _meals = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMeals({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final queryParams = <String, String>{
        'accepted': 'true',
        'limit': '100',
      };
      if (search.isNotEmpty) {
        queryParams['search'] = search;
      }
      final uri = Uri.parse('${ApiConfig.baseUrl}/admin/ai-meals')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _meals = data['meals'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    String normalizedPath = imagePath;
    if (normalizedPath.contains('uploads')) {
      final uploadsIndex = normalizedPath.indexOf('uploads');
      normalizedPath = normalizedPath.substring(uploadsIndex);
    }
    normalizedPath = normalizedPath.replaceAll('\\', '/');
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }
    return '${ApiConfig.baseUrl}$normalizedPath';
  }

  double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Color _darkenColor(Color color) {
    // Darken color by reducing brightness
    return Color.fromRGBO(
      ((color.r * 255.0) * 0.7).round(),
      ((color.g * 255.0) * 0.7).round(),
      ((color.b * 255.0) * 0.7).round(),
      1.0,
    );
  }

  void _showNutrientDetails(Map<String, dynamic> meal) {
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

    // Add other nutrients (vitamins, minerals, etc.) similar to mobile version
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
          'unit': entry.key == 'vita' ||
                  entry.key == 'vitk' ||
                  entry.key == 'vitb7' ||
                  entry.key == 'vitb9' ||
                  entry.key == 'vitb12'
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

    WebDialog.show(
      context: context,
      title: 'Chi tiết dinh dưỡng - ${meal['item_name'] ?? ''}',
      width: 700,
      content: SizedBox(
        height: 500,
        child: nutrients.isEmpty
            ? const Center(child: Text('Không có dữ liệu dinh dưỡng'))
            : ListView.builder(
                itemCount: nutrients.length,
                itemBuilder: (_, index) {
                  final n = nutrients[index];
                  return ListTile(
                    dense: true,
                    title: Text(n['name'] ?? ''),
                    trailing: Text(
                      '${n['amount']} ${n['unit'] ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showPromoteDialog(Map<String, dynamic> meal) async {
    final targetType = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.teal),
            SizedBox(width: 8),
            Text('Chọn loại'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bạn muốn thêm món này vào danh sách nào?',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    ctx,
                    icon: Icons.dinner_dining_rounded,
                    title: 'Món ăn',
                    subtitle: 'Dish',
                    color: Colors.deepOrange,
                    onTap: () => Navigator.pop(ctx, 'dish'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeCard(
                    ctx,
                    icon: Icons.local_drink_rounded,
                    title: 'Đồ uống',
                    subtitle: 'Drink',
                    color: Colors.cyan,
                    onTap: () => Navigator.pop(ctx, 'drink'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
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

  Widget _buildTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promoteMeal(
      Map<String, dynamic> meal, String targetType) async {
    final id = meal['id'] as int?;
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/ai-meals/$id/promote'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'target_type': targetType}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã tạo ${targetType == 'dish' ? 'món ăn' : 'đồ uống'} từ AI thành công',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadMeals(search: _searchQuery);
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error'] ?? 'Không thể promote'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectMeal(Map<String, dynamic> meal) async {
    final id = meal['id'] as int?;
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Từ chối món này?'),
        content: Text('Bạn có chắc muốn từ chối "${meal['item_name'] ?? ''}"?'),
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

    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/ai-meals/$id/reject'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối món này'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadMeals(search: _searchQuery);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể từ chối'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn/đồ uống...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadMeals();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) {
                      setState(() => _searchQuery = value);
                      _loadMeals(search: value);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _meals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_outlined,
                                size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có dữ liệu AI nào được ghi nhận',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final maxWidth = constraints.maxWidth;
                              const double spacing = 16.0;
                              const int columns = 3;
                              final totalSpacing = spacing * (columns - 1);
                              final rawCardWidth =
                                  (maxWidth - totalSpacing) / columns;
                              // Clamp card width so cards stay readable on small and very large screens
                              final cardWidth =
                                  rawCardWidth.clamp(240.0, 420.0);

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: _meals.map((meal) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: _buildMealCard(meal),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final promoted = (meal['promoted'] as bool?) ?? false;
    final itemType = (meal['item_type'] ?? 'food').toString();
    final itemName = meal['item_name'] ?? '';
    final existingDishId = meal['existing_dish_id'];
    final existingDrinkId = meal['existing_drink_id'];
    final hasExisting = existingDishId != null || existingDrinkId != null;

    final kcal = _parseNum(meal['enerc_kcal']) ?? 0;
    final carb = _parseNum(meal['chocdf']) ?? 0;
    final protein = _parseNum(meal['procnt']) ?? 0;
    final fat = _parseNum(meal['fat']) ?? 0;
    final water = _parseNum(meal['water_ml']) ?? 0;

    final analyzedAt = meal['analyzed_at']?.toString();
    String timeLabel = '';
    if (analyzedAt != null) {
      final dt = DateTime.tryParse(analyzedAt);
      if (dt != null) {
        timeLabel =
            '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasExisting ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image and name
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image (larger for better visual balance)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _getImageUrl(meal['image_path']),
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: Colors.grey.shade200,
                      child: Icon(
                        itemType == 'drink'
                            ? Icons.local_drink_rounded
                            : Icons.restaurant_rounded,
                        size: 44,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
                      if (timeLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (promoted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Đã thêm',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // 5 key nutrients
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildNutrientChip(
                  '${kcal.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                _buildNutrientChip(
                  '${carb.toStringAsFixed(0)} g carb',
                  Icons.grain,
                  Colors.amber,
                ),
                _buildNutrientChip(
                  '${protein.toStringAsFixed(0)} g protein',
                  Icons.fitness_center,
                  Colors.blue,
                ),
                _buildNutrientChip(
                  '${fat.toStringAsFixed(0)} g fat',
                  Icons.opacity,
                  Colors.purple,
                ),
                _buildNutrientChip(
                  '${water.toStringAsFixed(0)} ml nước',
                  Icons.water_drop,
                  Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showNutrientDetails(meal),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label:
                        const Text('Chi tiết', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                if (!promoted) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () => _showPromoteDialog(meal),
                    icon: const Icon(Icons.check_circle, size: 20),
                    color: Colors.green,
                    tooltip: 'Chấp nhận',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _rejectMeal(meal),
                    icon: const Icon(Icons.cancel, size: 20),
                    color: Colors.red,
                    tooltip: 'Từ chối',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _darkenColor(color),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
