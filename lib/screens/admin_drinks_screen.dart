import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/drink_service.dart';
import 'package:my_diary/services/food_service.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class AdminDrinksScreen extends StatefulWidget {
  const AdminDrinksScreen({super.key});

  @override
  State<AdminDrinksScreen> createState() => _AdminDrinksScreenState();
}

class _AdminDrinksScreenState extends State<AdminDrinksScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _drinks = [];

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    setState(() => _isLoading = true);
    final drinks = await DrinkService.adminFetchDrinks();
    if (!mounted) return;
    setState(() {
      _drinks = drinks;
      _isLoading = false;
    });
  }

  Future<void> _deleteDrink(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đồ uống'),
        content: const Text('Bạn có chắc muốn xóa đồ uống này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await DrinkService.adminDeleteDrink(id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa đồ uống')));
      _loadDrinks();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xóa thất bại')));
    }
  }

  Future<void> _openEditor({Map<String, dynamic>? drink}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DrinkEditorSheet(drink: drink),
    );
    if (result == true) {
      _loadDrinks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đồ uống')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm đồ uống'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDrinks,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _drinks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final drink = _drinks[index];
                  final nutrients =
                      (drink['nutrients'] as Map?) ?? <String, dynamic>{};
                  final hydration = _toDouble(drink['hydration_ratio']);
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      title: Text(
                        drink['vietnamese_name'] ?? drink['name'] ?? 'Đồ uống',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            drink['description'] ?? 'Không có mô tả',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              _buildChip(
                                icon: Icons.water_drop,
                                label:
                                    'Hydration ${(hydration * 100).toStringAsFixed(0)}%',
                              ),
                              if (drink['default_volume_ml'] != null)
                                _buildChip(
                                  icon: Icons.local_drink,
                                  label:
                                      '${drink['default_volume_ml']} ml mặc định',
                                ),
                              if (nutrients['ENERC_KCAL'] != null)
                                _buildChip(
                                  icon: Icons.bolt,
                                  label:
                                      '${nutrients['ENERC_KCAL']} kcal / 100ml',
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openEditor(drink: drink);
                          } else if (value == 'delete') {
                            _deleteDrink(drink['drink_id'] as int);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Chỉnh sửa'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Xóa'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: FitnessAppTheme.nearlyBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: FitnessAppTheme.nearlyBlue),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class DrinkEditorSheet extends StatefulWidget {
  final Map<String, dynamic>? drink;

  const DrinkEditorSheet({super.key, this.drink});

  @override
  State<DrinkEditorSheet> createState() => _DrinkEditorSheetState();
}

class _DrinkEditorSheetState extends State<DrinkEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _vnNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _volumeController;
  late final TextEditingController _hydrationController;
  late final TextEditingController _imageUrlController;
  bool _isPublic = true;
  bool _sugarFree = false;
  bool _saving = false;
  List<Map<String, dynamic>> _ingredients = [];
  bool _loadingIngredients = false;
  bool _checkingName = false;
  String? _nameError;
  Timer? _nameCheckTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.drink?['name'] ?? '');
    _vnNameController = TextEditingController(
      text: widget.drink?['vietnamese_name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.drink?['description'] ?? '',
    );
    _volumeController = TextEditingController(
      text: widget.drink?['default_volume_ml']?.toString() ?? '250',
    );
    _hydrationController = TextEditingController(
      text: (widget.drink?['hydration_ratio'] ?? 1).toString(),
    );
    _imageUrlController = TextEditingController(
      text: widget.drink?['image_url']?.toString() ?? '',
    );
    _isPublic = widget.drink?['is_public'] ?? true;
    _sugarFree = widget.drink?['sugar_free'] ?? false;
    _loadIngredients();
    
    // Add listeners for name validation
    _nameController.addListener(_onNameChanged);
    _vnNameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Debounce name checking
    _nameCheckTimer?.cancel();
    _nameCheckTimer = Timer(const Duration(milliseconds: 500), _checkNameExists);
  }

  Future<void> _checkNameExists() async {
    final name = _nameController.text.trim();
    final vnName = _vnNameController.text.trim();
    
    if (name.isEmpty && vnName.isEmpty) {
      setState(() {
        _nameError = null;
        _checkingName = false;
      });
      return;
    }
    
    setState(() {
      _checkingName = true;
      _nameError = null;
    });
    
    try {
      final exists = await DrinkService.checkNameExists(
        name: name.isNotEmpty ? name : null,
        vietnameseName: vnName.isNotEmpty ? vnName : null,
        excludeDrinkId: widget.drink?['drink_id'] as int?,
      );
      
      if (!mounted) return;
      
      setState(() {
        _checkingName = false;
        if (exists) {
          final duplicateName = name.isNotEmpty 
              ? (vnName.isNotEmpty ? '$name hoặc $vnName' : name)
              : vnName;
          _nameError = '$duplicateName đã có trong hệ thống';
        } else {
          _nameError = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingName = false;
        _nameError = null; // Don't show error on API failure
      });
    }
  }

  Future<void> _loadIngredients() async {
    if (widget.drink == null || widget.drink!['drink_id'] == null) return;

    setState(() => _loadingIngredients = true);
    try {
      final detail = await DrinkService.fetchDetail(
        widget.drink!['drink_id'] as int,
      );
      if (detail != null && detail['drink'] != null) {
        final ingredients =
            (detail['drink']['ingredients'] as List<dynamic>?) ?? [];
        setState(() {
          _ingredients = ingredients
              .map(
                (ing) => {
                  'food': {'food_id': ing['food_id'], 'name': ing['name']},
                  'amount': (ing['amount_g'] as num?)?.toDouble() ?? 100.0,
                  'notes': ing['notes'] ?? '',
                },
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading ingredients: $e');
    } finally {
      setState(() => _loadingIngredients = false);
    }
  }

  @override
  void dispose() {
    _nameCheckTimer?.cancel();
    _nameController.dispose();
    _vnNameController.dispose();
    _descriptionController.dispose();
    _volumeController.dispose();
    _hydrationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tên không được để trống')));
      return;
    }
    
    // Check name exists one more time before saving
    if (_nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_nameError!)),
      );
      return;
    }
    setState(() => _saving = true);
    final payload = {
      'name': _nameController.text.trim(),
      'vietnamese_name': _vnNameController.text.trim().isEmpty
          ? null
          : _vnNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'image_url': _imageUrlController.text.trim(),
      'default_volume_ml':
          double.tryParse(_volumeController.text.trim()) ?? 250,
      'hydration_ratio': double.tryParse(_hydrationController.text.trim()) ?? 1,
      'is_public': _isPublic,
      'sugar_free': _sugarFree,
      'ingredients': _ingredients
          .asMap()
          .entries
          .map(
            (entry) => {
              'food_id': entry.value['food']['food_id'],
              'amount_g': entry.value['amount'],
              'notes': entry.value['notes'],
              'display_order': entry.key,
            },
          )
          .toList(),
    };
    final result = await DrinkService.adminUpsertDrink(
      payload,
      drinkId: widget.drink?['drink_id'] as int?,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result != null && result['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?['error']?.toString() ?? 'Lỗi hệ thống')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: 550,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.cyan.shade50.withValues(alpha: 0.3)],
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan.shade600, Colors.cyan.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      widget.drink == null
                          ? Icons.add_circle_rounded
                          : Icons.edit_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.drink == null
                          ? 'Thêm đồ uống mới'
                          : 'Chỉnh sửa đồ uống',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Đóng',
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Info Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.shade100.withValues(alpha: 0.5),
                              Colors.cyan.shade50.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Colors.cyan.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Thông tin cơ bản',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Tên (English)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.cyan.shade400,
                                  Colors.cyan.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.local_drink_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          suffixIcon: _checkingName
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                          errorText: _nameError,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên đồ uống';
                          }
                          if (_nameError != null) {
                            return _nameError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _vnNameController,
                        decoration: InputDecoration(
                          labelText: 'Tên tiếng Việt',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.translate_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade400,
                                  Colors.purple.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _imageUrlController,
                        decoration: InputDecoration(
                          labelText: 'URL hình ảnh (tùy chọn)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.orange.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.image_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _volumeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Thể tích mặc định (ml)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.water_drop_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _hydrationController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: 'Hydration ratio',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.teal.shade400,
                                        Colors.teal.shade600,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.opacity_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                        title: const Text('Hiển thị cho tất cả người dùng'),
                      ),
                      SwitchListTile(
                        value: _sugarFree,
                        onChanged: (value) =>
                            setState(() => _sugarFree = value),
                        title: const Text('Không đường'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.ingredients,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addIngredient,
                            icon: const Icon(Icons.add),
                            label: Text(AppLocalizations.of(context)!.add),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_loadingIngredients)
                        const Center(child: CircularProgressIndicator())
                      else if (_ingredients.isEmpty)
                        Text(AppLocalizations.of(context)!.noIngredientsYet)
                      else
                        ..._ingredients.asMap().entries.map(
                          (entry) => Card(
                            child: ListTile(
                              title: Text(
                                entry.value['food']['vietnamese_name'] ??
                                    entry.value['food']['name'] ??
                                    'Unknown',
                              ),
                              subtitle: Text(
                                '${entry.value['amount'].toStringAsFixed(0)} g',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Xóa nguyên liệu',
                                onPressed: () {
                                  setState(() {
                                    _ingredients.removeAt(entry.key);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Actions Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan.shade500, Colors.cyan.shade700],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.shade300.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_saving || _nameError != null || _checkingName) ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.drink == null
                                      ? Icons.add_rounded
                                      : Icons.check_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.drink == null ? 'Thêm' : 'Cập nhật',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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

  Future<void> _addIngredient() async {
    final food = await _openFoodSearchDialog();
    if (food == null || !mounted) return;
    double amount = 100;
    String notes = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            food['vietnamese_name'] ??
                food['name'] ??
                AppLocalizations.of(context)!.ingredient,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.weightG,
                ),
                onChanged: (value) => amount = double.tryParse(value) ?? 100,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.notes,
                ),
                onChanged: (value) => notes = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.add),
            ),
          ],
        );
      },
    );
    if (ok == true) {
      setState(() {
        _ingredients.add({'food': food, 'amount': amount, 'notes': notes});
      });
    }
  }

  Future<Map<String, dynamic>?> _openFoodSearchDialog() async {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        List<Map<String, dynamic>> results = [];
        bool loading = false;
        final controller = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.selectIngredient),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.enterFoodName,
                      ),
                      onChanged: (value) async {
                        if (value.length < 2) return;
                        setStateDialog(() => loading = true);
                        final data = await FoodService.searchFoods(
                          value,
                          limit: 20,
                        );
                        setStateDialog(() {
                          results = data;
                          loading = false;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (results.isEmpty)
                      Text(AppLocalizations.of(context)!.enterKeywordToSearch)
                    else
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final item = results[index];
                            return ListTile(
                              title: Text(
                                item['vietnamese_name'] ?? item['name'],
                              ),
                              subtitle: Text(item['category'] ?? ''),
                              onTap: () => Navigator.pop(context, item),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.close),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
