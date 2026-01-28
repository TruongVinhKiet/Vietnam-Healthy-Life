import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../services/admin_approval_log_service.dart';
import '../../services/auth_service.dart';
import '../../services/drink_service.dart';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';

class WebAdminApprovalLogs extends StatefulWidget {
  const WebAdminApprovalLogs({super.key});

  @override
  State<WebAdminApprovalLogs> createState() => _WebAdminApprovalLogsState();
}

class _WebAdminApprovalLogsState extends State<WebAdminApprovalLogs> {
  static const int _pageSize = 50;

  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();

  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  String? _itemType;
  String? _action;
  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<String, dynamic>> _pendingDishes = [];
  List<Map<String, dynamic>> _pendingDrinks = [];
  bool _isLoadingPendingDishes = true;
  bool _isLoadingPendingDrinks = true;

  int _pendingDishPage = 1;
  int _pendingDishTotalPages = 1;
  int _pendingDishTotalItems = 0;

  int _pendingDrinkPage = 1;
  int _pendingDrinkTotalPages = 1;
  int _pendingDrinkTotalItems = 0;

  String _pendingDishSearch = '';
  String _pendingDrinkSearch = '';

  @override
  void initState() {
    super.initState();
    _loadLogs(page: 1);
    _loadPendingDishes(page: 1);
    _loadPendingDrinks(page: 1);
  }

  @override
  void dispose() {
    _adminIdController.dispose();
    _itemIdController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  int? _parseIntField(TextEditingController controller) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  String? _itemNameQuery() {
    final q = _itemNameController.text.trim();
    if (q.isEmpty) return null;
    return q;
  }

  String _formatApiDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }

  String? _formatStartDate(DateTime? value) {
    if (value == null) return null;
    return _formatApiDate(
        DateTime(value.year, value.month, value.day, 0, 0, 0));
  }

  String? _formatEndDate(DateTime? value) {
    if (value == null) return null;
    return _formatApiDate(
      DateTime(value.year, value.month, value.day, 23, 59, 59),
    );
  }

  String _formatDisplayDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m/${value.year}';
  }

  String _formatCreatedAt(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    try {
      final dt = DateTime.parse(raw).toLocal();
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$d/$m/${dt.year} $hh:$mm';
    } catch (_) {
      return raw;
    }
  }

  String _typeLabel(dynamic value) {
    final v = value?.toString();
    if (v == 'dish') return 'Món ăn';
    if (v == 'drink') return 'Đồ uống';
    return v ?? '';
  }

  String _actionLabel(dynamic value) {
    final v = value?.toString();
    if (v == 'approve') return 'Phê duyệt';
    return v ?? '';
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _endDate = picked);
  }

  void _clearFilters() {
    setState(() {
      _adminIdController.clear();
      _itemIdController.clear();
      _itemNameController.clear();
      _itemType = null;
      _action = null;
      _startDate = null;
      _endDate = null;
    });
    _loadLogs(page: 1);
  }

  Future<void> _loadLogs({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final offset = (page - 1) * _pageSize;
      final result = await AdminApprovalLogService.listApprovalLogs(
        adminId: _parseIntField(_adminIdController),
        itemType: _itemType,
        itemId: _parseIntField(_itemIdController),
        itemName: _itemNameQuery(),
        action: _action,
        startDate: _formatStartDate(_startDate),
        endDate: _formatEndDate(_endDate),
        limit: _pageSize,
        offset: offset,
      );

      final rawList =
          result['data'] is List ? (result['data'] as List) : const [];
      final logs = rawList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final totalRaw = result['total'];
      final total = totalRaw is int
          ? totalRaw
          : int.tryParse(totalRaw?.toString() ?? '') ?? 0;
      final totalPages = (total / _pageSize).ceil();

      if (!mounted) return;
      setState(() {
        _logs = logs;
        _totalItems = total;
        _totalPages = totalPages <= 0 ? 1 : totalPages;
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải audit log: $e')),
      );
    }
  }

  Future<void> _loadPendingDishes({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoadingPendingDishes = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        if (!mounted) return;
        setState(() => _isLoadingPendingDishes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa đăng nhập')),
        );
        return;
      }

      final offset = (page - 1) * _pageSize;
      final query = <String, String>{
        'isPublic': 'false',
        'isTemplate': 'false',
        'limit': _pageSize.toString(),
        'offset': offset.toString(),
      };

      final search = _pendingDishSearch.trim();
      if (search.isNotEmpty) {
        query['search'] = search;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/dishes/admin/all')
          .replace(queryParameters: query);
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        if (!mounted) return;
        setState(() => _isLoadingPendingDishes = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách (HTTP ${res.statusCode})'),
          ),
        );
        return;
      }

      final body = res.body.isNotEmpty ? json.decode(res.body) : {};
      final List<dynamic> raw = body is Map ? (body['data'] ?? []) : [];
      final pageData = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final hasMore = pageData.length >= _pageSize;
      if (!mounted) return;
      setState(() {
        _pendingDishes = pageData;
        _pendingDishPage = page;
        _pendingDishTotalItems = (page - 1) * _pageSize + pageData.length;
        _pendingDishTotalPages = hasMore ? page + 1 : page;
        _isLoadingPendingDishes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPendingDishes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách: $e')),
      );
    }
  }

  Future<void> _loadPendingDrinks({int page = 1}) async {
    if (!mounted) return;
    setState(() => _isLoadingPendingDrinks = true);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        if (!mounted) return;
        setState(() => _isLoadingPendingDrinks = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa đăng nhập')),
        );
        return;
      }

      final offset = (page - 1) * _pageSize;
      final search = _pendingDrinkSearch.trim();

      final pageData = await DrinkService.adminFetchDrinks(
        isPublic: false,
        isTemplate: false,
        search: search.isEmpty ? null : search,
        limit: _pageSize,
        offset: offset,
      );

      final hasMore = pageData.length >= _pageSize;
      if (!mounted) return;
      setState(() {
        _pendingDrinks = pageData;
        _pendingDrinkPage = page;
        _pendingDrinkTotalItems = (page - 1) * _pageSize + pageData.length;
        _pendingDrinkTotalPages = hasMore ? page + 1 : page;
        _isLoadingPendingDrinks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPendingDrinks = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách: $e')),
      );
    }
  }

  Future<void> _approvePendingDish(Map<String, dynamic> dish) async {
    final dishId = dish['dish_id'];
    if (dishId is! int) return;

    final dishName =
        (dish['vietnamese_name'] ?? dish['name'] ?? 'món ăn').toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt món ăn'),
        content: Text('Bạn có chắc muốn phê duyệt món "$dishName"?'),
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

    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId/approve'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _pendingDishes.removeWhere((d) => d['dish_id'] == dishId);
          if (_pendingDishTotalItems > 0) _pendingDishTotalItems -= 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã phê duyệt món ăn'),
            backgroundColor: Colors.green,
          ),
        );
        if (_pendingDishes.isEmpty && _pendingDishPage > 1) {
          await _loadPendingDishes(page: _pendingDishPage - 1);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phê duyệt thất bại (HTTP ${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
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

  Future<void> _approvePendingDrink(Map<String, dynamic> drink) async {
    final drinkId = drink['drink_id'];
    if (drinkId is! int) return;

    final drinkName =
        (drink['vietnamese_name'] ?? drink['name'] ?? 'đồ uống').toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt đồ uống'),
        content: Text('Bạn có chắc muốn phê duyệt "$drinkName"?'),
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

    try {
      final res = await DrinkService.adminApproveDrink(drinkId);
      if (!mounted) return;

      if (res != null && res['error'] == null) {
        setState(() {
          _pendingDrinks.removeWhere((d) => d['drink_id'] == drinkId);
          if (_pendingDrinkTotalItems > 0) _pendingDrinkTotalItems -= 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã phê duyệt đồ uống'),
            backgroundColor: Colors.green,
          ),
        );
        if (_pendingDrinks.isEmpty && _pendingDrinkPage > 1) {
          await _loadPendingDrinks(page: _pendingDrinkPage - 1);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['error']?.toString() ?? 'Phê duyệt thất bại'),
            backgroundColor: Colors.red,
          ),
        );
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

  int? _parseItemIdFromLog(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _openItemDetail(Map<String, dynamic> log) async {
    final type = log['item_type']?.toString();
    final itemId = _parseItemIdFromLog(log['item_id']);
    if (itemId == null) return;
    if (type == 'dish') {
      await _showDishDetails(itemId);
      return;
    }
    if (type == 'drink') {
      await _showDrinkDetails(itemId);
      return;
    }
  }

  Future<void> _showDishDetails(int dishId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200 || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy món ăn: $dishId')),
          );
        }
        return;
      }

      final decoded = json.decode(response.body);
      final dish = decoded is Map && decoded['data'] is Map
          ? Map<String, dynamic>.from(decoded['data'] as Map)
          : <String, dynamic>{};

      final nutrientsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId/nutrients'),
        headers: {'Authorization': 'Bearer $token'},
      );

      List<Map<String, dynamic>> nutrients = [];
      if (nutrientsResponse.statusCode == 200) {
        final nutrientsDecoded = json.decode(nutrientsResponse.body);
        final raw = nutrientsDecoded is Map && nutrientsDecoded['data'] is List
            ? (nutrientsDecoded['data'] as List)
            : const [];
        nutrients = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      if (!mounted) return;
      await WebDialog.show(
        context: context,
        title: 'Chi tiết món ăn',
        width: 800,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dish['vietnamese_name'] ?? dish['name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (dish['name'] != null)
                Text(
                  dish['name'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (dish['dish_id'] != null)
                    Chip(
                      avatar: const Icon(Icons.tag, size: 16),
                      label: Text('ID: ${dish['dish_id']}'),
                    ),
                  Chip(
                    avatar: const Icon(Icons.category, size: 16),
                    label: Text(dish['category'] ?? 'N/A'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.scale, size: 16),
                    label: Text('${dish['serving_size_g'] ?? 0}g'),
                  ),
                  Chip(
                    avatar: Icon(
                      dish['is_template'] == true ? Icons.star : Icons.person,
                      size: 16,
                    ),
                    label: Text(
                      dish['is_template'] == true
                          ? 'Món mẫu'
                          : 'Người dùng tạo',
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      dish['is_public'] == true ? Icons.public : Icons.schedule,
                      size: 16,
                    ),
                    label: Text(
                      dish['is_public'] == true ? 'Public' : 'Pending',
                    ),
                  ),
                ],
              ),
              if ((dish['description'] ?? '').toString().trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  (dish['description'] ?? '').toString(),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              if (nutrients.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Thông tin dinh dưỡng (per 100g)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...nutrients.take(10).map(
                      (n) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                (n['nutrient_name'] ?? n['name'] ?? 'N/A')
                                    .toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${n['amount_per_100g'] ?? 0} ${n['unit'] ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _showDrinkDetails(int drinkId) async {
    try {
      final detail = await DrinkService.adminFetchDetail(drinkId);
      if (detail == null || !mounted) return;
      if (detail['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${detail['error']}')),
        );
        return;
      }

      final rawDrink = detail['drink'];
      final Map<String, dynamic> drink = rawDrink is Map
          ? Map<String, dynamic>.from(rawDrink)
          : Map<String, dynamic>.from(detail);

      final ingredients = drink['ingredients'] is List
          ? (drink['ingredients'] as List)
          : const [];
      final nutrients = drink['nutrient_details'] is List
          ? (drink['nutrient_details'] as List)
          : const [];

      await WebDialog.show(
        context: context,
        title: 'Chi tiết đồ uống',
        width: 800,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drink['vietnamese_name'] ?? drink['name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (drink['name'] != null)
                Text(
                  drink['name'],
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (drink['drink_id'] != null)
                    Chip(
                      avatar: const Icon(Icons.tag, size: 16),
                      label: Text('ID: ${drink['drink_id']}'),
                    ),
                  if (drink['category'] != null)
                    Chip(
                      avatar: const Icon(Icons.category, size: 16),
                      label: Text('${drink['category']}'),
                    ),
                  Chip(
                    avatar: const Icon(Icons.local_drink, size: 16),
                    label: Text('${drink['default_volume_ml'] ?? 0} ml'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.water_drop, size: 16),
                    label: Text('${drink['hydration_ratio'] ?? 0} H'),
                  ),
                  Chip(
                    avatar: Icon(
                      drink['is_template'] == true ? Icons.star : Icons.person,
                      size: 16,
                    ),
                    label: Text(
                      drink['is_template'] == true ? 'Template' : 'User',
                    ),
                  ),
                  Chip(
                    avatar: Icon(
                      drink['is_public'] == true
                          ? Icons.public
                          : Icons.schedule,
                      size: 16,
                    ),
                    label: Text(
                      drink['is_public'] == true ? 'Public' : 'Pending',
                    ),
                  ),
                ],
              ),
              if ((drink['description'] ?? '').toString().trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    (drink['description'] ?? '').toString(),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              if (ingredients.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Nguyên liệu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...ingredients.take(12).map((i) {
                  final ing = i is Map
                      ? Map<String, dynamic>.from(i)
                      : <String, dynamic>{};
                  final name = ing['name'] ?? 'N/A';
                  final amount = ing['amount_g'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('$amount g - $name'),
                  );
                }),
              ],
              if (nutrients.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Thông tin dinh dưỡng (per 100ml)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...nutrients.take(10).map((n) {
                  final nutrient = n is Map
                      ? Map<String, dynamic>.from(n)
                      : <String, dynamic>{};
                  final name = nutrient['name'] ?? 'N/A';
                  final amount = nutrient['amount_per_100ml'] ?? 0;
                  final unit = nutrient['unit'] ?? '';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name.toString(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$amount $unit',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Widget _buildPendingTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.teal,
            tabs: const [
              Tab(text: 'Món ăn'),
              Tab(text: 'Đồ uống'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPendingDishesTable(),
                _buildPendingDrinksTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingDishesTable() {
    return WebDataTable<Map<String, dynamic>>(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Tên')),
        DataColumn(label: Text('Danh mục')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Trạng thái')),
        DataColumn(label: Text('Thao tác')),
      ],
      rows: _pendingDishes,
      rowBuilder: (context, dish, index) {
        final rawId = dish['dish_id'];
        final dishId =
            rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
        final name =
            (dish['vietnamese_name'] ?? dish['name'] ?? 'N/A').toString();
        final category = (dish['category'] ?? 'N/A').toString();
        final userText = '${dish['created_by_user'] ?? ''}'.trim();

        return DataRow(
          cells: [
            DataCell(Text(dishId?.toString() ?? '')),
            DataCell(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: dishId == null ? null : () => _showDishDetails(dishId),
                child: Text(name),
              ),
            ),
            DataCell(Text(category)),
            DataCell(Text(userText.isEmpty ? '-' : userText)),
            const DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('Pending'),
                ],
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Phê duyệt',
                    onPressed: () => _approvePendingDish(dish),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Xem chi tiết',
                    onPressed:
                        dishId == null ? null : () => _showDishDetails(dishId),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      isLoading: _isLoadingPendingDishes,
      currentPage: _pendingDishPage,
      totalPages: _pendingDishTotalPages,
      totalItems: _pendingDishTotalItems,
      onPageChanged: (page) => _loadPendingDishes(page: page),
      searchHint: 'Tìm kiếm món ăn...',
      onSearch: (query) {
        setState(() => _pendingDishSearch = query);
        _loadPendingDishes(page: 1);
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          tooltip: 'Tải lại',
          onPressed: () => _loadPendingDishes(page: _pendingDishPage),
        ),
      ],
    );
  }

  Widget _buildPendingDrinksTable() {
    return WebDataTable<Map<String, dynamic>>(
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Tên')),
        DataColumn(label: Text('Danh mục')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Trạng thái')),
        DataColumn(label: Text('Thao tác')),
      ],
      rows: _pendingDrinks,
      rowBuilder: (context, drink, index) {
        final rawId = drink['drink_id'];
        final drinkId =
            rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
        final name =
            (drink['vietnamese_name'] ?? drink['name'] ?? 'N/A').toString();
        final category = (drink['category'] ?? 'N/A').toString();
        final userText = '${drink['created_by_user'] ?? ''}'.trim();

        return DataRow(
          cells: [
            DataCell(Text(drinkId?.toString() ?? '')),
            DataCell(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap:
                    drinkId == null ? null : () => _showDrinkDetails(drinkId),
                child: Text(name),
              ),
            ),
            DataCell(Text(category)),
            DataCell(Text(userText.isEmpty ? '-' : userText)),
            const DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text('Pending'),
                ],
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Phê duyệt',
                    onPressed: () => _approvePendingDrink(drink),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Xem chi tiết',
                    onPressed: drinkId == null
                        ? null
                        : () => _showDrinkDetails(drinkId),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      isLoading: _isLoadingPendingDrinks,
      currentPage: _pendingDrinkPage,
      totalPages: _pendingDrinkTotalPages,
      totalItems: _pendingDrinkTotalItems,
      onPageChanged: (page) => _loadPendingDrinks(page: page),
      searchHint: 'Tìm kiếm đồ uống...',
      onSearch: (query) {
        setState(() => _pendingDrinkSearch = query);
        _loadPendingDrinks(page: 1);
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          tooltip: 'Tải lại',
          onPressed: () => _loadPendingDrinks(page: _pendingDrinkPage),
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 170,
                  child: TextField(
                    controller: _adminIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Admin ID',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _loadLogs(page: 1),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _itemType,
                    decoration: const InputDecoration(
                      labelText: 'Item type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(value: 'dish', child: Text('Món ăn')),
                      DropdownMenuItem(value: 'drink', child: Text('Đồ uống')),
                    ],
                    onChanged: (value) {
                      setState(() => _itemType = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _action,
                    decoration: const InputDecoration(
                      labelText: 'Action',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tất cả')),
                      DropdownMenuItem(
                        value: 'approve',
                        child: Text('Phê duyệt'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _action = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: TextField(
                    controller: _itemIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Item ID',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _loadLogs(page: 1),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _itemNameController,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _loadLogs(page: 1),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: OutlinedButton.icon(
                    onPressed: _pickStartDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _startDate == null
                          ? 'Từ ngày'
                          : _formatDisplayDate(_startDate!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: OutlinedButton.icon(
                    onPressed: _pickEndDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _endDate == null
                          ? 'Đến ngày'
                          : _formatDisplayDate(_endDate!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _loadLogs(page: 1),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Áp dụng'),
                ),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Xóa lọc'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: WebDataTable<Map<String, dynamic>>(
            columns: const [
              DataColumn(label: Text('Thời gian')),
              DataColumn(label: Text('Admin')),
              DataColumn(label: Text('Action')),
              DataColumn(label: Text('Loại')),
              DataColumn(label: Text('Item')),
              DataColumn(label: Text('User')),
              DataColumn(label: Text('Thao tác')),
            ],
            rows: _logs,
            rowBuilder: (context, log, index) {
              final itemType = log['item_type']?.toString();
              final itemId = _parseItemIdFromLog(log['item_id']);
              final canOpen =
                  (itemType == 'dish' || itemType == 'drink') && itemId != null;

              final itemText =
                  '${log['item_id'] ?? ''} ${log['item_name'] ?? ''}'.trim();
              final userText =
                  '${log['created_by_user'] ?? ''} ${log['user_full_name'] ?? log['user_email'] ?? ''}'
                      .trim();
              final adminText =
                  '${log['admin_username'] ?? ''} ${log['admin_id'] ?? ''}'
                      .trim();

              return DataRow(
                cells: [
                  DataCell(Text(_formatCreatedAt(log['created_at']))),
                  DataCell(Text(adminText.isEmpty ? '-' : adminText)),
                  DataCell(Text(_actionLabel(log['action']))),
                  DataCell(Text(_typeLabel(log['item_type']))),
                  DataCell(
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: canOpen ? () => _openItemDetail(log) : null,
                      child: Text(itemText.isEmpty ? '-' : itemText),
                    ),
                  ),
                  DataCell(Text(userText.isEmpty ? '-' : userText)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 18),
                          tooltip: 'Xem chi tiết',
                          onPressed:
                              canOpen ? () => _openItemDetail(log) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            isLoading: _isLoading,
            currentPage: _currentPage,
            totalPages: _totalPages,
            totalItems: _totalItems,
            onPageChanged: (page) => _loadLogs(page: page),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TabBar(
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: 'Chờ duyệt'),
                Tab(text: 'Nhật ký'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPendingTab(),
                  _buildLogsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
