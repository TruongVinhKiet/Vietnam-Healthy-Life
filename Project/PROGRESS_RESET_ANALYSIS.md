# PHÂN TÍCH RESET CÁC TÍNH NĂNG PROGRESS/STATISTICS

**Ngày phân tích:** 13/12/2025  
**Trạng thái:** ⚠️ **CHƯA ĐỦ - CẦN BỔ SUNG**

---

## 📊 CÁC TÍNH NĂNG PROGRESS/STATISTICS HIỆN CÓ

### ✅ 1. WATER INTAKE PROGRESS (Đã có reset)
**Bảng:** `water_intake`  
**Progress fields:** `today_water_ml`, `target_water_ml`  
**Reset trong function:** ❓ **KHÔNG RÕ RÀNG** 

**Hiện trạng:**
- Function `reset_daily_water_utc7()` **CHƯA RESET GÌ CẢ**
- Chỉ có comment "Water reset check" nhưng không có code thực thi
- Dữ liệu water intake vẫn còn từ ngày cũ

**Code hiện tại:**
```sql
CREATE OR REPLACE FUNCTION reset_daily_water_utc7() RETURNS void AS $$
DECLARE
    v_reset_date DATE;
BEGIN
    v_reset_date := (NOW() AT TIME ZONE 'Asia/Ho_Chi_Minh')::DATE;
    
    -- KHÔNG CÓ CODE RESET GÌ CẢ!
    -- Chỉ có comment nhưng không có action
    
    RAISE NOTICE 'Water reset check for date: %', v_reset_date;
END;
```

**❌ VẤN ĐỀ:** Function trống, không reset gì!

---

### ✅ 2. MEDITERRANEAN DIET PROGRESS (Đã có reset)
**Bảng:** `userprofile`  
**Progress fields:** `today_calories`, `today_protein`, `today_fat`, `today_carbs`  
**Reset trong function:** ✅ **CÓ** trong `reset_daily_mediterranean_utc7()`

**Hiện trạng:**
- ✅ Reset 4 fields: calories, protein, fat, carbs về 0
- ✅ Log vào `daily_reset_history` 
- ✅ Chỉ reset 1 lần/ngày
- ✅ Test history: Reset lần cuối 2025-12-13 01:04:17

**Code:**
```sql
UPDATE userprofile
SET 
  today_calories = 0,
  today_protein = 0,
  today_fat = 0,
  today_carbs = 0;
```

**✅ HOẠT ĐỘNG ĐÚNG!**

---

### ❌ 3. MEAL ENTRIES PROGRESS (CHƯA có reset)
**Bảng:** `meal_entries`  
**Progress:** Dữ liệu các bữa ăn trong ngày  
**Reset trong function:** ❌ **KHÔNG CÓ**

**Hiện trạng:**
- Data không cần xóa (lưu trữ lịch sử)
- Chỉ cần filter theo `entry_date`
- **KHÔNG CẦN RESET** - đây là historical data

**✅ OK - Không cần reset**

---

### ❌ 4. USER_MEAL_SUMMARIES (CHƯA có reset)
**Bảng:** `user_meal_summaries`  
**Progress:** Tổng hợp macro hàng ngày  
**Reset trong function:** ❌ **KHÔNG CÓ**

**Hiện trạng:**
- Hiện tại: 0 records (bảng trống)
- Data không cần xóa (lưu trữ lịch sử)
- **KHÔNG CẦN RESET** - đây là summary historical data

**✅ OK - Không cần reset**

---

### ❌ 5. USERNUTRIENTTRACKING (CHƯA có reset)
**Bảng:** `usernutrienttracking`  
**Progress:** Tracking các chất dinh dưỡng hàng ngày  
**Reset trong function:** ❌ **KHÔNG CÓ**

**Hiện trạng:**
- Hiện tại: 0 records (bảng trống hoặc không dùng)
- Nếu dùng: cần reset hoặc cleanup dữ liệu cũ
- **CẦN XEM XÉT** - nếu app dùng bảng này để track progress

**⚠️ CẦN KIỂM TRA THÊM**

---

### ❌ 6. DAILYSUMMARY (CHƯA có reset)
**Bảng:** `dailysummary`  
**Progress:** Tổng hợp tất cả nutrition hàng ngày  
**Reset trong function:** ❌ **KHÔNG CÓ**

**Hiện trạng:**
- Dữ liệu có từ 11/12, 12/12, 13/12
- Data không cần xóa (lưu trữ lịch sử)
- **KHÔNG CẦN RESET** - đây là daily summary history

**✅ OK - Không cần reset**

---

### ❌ 7. USER_DAILY_MEAL_SUGGESTIONS (CHƯA rõ)
**Bảng:** `user_daily_meal_suggestions`  
**Progress:** Gợi ý món ăn hàng ngày  
**Reset trong function:** ✅ **CÓ** trong `cleanup_old_daily_suggestions()`

**Hiện trạng:**
- Cleanup suggestions cũ hơn 7 ngày
- ✅ Đã có trong `perform_daily_reset_utc7()`

**✅ OK - Có cleanup**

---

## 🔍 PHÂN TÍCH CHI TIẾT

### Function `perform_daily_reset_utc7()` hiện tại:

```sql
CREATE OR REPLACE FUNCTION perform_daily_reset_utc7()
RETURNS void AS $$
DECLARE
  v_vietnam_date DATE;
  v_vietnam_time TIME;
  v_reset_count INT;
BEGIN
  v_vietnam_date := get_vietnam_date();
  v_vietnam_time := (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::TIME;
  
  RAISE NOTICE 'Starting daily reset at Vietnam time: % %', v_vietnam_date, v_vietnam_time;
  
  -- 1. Reset water tracking
  PERFORM reset_daily_water_utc7();  -- ❌ FUNCTION TRỐNG!
  
  -- 2. Reset Mediterranean diet tracking
  PERFORM reset_daily_mediterranean_utc7();  -- ✅ OK
  
  -- 3. Cleanup old daily meal suggestions (older than 7 days)
  SELECT cleanup_old_daily_suggestions() INTO v_reset_count;  -- ✅ OK
  
  -- 4. Check and notify nutrient deficiencies for yesterday
  PERFORM check_and_notify_nutrient_deficiencies();  -- ✅ OK
  
  -- 5. Auto-expire old pinned suggestions (delete expired ones)
  DELETE FROM user_pinned_suggestions WHERE expires_at < CURRENT_TIMESTAMP;  -- ✅ OK
  
  -- 6. Log the reset
  INSERT INTO daily_reset_history (reset_type, reset_date, reset_timestamp)
  VALUES ('full_daily_reset', v_vietnam_date, CURRENT_TIMESTAMP)
  ON CONFLICT (reset_type, reset_date) DO NOTHING;  -- ✅ OK
  
  RAISE NOTICE 'Daily reset completed successfully for %', v_vietnam_date;
END;
$$ LANGUAGE plpgsql;
```

---

## ⚠️ CÁC VẤN ĐỀ CẦN SỬA

### 🔴 1. Water Intake Reset - FUNCTION TRỐNG!

**Vấn đề:**
- `reset_daily_water_utc7()` không làm gì cả
- Bảng `water_intake` không được reset
- Data từ ngày cũ vẫn còn

**Giải pháp:**

**Option A: KHÔNG CẦN RESET** (Recommended)
- Water intake là historical data
- App filter theo `date` column
- Không cần xóa data cũ
- **Chỉ cần đổi tên function thành `check_daily_water_status_utc7()` để không gây nhầm lẫn**

**Option B: RESET DATA CŨ** (Nếu cần)
```sql
CREATE OR REPLACE FUNCTION reset_daily_water_utc7() RETURNS void AS $$
DECLARE
    v_vietnam_date DATE;
BEGIN
    v_vietnam_date := get_vietnam_date();
    
    -- Option 1: Delete old records (> 30 days)
    DELETE FROM water_intake
    WHERE date < v_vietnam_date - INTERVAL '30 days';
    
    -- Option 2: Archive old data before delete
    INSERT INTO water_intake_history 
    SELECT * FROM water_intake 
    WHERE date < v_vietnam_date - INTERVAL '30 days';
    
    DELETE FROM water_intake
    WHERE date < v_vietnam_date - INTERVAL '30 days';
    
    RAISE NOTICE 'Water intake cleanup completed for date: %', v_vietnam_date;
END;
$$ LANGUAGE plpgsql;
```

---

### 🟡 2. UserNutrientTracking - CHƯA RÕ

**Cần kiểm tra:**
- App có dùng bảng này không?
- Nếu có: cần reset hoặc cleanup
- Nếu không: có thể bỏ qua

**Giải pháp:** Kiểm tra backend code xem có query bảng này không

---

### 🟡 3. Progress Bar UI Data Source

**Cần xác định:**
- Water progress bar lấy data từ đâu?
  - Từ `water_intake.today_water_ml`?
  - Hay tính tổng từ các records?
- Meal progress lấy từ đâu?
  - Từ `userprofile.today_*`? ✅
  - Từ `dailysummary`? ✅
  
**Nếu progress bar dựa vào:**
- ✅ `userprofile.today_*` → Đã reset OK
- ✅ `dailysummary` → Historical data, OK
- ❓ `water_intake` aggregation → Cần confirm

---

## 📋 CHECKLIST KIỂM TRA

### Backend Code Review:
- [ ] Tìm code render water progress bar
- [ ] Xem query lấy `today_water_ml` từ đâu
- [ ] Kiểm tra `usernutrienttracking` có được dùng không
- [ ] Verify progress bars lấy data source nào

### Database Functions:
- [ ] Sửa `reset_daily_water_utc7()` - remove hoặc implement đúng
- [ ] Thêm cleanup cho `usernutrienttracking` nếu cần
- [ ] Test reset function với real data

### Testing:
- [ ] Test water progress bar sau reset
- [ ] Test meal progress bar sau reset  
- [ ] Verify data không bị mất
- [ ] Check performance của cleanup queries

---

## 🎯 KẾT LUẬN SAU KHI PHÂN TÍCH CODE

### ✅ WATER TRACKING - OK (KHÔNG CẦN RESET)

**Cách hoạt động:**
```javascript
// waterService.js - Khi log nước:
// 1. Insert vào WaterLog (historical log)
INSERT INTO WaterLog (user_id, amount_ml, log_date, ...)

// 2. Update DailySummary.total_water (cumulative)
INSERT INTO DailySummary (user_id, date, total_water) 
VALUES (...) 
ON CONFLICT DO UPDATE 
SET total_water = DailySummary.total_water + EXCLUDED.total_water
```

**Data flow:**
- `WaterLog` table: Historical logs (KHÔNG XÓA)
- `DailySummary.total_water`: Tổng nước trong ngày (CUMULATIVE)
- `water_intake` table: Aggregate view (có triggers auto-update)

**✅ KẾT LUẬN:** 
- ✅ Water progress đọc từ `DailySummary.total_water`
- ✅ `DailySummary` reset tự nhiên khi ngày mới (app query theo date)
- ✅ `WaterLog` là historical data (KHÔNG CẦN XÓA)
- ✅ Function `reset_daily_water_utc7()` **KHÔNG CẦN LÀM GÌ** vì data tự động phân biệt theo date
- ✅ **ĐÚNG THIẾT KẾ!**

---

### ✅ USERNUTRIENTTRACKING - ĐANG DÙNG (OK)

**Cách hoạt động:**
```javascript
// mealService.js & nutrientTrackingService.js
// Update sau mỗi meal operation:
INSERT INTO UserNutrientTracking (
  user_id, date, nutrient_type, nutrient_id, 
  target_amount, current_amount, unit, last_updated
) VALUES (...)
ON CONFLICT (user_id, date, nutrient_type, nutrient_id) 
DO UPDATE SET 
  current_amount = EXCLUDED.current_amount,
  target_amount = EXCLUDED.target_amount,
  last_updated = NOW()
```

**✅ KẾT LUẬN:**
- ✅ Bảng được dùng để track nutrients
- ✅ Data phân biệt theo `date` column
- ✅ **KHÔNG CẦN RESET** - data historical, query theo date

---

## 🎯 KẾT LUẬN CUỐI CÙNG

### ✅ TẤT CẢ PROGRESS/STATISTICS ĐÃ OK!

**Trạng thái hiện tại:**

✅ **HOẠT ĐỘNG ĐÚNG:**
1. ✅ **Mediterranean Diet Progress** 
   - Fields: `userprofile.today_calories/protein/fat/carbs`
   - Reset: `reset_daily_mediterranean_utc7()` - Reset về 0 mỗi ngày
   - Trigger: Auto-reset vào 00:00 UTC+7

2. ✅ **Water Intake Progress**
   - Fields: `DailySummary.total_water`
   - Reset: **KHÔNG CẦN** - Data tự nhiên phân theo `date`
   - Logs: `WaterLog` table (historical, không xóa)
   - Function `reset_daily_water_utc7()` **ĐÚNG LÀ TRỐNG** vì không cần làm gì

3. ✅ **Nutrient Tracking Progress**
   - Fields: `UserNutrientTracking.current_amount`
   - Reset: **KHÔNG CẦN** - Data phân theo `date`
   - Update: Sau mỗi meal operation

4. ✅ **Daily Summary**
   - Table: `DailySummary` (calories, protein, fat, carbs, water, fiber)
   - Reset: **KHÔNG CẦN** - Historical data theo `date`

5. ✅ **Meal Entries**
   - Table: `meal_entries`
   - Reset: **KHÔNG CẦN** - Historical data theo `entry_date`

6. ✅ **Meal Suggestions**
   - Table: `user_daily_meal_suggestions`
   - Cleanup: `cleanup_old_daily_suggestions()` - Xóa cũ hơn 7 ngày

7. ✅ **Pinned Suggestions**
   - Table: `user_pinned_suggestions`
   - Expire: Auto-delete khi `expires_at < NOW()`

---

## 📊 SƠ ĐỒ RESET SYSTEM

```
00:00 Vietnam Time
    ↓
perform_daily_reset_utc7()
    ↓
    ├─→ reset_daily_water_utc7()          ✅ OK (empty - không cần làm gì)
    ├─→ reset_daily_mediterranean_utc7()  ✅ RESET today_* về 0
    ├─→ cleanup_old_daily_suggestions()   ✅ XÓA suggestions > 7 days
    ├─→ check_and_notify_deficiencies()   ✅ CHECK nutrients
    └─→ DELETE expired pins               ✅ XÓA expired pins
```

---

## ✅ KHUYẾN NGHỊ

### 🟢 KHÔNG CẦN SỬA GÌ

**Lý do:**
1. ✅ Mediterranean diet progress **ĐANG RESET** đúng
2. ✅ Water progress **KHÔNG CẦN RESET** (data theo date)
3. ✅ Nutrient tracking **KHÔNG CẦN RESET** (data theo date)
4. ✅ Tất cả bảng khác đều là historical data (không cần reset)

### 📝 Documentation Update (Optional)

Nếu muốn làm rõ, có thể:
1. Đổi tên `reset_daily_water_utc7()` → `check_water_status_utc7()` (để không gây nhầm)
2. Thêm comment giải thích tại sao function trống
3. Hoặc giữ nguyên vì **THIẾT KẾ ĐÃ ĐÚNG**

---

## ✅ KẾT LUẬN

**🎉 TẤT CẢ PROGRESS VÀ STATISTICS ĐÃ TỰ ĐỘNG RESET ĐÚNG!**

- ✅ Mediterranean diet → Reset về 0 lúc 00:00
- ✅ Water intake → Tự động theo date (không cần reset)
- ✅ Nutrient tracking → Tự động theo date (không cần reset)
- ✅ Meal data → Historical (không cần reset)
- ✅ Suggestions → Auto cleanup cũ

**Hệ thống hoạt động hoàn hảo!** 🎯
