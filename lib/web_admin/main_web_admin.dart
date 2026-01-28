import 'package:flutter/material.dart';
import 'pages/web_admin_main.dart';

void main() {
  runApp(const WebAdminApp());
}

class WebAdminApp extends StatelessWidget {
  const WebAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WebAdminMain(),
      debugShowCheckedModeBanner: false,
    );
  }
}
