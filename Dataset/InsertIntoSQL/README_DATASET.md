# HỆ THỐNG QUẢN LÝ DINH DƯỠNG VIỆT NAM
## Vietnamese Nutrition Database - Full Dataset

---

## 📋 TỔNG QUAN

Hệ thống dữ liệu mẫu thực tế cho ứng dụng quản lý dinh dưỡng và sức khỏe người Việt Nam, bao gồm:

- **55+ chất dinh dưỡng** (Vitamins, Minerals, Macronutrients, Amino acids, Fatty acids)
- **140+ thực phẩm** (100 từ USDA + 40 món ăn Việt Nam)
- **30+ bệnh lý phổ biến** (Tiểu đường, cao huyết áp, loãng xương, gút...)
- **30+ loại thuốc** (Thuốc điều trị bệnh mãn tính từ DrugBank)
- **40+ tương tác thuốc-dinh dưỡng** (Cảnh báo an toàn)
- **40 món ăn Việt Nam** (Phở, Bún, Cơm, Bánh...)
- **40 đồ uống** (Cà phê, Sinh tố, Trà, Chè...)
- **40 công thức nấu ăn** chi tiết

**Tổng số records: 1,500+ dữ liệu thực tế**

---

## 📁 CẤU TRÚC FILE

```
d:\dataset/
├── real_dataset_vietnam.sql           # DỮ LIỆU CƠ BẢN (Priority 1)
│   ├── ALTER TABLE: Thêm cột tiếng Việt
│   ├── UPDATE: Tên tiếng Việt cho 55 nutrients
│   ├── INSERT: HealthCondition (30 bệnh lý)
│   ├── INSERT: Drug (30 thuốc)
│   ├── INSERT: DrugHealthCondition
│   ├── INSERT: DrugNutrientContraindication
│   ├── INSERT: Food (140 thực phẩm)
│   └── INSERT: FoodNutrient (450+ mappings)
│
├── extended_tables_vietnam.sql        # DỮ LIỆU MỞ RỘNG (Priority 2)
│   ├── INSERT: Dish (40 món ăn)
│   ├── INSERT: DishIngredient
│   ├── INSERT: DishNutrient
│   ├── INSERT: Drink (40 đồ uống)
│   ├── INSERT: DrinkIngredient
│   ├── INSERT: DrinkNutrient
│   ├── INSERT: PortionSize (100 khẩu phần)
│   ├── INSERT: ConditionFoodRecommendation
│   ├── INSERT: ConditionNutrientEffect
│   ├── INSERT: Recipe (40 công thức)
│   └── INSERT: RecipeIngredient
│
├── additional_data_extended.sql       # DỮ LIỆU BỔ SUNG (Priority 3)
│   ├── DrinkNutrient (drinks 21-40)
│   ├── PortionSize (20+ khẩu phần thêm)
│   ├── ConditionFoodRecommendation (20+ khuyến nghị)
│   ├── ConditionNutrientEffect (20+ hiệu ứng)
│   ├── Recipe (20+ công thức chi tiết)
│   └── RecipeIngredient
│
└── import_all_data.sql               # SCRIPT TỔNG HỢP (Chạy tất cả)
    ├── Import theo thứ tự đúng
    ├── Kiểm tra dữ liệu
    ├── Verify foreign keys
    ├── Tạo indexes
    └── Thống kê kết quả
```

---

## 🚀 HƯỚNG DẪN IMPORT

### **Phương án 1: Import Tất Cả (Khuyến nghị)**

```bash
# Kết nối PostgreSQL
psql -U your_username -d your_database

# Chạy script tổng hợp
\i 'd:/dataset/import_all_data.sql'
```

### **Phương án 2: Import Từng File**

```bash
# 1. Import dữ liệu cơ bản
\i 'd:/dataset/real_dataset_vietnam.sql'

# 2. Import dữ liệu mở rộng
\i 'd:/dataset/extended_tables_vietnam.sql'

# 3. Import dữ liệu bổ sung
\i 'd:/dataset/additional_data_extended.sql'
```

### **Phương án 3: Import Bằng Command Line**

```bash
# Windows PowerShell
psql -U postgres -d nutrition_db -f "d:\dataset\import_all_data.sql"

# Linux/Mac
psql -U postgres -d nutrition_db -f /path/to/import_all_data.sql
```

---

## 📊 DỮ LIỆU CHI TIẾT

### **1. NUTRIENT (55+ Chất Dinh Dưỡng)**

| ID  | TagName      | Name VI                    | Category        |
|-----|--------------|----------------------------|-----------------|
| 1   | ENERC_KCAL   | Năng lượng (Kcal)         | Energy          |
| 2   | PROCNT       | Chất đạm (Protein)        | Macronutrient   |
| 3   | FAT          | Tổng chất béo             | Macronutrient   |
| 4   | CHOCDF       | Carbohydrate              | Macronutrient   |
| 5   | FIBTG        | Chất xơ tổng              | Fiber           |
| 14  | VITK         | Vitamin K                 | Vitamin         |
| 15  | VITC         | Vitamin C                 | Vitamin         |
| 23  | VITB12       | Vitamin B12               | Vitamin         |
| 24  | CA           | Canxi (Ca)                | Mineral         |
| 27  | K            | Kali (K)                  | Mineral         |
| 28  | NA           | Natri (Na)                | Mineral         |
| 29  | FE           | Sắt (Fe)                  | Mineral         |
| 30  | ZN           | Kẽm (Zn)                  | Mineral         |
| ... | ...          | ...                       | ...             |

### **2. HEALTHCONDITION (30 Bệnh Lý)**

| ID   | Name EN                          | Name VI                          | ICD-10 |
|------|----------------------------------|----------------------------------|--------|
| 1001 | Type 2 Diabetes Mellitus         | Đái tháo đường tuýp 2           | E11    |
| 1002 | Essential Hypertension           | Tăng huyết áp                   | I10    |
| 1003 | Deep Vein Thrombosis             | Huyết khối tĩnh mạch sâu        | I82    |
| 1004 | Iron Deficiency Anemia           | Thiếu máu do thiếu sắt          | D50    |
| 1005 | Osteoporosis                     | Loãng xương                     | M81    |
| 1006 | Gout                             | Bệnh Gút                        | M10    |
| 1007 | Chronic Kidney Disease           | Bệnh thận mãn tính              | N18    |
| 1008 | GERD                             | Trào ngược dạ dày thực quản     | K21    |
| 1009 | Hyperlipidemia                   | Rối loạn lipid máu              | E78    |
| 1012 | Coronary Artery Disease          | Bệnh động mạch vành             | I25    |
| ...  | ...                              | ...                             | ...    |

### **3. DRUG (30 Thuốc)**

| ID   | Name EN       | Name VI        | Description VI                                |
|------|---------------|----------------|-----------------------------------------------|
| 2001 | Metformin     | Metformin      | Thuốc đầu tay điều trị tiểu đường            |
| 2002 | Warfarin      | Warfarin       | Thuốc chống đông máu, ngăn ngừa huyết khối   |
| 2003 | Lisinopril    | Lisinopril     | Thuốc ức chế men chuyển trị cao huyết áp     |
| 2004 | Ferrous Sulfate | Sắt Sulfate  | Viên uống bổ sung sắt điều trị thiếu máu     |
| 2005 | Alendronate   | Alendronate    | Thuốc bisphosphonat điều trị loãng xương     |
| 2006 | Allopurinol   | Allopurinol    | Thuốc làm giảm axit uric trị Gút             |
| 2007 | Omeprazole    | Omeprazole     | Thuốc ức chế bơm proton giảm axit dạ dày     |
| ...  | ...           | ...            | ...                                          |

### **4. FOOD (140 Thực Phẩm)**

**Thực phẩm USDA (1-100):**
- Bào ngư, Mật ong, Rau họ cải, Sữa bò, Cherry, Bia, Giá cải bông...

**Thực phẩm Việt Nam (3001-3040):**

| ID   | Name                    | Name VI                 | Nổi bật              |
|------|-------------------------|-------------------------|----------------------|
| 3001 | Spinach, cooked         | Rau bina nấu chín      | Giàu Vit K (493µg)   |
| 3002 | Kale, raw               | Cải xoăn               | Siêu giàu Vit K (817µg) |
| 3003 | Beef Liver              | Gan bò                 | Giàu B12, Sắt        |
| 3004 | Banana                  | Chuối                  | Giàu Kali (358mg)    |
| 3007 | Salmon                  | Cá hồi                 | Giàu Omega-3, B12    |
| 3011 | Pho Bo                  | Phở bò                 | Món ăn sáng phổ biến |
| 3012 | Bun Cha                 | Bún chả                | Đặc sản Hà Nội       |
| 3013 | Com Tam                 | Cơm tấm                | Món ăn sáng miền Nam |
| 3014 | Banh Mi                 | Bánh mì Việt Nam       | UNESCO công nhận     |
| 3021 | Bun Bo Hue              | Bún bò Huế             | Đặc sản Huế          |
| 3022 | Banh Xeo                | Bánh xèo               | Món ăn miền Trung    |
| 3035 | Chicken Curry           | Cà ri gà               | Món ăn gia đình      |
| ...  | ...                     | ...                    | ...                  |

### **5. TƯƠNG TÁC THUỐC-DINH DƯỠNG (Quan Trọng!)**

| Drug         | Nutrient     | Warning VI                                          | Severity |
|--------------|--------------|-----------------------------------------------------|----------|
| Warfarin     | Vitamin K    | Vitamin K làm giảm tác dụng chống đông máu         | High     |
| Metformin    | Vitamin B12  | Sử dụng lâu dài giảm hấp thu B12                   | Medium   |
| Lisinopril   | Potassium    | Thuốc làm tăng Kali máu, hạn chế thực phẩm giàu K  | High     |
| Spironolactone | Potassium  | Nguy cơ tăng Kali nghiêm trọng, tránh chuối cam    | High     |
| Alendronate  | Calcium      | Canxi giảm hấp thu thuốc, cách 30 phút             | High     |
| Ferrous Sulfate | Calcium   | Canxi cản trở hấp thu Sắt                          | Medium   |

---

## 🔍 QUERIES HỮU ÍCH

### **Tìm thực phẩm giàu Vitamin K (Cảnh báo Warfarin)**

```sql
SELECT 
  f.name_vi,
  fn.amount_per_100g as vitamin_k_mcg
FROM foodnutrient fn
JOIN food f ON fn.food_id = f.food_id
WHERE fn.nutrient_id = 14  -- Vitamin K
ORDER BY fn.amount_per_100g DESC
LIMIT 10;
```

**Kết quả:**
- Cải xoăn: 817µg
- Rau bina: 493µg
- Rau muống xào: 312µg

### **Tìm món ăn phù hợp với người tiểu đường**

```sql
SELECT 
  f.name_vi,
  cfr.recommendation_type,
  cfr.notes
FROM conditionfoodrecommendation cfr
JOIN food f ON cfr.food_id = f.food_id
WHERE cfr.condition_id = 1001  -- Tiểu đường
  AND cfr.recommendation_type = 'Recommended'
ORDER BY f.name_vi;
```

### **Kiểm tra tương tác thuốc đang dùng**

```sql
SELECT 
  d.name_vi as thuoc,
  n.name_vi as chat_dinh_duong,
  dnc.warning_message_vi as canh_bao,
  dnc.severity
FROM drugnutrientcontraindication dnc
JOIN drug d ON dnc.drug_id = d.drug_id
JOIN nutrient n ON dnc.nutrient_id = n.nutrient_id
WHERE d.drug_id = 2002  -- Warfarin
ORDER BY 
  CASE dnc.severity 
    WHEN 'High' THEN 1 
    WHEN 'Medium' THEN 2 
    ELSE 3 
  END;
```

### **Phân tích dinh dưỡng món ăn**

```sql
SELECT 
  d.vietnamese_name,
  MAX(CASE WHEN dn.nutrient_id = 1 THEN dn.amount_per_100g END) as calories,
  MAX(CASE WHEN dn.nutrient_id = 2 THEN dn.amount_per_100g END) as protein_g,
  MAX(CASE WHEN dn.nutrient_id = 3 THEN dn.amount_per_100g END) as fat_g,
  MAX(CASE WHEN dn.nutrient_id = 4 THEN dn.amount_per_100g END) as carbs_g,
  MAX(CASE WHEN dn.nutrient_id = 28 THEN dn.amount_per_100g END) as sodium_mg
FROM dish d
JOIN dishnutrient dn ON d.dish_id = dn.dish_id
WHERE d.dish_id BETWEEN 1 AND 20
GROUP BY d.dish_id, d.vietnamese_name
ORDER BY d.dish_id;
```

---

## ⚠️ LƯU Ý QUAN TRỌNG

### **1. Trước khi Import**

✅ **Backup database hiện tại**
```sql
pg_dump -U postgres nutrition_db > backup_$(date +%Y%m%d).sql
```

✅ **Kiểm tra cấu trúc bảng**
```sql
\d nutrient
\d food
\d healthcondition
\d drug
```

✅ **Xác nhận quyền truy cập**
```sql
SELECT current_user, current_database();
```

### **2. Thứ tự Import (Rất quan trọng!)**

```
1. real_dataset_vietnam.sql       (Cơ sở dữ liệu)
   ↓
2. extended_tables_vietnam.sql    (Mở rộng)
   ↓
3. additional_data_extended.sql   (Bổ sung)
```

**Lý do:** Foreign key constraints yêu cầu:
- `nutrient` tồn tại trước khi insert `foodnutrient`
- `food` tồn tại trước khi insert `dishingredient`
- `healthcondition` tồn tại trước khi insert `conditionfoodrecommendation`

### **3. Xử lý Lỗi Thường Gặp**

#### **Lỗi: Duplicate key**
```sql
-- Xóa dữ liệu cũ trước khi import
DELETE FROM foodnutrient WHERE food_id BETWEEN 1 AND 200;
DELETE FROM food WHERE food_id BETWEEN 1 AND 200;
```

#### **Lỗi: Foreign key violation**
```sql
-- Kiểm tra nutrient_id có tồn tại không
SELECT DISTINCT fn.nutrient_id 
FROM foodnutrient fn
LEFT JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
WHERE n.nutrient_id IS NULL;
```

#### **Lỗi: Character encoding**
```sql
-- Đặt encoding UTF-8
SET client_encoding = 'UTF8';
\encoding UTF8
```

### **4. Kiểm tra sau Import**

```sql
-- Đếm số lượng records
SELECT 'NUTRIENT' as table_name, COUNT(*) FROM nutrient
UNION ALL
SELECT 'FOOD', COUNT(*) FROM food
UNION ALL
SELECT 'FOODNUTRIENT', COUNT(*) FROM foodnutrient
UNION ALL
SELECT 'HEALTHCONDITION', COUNT(*) FROM healthcondition
UNION ALL
SELECT 'DRUG', COUNT(*) FROM drug;

-- Kiểm tra foreign keys
SELECT COUNT(*) as invalid_count
FROM foodnutrient fn
LEFT JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
WHERE n.nutrient_id IS NULL;
```

---

## 📈 THỐNG KÊ DỮ LIỆU

### **Tổng quan**

| Bảng                           | Số Records | Mô tả                              |
|--------------------------------|------------|------------------------------------|
| `nutrient`                     | 55-58      | Chất dinh dưỡng cơ bản             |
| `healthcondition`              | ~30        | Bệnh lý phổ biến                   |
| `drug`                         | ~30        | Thuốc điều trị                     |
| `food`                         | ~140       | Thực phẩm + Món ăn VN              |
| `foodnutrient`                 | ~450       | Dinh dưỡng thực phẩm               |
| `dish`                         | ~40        | Món ăn Việt Nam                    |
| `dishingredient`               | ~100       | Nguyên liệu món ăn                 |
| `dishnutrient`                 | ~150       | Dinh dưỡng món ăn                  |
| `drink`                        | ~40        | Đồ uống                            |
| `drinknutrient`                | ~160       | Dinh dưỡng đồ uống                 |
| `portionsize`                  | ~120       | Khẩu phần chuẩn                    |
| `conditionfoodrecommendation`  | ~120       | Khuyến nghị thực phẩm              |
| `conditionnutrienteffect`      | ~120       | Điều chỉnh dinh dưỡng theo bệnh    |
| `recipe`                       | ~40        | Công thức nấu ăn                   |
| `drughealthcondition`          | ~25        | Thuốc điều trị bệnh gì             |
| `drugnutrientcontraindication` | ~40        | Tương tác thuốc-dinh dưỡng         |

**TỔNG CỘNG: 1,500+ records**

---

## 💡 USE CASES

### **1. Ứng dụng Theo dõi Dinh dưỡng**
- Tính toán calories, protein, carbs, fat
- Gợi ý món ăn phù hợp
- Cảnh báo thiếu hụt dinh dưỡng

### **2. Ứng dụng Quản lý Bệnh Mãn tính**
- Tiểu đường: Khuyến nghị thực phẩm ít GI
- Cao huyết áp: Hạn chế muối
- Loãng xương: Tăng canxi, vitamin D

### **3. Hệ thống Cảnh báo Tương tác Thuốc**
- Warfarin + Vitamin K → Cảnh báo High
- Metformin + B12 → Khuyến nghị bổ sung
- Lisinopril + Kali → Tránh chuối, cam

### **4. Công cụ Lập kế hoạch Bữa ăn**
- Tính dinh dưỡng món ăn tự nấu
- Gợi ý thay thế nguyên liệu
- Điều chỉnh khẩu phần

---

## 🛠️ TÙY CHỈNH & MỞ RỘNG

### **Thêm món ăn mới**

```sql
-- Bước 1: Thêm dish
INSERT INTO dish (dish_id, name, vietnamese_name, description, category, serving_size_g)
VALUES (41, 'Pho Ga', 'Phở Gà', 'Phở gà thơm ngon', 'Breakfast', 600);

-- Bước 2: Thêm nguyên liệu
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
VALUES 
  (41, 3008, 200, 'Bánh phở', 1),
  (41, 3007, 100, 'Gà', 2);

-- Bước 3: Thêm dinh dưỡng
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g)
VALUES 
  (41, 1, 120.0),  -- Calories
  (41, 2, 8.5),    -- Protein
  (41, 4, 15.0);   -- Carbs
```

### **Thêm tương tác thuốc mới**

```sql
INSERT INTO drugnutrientcontraindication 
  (drug_id, nutrient_id, warning_message_en, warning_message_vi, severity)
VALUES 
  (2007, 24, 'May reduce calcium absorption', 
   'Có thể giảm hấp thu canxi', 'medium');
```

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề khi import hoặc sử dụng dữ liệu:

1. Kiểm tra file log PostgreSQL
2. Verify foreign key constraints
3. Kiểm tra encoding (phải là UTF-8)
4. Đảm bảo PostgreSQL version 12+

---

## 📝 CHANGELOG

### Version 1.0 (December 1, 2025)
- ✅ Initial release với 1,500+ records
- ✅ Hỗ trợ đầy đủ tiếng Việt
- ✅ Dữ liệu thực tế từ USDA + DrugBank
- ✅ 40 món ăn Việt Nam phổ biến
- ✅ 40 tương tác thuốc-dinh dưỡng
- ✅ Script import tự động

---

## 📄 LICENSE

Dữ liệu từ nguồn công khai:
- **USDA FoodData Central** (Public Domain)
- **DrugBank** (Academic License)
- **ICD-10 Codes** (WHO)

Dữ liệu món ăn Việt Nam: Sưu tầm và biên soạn.

---

**Chúc bạn sử dụng hiệu quả! 🎉**
