// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'register_screen.dart';
import 'admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginComplete;

  const LoginScreen({super.key, this.onLoginComplete});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _identifier = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await AuthService.login(
      identifier: _identifier,
      password: _password,
    );
    setState(() {
      _loading = false;
    });
    // Handle blocked account response shape from backend: { blocked: true, reason, can_request_unblock, unlock_required }
    if (res != null && res['blocked'] == true) {
      if (!context.mounted) return;
      final canRequest = res['can_request_unblock'] == true;
      final unlockRequired = res['unlock_required'] == true;
      final reason = (res['reason'] ?? 'Tài khoản đã bị chặn').toString();
      
      // Show local notification for account lock
      final attempts = res['failed_attempts'] as int? ?? 0;
      final threshold = res['lock_threshold'] as int? ?? 5;
      if (attempts > 0 && threshold > 0) {
        await LocalNotificationService().notifyAccountLocked(attempts, threshold);
      }
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          final unlockCodeCtrl = TextEditingController();
          return AlertDialog(
            title: const Text('Tài khoản bị chặn'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason),
                const SizedBox(height: 12),
                if (unlockRequired) ...[
                  const Text(
                    'Bạn có thể nhận mã mở khóa qua email và nhập mã để mở khóa ngay.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: unlockCodeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Mã mở khóa',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final resp =
                              await AuthService.requestUnlockCode(identifier: _identifier);
                          if (!context.mounted) return;
                          if (resp == null || resp['error'] != null) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(resp?['error']?.toString() ??
                                    'Không gửi được mã mở khóa'),
                              ),
                            );
                            return;
                          }
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Đã gửi mã mở khóa tới email của bạn')),
                          );
                        },
                        child: const Text('Gửi mã'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Xác nhận mở khóa'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final resp = await AuthService.confirmUnlockCode(
                        identifier: _identifier,
                        code: unlockCodeCtrl.text.trim(),
                      );
                      if (!context.mounted) return;
                      if (resp == null || resp['error'] != null) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(resp?['error']?.toString() ??
                                'Mã không hợp lệ'),
                          ),
                        );
                        return;
                      }
                      // Show local notification for account unlock
                      await LocalNotificationService().notifyAccountUnlocked();
                      
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Đã mở khóa tài khoản, vui lòng đăng nhập lại'),
                        ),
                      );
                      Navigator.of(ctx).pop();
                    },
                  ),
                  const Divider(height: 20),
                ],
                if (canRequest) ...[
                  const Text(
                    'Bạn có thể gửi yêu cầu gỡ chặn (tùy chọn ghi chú):',
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú cho quản trị viên',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Đóng'),
              ),
              if (canRequest)
                ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(ctx).pop();
                    final resp = await AuthService.submitUnblockRequest(
                      identifier: _identifier,
                      message: controller.text.trim().isNotEmpty
                          ? controller.text.trim()
                          : null,
                    );
                    if (!context.mounted) return;
                    if (resp != null && resp['error'] == null) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Đã gửi yêu cầu gỡ chặn')),
                      );
                    } else {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            resp?['error']?.toString() ??
                                'Gửi yêu cầu thất bại',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Gửi yêu cầu'),
                ),
            ],
          );
        },
      );
      return; // stay on login screen
    }

    // Handle MFA required
    if (res != null &&
        res['mfa_required'] == true &&
        res['temp_token'] is String) {
      final tempToken = res['temp_token'] as String;
      final otp = await _askOtp();
      if (otp == null || otp.isEmpty) return; // user cancelled
      setState(() {
        _loading = true;
      });
      final verify = await AuthService.loginMfaVerify(
        tempToken: tempToken,
        otp: otp,
      );
      setState(() {
        _loading = false;
      });
      if (verify == null || verify['error'] != null) {
        setState(() {
          _error = verify?['error']?.toString() ?? 'Xác thực MFA thất bại';
        });
        return;
      }
      if (!context.mounted) return;

      // MFA success
      if (widget.onLoginComplete != null) {
        widget.onLoginComplete!();
      } else {
        Navigator.of(context).pop(true);
      }
      return;
    }

    if (res == null || res['error'] != null) {
      setState(() {
        _error = res != null && res['error'] != null
            ? (res['error'] as String)
            : 'Đăng nhập thất bại';
      });
      return;
    }
    // on success, ensure widget still mounted before using context
    if (!context.mounted) return;

    // If we have a callback (from AuthWrapper), call it instead of popping
    if (widget.onLoginComplete != null) {
      widget.onLoginComplete!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<String?> _askOtp() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Nhập mã OTP',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '6 số trên ứng dụng Authenticator',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              style: const TextStyle(
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (ok == true) return controller.text.trim();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade700,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 24.0 : 48.0,
                vertical: 24.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Card(
                    elevation: 24,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // App Logo/Icon
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.health_and_safety,
                                size: 56,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'VietNam Healthy Life',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đăng nhập để tiếp tục',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email/Username Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email hoặc tên đầy đủ',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Bắt buộc' : null,
                              onSaved: (v) => _identifier = v ?? '',
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              obscureText: true,
                              validator: (v) => v == null || v.length < 6
                                  ? 'Mật khẩu >= 6 ký tự'
                                  : null,
                              onSaved: (v) => _password = v ?? '',
                            ),
                            const SizedBox(height: 24),

                            // Error Message
                            if (_error != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Đăng nhập',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'HOẶC',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Register Button
                            TextButton.icon(
                              onPressed: () async {
                                final navigator = Navigator.of(context);
                                final created = await navigator.push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const RegisterScreen(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: SlideTransition(
                                              position:
                                                  Tween<Offset>(
                                                    begin: const Offset(
                                                      1.0,
                                                      0.0,
                                                    ),
                                                    end: Offset.zero,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  ),
                                              child: child,
                                            ),
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 400,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                if (created == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Đăng ký thành công. Vui lòng đăng nhập.',
                                      ),
                                      backgroundColor: Colors.green.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text(
                                'Chưa có tài khoản? Đăng ký',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),

                            // Admin Login Button
                            TextButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const AdminLoginScreen(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.admin_panel_settings_outlined,
                              ),
                              label: const Text(
                                'Đăng nhập quản trị viên',
                                style: TextStyle(fontSize: 14),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
