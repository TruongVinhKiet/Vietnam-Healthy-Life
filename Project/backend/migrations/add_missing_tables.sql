-- Create missing tables for health system

-- 1. MedicationLog - Lịch sử uống thuốc
CREATE TABLE IF NOT EXISTS medicationlog (
    log_id SERIAL PRIMARY KEY,
    user_medication_id INT REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    medication_date DATE NOT NULL DEFAULT CURRENT_DATE,
    medication_time TIME NOT NULL,
    taken_at TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_medication_id, medication_date, medication_time)
);

-- 2. NutrientGoalAdjustment - Điều chỉnh mục tiêu dinh dưỡng
CREATE TABLE IF NOT EXISTS nutrientgoaladjustment (
    adjustment_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES nutrient(nutrient_id) ON DELETE CASCADE,
    condition_id INT REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
    adjustment_percentage DECIMAL(5,2),
    adjustment_reason VARCHAR(200),
    original_goal DECIMAL(10,2),
    adjusted_goal DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. UserNutrientNotification - Thông báo thiếu hụt dinh dưỡng
CREATE TABLE IF NOT EXISTS usernutrientnotification (
    notification_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    nutrient_id INT REFERENCES nutrient(nutrient_id) ON DELETE SET NULL,
    notification_type VARCHAR(50),
    message TEXT,
    severity VARCHAR(20),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. BodyMeasurement - Số đo cơ thể
CREATE TABLE IF NOT EXISTS bodymeasurement (
    measurement_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    measurement_date DATE NOT NULL DEFAULT CURRENT_DATE,
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    bmi DECIMAL(4,2),
    body_fat_percentage DECIMAL(4,2),
    muscle_mass_kg DECIMAL(5,2),
    waist_cm DECIMAL(5,2),
    hip_cm DECIMAL(5,2),
    chest_cm DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. FriendRequest - Yêu cầu kết bạn
CREATE TABLE IF NOT EXISTS friendrequest (
    request_id SERIAL PRIMARY KEY,
    sender_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    receiver_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    responded_at TIMESTAMP,
    UNIQUE(sender_id, receiver_id),
    CHECK (sender_id != receiver_id)
);

-- 6. AdminMessage - Tin nhắn từ admin
CREATE TABLE IF NOT EXISTS adminmessage (
    message_id SERIAL PRIMARY KEY,
    admin_id INT NOT NULL REFERENCES admin(admin_id) ON DELETE CASCADE,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    message_type VARCHAR(50),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_medicationlog_user_date ON medicationlog(user_id, medication_date);
CREATE INDEX IF NOT EXISTS idx_medicationlog_status ON medicationlog(status);
CREATE INDEX IF NOT EXISTS idx_nutrientgoaladjustment_user ON nutrientgoaladjustment(user_id);
CREATE INDEX IF NOT EXISTS idx_usernutrientnotification_user ON usernutrientnotification(user_id);
CREATE INDEX IF NOT EXISTS idx_usernutrientnotification_read ON usernutrientnotification(is_read);
CREATE INDEX IF NOT EXISTS idx_bodymeasurement_user_date ON bodymeasurement(user_id, measurement_date);
CREATE INDEX IF NOT EXISTS idx_friendrequest_receiver ON friendrequest(receiver_id);
CREATE INDEX IF NOT EXISTS idx_friendrequest_status ON friendrequest(status);
CREATE INDEX IF NOT EXISTS idx_adminmessage_user ON adminmessage(user_id);
CREATE INDEX IF NOT EXISTS idx_adminmessage_read ON adminmessage(is_read);
