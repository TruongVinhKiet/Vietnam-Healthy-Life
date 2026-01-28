// This file is deprecated. Use pages/web_admin_dashboard.dart instead.
import 'package:flutter/material.dart';

@Deprecated('Use pages/web_admin_dashboard.dart instead')
class WebAdminDashboard extends StatelessWidget {
  const WebAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Admin Dashboard'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Web Admin Dashboard!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
