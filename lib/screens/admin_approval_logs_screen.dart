import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_diary/screens/admin_dish_detail_screen.dart';
import 'package:my_diary/screens/admin_drink_detail_screen.dart';
import 'package:my_diary/services/admin_approval_log_service.dart';

class AdminApprovalLogsScreen extends StatefulWidget {
  const AdminApprovalLogsScreen({super.key});

  @override
  State<AdminApprovalLogsScreen> createState() =>
      _AdminApprovalLogsScreenState();
}

class _AdminApprovalLogsScreenState extends State<AdminApprovalLogsScreen> {
  static const int _pageSize = 50;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _adminIdController = TextEditingController();
  final TextEditingController _itemIdController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  int _total = 0;

  List<Map<String, dynamic>> _logs = [];

  String? _itemType;
  String? _action;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _adminIdController.dispose();
    _itemIdController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (!position.hasPixels) return;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _load(reset: false);
    }
  }

  int? _parseAdminId() {
    final raw = _adminIdController.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  int? _parseItemId() {
    final raw = _itemIdController.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  String? _itemNameQuery() {
    final raw = _itemNameController.text.trim();
    if (raw.isEmpty) return null;
    return raw;
  }

  String? _formatStartDate(DateTime? value) {
    if (value == null) return null;
    final dt = DateTime(value.year, value.month, value.day, 0, 0, 0);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  String? _formatEndDate(DateTime? value) {
    if (value == null) return null;
    final dt = DateTime(value.year, value.month, value.day, 23, 59, 59);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _isLoadingMore = false;
        _hasMore = true;
        _offset = 0;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await AdminApprovalLogService.listApprovalLogs(
        adminId: _parseAdminId(),
        itemType: _itemType,
        itemId: _parseItemId(),
        itemName: _itemNameQuery(),
        action: _action,
        startDate: _formatStartDate(_startDate),
        endDate: _formatEndDate(_endDate),
        limit: _pageSize,
        offset: _offset,
      );

      final List<dynamic> raw = response['data'] ?? [];
      final page = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final total = response['total'];
      final totalNum = total is int
          ? total
          : int.tryParse(total?.toString() ?? '0') ?? 0;

      setState(() {
        if (reset) {
          _logs = page;
        } else {
          _logs.addAll(page);
        }
        _total = totalNum;
        _hasMore = page.length >= _pageSize;
        if (_hasMore) {
          _offset += _pageSize;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể tải audit log: $e')));
      }
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
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
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => _endDate = picked);
  }

  void _clearFilters() {
    setState(() {
      _itemType = null;
      _action = null;
      _startDate = null;
      _endDate = null;
      _adminIdController.clear();
      _itemIdController.clear();
      _itemNameController.clear();
    });
    _load(reset: true);
  }

  String _formatCreatedAt(dynamic value) {
    if (value == null) return '';
    final raw = value.toString();
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
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

  IconData _typeIcon(dynamic value) {
    final v = value?.toString();
    if (v == 'dish') return Icons.restaurant_rounded;
    if (v == 'drink') return Icons.local_drink_rounded;
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký phê duyệt'),
        actions: [
          IconButton(
            onPressed: () => _load(reset: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          ExpansionTile(
            title: const Text('Bộ lọc'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: _itemType,
                            decoration: const InputDecoration(
                              labelText: 'Loại',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Tất cả'),
                              ),
                              DropdownMenuItem<String?>(
                                value: 'dish',
                                child: Text('Món ăn'),
                              ),
                              DropdownMenuItem<String?>(
                                value: 'drink',
                                child: Text('Đồ uống'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _itemType = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            initialValue: _action,
                            decoration: const InputDecoration(
                              labelText: 'Hành động',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Tất cả'),
                              ),
                              DropdownMenuItem<String?>(
                                value: 'approve',
                                child: Text('Phê duyệt'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _action = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _adminIdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Admin ID',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _load(reset: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _itemIdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Item ID',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _load(reset: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tìm theo tên',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _load(reset: true),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickStartDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate == null
                                  ? 'Từ ngày'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_startDate!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickEndDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate == null
                                  ? 'Đến ngày'
                                  : DateFormat('dd/MM/yyyy').format(_endDate!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _load(reset: true),
                            icon: const Icon(Icons.filter_alt),
                            label: const Text('Áp dụng'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear),
                            label: const Text('Xóa lọc'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đã tải ${_logs.length}/$_total',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _load(reset: true),
                    child: _logs.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('Không có dữ liệu')),
                            ],
                          )
                        : ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            itemCount: _logs.length + (_isLoadingMore ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (_isLoadingMore && index == _logs.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final log = _logs[index];
                              final itemName = (log['item_name'] ?? '')
                                  .toString();
                              final itemIdRaw = log['item_id'];
                              final itemId = itemIdRaw?.toString() ?? '';
                              final itemIdNum = itemIdRaw is int
                                  ? itemIdRaw
                                  : int.tryParse(itemIdRaw?.toString() ?? '');
                              final itemType = log['item_type'];
                              final itemTypeStr = itemType?.toString();
                              final action = log['action'];
                              final admin =
                                  (log['admin_username'] ??
                                          log['admin_id'] ??
                                          '')
                                      .toString();
                              final user =
                                  (log['user_full_name'] ??
                                          log['user_email'] ??
                                          log['created_by_user'] ??
                                          '')
                                      .toString();
                              final createdAt = _formatCreatedAt(
                                log['created_at'],
                              );

                              final title = itemName.isNotEmpty
                                  ? itemName
                                  : '${_typeLabel(itemType)} #$itemId';

                              return Card(
                                child: ListTile(
                                  leading: Icon(_typeIcon(itemType)),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                  ),
                                  onTap: itemIdNum == null
                                      ? null
                                      : () {
                                          if (itemTypeStr == 'dish') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AdminDishDetailScreen(
                                                      dishId: itemIdNum,
                                                    ),
                                              ),
                                            );
                                          } else if (itemTypeStr == 'drink') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AdminDrinkDetailScreen(
                                                      drinkId: itemIdNum,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Không hỗ trợ mở chi tiết cho loại này',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  title: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_actionLabel(action)} • ${_typeLabel(itemType)} #$itemId',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Admin: $admin',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      if (user.isNotEmpty)
                                        Text(
                                          'User: $user',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      if (createdAt.isNotEmpty)
                                        Text(
                                          createdAt,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
