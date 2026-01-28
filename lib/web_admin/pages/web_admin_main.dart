import 'package:flutter/material.dart';
import '../components/web_sidebar.dart';
import '../components/web_topbar.dart';
import 'web_admin_dashboard.dart';
import 'web_admin_users.dart';
import 'web_admin_foods.dart';
import 'web_admin_dishes.dart';
import 'web_admin_drinks.dart';
import 'web_admin_nutrients.dart';
import 'web_admin_health_conditions.dart';
import 'web_admin_drugs.dart';
import 'web_admin_ai_meals.dart';
import 'web_admin_chat.dart';
import 'web_admin_roles.dart';
import 'web_admin_settings.dart';
import 'web_admin_approval_logs.dart';

class WebAdminMain extends StatefulWidget {
  const WebAdminMain({super.key});

  @override
  State<WebAdminMain> createState() => _WebAdminMainState();
}

class _WebAdminMainState extends State<WebAdminMain> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  final List<String> _pageTitles = [
    'Tổng quan',
    'Quản lý người dùng',
    'Quản lý thực phẩm',
    'Quản lý món ăn',
    'Quản lý đồ uống',
    'Quản lý chất dinh dưỡng',
    'Quản lý bệnh lý',
    'Quản lý thuốc',
    'Quản lý AI',
    'Hỗ trợ chat',
    'Quản lý phân quyền',
    'Cài đặt',
    'Nhật ký phê duyệt',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade50.withValues(alpha: 0.3),
              Colors.green.shade50.withValues(alpha: 0.2),
              Colors.white,
            ],
          ),
        ),
        child: Row(
          children: [
            // Sidebar
            WebSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              isCollapsed: _sidebarCollapsed,
            ),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Topbar
                  WebTopbar(
                    title: _pageTitles[_selectedIndex],
                    leading: IconButton(
                      icon: Icon(
                        _sidebarCollapsed ? Icons.menu : Icons.menu_open,
                      ),
                      onPressed: () {
                        setState(() {
                          _sidebarCollapsed = !_sidebarCollapsed;
                        });
                      },
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _buildPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const WebAdminDashboard();
      case 1:
        return const WebAdminUsers();
      case 2:
        return const WebAdminFoods();
      case 3:
        return const WebAdminDishes();
      case 4:
        return const WebAdminDrinks();
      case 5:
        return const WebAdminNutrients();
      case 6:
        return const WebAdminHealthConditions();
      case 7:
        return const WebAdminDrugs();
      case 8:
        return const WebAdminAiMeals();
      case 9:
        return const WebAdminChat();
      case 10:
        return const WebAdminRoles();
      case 11:
        return const WebAdminSettings();
      case 12:
        return const WebAdminApprovalLogs();
      default:
        return const WebAdminDashboard();
    }
  }
}
