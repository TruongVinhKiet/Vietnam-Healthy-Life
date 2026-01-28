-- ============================================================
-- Water & Drink Enhancements
-- ------------------------------------------------------------
-- * Introduce Drink catalog & recipe infrastructure
-- * Link WaterLog entries to specific drinks
-- * Seed 20 Vietnamese beverage templates with nutrient data
-- * Provide base structures for future analytics
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- DRINK MASTER DATA
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Drink (
    drink_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    vietnamese_name VARCHAR(200),
    slug VARCHAR(120) UNIQUE,
    description TEXT,
    category VARCHAR(50),
    base_liquid VARCHAR(100),
    default_volume_ml NUMERIC(10,2) DEFAULT 250 CHECK (default_volume_ml > 0),
    default_temperature VARCHAR(20) DEFAULT 'cold',
    default_sweetness VARCHAR(20) DEFAULT 'normal',
    hydration_ratio NUMERIC(5,2) DEFAULT 1.0 CHECK (hydration_ratio >= 0 AND hydration_ratio <= 1.2),
    caffeine_mg NUMERIC(8,2) DEFAULT 0,
    sugar_free BOOLEAN DEFAULT FALSE,
    is_template BOOLEAN DEFAULT TRUE,
    is_public BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    created_by_user INT REFERENCES "User"(user_id) ON DELETE SET NULL,
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_drink_slug ON Drink(slug);
CREATE INDEX IF NOT EXISTS idx_drink_category ON Drink(category);
CREATE INDEX IF NOT EXISTS idx_drink_template ON Drink(is_template);

-- ------------------------------------------------------------
-- DRINK INGREDIENTS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DrinkIngredient (
    drink_ingredient_id SERIAL PRIMARY KEY,
    drink_id INT NOT NULL REFERENCES Drink(drink_id) ON DELETE CASCADE,
    food_id INT NOT NULL REFERENCES Food(food_id) ON DELETE RESTRICT,
    amount_g NUMERIC(10,2) NOT NULL CHECK (amount_g > 0),
    unit VARCHAR(16) DEFAULT 'g',
    display_order INT DEFAULT 0,
    notes TEXT,
    UNIQUE(drink_id, food_id)
);

CREATE INDEX IF NOT EXISTS idx_drink_ingredient_drink ON DrinkIngredient(drink_id);
CREATE INDEX IF NOT EXISTS idx_drink_ingredient_food ON DrinkIngredient(food_id);

-- ------------------------------------------------------------
-- DRINK NUTRIENT CACHE
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DrinkNutrient (
    drink_nutrient_id SERIAL PRIMARY KEY,
    drink_id INT NOT NULL REFERENCES Drink(drink_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    amount_per_100ml NUMERIC(12,6) DEFAULT 0,
    UNIQUE(drink_id, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_drink_nutrient_drink ON DrinkNutrient(drink_id);
CREATE INDEX IF NOT EXISTS idx_drink_nutrient_nutrient ON DrinkNutrient(nutrient_id);

-- ------------------------------------------------------------
-- DRINK STATISTICS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DrinkStatistics (
    stat_id SERIAL PRIMARY KEY,
    drink_id INT NOT NULL REFERENCES Drink(drink_id) ON DELETE CASCADE,
    log_count INT DEFAULT 0,
    unique_users INT DEFAULT 0,
    last_logged_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(drink_id)
);

CREATE INDEX IF NOT EXISTS idx_drink_stats_drink ON DrinkStatistics(drink_id);

-- ------------------------------------------------------------
-- WATER LOG UPDATES
-- ------------------------------------------------------------
ALTER TABLE WaterLog
    ADD COLUMN IF NOT EXISTS drink_id INT REFERENCES Drink(drink_id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS drink_name VARCHAR(200),
    ADD COLUMN IF NOT EXISTS hydration_ratio NUMERIC(5,2) DEFAULT 1.0,
    ADD COLUMN IF NOT EXISTS notes TEXT;

CREATE INDEX IF NOT EXISTS idx_waterlog_drink ON WaterLog(drink_id);

-- ------------------------------------------------------------
-- SEED 20 VIETNAMESE BEVERAGE TEMPLATES
-- ------------------------------------------------------------
INSERT INTO Drink
    (name, vietnamese_name, slug, description, category, base_liquid, default_volume_ml, default_temperature,
     hydration_ratio, caffeine_mg, sugar_free, image_url)
VALUES
    ('Filtered Water', 'Nước lọc', 'nuoc-loc', 'Nước đun sôi để nguội hoặc nước suối đóng chai', 'water', 'Nước', 250, 'room', 1.00, 0, TRUE, NULL),
    ('Mineral Water', 'Nước khoáng', 'nuoc-khoang', 'Nước khoáng thiên nhiên chứa khoáng chất nhẹ', 'water', 'Nước khoáng', 250, 'cold', 1.00, 0, TRUE, NULL),
    ('Sparkling Water', 'Nước có gas', 'nuoc-co-gas', 'Nước khoáng bổ sung CO₂ tạo cảm giác sảng khoái', 'water', 'Nước khoáng', 200, 'cold', 0.98, 0, TRUE, NULL),
    ('Coconut Water', 'Nước dừa', 'nuoc-dua', 'Nước dừa tươi Bến Tre giàu khoáng', 'juice', 'Nước dừa', 200, 'cold', 1.00, 0, TRUE, NULL),
    ('Sugarcane Juice', 'Nước mía', 'nuoc-mia', 'Nước mía tươi ép cùng tắc/chanh', 'juice', 'Nước mía', 250, 'cold', 0.95, 0, FALSE, NULL),
    ('Unsweetened Green Tea', 'Trà xanh không đường', 'tra-xanh', 'Trà xanh pha nóng, không đường', 'tea', 'Trà', 200, 'hot', 0.96, 30, TRUE, NULL),
    ('Black Coffee', 'Cà phê đen không đường', 'ca-phe-den', 'Cà phê rang xay phin đậm vị', 'coffee', 'Cà phê', 120, 'hot', 0.92, 80, TRUE, NULL),
    ('Vietnamese Iced Coffee', 'Cà phê sữa đá', 'ca-phe-sua-da', 'Cà phê phin pha với sữa đặc và đá', 'coffee', 'Cà phê', 180, 'cold', 0.88, 80, FALSE, NULL),
    ('Fresh Milk', 'Sữa tươi không đường', 'sua-tuoi', 'Sữa bò thanh trùng không đường', 'milk', 'Sữa', 200, 'cold', 0.90, 0, FALSE, NULL),
    ('Diluted Condensed Milk', 'Sữa đặc pha', 'sua-dac-pha', 'Sữa đặc pha loãng với nước nóng', 'milk', 'Sữa', 180, 'hot', 0.85, 0, FALSE, NULL),
    ('Fresh Orange Juice', 'Nước cam ép', 'nuoc-cam', 'Cam vắt tươi giữ nguyên tép', 'juice', 'Nước cam', 200, 'cold', 0.98, 0, FALSE, NULL),
    ('Lemonade', 'Nước chanh', 'nuoc-chanh', 'Chanh tươi, nước và đường', 'juice', 'Nước chanh', 220, 'cold', 0.97, 0, FALSE, NULL),
    ('Watermelon Juice', 'Nước ép dưa hấu', 'nuoc-dua-hau', 'Dưa hấu ép, giữ bã nhẹ', 'juice', 'Nước ép', 250, 'cold', 0.99, 0, TRUE, NULL),
    ('Mango Smoothie', 'Sinh tố xoài', 'sinh-to-xoai', 'Xoài chín cùng sữa hoặc sữa chua', 'smoothie', 'Sữa+topping', 220, 'cold', 0.85, 0, FALSE, NULL),
    ('Avocado Smoothie', 'Sinh tố bơ', 'sinh-to-bo', 'Bơ sáp, sữa tươi và sữa đặc', 'smoothie', 'Sữa+topping', 220, 'cold', 0.82, 0, FALSE, NULL),
    ('Bubble Milk Tea', 'Trà sữa trân châu', 'tra-sua-tran-chau', 'Trà đen pha sữa, kèm trân châu', 'tea', 'Trà+sữa', 250, 'cold', 0.80, 30, FALSE, NULL),
    ('Drinking Yogurt', 'Yaourt uống', 'yaourt-uong', 'Sữa chua uống hương trái cây nhẹ', 'fermented', 'Sữa chua', 200, 'cold', 0.88, 0, FALSE, NULL),
    ('Herbal Sam Drink', 'Nước sâm', 'nuoc-sam', 'Nước sâm thảo mộc mát gan', 'herbal', 'Thảo mộc', 250, 'cold', 0.97, 0, TRUE, NULL),
    ('Pennywort Juice', 'Nước rau má', 'nuoc-rau-ma', 'Rau má xay cùng đường, chút sữa', 'herbal', 'Rau má', 220, 'cold', 0.95, 0, FALSE, NULL),
    ('Soy Milk', 'Nước đậu nành', 'nuoc-dau-nanh', 'Đậu nành xay, nấu chín, chút đường', 'milk', 'Đậu nành', 220, 'hot', 0.93, 0, FALSE, NULL);

-- ------------------------------------------------------------
-- Nutrient seeding for the 20 template drinks
-- Amounts expressed per 100 ml
-- ------------------------------------------------------------
WITH nutrient_map AS (
    SELECT nutrient_id, nutrient_code
    FROM Nutrient
    WHERE nutrient_code IN ('ENERC_KCAL','PROCNT','FAT','CHOCDF','FIBTG','K','NA','CA','MG','VITC','VITA','VITB2','VITB12')
),
drink_data AS (
    SELECT * FROM (VALUES
        ('nuoc-loc','ENERC_KCAL',0),
        ('nuoc-loc','NA',2),

        ('nuoc-khoang','ENERC_KCAL',0),
        ('nuoc-khoang','K',5),
        ('nuoc-khoang','NA',20),
        ('nuoc-khoang','CA',30),
        ('nuoc-khoang','MG',10),

        ('nuoc-co-gas','ENERC_KCAL',0),
        ('nuoc-co-gas','NA',8),

        ('nuoc-dua','ENERC_KCAL',19),
        ('nuoc-dua','PROCNT',0.7),
        ('nuoc-dua','CHOCDF',3.7),
        ('nuoc-dua','K',250),
        ('nuoc-dua','NA',105),
        ('nuoc-dua','MG',6),
        ('nuoc-dua','VITC',2.4),

        ('nuoc-mia','ENERC_KCAL',76),
        ('nuoc-mia','CHOCDF',19),
        ('nuoc-mia','K',40),
        ('nuoc-mia','CA',10),
        ('nuoc-mia','MG',3),

        ('tra-xanh','ENERC_KCAL',2),
        ('tra-xanh','VITC',6),
        ('tra-xanh','VITA',2),

        ('ca-phe-den','ENERC_KCAL',2),
        ('ca-phe-den','PROCNT',0.1),
        ('ca-phe-den','K',90),

        ('ca-phe-sua-da','ENERC_KCAL',60),
        ('ca-phe-sua-da','PROCNT',1.2),
        ('ca-phe-sua-da','FAT',1.4),
        ('ca-phe-sua-da','CHOCDF',10.5),
        ('ca-phe-sua-da','NA',30),
        ('ca-phe-sua-da','CA',45),

        ('sua-tuoi','ENERC_KCAL',42),
        ('sua-tuoi','PROCNT',3.4),
        ('sua-tuoi','FAT',1.0),
        ('sua-tuoi','CHOCDF',5.2),
        ('sua-tuoi','CA',120),
        ('sua-tuoi','VITB2',0.4),

        ('sua-dac-pha','ENERC_KCAL',120),
        ('sua-dac-pha','PROCNT',3),
        ('sua-dac-pha','FAT',3.5),
        ('sua-dac-pha','CHOCDF',19),
        ('sua-dac-pha','CA',100),

        ('nuoc-cam','ENERC_KCAL',45),
        ('nuoc-cam','PROCNT',0.7),
        ('nuoc-cam','CHOCDF',10.4),
        ('nuoc-cam','FIBTG',0.2),
        ('nuoc-cam','K',200),
        ('nuoc-cam','VITC',50),

        ('nuoc-chanh','ENERC_KCAL',30),
        ('nuoc-chanh','CHOCDF',8.8),
        ('nuoc-chanh','VITC',38),

        ('nuoc-dua-hau','ENERC_KCAL',30),
        ('nuoc-dua-hau','CHOCDF',7.5),
        ('nuoc-dua-hau','K',112),
        ('nuoc-dua-hau','VITC',8.1),

        ('sinh-to-xoai','ENERC_KCAL',60),
        ('sinh-to-xoai','CHOCDF',15),
        ('sinh-to-xoai','VITC',28),
        ('sinh-to-xoai','VITA',54),

        ('sinh-to-bo','ENERC_KCAL',160),
        ('sinh-to-bo','FAT',15),
        ('sinh-to-bo','CHOCDF',9),
        ('sinh-to-bo','FIBTG',6.7),
        ('sinh-to-bo','K',485),

        ('tra-sua-tran-chau','ENERC_KCAL',130),
        ('tra-sua-tran-chau','PROCNT',1.5),
        ('tra-sua-tran-chau','FAT',4),
        ('tra-sua-tran-chau','CHOCDF',26),
        ('tra-sua-tran-chau','NA',40),

        ('yaourt-uong','ENERC_KCAL',65),
        ('yaourt-uong','PROCNT',3),
        ('yaourt-uong','FAT',2),
        ('yaourt-uong','CHOCDF',10),
        ('yaourt-uong','CA',120),

        ('nuoc-sam','ENERC_KCAL',30),
        ('nuoc-sam','CHOCDF',7.5),

        ('nuoc-rau-ma','ENERC_KCAL',25),
        ('nuoc-rau-ma','CHOCDF',6),
        ('nuoc-rau-ma','CA',40),
        ('nuoc-rau-ma','VITC',17),

        ('nuoc-dau-nanh','ENERC_KCAL',54),
        ('nuoc-dau-nanh','PROCNT',3.3),
        ('nuoc-dau-nanh','FAT',1.8),
        ('nuoc-dau-nanh','CHOCDF',6.3),
        ('nuoc-dau-nanh','K',118),
        ('nuoc-dau-nanh','CA',25)
    ) AS t(drink_slug, nutrient_code, amount)
)
INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
SELECT d.drink_id, n.nutrient_id, t.amount
FROM drink_data t
JOIN Drink d ON d.slug = t.drink_slug
JOIN nutrient_map n ON n.nutrient_code = t.nutrient_code;

COMMIT;

