-- Migration 4-8: All remaining data insertions (clean version)
-- Date: 2025-12-08

-- ============= MIGRATION 4: DISHES =============
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, created_by_admin) VALUES
('Quinoa Buddha Bowl Vietnam', 'Quinoa bowl kieu Viet', 'Quinoa mixed vegetables tofu Vietnamese style', 'main_course', 350.00, 1),
('Black Rice Stir-Fry Veggie', 'Gao den xao rau', 'Black rice stir-fried mixed vegetables', 'main_course', 300.00, 1),
('Beetroot Detox Salad', 'Salad cu den detox', 'Red beetroot salad lemon dressing', 'salad', 200.00, 1),
('Purple Sweet Potato Soup', 'Sup khoai lang tim', 'Creamy purple sweet potato soup', 'soup', 250.00, 1),
('Kabocha Pumpkin Curry', 'Cari bi do Nhat', 'Japanese pumpkin curry coconut milk', 'main_course', 300.00, 1),
('Enoki Mushroom Stir-Fry', 'Nam kim cham xao', 'Stir-fried enoki mushrooms garlic', 'side_dish', 150.00, 1),
('Lotus Root Salad Tangy', 'Goi ngo sen', 'Lotus root salad pickled tangy', 'salad', 180.00, 1),
('Sea Bass Steamed Ginger', 'Ca hap gung', 'Steamed sea bass fresh ginger', 'main_course', 250.00, 1),
('Mackerel Grilled Turmeric', 'Ca thu nuong nghe', 'Grilled mackerel turmeric marinade', 'main_course', 200.00, 1),
('Squid Stir-Fry Lemongrass', 'Muc xao sa', 'Stir-fried squid lemongrass chili', 'main_course', 220.00, 1),
('Tempeh Stir-Fry Vegetables', 'Tempeh xao rau', 'Tempeh stir-fried mixed vegetables', 'main_course', 250.00, 1),
('Edamame Garlic Butter', 'Dau nanh xanh boi toi', 'Steamed edamame garlic butter', 'appetizer', 120.00, 1),
('Dragon Fruit Smoothie Bowl', 'Smoothie bowl thanh long', 'Red dragon fruit smoothie bowl', 'breakfast', 300.00, 1),
('Longan Sticky Rice Sweet', 'Xoi nhan che', 'Sticky rice longan sweet dessert', 'dessert', 200.00, 1),
('Jackfruit Seed Curry', 'Cari hat mit', 'Jackfruit seed curry coconut', 'main_course', 280.00, 1),
('Bitter Melon Stuffed Pork', 'Kho qua nhoi thit', 'Bitter melon stuffed minced pork', 'main_course', 250.00, 1),
('Water Spinach Garlic Sauce', 'Rau muong xao toi', 'Water spinach stir-fried garlic', 'side_dish', 150.00, 1),
('Bok Choy Oyster Sauce', 'Cai thia sot dau hao', 'Baby bok choy oyster sauce', 'side_dish', 150.00, 1),
('Wood Ear Mushroom Soup', 'Canh nam meo', 'Wood ear mushroom vegetable soup', 'soup', 200.00, 1),
('Daikon Radish Pickled', 'Cu cai trang chua', 'Pickled daikon radish carrot', 'side_dish', 100.00, 1),
('Jicama Spring Rolls', 'Goi cuon cu san', 'Fresh spring rolls jicama shrimp', 'appetizer', 150.00, 1),
('Snow Pea Shrimp Stir-Fry', 'Dau Ha Lan xao tom', 'Snow peas stir-fried shrimp', 'main_course', 220.00, 1),
('Clam Soup Lemongrass', 'Canh ngao sa', 'Clam soup lemongrass broth', 'soup', 250.00, 1),
('Duck Breast Orange Glaze', 'Uc vit sot cam', 'Duck breast orange glaze sauce', 'main_course', 200.00, 1),
('Quail Egg Tamarind Sauce', 'Trung cut sot me', 'Quail eggs tamarind sauce', 'appetizer', 120.00, 1),
('Silken Tofu Ginger Syrup', 'Tau hu nuoc duong gung', 'Silken tofu ginger syrup dessert', 'dessert', 150.00, 1),
('Chia Seed Pudding Mango', 'Pudding hat chia xoai', 'Chia seed pudding mango topping', 'dessert', 180.00, 1),
('Flax Seed Crackers', 'Banh quy hat lanh', 'Flaxseed crackers healthy snack', 'snack', 80.00, 1),
('Pumpkin Seed Granola', 'Granola hat bi ngo', 'Homemade granola pumpkin seeds', 'breakfast', 100.00, 1),
('Walnut Energy Balls', 'Bo vien nang luong oc cho', 'Energy balls walnuts dates', 'snack', 60.00, 1);

-- ============= MIGRATION 5: DRINKS =============
INSERT INTO drink (name, vietnamese_name, description, category, base_liquid, default_volume_ml) VALUES
('Coconut Water Fresh Natural', 'Nuoc dua tuoi thien nhien', 'Fresh coconut water natural electrolytes', 'functional', 'Coconut', 250.00),
('Pandan Tea Aromatic', 'Tra la dua thom', 'Pandan leaf tea aromatic green', 'herbal_tea', 'Tea', 200.00),
('Chrysanthemum Honey Tea', 'Tra hoa cuc mat ong', 'Chrysanthemum flower honey tea', 'herbal_tea', 'Tea', 200.00),
('Ginger Lemon Turmeric Shot', 'Shot gung nghe chanh', 'Ginger turmeric lemon immunity shot', 'functional', 'Water', 50.00),
('Dragon Fruit Smoothie Red', 'Sinh to thanh long ruot do', 'Red dragon fruit smoothie creamy', 'smoothie', 'Milk', 300.00),
('Longan Ginger Tea Sweet', 'Che nhan gung', 'Longan ginger tea sweet warm', 'herbal_tea', 'Tea', 250.00),
('Lychee Rose Water Cooler', 'Nuoc vai hong ep lanh', 'Lychee rose water refreshing', 'juice', 'Water', 250.00),
('Passion Fruit Green Tea', 'Tra xanh chanh day', 'Green tea passion fruit tangy', 'tea', 'Tea', 300.00),
('Guava Lime Juice Fresh', 'Nuoc ep oi chanh', 'Fresh guava lime juice vitamin C', 'juice', 'Water', 250.00),
('Star Fruit Honey Drink', 'Nuoc khe mat ong', 'Star fruit honey cooling drink', 'juice', 'Water', 250.00),
('Pomelo Mint Infusion', 'Nuoc buoi bac ha', 'Pomelo mint infused water', 'infused_water', 'Water', 300.00),
('Basil Seed Lychee Drink', 'Nuoc hat e vai', 'Basil seeds lychee sweet drink', 'functional', 'Water', 300.00),
('Almond Milk Matcha Latte', 'Matcha latte sua hanh nhan', 'Matcha latte almond milk creamy', 'coffee_tea', 'Milk', 250.00),
('Chia Seed Lemonade', 'Nuoc chanh hat chia', 'Lemonade chia seeds refreshing', 'functional', 'Water', 300.00),
('Beetroot Apple Detox Juice', 'Nuoc ep cu den tao detox', 'Beetroot apple carrot detox juice', 'juice', 'Water', 250.00),
('Kaffir Lime Soda', 'Soda chanh makrut', 'Kaffir lime soda sparkling', 'soda', 'Water', 250.00),
('Lemongrass Ginger Tea Hot', 'Tra sa gung nong', 'Hot lemongrass ginger tea soothing', 'herbal_tea', 'Tea', 200.00),
('Perilla Leaf Tea Purple', 'Tra la tia to', 'Purple perilla leaf tea fragrant', 'herbal_tea', 'Tea', 200.00),
('Jackfruit Smoothie Creamy', 'Sinh to mit ngot', 'Ripe jackfruit smoothie creamy sweet', 'smoothie', 'Milk', 300.00),
('Rambutan Lychee Cooler', 'Nuoc cham chom vai mat', 'Rambutan lychee refreshing cooler', 'juice', 'Water', 250.00);

-- Verify
DO $$
DECLARE
  dish_count INTEGER;
  drink_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO dish_count FROM dish WHERE dish_id > 1000;
  SELECT COUNT(*) INTO drink_count FROM drink WHERE drink_id > 1000;
  RAISE NOTICE 'SUCCESS: Inserted % dishes and % drinks', dish_count, drink_count;
END $$;
