// ignore_for_file: deprecated_member_use, use_build_context_synchronously, prefer_interpolation_to_compose_strings, curly_braces_in_flow_control_structures, use_super_parameters

import 'package:flutter/material.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/widgets/admin_chat_panel.dart';
import 'package:my_diary/widgets/profile_provider.dart';
import 'package:my_diary/screens/admin_users_screen.dart';
import 'package:my_diary/screens/admin_foods_screen.dart';
import 'package:my_diary/screens/admin_nutrients_screen.dart';
import 'package:my_diary/screens/admin_health_conditions_screen.dart';
import 'package:my_diary/screens/admin_settings_screen.dart';
import 'package:my_diary/screens/admin_role_management_screen.dart';
import 'package:my_diary/screens/admin_dishes_screen.dart';
import 'package:my_diary/screens/admin_drinks_screen.dart';
import 'package:my_diary/screens/admin_drugs_screen.dart';
import 'package:my_diary/screens/admin_ai_meals_screen.dart';
import 'package:my_diary/screens/admin_pending_queue_screen.dart';
import 'package:my_diary/screens/admin_approval_logs_screen.dart';
import '../widgets/role_protected_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../config/api_config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  Map<String, dynamic>? stats;
  bool isLoading = true;
  late AnimationController _animationController;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadStats();
    // Auto refresh every 30 seconds
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadStats(),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/dashboard/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
          isLoading = false;
        });
        _animationController.forward(from: 0);
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tải thống kê')),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: true,
            pinned: false,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                      color: Color.fromARGB(120, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.deepPurple.shade300,
                          Colors.deepPurple.shade600,
                          Colors.deepPurple.shade900,
                        ],
                      ),
                    ),
                  ),
                  // Animated particles effect
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParticlePainter(
                        animation: _animationController,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    right: -40,
                    child: Opacity(
                      opacity: 0.08,
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 250,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Làm mới',
                onPressed: () {
                  setState(() => isLoading = true);
                  _loadStats();
                },
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(
                        Icons.logout_rounded,
                        color: Colors.red.shade400,
                      ),
                      title: const Text('Đăng xuất'),
                      onTap: () async {
                        Navigator.pop(context); // Close popup
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Đăng xuất'),
                            content: const Text('Bạn có chắc muốn đăng xuất?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Đăng xuất'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Clear profile data before logout
                          final prov = context.maybeProfile();
                          if (prov != null) {
                            await prov.clearProfile();
                          }
                          await AuthService.logout();
                          if (mounted) {
                            // Pop back to login screen
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isLoading)
                  _buildSkeletonLoading()
                else ...[
                  // Welcome Card
                  _buildWelcomeCard(),
                  const SizedBox(height: 32),

                  // Statistics Section
                  if (stats != null) ...[
                    _buildSectionHeader(
                      'Thống kê tổng quan',
                      Icons.bar_chart_rounded,
                      Colors.deepPurple,
                    ),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 40),
                  ],

                  // Management Section
                  _buildSectionHeader(
                    'Quản lý hệ thống',
                    Icons.settings_rounded,
                    Colors.deepOrange,
                  ),
                  const SizedBox(height: 20),
                  _buildManagementGrid(),
                  const SizedBox(height: 40),

                  // User Support Chat
                  _buildSectionHeader(
                    'Hỗ trợ người dùng',
                    Icons.support_agent_rounded,
                    Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 600, child: const AdminChatPanel()),
                  const SizedBox(height: 20),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _animationController.value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED), Color(0xFF6D28D9)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8B5CF6).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.rotate(angle: value * 0.3, child: child);
                },
                child: Text('??', style: TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Xin chào, Admin!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chào mừng trở lại với bảng điều khiển quản trị',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.65,
      children: [
        _buildStatCard(
          'Tổng người dùng',
          '${stats!['total_users'] ?? 0}',
          Icons.people_rounded,
          Colors.blue,
        ),
        _buildStatCard(
          'Thực phẩm',
          '${stats!['total_foods'] ?? 0}',
          Icons.restaurant_rounded,
          Colors.green,
        ),
        _buildStatCard(
          'Món ăn',
          '${stats!['total_dishes'] ?? 0}',
          Icons.dinner_dining_rounded,
          Colors.teal,
        ),
        _buildStatCard(
          'Đồ uống',
          '${stats!['total_drinks'] ?? 0}',
          Icons.local_drink_rounded,
          Colors.cyan,
        ),
        _buildStatCard(
          'Chất dinh dưỡng',
          '${stats!['total_nutrients'] ?? 0}',
          Icons.science_rounded,
          Colors.orange,
        ),
        _buildStatCard(
          'Bữa ăn hôm nay',
          '${stats!['today_meals'] ?? 0}',
          Icons.fastfood_rounded,
          Colors.purple,
        ),
        _buildStatCard(
          'Hoạt động (7 ngày)',
          '${stats!['active_users_7days'] ?? 0}',
          Icons.trending_up_rounded,
          Colors.deepPurple,
        ),
        _buildStatCard(
          'Đăng ký mới',
          '${stats!['new_users_this_month'] ?? 0}',
          Icons.person_add_rounded,
          Colors.pink,
        ),
        _buildStatCard(
          'Món được ghi nhận',
          '${stats!['dish_logs'] ?? 0}',
          Icons.analytics_rounded,
          Colors.indigo,
        ),
        _buildStatCard(
          'Bệnh lý trong hệ thống',
          '${stats!['total_health_conditions'] ?? 0}',
          Icons.favorite_rounded,
          Colors.red,
        ),
        _buildStatCard(
          'Thuốc có sẵn',
          '${stats!['total_drugs'] ?? 0}',
          Icons.medication_rounded,
          Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return _StatCard(
      title: title,
      value: value,
      icon: icon,
      color: color,
      animation: _animationController,
    );
  }

  Widget _buildManagementGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _buildManagementCard(
          'Quản lý người dùng',
          'Xem, chỉnh sửa và quản lý người dùng',
          Icons.people_rounded,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['user_manager', 'analyst', 'support'],
                child: AdminUsersScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          '🛡️ Quản lý phân quyền',
          'Gán roles và permissions cho admin',
          Icons.shield_rounded,
          Colors.red,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['super_admin'],
                child: AdminRoleManagementScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý thực phẩm',
          'Thêm, sửa thực phẩm và dinh dưỡng',
          Icons.restaurant_menu_rounded,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminFoodsScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý món ăn',
          'Quản lý món ăn mẫu và người dùng tạo',
          Icons.dinner_dining_rounded,
          Colors.teal,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminDishesScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Chờ duyệt',
          'Danh sách món/đồ uống chờ duyệt',
          Icons.pending_actions_rounded,
          Colors.deepOrange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminPendingQueueScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Audit log',
          'Nhật ký admin phê duyệt',
          Icons.receipt_long_rounded,
          Colors.indigo,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminApprovalLogsScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý đồ uống',
          'Thiết lập menu nước uống và template',
          Icons.local_drink_rounded,
          Colors.cyan,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminDrinksScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý chất dinh dưỡng',
          'Xem danh sách và thống kê',
          Icons.science_rounded,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminNutrientsScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý bệnh lý',
          'Quản lý bệnh và khuyến nghị dinh dưỡng',
          Icons.health_and_safety_rounded,
          Colors.red,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminHealthConditionsScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý thuốc',
          'Thêm, sửa thuốc và tác dụng phụ',
          Icons.medication_rounded,
          Colors.deepOrange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminDrugsScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Quản lý AI',
          'Xem và duyệt các món được AI phân tích',
          Icons.auto_awesome_rounded,
          Colors.indigo,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['content_manager', 'analyst'],
                child: AdminAiMealsScreen(),
              ),
            ),
          ),
        ),
        _buildManagementCard(
          'Tùy biến ứng dụng',
          'Cài đặt giao diện và tính năng',
          Icons.settings_applications_rounded,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RoleProtectedScreen(
                requiredRoles: ['analyst', 'user_manager', 'content_manager'],
                child: AdminSettingsScreen(),
              ),
            ),
          ),
        ),
        // Coming Soon Card
        _buildComingSoonCard(
          'Tính năng mới',
          'Nhiều tính năng mới đang được phát triển',
          Icons.auto_awesome_rounded,
          Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildComingSoonCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade100, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        children: [
          // Diagonal stripes pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _DiagonalStripesPainter(
                color: color.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: color.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'COMING SOON',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return _ManagementCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      onTap: onTap,
    );
  }

  // ignore: unused_element
  Widget _buildQuickActions() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _buildQuickActionChip(
          'Thêm thực phẩm',
          Icons.add_circle_outline_rounded,
          Colors.green,
          false, // Not coming soon - has functionality
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RoleProtectedScreen(
                  requiredRoles: ['content_manager', 'analyst'],
                  child: AdminFoodsScreen(),
                ),
              ),
            );
          },
        ),
        _buildQuickActionChip(
          'Làm mới dữ liệu',
          Icons.refresh_rounded,
          Colors.blue,
          false,
          () {
            setState(() => isLoading = true);
            _loadStats();
          },
        ),
        _buildQuickActionChip(
          'Xem người dùng',
          Icons.people_alt_rounded,
          Colors.purple,
          false,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RoleProtectedScreen(
                  requiredRoles: ['user_manager', 'analyst', 'support'],
                  child: AdminUsersScreen(),
                ),
              ),
            );
          },
        ),
        _buildQuickActionChip(
          'Cài đặt',
          Icons.settings_rounded,
          Colors.teal,
          false,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RoleProtectedScreen(
                  requiredRoles: ['analyst', 'user_manager', 'content_manager'],
                  child: AdminSettingsScreen(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
    String label,
    IconData icon,
    Color color,
    bool isComingSoon,
    VoidCallback onTap,
  ) {
    return _QuickActionChip(
      label: label,
      icon: icon,
      color: color,
      isComingSoon: isComingSoon,
      onTap: onTap,
    );
  }

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBox(height: 100, width: double.infinity),
          const SizedBox(height: 32),
          _buildSkeletonBox(height: 30, width: 200),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.4,
            children: List.generate(
              6,
              (index) => _buildSkeletonBox(height: 120, width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: -1.0, end: 2.0),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: [
                    (value - 0.3).clamp(0.0, 1.0),
                    value.clamp(0.0, 1.0),
                    (value + 0.3).clamp(0.0, 1.0),
                  ],
                ),
              ),
            );
          },
          onEnd: () {
            if (mounted && isLoading) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Animation<double> animation;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.animation,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Opacity(opacity: widget.animation.value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withValues(alpha: 0.2),
                        widget.color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 18, color: widget.color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                widget.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Management Card Widget
class _ManagementCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ManagementCard> createState() => _ManagementCardState();
}

class _ManagementCardState extends State<_ManagementCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, widget.color.withValues(alpha: 0.08)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.color.withValues(alpha: _isHovered ? 0.4 : 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _isHovered ? 0.25 : 0.12),
              blurRadius: _isHovered ? 16 : 10,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withValues(alpha: 0.2),
                          widget.color.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, size: 22, color: widget.color),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'M?',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..translate(_isHovered ? 4.0 : 0.0, 0.0),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Quick Action Chip Widget
class _QuickActionChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isComingSoon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.color,
    this.isComingSoon = false,
    required this.onTap,
  });

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.05 : 1.0)
          ..translate(0.0, _isHovered ? -2.0 : 0.0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withValues(alpha: _isHovered ? 0.2 : 0.12),
                  widget.color.withValues(alpha: _isHovered ? 0.15 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.color.withValues(alpha: _isHovered ? 0.5 : 0.3),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 22, color: widget.color),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                // Coming Soon Badge
                if (widget.isComingSoon)
                  Positioned(
                    top: -10,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade400,
                            Colors.orange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Painter for animated particles
class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  _ParticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final dx = (i * 50.0 + animation.value * 100) % size.width;
      final dy = (i * 30.0 + animation.value * 80) % size.height;
      final radius = 2.0 + (i % 3);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

// Custom Painter for diagonal stripes
class _DiagonalStripesPainter extends CustomPainter {
  final Color color;

  _DiagonalStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DiagonalStripesPainter oldDelegate) => false;
}
