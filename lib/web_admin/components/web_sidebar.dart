import 'package:flutter/material.dart';

class WebSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isCollapsed;

  const WebSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsed = false,
  });

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final width = widget.isCollapsed ? 70.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade50,
            Colors.green.shade50.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(2, 0),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            height: 65,
            padding: const EdgeInsets.symmetric(vertical: 16),
            // Không có decoration để bỏ nền xanh
            child: widget.isCollapsed
                ? Center(
                    child: Icon(
                      Icons.spa_rounded,
                      color: Colors.green,
                      size: 32,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.spa_rounded,
                        color: Colors.green,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Healthy Life',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  label: 'Tổng quan',
                  index: 0,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildDivider(),
                _buildSectionHeader('Quản lý hệ thống', widget.isCollapsed),
                _buildMenuItem(
                  context,
                  icon: Icons.people_rounded,
                  label: 'Người dùng',
                  index: 1,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Thực phẩm',
                  index: 2,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.dinner_dining_rounded,
                  label: 'Món ăn',
                  index: 3,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.local_drink_rounded,
                  label: 'Đồ uống',
                  index: 4,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.science_rounded,
                  label: 'Chất dinh dưỡng',
                  index: 5,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.health_and_safety_rounded,
                  label: 'Bệnh lý',
                  index: 6,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.medication_rounded,
                  label: 'Thuốc',
                  index: 7,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  label: 'Quản lý AI',
                  index: 8,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildDivider(),
                _buildSectionHeader('Hệ thống', widget.isCollapsed),
                _buildMenuItem(
                  context,
                  icon: Icons.support_agent_rounded,
                  label: 'Hỗ trợ chat',
                  index: 9,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.shield_rounded,
                  label: 'Phân quyền',
                  index: 10,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Cài đặt',
                  index: 11,
                  isCollapsed: widget.isCollapsed,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Nhật ký phê duyệt',
                  index: 12,
                  isCollapsed: widget.isCollapsed,
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.all(widget.isCollapsed ? 12 : 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: widget.isCollapsed
                ? const Icon(Icons.logout_rounded, color: Colors.red)
                : TextButton.icon(
                    onPressed: () {
                      // Handle logout
                    },
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Đăng xuất'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isCollapsed,
  }) {
    final isSelected = widget.selectedIndex == index;
    final isHovered = _hoveredIndex == index;
    final color = isSelected ? Colors.teal.shade700 : Colors.grey.shade700;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 4 : 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.teal.shade100.withValues(alpha: 0.5)
            : isHovered
                ? Colors.green.shade50
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onItemSelected(index),
          onHover: (hover) =>
              setState(() => _hoveredIndex = hover ? index : null),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: isCollapsed ? 0 : 12,
            ),
            child: isCollapsed
                ? Center(child: Icon(icon, color: color, size: 22))
                : Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
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

  Widget _buildSectionHeader(String title, bool isCollapsed) {
    if (isCollapsed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}
