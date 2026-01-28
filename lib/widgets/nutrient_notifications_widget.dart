import 'package:flutter/material.dart';
import 'package:my_diary/l10n/app_localizations.dart';
import '../fitness_app_theme.dart';
import '../services/nutrient_tracking_service.dart';

class NutrientNotificationsWidget extends StatefulWidget {
  const NutrientNotificationsWidget({super.key});

  @override
  createState() => _NutrientNotificationsWidgetState();
}

class _NutrientNotificationsWidgetState
    extends State<NutrientNotificationsWidget>
    with SingleTickerProviderStateMixin {
  List<dynamic> notifications = [];
  int unreadCount = 0;
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() => isLoading = true);

    try {
      final data = await NutrientTrackingService.getNotifications(limit: 50);
      setState(() {
        notifications = data['notifications'] ?? [];
        unreadCount = data['unread_count'] ?? 0;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.loadNotificationsError('$e')),
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final success = await NutrientTrackingService.markNotificationRead(
      notificationId,
    );
    if (success && mounted) {
      setState(() {
        notifications[index]['is_read'] = true;
        unreadCount = (unreadCount - 1).clamp(0, 999);
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await NutrientTrackingService.markAllNotificationsRead();
    if (success && mounted) {
      setState(() {
        for (var notif in notifications) {
          notif['is_read'] = true;
        }
        unreadCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.allMarkedAsRead);
            },
          ),
        ),
      );
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFE57373); // Red
      case 'warning':
        return const Color(0xFFFFA726); // Orange
      default:
        return const Color(0xFF64B5F6); // Blue
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      appBar: AppBar(
        backgroundColor: FitnessAppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: FitnessAppTheme.nearlyBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.nutritionalNotifications,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: FitnessAppTheme.nearlyBlack,
              ),
            ),
            if (unreadCount > 0)
              Text(
                AppLocalizations.of(context)!.unreadCount(unreadCount.toString()),
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 12,
                  color: FitnessAppTheme.grey.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all, color: FitnessAppTheme.nearlyBlue),
              onPressed: _markAllAsRead,
              tooltip: AppLocalizations.of(context)!.markAllAsRead,
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: FitnessAppTheme.nearlyBlue),
            onPressed: _loadNotifications,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FitnessAppTheme.nearlyBlue,
                ),
              ),
            )
          : notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: FitnessAppTheme.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotificationsShort,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontSize: 16,
              color: FitnessAppTheme.grey.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return FadeTransition(
      opacity: _animationController,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['is_read'] ?? false;
    final severity = notification['severity'] ?? 'info';
    final title = notification['title'] ?? AppLocalizations.of(context)!.notification;
    final message = notification['message'] ?? '';
    final createdAt = DateTime.parse(
      notification['created_at'] ?? DateTime.now().toIso8601String(),
    );
    final nutrientName = notification['nutrient_name'] ?? '';

    final delay = index * 100;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!isRead && notification['notification_id'] != null) {
                _markAsRead(notification['notification_id'], index);
              }
              _showNotificationDetail(notification);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isRead
                    ? FitnessAppTheme.white
                    : FitnessAppTheme.nearlyBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isRead
                      ? FitnessAppTheme.grey.withValues(alpha: 0.1)
                      : FitnessAppTheme.nearlyBlue.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getSeverityColor(severity).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Severity Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getSeverityColor(
                          severity,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getSeverityIcon(severity),
                        color: _getSeverityColor(severity),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: FitnessAppTheme.nearlyBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 13,
                              color: FitnessAppTheme.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (nutrientName.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.nearlyBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                nutrientName,
                                style: TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: FitnessAppTheme.nearlyBlue,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(createdAt),
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontSize: 11,
                              color: FitnessAppTheme.grey.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Unread indicator
                    if (!isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: FitnessAppTheme.nearlyBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    final metadata = notification['metadata'] ?? {};
    final percentage = metadata['percentage']?.toDouble() ?? 0.0;
    final currentAmount = metadata['current_amount']?.toDouble() ?? 0.0;
    final targetAmount = metadata['target_amount']?.toDouble() ?? 0.0;
    final unit = metadata['unit'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: FitnessAppTheme.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FitnessAppTheme.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                notification['title'] ?? AppLocalizations.of(context)!.notificationDetail,
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: FitnessAppTheme.nearlyBlack,
                ),
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                notification['message'] ?? '',
                style: TextStyle(
                  fontFamily: FitnessAppTheme.fontName,
                  fontSize: 15,
                  height: 1.5,
                  color: FitnessAppTheme.grey,
                ),
              ),
              if (metadata.isNotEmpty) ...[
                const SizedBox(height: 24),
                // Progress section
                _buildProgressSection(
                  percentage: percentage,
                  currentAmount: currentAmount,
                  targetAmount: targetAmount,
                  unit: unit,
                ),
              ],
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FitnessAppTheme.nearlyBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(l10n.cancel);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection({
    required double percentage,
    required double currentAmount,
    required double targetAmount,
    required String unit,
  }) {
    final progressColor = NutrientTrackingService.getProgressColor(percentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: progressColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.todayProgress,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: FitnessAppTheme.nearlyBlack,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: FitnessAppTheme.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 12),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.current,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: FitnessAppTheme.grey.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    NutrientTrackingService.formatAmount(currentAmount, unit),
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: FitnessAppTheme.nearlyBlack,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.target,
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontSize: 12,
                      color: FitnessAppTheme.grey.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    NutrientTrackingService.formatAmount(targetAmount, unit),
                    style: TextStyle(
                      fontFamily: FitnessAppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: FitnessAppTheme.nearlyBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (diff.inMinutes < 60) {
      return AppLocalizations.of(context)!.minutesAgo(diff.inMinutes.toString());
    } else if (diff.inHours < 24) {
      return AppLocalizations.of(context)!.hoursAgo(diff.inHours.toString());
    } else if (diff.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(diff.inDays.toString());
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
