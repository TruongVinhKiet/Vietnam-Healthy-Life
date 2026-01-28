import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/drink_service.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import '../config/api_config.dart';

class DrinkDetailScreen extends StatefulWidget {
  final int drinkId;
  final Map<String, dynamic>? initialDrink;

  const DrinkDetailScreen({
    super.key,
    required this.drinkId,
    this.initialDrink,
  });

  @override
  State<DrinkDetailScreen> createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  Map<String, dynamic>? _drink;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialDrink != null) {
      _drink = widget.initialDrink;
    }
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
    });
    final result = await DrinkService.fetchDetail(widget.drinkId);
    if (!mounted) return;
    if (result != null && result['success'] == true) {
      setState(() {
        _drink = Map<String, dynamic>.from(result['drink'] as Map);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _logDrink() async {
    final drink = _drink;
    if (drink == null) return;
    final profile = context.maybeProfile();
    double volume = _toDouble(drink['default_volume_ml']);
    if (volume <= 0) volume = 250;
    double selectedVolume = volume;
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ghi nhận ${drink['vietnamese_name'] ?? drink['name']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: selectedVolume,
                    min: 50,
                    max: 800,
                    divisions: 15,
                    label: '${selectedVolume.toStringAsFixed(0)} ml',
                    onChanged: (value) =>
                        setBottomState(() => selectedVolume = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${selectedVolume.toStringAsFixed(0)} ml',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(this.context);
                          final res = await AuthService.logWater(
                            amountMl: selectedVolume,
                            drinkId: drink['drink_id'] as int?,
                            hydrationRatio: _toDouble(drink['hydration_ratio']),
                            drinkName:
                                drink['vietnamese_name'] ?? drink['name'],
                          );
                          if (!mounted || !context.mounted) return;
                          if (res != null && res['error'] == null) {
                            profile?.loadProfile();
                            navigator.pop(true);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã ghi nhận ${selectedVolume.toStringAsFixed(0)} ml',
                                ),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  res?['error']?.toString() ??
                                      'Không thể ghi nhận nước uống',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(l10n.record);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteDrink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.deleteDrink),
          content: Text(l10n.confirmDeleteDrink),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    final ok = await DrinkService.deleteCustomDrink(widget.drinkId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.drinkDeleted);
            },
          ),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.cannotDeleteDrink);
            },
          ),
        ),
      );
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
              return Text(l10n.drinkDetail);
            },
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_drink == null) {
      return Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.drinkDetail);
            },
          ),
        ),
        body: Center(
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.drinkNotFound);
            },
          ),
        ),
      );
    }

    final drink = _drink!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.blue.shade600,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                drink['vietnamese_name'] ?? drink['name'] ?? '',
                style: const TextStyle(
                  shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
                ),
              ),
              background: drink['image_url'] != null
                  ? Image.network(
                      drink['image_url'].toString().startsWith('http')
                          ? drink['image_url']
                          : '${ApiConfig.baseUrl}${drink['image_url']}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade600,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_drink,
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
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_drink,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (drink['description'] != null)
                    _buildSectionCard(
                      title: 'Mô tả',
                      icon: Icons.description,
                      child: Text(drink['description']),
                    ),
                  _buildStatsRow(drink),
                  if ((drink['ingredients'] as List<dynamic>?)?.isNotEmpty ==
                      true)
                    _buildIngredients(drink),
                  _buildNutrients(drink),
                  if (drink['is_owner'] == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa đồ uống'),
                        onPressed: _deleteDrink,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logDrink,
        icon: const Icon(Icons.water_drop, color: Colors.white),
        label: const Text('Ghi nhận', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade600,
      ),
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> drink) {
    final stats = [
      {
        'label': 'Thể tích',
        'value':
            '${_toDouble(drink['default_volume_ml']).toStringAsFixed(0)} ml',
      },
      {
        'label': 'Hydration',
        'value':
            '${(_toDouble(drink['hydration_ratio']) * 100).toStringAsFixed(0)}%',
      },
      {
        'label': 'Caffeine',
        'value': _toDouble(drink['caffeine_mg']) > 0
            ? '${_toDouble(drink['caffeine_mg']).toStringAsFixed(0)} mg'
            : '0 mg',
      },
      {'label': 'Danh mục', 'value': (drink['category'] ?? 'Khác').toString()},
    ];

    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
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
                  children: [
                    Text(
                      stat['value']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label']!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildIngredients(Map<String, dynamic> drink) {
    final ingredients = List<Map<String, dynamic>>.from(
      drink['ingredients'] ?? [],
    );
    if (ingredients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(l10n.noIngredientInfo);
          },
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nguyên liệu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...ingredients.asMap().entries.map((entry) {
            final ing = entry.value;
            final nutrition = List<Map<String, dynamic>>.from(
              ing['nutrition'] ?? [],
            );
            final topNutrients = nutrition
                .where(
                  (n) => [
                    'ENERC_KCAL',
                    'PROCNT',
                    'FAT',
                    'CHOCDF',
                    'FIBTG',
                  ].contains(n['nutrient_code']),
                )
                .toList();
            final otherNutrients = nutrition
                .where(
                  (n) => ![
                    'ENERC_KCAL',
                    'PROCNT',
                    'FAT',
                    'CHOCDF',
                    'FIBTG',
                  ].contains(n['nutrient_code']),
                )
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: const Icon(Icons.circle, size: 8, color: Colors.blue),
                title: Text(
                  ing['vietnamese_name'] ?? ing['name'] ?? 'Nguyên liệu',
                ),
                subtitle: Text(
                  '${_toDouble(ing['amount_g']).toStringAsFixed(0)} g',
                ),
                children: [
                  if (nutrition.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chất dinh dưỡng:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: topNutrients.map((nutrient) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nutrient['name'] ??
                                          nutrient['nutrient_code'] ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '${_toDouble(nutrient['amount_in_ingredient']).toStringAsFixed(1)} ${nutrient['unit'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          if (otherNutrients.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Vi chất khác:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...otherNutrients.map(
                              (nutrient) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        nutrient['name'] ??
                                            nutrient['nutrient_code'],
                                      ),
                                    ),
                                    Text(
                                      '${_toDouble(nutrient['amount_in_ingredient']).toStringAsFixed(2)} ${nutrient['unit'] ?? ''}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Chưa có thông tin dinh dưỡng',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNutrients(Map<String, dynamic> drink) {
    final nutrients = List<Map<String, dynamic>>.from(
      drink['nutrient_details'] ?? [],
    );
    if (nutrients.isEmpty) {
      return const SizedBox.shrink();
    }
    final topCodes = {'ENERC_KCAL', 'PROCNT', 'FAT', 'CHOCDF'};
    final top = nutrients
        .where((n) => topCodes.contains(n['nutrient_code']))
        .toList();
    final others = nutrients
        .where((n) => !topCodes.contains(n['nutrient_code']))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dinh dưỡng (per 100ml)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: top
                    .map(
                      (nutrient) => Container(
                        width: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nutrient['name'] ?? nutrient['nutrient_code'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_toDouble(nutrient['amount_per_100ml']).toStringAsFixed(1)} ${nutrient['unit']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vi chất khác',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...others.map(
                (nutrient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          nutrient['name'] ?? nutrient['nutrient_code'],
                        ),
                      ),
                      Text(
                        '${_toDouble(nutrient['amount_per_100ml']).toStringAsFixed(2)} ${nutrient['unit']}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
