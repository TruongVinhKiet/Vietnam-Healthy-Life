// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'admin_register_screen.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _password = '';
  String _confirm = '';
  int? _age;
  String? _gender;
  double? _heightCm;
  double? _weightKg;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_password != _confirm) {
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _error = l10n.passwordMismatch;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await AuthService.register(
      fullName: _fullName,
      email: _email,
      password: _password,
      age: _age,
      gender: _gender,
      heightCm: _heightCm,
      weightKg: _weightKg,
    );
    setState(() {
      _loading = false;
    });
    if (res == null || res['error'] != null) {
      setState(() {
        _error = res != null && res['error'] != null
            ? (res['error'] as String)
            : AppLocalizations.of(context)!.registrationFailed;
      });
      return;
    }
    // success: return true so caller (Login or Account) can refresh
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.green.shade400,
              Colors.green.shade700,
              Colors.teal.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      l10n.register,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24.0 : 48.0,
                      vertical: 16.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
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
                            padding: EdgeInsets.all(
                              isSmallScreen ? 24.0 : 32.0,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Icon
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.person_add,
                                        size: 48,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Full Name
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: l10n.fullName,
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (v) => v == null || v.isEmpty
                                        ? l10n.required
                                        : null,
                                    onSaved: (v) => _fullName = v ?? '',
                                  ),
                                  const SizedBox(height: 16),

                                  // Email
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) =>
                                        v == null || !v.contains('@')
                                        ? l10n.invalidEmail
                                        : null,
                                    onSaved: (v) => _email = v ?? '',
                                  ),
                                  const SizedBox(height: 16),

                                  // Age and Gender Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Tuổi',
                                            prefixIcon: const Icon(
                                              Icons.cake_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return l10n.required;
                                            final n = int.tryParse(v);
                                            if (n == null || n <= 0)
                                              return l10n.invalidAge;
                                            return null;
                                          },
                                          onSaved: (v) =>
                                              _age = int.tryParse(v ?? ''),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          decoration: InputDecoration(
                                            labelText: 'Giới tính',
                                            prefixIcon: const Icon(
                                              Icons.wc_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: 'male',
                                              child: Text(l10n.male),
                                            ),
                                            DropdownMenuItem(
                                              value: 'female',
                                              child: Text(l10n.female),
                                            ),
                                            DropdownMenuItem(
                                              value: 'other',
                                              child: Text(l10n.other),
                                            ),
                                          ],
                                          onChanged: (v) => _gender = v,
                                          validator: (v) => v == null
                                              ? l10n.selectGender
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Height and Weight Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Cao (cm)',
                                            prefixIcon: const Icon(
                                              Icons.height_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return l10n.required;
                                            final n = double.tryParse(v);
                                            if (n == null || n <= 0)
                                              return l10n.invalid;
                                            return null;
                                          },
                                          onSaved: (v) => _heightCm =
                                              double.tryParse(v ?? ''),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Nặng (kg)',
                                            prefixIcon: const Icon(
                                              Icons.monitor_weight_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                          ),
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty)
                                              return l10n.required;
                                            final n = double.tryParse(v);
                                            if (n == null || n <= 0)
                                              return l10n.invalid;
                                            return null;
                                          },
                                          onSaved: (v) => _weightKg =
                                              double.tryParse(v ?? ''),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Mật khẩu',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
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
                                  const SizedBox(height: 16),

                                  // Confirm Password
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Xác nhận mật khẩu',
                                      prefixIcon: const Icon(
                                        Icons.lock_open_outlined,
                                      ),
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
                                    onSaved: (v) => _confirm = v ?? '',
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

                                  // Register Button
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                              'Đăng ký',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Admin Register Link
                                  TextButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminRegisterScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.admin_panel_settings_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Đăng ký quản trị viên (cần mã cấp quyền)',
                                      style: TextStyle(fontSize: 13),
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
            ],
          ),
        ),
      ),
    );
  }
}
