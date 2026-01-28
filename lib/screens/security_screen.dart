// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _twoFaEnabled = false;
  int _lockThreshold = 5; // 5..10

  // 2FA setup state
  String? _otpauthUrl; // show as QR
  bool _verifying2fa = false;

  late final AnimationController _intro;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _intro,
            curve: const Interval(0.2, 0.85, curve: Curves.easeOutCubic),
          ),
        );
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final status = await AuthService.getTwoFactorStatus();
    setState(() {
      _twoFaEnabled = status != null && status['enabled'] == true;
      // if the backend returns lock_threshold, apply it; else keep default
      final t = status != null ? status['lock_threshold'] : null;
      if (t is num) _lockThreshold = t.clamp(3, 10).toInt();
      _loading = false;
    });
    if (mounted) _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final season = SeasonEffectNotifier.maybeOf(context);
    return SeasonEffect(
      currentDate: season?.selectedDate ?? DateTime.now(),
      enabled: season?.enabled ?? true,
      child: Container(
        color: FitnessAppTheme.background,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 180,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Row(
                          children: const [
                            Hero(
                              tag: 'heroSecurity',
                              child: Icon(Icons.lock_outline, size: 22),
                            ),
                            SizedBox(width: 8),
                            Text('Bảo mật'),
                          ],
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.teal, Colors.green],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Icon(
                                Icons.shield_rounded,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 120,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _twoFactorCard(),
                                const SizedBox(height: 16),
                                _passwordChangeCard(),
                                const SizedBox(height: 16),
                                _lockThresholdCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _twoFactorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(Colors.teal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            icon: Icons.phonelink_lock,
            color: Colors.teal,
            title: 'Xác thực hai lớp (2FA)',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _twoFaEnabled
                      ? 'Đã bật. Khi đăng nhập, cần nhập thêm mã 6 số từ Google Authenticator.'
                      : 'Tăng bảo mật bằng cách yêu cầu mã 6 số từ Google Authenticator khi đăng nhập.',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ),
              Switch(
                value: _twoFaEnabled,
                onChanged: (v) => v ? _startEnable2FA() : _startDisable2FA(),
              ),
            ],
          ),
          if (_otpauthUrl != null) ...[
            const Divider(height: 24),
            const Text(
              'Quét mã QR bằng Google Authenticator',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _otpauthUrl!,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _verifyOtpField(),
          ],
        ],
      ),
    );
  }

  Widget _verifyOtpField() {
    final controller = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhập 6 số từ ứng dụng Authenticator',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  letterSpacing: 8,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green.shade600,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hintText: '••••••',
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _verifying2fa
                  ? null
                  : () async {
                      setState(() => _verifying2fa = true);
                      final resp = await AuthService.verifyTwoFactor(
                        otp: controller.text.trim(),
                      );
                      setState(() => _verifying2fa = false);
                      final ok = resp != null && resp['error'] == null;
                      if (!context.mounted) return;
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Đã xác thực 2FA'
                                : (resp?['error']?.toString() ??
                                    'Lỗi xác thực'),
                          ),
                        ),
                      );
                      if (ok) {
                        setState(() {
                          _otpauthUrl = null;
                          _twoFaEnabled = true;
                        });
                      }
                    },
              child: _verifying2fa
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Xác nhận'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startEnable2FA() async {
    // ask password
    final pw = await _askPassword('Nhập mật khẩu để bật 2FA');
    if (pw == null || pw.isEmpty) return;
    final resp = await AuthService.enableTwoFactor(password: pw);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (resp == null || resp['error'] != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(resp?['error']?.toString() ?? 'Không bật được 2FA'),
        ),
      );
      setState(() => _twoFaEnabled = false);
      return;
    }
    setState(() {
      _otpauthUrl = resp['otpauth_url']?.toString();
    });
    // Show local notification
    await LocalNotificationService().notify2FAEnabled();
  }

  Future<void> _startDisable2FA() async {
    final pw = await _askPassword('Nhập mật khẩu để tắt 2FA');
    if (pw == null || pw.isEmpty) {
      setState(() => _twoFaEnabled = true);
      return;
    }
    final resp = await AuthService.disableTwoFactor(password: pw);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (resp == null || resp['error'] != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(resp?['error']?.toString() ?? 'Không tắt được 2FA'),
        ),
      );
      setState(() => _twoFaEnabled = true);
      return;
    }
    setState(() {
      _twoFaEnabled = false;
      _otpauthUrl = null;
    });
    // Show local notification
    await LocalNotificationService().notify2FADisabled();
  }

  Future<String?> _askPassword(String title) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mật khẩu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
    if (ok == true) return controller.text.trim();
    return null;
  }

  BoxDecoration _cardDeco(MaterialColor c) => BoxDecoration(
    color: FitnessAppTheme.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 10,
        offset: const Offset(0, 6),
      ),
    ],
    border: Border.all(color: c.shade100),
  );

  Widget _header({
    required IconData icon,
    required MaterialColor color,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.shade400, color.shade600]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _passwordChangeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(Colors.indigo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            icon: Icons.key_rounded,
            color: Colors.indigo,
            title: 'Đổi mật khẩu',
          ),
          const SizedBox(height: 12),
          Text(
            'Hệ thống sẽ gửi mã xác thực qua email. Nhập đúng mã để đặt mật khẩu mới.',
            style: TextStyle(color: Colors.grey[800]),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.email_outlined),
              label: const Text('Gửi mã qua email'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final resp = await AuthService.requestPasswordChangeCode();
                if (!context.mounted) return;
                if (resp == null || resp['error'] != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        resp?['error']?.toString() ?? 'Không gửi được mã',
                      ),
                    ),
                  );
                  return;
                }
                _openPasswordConfirmDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPasswordConfirmDialog() async {
    final codeCtrl = TextEditingController();
    final pass1 = TextEditingController();
    final pass2 = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Xác nhận đổi mật khẩu',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Mã xác thực',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  style: const TextStyle(
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pass1,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pass2,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nhập lại mật khẩu mới',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () async {
                if (pass1.text.trim() != pass2.text.trim()) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Mật khẩu nhập lại không khớp')),
                  );
                  return;
                }
                final messenger = ScaffoldMessenger.of(context);
                final resp = await AuthService.confirmPasswordChange(
                  code: codeCtrl.text.trim(),
                  newPassword: pass1.text.trim(),
                );
                if (resp == null || resp['error'] != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        resp?['error']?.toString() ?? 'Đổi mật khẩu thất bại',
                      ),
                    ),
                  );
                  return;
                }
                // Show local notification
                await LocalNotificationService().notifyPasswordChanged();
                
                messenger.showSnackBar(
                  const SnackBar(content: Text('Đã đổi mật khẩu')),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Widget _lockThresholdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(Colors.orange),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            icon: Icons.security_rounded,
            color: Colors.orange,
            title: 'Khóa tài khoản khi nhập sai nhiều lần',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _lockThreshold.toDouble(),
                  min: 3,
                  max: 10,
                  divisions: 7,
                  label: '$_lockThreshold lần',
                  onChanged: (v) => setState(() => _lockThreshold = v.round()),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Text(
                  '$_lockThreshold lần',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text('Lưu'),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final resp = await AuthService.updateSecuritySettings(
                  lockThreshold: _lockThreshold,
                );
                if (!context.mounted) return;
                if (resp == null || resp['error'] != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        resp?['error']?.toString() ??
                            'Không lưu được thiết lập bảo mật',
                      ),
                    ),
                  );
                  return;
                }
                messenger.showSnackBar(
                  const SnackBar(content: Text('Đã lưu thiết lập bảo mật')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
