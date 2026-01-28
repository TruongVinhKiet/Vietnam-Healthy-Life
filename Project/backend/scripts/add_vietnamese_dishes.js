const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

// ============================================================================
// VIETNAMESE DISHES WITH RECIPES
// Format: { name, category, ingredients: [{food_name, weight_g}] }
// ============================================================================

const VIETNAMESE_DISHES = [
  // PHỞ & BÚN
  {
    name: 'Phở bò tái', category: 'main_course',
    ingredients: [
      {food: 'Bánh phở', weight: 200},
      {food: 'Thịt bò nạc', weight: 100},
      {food: 'Hành tây', weight: 20},
      {food: 'Gừng', weight: 5},
      {food: 'Rau muống', weight: 30}
    ]
  },
  {
    name: 'Bún bò Huế', category: 'main_course',
    ingredients: [
      {food: 'Bún', weight: 200},
      {food: 'Thịt bò nạc', weight: 80},
      {food: 'Thịt heo nạc', weight: 50},
      {food: 'Hành tây', weight: 20},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Bún chả Hà Nội', category: 'main_course',
    ingredients: [
      {food: 'Bún', weight: 200},
      {food: 'Thịt heo nạc', weight: 120},
      {food: 'Rau muống', weight: 50},
      {food: 'Cà rốt', weight: 30}
    ]
  },
  {
    name: 'Phở gà', category: 'main_course',
    ingredients: [
      {food: 'Bánh phở', weight: 200},
      {food: 'Chicken breast', weight: 100},
      {food: 'Hành tây', weight: 20},
      {food: 'Gừng', weight: 5},
      {food: 'Rau muống', weight: 30}
    ]
  },
  {
    name: 'Bún riêu cua', category: 'main_course',
    ingredients: [
      {food: 'Bún', weight: 200},
      {food: 'Trứng vịt', weight: 50},
      {food: 'Đậu phụ non', weight: 100},
      {food: 'Tomatoes', weight: 80},
      {food: 'Rau muống', weight: 40}
    ]
  },

  // CƠM (RICE DISHES)
  {
    name: 'Cơm tấm sườn', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 150},
      {food: 'Thịt heo nạc', weight: 100},
      {food: 'Trứng', weight: 50},
      {food: 'Cà rốt', weight: 30}
    ]
  },
  {
    name: 'Cơm gà xối mỡ', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 150},
      {food: 'Chicken breast', weight: 120},
      {food: 'Gừng', weight: 5},
      {food: 'Hành tây', weight: 15}
    ]
  },
  {
    name: 'Cơm chiên dương châu', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 150},
      {food: 'Trứng', weight: 50},
      {food: 'Tôm sú', weight: 60},
      {food: 'Thịt heo nạc', weight: 40},
      {food: 'Cà rốt', weight: 30}
    ]
  },
  {
    name: 'Cơm gà Hải Nam', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 150},
      {food: 'Chicken breast', weight: 120},
      {food: 'Gừng', weight: 8},
      {food: 'Hành tây', weight: 15}
    ]
  },
  {
    name: 'Cơm lam', category: 'main_course',
    ingredients: [
      {food: 'Gạo nếp', weight: 150},
      {food: 'Mè', weight: 10}
    ]
  },

  // MÓN XÀO (STIR-FRY)
  {
    name: 'Thịt bò xào rau muống', category: 'main_course',
    ingredients: [
      {food: 'Thịt bò nạc', weight: 120},
      {food: 'Rau muống', weight: 150},
      {food: 'Tỏi', weight: 10},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Gà xào sả ớt', category: 'main_course',
    ingredients: [
      {food: 'Chicken breast', weight: 150},
      {food: 'Hành tây', weight: 40},
      {food: 'Tỏi', weight: 10},
      {food: 'Ớt chuông', weight: 30}
    ]
  },
  {
    name: 'Rau muống xào tỏi', category: 'side_dish',
    ingredients: [
      {food: 'Rau muống', weight: 200},
      {food: 'Tỏi', weight: 15}
    ]
  },
  {
    name: 'Cải bắp xào tỏi', category: 'side_dish',
    ingredients: [
      {food: 'Cải bắp', weight: 200},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Đậu phụ xào cà chua', category: 'main_course',
    ingredients: [
      {food: 'Đậu phụ non', weight: 200},
      {food: 'Tomatoes', weight: 100},
      {food: 'Hành tây', weight: 30},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Thịt heo xào củ hành', category: 'main_course',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 150},
      {food: 'Hành tây', weight: 80},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Mực xào chua ngọt', category: 'main_course',
    ingredients: [
      {food: 'Mực ống', weight: 150},
      {food: 'Ớt chuông', weight: 50},
      {food: 'Hành tây', weight: 40},
      {food: 'Tomatoes', weight: 50}
    ]
  },
  {
    name: 'Tôm rim mặn', category: 'main_course',
    ingredients: [
      {food: 'Tôm sú', weight: 150},
      {food: 'Tỏi', weight: 10},
      {food: 'Gừng', weight: 5}
    ]
  },

  // CANH (SOUP)
  {
    name: 'Canh chua cá', category: 'soup',
    ingredients: [
      {food: 'Cá tra', weight: 120},
      {food: 'Tomatoes', weight: 80},
      {food: 'Bí đao', weight: 100},
      {food: 'Rau muống', weight: 50}
    ]
  },
  {
    name: 'Canh bí đỏ', category: 'soup',
    ingredients: [
      {food: 'Bí đỏ', weight: 200},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Canh rau dền nấu tôm', category: 'soup',
    ingredients: [
      {food: 'Rau dền', weight: 150},
      {food: 'Tôm thẻ', weight: 80},
      {food: 'Tỏi', weight: 5}
    ]
  },
  {
    name: 'Canh cải thảo nấu thịt', category: 'soup',
    ingredients: [
      {food: 'Cải bắp', weight: 150},
      {food: 'Thịt heo nạc', weight: 80},
      {food: 'Hành tây', weight: 20}
    ]
  },
  {
    name: 'Canh khổ qua nhồi thịt', category: 'soup',
    ingredients: [
      {food: 'Mướp đắng', weight: 150},
      {food: 'Thịt heo nạc', weight: 100},
      {food: 'Hành tây', weight: 20}
    ]
  },
  {
    name: 'Canh nghêu', category: 'soup',
    ingredients: [
      {food: 'Nghêu', weight: 150},
      {food: 'Rau muống', weight: 80},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Canh cá rô', category: 'soup',
    ingredients: [
      {food: 'Cá rô phi', weight: 120},
      {food: 'Tomatoes', weight: 60},
      {food: 'Hành tây', weight: 30},
      {food: 'Rau muống', weight: 50}
    ]
  },

  // CHÁO (PORRIDGE)
  {
    name: 'Cháo gà', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 60},
      {food: 'Chicken breast', weight: 80},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Cháo cá', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 60},
      {food: 'Cá tra', weight: 80},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Cháo lươn', category: 'main_course',
    ingredients: [
      {food: 'Gạo trắng', weight: 60},
      {food: 'Gừng', weight: 8},
      {food: 'Hành tây', weight: 15}
    ]
  },
  {
    name: 'Cháo yến mạch', category: 'breakfast',
    ingredients: [
      {food: 'Yến mạch', weight: 80},
      {food: 'Sữa tươi nguyên chất', weight: 100},
      {food: 'Chuối tiêu', weight: 50}
    ]
  },
  {
    name: 'Cháo gạo lứt rau củ', category: 'main_course',
    ingredients: [
      {food: 'Gạo lứt', weight: 60},
      {food: 'Cà rốt', weight: 50},
      {food: 'Bí đỏ', weight: 50}
    ]
  },

  // GỎI & SALAD
  {
    name: 'Gỏi gà bắp cải', category: 'salad',
    ingredients: [
      {food: 'Chicken breast', weight: 100},
      {food: 'Cải bắp', weight: 100},
      {food: 'Cà rốt', weight: 50},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Gỏi ngó sen tôm thịt', category: 'salad',
    ingredients: [
      {food: 'Tôm sú', weight: 80},
      {food: 'Thịt heo nạc', weight: 60},
      {food: 'Cà rốt', weight: 50}
    ]
  },
  {
    name: 'Gỏi đu đủ', category: 'salad',
    ingredients: [
      {food: 'Đu đủ', weight: 150},
      {food: 'Cà rốt', weight: 50},
      {food: 'Tôm thẻ', weight: 60}
    ]
  },
  {
    name: 'Salad rau củ', category: 'salad',
    ingredients: [
      {food: 'Cải bắp', weight: 80},
      {food: 'Cà rốt', weight: 50},
      {food: 'Ớt chuông', weight: 40},
      {food: 'Hành tây', weight: 20}
    ]
  },

  // MÓN NƯỚNG (GRILLED)
  {
    name: 'Cá thu nướng', category: 'main_course',
    ingredients: [
      {food: 'Cá thu', weight: 150},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Gà nướng mật ong', category: 'main_course',
    ingredients: [
      {food: 'Chicken breast', weight: 150},
      {food: 'Tỏi', weight: 10},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Sườn nướng', category: 'main_course',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 150},
      {food: 'Tỏi', weight: 10},
      {food: 'Hành tây', weight: 20}
    ]
  },
  {
    name: 'Tôm nướng', category: 'main_course',
    ingredients: [
      {food: 'Tôm sú', weight: 150},
      {food: 'Tỏi', weight: 5}
    ]
  },
  {
    name: 'Mực nướng sa tế', category: 'main_course',
    ingredients: [
      {food: 'Mực ống', weight: 150},
      {food: 'Tỏi', weight: 10},
      {food: 'Ớt chuông', weight: 30}
    ]
  },

  // MÓN HẤP (STEAMED)
  {
    name: 'Cá hấp xì dầu', category: 'main_course',
    ingredients: [
      {food: 'Cá rô phi', weight: 150},
      {food: 'Gừng', weight: 8},
      {food: 'Hành tây', weight: 20}
    ]
  },
  {
    name: 'Gà hấp lá chanh', category: 'main_course',
    ingredients: [
      {food: 'Chicken breast', weight: 150},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Trứng hấp', category: 'side_dish',
    ingredients: [
      {food: 'Trứng', weight: 100},
      {food: 'Hành tây', weight: 10}
    ]
  },
  {
    name: 'Đậu phụ hấp nấm', category: 'main_course',
    ingredients: [
      {food: 'Đậu phụ non', weight: 200},
      {food: 'Nấm rơm', weight: 80},
      {food: 'Tỏi', weight: 5}
    ]
  },

  // MÓN LUỘC (BOILED)
  {
    name: 'Gà luộc', category: 'main_course',
    ingredients: [
      {food: 'Chicken breast', weight: 150},
      {food: 'Gừng', weight: 5}
    ]
  },
  {
    name: 'Tôm luộc', category: 'appetizer',
    ingredients: [
      {food: 'Tôm sú', weight: 150}
    ]
  },
  {
    name: 'Trứng luộc', category: 'side_dish',
    ingredients: [
      {food: 'Trứng', weight: 100}
    ]
  },
  {
    name: 'Rau luộc', category: 'side_dish',
    ingredients: [
      {food: 'Cải bắp', weight: 100},
      {food: 'Cà rốt', weight: 50},
      {food: 'Bí đỏ', weight: 50}
    ]
  },
  {
    name: 'Khoai lang luộc', category: 'snack',
    ingredients: [
      {food: 'Khoai lang', weight: 200}
    ]
  },
  {
    name: 'Khoai tây luộc', category: 'snack',
    ingredients: [
      {food: 'Khoai tây', weight: 200}
    ]
  },
  {
    name: 'Ngô luộc', category: 'snack',
    ingredients: [
      {food: 'Ngô', weight: 200}
    ]
  },

  // MÓN RIM/KHO (BRAISED)
  {
    name: 'Cá kho tộ', category: 'main_course',
    ingredients: [
      {food: 'Cá tra', weight: 150},
      {food: 'Hành tây', weight: 30},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Thịt kho tàu', category: 'main_course',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 150},
      {food: 'Trứng vịt', weight: 100},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Gà kho gừng', category: 'main_course',
    ingredients: [
      {food: 'Chicken breast', weight: 150},
      {food: 'Gừng', weight: 15},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Đậu phụ kho', category: 'main_course',
    ingredients: [
      {food: 'Đậu phụ non', weight: 200},
      {food: 'Tomatoes', weight: 60},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Cá chép kho riềng', category: 'main_course',
    ingredients: [
      {food: 'Cá chép', weight: 150},
      {food: 'Gừng', weight: 15},
      {food: 'Hành tây', weight: 30}
    ]
  },

  // ĂN VẶT & TRÁNG MIỆNG
  {
    name: 'Chè đậu xanh', category: 'dessert',
    ingredients: [
      {food: 'Đậu xanh', weight: 100},
      {food: 'Sữa đậu nành', weight: 150}
    ]
  },
  {
    name: 'Chè bí đỏ', category: 'dessert',
    ingredients: [
      {food: 'Bí đỏ', weight: 150},
      {food: 'Sữa tươi nguyên chất', weight: 100}
    ]
  },
  {
    name: 'Sinh tố bơ', category: 'beverage',
    ingredients: [
      {food: 'Avocado', weight: 150},
      {food: 'Sữa tươi nguyên chất', weight: 150}
    ]
  },
  {
    name: 'Sinh tố chuối', category: 'beverage',
    ingredients: [
      {food: 'Chuối tiêu', weight: 150},
      {food: 'Sữa tươi nguyên chất', weight: 150}
    ]
  },
  {
    name: 'Sinh tố dâu tây', category: 'beverage',
    ingredients: [
      {food: 'Strawberries', weight: 150},
      {food: 'Sữa tươi nguyên chất', weight: 150}
    ]
  },
  {
    name: 'Nước ép cam', category: 'beverage',
    ingredients: [
      {food: 'Orange', weight: 200}
    ]
  },
  {
    name: 'Nước ép ổi', category: 'beverage',
    ingredients: [
      {food: 'Ổi', weight: 200}
    ]
  },
  {
    name: 'Trái cây trộn', category: 'dessert',
    ingredients: [
      {food: 'Đu đủ', weight: 80},
      {food: 'Chuối tiêu', weight: 80},
      {food: 'Ổi', weight: 80}
    ]
  },

  // MÓN CHAY (VEGETARIAN)
  {
    name: 'Đậu phụ sốt cà chua', category: 'main_course',
    ingredients: [
      {food: 'Đậu phụ non', weight: 200},
      {food: 'Tomatoes', weight: 100},
      {food: 'Hành tây', weight: 40},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Rau củ xào chay', category: 'main_course',
    ingredients: [
      {food: 'Cải bắp', weight: 100},
      {food: 'Cà rốt', weight: 80},
      {food: 'Bí đỏ', weight: 80},
      {food: 'Nấm rơm', weight: 60}
    ]
  },
  {
    name: 'Cơm chiên chay', category: 'main_course',
    ingredients: [
      {food: 'Gạo lứt', weight: 150},
      {food: 'Cà rốt', weight: 50},
      {food: 'Đậu cove', weight: 50},
      {food: 'Ngô', weight: 50}
    ]
  },
  {
    name: 'Canh rau củ chay', category: 'soup',
    ingredients: [
      {food: 'Bí đỏ', weight: 100},
      {food: 'Cà rốt', weight: 80},
      {food: 'Su su', weight: 80},
      {food: 'Nấm rơm', weight: 50}
    ]
  },

  // MÓN SÁNG (BREAKFAST)
  {
    name: 'Bánh mì trứng', category: 'breakfast',
    ingredients: [
      {food: 'Bread', weight: 100},
      {food: 'Trứng', weight: 50},
      {food: 'Cà rốt', weight: 30}
    ]
  },
  {
    name: 'Xôi gà', category: 'breakfast',
    ingredients: [
      {food: 'Gạo nếp', weight: 150},
      {food: 'Chicken breast', weight: 80},
      {food: 'Hành tây', weight: 20}
    ]
  },
  {
    name: 'Xôi đậu xanh', category: 'breakfast',
    ingredients: [
      {food: 'Gạo nếp', weight: 150},
      {food: 'Đậu xanh', weight: 80}
    ]
  },
  {
    name: 'Sữa chua hoa quả', category: 'breakfast',
    ingredients: [
      {food: 'Greek yogurt', weight: 150},
      {food: 'Chuối tiêu', weight: 50},
      {food: 'Ổi', weight: 50}
    ]
  },

  // THÊM MÓN ĐA DẠNG
  {
    name: 'Miến xào hải sản', category: 'main_course',
    ingredients: [
      {food: 'Tôm sú', weight: 80},
      {food: 'Mực ống', weight: 80},
      {food: 'Cà rốt', weight: 50},
      {food: 'Cải bắp', weight: 50}
    ]
  },
  {
    name: 'Nem rán', category: 'appetizer',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 100},
      {food: 'Cà rốt', weight: 50},
      {food: 'Nấm rơm', weight: 40}
    ]
  },
  {
    name: 'Chả giò', category: 'appetizer',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 80},
      {food: 'Tôm thẻ', weight: 60},
      {food: 'Cà rốt', weight: 40},
      {food: 'Nấm rơm', weight: 30}
    ]
  },
  {
    name: 'Bánh xèo', category: 'main_course',
    ingredients: [
      {food: 'Bột gạo', weight: 100},
      {food: 'Tôm sú', weight: 60},
      {food: 'Thịt heo nạc', weight: 50},
      {food: 'Rau muống', weight: 50}
    ]
  },
  {
    name: 'Bánh cuốn', category: 'breakfast',
    ingredients: [
      {food: 'Bột gạo', weight: 100},
      {food: 'Thịt heo nạc', weight: 60},
      {food: 'Nấm rơm', weight: 40}
    ]
  },
  {
    name: 'Hủ tiếu Nam Vang', category: 'main_course',
    ingredients: [
      {food: 'Bún', weight: 200},
      {food: 'Thịt heo nạc', weight: 80},
      {food: 'Tôm thẻ', weight: 60},
      {food: 'Mực ống', weight: 40}
    ]
  },
  {
    name: 'Mì Quảng', category: 'main_course',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 80},
      {food: 'Tôm sú', weight: 60},
      {food: 'Trứng', weight: 50},
      {food: 'Rau muống', weight: 40}
    ]
  },
  {
    name: 'Cao lầu Hội An', category: 'main_course',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 100},
      {food: 'Rau muống', weight: 60},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Bánh bèo', category: 'snack',
    ingredients: [
      {food: 'Bột gạo', weight: 80},
      {food: 'Tôm thẻ', weight: 40}
    ]
  },
  {
    name: 'Bánh bột lọc', category: 'snack',
    ingredients: [
      {food: 'Tôm sú', weight: 60},
      {food: 'Thịt heo nạc', weight: 40}
    ]
  },
  {
    name: 'Bánh ít trần', category: 'snack',
    ingredients: [
      {food: 'Gạo nếp', weight: 100},
      {food: 'Đậu xanh', weight: 60}
    ]
  },
  {
    name: 'Chả cá Lã Vọng', category: 'main_course',
    ingredients: [
      {food: 'Cá tra', weight: 150},
      {food: 'Rau muống', weight: 80},
      {food: 'Hành tây', weight: 30},
      {food: 'Tỏi', weight: 10}
    ]
  },
  {
    name: 'Bún thịt nướng', category: 'main_course',
    ingredients: [
      {food: 'Bún', weight: 200},
      {food: 'Thịt heo nạc', weight: 120},
      {food: 'Rau muống', weight: 50},
      {food: 'Cà rốt', weight: 30}
    ]
  },
  {
    name: 'Bún cá', category: 'main_course',
    ingredients: [
      {food: 'Bún', weight: 200},
      {food: 'Cá tra', weight: 100},
      {food: 'Tomatoes', weight: 60},
      {food: 'Rau muống', weight: 50}
    ]
  },
  {
    name: 'Súp bí đỏ', category: 'soup',
    ingredients: [
      {food: 'Bí đỏ', weight: 200},
      {food: 'Sữa tươi nguyên chất', weight: 100},
      {food: 'Hành tây', weight: 30}
    ]
  },
  {
    name: 'Súp gà nấm', category: 'soup',
    ingredients: [
      {food: 'Chicken breast', weight: 100},
      {food: 'Nấm rơm', weight: 80},
      {food: 'Cà rốt', weight: 50}
    ]
  },
  {
    name: 'Lẩu thái', category: 'main_course',
    ingredients: [
      {food: 'Tôm sú', weight: 100},
      {food: 'Mực ống', weight: 80},
      {food: 'Nấm rơm', weight: 60},
      {food: 'Tomatoes', weight: 60},
      {food: 'Rau muống', weight: 50}
    ]
  },
  {
    name: 'Lẩu gà lá é', category: 'main_course',
    ingredients: [
      {food: 'Chicken breast', weight: 150},
      {food: 'Nấm rơm', weight: 80},
      {food: 'Rau muống', weight: 60}
    ]
  },
  {
    name: 'Bò nhúng dấm', category: 'main_course',
    ingredients: [
      {food: 'Thịt bò nạc', weight: 150},
      {food: 'Rau muống', weight: 80},
      {food: 'Cải bắp', weight: 60}
    ]
  },
  {
    name: 'Gỏi cuốn tôm thịt', category: 'appetizer',
    ingredients: [
      {food: 'Tôm sú', weight: 80},
      {food: 'Thịt heo nạc', weight: 60},
      {food: 'Bún', weight: 50},
      {food: 'Rau muống', weight: 40}
    ]
  },
  {
    name: 'Nem nướng', category: 'appetizer',
    ingredients: [
      {food: 'Thịt heo nạc', weight: 120},
      {food: 'Tỏi', weight: 10}
    ]
  }
];

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
    console.log('🚀 Adding Vietnamese dishes with recipes...\n');

    // First, get all food IDs
    const foodResult = await client.query('SELECT food_id, name, name_vi FROM food');
    const foodMap = new Map();
    foodResult.rows.forEach(f => {
      foodMap.set(f.name, f.food_id);
      if (f.name_vi) foodMap.set(f.name_vi, f.food_id);
    });

    let dishCount = 0;
    let ingredientCount = 0;
    const missingFoods = new Set();

    for (const dish of VIETNAMESE_DISHES) {
      // Check if dish already exists
      const existingDish = await client.query(
        'SELECT dish_id FROM dish WHERE name = $1',
        [dish.name]
      );

      let dishId;
      if (existingDish.rows.length > 0) {
        console.log(`⏭️  Dish exists: ${dish.name}`);
        dishId = existingDish.rows[0].dish_id;
        
        // Delete old ingredients to refresh
        await client.query('DELETE FROM dishingredient WHERE dish_id = $1', [dishId]);
      } else {
        // Insert new dish (created_by_admin = 1 to satisfy constraint)
        const result = await client.query(
          `INSERT INTO dish (name, category, created_by_admin, created_at, updated_at)
           VALUES ($1, $2, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
           RETURNING dish_id`,
          [dish.name, dish.category]
        );
        dishId = result.rows[0].dish_id;
        dishCount++;
        console.log(`✅ Added dish: ${dish.name} (ID: ${dishId})`);
      }

      // Add ingredients
      for (const ing of dish.ingredients) {
        const foodId = foodMap.get(ing.food);
        if (!foodId) {
          missingFoods.add(ing.food);
          console.log(`   ⚠️  Missing food: ${ing.food}`);
          continue;
        }

        await client.query(
          `INSERT INTO dishingredient (dish_id, food_id, weight_g)
           VALUES ($1, $2, $3)`,
          [dishId, foodId, ing.weight]
        );
        ingredientCount++;
      }
    }

    console.log(`\n📊 Summary:`);
    console.log(`✅ Added ${dishCount} new dishes`);
    console.log(`✅ Added ${ingredientCount} ingredient entries`);
    
    if (missingFoods.size > 0) {
      console.log(`\n⚠️  Missing foods (${missingFoods.size}):`);
      Array.from(missingFoods).slice(0, 20).forEach(f => console.log(`   - ${f}`));
      if (missingFoods.size > 20) {
        console.log(`   ... and ${missingFoods.size - 20} more`);
      }
    }

    // Verify total dishes
    const totalResult = await client.query('SELECT COUNT(*) FROM dish');
    console.log(`\n📈 Total dishes in database: ${totalResult.rows[0].count}`);

    await client.query('COMMIT');
    console.log('\n✅ Vietnamese dishes added successfully! 🎉');

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
