import 'package:flutter/material.dart';
import '../services/admin_role_service.dart';

class AdminRoleManagementScreen extends StatefulWidget {
  const AdminRoleManagementScreen({super.key});

  @override
  State<AdminRoleManagementScreen> createState() => _AdminRoleManagementScreenState();
}

class _AdminRoleManagementScreenState extends State<AdminRoleManagementScreen> {
  final AdminRoleService _roleService = AdminRoleService();
  
  List<Map<String, dynamic>> _allRoles = [];
  List<Map<String, dynamic>> _allAdmins = [];
  Map<String, dynamic> _permissions = {};
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
      // Check xem có phải super_admin không
      try {
        final myRoles = await _roleService.getMyRoles();
        _isSuperAdmin = myRoles.contains('super_admin');
        
        debugPrint('DEBUG: My roles = $myRoles');
        debugPrint('DEBUG: Is super admin = $_isSuperAdmin');
      } catch (e) {
        debugPrint('DEBUG: Error getting roles: $e');
        setState(() {
          _errorMessage = 'Không thể xác thực quyền truy cập: $e';
          _isLoading = false;
        });
        return;
      }
      
      if (!_isSuperAdmin) {
        setState(() {
          _errorMessage = 'Bạn không có quyền truy cập trang này.\n\nChỉ tài khoản có role "Super Admin" mới có thể quản lý phân quyền.';
          _isLoading = false;
        });
        return;
      }

      // Load tất cả data song song
      final results = await Future.wait([
        _roleService.getAllRoles(),
        _roleService.getRolePermissions(),
        _loadAdminsWithRoles(),
      ]);

      setState(() {
        _allRoles = results[0] as List<Map<String, dynamic>>;
        _permissions = results[1] as Map<String, dynamic>;
        _allAdmins = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('DEBUG: Load data error: $e');
      setState(() {
        _errorMessage = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _loadAdminsWithRoles() async {
    try {
      // Lấy danh sách admins từ API
      final admins = await _roleService.getAllAdmins();

      // Load roles cho từng admin
      List<Map<String, dynamic>> adminsWithRoles = [];
      for (var admin in admins) {
        try {
          final adminData = await _roleService.getAdminRoles(admin['admin_id'] as int);
          adminsWithRoles.add(adminData);
        } catch (e) {
          // Nếu không load được roles, vẫn thêm admin vào list
          adminsWithRoles.add({
            ...admin,
            'roles': [],
          });
        }
      }

      return adminsWithRoles;
    } catch (e) {
      debugPrint('DEBUG: Error loading admins: $e');
      return [];
    }
  }

  Future<void> _assignRole(int adminId, String adminEmail, String roleName) async {
    try {
      await _roleService.assignRole(adminId, roleName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã gán role "$roleName" cho $adminEmail'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeRole(int adminId, String adminEmail, String roleName) async {
    try {
      await _roleService.removeRole(adminId, roleName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã gỡ role "$roleName" khỏi $adminEmail'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData(); // Reload data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRoleDialog(Map<String, dynamic> admin) {
    final List<String> currentRoles = List<String>.from(admin['roles'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quản lý roles - ${admin['username']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin ID: ${admin['admin_id']}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Text('Chọn roles:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._allRoles.map((role) {
                final roleName = role['role_name'] as String;
                final hasRole = currentRoles.contains(roleName);
                
                return CheckboxListTile(
                  value: hasRole,
                  title: Row(
                    children: [
                      Text(
                        AdminRoleService.getRoleIcon(roleName),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roleName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              AdminRoleService.getRoleDescription(roleName),
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onChanged: (bool? value) {
                    Navigator.pop(context);
                    
                    if (value == true) {
                      _assignRole(admin['admin_id'], admin['username'], roleName);
                    } else {
                      _removeRole(admin['admin_id'], admin['username'], roleName);
                    }
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog(String roleName) {
    final rolePerms = _permissions[roleName];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(AdminRoleService.getRoleIcon(roleName)),
            const SizedBox(width: 8),
            Text(roleName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rolePerms['description'] ?? '',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...((rolePerms['permissions'] ?? []) as List).map((perm) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(perm.toString()),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 Quản Lý Phân Quyền Admin'),
        backgroundColor: Colors.red[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 80, color: Colors.red[300]),
                      const SizedBox(height: 24),
                      Text(
                        'Truy cập bị từ chối',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red[200]!, width: 2),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.red[900],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Quay lại Dashboard'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header card
                        Card(
                          color: Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.shield, size: 48, color: Colors.red[700]),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Role-Based Access Control',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quản lý phân quyền chi tiết cho từng admin',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Available Roles Section
                        const Text(
                          '📋 Các Role Có Sẵn',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allRoles.map((role) {
                            final roleName = role['role_name'] as String;
                            return InkWell(
                              onTap: () => _showPermissionDialog(roleName),
                              child: Chip(
                                avatar: Text(
                                  AdminRoleService.getRoleIcon(roleName),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                label: Text(roleName),
                                backgroundColor: Color(
                                  int.parse(AdminRoleService.getRoleColor(roleName).substring(1), radix: 16) + 0xFF000000,
                                ).withAlpha((0.15 * 255).round()),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),

                        // Admins List Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '👥 Danh Sách Admin',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${_allAdmins.length} admin(s)',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Admin Cards
                        ..._allAdmins.map((admin) {
                          final roles = List<String>.from(admin['roles'] ?? []);
                          final isSuperAdmin = roles.contains('super_admin');
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSuperAdmin ? Colors.red[700] : Colors.blue[700],
                                child: Text(
                                  isSuperAdmin ? '👑' : '👤',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      admin['username'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (isSuperAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red[700],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'SUPER ADMIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${admin['admin_id']}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  if (roles.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        ...roles.map((role) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(AdminRoleService.getRoleColor(role).substring(1), radix: 16) + 0xFF000000,
                                            ).withAlpha((0.2 * 255).round()),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Color(
                                                int.parse(AdminRoleService.getRoleColor(role).substring(1), radix: 16) + 0xFF000000,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '${AdminRoleService.getRoleIcon(role)} $role',
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      }),
                                      ],
                                    )
                                  else
                                    Text(
                                      'Chưa có role nào',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.blue[700],
                                onPressed: () => _showRoleDialog(admin),
                                tooltip: 'Chỉnh sửa roles',
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Help Section
                        Card(
                          color: Colors.blue[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.blue[700]),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Hướng Dẫn',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildHelpItem('Click vào role badge để xem chi tiết permissions'),
                                _buildHelpItem('Click nút Edit để gán/gỡ roles cho admin'),
                                _buildHelpItem('Super Admin có toàn quyền và bypass mọi kiểm tra'),
                                _buildHelpItem('Một admin có thể có nhiều roles cùng lúc'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
