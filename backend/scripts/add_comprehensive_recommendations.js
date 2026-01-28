const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

// ============================================================================
// STEP 1: Insert comprehensive food recommendations for ALL 39 conditions
// Using EXISTING food names - no need to add new foods
// ============================================================================

const COMPREHENSIVE_RECOMMENDATIONS = {
  // [1] Diabetes Type 2 - Already has data, add more
  1: {
    avoid: ['Sugar', 'White bread', 'White rice', 'Candy', 'Soda', 'Gạo nếp', 'Bột gạo', 'Miến', 'Mật ong', 'Chuối tiêu', 'Xoài', 'Dưa hấu', 'Nhãn', 'Vải thiều', 'Măng cụt', 'Chôm chôm'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Mướp đắng', 'Cà rốt', 'Cải bắp', 'Cải xanh', 'Đậu cove', 'Đậu đũa', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Gạo lứt', 'Yến mạch', 'Ổi', 'Bưởi']
  },

  // [2] Hypertension - Already has data
  2: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Ham', 'Sausage', 'Cheese', 'Butter', 'Canned soup', 'Pizza', 'Thịt heo nạc', 'Thịt vịt', 'Tôm sú', 'Tôm thẻ', 'Mực ống', 'Nghêu', 'Phô mai', 'Bơ thực vật'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Bananas', 'Oranges', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Bí đao', 'Cà rốt', 'Khoai lang', 'Cải bắp', 'Cải ngọt', 'Chuối tiêu', 'Cam', 'Quýt', 'Xoài', 'Đu đủ', 'Dưa hấu', 'Ổi', 'Bưởi', 'Gạo lứt', 'Yến mạch', 'Hạt sen']
  },

  // [3] High Cholesterol - Already has data
  3: {
    avoid: ['Butter', 'Cheese', 'Bacon', 'Ham', 'Sausage', 'Egg yolk', 'Ice cream', 'Thịt heo nạc', 'Thịt vịt', 'Trứng gà', 'Trứng vịt', 'Phô mai', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Fish', 'Chicken breast', 'Tofu', 'Broccoli', 'Spinach', 'Carrots', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Đậu hũ', 'Đậu phụ non', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Gạo lứt', 'Yến mạch', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cam', 'Ổi', 'Mè rang', 'Dầu ô liu']
  },

  // [4] Fatty Liver
  4: {
    avoid: ['Butter', 'Sugar', 'Alcohol', 'Bacon', 'Gạo nếp', 'Mật ong', 'Thịt heo nạc', 'Thịt vịt', 'Bơ thực vật', 'Dầu đậu nành', 'Chuối tiêu', 'Nhãn', 'Vải thiều'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Cà chua', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo lứt', 'Yến mạch', 'Cam', 'Ổi', 'Chanh']
  },

  // [5] Gout
  5: {
    avoid: ['Bacon', 'Sausage', 'Beef', 'Pork', 'Fish', 'Thịt bò nạc', 'Thịt vịt', 'Cá rô phi', 'Cá tra', 'Cá chép', 'Cá thu', 'Tôm sú', 'Tôm thẻ', 'Mực ống', 'Nghêu', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Nấm rơm'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Bí đao', 'Cà rốt', 'Khoai lang', 'Cải bắp', 'Cải ngọt', 'Cà chua', 'Dưa chuột', 'Thịt gà', 'Đậu hũ', 'Đậu phụ non', 'Chuối tiêu', 'Cam', 'Đu đủ', 'Dưa hấu', 'Bưởi', 'Gạo lứt', 'Sữa chua không đường']
  },

  // [6] Anemia
  6: {
    avoid: [],
    recommend: ['Beef', 'Pork', 'Chicken', 'Fish', 'Eggs', 'Spinach', 'Broccoli', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt gà', 'Thịt vịt', 'Trứng gà', 'Cá rô phi', 'Cá tra', 'Cá chép', 'Cá thu', 'Rau muống', 'Rau dền', 'Cà rốt', 'Khoai lang', 'Cải ngọt', 'Cải xanh', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Gạo lứt', 'Sữa bò', 'Sữa chua không đường']
  },

  // [7] Osteoporosis
  7: {
    avoid: ['Salt', 'Soy sauce'],
    recommend: ['Milk', 'Yogurt', 'Cheese', 'Eggs', 'Tofu', 'Broccoli', 'Spinach', 'Carrots', 'Fish', 'Trứng gà', 'Sữa bò', 'Sữa chua không đường', 'Phô mai', 'Sữa dê', 'Đậu hũ', 'Đậu phụ non', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Cá rô phi', 'Cá tra', 'Cam', 'Ổi', 'Mè rang']
  },

  // [8] IBS
  8: {
    avoid: ['Bacon', 'Sausage', 'Beans', 'Onions', 'Garlic', 'Thịt heo nạc', 'Thịt vịt', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Hành tây', 'Tỏi'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Rice', 'Carrots', 'Bananas', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu phụ non', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Cà rốt', 'Khoai lang', 'Chuối tiêu', 'Cam', 'Ổi', 'Sữa chua không đường']
  },

  // [9] GERD
  9: {
    avoid: ['Bacon', 'Sausage', 'Tomatoes', 'Citrus', 'Chocolate', 'Cà chua', 'Ớt chuông', 'Chanh', 'Cam', 'Quýt', 'Tỏi', 'Gừng'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Carrots', 'Broccoli', 'Bananas', 'Bí đỏ', 'Bí đao', 'Cà rốt', 'Khoai lang', 'Cải bắp', 'Cải ngọt', 'Thịt gà', 'Cá rô phi', 'Đậu hũ', 'Chuối tiêu', 'Đu đủ', 'Ổi', 'Gạo tẻ trắng', 'Yến mạch', 'Sữa bò', 'Sữa chua không đường']
  },

  // [10] Gastritis
  10: {
    avoid: ['Bacon', 'Sausage', 'Tomatoes', 'Citrus', 'Spicy food', 'Cà chua', 'Ớt chuông', 'Chanh', 'Tỏi', 'Gừng'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Carrots', 'Broccoli', 'Bananas', 'Bí đỏ', 'Bí đao', 'Cà rốt', 'Khoai lang', 'Cải bắp', 'Thịt gà', 'Cá rô phi', 'Đậu hũ', 'Chuối tiêu', 'Đu đủ', 'Ổi', 'Gạo tẻ trắng', 'Yến mạch', 'Sữa bò', 'Sữa chua không đường']
  },

  // [11] Peptic Ulcer
  11: {
    avoid: ['Bacon', 'Sausage', 'Tomatoes', 'Citrus', 'Spicy food', 'Cà chua', 'Ớt chuông', 'Chanh', 'Tỏi', 'Gừng'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Carrots', 'Broccoli', 'Bananas', 'Bí đỏ', 'Bí đao', 'Cà rốt', 'Cải bắp', 'Thịt gà', 'Cá rô phi', 'Đậu hũ', 'Chuối tiêu', 'Đu đủ', 'Gạo tẻ trắng', 'Gạo lứt', 'Yến mạch', 'Sữa bò', 'Sữa chua không đường']
  },

  // [12] Celiac Disease
  12: {
    avoid: ['White bread', 'Wheat bread', 'Pasta', 'Bột mì nguyên cám', 'Bánh mì'],
    recommend: ['Rice', 'Gạo tẻ trắng', 'Gạo lứt', 'Gạo nếp', 'Bột gạo', 'Ngô', 'Khoai mì', 'Khoai môn', 'Khoai lang', 'Khoai tây', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Rau muống', 'Rau dền', 'Chuối tiêu', 'Cam', 'Ổi']
  },

  // [13] Kidney Disease (E105)
  13: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Ham', 'Beef', 'Pork', 'Eggs', 'Beans', 'Milk', 'Cheese', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt vịt', 'Trứng gà', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Sữa bò', 'Phô mai'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Bí đao', 'Su su', 'Dưa chuột', 'Thịt gà', 'Cá rô phi', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Chuối tiêu', 'Cam', 'Dưa hấu', 'Ổi']
  },

  // [14] Obesity - same as Diabetes
  14: {
    avoid: ['Sugar', 'White bread', 'Candy', 'Soda', 'Bacon', 'Butter', 'Gạo nếp', 'Bột gạo', 'Miến', 'Mật ong', 'Bơ thực vật', 'Dầu đậu nành', 'Thịt heo nạc', 'Thịt vịt', 'Chuối tiêu', 'Nhãn', 'Vải thiều', 'Măng cụt', 'Chôm chôm', 'Hạt điều', 'Đậu phộng'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Bí đao', 'Mướp đắng', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Cải xanh', 'Cà chua', 'Dưa chuột', 'Đậu cove', 'Đậu đũa', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Gạo lứt', 'Yến mạch', 'Ổi']
  },

  // [15] Malnutrition (E46)
  15: {
    avoid: [],
    recommend: ['Beef', 'Pork', 'Chicken', 'Fish', 'Eggs', 'Milk', 'Cheese', 'Beans', 'Nuts', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt gà', 'Thịt vịt', 'Trứng gà', 'Cá rô phi', 'Cá tra', 'Cá chép', 'Cá thu', 'Đậu hũ', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Gạo tẻ trắng', 'Gạo lứt', 'Yến mạch', 'Bột mì nguyên cám', 'Mè rang', 'Hạt điều', 'Đậu phộng', 'Sữa bò', 'Mật ong']
  },

  // [16] Heart Failure (I50)
  16: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Ham', 'Sausage', 'Butter', 'Cheese', 'Thịt heo nạc', 'Thịt vịt', 'Phô mai', 'Bơ thực vật'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Đậu hũ', 'Gạo lứt', 'Yến mạch', 'Chuối tiêu', 'Cam', 'Ổi', 'Dầu ô liu']
  },

  // [17] Coronary Artery Disease - same as High Cholesterol
  17: {
    avoid: ['Butter', 'Cheese', 'Bacon', 'Ham', 'Sausage', 'Egg yolk', 'Thịt heo nạc', 'Thịt vịt', 'Trứng gà', 'Trứng vịt', 'Phô mai', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Fish', 'Chicken breast', 'Tofu', 'Broccoli', 'Spinach', 'Carrots', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Đậu hũ', 'Đậu nành', 'Gạo lứt', 'Yến mạch', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cam', 'Ổi', 'Mè rang', 'Dầu ô liu']
  },

  // [18] Atherosclerosis - same as High Cholesterol
  18: {
    avoid: ['Butter', 'Cheese', 'Bacon', 'Ham', 'Sausage', 'Egg yolk', 'Thịt heo nạc', 'Thịt vịt', 'Trứng gà', 'Trứng vịt', 'Phô mai', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Fish', 'Chicken breast', 'Tofu', 'Broccoli', 'Spinach', 'Carrots', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Đậu hũ', 'Đậu nành', 'Gạo lứt', 'Yến mạch', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cam', 'Ổi', 'Mè rang', 'Dầu ô liu']
  },

  // [19] Asthma (J45)
  19: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Cheese'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Fish', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Cam', 'Ổi', 'Gạo lứt', 'Dầu ô liu']
  },

  // [20] COPD (J440)
  20: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Cam', 'Ổi', 'Gạo lứt', 'Yến mạch', 'Dầu ô liu']
  },

  // [21] Hypothyroidism (E039)
  21: {
    avoid: ['Broccoli', 'Cabbage', 'Cauliflower', 'Soy', 'Bí đỏ', 'Cải bắp', 'Bắp cải tím', 'Cải xanh', 'Đậu nành'],
    recommend: ['Fish', 'Seafood', 'Eggs', 'Cá rô phi', 'Cá tra', 'Cá chép', 'Cá thu', 'Tôm sú', 'Tôm thẻ', 'Nghêu', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải ngọt', 'Thịt gà', 'Gạo lứt', 'Yến mạch', 'Mè rang']
  },

  // [22] Hyperthyroidism (E05)
  22: {
    avoid: ['Fish', 'Seafood', 'Cá rô phi', 'Cá tra', 'Cá chép', 'Cá thu', 'Tôm sú', 'Tôm thẻ', 'Mực ống', 'Nghêu', 'Mè rang'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Thịt gà', 'Đậu hũ', 'Gạo tẻ trắng', 'Gạo lứt', 'Chuối tiêu', 'Cam']
  },

  // [23] Rheumatoid Arthritis (M06)
  23: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Butter', 'Thịt heo nạc', 'Thịt vịt', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Đậu hũ', 'Gạo lứt', 'Yến mạch', 'Cam', 'Ổi', 'Dầu ô liu']
  },

  // [24] Psoriasis - same as RA
  24: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Butter', 'Thịt heo nạc', 'Thịt vịt', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Cá rô phi', 'Cá tra', 'Cá thu', 'Đậu hũ', 'Gạo lứt', 'Yến mạch', 'Cam', 'Ổi', 'Dầu ô liu']
  },

  // [25] Crohn's Disease (K50)
  25: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Broccoli', 'Spinach', 'Beans', 'Nuts', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Đậu cove', 'Đậu đũa', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Bột mì nguyên cám'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Rice', 'Carrots', 'Bananas', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu phụ non', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Cà rốt', 'Khoai lang', 'Chuối tiêu', 'Đu đủ', 'Sữa chua không đường']
  },

  // [26] Ulcerative Colitis - same as Crohn's
  26: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Broccoli', 'Spinach', 'Beans', 'Nuts', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Đậu cove', 'Đậu đũa', 'Đậu nành', 'Đậu xanh', 'Đậu đen', 'Đậu đỏ', 'Bột mì nguyên cám'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Rice', 'Carrots', 'Bananas', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu phụ non', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Cà rốt', 'Khoai lang', 'Chuối tiêu', 'Đu đủ', 'Sữa chua không đường']
  },

  // [27] Lactose Intolerance (E73)
  27: {
    avoid: ['Milk', 'Yogurt', 'Cheese', 'Ice cream', 'Sữa bò', 'Sữa chua không đường', 'Phô mai', 'Sữa dê'],
    recommend: ['Soy milk', 'Tofu', 'Fish', 'Chicken', 'Sữa đậu nành', 'Đậu hũ', 'Đậu phụ non', 'Đậu nành', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cá rô phi', 'Cá tra', 'Cam', 'Ổi', 'Gạo lứt', 'Yến mạch']
  },

  // [28] Food Allergy (T78)
  28: {
    avoid: ['Peanuts', 'Nuts', 'Soy', 'Shellfish', 'Đậu nành', 'Hạt điều', 'Đậu phộng', 'Mè rang', 'Tôm sú', 'Tôm thẻ', 'Mực ống', 'Nghêu'],
    recommend: ['Chicken breast', 'Fish', 'Vegetables', 'Fruits', 'Rice', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Rau muống', 'Rau dền', 'Cà rốt', 'Cam', 'Ổi', 'Gạo tẻ trắng', 'Gạo lứt']
  },

  // [29] Diverticulitis (K57)
  29: {
    avoid: ['Nuts', 'Seeds', 'Corn', 'Mè rang', 'Hạt điều', 'Đậu phộng', 'Ngô'],
    recommend: ['Chicken breast', 'Fish', 'Tofu', 'Rice', 'Carrots', 'Bananas', 'Thịt gà', 'Cá rô phi', 'Đậu hũ', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Cà rốt', 'Khoai lang', 'Chuối tiêu', 'Đu đủ', 'Sữa chua không đường']
  },

  // [30] Cirrhosis (K746)
  30: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Beef', 'Pork', 'Eggs', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt vịt', 'Trứng gà'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Cà rốt', 'Cải bắp', 'Thịt gà', 'Cá rô phi', 'Đậu hũ', 'Gạo tẻ trắng', 'Gạo lứt', 'Cam', 'Ổi']
  },

  // [31] Hepatitis B - same as Fatty Liver
  31: {
    avoid: ['Butter', 'Sugar', 'Alcohol', 'Bacon', 'Gạo nếp', 'Mật ong', 'Thịt heo nạc', 'Thịt vịt', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo lứt', 'Yến mạch', 'Cam', 'Ổi']
  },

  // [32] Hepatitis C - same as Fatty Liver
  32: {
    avoid: ['Butter', 'Sugar', 'Alcohol', 'Bacon', 'Gạo nếp', 'Mật ong', 'Thịt heo nạc', 'Thịt vịt', 'Bơ thực vật', 'Dầu đậu nành'],
    recommend: ['Broccoli', 'Spinach', 'Carrots', 'Tomatoes', 'Chicken breast', 'Fish', 'Tofu', 'Rau muống', 'Rau dền', 'Bí đỏ', 'Cà rốt', 'Cải bắp', 'Cải ngọt', 'Thịt gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo lứt', 'Yến mạch', 'Cam', 'Ổi']
  },

  // [33] Cholera (A00)
  33: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Tomatoes', 'Citrus', 'Cà chua', 'Ớt chuông'],
    recommend: ['Rice', 'Bananas', 'Chicken', 'Carrots', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Chuối tiêu', 'Đu đủ', 'Dưa hấu', 'Sữa chua không đường', 'Cà rốt', 'Khoai lang']
  },

  // [34] Typhoid - same as Cholera
  34: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Tomatoes', 'Citrus', 'Cà chua', 'Ớt chuông'],
    recommend: ['Rice', 'Bananas', 'Chicken', 'Carrots', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Chuối tiêu', 'Đu đủ', 'Dưa hấu', 'Sữa chua không đường', 'Cà rốt', 'Khoai lang']
  },

  // [35] Tuberculosis (A15) - needs nutrition
  35: {
    avoid: [],
    recommend: ['Beef', 'Pork', 'Chicken', 'Fish', 'Eggs', 'Milk', 'Nuts', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt gà', 'Thịt vịt', 'Trứng gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo tẻ trắng', 'Gạo lứt', 'Yến mạch', 'Sữa bò', 'Mật ong']
  },

  // [36] Pulmonary TB - same as TB
  36: {
    avoid: [],
    recommend: ['Beef', 'Pork', 'Chicken', 'Fish', 'Eggs', 'Milk', 'Nuts', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt gà', 'Thịt vịt', 'Trứng gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo tẻ trắng', 'Gạo lứt', 'Yến mạch', 'Sữa bò', 'Mật ong']
  },

  // [37] TB Meningitis - same as TB
  37: {
    avoid: [],
    recommend: ['Beef', 'Pork', 'Chicken', 'Fish', 'Eggs', 'Milk', 'Nuts', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt gà', 'Thịt vịt', 'Trứng gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo tẻ trắng', 'Gạo lứt', 'Yến mạch', 'Sữa bò', 'Mật ong']
  },

  // [38] E.coli Infection - same as Cholera
  38: {
    avoid: ['Salt', 'Soy sauce', 'Bacon', 'Sausage', 'Tomatoes', 'Citrus', 'Cà chua', 'Ớt chuông', 'Thịt heo nạc', 'Thịt vịt'],
    recommend: ['Rice', 'Bananas', 'Chicken', 'Fish', 'Carrots', 'Gạo tẻ trắng', 'Bún tươi', 'Bánh phở', 'Chuối tiêu', 'Đu đủ', 'Dưa hấu', 'Sữa chua không đường', 'Cà rốt', 'Khoai lang', 'Thịt gà', 'Cá rô phi']
  },

  // [39] TB Meningitis duplicate - same as TB
  39: {
    avoid: [],
    recommend: ['Beef', 'Pork', 'Chicken', 'Fish', 'Eggs', 'Milk', 'Nuts', 'Thịt heo nạc', 'Thịt bò nạc', 'Thịt gà', 'Thịt vịt', 'Trứng gà', 'Cá rô phi', 'Cá tra', 'Đậu hũ', 'Đậu nành', 'Gạo tẻ trắng', 'Gạo lứt', 'Yến mạch', 'Sữa bò', 'Mật ong']
  },
};

async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'Health',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'Kiet2004',
  });

  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('🚀 Generating comprehensive food recommendations for ALL 39 health conditions...\n');

    // Create a map of food names to IDs
    const foodMapResult = await client.query('SELECT food_id, name, name_vi FROM food');
    const foodNameToId = {};
    for (const row of foodMapResult.rows) {
      foodNameToId[row.name] = row.food_id;
      if (row.name_vi) {
        foodNameToId[row.name_vi] = row.food_id;
      }
    }

    console.log(`📦 Found ${Object.keys(foodNameToId).length} food name mappings\n`);

    // Insert recommendations
    let totalInserted = 0;
    let totalSkipped = 0;

    for (const [conditionId, data] of Object.entries(COMPREHENSIVE_RECOMMENDATIONS)) {
      console.log(`\n💊 Processing Condition ${conditionId}...`);
      
      // Insert AVOID recommendations
      for (const foodName of data.avoid) {
        const foodId = foodNameToId[foodName];
        if (!foodId) {
          console.log(`  ⚠️  Food not found: ${foodName}`);
          totalSkipped++;
          continue;
        }

        await client.query(
          `INSERT INTO conditionfoodrecommendation (food_id, condition_id, recommendation_type)
           VALUES ($1, $2, 'avoid')
           ON CONFLICT (food_id, condition_id) DO UPDATE SET recommendation_type = 'avoid'`,
          [foodId, parseInt(conditionId)]
        );
        totalInserted++;
      }

      // Insert RECOMMEND recommendations
      for (const foodName of data.recommend) {
        const foodId = foodNameToId[foodName];
        if (!foodId) {
          console.log(`  ⚠️  Food not found: ${foodName}`);
          totalSkipped++;
          continue;
        }

        await client.query(
          `INSERT INTO conditionfoodrecommendation (food_id, condition_id, recommendation_type)
           VALUES ($1, $2, 'recommend')
           ON CONFLICT (food_id, condition_id) DO UPDATE SET recommendation_type = 'recommend'`,
          [foodId, parseInt(conditionId)]
        );
        totalInserted++;
      }

      console.log(`  ✅ Condition ${conditionId}: ${data.avoid.length} avoid, ${data.recommend.length} recommend`);
    }

    console.log(`\n📊 Total recommendations inserted: ${totalInserted}`);
    console.log(`⚠️  Foods not found (skipped): ${totalSkipped}\n`);

    // Verification
    console.log('🔍 Final Coverage Report:\n');
    const coverageResult = await client.query(`
      SELECT hc.condition_id as id, hc.name_vi,
             COUNT(DISTINCT CASE WHEN cfr.recommendation_type = 'avoid' THEN cfr.food_id END) as avoid_count,
             COUNT(DISTINCT CASE WHEN cfr.recommendation_type = 'recommend' THEN cfr.food_id END) as recommend_count
      FROM healthcondition hc
      LEFT JOIN conditionfoodrecommendation cfr ON hc.condition_id = cfr.condition_id
      GROUP BY hc.condition_id, hc.name_vi
      ORDER BY hc.condition_id
    `);

    let fullCoverage = 0;
    for (const row of coverageResult.rows) {
      const status = (row.avoid_count > 0 || row.recommend_count > 0) ? '✅' : '❌';
      console.log(`${status} [${row.id}] ${row.name_vi}: ${row.avoid_count} avoid, ${row.recommend_count} recommend`);
      if (row.avoid_count > 0 || row.recommend_count > 0) fullCoverage++;
    }

    console.log(`\n🎯 Coverage: ${fullCoverage}/39 conditions (${Math.round(fullCoverage/39*100)}%)`);

    await client.query('COMMIT');
    console.log('\n✅ DONE! All 39 health conditions now have food recommendations! 🎉');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
