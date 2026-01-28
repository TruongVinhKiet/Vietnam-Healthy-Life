import 'package:flutter/material.dart';
import 'package:my_diary/fitness_app_theme.dart';
import 'package:my_diary/services/auth_service.dart';
import 'package:my_diary/services/local_notification_service.dart';
import 'package:my_diary/widgets/season_effect.dart';
import 'package:my_diary/widgets/season_effect_provider.dart';
import 'package:my_diary/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

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

    // Load both backend notifications and local notifications
    final backendData = await AuthService.getNotifications();
    final localNotifications = await LocalNotificationService()
        .getNotificationHistory();

    // Combine and merge notifications
    final List<Map<String, dynamic>> allNotifications = [];

    // Add backend notifications
    if (backendData != null) {
      for (var item in backendData) {
        allNotifications.add({
          'type': item['type']?.toString() ?? 'info',
          'message': item['message']?.toString() ?? '—',
          'at': item['at']?.toString(),
          'source': 'backend',
          'title': item['message']?.toString() ?? '—',
          'body': item['detail']?.toString(),
        });
      }
    }

    // Add local notifications
    for (var localNotif in localNotifications) {
      allNotifications.add({
        'type': localNotif['type']?.toString() ?? 'info',
        'message':
            '${localNotif['title']?.toString() ?? ''}\n${localNotif['body']?.toString() ?? ''}',
        'at': localNotif['created_at']?.toString(),
        'source': 'local',
        'title': localNotif['title']?.toString(),
        'body': localNotif['body']?.toString(),
      });
    }

    // Sort by time (newest first)
    allNotifications.sort((a, b) {
      final aTime = a['at']?.toString();
      final bTime = b['at']?.toString();
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      try {
        final aDate = DateTime.parse(aTime);
        final bDate = DateTime.parse(bTime);
        return bDate.compareTo(aDate);
      } catch (_) {
        return 0;
      }
    });

    setState(() {
      _items = allNotifications;
      _loading = false;
    });

    // Mark as seen now so the badge on the bell can clear
    await AuthService.markNotificationsSeenNow();
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
                          children: [
                            const Hero(
                              tag: 'heroNotifications',
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.notifications),
                          ],
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.indigo.shade500,
                                Colors.blue.shade600,
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Icon(
                                Icons.notifications_active,
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
                              children: (_items.isEmpty
                                  ? _emptyView()
                                  : _list()),
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

  List<Widget> _list() {
    return _items
        .map(
          (e) => _notificationTile(
            type: e['type']?.toString() ?? 'info',
            message: e['message']?.toString() ?? '—',
            at: e['at']?.toString(),
            title: e['title']?.toString(),
            body: e['body']?.toString(),
            source: e['source']?.toString() ?? 'backend',
          ),
        )
        .toList();
  }

  List<Widget> _emptyView() {
    return [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.noNotifications,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _notificationTile({
    required String type,
    required String message,
    String? at,
    String? title,
    String? body,
    String? source,
  }) {
    final iconColor = _colorForType(type);
    final iconData = _iconForType(type);

    // Use title and body if available (from local notifications), otherwise use message
    final displayTitle =
        title ?? (message.contains('\n') ? message.split('\n')[0] : message);
    final displayBody =
        body ??
        (message.contains('\n')
            ? message.split('\n').skip(1).join('\n')
            : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FitnessAppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [iconColor.withValues(alpha: 0.6), iconColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (displayBody != null && displayBody.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    displayBody,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _friendlyTime(at),
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    if (source == 'local') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Local',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.tryParse(iso)?.toLocal();
      if (dt == null) return '—';
      final l10n = AppLocalizations.of(context)!;
      final date =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$date ${l10n.at} $time';
    } catch (_) {
      return iso;
    }
  }

  MaterialColor _colorForType(String type) {
    switch (type) {
      case 'metrics_updated':
        return Colors.green;
      case 'account_unblocked':
      case 'account_status':
        return Colors.orange;
      case 'last_login':
        return Colors.blue;
      case 'dish_created':
      case 'drink_created':
        return Colors.purple;
      case 'dish_approved':
      case 'drink_approved':
        return Colors.green;
      case 'meal_added':
        return Colors.orange;
      case 'water_added':
        return Colors.blue;
      case 'chat_message':
        return Colors.indigo;
      case 'meal_time':
        return Colors.amber;
      case 'medication_time':
        return Colors.red;
      case 'personal_info_changed':
        return Colors.teal;
      case 'security':
        return Colors.deepOrange;
      case 'nutrition_accepted':
        return Colors.green;
      case 'progress_completed':
        return Colors.lightGreen;
      default:
        return Colors.indigo;
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'metrics_updated':
        return Icons.monitor_heart_rounded;
      case 'account_unblocked':
      case 'account_status':
        return Icons.lock_open_rounded;
      case 'last_login':
        return Icons.login_rounded;
      case 'dish_created':
        return Icons.restaurant_rounded;
      case 'drink_created':
        return Icons.local_drink_rounded;
      case 'dish_approved':
      case 'drink_approved':
        return Icons.check_circle_rounded;
      case 'meal_added':
        return Icons.fastfood_rounded;
      case 'water_added':
        return Icons.water_drop_rounded;
      case 'chat_message':
        return Icons.chat_bubble_rounded;
      case 'meal_time':
        return Icons.access_time_rounded;
      case 'medication_time':
        return Icons.medication_rounded;
      case 'personal_info_changed':
        return Icons.person_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'nutrition_accepted':
        return Icons.check_circle_rounded;
      case 'progress_completed':
        return Icons.emoji_events_rounded;
      default:
        return Icons.notifications;
    }
  }
}
