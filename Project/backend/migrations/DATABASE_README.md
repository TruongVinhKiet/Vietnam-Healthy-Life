# TÀI LIỆU CƠ SỞ DỮ LIỆU - MY DIARY APP

Tài liệu này mô tả tất cả các bảng và cột trong cơ sở dữ liệu của ứng dụng My Diary.

**Tổng số bảng:** 81

---

## MỤC LỤC

1. [Admin](#admin)
2. [AdminConversation](#adminconversation)
3. [AdminMessage](#adminmessage)
4. [AdminRole](#adminrole)
5. [AminoAcid](#aminoacid)
6. [AminoRequirement](#aminorequirement)
7. [BodyMeasurement](#bodymeasurement)
8. [ChatbotConversation](#chatbotconversation)
9. [ChatbotMessage](#chatbotmessage)
10. [ConditionEffectLog](#conditioneffectlog)
11. [ConditionFoodRecommendation](#conditionfoodrecommendation)
12. [ConditionNutrientEffect](#conditionnutrienteffect)
13. [DailySummary](#dailysummary)
14. [Dish](#dish)
15. [DishImage](#dishimage)
16. [DishIngredient](#dishingredient)
17. [DishNutrient](#dishnutrient)
18. [DishStatistics](#dishstatistics)
19. [Drink](#drink)
20. [DrinkIngredient](#drinkingredient)
21. [DrinkNutrient](#drinknutrient)
22. [DrinkStatistics](#drinkstatistics)
23. [FattyAcid](#fattyacid)
24. [FattyAcidRequirement](#fattyacidrequirement)
25. [Fiber](#fiber)
26. [FiberRequirement](#fiberrequirement)
27. [Food](#food)
28. [FoodCategory](#foodcategory)
29. [FoodNutrient](#foodnutrient)
30. [FoodTag](#foodtag)
31. [FoodTagMapping](#foodtagmapping)
32. [HealthCondition](#healthcondition)
33. [Meal](#meal)
34. [MealItem](#mealitem)
35. [MealNote](#mealnote)
36. [MealTemplate](#mealtemplate)
37. [MealTemplateItem](#mealtemplateitem)
38. [MedicationLog](#medicationlog)
39. [MedicationSchedule](#medicationschedule)
40. [Mineral](#mineral)
41. [MineralNutrient](#mineralnutrient)
42. [MineralRDA](#mineralrda)
43. [Nutrient](#nutrient)
44. [NutrientContraindication](#nutrientcontraindication)
45. [NutrientMapping](#nutrientmapping)
46. [NutritionAnalysis](#nutritionanalysis)
47. [PasswordChangeCode](#passwordchangecode)
48. [PortionSize](#portionsize)
49. [Recipe](#recipe)
50. [RecipeIngredient](#recipeingredient)
51. [Role](#role)
52. [Suggestion](#suggestion)
53. [User](#user)
54. [UserActivityLog](#useractivitylog)
55. [UserAminoIntake](#useraminointake)
56. [UserAminoRequirement](#useraminorequirement)
57. [UserFattyAcidIntake](#userfattyacidintake)
58. [UserFattyAcidRequirement](#userfattyacidrequirement)
59. [UserFiberIntake](#userfiberintake)
60. [UserFiberRequirement](#userfiberrequirement)
61. [UserGoal](#usergoal)
62. [UserHealthCondition](#userhealthcondition)
63. [UserMineralRequirement](#usermineralrequirement)
64. [UserNutrientNotification](#usernutrientnotification)
65. [UserNutrientTracking](#usernutrienttracking)
66. [UserProfile](#userprofile)
67. [UserSecurity](#usersecurity)
68. [UserSetting](#usersetting)
69. [UserVitaminRequirement](#uservitaminrequirement)
70. [Vitamin](#vitamin)
71. [VitaminNutrient](#vitaminnutrient)
72. [VitaminRDA](#vitaminrda)
73. [dishnotification](#dishnotification)
74. [meal_entries](#meal_entries)
75. [permission](#permission)
76. [rolepermission](#rolepermission)
77. [user_account_status](#user_account_status)
78. [user_block_event](#user_block_event)
79. [user_meal_summaries](#user_meal_summaries)
80. [user_meal_targets](#user_meal_targets)
81. [user_unblock_request](#user_unblock_request)

---

## Admin

**Mô tả:** Bảng quản lý tài khoản admin

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `admin_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `username` | Chuỗi ký tự có độ dài giới hạn (50) | Tên | UNIQUE, NOT NULL |
| `password_hash` | Chuỗi ký tự không giới hạn | Mật khẩu | NOT NULL |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `is_deleted` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |

---

## AdminConversation

**Mô tả:** Bảng lưu cuộc hội thoại với admin

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `admin_conversation_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `status` | Chuỗi ký tự có độ dài giới hạn (20) | Trạng thái | DEFAULT |
| `subject` | Chuỗi ký tự có độ dài giới hạn (200) | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## AdminMessage

**Mô tả:** Bảng lưu tin nhắn với admin

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `admin_message_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `admin_conversation_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `sender_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `sender_id` | Số nguyên | ID định danh | NOT NULL |
| `message_text` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `is_read` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## AdminRole

**Mô tả:** Bảng liên kết admin và vai trò

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `admin_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `role_id` | Số nguyên | ID định danh | FOREIGN KEY |

---

## AminoAcid

**Mô tả:** Bảng lưu thông tin axit amin

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `amino_acid_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `code` | Chuỗi ký tự có độ dài giới hạn (32) | Cột chưa có mô tả | UNIQUE, NOT NULL |
| `name` | Chuỗi ký tự có độ dài giới hạn (128) | Tên | NOT NULL |
| `hex_color` | Chuỗi ký tự có độ dài giới hạn (7) | Cột chưa có mô tả | NOT NULL |
| `home_display` | Giá trị logic (true/false) | Cột chưa có mô tả | NOT NULL, DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## AminoRequirement

**Mô tả:** Bảng lưu yêu cầu axit amin theo độ tuổi và giới tính

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `amino_requirement_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `amino_acid_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `sex` | Chuỗi ký tự có độ dài giới hạn (16) | Cột chưa có mô tả | DEFAULT |
| `age_min` | Số nguyên | Tuổi | - |
| `age_max` | Số nguyên | Tuổi | - |
| `per_kg` | Giá trị logic (true/false) | Cột chưa có mô tả | NOT NULL, DEFAULT |
| `amount` | NUMERIC NOT NULL | Lượng | NOT NULL |
| `unit` | Chuỗi ký tự có độ dài giới hạn (16) | Đơn vị | DEFAULT |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## BodyMeasurement

**Mô tả:** Bảng lưu đo lường cơ thể

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `measurement_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `measurement_date` | Ngày giờ | Ngày | DEFAULT |
| `weight_kg` | Số thập phân (5) | Cân nặng | - |
| `height_cm` | Số thập phân (5) | Chiều cao | - |
| `bmi` | Số thập phân (4) | Cột chưa có mô tả | - |
| `bmi_score` | Số nguyên | Cột chưa có mô tả | - |
| `bmi_category` | Chuỗi ký tự có độ dài giới hạn (20) | Danh mục | - |
| `source` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | DEFAULT |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## ChatbotConversation

**Mô tả:** Bảng lưu cuộc hội thoại với chatbot

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `conversation_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `title` | Chuỗi ký tự có độ dài giới hạn (200) | Cột chưa có mô tả | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## ChatbotMessage

**Mô tả:** Bảng lưu tin nhắn trong cuộc hội thoại

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `message_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `conversation_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `sender` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `message_text` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `nutrition_data` | Dữ liệu JSON | Cột chưa có mô tả | - |
| `is_approved` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## ConditionEffectLog

**Mô tả:** Bảng log thay đổi RDA do bệnh

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `log_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `condition_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `effect_type` | Chuỗi ký tự có độ dài giới hạn (10) | Cột chưa có mô tả | - |
| `adjustment_percent` | Số thập phân (5) | Cột chưa có mô tả | - |
| `original_rda` | Số thập phân (10) | Cột chưa có mô tả | - |
| `adjusted_rda` | Số thập phân (10) | Cột chưa có mô tả | - |
| `applied_at` | Ngày giờ | Cột chưa có mô tả | DEFAULT |

---

## ConditionFoodRecommendation

**Mô tả:** Bảng lưu thực phẩm nên ăn/tránh cho từng bệnh

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `recommendation_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `condition_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `recommendation_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## ConditionNutrientEffect

**Mô tả:** Bảng lưu hiệu ứng dinh dưỡng của từng bệnh

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `effect_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `condition_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `effect_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `adjustment_percent` | Số nguyên | Cột chưa có mô tả | NOT NULL |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## DailySummary

**Mô tả:** Bảng tổng hợp dinh dưỡng hàng ngày

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `summary_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `date` | Ngày tháng | Ngày | NOT NULL |
| `total_calories` | Số thập phân (10) | Tổng | - |
| `total_protein` | Số thập phân (10) | Tổng | - |
| `total_fiber` | Số thập phân (10) | Tổng | - |
| `total_carbs` | Số thập phân (10) | Tổng | - |
| `total_fat` | Số thập phân (10) | Tổng | - |

---

## Dish

**Mô tả:** Bảng lưu thông tin món ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `dish_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | NOT NULL |
| `vietnamese_name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | - |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `category` | Chuỗi ký tự có độ dài giới hạn (50) | Danh mục | - |
| `serving_size_g` | Số thập phân (10) | Cột chưa có mô tả | - |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `is_template` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `is_public` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_by_user` | Số nguyên | Người tạo | FOREIGN KEY |
| `created_by_admin` | Số nguyên | Người tạo | FOREIGN KEY |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## DishImage

**Mô tả:** Bảng lưu hình ảnh món ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `dish_image_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `dish_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | NOT NULL |
| `image_type` | Chuỗi ký tự có độ dài giới hạn (20) | Tuổi | DEFAULT |
| `is_primary` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `display_order` | Số nguyên | Thứ tự hiển thị | DEFAULT |
| `caption` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `uploaded_at` | Ngày giờ | Cột chưa có mô tả | DEFAULT |

---

## DishIngredient

**Mô tả:** Bảng lưu nguyên liệu trong món ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `dish_ingredient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `dish_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `weight_g` | Số thập phân (10) | Cân nặng | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `display_order` | Số nguyên | Thứ tự hiển thị | DEFAULT |

---

## DishNutrient

**Mô tả:** Bảng lưu dinh dưỡng của món ăn (tính trên 100g)

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `dish_nutrient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `dish_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `amount_per_100g` | Số thập phân (12) | Lượng | - |
| `calculated_at` | Ngày giờ | Cột chưa có mô tả | DEFAULT |

---

## DishStatistics

**Mô tả:** Bảng lưu thống kê món ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `stat_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `dish_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `total_times_logged` | Số nguyên | Thời gian | DEFAULT |
| `avg_rating` | Số thập phân (3) | Cột chưa có mô tả | - |
| `last_logged_at` | Ngày giờ | Cột chưa có mô tả | - |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## Drink

**Mô tả:** Bảng lưu thông tin đồ uống

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `drink_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | NOT NULL |
| `vietnamese_name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | - |
| `slug` | Chuỗi ký tự có độ dài giới hạn (120) | Đường dẫn URL thân thiện | UNIQUE |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `category` | Chuỗi ký tự có độ dài giới hạn (50) | Danh mục | - |
| `base_liquid` | Chuỗi ký tự có độ dài giới hạn (100) | Chất lỏng cơ bản | - |
| `default_volume_ml` | Số thập phân (10) | Thể tích mặc định (ml) | DEFAULT |
| `default_temperature` | Chuỗi ký tự có độ dài giới hạn (20) | Nhiệt độ mặc định | DEFAULT |
| `default_sweetness` | Chuỗi ký tự có độ dài giới hạn (20) | Độ ngọt mặc định | DEFAULT |
| `hydration_ratio` | Số thập phân (5) | Tỷ lệ hydrat hóa | - |
| `caffeine_mg` | Số thập phân (8) | Lượng caffeine (mg) | - |
| `sugar_free` | Giá trị logic (true/false) | Không đường | DEFAULT |
| `is_template` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `is_public` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `created_by_user` | Số nguyên | Người tạo | FOREIGN KEY |
| `created_by_admin` | Số nguyên | Người tạo | FOREIGN KEY |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ có múi giờ | Thời điểm cập nhật | DEFAULT |

---

## DrinkIngredient

**Mô tả:** Bảng lưu nguyên liệu trong đồ uống

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `drink_ingredient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `drink_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `amount_g` | Số thập phân (10) | Lượng | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (16) | Đơn vị | DEFAULT |
| `display_order` | Số nguyên | Thứ tự hiển thị | DEFAULT |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## DrinkNutrient

**Mô tả:** Bảng lưu dinh dưỡng của đồ uống (tính trên 100ml)

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `drink_nutrient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `drink_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `amount_per_100ml` | Số thập phân (12) | Lượng | - |

---

## DrinkStatistics

**Mô tả:** Bảng lưu thống kê đồ uống

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `stat_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `drink_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `log_count` | Số nguyên | Cột chưa có mô tả | DEFAULT |
| `last_logged_at` | Ngày giờ có múi giờ | Cột chưa có mô tả | - |
| `updated_at` | Ngày giờ có múi giờ | Thời điểm cập nhật | DEFAULT |

---

## FattyAcid

**Mô tả:** Bảng lưu thông tin axit béo

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `fatty_acid_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `code` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | UNIQUE, NOT NULL |
| `name` | Chuỗi ký tự có độ dài giới hạn (150) | Tên | NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | DEFAULT |
| `hex_color` | Chuỗi ký tự có độ dài giới hạn (7) | Cột chưa có mô tả | - |
| `home_display` | Giá trị logic (true/false) | Cột chưa có mô tả | DEFAULT |
| `is_user_editable` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## FattyAcidRequirement

**Mô tả:** Bảng lưu yêu cầu axit béo theo độ tuổi và giới tính

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `fa_req_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `fatty_acid_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `sex` | Chuỗi ký tự có độ dài giới hạn (10) | Cột chưa có mô tả | - |
| `age_min` | Số nguyên | Tuổi | - |
| `age_max` | Số nguyên | Tuổi | - |
| `base_value` | Số thập phân (12) | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | DEFAULT |
| `is_per_kg` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `is_energy_pct` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `energy_pct` | Số thập phân (6) | Cột chưa có mô tả | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## Fiber

**Mô tả:** Bảng lưu thông tin chất xơ

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `fiber_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `code` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | UNIQUE, NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## FiberRequirement

**Mô tả:** Bảng lưu yêu cầu chất xơ theo độ tuổi và giới tính

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `requirement_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `fiber_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `sex` | Chuỗi ký tự có độ dài giới hạn (10) | Cột chưa có mô tả | NOT NULL |
| `age_min` | Số nguyên | Tuổi | NOT NULL |
| `age_max` | Số nguyên | Tuổi | NOT NULL |
| `rda_value` | Số thập phân (10) | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (10) | Đơn vị | DEFAULT |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## Food

**Mô tả:** Bảng lưu thông tin thực phẩm

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `food_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `category` | Chuỗi ký tự có độ dài giới hạn (50) | Danh mục | - |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `created_by_admin` | Số nguyên | Người tạo | FOREIGN KEY |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `name_vi` | Chuỗi ký tự không giới hạn | Tên | - |

---

## FoodCategory

**Mô tả:** Bảng lưu danh mục thực phẩm

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `category_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | UNIQUE, NOT NULL |
| `name_vi` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | - |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## FoodNutrient

**Mô tả:** Bảng liên kết thực phẩm và chất dinh dưỡng (lượng dinh dưỡng trong 100g)

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `food_nutrient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `amount_per_100g` | Số thập phân (10) | Lượng | - |

---

## FoodTag

**Mô tả:** Bảng quản lý nhãn/tag cho thực phẩm

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `tag_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `tag_name` | Chuỗi ký tự có độ dài giới hạn (50) | Tên | NOT NULL |

---

## FoodTagMapping

**Mô tả:** Bảng liên kết thực phẩm và tag

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `tag_id` | Số nguyên | ID định danh | FOREIGN KEY |

---

## HealthCondition

**Mô tả:** Bảng lưu danh sách các bệnh/tình trạng sức khỏe

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `condition_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name_en` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | NOT NULL |
| `name_vi` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `severity` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## Meal

**Mô tả:** Bảng lưu thông tin bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `meal_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `meal_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | - |
| `meal_date` | Ngày tháng | Ngày | NOT NULL |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `is_favorite` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `photo_url` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |

---

## MealItem

**Mô tả:** Bảng lưu các món ăn trong bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `meal_item_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `meal_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `weight_g` | Số thập phân (10) | Cân nặng | - |
| `dish_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `quick_add_count` | Số nguyên | Cột chưa có mô tả | DEFAULT |
| `calories` | Số thập phân (10) | Cột chưa có mô tả | - |

---

## MealNote

**Mô tả:** Bảng lưu ghi chú cho bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `note_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `meal_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `note` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## MealTemplate

**Mô tả:** Bảng lưu mẫu bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `template_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `template_name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `meal_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | - |
| `is_favorite` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `usage_count` | Số nguyên | Tuổi | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## MealTemplateItem

**Mô tả:** Bảng lưu các món trong mẫu bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `template_item_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `template_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `weight_g` | Số thập phân (10) | Cân nặng | - |
| `item_order` | Số nguyên | Cột chưa có mô tả | DEFAULT |

---

## MedicationLog

**Mô tả:** Bảng lưu lịch sử uống thuốc hàng ngày

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `log_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_condition_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `medication_date` | Ngày tháng | Ngày | NOT NULL |
| `medication_time` | Giờ | Thời gian | NOT NULL |
| `taken_at` | Ngày giờ | Cột chưa có mô tả | - |
| `status` | Chuỗi ký tự có độ dài giới hạn (20) | Trạng thái | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## MedicationSchedule

**Mô tả:** Bảng lưu lịch uống thuốc

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `medication_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_condition_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `medication_details` | Dữ liệu JSON | Cột chưa có mô tả | DEFAULT |

---

## Mineral

**Mô tả:** Bảng lưu thông tin khoáng chất

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `mineral_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `code` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | UNIQUE, NOT NULL |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | DEFAULT |
| `recommended_daily` | Số thập phân (10) | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `created_by_admin` | Số nguyên | Người tạo | FOREIGN KEY |

---

## MineralNutrient

**Mô tả:** Bảng ánh xạ khoáng chất với nutrient

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `mineral_nutrient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `mineral_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `amount` | Số thập phân (10) | Lượng | - |
| `factor` | Số thập phân (10) | Cột chưa có mô tả | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## MineralRDA

**Mô tả:** Bảng lưu giá trị RDA chuẩn cho khoáng chất

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `mineral_rda_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `mineral_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `sex` | Chuỗi ký tự có độ dài giới hạn (10) | Cột chưa có mô tả | - |
| `age_min` | Số nguyên | Tuổi | - |
| `age_max` | Số nguyên | Tuổi | - |
| `rda_value` | Số thập phân (10) | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## Nutrient

**Mô tả:** Bảng lưu thông tin chất dinh dưỡng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `nutrient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `nutrient_code` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | NOT NULL |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `created_by_admin` | Số nguyên | Người tạo | FOREIGN KEY |
| `group_name` | Chuỗi ký tự có độ dài giới hạn (50) | Tên | - |

---

## NutrientContraindication

**Mô tả:** Bảng lưu chống chỉ định của chất dinh dưỡng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `contra_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `condition_name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `note` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## NutrientMapping

**Mô tả:** Bảng ánh xạ giữa các loại nutrient khác nhau

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `mapping_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `fiber_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `fatty_acid_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `factor` | Số thập phân (10) | Cột chưa có mô tả | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## NutritionAnalysis

**Mô tả:** Bảng lưu phân tích dinh dưỡng từ hình ảnh

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `analysis_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | NOT NULL |
| `food_name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | - |
| `confidence_score` | Số thập phân (3) | Cột chưa có mô tả | - |
| `nutrients` | Dữ liệu JSON | Cột chưa có mô tả | NOT NULL |
| `is_approved` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `approved_at` | Ngày giờ | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## PasswordChangeCode

**Mô tả:** Bảng lưu mã đổi mật khẩu

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `id` | Số tự động tăng | Cột chưa có mô tả | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `code` | Chuỗi ký tự có độ dài giới hạn (12) | Cột chưa có mô tả | NOT NULL |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | NOT NULL, DEFAULT |
| `used_at` | Ngày giờ có múi giờ | Cột chưa có mô tả | - |
| `expires_at` | Ngày giờ có múi giờ | Cột chưa có mô tả | NOT NULL |

---

## PortionSize

**Mô tả:** Bảng lưu kích thước khẩu phần ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `portion_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `portion_name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `portion_name_vi` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | - |
| `weight_g` | Số thập phân (10) | Cân nặng | - |
| `is_common` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## Recipe

**Mô tả:** Bảng lưu công thức nấu ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `recipe_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `recipe_name` | Chuỗi ký tự có độ dài giới hạn (200) | Tên | NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `servings` | Số nguyên | Cột chưa có mô tả | DEFAULT |
| `prep_time_minutes` | Số nguyên | Thời gian | - |
| `cook_time_minutes` | Số nguyên | Thời gian | - |
| `instructions` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `image_url` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `is_public` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## RecipeIngredient

**Mô tả:** Bảng lưu nguyên liệu trong công thức

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `recipe_ingredient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `recipe_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `food_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `weight_g` | Số thập phân (10) | Cân nặng | - |
| `ingredient_order` | Số nguyên | Cột chưa có mô tả | DEFAULT |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## Role

**Mô tả:** Bảng quản lý vai trò

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `role_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `role_name` | Chuỗi ký tự có độ dài giới hạn (50) | Tên | UNIQUE, NOT NULL |

---

## Suggestion

**Mô tả:** Bảng lưu gợi ý dinh dưỡng cho người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `suggestion_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `date` | Ngày tháng | Ngày | NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `deficiency_amount` | Số thập phân (10) | Lượng | - |
| `suggested_food_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `note` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |

---

## User

**Mô tả:** Bảng lưu thông tin người dùng cơ bản

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `full_name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | - |
| `email` | Chuỗi ký tự có độ dài giới hạn (100) | Email | UNIQUE, NOT NULL |
| `password_hash` | Chuỗi ký tự không giới hạn | Mật khẩu | NOT NULL |
| `age` | Số nguyên | Tuổi | - |
| `gender` | Chuỗi ký tự có độ dài giới hạn (10) | Giới tính | - |
| `height_cm` | Số thập phân (5) | Chiều cao | - |
| `weight_kg` | Số thập phân (5) | Cân nặng | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `last_login` | Ngày giờ có múi giờ | Cột chưa có mô tả | - |

---

## UserActivityLog

**Mô tả:** Bảng ghi log hoạt động của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `log_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `action` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `log_time` | Ngày giờ | Thời gian | DEFAULT |

---

## UserAminoIntake

**Mô tả:** Bảng lưu lượng axit amin tiêu thụ hàng ngày

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `amino_acid_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `amount` | NUMERIC NOT NULL | Lượng | NOT NULL |
| `unit` | Chuỗi ký tự có độ dài giới hạn (16) | Đơn vị | DEFAULT |
| `source` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `recorded_at` | Ngày giờ | Cột chưa có mô tả | DEFAULT |

---

## UserAminoRequirement

**Mô tả:** Bảng lưu yêu cầu axit amin của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `amino_acid_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `base` | Số thập phân | Cột chưa có mô tả | - |
| `multiplier` | Số thập phân | Cột chưa có mô tả | - |
| `recommended` | Số thập phân | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự không giới hạn | Đơn vị | - |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## UserFattyAcidIntake

**Mô tả:** Bảng lưu lượng axit béo tiêu thụ hàng ngày

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `intake_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `date` | Ngày tháng | Ngày | NOT NULL |
| `fatty_acid_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `amount` | Số thập phân (12) | Lượng | - |

---

## UserFattyAcidRequirement

**Mô tả:** Bảng lưu yêu cầu axit béo của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `fatty_acid_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `base` | Số thập phân | Cột chưa có mô tả | - |
| `multiplier` | Số thập phân | Cột chưa có mô tả | - |
| `recommended` | Số thập phân | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự không giới hạn | Đơn vị | - |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## UserFiberIntake

**Mô tả:** Bảng lưu lượng chất xơ tiêu thụ hàng ngày

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `intake_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `date` | Ngày tháng | Ngày | NOT NULL |
| `fiber_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `amount` | Số thập phân (12) | Lượng | - |

---

## UserFiberRequirement

**Mô tả:** Bảng lưu yêu cầu chất xơ của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `fiber_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `base` | Số thập phân | Cột chưa có mô tả | - |
| `multiplier` | Số thập phân | Cột chưa có mô tả | - |
| `recommended` | Số thập phân | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự không giới hạn | Đơn vị | - |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## UserGoal

**Mô tả:** Bảng lưu mục tiêu của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `goal_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `goal_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `goal_weight` | Số thập phân (5) | Cân nặng | - |
| `activity_factor` | Số thập phân (3) | Cột chưa có mô tả | - |
| `bmr` | Số thập phân (10) | Cột chưa có mô tả | - |
| `tdee` | Số thập phân (10) | Cột chưa có mô tả | - |
| `daily_calorie_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_protein_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_fat_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_carb_target` | Số thập phân (10) | Mục tiêu | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## UserHealthCondition

**Mô tả:** Bảng lưu bệnh mà người dùng đang mắc

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_condition_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `condition_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `diagnosed_date` | Ngày tháng | Ngày | DEFAULT |
| `treatment_start_date` | Ngày tháng | Ngày | DEFAULT |
| `treatment_end_date` | Ngày tháng | Ngày | - |
| `treatment_duration_days` | Số nguyên | Cột chưa có mô tả | - |
| `status` | Chuỗi ký tự có độ dài giới hạn (20) | Trạng thái | DEFAULT |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## UserMineralRequirement

**Mô tả:** Bảng lưu yêu cầu khoáng chất của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `mineral_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `base` | Số thập phân | Cột chưa có mô tả | - |
| `multiplier` | Số thập phân | Cột chưa có mô tả | - |
| `recommended` | Số thập phân | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự không giới hạn | Đơn vị | - |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## UserNutrientNotification

**Mô tả:** Bảng lưu thông báo về dinh dưỡng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `notification_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `nutrient_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | NOT NULL |
| `nutrient_name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | - |
| `notification_type` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | NOT NULL |
| `title` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | NOT NULL |
| `message` | Chuỗi ký tự không giới hạn | Tuổi | NOT NULL |
| `severity` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | DEFAULT |
| `is_read` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `metadata` | Dữ liệu JSON | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## UserNutrientTracking

**Mô tả:** Bảng theo dõi dinh dưỡng hàng ngày

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `tracking_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `date` | Ngày tháng | Ngày | NOT NULL, DEFAULT |
| `nutrient_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | NOT NULL |
| `target_amount` | Số thập phân (10) | Lượng | - |
| `current_amount` | Số thập phân (10) | Lượng | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | - |
| `last_updated` | Ngày giờ có múi giờ | Ngày | DEFAULT |

---

## UserProfile

**Mô tả:** Bảng lưu hồ sơ chi tiết và mục tiêu dinh dưỡng của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | PRIMARY KEY, FOREIGN KEY |
| `activity_level` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | - |
| `diet_type` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | - |
| `allergies` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `health_goals` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `goal_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | - |
| `goal_weight` | Số thập phân (5) | Cân nặng | - |
| `activity_factor` | Số thập phân (3) | Cột chưa có mô tả | - |
| `bmr` | Số thập phân (10) | Cột chưa có mô tả | - |
| `tdee` | Số thập phân (10) | Cột chưa có mô tả | - |
| `daily_calorie_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_protein_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_fat_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_carb_target` | Số thập phân (10) | Mục tiêu | - |
| `daily_water_target` | Số thập phân (10) | Mục tiêu | - |

---

## UserSecurity

**Mô tả:** Bảng lưu thông tin bảo mật người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | PRIMARY KEY, FOREIGN KEY |
| `twofa_enabled` | Giá trị logic (true/false) | Cột chưa có mô tả | NOT NULL, DEFAULT |
| `twofa_secret` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `lock_threshold` | Số nguyên | Cột chưa có mô tả | NOT NULL, DEFAULT |
| `failed_attempts` | Số nguyên | Cột chưa có mô tả | NOT NULL, DEFAULT |
| `updated_at` | Ngày giờ có múi giờ | Thời điểm cập nhật | NOT NULL, DEFAULT |

---

## UserSetting

**Mô tả:** Bảng lưu cài đặt giao diện và tùy chọn của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | PRIMARY KEY, FOREIGN KEY |
| `theme` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | DEFAULT |
| `language` | Chuỗi ký tự có độ dài giới hạn (10) | Tuổi | DEFAULT |
| `font_size` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | DEFAULT |
| `unit_system` | Chuỗi ký tự có độ dài giới hạn (10) | Đơn vị | DEFAULT |
| `seasonal_ui_enabled` | Giá trị logic (true/false) | Cột chưa có mô tả | DEFAULT |
| `seasonal_mode` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | DEFAULT |
| `seasonal_custom_bg` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `falling_leaves_enabled` | Giá trị logic (true/false) | Cột chưa có mô tả | DEFAULT |
| `weather_enabled` | Giá trị logic (true/false) | Cột chưa có mô tả | DEFAULT |
| `weather_city` | Chuỗi ký tự có độ dài giới hạn (100) | Cột chưa có mô tả | - |
| `weather_last_update` | Ngày giờ | Ngày | - |
| `weather_last_data` | Dữ liệu JSON | Cột chưa có mô tả | - |
| `background_image_url` | Chuỗi ký tự không giới hạn | áº£nh background chung (náº¿u cÃ³) | - |
| `calorie_multiplier` | Số thập phân (4) | Cột chưa có mô tả | - |
| `macro_protein_pct` | Số thập phân (5) | Cột chưa có mô tả | - |
| `macro_fat_pct` | Số thập phân (5) | Cột chưa có mô tả | - |
| `macro_carb_pct` | Số thập phân (5) | Cột chưa có mô tả | - |
| `wind_direction` | DOUBLE PRECISION DEFAULT 0 | Cột chưa có mô tả | DEFAULT |
| `weather_effects_enabled` | Giá trị logic (true/false) | whether weather effects (icons/overlays) are enabled | DEFAULT |
| `effect_intensity` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | DEFAULT |
| `calorie_multiplier` | Số thực | Cột chưa có mô tả | - |
| `meal_pct_breakfast` | Số thập phân (5) | Cột chưa có mô tả | - |
| `seasonal_ui_enabled` | Giá trị logic (true/false) | Cột chưa có mô tả | DEFAULT |
| `theme` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | DEFAULT |
| `weather_effects_enabled` | Giá trị logic (true/false) | Cột chưa có mô tả | DEFAULT |
| `wind_direction` | DOUBLE PRECISION DEFAULT 0 | Cột chưa có mô tả | DEFAULT |

---

## UserVitaminRequirement

**Mô tả:** Bảng lưu yêu cầu vitamin của người dùng

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `vitamin_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `base` | Số thập phân | Cột chưa có mô tả | - |
| `multiplier` | Số thập phân | Cột chưa có mô tả | - |
| `recommended` | Số thập phân | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự không giới hạn | Đơn vị | - |
| `updated_at` | Ngày giờ | Thời điểm cập nhật | DEFAULT |

---

## Vitamin

**Mô tả:** Bảng lưu thông tin vitamin

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `vitamin_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `code` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | UNIQUE, NOT NULL |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | DEFAULT |
| `recommended_daily` | Số thập phân (10) | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `created_by_admin` | Số nguyên | Người tạo | FOREIGN KEY |

---

## VitaminNutrient

**Mô tả:** Bảng ánh xạ vitamin với nutrient

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `vitamin_nutrient_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `vitamin_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `nutrient_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `amount` | Số thập phân (10) | Lượng | - |
| `factor` | Số thập phân (10) | Cột chưa có mô tả | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## VitaminRDA

**Mô tả:** Bảng lưu giá trị RDA chuẩn cho vitamin

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `vitamin_rda_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `vitamin_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `sex` | Chuỗi ký tự có độ dài giới hạn (10) | Cột chưa có mô tả | - |
| `age_min` | Số nguyên | Tuổi | - |
| `age_max` | Số nguyên | Tuổi | - |
| `rda_value` | Số thập phân (10) | Cột chưa có mô tả | - |
| `unit` | Chuỗi ký tự có độ dài giới hạn (20) | Đơn vị | - |
| `notes` | Chuỗi ký tự không giới hạn | Ghi chú | - |

---

## dishnotification

**Mô tả:** Bảng lưu thông báo về món ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `notification_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `dish_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `notification_type` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | NOT NULL |
| `title` | Chuỗi ký tự có độ dài giới hạn (200) | Cột chưa có mô tả | NOT NULL |
| `message` | Chuỗi ký tự không giới hạn | Tuổi | NOT NULL |
| `is_read` | Giá trị logic (true/false) | Cờ đánh dấu | DEFAULT |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |
| `read_at` | Ngày giờ | Cột chưa có mô tả | - |

---

## meal_entries

**Mô tả:** Bảng lưu các món ăn đã ghi nhận

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `id` | Số tự động tăng | Cột chưa có mô tả | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `entry_date` | Ngày tháng | Ngày | NOT NULL, DEFAULT |
| `meal_type` | Chuỗi ký tự có độ dài giới hạn (16) | Cột chưa có mô tả | NOT NULL |
| `food_id` | Số nguyên | ID định danh | - |
| `weight_g` | Số thập phân (10) | Cân nặng | - |
| `kcal` | Số thập phân (10) | Cột chưa có mô tả | - |
| `carbs` | Số thập phân (10) | Cột chưa có mô tả | - |
| `protein` | Số thập phân (10) | Cột chưa có mô tả | - |
| `fat` | Số thập phân (10) | Cột chưa có mô tả | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |

---

## permission

**Mô tả:** Bảng chưa có mô tả

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `permission_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `name` | Chuỗi ký tự có độ dài giới hạn (100) | Tên | UNIQUE, NOT NULL |
| `description` | Chuỗi ký tự không giới hạn | Mô tả | - |
| `resource` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | NOT NULL |
| `action` | Chuỗi ký tự có độ dài giới hạn (50) | Cột chưa có mô tả | NOT NULL |
| `created_at` | Ngày giờ | Thời điểm tạo | DEFAULT |

---

## rolepermission

**Mô tả:** Bảng chưa có mô tả

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `role_permission_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `role_name` | Chuỗi ký tự có độ dài giới hạn (50) | Tên | FOREIGN KEY |
| `permission_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `granted_at` | Ngày giờ | Cột chưa có mô tả | DEFAULT |

---

## user_account_status

**Mô tả:** Bảng lưu trạng thái tài khoản

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `user_id` | Số nguyên | ID định danh | PRIMARY KEY, FOREIGN KEY |
| `is_blocked` | Giá trị logic (true/false) | Cờ đánh dấu | NOT NULL, DEFAULT |
| `blocked_reason` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `blocked_at` | Ngày giờ có múi giờ | Cột chưa có mô tả | - |
| `blocked_by_admin` | Số nguyên | Cột chưa có mô tả | FOREIGN KEY |
| `updated_at` | Ngày giờ có múi giờ | Thời điểm cập nhật | NOT NULL, DEFAULT |

---

## user_block_event

**Mô tả:** Bảng lưu sự kiện chặn tài khoản

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `block_event_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `event_type` | Chuỗi ký tự có độ dài giới hạn (20) | Cột chưa có mô tả | NOT NULL |
| `reason` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `admin_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | NOT NULL, DEFAULT |

---

## user_meal_summaries

**Mô tả:** Bảng tổng hợp dinh dưỡng theo bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `id` | Số tự động tăng | Cột chưa có mô tả | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `summary_date` | Ngày tháng | Ngày | NOT NULL, DEFAULT |
| `meal_type` | Chuỗi ký tự có độ dài giới hạn (16) | Cột chưa có mô tả | NOT NULL |
| `consumed_kcal` | Số thập phân (12) | Cột chưa có mô tả | - |
| `consumed_carbs` | Số thập phân (12) | Cột chưa có mô tả | - |
| `consumed_protein` | Số thập phân (12) | Cột chưa có mô tả | - |
| `consumed_fat` | Số thập phân (12) | Cột chưa có mô tả | - |
| `updated_at` | Ngày giờ có múi giờ | Thời điểm cập nhật | DEFAULT |

---

## user_meal_targets

**Mô tả:** Bảng lưu mục tiêu dinh dưỡng cho từng bữa ăn

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `id` | Số tự động tăng | Cột chưa có mô tả | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY, NOT NULL |
| `target_date` | Ngày tháng | Ngày | NOT NULL, DEFAULT |
| `meal_type` | Chuỗi ký tự có độ dài giới hạn (16) | Cột chưa có mô tả | NOT NULL |
| `target_kcal` | Số thập phân (10) | Mục tiêu | - |
| `target_carbs` | Số thập phân (10) | Mục tiêu | - |
| `target_protein` | Số thập phân (10) | Mục tiêu | - |
| `target_fat` | Số thập phân (10) | Mục tiêu | - |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | DEFAULT |
| `updated_at` | Ngày giờ có múi giờ | Thời điểm cập nhật | DEFAULT |

---

## user_unblock_request

**Mô tả:** Bảng lưu yêu cầu mở khóa tài khoản

### Các cột (Columns)

| Tên cột | Kiểu dữ liệu | Mô tả | Đặc điểm |
|---------|--------------|-------|----------|
| `request_id` | Số tự động tăng | ID định danh | PRIMARY KEY |
| `user_id` | Số nguyên | ID định danh | FOREIGN KEY |
| `status` | Chuỗi ký tự có độ dài giới hạn (20) | Trạng thái | NOT NULL, DEFAULT |
| `message` | Chuỗi ký tự không giới hạn | Tuổi | - |
| `admin_response` | Chuỗi ký tự không giới hạn | Cột chưa có mô tả | - |
| `decided_at` | Ngày giờ có múi giờ | Cột chưa có mô tả | - |
| `decided_by_admin` | Số nguyên | Cột chưa có mô tả | FOREIGN KEY |
| `created_at` | Ngày giờ có múi giờ | Thời điểm tạo | NOT NULL, DEFAULT |

---

