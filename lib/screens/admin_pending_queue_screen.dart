import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/drink_service.dart';

import '../config/api_config.dart';

class AdminPendingQueueScreen extends StatelessWidget {
  const AdminPendingQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chờ duyệt'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Món ăn'),
              Tab(text: 'Đồ uống'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_PendingDishesTab(), _PendingDrinksTab()],
        ),
      ),
    );
  }
}

class _PendingDishesTab extends StatefulWidget {
  const _PendingDishesTab();

  @override
  State<_PendingDishesTab> createState() => _PendingDishesTabState();
}

class _PendingDishesTabState extends State<_PendingDishesTab> {
  static const int _pageSize = 50;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  List<Map<String, dynamic>> _dishes = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    final position = _scrollController.position;
    if (!position.hasPixels) return;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _load(reset: false);
    }
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
      final token = await AuthService.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Chưa đăng nhập')));
        }
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final query = <String, String>{
        'isPublic': 'false',
        'isTemplate': 'false',
        'limit': _pageSize.toString(),
        'offset': _offset.toString(),
      };

      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        query['search'] = search;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/dishes/admin/all',
      ).replace(queryParameters: query);

      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải danh sách (HTTP ${res.statusCode})'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
        return;
      }

      final body = res.body.isNotEmpty ? json.decode(res.body) : {};
      final List<dynamic> raw = body is Map ? (body['data'] ?? []) : [];

      final page = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      setState(() {
        if (reset) {
          _dishes = page;
        } else {
          _dishes.addAll(page);
        }
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
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _load(reset: true);
    });
  }

  Future<void> _approveDish(Map<String, dynamic> dish) async {
    final dishId = dish['dish_id'];
    if (dishId is! int) return;

    final title = (dish['vietnamese_name'] ?? dish['name'] ?? 'Món ăn')
        .toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt'),
        content: Text('Phê duyệt "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
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

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dishes/admin/$dishId/approve'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          _dishes.removeWhere((d) => d['dish_id'] == dishId);
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã phê duyệt')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Phê duyệt thất bại (HTTP ${res.statusCode})'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm món ăn chờ duyệt...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _load(reset: true);
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _load(reset: true),
                  child: _dishes.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Không có món ăn chờ duyệt')),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _dishes.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (_isLoadingMore && index == _dishes.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final dish = _dishes[index];
                            final title =
                                (dish['vietnamese_name'] ??
                                        dish['name'] ??
                                        'Món ăn')
                                    .toString();
                            final category = dish['category']?.toString();
                            final createdAt = dish['created_at']?.toString();

                            return Card(
                              child: ListTile(
                                title: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (category != null && category.isNotEmpty)
                                      Text(
                                        category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (createdAt != null &&
                                        createdAt.isNotEmpty)
                                      Text(
                                        createdAt,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () => _approveDish(dish),
                                  icon: const Icon(Icons.check_circle_rounded),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

class _PendingDrinksTab extends StatefulWidget {
  const _PendingDrinksTab();

  @override
  State<_PendingDrinksTab> createState() => _PendingDrinksTabState();
}

class _PendingDrinksTabState extends State<_PendingDrinksTab> {
  static const int _pageSize = 50;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  List<Map<String, dynamic>> _drinks = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    final position = _scrollController.position;
    if (!position.hasPixels) return;
    if (position.pixels >= position.maxScrollExtent - 240) {
      _load(reset: false);
    }
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
      final search = _searchController.text.trim();

      final page = await DrinkService.adminFetchDrinks(
        isPublic: false,
        isTemplate: false,
        search: search.isEmpty ? null : search,
        limit: _pageSize,
        offset: _offset,
      );

      setState(() {
        if (reset) {
          _drinks = page;
        } else {
          _drinks.addAll(page);
        }
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
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _load(reset: true);
    });
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _approveDrink(Map<String, dynamic> drink) async {
    final drinkId = drink['drink_id'];
    if (drinkId is! int) return;

    final title = (drink['vietnamese_name'] ?? drink['name'] ?? 'Đồ uống')
        .toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phê duyệt'),
        content: Text('Phê duyệt "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await DrinkService.adminApproveDrink(drinkId);
    if (res != null && res['error'] == null) {
      setState(() {
        _drinks.removeWhere((d) => d['drink_id'] == drinkId);
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã phê duyệt')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['error']?.toString() ?? 'Phê duyệt thất bại'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm đồ uống chờ duyệt...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _load(reset: true);
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => _load(reset: true),
                  child: _drinks.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Không có đồ uống chờ duyệt')),
                          ],
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _drinks.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (_isLoadingMore && index == _drinks.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final drink = _drinks[index];
                            final title =
                                (drink['vietnamese_name'] ??
                                        drink['name'] ??
                                        'Đồ uống')
                                    .toString();
                            final category = drink['category']?.toString();
                            final volume = drink['default_volume_ml']
                                ?.toString();
                            final hydration = _toDouble(
                              drink['hydration_ratio'],
                            );

                            return Card(
                              child: ListTile(
                                title: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (category != null && category.isNotEmpty)
                                      Text(
                                        category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Text(
                                      '${volume ?? 250} ml • Hydration ${(hydration * 100).toStringAsFixed(0)}%',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () => _approveDrink(drink),
                                  icon: const Icon(Icons.check_circle_rounded),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
