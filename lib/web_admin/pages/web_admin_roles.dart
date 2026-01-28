import 'package:flutter/material.dart';
import '../components/web_data_table.dart';
import '../components/web_dialog.dart';
import '../../services/admin_role_service.dart';

class WebAdminRoles extends StatefulWidget {
  const WebAdminRoles({super.key});

  @override
  State<WebAdminRoles> createState() => _WebAdminRolesState();
}

class _WebAdminRolesState extends State<WebAdminRoles> {
  final AdminRoleService _roleService = AdminRoleService();
  List<Map<String, dynamic>> _allRoles = [];
  List<Map<String, dynamic>> _allAdmins = [];
  bool _isLoading = true;
  bool _isSuperAdmin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final myRoles = await _roleService.getMyRoles();
      _isSuperAdmin = myRoles.contains('super_admin');

      if (!_isSuperAdmin) {
        setState(() {
          _errorMessage =
              'Bạn không có quyền truy cập trang này.\n\nChỉ tài khoản có role "Super Admin" mới có thể quản lý phân quyền.';
          _isLoading = false;
        });
        return;
      }

      final results = await Future.wait([
        _roleService.getAllRoles(),
        _loadAdminsWithRoles(),
      ]);

      setState(() {
        _allRoles = List<Map<String, dynamic>>.from(results[0]);
        _allAdmins = List<Map<String, dynamic>>.from(results[1]);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadAdminsWithRoles() async {
    try {
      final admins = await _roleService.getAllAdmins();
      List<Map<String, dynamic>> adminsWithRoles = [];
      for (var admin in admins) {
        try {
          // Normalize admin_id to int
          final adminIdRaw = admin['admin_id'];
          int? adminId;
          if (adminIdRaw is int) {
            adminId = adminIdRaw;
          } else if (adminIdRaw is String) {
            adminId = int.tryParse(adminIdRaw);
          } else if (adminIdRaw is double) {
            adminId = adminIdRaw.toInt();
          }
          
          if (adminId == null) {
            adminsWithRoles.add({
              ...admin,
              'roles': [],
            });
            continue;
          }
          
          final adminData = await _roleService.getAdminRoles(adminId);
          adminsWithRoles.add(adminData);
        } catch (e) {
          adminsWithRoles.add({
            ...admin,
            'roles': [],
          });
        }
      }
      return adminsWithRoles;
    } catch (e) {
      return [];
    }
  }

  Future<void> _assignRole(dynamic adminIdRaw, String roleName) async {
    try {
      // Normalize adminId to int
      int adminId;
      if (adminIdRaw is int) {
        adminId = adminIdRaw;
      } else if (adminIdRaw is String) {
        adminId = int.parse(adminIdRaw);
      } else if (adminIdRaw is double) {
        adminId = adminIdRaw.toInt();
      } else {
        throw Exception('Invalid admin_id type');
      }
      
      await _roleService.assignRole(adminId, roleName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gán role $roleName')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _removeRole(dynamic adminIdRaw, String roleName) async {
    try {
      // Normalize adminId to int
      int adminId;
      if (adminIdRaw is int) {
        adminId = adminIdRaw;
      } else if (adminIdRaw is String) {
        adminId = int.parse(adminIdRaw);
      } else if (adminIdRaw is double) {
        adminId = adminIdRaw.toInt();
      } else {
        throw Exception('Invalid admin_id type');
      }
      
      await _roleService.removeRole(adminId, roleName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gỡ role $roleName')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _showAdminRoles(Map<String, dynamic> admin) async {
    await WebDialog.show(
      context: context,
      title: 'Phân quyền: ${admin['username']}',
      width: 600,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${admin['username']}'),
          const SizedBox(height: 16),
          const Text(
            'Roles hiện tại:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: (admin['roles'] as List<dynamic>? ?? [])
                .map((role) {
                  final roleName = role is Map 
                      ? (role['role_name'] ?? '') 
                      : role.toString();
                  return Chip(
                    label: Text(roleName),
                    onDeleted: () => _removeRole(
                      admin['admin_id'],
                      roleName,
                    ),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gán role mới:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _allRoles
                .where((role) => !(admin['roles'] as List<dynamic>? ?? []).any(
                      (r) => r['role_name'] == role['role_name'],
                    ))
                .map((role) => ActionChip(
                      label: Text(role['role_name'] ?? ''),
                      onPressed: () => _assignRole(
                        admin['admin_id'],
                        role['role_name'],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Không có quyền truy cập',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.purple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Tổng số roles',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_allRoles.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Tổng số admin',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_allAdmins.length}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Admins Table
          Expanded(
            child: WebDataTable<Map<String, dynamic>>(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Roles')),
                DataColumn(label: Text('Thao tác')),
              ],
              rows: _allAdmins.cast<Map<String, dynamic>>(),
              rowBuilder: (context, admin, index) {
                final roles = admin['roles'] as List<dynamic>? ?? [];
                return DataRow(
                  cells: [
                    DataCell(Text('${admin['admin_id'] ?? ''}')),
                    DataCell(Text(admin['username'] ?? 'N/A')),
                    DataCell(
                      Wrap(
                        spacing: 4,
                        children: roles
                            .map((role) {
                              final roleName = role is Map 
                                  ? (role['role_name'] ?? '') 
                                  : role.toString();
                              return Chip(
                                label: Text(
                                  roleName,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: Colors.blue.shade50,
                              );
                            })
                            .toList(),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _showAdminRoles(admin),
                        tooltip: 'Quản lý roles',
                      ),
                    ),
                  ],
                );
              },
              isLoading: _isLoading,
              currentPage: 1,
              totalPages: 1,
              totalItems: _allAdmins.length,
              actions: [
                ElevatedButton.icon(
                  onPressed: _loadData,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Làm mới'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
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
