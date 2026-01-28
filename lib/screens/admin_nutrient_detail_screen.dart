import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/widgets/nutrient_detail_shell.dart';
import 'admin_nutrient_form_screen.dart';

class AdminNutrientDetailScreen extends StatefulWidget {
  final int nutrientId;
  final String nutrientName;

  const AdminNutrientDetailScreen({
    super.key,
    required this.nutrientId,
    required this.nutrientName,
  });

  @override
  State<AdminNutrientDetailScreen> createState() =>
      _AdminNutrientDetailScreenState();
}

class _AdminNutrientDetailScreenState extends State<AdminNutrientDetailScreen> {
  Map<String, dynamic>? detail; // { nutrient: {...}, foods: [...] }
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final res = await AuthService.adminGetNutrientDetail(widget.nutrientId);
    if (mounted) {
      setState(() {
        detail = res != null && res['error'] == null ? res : null;
        loading = false;
      });
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa chất dinh dưỡng'),
        content: Text(
          'Bạn có chắc muốn xóa "${detail?['nutrient']?['name'] ?? widget.nutrientName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final res = await AuthService.adminDeleteNutrient(widget.nutrientId);
      if (!mounted) return;
      if (res != null && res['error'] == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã xóa thành công')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Xóa thất bại: ${res?['error'] ?? 'Lỗi không xác định'}',
            ),
          ),
        );
      }
    }
  }

  Future<void> _edit() async {
    final nutrient = detail?['nutrient'] as Map<String, dynamic>?;
    if (nutrient == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminNutrientFormScreen(nutrient: nutrient),
      ),
    );
    if (changed == true) {
      await _load();
      if (mounted) Navigator.pop(context, true); // let list refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrient = detail?['nutrient'] as Map<String, dynamic>?;
    final foods =
        (detail?['foods'] as List?)?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    final name = nutrient?['name']?.toString() ?? widget.nutrientName;
    final group = nutrient?['group_name'] ?? nutrient?['category'];
    final unit = nutrient?['unit'];
    final code = nutrient?['nutrient_code'];
    final imageUrl = nutrient?['image_url']?.toString();
    final benefits = nutrient?['benefits']?.toString();
    final rawContra = detail?['contraindications'];
    final contraindications = rawContra is List ? rawContra : null;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final infoRows = <Map<String, String>>[
      {'label': 'Tên Việt Nam', 'value': name},
      if ((code ?? '').toString().isNotEmpty)
        {'label': 'Mã', 'value': code.toString()},
      if ((group ?? '').toString().isNotEmpty)
        {'label': 'Nhóm', 'value': group.toString()},
      if ((unit ?? '').toString().isNotEmpty)
        {'label': 'Đơn vị', 'value': unit.toString()},
      if (nutrient?['recommended_daily'] != null)
        {
          'label': 'RDA',
          'value': '${nutrient!['recommended_daily']} ${unit ?? ''}',
        },
      if (nutrient?['recommended_for_user'] != null &&
          (nutrient?['recommended_for_user']?['value'] != null))
        {
          'label': 'Khuyến nghị cá nhân',
          'value':
              '${nutrient?['recommended_for_user']?['value']} ${nutrient?['recommended_for_user']?['unit'] ?? ''}',
        },
    ];

    return NutrientDetailShell(
      title: name,
      subtitle: (group ?? '').toString(),
      imageUrl: imageUrl ?? '',
      chips: const [],
      overview: (benefits != null && benefits.isNotEmpty)
          ? Text(benefits)
          : null,
      foods: foods,
      contraindications: contraindications,
      infoRows: infoRows,
      actions: [
        IconButton(onPressed: _edit, icon: const Icon(Icons.edit)),
        IconButton(
          onPressed: _delete,
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }
}
