# README — Chi tiết tính năng Backend

Phiên bản: 1.0
Ngày: 2025-12-13
Nguồn: phân tích `routes/`, `controllers/`, `services/` trong `backend/`

**Mục tiêu tài liệu:** liệt kê đầy đủ các tính năng hiện có, luồng chính, bảng/khả năng DB liên quan và nơi để mở rộng.

**LƯU Ý:** file này tạo từ phân tích mã hiện có; để kiểm tra sâu hơn hãy mở các file controller/service tương ứng.

**1. Kiến trúc tổng quan**
- Stack: Node.js + Express, PostgreSQL (pg), JWT auth.
- Tổ chức: `routes/` -> `controllers/` -> `services/` -> `db`.
- Migrations/Seed/DB helpers: `others/` chứa nhiều script (seed, audit, fix migrations).
- Static uploads: thư mục `uploads/` được serve tĩnh.

**2. Authentication & Authorization**
- File liên quan: `routes/auth.js`, `controllers/authController.js`, `services/securityService.js`, `services/roleService.js`.
- Tính năng:
  - Đăng ký / đăng nhập (email + password), hash bằng `bcryptjs`.
  - JWT generation/verification; middleware `authenticateToken` (gắn `req.user`).
  - Role-based access: admin routes & permission checks (roleController + permissions routes).
  - Admin invitation/verification flow: `adminVerificationService`, `create_admin`, `create_test_token` helpers.

**3. User profile và Settings**
- Bảng và cột: `User` bảng mở rộng nhiều cột (activity_level, diet_type, goal_weight, bmr, tdee, daily targets, last_login).
- `UserSetting` table: theme, language, unit_system, meal times, meal percentages, weather UI flags, background image, calorie/macro multipliers.
- Endpoints: `routes/settings.js`, `controllers/settingsController.js`, `services/settingService.js`.

**4. Food Catalog (Food / Dish / Drink)**
- Files: `routes/foods.js`, `controllers/dishController.js`, `drinkController.js`, `services/dishService.js`, `drinkService.js`.
- Tính năng:
  - CRUD cho food/dish/drink (admin & public endpoints khác nhau).
  - Nutrient data: `dishnutrient` / `drinknutrient` (amount_per_100g / amount_per_100ml).
  - Search & import helpers: `others/search_foods.js`, `add_missing_foods.js`, enrichment scripts for Vietnamese dishes.
  - Batch queries to avoid N+1 in nutrient fetch.

**5. Meal Management**
- Files: `routes/meals.js`, `routes/mealEntries.js`, `controllers/mealController.js`, `mealEntriesController.js`, `services/mealService.js`, `mealEntriesService.js`.
- Tính năng:
  - Tạo / sửa / xoá meal và meal entries.
  - Meal templates: `mealTemplateController`, `mealTemplateRoutes`.
  - Meal targets per day/meal (`user_meal_targets`) và meal summaries.
  - Meal history view, quick add endpoints, and summary aggregation.

**6. Daily Meal Suggestions / Smart Suggestions**
- Files: `routes/dailyMealSuggestions.js`, `controllers/dailyMealSuggestionController.js`, `services/dailyMealSuggestionService.js`, `routes/suggestions.js`, `smartSuggestionService.js`.
- Tính năng chính:
  - Generate full-day suggestions: compute RDA gaps, distribute per meal (breakfast 25%, lunch 35%, dinner 30%, snack 10%), filter contraindications, rank by score.
  - Scoring function: normalized coverage of nutrient gaps (example: sum(min(provided,gap)/gap)/count *100).
  - Endpoints: POST `/api/suggestions/daily-meals` (generate), GET `/api/suggestions/daily-meals` (fetch), PUT `/:id/accept`, PUT `/:id/reject`, DELETE `/:id`, cleanup endpoints (`/cleanup`, `/cleanup-passed`).
  - Persists suggestions to `user_daily_meal_suggestions` (or similar table).
  - Performance: candidate limiting (max N items), batch nutrient queries (`ANY($1)`), recommendation to cache dish scores or use materialized views.

**7. Nutrient Tracking & Requirement Tables**
- Files: `services/nutrientTrackingService.js`, `vitaminService.js`, `mineralService.js`, `aminoService.js`, `fattyService.js`, `fiberService.js`, `manualNutritionService.js`, `controllers/nutrientTrackingController.js`.
- Tính năng:
  - User-specific requirement tables: `UserVitaminRequirement`, `UserMineralRequirement`, `UserAminoRequirement`, `UserFiberRequirement`, `UserFattyAcidRequirement`.
  - Mapping tables: `vitaminnutrient`, `mineralnutrient` to map vitamins/minerals → nutrient IDs.
  - Manual nutrient logs (`UserNutrientManualLog`) with unique constraint to support upsert.
  - Daily nutrient aggregation and tracking endpoints.

**8. Health Conditions & Food Restrictions**
- Files: `routes/health.js`, `controllers/healthConditionController.js`, `services/healthConditionService.js`.
- Tính năng:
  - Admin CRUD for `healthcondition` catalog (condition_code, name, category, severity, icd_code).
  - User-level: add user health conditions (`userhealthcondition`), status, diagnosed_date, notes.
  - Contraindications: `foodhealthcondition` to mark foods incompatible with certain conditions; `drugnutrientcontraindication` for drug-nutrient rules.
  - Endpoints: get user adjusted RDA, get restricted foods, add nutrient effects for conditions.

**9. Medication & Scheduling**
- Files: `controllers/medicationController.js`, `services/medicationService.js`.
- Tính năng:
  - `usermedication` table: medication_name, dosage, frequency, start/end_date, status.
  - `medicationlog` table: logs of taken meds; `medicationschedule` for schedule times.
  - Endpoints: get today meds, mark taken, get stats, calendar dates, logs.

**10. Body Measurements & Water Tracking**
- Files: `controllers/bodyMeasurementController.js`, `services/bodyMeasurementService.js`, `controllers/waterController.js`, `waterService.js`.
- Tính năng:
  - Track weight, waist, body fat, latest & historical endpoints, statistics.
  - `WaterLog` table and `DailySummary.total_water` column; upsert constraints for per-user date.
  - Water period tracking via `waterPeriodController`.

**11. Recipes & Portions**
- Files: `recipeRoutes.js`, `recipes.js`, `recipeController.js`, `portionController.js`, `portionRoutes.js`, `portions.js`.
- Tính năng:
  - Recipe CRUD, mapping recipe ingredients to food items, nutrient calculation per recipe.
  - Portion helpers for converting grams/ml to servings.

**12. Social & Chat System**
- Files: `routes/chatRoutes.js`, `controllers/chatController.js`, `controllers/adminChatController.js`, `controllers/socialController.js`.
- Tính năng:
  - Conversations, messages, community feeds, private messages, admin chat.
  - Timezone handling: controllers were patched to return ISO timestamps with "+07:00" and ORDER BY converted timestamps.

**13. Image Upload & AI Analysis**
- Files: `controllers/imageUploadController.js`, `aiAnalysisController.js`, `routes/aiAnalysis.js`, `uploadController.js`.
- Tính năng:
  - Image upload via `multer`, large JSON body support for base64 images.
  - AI endpoints for image analysis (food recognition, portion estimate skeletons present).

**14. Admin / Debug / Utilities**
- Files: `controllers/adminController.js`, `adminActivityController.js`, `adminDashboardController.js`, `routes/admin.js`, `others/` scripts.
- Tính năng:
  - Admin dashboard endpoints, activity logs, admin chat, import scripts, seed scripts, DB audit scripts (`comprehensive_audit.js`, `database_status_report.js`).
  - Helpers to ensure schema columns/tables on startup (safe alters in `others/index.js`).

**15. Testing & Scripts**
- Tests present: `test_daily_meal_suggestion.js`, `test_daily_meal_api.js`, others in `tests/`.
- Scripts: seeding (`seed_basic_data.js`, `seed_everything.js`), migration helpers, troubleshooting scripts (`debug_fks.js`).

**16. Security & Data Integrity**
- Ownership verification before sensitive actions (accept/reject/delete suggestions).
- DB unique constraints and indexes enforced by startup scripts.
- Email / token utilities in `others/` (create_test_token, get_token).

---

**Phần cuối — Bản đồ nơi tìm logic cụ thể**
- Scoring & suggestion algorithm: `backend/services/dailyMealSuggestionService.js` (mở file để đọc chi tiết thuật toán).
- Request → Controller mapping: `backend/routes/*` → `backend/controllers/*Controller.js`.
- Database-safe migrations & fixes: `backend/others/*` (chạy thủ công hoặc script khi cần).

**Gợi ý bước tiếp theo (tùy chọn)**
- Muốn tôi: 1) tạo README module cho `dailyMealSuggestionService`, 2) viết migration SQL cho `PantryItem` + shopping list, hoặc 3) implement basic `drug_nutrient_interactions` table + check on suggestion accept — chọn 1/2/3.

File đã được lưu vào: `backend/README_FEATURES_DETAILED.md`.
