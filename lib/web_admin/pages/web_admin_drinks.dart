import 'package:flutter/material.dart';
import '../components/web_data_table.dart';
// ignore_for_file: unused_element_parameter
import '../../services/drink_service.dart';
import '../../services/food_service.dart';

class WebAdminDrinks extends StatefulWidget {
  const WebAdminDrinks({super.key});

  @override
  State<WebAdminDrinks> createState() => _WebAdminDrinksState();
}

// ======= Web Add/Edit Drink Dialog =======

class _WebAddEditDrinkDialog extends StatefulWidget {
  final Map<String, dynamic>? drink;
  final VoidCallback onSaved;
  const _WebAddEditDrinkDialog({this.drink, required this.onSaved});

  @override
  State<_WebAddEditDrinkDialog> createState() => _WebAddEditDrinkDialogState();
}

class _WebAddEditDrinkDialogState extends State<_WebAddEditDrinkDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _vnNameController;
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _baseLiquidController;
  late TextEditingController _volumeController;
  late TextEditingController _tempController;
  late TextEditingController _sweetnessController;
  late TextEditingController _hydrationController;
  late TextEditingController _caffeineController;
  late TextEditingController _imageController;
  bool _isSaving = false;
  bool _sugarFree = false;
  bool _isTemplate = true;
  bool _isPublic = true;

  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _availableNutrients = [];
  final List<Map<String, dynamic>> _selectedNutrients = [];

  @override
  void initState() {
    super.initState();
    final d = widget.drink;
    _vnNameController =
        TextEditingController(text: d?['vietnamese_name'] ?? '');
    _nameController = TextEditingController(text: d?['name'] ?? '');
    _slugController = TextEditingController(text: d?['slug'] ?? '');
    _descriptionController =
        TextEditingController(text: d?['description'] ?? '');
    _categoryController = TextEditingController(text: d?['category'] ?? '');
    _baseLiquidController =
        TextEditingController(text: d?['base_liquid'] ?? '');
    _volumeController = TextEditingController(
        text: d?['default_volume_ml']?.toString() ?? '250');
    _tempController =
        TextEditingController(text: d?['default_temperature'] ?? 'cold');
    _sweetnessController =
        TextEditingController(text: d?['default_sweetness'] ?? 'normal');
    _hydrationController =
        TextEditingController(text: d?['hydration_ratio']?.toString() ?? '1');
    _caffeineController =
        TextEditingController(text: d?['caffeine_mg']?.toString() ?? '0');
    _imageController = TextEditingController(text: d?['image_url'] ?? '');
    _sugarFree = d?['sugar_free'] ?? false;
    _isTemplate = d?['is_template'] ?? true;
    _isPublic = d?['is_public'] ?? true;

    final ing = d?['ingredients'] as List<dynamic>? ?? [];
    _ingredients = ing.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    final nuts = d?['nutrients'] as List<dynamic>? ?? [];
    _selectedNutrients.addAll(nuts.map((n) {
      final m = Map<String, dynamic>.from(n as Map);
      return {
        'nutrient_id': m['nutrient_id'] ?? m['id'],
        'nutrient_code': m['nutrient_code'] ?? m['code'],
        'nutrient_name': m['nutrient_name'] ?? m['name'],
        'amount_per_100ml':
            m['amount_per_100ml'] ?? m['amount_per_100g'] ?? m['value'] ?? 0,
      };
    }));

    _fetchAvailableNutrients();
  }

  Future<void> _fetchAvailableNutrients() async {
    final nutrients = await FoodService.listAvailableNutrients();
    if (!mounted) return;
    setState(() {
      _availableNutrients = nutrients;
    });
  }

  @override
  void dispose() {
    _vnNameController.dispose();
    _nameController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _baseLiquidController.dispose();
    _volumeController.dispose();
    _tempController.dispose();
    _sweetnessController.dispose();
    _hydrationController.dispose();
    _caffeineController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add({'food_id': null, 'food_name': '', 'amount_g': 100});
    });
  }

  void _addNutrientRow() {
    setState(() {
      _selectedNutrients.add({
        'nutrient_id': null,
        'nutrient_code': null,
        'nutrient_name': null,
        'amount_per_100ml': 0
      });
    });
  }

  Future<Map<String, dynamic>?> _openFoodSearchDialog() async {
    final queryCtrl = TextEditingController();
    List<Map<String, dynamic>> results = [];
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setStateDialog) {
        Future<void> search() async {
          final q = queryCtrl.text.trim();
          if (q.isEmpty) return;
          results = await FoodService.searchFoods(q, limit: 10);
          setStateDialog(() {});
        }

        return AlertDialog(
          title: const Text('Tìm thực phẩm'),
          content: SizedBox(
            width: 600,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: queryCtrl,
                  decoration: const InputDecoration(labelText: 'Tên thực phẩm'),
                  onSubmitted: (_) => search()),
              const SizedBox(height: 12),
              if (results.isNotEmpty)
                SizedBox(
                    height: 200,
                    child: ListView(
                        children: results
                            .map((r) => ListTile(
                                title: Text(
                                    r['name'] ?? r['vietnamese_name'] ?? 'N/A'),
                                subtitle: Text(r['category'] ?? ''),
                                onTap: () => Navigator.pop(ctx, r)))
                            .toList()))
              else
                const SizedBox.shrink(),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Hủy'))
          ],
        );
      }),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'name': _nameController.text.trim().isEmpty
            ? _vnNameController.text.trim()
            : _nameController.text.trim(),
        'vietnamese_name': _vnNameController.text.trim().isEmpty
            ? null
            : _vnNameController.text.trim(),
        'slug': _slugController.text.trim().isEmpty
            ? null
            : _slugController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'category': _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        'base_liquid': _baseLiquidController.text.trim().isEmpty
            ? null
            : _baseLiquidController.text.trim(),
        'default_volume_ml':
            double.tryParse(_volumeController.text.trim()) ?? 250,
        'default_temperature': _tempController.text.trim().isEmpty
            ? null
            : _tempController.text.trim(),
        'default_sweetness': _sweetnessController.text.trim().isEmpty
            ? null
            : _sweetnessController.text.trim(),
        'hydration_ratio':
            double.tryParse(_hydrationController.text.trim()) ?? 1,
        'caffeine_mg': double.tryParse(_caffeineController.text.trim()) ?? 0,
        'sugar_free': _sugarFree,
        'is_template': _isTemplate,
        'is_public': _isPublic,
        'image_url': _imageController.text.trim().isEmpty
            ? null
            : _imageController.text.trim(),
        'ingredients': _ingredients
            .map((i) => {
                  'food_id': i['food_id'],
                  'amount_g': i['amount_g'],
                })
            .toList(),
        'nutrients': _selectedNutrients
            .where((n) => n['nutrient_id'] != null)
            .map((n) => {
                  'nutrient_id': n['nutrient_id'],
                  'amount_per_100ml': double.tryParse(
                          n['amount_per_100ml']?.toString() ?? '0') ??
                      0,
                })
            .toList(),
      };

      final res = await DrinkService.adminUpsertDrink(payload,
          drinkId: widget.drink?['drink_id'] as int?);
      if (!mounted) return;
      setState(() => _isSaving = false);
      if (res != null && res['error'] == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.drink != null
                ? 'Cập nhật đồ uống thành công'
                : 'Thêm đồ uống thành công')));
        widget.onSaved();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi lưu: ${res?['error'] ?? 'Unknown'}')));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // build ingredient and nutrient rows
    final ingredientWidgets = _ingredients.asMap().entries.map((e) {
      final i = e.key;
      final ing = e.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(
            child: TextFormField(
              controller: TextEditingController(
                  text: ing['food_name']?.toString() ?? ''),
              decoration: const InputDecoration(labelText: 'Food name'),
              onTap: () async {
                final chosen = await _openFoodSearchDialog();
                if (chosen != null) {
                  setState(() {
                    _ingredients[i]['food_id'] =
                        chosen['food_id'] ?? chosen['id'];
                    _ingredients[i]['food_name'] = chosen['name'] ??
                        chosen['vietnamese_name'] ??
                        chosen['title'];
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: TextEditingController(
                  text: ing['amount_g']?.toString() ?? '100'),
              decoration: const InputDecoration(labelText: 'g'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) =>
                  _ingredients[i]['amount_g'] = double.tryParse(v) ?? 0,
            ),
          ),
          IconButton(
              onPressed: () => setState(() => _ingredients.removeAt(i)),
              icon: const Icon(Icons.delete, color: Colors.red))
        ]),
      );
    }).toList();

    final nutrientWidgets = _selectedNutrients.asMap().entries.map((e) {
      final i = e.key;
      final n = e.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: n['nutrient_id'] as int?,
              items: _availableNutrients
                  .map((a) => DropdownMenuItem<int>(
                      value: a['nutrient_id'] as int,
                      child: Text(
                          '${a['nutrient_code']} - ${a['nutrient_name']}')))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedNutrients[i]['nutrient_id'] = v),
              decoration: const InputDecoration(labelText: 'Nutrient'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: TextFormField(
              initialValue: n['amount_per_100ml']?.toString() ?? '0',
              decoration: const InputDecoration(labelText: 'amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => _selectedNutrients[i]['amount_per_100ml'] = v,
            ),
          ),
          IconButton(
              onPressed: () => setState(() => _selectedNutrients.removeAt(i)),
              icon: const Icon(Icons.delete, color: Colors.red)),
        ]),
      );
    }).toList();

    return Dialog(
      child: SizedBox(
        width: 920,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.drink != null
                              ? 'Chỉnh sửa đồ uống'
                              : 'Thêm đồ uống',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // left image/flags
                            Container(
                              width: 260,
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: (widget.drink != null &&
                                            (widget.drink!['image_url'] ??
                                                    _imageController.text)
                                                .toString()
                                                .isNotEmpty)
                                        ? Image.network(
                                            widget.drink!['image_url'] ??
                                                _imageController.text,
                                            width: 240,
                                            height: 160,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.local_drink,
                                                    size: 80))
                                        : Container(
                                            width: 240,
                                            height: 160,
                                            color: Colors.grey[100],
                                            child: const Icon(Icons.local_drink,
                                                size: 80)),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                      controller: _imageController,
                                      decoration: const InputDecoration(
                                          labelText: 'Image URL'),
                                      onChanged: (_) => setState(() {})),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Checkbox(
                                        value: _sugarFree,
                                        onChanged: (v) => setState(
                                            () => _sugarFree = v ?? false)),
                                    const Text('Sugar free')
                                  ]),
                                  Row(children: [
                                    Checkbox(
                                        value: _isTemplate,
                                        onChanged: (v) => setState(
                                            () => _isTemplate = v ?? true)),
                                    const Text('Template')
                                  ]),
                                  Row(children: [
                                    Checkbox(
                                        value: _isPublic,
                                        onChanged: (v) => setState(
                                            () => _isPublic = v ?? true)),
                                    const Text('Public')
                                  ]),
                                ],
                              ),
                            ),
                            // right main fields
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Row(children: [
                                    Expanded(
                                        child: TextFormField(
                                            controller: _vnNameController,
                                            decoration: const InputDecoration(
                                                labelText: 'Tên tiếng Việt *'),
                                            validator: (v) =>
                                                v == null || v.trim().isEmpty
                                                    ? 'Bắt buộc'
                                                    : null)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: TextFormField(
                                            controller: _nameController,
                                            decoration: const InputDecoration(
                                                labelText: 'Tên tiếng Anh')))
                                  ]),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Expanded(
                                        child: TextFormField(
                                            controller: _slugController,
                                            decoration: const InputDecoration(
                                                labelText: 'Slug (URL)'))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: TextFormField(
                                            controller: _categoryController,
                                            decoration: const InputDecoration(
                                                labelText: 'Danh mục')))
                                  ]),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                      controller: _descriptionController,
                                      decoration: const InputDecoration(
                                          labelText: 'Mô tả'),
                                      maxLines: 3),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Expanded(
                                        child: TextFormField(
                                            controller: _baseLiquidController,
                                            decoration: const InputDecoration(
                                                labelText: 'Base liquid'))),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                        width: 160,
                                        child: TextFormField(
                                            controller: _volumeController,
                                            decoration: const InputDecoration(
                                                labelText: 'Thể tích (ml)')))
                                  ]),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    SizedBox(
                                        width: 180,
                                        child: TextFormField(
                                            controller: _tempController,
                                            decoration: const InputDecoration(
                                                labelText: 'Nhiệt độ'))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: TextFormField(
                                            controller: _sweetnessController,
                                            decoration: const InputDecoration(
                                                labelText: 'Mức ngọt')))
                                  ]),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    SizedBox(
                                        width: 180,
                                        child: TextFormField(
                                            controller: _hydrationController,
                                            decoration: const InputDecoration(
                                                labelText: 'Hydration ratio'))),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                        width: 160,
                                        child: TextFormField(
                                            controller: _caffeineController,
                                            decoration: const InputDecoration(
                                                labelText: 'Caffeine (mg)')))
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nguyên liệu',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextButton(
                                  onPressed: _addIngredientRow,
                                  child: const Text('+ Thêm'))
                            ]),
                        const SizedBox(height: 8),
                        ...ingredientWidgets,
                        const SizedBox(height: 12),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Dinh dưỡng (per 100ml)',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextButton(
                                  onPressed: _addNutrientRow,
                                  child: const Text('+ Thêm'))
                            ]),
                        const SizedBox(height: 8),
                        ...nutrientWidgets,
                        const SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: _isSaving
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text('Hủy')),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                  onPressed: _isSaving ? null : _save,
                                  child:
                                      Text(_isSaving ? 'Đang lưu...' : 'Lưu'))
                            ]),
                      ],
                    ), // end inner Column (Form)
                  ), // end Form
                ],
              ), // end Column (scroll child)
            ), // end SingleChildScrollView
          ), // end Padding
        ), // end ConstrainedBox
      ), // end SizedBox
    ); // end Dialog
  }
}

class _WebDrinkDetailPage extends StatefulWidget {
  final Map<String, dynamic> drinkData;
  const _WebDrinkDetailPage({required this.drinkData});

  @override
  State<_WebDrinkDetailPage> createState() => _WebDrinkDetailPageState();
}

class _WebDrinkDetailPageState extends State<_WebDrinkDetailPage> {
  late Map<String, dynamic> drink;

  @override
  void initState() {
    super.initState();
    // Normalize possible wrapped response shapes so detail page finds fields
    Map<String, dynamic> d = Map<String, dynamic>.from(widget.drinkData);
    if (d.containsKey('drink') && d['drink'] is Map) {
      d = Map<String, dynamic>.from(d['drink']);
    } else if (d.containsKey('data') && d['data'] is Map) {
      final inner = d['data'];
      if (inner is Map && inner.containsKey('drink') && inner['drink'] is Map) {
        d = Map<String, dynamic>.from(inner['drink']);
      } else if (inner is Map) {
        d = Map<String, dynamic>.from(inner);
      }
    }
    drink = d;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Widget _buildStat(String label, String value) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value)
      ]);

  Widget _buildIngredients() {
    final ingredients =
        List<Map<String, dynamic>>.from(drink['ingredients'] ?? []);
    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: ingredients.map((ing) {
            final name = ing['food_name'] ?? 'ID ${ing['food_id'] ?? ''}';
            final amt = ing['amount_g'] ?? ing['amount'] ?? '';
            return ListTile(
              title: Text(name.toString()),
              subtitle: Text(ing['notes']?.toString() ?? ''),
              trailing: Text('$amt g'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNutrients() {
    final raw = drink['nutrients'] ??
        drink['nutrient_details'] ??
        drink['drink_nutrients'] ??
        drink['drink_nutrient'] ??
        [];
    final nutrients = <Map<String, dynamic>>[];
    if (raw is Map) {
      // keyed by nutrient code or id
      raw.forEach((k, v) {
        if (v is Map) nutrients.add(Map<String, dynamic>.from(v));
      });
    } else if (raw is List) {
      for (final e in raw) {
        if (e is Map) nutrients.add(Map<String, dynamic>.from(e));
      }
    }

    if (nutrients.isEmpty) return const SizedBox.shrink();

    Map<String, dynamic> normalizeNutrient(Map<String, dynamic> n) {
      // support shapes like:
      // {nutrient_id, nutrient_code, nutrient_name, amount_per_100ml, unit}
      // {drink_nutrient_id, nutrient: {id, code, name, unit}, amount_per_100ml}
      // {nutrient: {...}, amount_per_100ml}
      final out = <String, dynamic>{};
      if (n.containsKey('nutrient') && n['nutrient'] is Map) {
        final inner = Map<String, dynamic>.from(n['nutrient']);
        out['nutrient_id'] = inner['nutrient_id'] ?? inner['id'];
        out['nutrient_code'] = inner['nutrient_code'] ?? inner['code'];
        out['nutrient_name'] = inner['nutrient_name'] ?? inner['name'];
        out['unit'] = inner['unit'] ?? inner['uom'] ?? '';
      }
      out['nutrient_id'] =
          out['nutrient_id'] ?? n['nutrient_id'] ?? n['id'] ?? n['nutrientId'];
      out['nutrient_code'] = out['nutrient_code'] ??
          n['nutrient_code'] ??
          n['code'] ??
          n['nutrient_code'];
      out['nutrient_name'] =
          out['nutrient_name'] ?? n['nutrient_name'] ?? n['name'] ?? n['label'];
      out['unit'] = out['unit'] ?? n['unit'] ?? n['uom'] ?? '';
      out['amount_per_100ml'] = n['amount_per_100ml'] ??
          n['amount_per_100g'] ??
          n['value'] ??
          n['amount'] ??
          0;
      out['raw'] = n;
      return out;
    }

    final normalized = nutrients.map(normalizeNutrient).toList();

    // present as a DataTable for clarity
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Chi tiết dinh dưỡng (per 100ml)',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Mã')),
              DataColumn(label: Text('Tên')),
              DataColumn(label: Text('Lượng /100ml')),
              DataColumn(label: Text('Đơn vị')),
            ],
            rows: normalized.map((n) {
              return DataRow(cells: [
                DataCell(Text((n['nutrient_code'] ?? '').toString())),
                DataCell(Text((n['nutrient_name'] ?? '').toString())),
                DataCell(Text((_toDouble(n['amount_per_100ml'])).toString())),
                DataCell(Text((n['unit'] ?? '').toString())),
              ]);
            }).toList(),
          ),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final String titleStr = drink['vietnamese_name'] ??
        drink['name'] ??
        drink['title'] ??
        drink['display_name'] ??
        drink['label'] ??
        'Chi tiết đồ uống';
    final dynamic imageUrl = drink['image_url'] ??
        drink['image'] ??
        drink['photo_url'] ??
        drink['imageUrl'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titleStr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Sửa',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (_) => _WebAddEditDrinkDialog(
                    drink: Map<String, dynamic>.from(drink),
                    onSaved: () async {
                      // refetch updated detail
                      final updated = await DrinkService.adminFetchDetail(
                          drink['drink_id'] as int);
                      if (updated != null) {
                        final Map<String, dynamic> newData =
                            updated['drink'] is Map
                                ? Map<String, dynamic>.from(updated['drink'])
                                : Map<String, dynamic>.from(updated);
                        if (!mounted) return;
                        setState(() {
                          drink = newData;
                        });
                      }
                    }),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(drink['vietnamese_name'] ?? drink['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    if (drink['name'] != null)
                      Text(drink['name'],
                          style: const TextStyle(color: Colors.grey)),
                  ]),
            ),
            if (imageUrl != null && imageUrl.toString().isNotEmpty)
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imageUrl.toString(),
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.local_drink, size: 80)))
          ]),
          const SizedBox(height: 16),
          Text(drink['description'] ?? '',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 6, children: [
            if (drink['drink_id'] != null)
              Chip(label: Text('ID: ${drink['drink_id']}')),
            if (drink['slug'] != null)
              Chip(label: Text('Slug: ${drink['slug']}')),
            Chip(
                label: Text(drink['is_public'] == true ? 'Public' : 'Private')),
            Chip(
                label:
                    Text(drink['is_template'] == true ? 'Template' : 'Custom')),
            if (drink['sugar_free'] == true)
              const Chip(label: Text('Sugar free')),
            if (drink['base_liquid'] != null)
              Chip(label: Text('Base: ${drink['base_liquid']}')),
            if (drink['default_temperature'] != null)
              Chip(label: Text('Temp: ${drink['default_temperature']}')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            if (drink['created_by_user'] != null || drink['created_by'] != null)
              Expanded(
                  child: Text(
                      'Tạo bởi: ${(drink['created_by_user'] ?? drink['created_by'] ?? 'unknown').toString()}')),
            if (drink['created_at'] != null)
              Text('Tạo: ${drink['created_at']}'),
            const SizedBox(width: 12),
            if (drink['updated_at'] != null)
              Text('Cập nhật: ${drink['updated_at']}'),
          ]),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStat(
                        'Thể tích', '${drink['default_volume_ml'] ?? 250} ml'),
                    _buildStat('Hydration',
                        '${(_toDouble(drink['hydration_ratio']) * 100).toStringAsFixed(0)}%'),
                    _buildStat('Caffeine', '${drink['caffeine_mg'] ?? 0} mg'),
                    _buildStat(
                        'Danh mục', (drink['category'] ?? 'Khác').toString()),
                  ]),
            ),
          ),
          const SizedBox(height: 16),
          _buildIngredients(),
          const SizedBox(height: 16),
          _buildNutrients(),
        ]),
      ),
    );
  }
}

class _WebAdminDrinksState extends State<WebAdminDrinks> {
  List<Map<String, dynamic>> _drinks = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool? _filterTemplate;
  bool? _filterPublic;

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

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _showDrinkDetails(Map<String, dynamic> drink) async {
    // Navigate to full detail page for better layout and handling of related tables
    try {
      final detail =
          await DrinkService.adminFetchDetail(drink['drink_id'] as int);
      if (detail == null || !mounted) return;
      final Map<String, dynamic> drinkData = detail['drink'] is Map
          ? Map<String, dynamic>.from(detail['drink'])
          : Map<String, dynamic>.from(detail);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _WebDrinkDetailPage(drinkData: drinkData),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deleteDrink(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa đồ uống "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await DrinkService.adminDeleteDrink(id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa đồ uống')),
      );
      _loadDrinks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa thất bại')),
      );
    }
  }

  Future<void> _approveDrink(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt đồ uống'),
        content: Text('Bạn có chắc muốn phê duyệt đồ uống "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await DrinkService.adminApproveDrink(id);
    if (!mounted) return;

    if (res != null && res['error'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã phê duyệt đồ uống'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDrinks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi phê duyệt: ${res?['error'] ?? 'Unknown'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openDrinkFormDialog({Map<String, dynamic>? initial}) async {
    // Use the richer dialog widget implemented above to keep UI consistent
    Map<String, dynamic>? effectiveInitial = initial;
    if (initial != null && initial['drink_id'] != null) {
      try {
        final detail =
            await DrinkService.adminFetchDetail(initial['drink_id'] as int);
        if (!mounted) return;
        if (detail != null && detail['drink'] is Map) {
          effectiveInitial = Map<String, dynamic>.from(detail['drink'] as Map);
        }
      } catch (_) {
        // fallback to initial
      }
    }

    await showDialog(
      context: context,
      builder: (_) => _WebAddEditDrinkDialog(
          drink: effectiveInitial != null
              ? Map<String, dynamic>.from(effectiveInitial)
              : null,
          onSaved: () {
            _loadDrinks();
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDrinks = _drinks.where((drink) {
      final name = (drink['vietnamese_name'] ?? drink['name'] ?? '')
          .toString()
          .toLowerCase();
      final matchesSearch =
          _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());

      final matchesTemplate = _filterTemplate == null
          ? true
          : (drink['is_template'] == true) == _filterTemplate;
      final matchesPublic = _filterPublic == null
          ? true
          : (drink['is_public'] == true) == _filterPublic;

      return matchesSearch && matchesTemplate && matchesPublic;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      initialValue: _filterTemplate,
                      decoration: const InputDecoration(
                        labelText: 'Loại',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Template'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Người dùng tạo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _filterTemplate = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      initialValue: _filterPublic,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Tất cả')),
                        DropdownMenuItem(
                          value: true,
                          child: Text('Public'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Chờ duyệt'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _filterPublic = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: WebDataTable<Map<String, dynamic>>(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Tên')),
                DataColumn(label: Text('Loại')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(label: Text('Hydration')),
                DataColumn(label: Text('Thể tích')),
                DataColumn(label: Text('Thao tác')),
              ],
              rows: filteredDrinks,
              rowBuilder: (context, drink, index) {
                final hydration = _toDouble(drink['hydration_ratio']);
                final bool isPublic = drink['is_public'] == true;
                final bool isPendingUserDrink =
                    drink['created_by_user'] != null && isPublic == false;

                return DataRow(
                  cells: [
                    DataCell(Text('${drink['drink_id'] ?? ''}')),
                    DataCell(Text(
                      drink['vietnamese_name'] ?? drink['name'] ?? 'N/A',
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            drink['is_template'] == true
                                ? Icons.star
                                : Icons.person,
                            size: 16,
                            color: drink['is_template'] == true
                                ? Colors.orange
                                : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            drink['is_template'] == true ? 'Template' : 'User',
                            style: TextStyle(
                              fontSize: 12,
                              color: drink['is_template'] == true
                                  ? Colors.orange
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPublic ? Icons.public : Icons.schedule,
                            size: 16,
                            color: isPublic ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPublic ? 'Public' : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: isPublic ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text('${(hydration * 100).toStringAsFixed(0)}%')),
                    DataCell(Text('${drink['default_volume_ml'] ?? 250} ml')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPendingUserDrink)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green,
                              ),
                              tooltip: 'Phê duyệt',
                              onPressed: () => _approveDrink(
                                drink['drink_id'] as int,
                                drink['vietnamese_name'] ??
                                    drink['name'] ??
                                    'đồ uống',
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18),
                            tooltip: 'Xem chi tiết',
                            onPressed: () => _showDrinkDetails(drink),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 18, color: Colors.orange),
                            tooltip: 'Sửa',
                            onPressed: () => _openDrinkFormDialog(
                              initial: drink,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 18, color: Colors.red),
                            tooltip: 'Xóa',
                            onPressed: () => _deleteDrink(
                              drink['drink_id'] as int,
                              drink['vietnamese_name'] ??
                                  drink['name'] ??
                                  'đồ uống',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              isLoading: _isLoading,
              currentPage: 1,
              totalPages: 1,
              totalItems: filteredDrinks.length,
              searchHint: 'Tìm kiếm đồ uống...',
              onSearch: (query) {
                setState(() => _searchQuery = query);
              },
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _openDrinkFormDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Thêm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
