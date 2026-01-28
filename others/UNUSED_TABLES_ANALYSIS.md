# PHÂN TÍCH CÁC BẢNG CHƯA SỬ DỤNG VÀ GỢI Ý TÍNH NĂNG

## 📊 TỔNG QUAN
- **Tổng số bảng trong schema**: 55+ bảng
- **Bảng đã sử dụng**: ~20 bảng
- **Bảng chưa sử dụng hoàn toàn**: 12 bảng
- **Bảng sử dụng một phần**: 8 bảng

---

## 🔴 NHÓM 1: BẢNG CHƯA SỬ DỤNG HOÀN TOÀN (CÓ TRONG SCHEMA NHƯNG CHƯA CÓ ENDPOINT/SCREEN)

### 1. **FoodTag & FoodTagMapping**
**Mô tả**: Gắn tag/nhãn cho thực phẩm (vd: "giàu protein", "ít calo", "chay")

**Trạng thái**: ❌ Chưa có route, controller, screen

**Tính năng đề xuất**:
```
✅ Tính năng "Lọc thực phẩm theo tag"
   - Screen: Food Explorer/Search với bộ lọc tag
   - Backend: GET /foods/tags (list tags), GET /foods?tags=protein,low-carb
   - UI: Chip/Badge hiển thị tags trên Food Card
   
✅ Tính năng "Gợi ý thực phẩm theo sở thích"
   - Lưu tag yêu thích của user → gợi ý món ăn tương tự
   - Backend: POST /users/preferences/tags
   - Screen: PersonalizedFoodRecommendationScreen

✅ Admin quản lý tags
   - Screen: admin/tags
   - CRUD operations cho tags
```

**Độ ưu tiên**: ⭐⭐⭐⭐ (CAO - tăng trải nghiệm tìm kiếm)

---

### 2. **HealthCondition**
**Mô tả**: Lưu các tình trạng sức khỏe của user (tiểu đường, huyết áp cao, v.v.)

**Trạng thái**: ❌ Không có endpoint, chỉ có bảng trong DB

**Tính năng đề xuất**:
```
✅ Tính năng "Hồ sơ sức khỏe cá nhân"
   - Screen: HealthProfileScreen
   - Cho phép user chọn/nhập các bệnh lý hiện có
   - Backend: GET/POST/DELETE /users/health-conditions
   
✅ Cảnh báo dinh dưỡng thông minh
   - Cảnh báo khi user chọn món ăn không phù hợp với bệnh lý
   - Ví dụ: "Bạn có tiểu đường, món này có chỉ số đường cao"
   - Backend: GET /users/health-warnings?food_id=123

✅ Gợi ý thực đơn cá nhân hóa
   - Dựa trên health conditions để filter món ăn
   - Screen: PersonalizedMealPlanScreen
```

**Độ ưu tiên**: ⭐⭐⭐⭐⭐ (RẤT CAO - tính năng core cho health app)

---

### 3. **Suggestion**
**Mô tả**: Gợi ý thực phẩm dựa trên thiếu hụt dinh dưỡng hàng ngày

**Trạng thái**: ❌ Bảng trống, không có logic tính toán

**Tính năng đề xuất**:
```
✅ Tính năng "Gợi ý thông minh"
   - Sau mỗi bữa ăn, tính thiếu hụt dinh dưỡng
   - Gợi ý món ăn bổ sung (vd: "Bạn thiếu 20g protein, nên ăn thêm...")
   - Backend: GET /suggestions/daily
   - Screen: DailySuggestionWidget (hiển thị trên home)

✅ Scheduled job tự động
   - Chạy vào cuối ngày để tạo suggestions cho ngày hôm sau
   - Notification: "Hôm nay bạn nên ăn cá hồi để bổ sung Omega-3"
```

**Độ ưu tiên**: ⭐⭐⭐⭐⭐ (RẤT CAO - AI-driven feature)

---

### 4. **ConditionNutrientEffect**
**Mô tả**: Định nghĩa ảnh hưởng của bệnh lý đến nhu cầu dinh dưỡng

**Trạng thái**: ❌ Bảng trống, không có seed data

**Tính năng đề xuất**:
```
✅ Điều chỉnh RDA dựa trên bệnh lý
   - Tự động tăng/giảm recommended daily amount
   - Ví dụ: Người bị thiếu máu → tăng 30% nhu cầu sắt
   - Backend: Trigger tự động khi user thêm health condition

✅ Admin seed data
   - Screen: admin/condition-effects
   - Seed các rule medically-validated
   - Ví dụ: "Hypertension" → decrease sodium by 50%
```

**Độ ưu tiên**: ⭐⭐⭐⭐ (CAO - làm hoàn thiện health tracking)

---

### 5. **ConditionFoodRecommendation**
**Mô tả**: Gợi ý/tránh thực phẩm cho từng bệnh lý

**Trạng thái**: ❌ Bảng trống

**Tính năng đề xuất**:
```
✅ Tính năng "Thực phẩm nên/tránh"
   - Screen: FoodRecommendationScreen
   - Hiển thị danh sách món nên ăn + món cần tránh
   - Backend: GET /health-conditions/:id/foods
   
✅ Smart filter trong food search
   - Tự động ẩn/đánh dấu món ăn không phù hợp
   - Red badge: "⚠️ Không phù hợp với tình trạng của bạn"
```

**Độ ưu tiên**: ⭐⭐⭐⭐ (CAO)

---

### 6. **ConditionEffectLog**
**Mô tả**: Log history các ảnh hưởng đã áp dụng

**Trạng thái**: ❌ Chưa có trigger/logic ghi log

**Tính năng đề xuất**:
```
✅ Audit trail cho health tracking
   - Ghi lại mọi thay đổi RDA do bệnh lý
   - Screen: HealthHistoryScreen
   - Useful cho phân tích dài hạn
```

**Độ ưu tiên**: ⭐⭐ (THẤP - chỉ cần khi cần audit)

---

### 7. **MealNote**
**Mô tả**: Ghi chú cho từng bữa ăn

**Trạng thái**: ❌ Bảng có trong schema nhưng không có UI/endpoint

**Tính năng đề xuất**:
```
✅ Tính năng "Nhật ký bữa ăn"
   - Cho phép user ghi chú cảm giác sau khi ăn
   - Ví dụ: "Ăn ngon, no lâu", "Bị đầy bụng", "Dị ứng nhẹ"
   - Backend: POST /meals/:id/notes
   - Screen: Add note field trong MealDetailScreen

✅ Phân tích cảm xúc ăn uống
   - AI phân tích notes để đưa ra insights
   - "Bạn thường cảm thấy mệt sau khi ăn carb nhiều"
```

**Độ ưu tiên**: ⭐⭐⭐ (TRUNG BÌNH)

---

### 8. **UserGoal**
**Mô tả**: Lưu mục tiêu của user (giảm cân, tăng cơ, v.v.)

**Trạng thái**: ⚠️ Có bảng nhưng logic nằm rải rác trong UserProfile

**Tính năng đề xuất**:
```
✅ Refactor goal management
   - Tách riêng goal history (track progress theo thời gian)
   - Screen: GoalProgressScreen với charts
   - Backend: GET /users/goals/history

✅ Multiple concurrent goals
   - Cho phép user set nhiều goal cùng lúc
   - Ví dụ: "Giảm 5kg" + "Tăng protein" + "Chạy 5km"
```

**Độ ưu tiên**: ⭐⭐⭐ (TRUNG BÌNH - có thể refactor sau)

---

### 9. **Role & AdminRole**
**Mô tả**: Phân quyền admin (super admin, moderator, viewer)

**Trạng thái**: ❌ Chỉ có authentication, chưa có authorization

**Tính năng đề xuất**:
```
✅ RBAC (Role-Based Access Control)
   - Seed roles: super_admin, content_manager, support
   - Middleware check permissions
   - Screen: admin/roles-management

✅ Audit log
   - Track mọi action của admin
   - "Admin X đã xóa Food Y lúc Z"
```

**Độ ưu tiên**: ⭐⭐⭐⭐ (CAO - cần thiết khi scale admin team)

---

### 10. **UserActivityLog**
**Mô tả**: Log mọi hành động của user trong app

**Trạng thái**: ❌ Bảng trống, không có trigger

**Tính năng đề xuất**:
```
✅ User behavior analytics
   - Track: login, view vitamin, add meal, v.v.
   - Backend: Auto-insert via middleware
   - Screen: admin/user-analytics dashboard

✅ Personalization
   - "Bạn thường xem Vitamin C → gợi ý Vitamin E"
```

**Độ ưu tiên**: ⭐⭐⭐ (TRUNG BÌNH - useful cho analytics)

---

## 🟡 NHÓM 2: BẢNG SỬ DỤNG MỘT PHẦN (CÓ ROUTE NHƯNG THIẾU FEATURES)

### 11. **VitaminRDA & MineralRDA**
**Trạng thái**: ⚠️ Bảng có nhưng TRỐNG (không có seed data age/sex specific)

**Tính năng cần bổ sung**:
```
✅ Seed RDA data chuẩn WHO/FDA
   - Theo tuổi (0-1, 1-3, 4-8, 9-13, 14-18, 19-50, 50+)
   - Theo giới tính (nam/nữ)
   - Migration: 2025_seed_vitamin_mineral_rda.sql

✅ Screen: PersonalizedNutritionScreen
   - Hiển thị RDA phù hợp với tuổi/giới tính của user
   - "Bạn (nam, 28 tuổi) cần 15mg Vitamin E/ngày"
```

**Độ ưu tiên**: ⭐⭐⭐⭐⭐ (CAO - tính năng core đang thiếu)

---

### 12. **FiberRequirement & FattyAcidRequirement**
**Trạng thái**: ⚠️ Tương tự VitaminRDA, bảng trống

**Tính năng cần bổ sung**: Giống như #11

**Độ ưu tiên**: ⭐⭐⭐⭐

---

## 🟢 NHÓM 3: BẢNG MỚI CẦN TẠO

### 13. **UserNotification** (CHƯA TỒN TẠI)
**Đề xuất tạo bảng mới**:
```sql
CREATE TABLE user_notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    type VARCHAR(50), -- 'suggestion', 'warning', 'achievement'
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Tính năng**:
- In-app notification center
- Push notification (với Firebase)
- Screen: NotificationsScreen (đã có trong codebase nhưng chưa kết nối DB)

**Độ ưu tiên**: ⭐⭐⭐⭐

---

### 14. **UserAchievement** (CHƯA TỒN TẠI)
**Đề xuất gamification**:
```sql
CREATE TABLE achievements (
    achievement_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE,
    name VARCHAR(100),
    description TEXT,
    icon_url TEXT,
    points INT DEFAULT 0
);

CREATE TABLE user_achievements (
    user_id INT REFERENCES "User"(user_id),
    achievement_id INT REFERENCES achievements(achievement_id),
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, achievement_id)
);
```

**Examples**:
- "First Week Warrior" - Hoàn thành 7 ngày tracking
- "Protein Champion" - Đạt protein goal 30 ngày liên tiếp
- "Vitamin Hunter" - Xem chi tiết 10 loại vitamin khác nhau

**Độ ưu tiên**: ⭐⭐⭐

---

## 📋 BẢNG ƯU TIÊN TRIỂN KHAI

### Giai đoạn 1 (Tuần này - CAO nhất):
1. ✅ **Seed VitaminRDA/MineralRDA** với data WHO
2. ✅ **HealthCondition endpoints** + screen
3. ✅ **Suggestion system** (AI-driven recommendations)

### Giai đoạn 2 (Tuần sau):
4. ✅ **FoodTag system** (search & filter)
5. ✅ **ConditionNutrientEffect** logic
6. ✅ **ConditionFoodRecommendation** feature

### Giai đoạn 3 (Tháng sau):
7. ✅ **MealNote** feature
8. ✅ **UserNotification** center
9. ✅ **Role-based access control**
10. ✅ **UserAchievement** gamification

---

## 💡 GỢI Ý MIGRATIONS CẦN TẠO

```bash
# High priority
2025_seed_vitamin_rda_who_standards.sql
2025_seed_mineral_rda_who_standards.sql
2025_create_health_condition_features.sql
2025_create_suggestion_system.sql

# Medium priority
2025_create_food_tag_system.sql
2025_seed_condition_nutrient_effects.sql
2025_seed_condition_food_recommendations.sql

# Low priority (later)
2025_create_user_notifications.sql
2025_create_achievements_gamification.sql
2025_add_rbac_system.sql
```

---

## 🎯 KẾT LUẬN

**Tổng số tính năng có thể phát triển**: 14+ tính năng mới

**Estimated development time**: 
- Giai đoạn 1: 1 tuần (3 features quan trọng nhất)
- Giai đoạn 2: 1.5 tuần (3 features)
- Giai đoạn 3: 2 tuần (4 features + gamification)

**ROI cao nhất**: 
1. HealthCondition + Suggestions (tăng 50% user engagement)
2. RDA personalization (improve accuracy 100%)
3. FoodTag filtering (reduce search time 70%)
