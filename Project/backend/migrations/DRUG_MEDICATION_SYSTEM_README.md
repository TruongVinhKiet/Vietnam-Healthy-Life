# Hệ Thống Quản Lý Thuốc & Cảnh Báo Tương Tác Thuốc-Dinh Dưỡng

## Tổng Quan

Tính năng này cho phép:
- **Admin**: Quản lý thuốc, liên kết với bệnh, cấu hình tác dụng phụ (tương tác với chất dinh dưỡng)
- **User**: Chọn thuốc khi uống, nhận cảnh báo real-time khi thêm meal/drink có chất dinh dưỡng kỵ với thuốc đã uống

## Cấu Trúc Database

### Bảng Mới

1. **Drug** - Bảng quản lý thuốc
   - `drug_id`, `name_vi`, `name_en`, `generic_name`, `drug_class`
   - `description`, `image_url`, `source_link`, `dosage_form`
   - `is_active`, `created_by_admin`

2. **DrugHealthCondition** - Liên kết thuốc với bệnh
   - `drug_id`, `condition_id`, `is_primary`, `treatment_notes`

3. **DrugNutrientContraindication** - Tác dụng phụ (tương tác)
   - `drug_id`, `nutrient_id`
   - `avoid_hours_before`, `avoid_hours_after` (số giờ cần tránh)
   - `warning_message_vi`, `warning_message_en`, `severity`

### Bảng Cập Nhật

- **MedicationSchedule**: Thêm `drug_id`
- **MedicationLog**: Thêm `drug_id`

## Functions & Views

1. **check_drug_nutrient_interaction()** - Kiểm tra tương tác real-time
2. **get_drugs_for_condition()** - Lấy danh sách thuốc cho một bệnh
3. **get_medication_history_stats()** - Thống kê lịch sử uống thuốc
4. **DrugStatistics** - View thống kê thuốc cho admin

## Cách Chạy Migration

### Bước 1: Chạy migration tạo bảng

```bash
psql -U your_user -d your_database -f my_diary/backend/migrations/2025_drug_medication_system.sql
```

Hoặc trong Node.js:
```javascript
const db = require('./db');
const fs = require('fs');
const sql = fs.readFileSync('./migrations/2025_drug_medication_system.sql', 'utf8');
await db.query(sql);
```

### Bước 2: Chạy seed data

```bash
psql -U your_user -d your_database -f my_diary/backend/migrations/2025_seed_drug_medication_data.sql
```

## API Endpoints

### Admin Endpoints

#### GET `/api/admin/drugs`
- Liệt kê tất cả thuốc (có phân trang, tìm kiếm)
- Query params: `search`, `is_active`, `page`, `limit`
- Role: `content_manager`, `analyst`

#### GET `/api/admin/drugs/stats`
- Thống kê số lượng thuốc
- Role: Tất cả admin

#### GET `/api/admin/drugs/:id`
- Chi tiết thuốc (bao gồm conditions, contraindications)
- Role: `content_manager`, `analyst`

#### POST `/api/admin/drugs`
- Tạo thuốc mới
- Body:
```json
{
  "name_vi": "Tetracycline",
  "name_en": "Tetracycline",
  "generic_name": "Tetracycline Hydrochloride",
  "drug_class": "Antibiotic",
  "description": "...",
  "image_url": "...",
  "source_link": "...",
  "dosage_form": "Viên nang",
  "is_active": true,
  "condition_ids": [
    {
      "condition_id": 1,
      "is_primary": true,
      "treatment_notes": "..."
    }
  ],
  "contraindications": [
    {
      "nutrient_id": 123,
      "avoid_hours_before": 2,
      "avoid_hours_after": 2,
      "warning_message_vi": "Tránh canxi trong 2 giờ",
      "warning_message_en": "Avoid calcium for 2 hours",
      "severity": "severe"
    }
  ]
}
```
- Role: `content_manager`

#### PUT `/api/admin/drugs/:id`
- Cập nhật thuốc
- Body: Tương tự POST
- Role: `content_manager`

#### DELETE `/api/admin/drugs/:id`
- Xóa thuốc (chỉ khi không được sử dụng trong MedicationSchedule)
- Role: `content_manager`

### User Endpoints

#### GET `/api/medications/conditions/:conditionId/drugs`
- Lấy danh sách thuốc điều trị một bệnh
- Auth: User token

#### POST `/api/medications/log`
- Ghi nhận đã uống thuốc
- Body:
```json
{
  "drug_id": 1,
  "user_condition_id": 5,
  "medication_date": "2025-11-23",
  "medication_time": "07:00:00"
}
```
- Auth: User token

#### GET `/api/medications/check-interaction`
- Kiểm tra tương tác khi thêm meal/drink
- Query params:
  - `meal_time`: ISO timestamp
  - `food_ids`: Comma-separated food IDs (optional)
  - `drink_id`: Drink ID (optional)
- Response:
```json
{
  "success": true,
  "has_interaction": true,
  "interactions": [
    {
      "drug_id": 9,
      "drug_name_vi": "Tetracycline",
      "nutrient_id": 123,
      "nutrient_name": "Calcium",
      "warning_message_vi": "Bạn vừa uống thuốc...",
      "severity": "severe",
      "medication_time": "2025-11-23T07:00:00Z"
    }
  ]
}
```
- Auth: User token

#### GET `/api/medications/history/stats`
- Thống kê lịch sử uống thuốc
- Query params: `start_date`, `end_date` (optional)
- Auth: User token

#### GET `/api/medications/schedule`
- Lấy lịch uống thuốc của user
- Query params: `date` (optional, default: today)
- Auth: User token

## Cập Nhật Dashboard Stats

Dashboard stats đã được cập nhật để bao gồm `total_drugs`:
- GET `/api/admin/dashboard/stats` trả về thêm `total_drugs`

## Dữ Liệu Mẫu

File seed bao gồm:
- 15 thuốc mẫu (Metformin, Amlodipine, Atorvastatin, Tetracycline, v.v.)
- Liên kết với các bệnh trong HealthCondition
- Tác dụng phụ thực tế (Tetracycline kỵ Canxi, v.v.)
- Thực phẩm giàu canxi (sữa, sữa chua, phô mai, cá mòi)
- Đồ uống giàu canxi (sữa tươi, sữa đậu nành)
- Món ăn giàu canxi (mì Ý sốt phô mai, súp kem)

## Workflow

### Admin Workflow

1. Admin tạo thuốc mới:
   - Nhập thông tin thuốc (tên, mô tả, hình ảnh)
   - Chọn bệnh điều trị (từ HealthCondition)
   - Thêm tác dụng phụ:
     - Click "+" để chọn nutrient cần tránh
     - Chọn số giờ cần tránh (trước và sau khi uống)
     - Nhập thông báo cảnh báo

### User Workflow

1. User có bệnh X → Hệ thống hiển thị danh sách thuốc điều trị
2. User chọn thuốc Y và bấm "Uống thuốc"
3. User thêm meal/drink:
   - Hệ thống gọi `/api/medications/check-interaction`
   - Nếu có tương tác → Hiển thị cảnh báo đỏ
   - Ví dụ: "Bạn vừa uống thuốc Tetracycline. Không nên uống sữa trong vòng 2 giờ tới vì canxi làm mất tác dụng thuốc."

## Frontend Integration

### Admin Dashboard

1. **Statistics Card**: Hiển thị `total_drugs`
2. **Drug Management Page**:
   - List drugs với search, filter
   - Create/Edit drug form:
     - Basic info
     - Condition selection (multi-select với is_primary checkbox)
     - Contraindications section:
       - "+" button để thêm nutrient
       - Time picker cho avoid_hours_before/after
       - Warning message input

### User Health Page

1. **Medication Button Enhancement**:
   - Trước khi bấm "Uống thuốc" → Hiển thị modal chọn thuốc
   - Dropdown danh sách thuốc cho bệnh hiện tại
   - Sau khi chọn → Gọi POST `/api/medications/log`

2. **Warning System**:
   - Khi user thêm meal/drink → Gọi GET `/api/medications/check-interaction`
   - Nếu `has_interaction = true` → Hiển thị alert/notification đỏ
   - Hiển thị danh sách interactions với severity

3. **Medication History**:
   - Tab thống kê lịch sử uống thuốc
   - Gọi GET `/api/medications/history/stats`
   - Hiển thị: total_taken, total_skipped, on_time_count, late_count

## Notes

- Function `check_drug_nutrient_interaction` kiểm tra trong vòng +/- 2 giờ (hoặc theo cấu hình)
- Tất cả timestamps sử dụng TIMEZONE-aware
- Drug không thể xóa nếu đang được sử dụng trong MedicationSchedule (nên deactivate thay vì xóa)

## Testing

1. Chạy migrations
2. Seed data
3. Test admin endpoints (tạo, sửa, xóa thuốc)
4. Test user endpoints (chọn thuốc, log medication, check interaction)
5. Test real-time warning khi thêm meal/drink

