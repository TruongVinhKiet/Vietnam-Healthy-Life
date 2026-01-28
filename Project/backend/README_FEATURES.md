# README — Tổng hợp tính năng Backend

Phiên bản: 1.0
Ngày tạo: 2025-12-13

## Mục đích
Tài liệu này tóm tắt nhanh các tính năng hiện có của backend trong dự án, cách chạy nhanh, các route và nơi để mở rộng. Dành cho developer mới hoặc khi cần roadmap nhanh để xây tính năng mới.

## Chạy nhanh (dev)
- Cài node packages:

```bash
cd Project/backend
npm install
```

- Chạy server (dev):

```bash
npm run dev
# hoặc
node index.js
```

- Biến môi trường: copy `.env` vào `backend/.env` và set `PORT`, `DATABASE_URL`.

## Kiến trúc tóm tắt
- Node.js + Express
- PostgreSQL (pg)
- Cấu trúc theo module: `routes/` → `controllers/` → `services/`
- Các script & migration helper nằm trong `others/`

## Nhóm chức năng chính
1. Authentication & Authorization
   - JWT / `auth` routes, `authController`, `roleService`.
2. Food & Nutrition Catalog
   - `foods`, `dishes`, `drinks` cùng các bảng dinh dưỡng (dishnutrient, drinknutrient).
3. Meal Management
   - Meal creation, `meal_entries`, `meal_targets`, templates, history.
4. Daily Meal Suggestions / Smart Suggestions
   - Service `dailyMealSuggestionService.js` + controller + routes `/api/suggestions/daily-meals`.
   - Tính toán gap RDA, phân bổ theo bữa, lọc chống chỉ định, scoring.
5. Nutrient Tracking & Manual Logs
   - Vitamins, minerals, amino acids, fatty acids, fiber, manual nutrient logs.
6. Health Conditions & Medication
   - Lưu health conditions, usermedication, medication logs/schedules, drug interaction hooks.
7. Body & Water Tracking
   - Body measurements, water logs, periods.
8. Recipes / Portions
   - Recipe builder, portion helper.
9. Social & Chat
   - Community messages, private chat, admin chat. (Đã có chỉnh timezone)
10. Image Upload & AI Analysis
   - Upload endpoints và image analysis (`aiAnalysisController`).
11. Admin / Debug / Utilities
   - Import, seeding, audit, debug endpoints in `others/`.

## Các route quan trọng (tổng quan)
- Auth: `/auth`
- Users/Admin: `/admin`, `/settings`
- Foods/Dishes/Drinks: `/foods`, `/dishes`, `/drinks`, `/admin/foods`
- Meals: `/meals`, `/meal-entries`, `/meal-history`, `/meal-templates`
- Suggestions: `/api/suggestions/daily-meals`, `/api/smart-suggestions`
- Nutrients: `/vitamins`, `/minerals`, `/amino_acids`, `/fatty-acids`, `/fibers`
- Health/Medication: `/health`, `/medications`
- Chat/Social: `/chat`, `/social`, `/admin/chat`
- AI/Image: `/api` (AI analysis)
- Debug: `/debug`

## Nơi chứa logic quan trọng
- Business logic chính: `backend/services/dailyMealSuggestionService.js`
- Controller layer: `backend/controllers/*Controller.js`
- Route registration: `backend/others/index.js` và `backend/routes/*`
- DB helpers / migration scripts: `backend/others/` (seed & fix scripts)

## Best practices & Notes
- Các service trả về dữ liệu đã kiểm tra ownership; mọi route quan trọng bảo vệ bằng middleware `authenticateToken`.
- Các migration helper trong `others/` thường tự đảm bảo column/table tồn tại (safe to run on startup).
- Tránh N+1: đã áp dụng batch queries (ANY($1)) trong các nơi tốn chi phí (dish nutrient queries).
- Chat timezone: đã sửa ở controller + migrations (format ISO+07:00) — kiểm tra client Flutter để parse đúng.

## Gợi ý mở rộng nhanh (ý tưởng triển khai nhanh, "ăn điểm")
- Thêm `PantryItem` + `weeklyPlannerService` để tạo shopping list từ gợi ý.
- Cải tiến Image Portion Estimator: endpoint `/api/ai/portion-estimate`.
- Drug–Nutrient Interaction engine: bảng `drug_nutrient_interactions` + check khi accept suggestion.
- Simple bandit feedback: dùng accept/reject làm reward để tune scorer (offline trainer / Redis store).

## Các bước tiếp theo đề xuất
- Thêm README module cho `dailyMealSuggestionService` (chi tiết API và thuật toán scoring).
- Tạo migration SQL cho `PantryItem` nếu muốn feature shopping list.
- Thực hiện tích hợp test cho endpoints mới (thêm test file vào `tests/`).

---
Tài liệu này được tạo tự động từ cấu trúc `backend/routes`, `backend/controllers`, `backend/services`.

Nếu bạn muốn, tôi có thể:
- (A) Ghi file README này vào repo (đã tạo tại `backend/README_FEATURES.md`).
- (B) Mở rộng phần hướng dẫn deploy hoặc viết migration skeleton cho feature bạn chọn.

Chọn A hoặc B (và nếu B, cho biết feature sẽ triển khai đầu tiên).