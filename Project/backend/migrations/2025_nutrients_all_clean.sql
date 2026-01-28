-- Migration 6-8: Nutrient data for 30 dishes and 20 drinks
-- Date: 2025-12-08

-- ============= DISH NUTRIENTS (Dishes 153-182) =============

-- Dish 153: Quinoa Buddha Bowl Vietnam
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(153, 1, 165.0), -- Calories
(153, 2, 6.5), -- Protein
(153, 3, 5.2), -- Fat
(153, 4, 24.8), -- Carbs
(153, 5, 4.5), -- Fiber
(153, 11, 450.0), -- Vitamin A
(153, 15, 25.0), -- Vitamin C
(153, 24, 45.0), -- Calcium
(153, 29, 2.8), -- Iron
(153, 26, 78.0); -- Magnesium

-- Dish 154: Black Rice Stir-Fry Veggie
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(154, 1, 178.0),
(154, 2, 4.2),
(154, 3, 3.8),
(154, 4, 32.5),
(154, 5, 3.8),
(154, 11, 380.0),
(154, 15, 18.0),
(154, 24, 35.0),
(154, 29, 2.2),
(154, 26, 65.0);

-- Dish 155: Beetroot Detox Salad
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(155, 1, 68.0),
(155, 2, 2.8),
(155, 3, 2.5),
(155, 4, 10.2),
(155, 5, 3.2),
(155, 11, 520.0),
(155, 15, 35.0),
(155, 24, 28.0),
(155, 29, 1.8),
(155, 22, 85.0); -- Folate

-- Dish 156: Purple Sweet Potato Soup
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(156, 1, 92.0),
(156, 2, 1.8),
(156, 3, 0.8),
(156, 4, 20.5),
(156, 5, 3.5),
(156, 11, 820.0),
(156, 15, 12.0),
(156, 24, 32.0),
(156, 27, 285.0); -- Potassium

-- Dish 157: Kabocha Pumpkin Curry
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(157, 1, 125.0),
(157, 2, 3.2),
(157, 3, 6.8),
(157, 4, 15.8),
(157, 5, 2.8),
(157, 11, 680.0),
(157, 15, 18.0),
(157, 24, 38.0),
(157, 29, 1.5);

-- Dish 158: Enoki Mushroom Stir-Fry
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(158, 1, 48.0),
(158, 2, 3.5),
(158, 3, 1.2),
(158, 4, 7.8),
(158, 5, 2.5),
(158, 16, 0.18), -- B1
(158, 17, 0.22), -- B2
(158, 18, 5.2), -- B3
(158, 12, 85.0); -- Vitamin D

-- Dish 159: Lotus Root Salad Tangy
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(159, 1, 74.0),
(159, 2, 2.2),
(159, 3, 0.5),
(159, 4, 17.2),
(159, 5, 4.8),
(159, 15, 44.0),
(159, 24, 45.0),
(159, 27, 556.0);

-- Dish 160: Sea Bass Steamed Ginger
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(160, 1, 124.0),
(160, 2, 24.2),
(160, 3, 2.8),
(160, 4, 0.0),
(160, 12, 180.0),
(160, 20, 0.42), -- B6
(160, 23, 3.8), -- B12
(160, 34, 42.0), -- Selenium
(160, 42, 0.18), -- EPA
(160, 43, 0.32); -- DHA

-- Dish 161: Mackerel Grilled Turmeric
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(161, 1, 205.0),
(161, 2, 18.6),
(161, 3, 13.9),
(161, 4, 0.0),
(161, 12, 360.0),
(161, 23, 8.7),
(161, 34, 44.0),
(161, 42, 0.75), -- EPA
(161, 43, 1.15); -- DHA

-- Dish 162: Squid Stir-Fry Lemongrass
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(162, 1, 92.0),
(162, 2, 15.6),
(162, 3, 1.4),
(162, 4, 3.1),
(162, 10, 233.0), -- Cholesterol
(162, 30, 1.5), -- Zinc
(162, 31, 1.9), -- Copper
(162, 34, 44.8);

-- Dish 163: Tempeh Stir-Fry Vegetables
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(163, 1, 142.0),
(163, 2, 12.8),
(163, 3, 6.4),
(163, 4, 10.2),
(163, 5, 4.2),
(163, 24, 112.0),
(163, 29, 2.8),
(163, 26, 68.0),
(163, 30, 1.4);

-- Dish 164: Edamame Garlic Butter
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(164, 1, 122.0),
(164, 2, 11.2),
(164, 3, 5.2),
(164, 4, 8.9),
(164, 5, 5.2),
(164, 22, 311.0),
(164, 24, 63.0),
(164, 29, 2.3),
(164, 26, 64.0);

-- Dish 165: Dragon Fruit Smoothie Bowl
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(165, 1, 85.0),
(165, 2, 2.8),
(165, 3, 1.2),
(165, 4, 18.5),
(165, 5, 3.0),
(165, 15, 9.0),
(165, 24, 28.0),
(165, 29, 0.8);

-- Dish 166: Longan Sticky Rice Sweet
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(166, 1, 168.0),
(166, 2, 3.2),
(166, 3, 2.5),
(166, 4, 35.8),
(166, 5, 1.8),
(166, 15, 84.0),
(166, 27, 266.0),
(166, 24, 22.0);

-- Dish 167: Jackfruit Seed Curry
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(167, 1, 135.0),
(167, 2, 4.8),
(167, 3, 5.2),
(167, 4, 22.5),
(167, 5, 3.8),
(167, 16, 0.25),
(167, 29, 1.8),
(167, 26, 52.0);

-- Dish 168: Bitter Melon Stuffed Pork
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(168, 1, 108.0),
(168, 2, 12.5),
(168, 3, 4.2),
(168, 4, 5.8),
(168, 5, 2.6),
(168, 15, 95.0),
(168, 24, 28.0),
(168, 29, 1.5);

-- Dish 169: Water Spinach Garlic Sauce
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(169, 1, 32.0),
(169, 2, 2.8),
(169, 3, 0.8),
(169, 4, 5.2),
(169, 5, 2.2),
(169, 11, 630.0),
(169, 15, 55.0),
(169, 24, 77.0),
(169, 29, 2.5);

-- Dish 170: Bok Choy Oyster Sauce
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(170, 1, 28.0),
(170, 2, 2.2),
(170, 3, 0.5),
(170, 4, 4.5),
(170, 5, 1.8),
(170, 11, 450.0),
(170, 15, 45.0),
(170, 24, 105.0),
(170, 14, 45.8); -- Vitamin K

-- Dish 171: Wood Ear Mushroom Soup
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(171, 1, 38.0),
(171, 2, 2.5),
(171, 3, 0.3),
(171, 4, 7.8),
(171, 5, 3.2),
(171, 29, 5.8),
(171, 24, 32.0),
(171, 12, 95.0);

-- Dish 172: Daikon Radish Pickled
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(172, 1, 18.0),
(172, 2, 0.6),
(172, 3, 0.1),
(172, 4, 4.2),
(172, 5, 1.6),
(172, 15, 22.0),
(172, 27, 227.0),
(172, 28, 650.0); -- Sodium (pickled)

-- Dish 173: Jicama Spring Rolls
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(173, 1, 95.0),
(173, 2, 6.8),
(173, 3, 2.2),
(173, 4, 13.5),
(173, 5, 3.5),
(173, 15, 20.0),
(173, 24, 35.0),
(173, 29, 0.8);

-- Dish 174: Snow Pea Shrimp Stir-Fry
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(174, 1, 98.0),
(174, 2, 14.2),
(174, 3, 2.5),
(174, 4, 6.8),
(174, 5, 2.8),
(174, 15, 60.0),
(174, 30, 1.8),
(174, 34, 38.0);

-- Dish 175: Clam Soup Lemongrass
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(175, 1, 62.0),
(175, 2, 10.8),
(175, 3, 0.8),
(175, 4, 3.2),
(175, 23, 49.4),
(175, 29, 13.8),
(175, 30, 1.4),
(175, 34, 24.3);

-- Dish 176: Duck Breast Orange Glaze
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(176, 1, 185.0),
(176, 2, 19.8),
(176, 3, 10.2),
(176, 4, 5.2),
(176, 23, 0.3),
(176, 30, 2.1),
(176, 29, 2.4),
(176, 34, 18.5);

-- Dish 177: Quail Egg Tamarind Sauce
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(177, 1, 158.0),
(177, 2, 13.1),
(177, 3, 11.1),
(177, 4, 0.4),
(177, 11, 543.0),
(177, 23, 1.6),
(177, 29, 3.7),
(177, 34, 32.0);

-- Dish 178: Silken Tofu Ginger Syrup
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(178, 1, 92.0),
(178, 2, 4.8),
(178, 3, 2.2),
(178, 4, 14.5),
(178, 24, 85.0),
(178, 29, 1.2),
(178, 26, 28.0);

-- Dish 179: Chia Seed Pudding Mango
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(179, 1, 118.0),
(179, 2, 4.5),
(179, 3, 5.8),
(179, 4, 14.2),
(179, 5, 8.5),
(179, 46, 3.2), -- ALA
(179, 24, 145.0),
(179, 29, 1.8);

-- Dish 180: Flax Seed Crackers
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(180, 1, 285.0),
(180, 2, 12.5),
(180, 3, 18.2),
(180, 4, 22.8),
(180, 5, 15.8),
(180, 46, 12.5), -- ALA
(180, 26, 168.0);

-- Dish 181: Pumpkin Seed Granola
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(181, 1, 325.0),
(181, 2, 14.8),
(181, 3, 15.2),
(181, 4, 35.5),
(181, 5, 6.8),
(181, 30, 4.2),
(181, 26, 185.0),
(181, 29, 3.8);

-- Dish 182: Walnut Energy Balls
INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES
(182, 1, 295.0),
(182, 2, 8.5),
(182, 3, 18.8),
(182, 4, 28.2),
(182, 5, 5.2),
(182, 46, 5.8), -- ALA
(182, 26, 98.0),
(182, 31, 1.1); -- Copper

-- ============= DRINK NUTRIENTS (Drinks 68-87) =============

-- Drink 68: Coconut Water Fresh Natural
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(68, 1, 19.0),
(68, 2, 0.7),
(68, 3, 0.2),
(68, 4, 3.7),
(68, 27, 250.0), -- Potassium
(68, 28, 105.0), -- Sodium
(68, 24, 24.0),
(68, 26, 25.0);

-- Drink 69: Pandan Tea Aromatic
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(69, 1, 2.0),
(69, 2, 0.0),
(69, 3, 0.0),
(69, 4, 0.5),
(69, 11, 15.0),
(69, 15, 2.0);

-- Drink 70: Chrysanthemum Honey Tea
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(70, 1, 32.0),
(70, 2, 0.3),
(70, 3, 0.0),
(70, 4, 8.2),
(70, 15, 1.8),
(70, 24, 8.0);

-- Drink 71: Ginger Lemon Turmeric Shot
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(71, 1, 28.0),
(71, 2, 0.5),
(71, 3, 0.3),
(71, 4, 6.5),
(71, 15, 38.0),
(71, 26, 12.0),
(71, 29, 0.8);

-- Drink 72: Dragon Fruit Smoothie Red
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(72, 1, 65.0),
(72, 2, 2.2),
(72, 3, 1.8),
(72, 4, 12.5),
(72, 5, 1.2),
(72, 15, 6.0),
(72, 24, 35.0);

-- Drink 73: Longan Ginger Tea Sweet
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(73, 1, 58.0),
(73, 2, 0.8),
(73, 3, 0.1),
(73, 4, 14.2),
(73, 15, 68.0),
(73, 27, 185.0);

-- Drink 74: Lychee Rose Water Cooler
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(74, 1, 42.0),
(74, 2, 0.6),
(74, 3, 0.3),
(74, 4, 10.2),
(74, 15, 55.0),
(74, 27, 155.0);

-- Drink 75: Passion Fruit Green Tea
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(75, 1, 22.0),
(75, 2, 0.5),
(75, 3, 0.1),
(75, 4, 5.2),
(75, 15, 28.0),
(75, 11, 64.0);

-- Drink 76: Guava Lime Juice Fresh
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(76, 1, 48.0),
(76, 2, 0.8),
(76, 3, 0.2),
(76, 4, 11.8),
(76, 5, 3.5),
(76, 15, 185.0),
(76, 11, 31.0);

-- Drink 77: Star Fruit Honey Drink
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(77, 1, 38.0),
(77, 2, 0.5),
(77, 3, 0.2),
(77, 4, 9.2),
(77, 15, 34.0),
(77, 27, 133.0);

-- Drink 78: Pomelo Mint Infusion
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(78, 1, 18.0),
(78, 2, 0.4),
(78, 3, 0.0),
(78, 4, 4.5),
(78, 15, 58.0),
(78, 27, 115.0);

-- Drink 79: Basil Seed Lychee Drink
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(79, 1, 52.0),
(79, 2, 1.2),
(79, 3, 0.8),
(79, 4, 11.5),
(79, 5, 2.8),
(79, 24, 22.0);

-- Drink 80: Almond Milk Matcha Latte
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(80, 1, 68.0),
(80, 2, 2.5),
(80, 3, 3.2),
(80, 4, 7.8),
(80, 24, 95.0),
(80, 13, 3.8),
(80, 26, 18.0);

-- Drink 81: Chia Seed Lemonade
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(81, 1, 42.0),
(81, 2, 1.5),
(81, 3, 1.8),
(81, 4, 7.2),
(81, 5, 3.2),
(81, 15, 15.0),
(81, 24, 45.0);

-- Drink 82: Beetroot Apple Detox Juice
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(82, 1, 48.0),
(82, 2, 0.8),
(82, 3, 0.2),
(82, 4, 11.2),
(82, 5, 1.5),
(82, 15, 22.0),
(82, 22, 68.0),
(82, 29, 0.8);

-- Drink 83: Kaffir Lime Soda
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(83, 1, 12.0),
(83, 2, 0.1),
(83, 3, 0.0),
(83, 4, 3.2),
(83, 15, 18.0),
(83, 24, 5.0);

-- Drink 84: Lemongrass Ginger Tea Hot
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(84, 1, 8.0),
(84, 2, 0.2),
(84, 3, 0.1),
(84, 4, 1.8),
(84, 15, 4.0),
(84, 29, 0.3);

-- Drink 85: Perilla Leaf Tea Purple
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(85, 1, 5.0),
(85, 2, 0.2),
(85, 3, 0.1),
(85, 4, 1.2),
(85, 11, 28.0),
(85, 24, 12.0);

-- Drink 86: Jackfruit Smoothie Creamy
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(86, 1, 78.0),
(86, 2, 1.2),
(86, 3, 2.2),
(86, 4, 16.5),
(86, 5, 1.8),
(86, 15, 12.0),
(86, 27, 285.0);

-- Drink 87: Rambutan Lychee Cooler
INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES
(87, 1, 52.0),
(87, 2, 0.7),
(87, 3, 0.2),
(87, 4, 12.8),
(87, 15, 48.0),
(87, 27, 168.0);

-- Verification
DO $$
DECLARE
  dish_nutrient_count INTEGER;
  drink_nutrient_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO dish_nutrient_count FROM dishnutrient WHERE dish_id >= 153;
  SELECT COUNT(*) INTO drink_nutrient_count FROM drinknutrient WHERE drink_id >= 68;
  RAISE NOTICE 'SUCCESS: Inserted % dish nutrients and % drink nutrients', dish_nutrient_count, drink_nutrient_count;
END $$;
