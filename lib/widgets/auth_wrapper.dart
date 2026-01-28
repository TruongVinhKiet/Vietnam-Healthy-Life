import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'profile_provider.dart';

/// AuthWrapper checks if user is logged in before showing the main app
class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getUserRole();

    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _isLoading = false;
    });

    // If logged in as admin, redirect to admin dashboard
    if (_isLoggedIn && role == 'admin') {
      // Admin should not use main app, clear profile and redirect to admin login
      final prov = context.maybeProfile();
      if (prov != null) {
        await prov.clearProfile();
      }
      await AuthService.logout();

      if (!mounted) return;
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  Future<void> _refreshAuth() async {
    await _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return LoginScreen(onLoginComplete: _refreshAuth);
    }

    return widget.child;
  }
}
