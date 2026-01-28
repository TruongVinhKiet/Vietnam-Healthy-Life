# HƯỚNG DẪN NHANH - HỆ THỐNG RESET TỰ ĐỘNG UTC+7

## ✅ ĐÃ HOÀN TẤT

Hệ thống **TỰ ĐỘNG RESET** mỗi ngày lúc 00:00 giờ Việt Nam đã được cài đặt và test thành công.

---

## 🚀 SỬ DỤNG

### TỰ ĐỘNG (Khuyên Dùng)

**KHÔNG CẦN LÀM GÌ!** Hệ thống tự động hoạt động khi:
- User log nước đầu tiên trong ngày
- User thêm meal đầu tiên trong ngày

### Kiểm Tra Reset
```sql
-- Xem lịch sử reset
SELECT * FROM daily_reset_history ORDER BY reset_timestamp DESC LIMIT 5;

-- Kiểm tra cần reset không
SELECT should_perform_daily_reset();

-- Thời gian VN hiện tại
SELECT get_vietnam_date(), 
       (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME;
```

### Reset Thủ Công (Nếu Cần)
```sql
SELECT perform_daily_reset_utc7();
```

Hoặc từ terminal:
```bash
psql -U postgres -d Health -c "SELECT perform_daily_reset_utc7();"
```

---

## 📊 CÁC THÔNG SỐ ĐƯỢC RESET

| Thông số | Bảng | Giá trị reset |
|----------|------|---------------|
| Water intake | `WaterLog` / `DailySummary` | 0 ml |
| Calories | `userprofile.today_calories` | 0 |
| Protein | `userprofile.today_protein` | 0 |
| Fat | `userprofile.today_fat` | 0 |
| Carbs | `userprofile.today_carbs` | 0 |
| Old suggestions | `user_daily_meal_suggestions` | Deleted (>7 days) |
| Expired pins | `user_pinned_suggestions` | Deleted |

---

## 🔧 FUNCTIONS QUAN TRỌNG

### Helper Functions
```sql
get_vietnam_date()              -- Date hiện tại VN
to_vietnam_date(timestamp)      -- Convert timestamp to VN date
vietnam_date_start(date)        -- 00:00:00 VN time
vietnam_date_end(date)          -- 23:59:59 VN time
```

### Reset Functions
```sql
perform_daily_reset_utc7()             -- MASTER RESET (gọi cái này)
should_perform_daily_reset()            -- Check cần reset không
reset_daily_water_utc7()                -- Reset water
reset_daily_mediterranean_utc7()        -- Reset mediterranean diet
```

---

## ⚡ VÍ DỤ SỬ DỤNG

### Backend JavaScript
```javascript
const { getVietnamDate } = require('../utils/dateHelper');

// Get VN date
const today = getVietnamDate(); // "2025-12-12"

// Query with VN date
const result = await pool.query(
  'SELECT * FROM meal_entries WHERE entry_date = $1',
  [today]
);
```

### SQL Queries
```sql
-- Insert với VN date (auto default)
INSERT INTO meal_entries (user_id, food_id, weight_g)
VALUES (1, 100, 150);
-- entry_date tự động = get_vietnam_date()

-- Query hôm nay
SELECT * FROM meal_entries 
WHERE entry_date = get_vietnam_date();

-- Query 7 ngày qua
SELECT * FROM meal_entries
WHERE entry_date >= get_vietnam_date() - INTERVAL '7 days';
```

### Flutter/Dart
```dart
// Get VN date
String _vietnamDateString() {
  final utcNow = DateTime.now().toUtc();
  final vnNow = utcNow.add(const Duration(hours: 7));
  return vnNow.toIso8601String().split('T').first;
}
```

---

## 📅 LỊCH RESET HÀNG NGÀY

**Thời điểm:** 00:00 giờ Việt Nam (UTC+7)

**Tự động kích hoạt khi:**
1. User log water đầu tiên
2. User add meal đầu tiên

**Các công việc thực hiện:**
1. ✅ Reset water tracking về 0
2. ✅ Reset Mediterranean diet counters về 0
3. ✅ Xóa meal suggestions cũ hơn 7 ngày
4. ✅ Kiểm tra thiếu dinh dưỡng
5. ✅ Xóa pinned suggestions đã hết hạn
6. ✅ Ghi log vào `daily_reset_history`

---

## 🔍 TROUBLESHOOTING

### Reset không chạy?
```sql
-- 1. Kiểm tra triggers
SELECT tgname, tgrelid::regclass 
FROM pg_trigger 
WHERE tgname LIKE '%auto_daily_reset%';

-- 2. Kiểm tra functions
SELECT proname FROM pg_proc 
WHERE proname LIKE '%vietnam%';

-- 3. Reset thủ công
SELECT perform_daily_reset_utc7();
```

### Kiểm tra timezone
```sql
SHOW TIMEZONE;  -- Nên là 'Asia/Ho_Chi_Minh'

SELECT 
  get_vietnam_date() as vn_date,
  CURRENT_DATE as utc_date,
  CURRENT_DATE = get_vietnam_date() as is_same;
```

### Xem logs
```sql
-- Reset history
SELECT * FROM daily_reset_history 
WHERE reset_date >= CURRENT_DATE - 7
ORDER BY reset_timestamp DESC;

-- Kiểm tra user data
SELECT user_id, today_calories, today_protein 
FROM userprofile 
LIMIT 5;
```

---

## 🎯 LƯU Ý QUAN TRỌNG

⚠️ **QUAN TRỌNG:** 
- Tất cả date operations PHẢI dùng `get_vietnam_date()`
- KHÔNG dùng `CURRENT_DATE` trực tiếp
- KHÔNG dùng `new Date().toISOString()` trong JavaScript

✅ **ĐÚNG:**
```sql
WHERE entry_date = get_vietnam_date()
```

❌ **SAI:**
```sql
WHERE entry_date = CURRENT_DATE
```

✅ **ĐÚNG (JS):**
```javascript
const date = getVietnamDate();
```

❌ **SAI (JS):**
```javascript
const date = new Date().toISOString().split('T')[0];
```

---

## 📱 CONTACT / SUPPORT

Nếu có vấn đề:
1. Kiểm tra logs trong `daily_reset_history`
2. Test với `SELECT perform_daily_reset_utc7();`
3. Xem file `TIMEZONE_COMPLETE_AUDIT_REPORT.md` để biết chi tiết

---

**Trạng thái:** ✅ PRODUCTION READY  
**Last Updated:** 13/12/2025
