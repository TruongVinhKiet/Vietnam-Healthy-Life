# Real-time Nutrient Tracking & Push Notifications

Hệ thống theo dõi dinh dưỡng thời gian thực và thông báo tự động khi thiếu hụt chất dinh dưỡng.

## 📊 Database Schema

### UserNutrientTracking Table
Theo dõi lượng chất dinh dưỡng hàng ngày:
- `tracking_id`: Primary key
- `user_id`: Foreign key to User
- `date`: Ngày theo dõi
- `nutrient_type`: 'vitamin', 'mineral', 'fiber', 'fatty_acid'
- `nutrient_id`: ID của chất dinh dưỡng
- `target_amount`: Lượng khuyến nghị
- `current_amount`: Lượng hiện tại đã tiêu thụ
- `unit`: Đơn vị đo
- `last_updated`: Timestamp cập nhật cuối

### UserNutrientNotification Table
Lưu trữ thông báo về dinh dưỡng:
- `notification_id`: Primary key
- `user_id`: Foreign key to User
- `nutrient_type`: Loại chất dinh dưỡng
- `nutrient_id`: ID chất dinh dưỡng
- `nutrient_name`: Tên chất dinh dưỡng
- `notification_type`: 'deficiency_warning', 'daily_reminder', 'goal_achieved'
- `title`: Tiêu đề thông báo
- `message`: Nội dung chi tiết
- `severity`: 'info', 'warning', 'critical'
- `is_read`: Đã đọc hay chưa
- `metadata`: Dữ liệu bổ sung (JSON)
- `created_at`: Thời gian tạo

## 🔧 Backend Functions

### 1. calculate_daily_nutrient_intake(user_id, date)
Tính toán lượng chất dinh dưỡng từ bữa ăn trong ngày:
- Query FoodNutrient để tính tổng từ MealItem
- So sánh với UserVitaminRequirement/UserMineralRequirement
- Trả về: nutrient_type, nutrient_id, current_amount, target_amount, percentage

### 2. check_and_notify_nutrient_deficiencies(user_id, date)
Kiểm tra thiếu hụt và tạo thông báo:
- Chạy sau mỗi ngày hoặc khi user yêu cầu
- Phát hiện nutrients < 50% mục tiêu
- Severity levels:
  - < 25%: 'critical' (⚠️ Thiếu hụt nghiêm trọng)
  - < 50%: 'warning' (⚡ Cần bổ sung)
- Tự động insert vào UserNutrientNotification

### 3. update_nutrient_tracking() Trigger
Trigger tự động khi MealItem thay đổi:
- INSERT/UPDATE/DELETE trên MealItem
- Cập nhật UserNutrientTracking

## 🚀 API Endpoints

### GET /nutrients/tracking/daily
Lấy theo dõi hàng ngày với tiến độ hiện tại
```json
{
  "success": true,
  "date": "2025-06-15",
  "nutrients": [
    {
      "nutrient_type": "vitamin",
      "nutrient_id": 1,
      "nutrient_name": "Vitamin A",
      "current_amount": 450,
      "target_amount": 900,
      "unit": "µg",
      "percentage": 50.0
    }
  ]
}
```

### GET /nutrients/tracking/breakdown
Chi tiết nguồn thức ăn đóng góp dinh dưỡng

### POST /nutrients/tracking/check-deficiencies
Kiểm tra và tạo thông báo thiếu hụt

### GET /nutrients/tracking/notifications
Lấy danh sách thông báo dinh dưỡng
```json
{
  "success": true,
  "notifications": [
    {
      "notification_id": 123,
      "title": "⚠️ Thiếu hụt nghiêm trọng: Vitamin D",
      "message": "Bạn chỉ đạt 18% nhu cầu Vitamin D (3.6/20 µg). Hãy bổ sung ngay!",
      "severity": "critical",
      "is_read": false,
      "metadata": {
        "percentage": 18.0,
        "current_amount": 3.6,
        "target_amount": 20.0,
        "unit": "µg"
      }
    }
  ],
  "unread_count": 5
}
```

### PUT /nutrients/tracking/notifications/:id/read
Đánh dấu thông báo đã đọc

### PUT /nutrients/tracking/notifications/read-all
Đánh dấu tất cả đã đọc

### GET /nutrients/tracking/summary
Tóm tắt cho home screen RDA cards

### GET /nutrients/tracking/report
Báo cáo toàn diện

### POST /nutrients/tracking/update
Cập nhật tracking sau khi thêm/sửa meal

## 📱 Flutter Integration

### NutrientTrackingService
Service class với các methods:
- `getDailyTracking({date})`: Lấy tracking hàng ngày
- `getNutrientBreakdown({date})`: Chi tiết nguồn thức ăn
- `checkDeficiencies({date})`: Kiểm tra thiếu hụt
- `getNotifications({limit})`: Lấy thông báo
- `markNotificationRead(id)`: Đánh dấu đã đọc
- `getSummary({date})`: Tóm tắt
- `updateTracking({date})`: Cập nhật sau meal change

Helpers:
- `calculateProgress(current, target)`: Tính %
- `getProgressColor(percentage)`: Màu theo %
- `formatAmount(amount, unit)`: Format hiển thị

### PersonalizedRDAScreen Updates
- Real-time tracking data từ backend
- Progress bars với actual meal data
- Notification badge
- Refresh functionality

### NutrientNotificationsWidget
Full-featured notification screen:
- List với animations (staggered)
- Severity indicators (critical/warning/info)
- Unread count badge
- Mark as read functionality
- Detail modal với progress visualization
- Time formatting (vừa xong, X phút trước, etc.)

## 🔄 Notification Integration

### Updated authController.notifications()
Merged notifications:
```javascript
// Get security notifications (login, account status)
const securityNotifications = await securityService.getNotifications(userId);

// Get nutrient notifications (deficiencies)
const nutrientNotifications = await nutrientTrackingService.getNutrientNotifications(userId, 20);

// Merge and sort by time
const allNotifications = [...securityNotifications, ...nutrientNotifications];
```

Types:
- Security: 'last_login', 'account_unblocked', 'metrics_updated'
- Nutrient: 'deficiency_warning'

## 🧪 Testing

Run migration:
```bash
node backend/run_nutrient_tracking_migration.js
```

Test tracking:
```bash
node backend/test_nutrient_tracking.js
```

Test output includes:
- ✅ Login/Register
- 📊 Daily tracking with progress bars
- 🍎 Food sources breakdown
- 🔔 Notifications with severity icons
- 💊 Summary statistics
- ⚗️ Integration with auth notifications

## 🎨 UI Features

### Progress Indicators
Color-coded by percentage:
- 🟢 Green (≥100%): Achieved
- 🟠 Orange (≥70%): Good progress
- 🔵 Blue (≥50%): Moderate
- 🟠 Deep Orange (≥25%): Warning
- 🔴 Red (<25%): Critical

### Animations
- Fade in: 800ms main content
- Staggered cards: 400ms + index*100ms
- Slide up: Offset(0, 0.3) → Offset.zero
- Scale: RDA cards on home screen
- TweenAnimationBuilder for smooth transitions

### Notification Badges
- Unread count on app bar
- Blue dot indicator on unread items
- Different background color for unread

## 📝 Data Flow

1. **User adds meal** → MealItem INSERT
2. **Trigger fires** → update_nutrient_tracking()
3. **Backend calculates** → calculate_daily_nutrient_intake()
4. **End of day check** → check_and_notify_nutrient_deficiencies()
5. **Notifications created** → UserNutrientNotification INSERT
6. **User opens app** → GET /auth/notifications
7. **Merged response** → Security + Nutrient notifications
8. **UI displays** → NotificationsScreen with badges

## 🚀 Next Steps

- [ ] Schedule daily deficiency check (cron job)
- [ ] Push notifications (Firebase)
- [ ] Weekly/monthly reports
- [ ] Export to PDF
- [ ] AI-powered food suggestions
- [ ] Barcode scanner for quick food entry
- [ ] Meal planning based on deficiencies

## 📊 Example Notification Messages

**Critical (< 25%)**:
```
⚠️ Thiếu hụt nghiêm trọng: Vitamin D
Bạn chỉ đạt 18% nhu cầu Vitamin D (3.6/20 µg). Hãy bổ sung ngay!
```

**Warning (< 50%)**:
```
⚡ Cần bổ sung: Calcium
Bạn đã đạt 45% nhu cầu Calcium (450/1000 mg). Còn 550 mg nữa.
```

**Info (≥ 50%)**:
```
ℹ️ Tiến độ tốt: Vitamin C
Bạn đã đạt 85% nhu cầu Vitamin C (68/80 mg). Còn 12 mg nữa.
```
