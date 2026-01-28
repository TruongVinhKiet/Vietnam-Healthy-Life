import 'package:flutter/material.dart';
import '../services/admin_role_service.dart';

/// Widget wrapper để bảo vệ screens với role requirements
/// 
/// Usage:
/// ```dart
/// RoleProtectedScreen(
///   requiredRoles: ['user_manager', 'support'],
///   child: YourActualScreen(),
/// )
/// ```
class RoleProtectedScreen extends StatefulWidget {
  final List<String> requiredRoles;
  final Widget child;
  final String? customErrorMessage;

  const RoleProtectedScreen({
    super.key,
    required this.requiredRoles,
    required this.child,
    this.customErrorMessage,
  });

  @override
  State<RoleProtectedScreen> createState() => _RoleProtectedScreenState();
}

class _RoleProtectedScreenState extends State<RoleProtectedScreen> {
  final AdminRoleService _roleService = AdminRoleService();
  bool _isLoading = true;
  bool _hasPermission = false;
  List<String> _userRoles = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    try {
      // Lấy roles của user hiện tại
      _userRoles = await _roleService.getMyRoles();

      // Check xem có super_admin không (bypass tất cả)
      if (_userRoles.contains('super_admin')) {
        setState(() {
          _hasPermission = true;
          _isLoading = false;
        });
        return;
      }

      // Check xem có ít nhất 1 role yêu cầu không
      final hasAnyRequiredRole = widget.requiredRoles.any(
        (role) => _userRoles.contains(role),
      );

      setState(() {
        _hasPermission = hasAnyRequiredRole;
        _isLoading = false;
        
        if (!hasAnyRequiredRole) {
          final requiredList = widget.requiredRoles.map((r) => '• $r').join('\n');
          final currentList = _userRoles.isEmpty
              ? '• (Chưa có role nào)'
              : _userRoles.map((r) => '• $r').join('\n');

            _errorMessage = widget.customErrorMessage ??
              'Bạn không có quyền truy cập trang này.\n\nYêu cầu một trong các role sau:\n'
                '$requiredList\n\nRole hiện tại của bạn:\n$currentList';
        }
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
        _isLoading = false;
        _errorMessage = 'Lỗi kiểm tra quyền truy cập: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đang kiểm tra quyền...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Truy cập bị từ chối'),
          backgroundColor: Colors.red[700],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.red[300],
                ),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage ?? 'Bạn không có quyền truy cập trang này',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[900],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigate to role management or contact admin
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng liên hệ Super Admin để được cấp quyền'),
                      ),
                    );
                  },
                  child: const Text('Yêu cầu cấp quyền'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Có permission, hiển thị màn hình gốc
    return widget.child;
  }
}
