import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';

class WebAdminNutrients extends StatefulWidget {
  const WebAdminNutrients({super.key});

  @override
  State<WebAdminNutrients> createState() => _WebAdminNutrientsState();
}

class _WebAdminNutrientsState extends State<WebAdminNutrients> {
  List<dynamic> _nutrients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNutrients();
  }

  Future<void> _loadNutrients({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/admin/nutrients?limit=100&search=$search',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nutrients = data['nutrients'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showNutrientFoods(int nutrientId, String nutrientName) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/nutrients/$nutrientId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] ?? [];
        final unit = data['nutrient']['unit'] ?? '';

        if (mounted) {
          await WebDialog.show(
            context: context,
            title: '$nutrientName - Top thực phẩm',
            width: 700,
            content: SizedBox(
              height: 400,
              child: foods.isEmpty
                  ? const Center(
                      child: Text('Không có thực phẩm nào chứa chất này'),
                    )
                  : ListView.builder(
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        final amount = food['amount_per_100g'];
                        final rank = index + 1;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRankColor(rank),
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(food['name'] ?? 'N/A'),
                            subtitle:
                                Text(food['category'] ?? 'Chưa phân loại'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Text(
                                '$amount $unit',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  Future<void> _deleteNutrient(int nutrientId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa chất dinh dưỡng "$name"?'),
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

    try {
      final res = await AuthService.adminDeleteNutrient(nutrientId);
      if (!mounted) return;
      if (res != null && res['error'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa thành công')),
        );
        _loadNutrients(search: _searchQuery);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Xóa thất bại: ${res?['error'] ?? 'Lỗi không xác định'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: WebDataTable<Map<String, dynamic>>(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Mã')),
          DataColumn(label: Text('Đơn vị')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: _nutrients.cast<Map<String, dynamic>>(),
        rowBuilder: (context, nutrient, index) {
          return DataRow(
            cells: [
              DataCell(Text('${nutrient['nutrient_id'] ?? ''}')),
              DataCell(Text(nutrient['name'] ?? 'N/A')),
              DataCell(Text(nutrient['nutrient_code'] ?? 'N/A')),
              DataCell(Text(nutrient['unit'] ?? 'N/A')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18),
                      tooltip: 'Xem thực phẩm',
                      onPressed: () => _showNutrientFoods(
                        nutrient['nutrient_id'] as int,
                        nutrient['name'] ?? 'N/A',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                      tooltip: 'Xóa',
                      onPressed: () => _deleteNutrient(
                        nutrient['nutrient_id'] as int,
                        nutrient['name'] ?? 'chất dinh dưỡng',
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
        totalItems: _nutrients.length,
        searchHint: 'Tìm kiếm chất dinh dưỡng...',
        onSearch: (query) {
          _searchQuery = query;
          _loadNutrients(search: query);
        },
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Đang phát triển'),
                  content: const Text(
                    'Hiện tại backend chưa hỗ trợ tạo/cập nhật chất dinh dưỡng.\n'
                    'Chức năng này sẽ được bổ sung sau khi có API tương ứng.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
