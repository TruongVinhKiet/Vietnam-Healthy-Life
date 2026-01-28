# Hệ Thống Thông Báo Local - Tài Liệu Triển Khai

## ✅ Đã Hoàn Thành

### 1. Package và Service
- ✅ Thêm `flutter_local_notifications` và `timezone` vào `pubspec.yaml`
- ✅ Tạo `LocalNotificationService` với đầy đủ các phương thức thông báo
- ✅ Khởi tạo service trong `main.dart`

### 2. Thông Báo Đã Tích Hợp

#### ✅ Tạo Món Ăn Mới
- **File**: `lib/screens/create_dish_screen.dart`
- **Thông báo**: "Món ăn đã được tạo thành công! 🍽️"
- **Trigger**: Khi tạo món ăn thành công

#### ✅ Tạo Đồ Uống Mới
- **File**: `lib/screens/create_drink_screen.dart`
- **Thông báo**: "Đồ uống đã được tạo thành công! 🥤"
- **Trigger**: Khi tạo đồ uống thành công

#### ✅ Thêm Meal
- **File**: `lib/widgets/add_meal_dialog.dart`
- **Thông báo**: "Đã thêm vào [Bữa sáng/trưa/xế/tối]! ✅"
- **Trigger**: Khi thêm món ăn vào meal thành công

#### ✅ Thêm Water
- **File**: `lib/water_view.dart`
- **Thông báo**: "Đã ghi nhận nước! 💧"
- **Trigger**: Khi log water thành công

#### ✅ Chấp Nhận Bảng Dinh Dưỡng (Chatbot)
- **File**: `lib/screens/chat_screen.dart`
- **Thông báo**: "Đã chấp nhận bảng dinh dưỡng! ✅"
- **Trigger**: Khi chấp nhận nutrition từ chatbot

#### ✅ Chấp Nhận Bảng Dinh Dưỡng (AI Image Analysis)
- **File**: `lib/screens/ai_image_analysis_screen.dart`
- **Thông báo**: "Đã chấp nhận phân tích AI! ✅"
- **Trigger**: Khi chấp nhận nutrition từ AI analysis

#### ✅ Thay Đổi Thông Tin Cá Nhân
- **File**: `lib/screens/personal_info_screen.dart`
- **Thông báo**: "Thông tin đã được cập nhật! ✅"
- **Trigger**: Khi cập nhật profile thành công

#### ✅ Bật/Tắt 2FA
- **File**: `lib/screens/security_screen.dart`
- **Thông báo**: 
  - "Xác thực hai lớp đã được bật! 🔒" (khi bật)
  - "Xác thực hai lớp đã được tắt! 🔓" (khi tắt)
- **Trigger**: Khi enable/disable 2FA thành công

#### ✅ Đổi Mật Khẩu
- **File**: `lib/screens/security_screen.dart`
- **Thông báo**: "Mật khẩu đã được đổi! 🔑"
- **Trigger**: Khi đổi mật khẩu thành công

#### ✅ Lên Lịch Giờ Ăn
- **File**: `lib/my_diary_screen.dart`
- **Thông báo**: 
  - "Đến giờ ăn sáng! 🌅"
  - "Đến giờ ăn trưa! 🍽️"
  - "Đến giờ ăn xế! 🍰"
  - "Đến giờ ăn tối! 🌙"
- **Trigger**: Khi cập nhật meal time settings, tự động lên lịch thông báo hàng ngày

## ⚠️ Cần Hoàn Thiện

### 1. Thông Báo Tin Nhắn Mới (Admin, Community, Friends)
**Trạng thái**: Chưa tích hợp
**Lý do**: Cần thêm listener/polling để phát hiện tin nhắn mới
**Cách triển khai**:
- Thêm polling trong `chat_screen.dart` để kiểm tra tin nhắn mới
- Hoặc sử dụng WebSocket nếu backend hỗ trợ
- Gọi `LocalNotificationService().notifyNewAdminMessage()` khi có tin nhắn mới từ admin
- Gọi `LocalNotificationService().notifyNewCommunityMessage()` khi có tin nhắn mới từ cộng đồng
- Gọi `LocalNotificationService().notifyNewFriendMessage()` khi có tin nhắn mới từ bạn bè

**Lưu ý**: KHÔNG thông báo tin nhắn từ chatbot (theo yêu cầu)

### 2. Thông Báo Giờ Uống Thuốc
**Trạng thái**: Service đã có, chưa tích hợp vào UI
**Cách triển khai**:
- Khi tạo/cập nhật medication schedule trong `health_condition_dialog.dart` hoặc `schedule_screen.dart`
- Gọi `LocalNotificationService().updateMedicationNotifications()` với danh sách medications
- Service sẽ tự động lên lịch thông báo hàng ngày cho mỗi giờ uống thuốc

### 3. Thông Báo Khi Tài Khoản Bị Khóa/Mở Khóa
**Trạng thái**: Service đã có, cần tích hợp vào backend response
**Cách triển khai**:
- Khi login thất bại nhiều lần → backend trả về account locked → gọi `notifyAccountLocked()`
- Khi unlock thành công → gọi `notifyAccountUnlocked()`
- Khi admin lock/unlock → backend trả về → gọi `notifyAccountLockedByAdmin()` hoặc `notifyAccountUnlockedByAdmin()`

### 4. Thông Báo Khi Hoàn Thành Progress Bars
**Trạng thái**: Chưa tích hợp
**Cách triển khai**:
- Trong `mediterranean_diet_view.dart`: Kiểm tra khi progress đạt 100% → gọi `notifyMediterraneanDietCompleted()`
- Trong `water_view.dart` hoặc nơi hiển thị water progress: Kiểm tra khi đạt goal → gọi `notifyWaterGoalCompleted()`
- Trong `nutrition_overview_view.dart`: Kiểm tra khi mỗi nutrient đạt 100% → gọi `notifyNutrientGoalCompleted()`

**Lưu ý**: Cần kiểm tra để không thông báo nhiều lần cho cùng một mục tiêu trong cùng một ngày

## 📝 Cấu Trúc Service

### LocalNotificationService Methods

#### Immediate Notifications
- `notifyDishCreated(String dishName)`
- `notifyDrinkCreated(String drinkName)`
- `notifyMealAdded(String mealType, String foodName)`
- `notifyWaterAdded(double amountMl, String? drinkName)`
- `notifyNewAdminMessage(String messagePreview)`
- `notifyNewCommunityMessage(String senderName, String messagePreview)`
- `notifyNewFriendMessage(String friendName, String messagePreview)`
- `notifyPersonalInfoChanged()`
- `notify2FAEnabled()`
- `notify2FADisabled()`
- `notifyPasswordChanged()`
- `notifyAccountLocked(int attempts, int threshold)`
- `notifyAccountUnlocked()`
- `notifyAccountLockedByAdmin(String reason)`
- `notifyAccountUnlockedByAdmin()`
- `notifyNutritionAcceptedFromChat(String foodName)`
- `notifyNutritionAcceptedFromAI(String foodName)`
- `notifyMediterraneanDietCompleted(String nutrient)`
- `notifyWaterGoalCompleted()`
- `notifyNutrientGoalCompleted(String nutrientName)`

#### Scheduled Notifications
- `scheduleBreakfastNotification(TimeOfDay time)`
- `scheduleLunchNotification(TimeOfDay time)`
- `scheduleSnackNotification(TimeOfDay time)`
- `scheduleDinnerNotification(TimeOfDay time)`
- `scheduleMedicationNotification(...)`
- `updateMealTimeNotifications(...)`
- `updateMedicationNotifications(List<Map<String, dynamic>> medications)`

## 🔧 Cấu Hình

### Android
- Channel ID: `my_diary_channel`
- Channel Name: `My Diary Notifications`
- Importance: High
- Priority: High

### iOS
- Alert: Enabled
- Badge: Enabled
- Sound: Enabled

## 📱 Testing

Để test thông báo:
1. Chạy app trên thiết bị thật (thông báo local không hoạt động trên emulator)
2. Cấp quyền thông báo khi được hỏi
3. Thực hiện các hành động để trigger thông báo
4. Kiểm tra thông báo xuất hiện

## 🐛 Known Issues

- Thông báo chat messages chưa được tích hợp (cần polling/WebSocket)
- Thông báo medication chưa được tích hợp vào UI
- Thông báo progress bar completion chưa được tích hợp
- Thông báo account lock/unlock cần tích hợp vào login flow

## 📚 Tài Liệu Tham Khảo

- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [timezone](https://pub.dev/packages/timezone)

