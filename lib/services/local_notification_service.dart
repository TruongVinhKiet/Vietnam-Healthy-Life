import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service quản lý tất cả các thông báo local trên máy
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  
  // Track completed goals for today to avoid duplicate notifications
  final Set<String> _completedGoalsToday = {};
  String? _lastResetDate;
  
  // Store notification history for display in notifications screen
  static const String _notificationsHistoryKey = 'local_notifications_history';
  static const int _maxHistorySize = 100; // Keep last 100 notifications

  /// Khởi tạo service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    } catch (e) {
      debugPrint('Error setting timezone: $e');
    }
    
    // Reset completed goals tracking daily
    _resetCompletedGoalsIfNeeded();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Có thể xử lý navigation ở đây nếu cần
  }
  
  /// Get notification type from payload
  String _getTypeFromPayload(String? payload) {
    if (payload == null) return 'info';
    
    if (payload.contains('dish_created')) return 'dish_created';
    if (payload.contains('drink_created')) return 'drink_created';
    if (payload.contains('meal_added')) return 'meal_added';
    if (payload.contains('water_added')) return 'water_added';
    if (payload.contains('admin_message') || payload.contains('community_message') || payload.contains('friend_message')) return 'chat_message';
    if (payload.contains('meal_time')) return 'meal_time';
    if (payload.contains('medication_time')) return 'medication_time';
    if (payload.contains('personal_info_changed')) return 'personal_info_changed';
    if (payload.contains('2fa') || payload.contains('password_changed') || payload.contains('security')) return 'security';
    if (payload.contains('account_locked') || payload.contains('account_unlocked')) return 'account_status';
    if (payload.contains('nutrition_accepted')) return 'nutrition_accepted';
    if (payload.contains('mediterranean_diet_completed') || payload.contains('water_goal_completed') || payload.contains('nutrient_goal_completed')) return 'progress_completed';
    
    return 'info';
  }
  
  /// Reset completed goals tracking if it's a new day
  void _resetCompletedGoalsIfNeeded() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastResetDate != today) {
      _completedGoalsToday.clear();
      _lastResetDate = today;
    }
  }
  
  /// Check if goal was already completed today
  bool _isGoalCompletedToday(String goalKey) {
    _resetCompletedGoalsIfNeeded();
    return _completedGoalsToday.contains(goalKey);
  }
  
  /// Mark goal as completed today
  void _markGoalCompletedToday(String goalKey) {
    _resetCompletedGoalsIfNeeded();
    _completedGoalsToday.add(goalKey);
  }

  /// Lưu thông báo vào lịch sử
  Future<void> _saveNotificationToHistory({
    required String title,
    required String body,
    required String type,
    String? payload,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_notificationsHistoryKey);
      List<Map<String, dynamic>> history = [];
      
      if (historyJson != null) {
        final decoded = json.decode(historyJson);
        if (decoded is List) {
          history = List<Map<String, dynamic>>.from(
            decoded.map((e) => Map<String, dynamic>.from(e)),
          );
        }
      }
      
      // Add new notification at the beginning
      history.insert(0, {
        'title': title,
        'body': body,
        'type': type,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Keep only last N notifications
      if (history.length > _maxHistorySize) {
        history = history.sublist(0, _maxHistorySize);
      }
      
      await prefs.setString(_notificationsHistoryKey, json.encode(history));
    } catch (e) {
      debugPrint('Error saving notification to history: $e');
    }
  }
  
  /// Lấy lịch sử thông báo
  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_notificationsHistoryKey);
      
      if (historyJson == null) return [];
      
      final decoded = json.decode(historyJson);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(
          decoded.map((e) => Map<String, dynamic>.from(e)),
        );
      }
      
      return [];
    } catch (e) {
      debugPrint('Error loading notification history: $e');
      return [];
    }
  }
  
  /// Xóa lịch sử thông báo
  Future<void> clearNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsHistoryKey);
    } catch (e) {
      debugPrint('Error clearing notification history: $e');
    }
  }

  /// Hiển thị thông báo ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? type,
  }) async {
    if (!_initialized) await initialize();
    
    // Determine notification type from payload if not provided
    final notificationType = type ?? _getTypeFromPayload(payload);

    // Save to history
    await _saveNotificationToHistory(
      title: title,
      body: body,
      type: notificationType,
      payload: payload,
    );

    const androidDetails = AndroidNotificationDetails(
      'vietnam_healthy_life_channel',
      'VietNam Healthy Life Notifications',
      channelDescription: 'Thông báo từ ứng dụng VietNam Healthy Life',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Lên lịch thông báo theo thời gian cụ thể
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'vietnam_healthy_life_channel',
      'My Diary Notifications',
      channelDescription: 'Thông báo từ ứng dụng My Diary',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Lên lịch thông báo lặp lại hàng ngày
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Nếu thời gian đã qua trong ngày hôm nay, lên lịch cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'vietnam_healthy_life_channel',
      'My Diary Notifications',
      channelDescription: 'Thông báo từ ứng dụng My Diary',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Hủy thông báo
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // ============================================================
  // CÁC PHƯƠNG THỨC THÔNG BÁO CỤ THỂ
  // ============================================================

  /// Thông báo khi tạo món ăn mới
  Future<void> notifyDishCreated(String dishName) async {
    await showNotification(
      id: 1001,
      title: 'Món ăn đã được tạo thành công! 🍽️',
      body: 'Món "$dishName" của bạn đã được tạo thành công và đang chờ phê duyệt.',
      payload: 'dish_created',
      type: 'dish_created',
    );
  }

  /// Thông báo khi tạo đồ uống mới
  Future<void> notifyDrinkCreated(String drinkName) async {
    await showNotification(
      id: 1002,
      title: 'Đồ uống đã được tạo thành công! 🥤',
      body: 'Đồ uống "$drinkName" của bạn đã được tạo thành công và đang chờ phê duyệt.',
      payload: 'drink_created',
      type: 'drink_created',
    );
  }

  /// Thông báo khi thêm meal
  Future<void> notifyMealAdded(String mealType, String foodName) async {
    final mealTypeNames = {
      'breakfast': 'Bữa sáng',
      'lunch': 'Bữa trưa',
      'snack': 'Bữa xế',
      'dinner': 'Bữa tối',
    };
    final mealTypeName = mealTypeNames[mealType.toLowerCase()] ?? mealType;

    await showNotification(
      id: 2001,
      title: 'Đã thêm vào $mealTypeName! ✅',
      body: 'Bạn đã thêm "$foodName" vào $mealTypeName của mình.',
      payload: 'meal_added',
      type: 'meal_added',
    );
  }

  /// Thông báo khi thêm water
  Future<void> notifyWaterAdded(double amountMl, String? drinkName) async {
    final safeDrinkName = (drinkName == null || drinkName.trim().isEmpty)
        ? 'nước'
        : drinkName.trim();
    final drinkText = ' ($safeDrinkName)';
    await showNotification(
      id: 2002,
      title: 'Đã ghi nhận nước! 💧',
      body: 'Bạn đã uống ${amountMl.toStringAsFixed(0)}ml$drinkText.',
      payload: 'water_added',
      type: 'water_added',
    );
  }

  /// Thông báo tin nhắn mới từ admin
  Future<void> notifyNewAdminMessage(String messagePreview) async {
    await showNotification(
      id: 3001,
      title: 'Tin nhắn mới từ Admin 👨‍💼',
      body: messagePreview.length > 50
          ? '${messagePreview.substring(0, 50)}...'
          : messagePreview,
      payload: 'admin_message',
      type: 'chat_message',
    );
  }

  /// Thông báo tin nhắn mới từ cộng đồng
  Future<void> notifyNewCommunityMessage(String senderName, String messagePreview) async {
    await showNotification(
      id: 3002,
      title: 'Tin nhắn mới từ $senderName 👥',
      body: messagePreview.length > 50
          ? '${messagePreview.substring(0, 50)}...'
          : messagePreview,
      payload: 'community_message',
      type: 'chat_message',
    );
  }

  /// Thông báo tin nhắn mới từ bạn bè
  Future<void> notifyNewFriendMessage(String friendName, String messagePreview) async {
    await showNotification(
      id: 3003,
      title: 'Tin nhắn mới từ $friendName 👤',
      body: messagePreview.length > 50
          ? '${messagePreview.substring(0, 50)}...'
          : messagePreview,
      payload: 'friend_message',
      type: 'chat_message',
    );
  }

  /// Thông báo giờ ăn sáng
  Future<void> scheduleBreakfastNotification(TimeOfDay time) async {
    await scheduleDailyNotification(
      id: 4001,
      title: 'Đến giờ ăn sáng! 🌅',
      body: 'Đã đến giờ ăn sáng của bạn. Hãy bổ sung năng lượng cho ngày mới!',
      time: time,
      payload: 'meal_time_breakfast',
    );
  }

  /// Thông báo giờ ăn trưa
  Future<void> scheduleLunchNotification(TimeOfDay time) async {
    await scheduleDailyNotification(
      id: 4002,
      title: 'Đến giờ ăn trưa! 🍽️',
      body: 'Đã đến giờ ăn trưa của bạn. Hãy bổ sung dinh dưỡng cho buổi chiều!',
      time: time,
      payload: 'meal_time_lunch',
    );
  }

  /// Thông báo giờ ăn xế
  Future<void> scheduleSnackNotification(TimeOfDay time) async {
    await scheduleDailyNotification(
      id: 4003,
      title: 'Đến giờ ăn xế! 🍰',
      body: 'Đã đến giờ ăn xế của bạn. Hãy bổ sung năng lượng nhẹ!',
      time: time,
      payload: 'meal_time_snack',
    );
  }

  /// Thông báo giờ ăn tối
  Future<void> scheduleDinnerNotification(TimeOfDay time) async {
    await scheduleDailyNotification(
      id: 4004,
      title: 'Đến giờ ăn tối! 🌙',
      body: 'Đã đến giờ ăn tối của bạn. Hãy bổ sung dinh dưỡng cho buổi tối!',
      time: time,
      payload: 'meal_time_dinner',
    );
  }

  /// Thông báo giờ uống thuốc
  Future<void> scheduleMedicationNotification({
    required int medicationId,
    required TimeOfDay time,
    required String medicationName,
    required String period, // "Buổi sáng", "Buổi trưa", "Buổi tối"
  }) async {
    await scheduleDailyNotification(
      id: 5000 + medicationId, // Unique ID cho mỗi loại thuốc
      title: 'Đến giờ uống thuốc! 💊',
      body: '$period: Đã đến giờ uống "$medicationName".',
      time: time,
      payload: 'medication_time',
    );
  }

  /// Thông báo khi thay đổi thông tin cá nhân
  Future<void> notifyPersonalInfoChanged() async {
    await showNotification(
      id: 6001,
      title: 'Thông tin đã được cập nhật! ✅',
      body: 'Thông tin cá nhân của bạn đã được cập nhật thành công.',
      payload: 'personal_info_changed',
      type: 'personal_info_changed',
    );
  }

  /// Thông báo khi bật 2FA
  Future<void> notify2FAEnabled() async {
    await showNotification(
      id: 7001,
      title: 'Xác thực hai lớp đã được bật! 🔒',
      body: 'Tài khoản của bạn đã được bảo vệ bằng xác thực hai lớp (2FA).',
      payload: '2fa_enabled',
      type: 'security',
    );
  }

  /// Thông báo khi tắt 2FA
  Future<void> notify2FADisabled() async {
    await showNotification(
      id: 7002,
      title: 'Xác thực hai lớp đã được tắt! 🔓',
      body: 'Xác thực hai lớp (2FA) đã được tắt cho tài khoản của bạn.',
      payload: '2fa_disabled',
      type: 'security',
    );
  }

  /// Thông báo khi đổi mật khẩu
  Future<void> notifyPasswordChanged() async {
    await showNotification(
      id: 7003,
      title: 'Mật khẩu đã được đổi! 🔑',
      body: 'Mật khẩu của bạn đã được thay đổi thành công.',
      payload: 'password_changed',
      type: 'security',
    );
  }

  /// Thông báo khi tài khoản bị khóa do nhập sai mật khẩu nhiều lần
  Future<void> notifyAccountLocked(int attempts, int threshold) async {
    await showNotification(
      id: 7004,
      title: 'Tài khoản đã bị khóa! ⚠️',
      body: 'Tài khoản của bạn đã bị khóa do nhập sai mật khẩu $attempts lần (ngưỡng: $threshold lần).',
      payload: 'account_locked',
      type: 'account_status',
    );
  }

  /// Thông báo khi tài khoản được mở khóa
  Future<void> notifyAccountUnlocked() async {
    await showNotification(
      id: 7005,
      title: 'Tài khoản đã được mở khóa! ✅',
      body: 'Tài khoản của bạn đã được mở khóa thành công.',
      payload: 'account_unlocked',
      type: 'account_status',
    );
  }

  /// Thông báo khi admin khóa tài khoản
  Future<void> notifyAccountLockedByAdmin(String reason) async {
    await showNotification(
      id: 7006,
      title: 'Tài khoản đã bị khóa bởi Admin! 🚫',
      body: 'Tài khoản của bạn đã bị khóa bởi quản trị viên. Lý do: $reason',
      payload: 'account_locked_by_admin',
      type: 'account_status',
    );
  }

  /// Thông báo khi admin mở khóa tài khoản
  Future<void> notifyAccountUnlockedByAdmin() async {
    await showNotification(
      id: 7007,
      title: 'Tài khoản đã được mở khóa bởi Admin! ✅',
      body: 'Tài khoản của bạn đã được mở khóa bởi quản trị viên.',
      payload: 'account_unlocked_by_admin',
      type: 'account_status',
    );
  }

  /// Thông báo khi chấp nhận bảng dinh dưỡng từ chatbot
  Future<void> notifyNutritionAcceptedFromChat(String foodName) async {
    await showNotification(
      id: 8001,
      title: 'Đã chấp nhận bảng dinh dưỡng! ✅',
      body: 'Bảng dinh dưỡng của "$foodName" đã được chấp nhận và lưu vào hệ thống.',
      payload: 'nutrition_accepted_chat',
      type: 'nutrition_accepted',
    );
  }

  /// Thông báo khi chấp nhận bảng dinh dưỡng từ AI image analysis
  Future<void> notifyNutritionAcceptedFromAI(String foodName) async {
    await showNotification(
      id: 8002,
      title: 'Đã chấp nhận phân tích AI! ✅',
      body: 'Phân tích dinh dưỡng của "$foodName" đã được chấp nhận và lưu vào hệ thống.',
      payload: 'nutrition_accepted_ai',
      type: 'nutrition_accepted',
    );
  }

  /// Thông báo khi hoàn thành Mediterranean diet progress
  Future<void> notifyMediterraneanDietCompleted(String nutrient) async {
    final goalKey = 'mediterranean_$nutrient';
    if (_isGoalCompletedToday(goalKey)) return;
    
    _markGoalCompletedToday(goalKey);
    await showNotification(
      id: 9001,
      title: 'Hoàn thành mục tiêu Mediterranean Diet! 🎉',
      body: 'Bạn đã đạt mục tiêu $nutrient trong chế độ ăn Mediterranean!',
      payload: 'mediterranean_diet_completed',
      type: 'progress_completed',
    );
  }

  /// Thông báo khi hoàn thành water progress
  Future<void> notifyWaterGoalCompleted() async {
    const goalKey = 'water_goal';
    if (_isGoalCompletedToday(goalKey)) return;
    
    _markGoalCompletedToday(goalKey);
    await showNotification(
      id: 9002,
      title: 'Hoàn thành mục tiêu nước! 💧',
      body: 'Chúc mừng! Bạn đã đạt mục tiêu nước hôm nay.',
      payload: 'water_goal_completed',
      type: 'progress_completed',
    );
  }

  /// Thông báo khi hoàn thành nutrient progress trong tổng quan dinh dưỡng
  Future<void> notifyNutrientGoalCompleted(String nutrientName) async {
    final goalKey = 'nutrient_$nutrientName';
    if (_isGoalCompletedToday(goalKey)) return;
    
    _markGoalCompletedToday(goalKey);
    await showNotification(
      id: 9003,
      title: 'Hoàn thành mục tiêu $nutrientName! 🎯',
      body: 'Chúc mừng! Bạn đã đạt mục tiêu $nutrientName hôm nay.',
      payload: 'nutrient_goal_completed',
      type: 'progress_completed',
    );
  }
  
  /// Kiểm tra và thông báo khi progress đạt 100%
  Future<void> checkAndNotifyProgressCompletion({
    required String type, // 'mediterranean', 'water', 'nutrient'
    required String name,
    required double consumed,
    required double target,
  }) async {
    if (target <= 0) return;
    
    final percentage = (consumed / target * 100).clamp(0.0, 100.0);
    
    // Only notify when reaching 100% for the first time today
    if (percentage >= 100.0) {
      switch (type) {
        case 'mediterranean':
          await notifyMediterraneanDietCompleted(name);
          break;
        case 'water':
          await notifyWaterGoalCompleted();
          break;
        case 'nutrient':
          await notifyNutrientGoalCompleted(name);
          break;
      }
    }
  }

  /// Cập nhật lịch thông báo giờ ăn từ settings
  Future<void> updateMealTimeNotifications({
    TimeOfDay? breakfast,
    TimeOfDay? lunch,
    TimeOfDay? snack,
    TimeOfDay? dinner,
  }) async {
    // Hủy các thông báo cũ
    await cancelNotification(4001);
    await cancelNotification(4002);
    await cancelNotification(4003);
    await cancelNotification(4004);

    // Lên lịch lại với thời gian mới
    if (breakfast != null) await scheduleBreakfastNotification(breakfast);
    if (lunch != null) await scheduleLunchNotification(lunch);
    if (snack != null) await scheduleSnackNotification(snack);
    if (dinner != null) await scheduleDinnerNotification(dinner);
  }

  /// Cập nhật lịch thông báo uống thuốc
  Future<void> updateMedicationNotifications(
    List<Map<String, dynamic>> medications,
  ) async {
    // Hủy tất cả thông báo thuốc cũ (ID từ 5000-5999)
    for (int i = 5000; i < 6000; i++) {
      await cancelNotification(i);
    }

    // Lên lịch lại cho từng loại thuốc
    for (var medication in medications) {
      final medicationId = medication['medication_id'] as int?;
      final medicationTimes = medication['medication_times'] as List<dynamic>?;
      final medicationName = medication['medication_name'] as String? ?? 'Thuốc';
      final period = medication['period'] as String? ?? '';

      if (medicationId != null && medicationTimes != null) {
        for (var timeStr in medicationTimes) {
          final parts = timeStr.toString().split(':');
          if (parts.length >= 2) {
            final hour = int.tryParse(parts[0]);
            final minute = int.tryParse(parts[1]);
            if (hour != null && minute != null) {
              await scheduleMedicationNotification(
                medicationId: medicationId,
                time: TimeOfDay(hour: hour, minute: minute),
                medicationName: medicationName,
                period: period,
              );
            }
          }
        }
      }
    }
  }
}

