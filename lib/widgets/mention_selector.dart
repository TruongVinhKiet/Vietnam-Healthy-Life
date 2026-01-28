import 'package:flutter/material.dart';
import '../services/dish_service.dart';
import '../services/drink_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

enum MentionType { dish, drink, healthCondition }

class MentionSelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onSelect;
  final VoidCallback onCancel;

  const MentionSelector({
    super.key,
    required this.onSelect,
    required this.onCancel,
  });

  @override
  State<MentionSelector> createState() => _MentionSelectorState();
}

class _MentionSelectorState extends State<MentionSelector> {
  MentionType? _selectedType;
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems(MentionType type) async {
    setState(() {
      _isLoading = true;
      _items = [];
      _filteredItems = [];
    });

    try {
      List<Map<String, dynamic>> items = [];

      if (type == MentionType.dish) {
        items = await DishService.getDishes(publicOnly: true);
      } else if (type == MentionType.drink) {
        items = await DrinkService.fetchCatalog();
      } else if (type == MentionType.healthCondition) {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/health/conditions'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final conditions = data['conditions'] ?? data;
          items = (conditions is List)
              ? conditions.cast<Map<String, dynamic>>()
              : [];
        }
      }

      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = _items;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = _items.where((item) {
          final nameVi = item['vietnamese_name']?.toString().toLowerCase() ?? '';
          final nameEn = item['name']?.toString().toLowerCase() ?? '';
          final name = item['name_vi']?.toString().toLowerCase() ?? '';
          return nameVi.contains(lowerQuery) ||
              nameEn.contains(lowerQuery) ||
              name.contains(lowerQuery);
        }).toList();
      }
    });
  }

  void _selectItem(Map<String, dynamic> item) {
    String type;
    int id;
    String name;

    if (_selectedType == MentionType.dish) {
      type = 'dish';
      id = item['dish_id'] ?? item['id'] ?? 0;
      name = item['vietnamese_name'] ?? item['name'] ?? '';
    } else if (_selectedType == MentionType.drink) {
      type = 'drink';
      id = item['drink_id'] ?? item['id'] ?? 0;
      name = item['vietnamese_name'] ?? item['name'] ?? '';
    } else {
      type = 'healthCondition';
      id = item['condition_id'] ?? item['id'] ?? 0;
      name = item['name_vi'] ?? item['name'] ?? '';
    }

    widget.onSelect({
      'type': type,
      'id': id,
      'name': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedType == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.orange),
              title: const Text('Món ăn'),
              onTap: () {
                setState(() => _selectedType = MentionType.dish);
                _loadItems(MentionType.dish);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.local_drink, color: Colors.blue),
              title: const Text('Nước uống'),
              onTap: () {
                setState(() => _selectedType = MentionType.drink);
                _loadItems(MentionType.drink);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.medical_services, color: Colors.red),
              title: const Text('Bệnh'),
              onTap: () {
                setState(() => _selectedType = MentionType.healthCondition);
                _loadItems(MentionType.healthCondition);
              },
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with back button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _items = [];
                      _filteredItems = [];
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _selectedType == MentionType.dish
                        ? 'Chọn món ăn'
                        : _selectedType == MentionType.drink
                        ? 'Chọn nước uống'
                        : 'Chọn bệnh',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterItems,
            ),
          ),
          // Items list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Không có dữ liệu'
                          : 'Không tìm thấy',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      String name;
                      if (_selectedType == MentionType.dish) {
                        name = item['vietnamese_name'] ?? item['name'] ?? '';
                      } else if (_selectedType == MentionType.drink) {
                        name = item['vietnamese_name'] ?? item['name'] ?? '';
                      } else {
                        name = item['name_vi'] ?? item['name'] ?? '';
                      }

                      return ListTile(
                        title: Text(name),
                        onTap: () => _selectItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

