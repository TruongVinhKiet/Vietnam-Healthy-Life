-- ============================================================
-- DRUG & MEDICATION SYSTEM WITH NUTRIENT INTERACTIONS
-- ============================================================
-- Tính năng: Quản lý thuốc, cảnh báo tương tác thuốc-dinh dưỡng
-- - Admin quản lý thuốc, liên kết với bệnh, tác dụng phụ
-- - User chọn thuốc khi uống, hệ thống cảnh báo real-time
-- ============================================================

BEGIN;

-- ============================================================
-- 1. BẢNG DRUG (THUỐC) - Admin quản lý
-- ============================================================
CREATE TABLE IF NOT EXISTS Drug (
    drug_id SERIAL PRIMARY KEY,
    name_vi VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    generic_name VARCHAR(200),              -- Tên hoạt chất
    drug_class VARCHAR(100),                -- Nhóm thuốc
    description TEXT,                        -- Mô tả thuốc
    image_url TEXT,                          -- URL hình ảnh
    source_link TEXT,                        -- Nguồn tham khảo
    dosage_form VARCHAR(50),                -- Dạng bào chế: viên, nước, tiêm...
    is_active BOOLEAN DEFAULT TRUE,          -- Thuốc còn sử dụng
    created_by_admin INT REFERENCES Admin(admin_id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_drug_name_vi ON Drug(name_vi);
CREATE INDEX IF NOT EXISTS idx_drug_active ON Drug(is_active);

-- ============================================================
-- 2. BẢNG DRUG HEALTH CONDITION - Thuốc điều trị bệnh gì
-- ============================================================
CREATE TABLE IF NOT EXISTS DrugHealthCondition (
    drug_condition_id SERIAL PRIMARY KEY,
    drug_id INT NOT NULL REFERENCES Drug(drug_id) ON DELETE CASCADE,
    condition_id INT NOT NULL REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
    treatment_notes TEXT,                    -- Ghi chú điều trị
    is_primary BOOLEAN DEFAULT FALSE,        -- Điều trị chính hay phụ
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(drug_id, condition_id)
);

CREATE INDEX IF NOT EXISTS idx_drug_condition_drug ON DrugHealthCondition(drug_id);
CREATE INDEX IF NOT EXISTS idx_drug_condition_condition ON DrugHealthCondition(condition_id);

-- ============================================================
-- 3. BẢNG DRUG NUTRIENT CONTRAINDICATION - Tác dụng phụ
-- ============================================================
CREATE TABLE IF NOT EXISTS DrugNutrientContraindication (
    contra_id SERIAL PRIMARY KEY,
    drug_id INT NOT NULL REFERENCES Drug(drug_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    avoid_hours_before NUMERIC(5,2) DEFAULT 0,    -- Tránh X giờ TRƯỚC khi uống
    avoid_hours_after NUMERIC(5,2) DEFAULT 2,    -- Tránh X giờ SAU khi uống (mặc định 2h)
    warning_message_vi TEXT,                       -- Thông báo cảnh báo tiếng Việt
    warning_message_en TEXT,                      -- Thông báo cảnh báo tiếng Anh
    severity VARCHAR(20) DEFAULT 'moderate',      -- mild, moderate, severe
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(drug_id, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_drug_contra_drug ON DrugNutrientContraindication(drug_id);
CREATE INDEX IF NOT EXISTS idx_drug_contra_nutrient ON DrugNutrientContraindication(nutrient_id);

-- ============================================================
-- 4. CẬP NHẬT MEDICATION SCHEDULE - Thêm drug_id
-- ============================================================
ALTER TABLE MedicationSchedule
    ADD COLUMN IF NOT EXISTS drug_id INT REFERENCES Drug(drug_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_medication_schedule_drug ON MedicationSchedule(drug_id);

-- ============================================================
-- 5. CẬP NHẬT MEDICATION LOG - Thêm drug_id
-- ============================================================
ALTER TABLE MedicationLog
    ADD COLUMN IF NOT EXISTS drug_id INT REFERENCES Drug(drug_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_medication_log_drug ON MedicationLog(drug_id);

-- ============================================================
-- 6. FUNCTION: Kiểm tra tương tác thuốc-dinh dưỡng real-time
-- ============================================================
CREATE OR REPLACE FUNCTION check_drug_nutrient_interaction(
    p_user_id INT,
    p_meal_time TIMESTAMP,
    p_food_ids INT[] DEFAULT NULL,
    p_drink_id INT DEFAULT NULL
)
RETURNS TABLE(
    drug_id INT,
    drug_name_vi VARCHAR(200),
    nutrient_id INT,
    nutrient_name VARCHAR(100),
    warning_message_vi TEXT,
    warning_message_en TEXT,
    severity VARCHAR(20),
    medication_time TIMESTAMP
) AS $$
DECLARE
    v_window_start TIMESTAMP;
    v_window_end TIMESTAMP;
BEGIN
    -- Kiểm tra các lần uống thuốc trong vòng +/- 2 giờ (hoặc theo cấu hình)
    FOR drug_id, drug_name_vi, nutrient_id, nutrient_name, warning_message_vi, warning_message_en, severity, medication_time IN
        SELECT DISTINCT
            d.drug_id,
            d.name_vi,
            nc.nutrient_id,
            n.name,
            nc.warning_message_vi,
            nc.warning_message_en,
            nc.severity,
            ml.taken_at
        FROM MedicationLog ml
        JOIN Drug d ON d.drug_id = ml.drug_id
        JOIN DrugNutrientContraindication nc ON nc.drug_id = d.drug_id
        JOIN Nutrient n ON n.nutrient_id = nc.nutrient_id
        WHERE ml.user_id = p_user_id
          AND ml.status = 'taken'
          AND ml.taken_at IS NOT NULL
          AND ml.taken_at >= (p_meal_time - INTERVAL '1 hour' * COALESCE(nc.avoid_hours_before, 0))
          AND ml.taken_at <= (p_meal_time + INTERVAL '1 hour' * COALESCE(nc.avoid_hours_after, 2))
        LOOP
            -- Kiểm tra xem meal/drink có chứa nutrient này không
            IF p_food_ids IS NOT NULL AND array_length(p_food_ids, 1) > 0 THEN
                IF EXISTS (
                    SELECT 1
                    FROM FoodNutrient fn
                    WHERE fn.food_id = ANY(p_food_ids)
                      AND fn.nutrient_id = nutrient_id
                      AND fn.amount_per_100g > 0
                ) THEN
                    RETURN QUERY SELECT drug_id, drug_name_vi, nutrient_id, nutrient_name, warning_message_vi, warning_message_en, severity, medication_time;
                END IF;
            END IF;

            -- Kiểm tra drink
            IF p_drink_id IS NOT NULL THEN
                IF EXISTS (
                    SELECT 1
                    FROM DrinkNutrient dn
                    WHERE dn.drink_id = p_drink_id
                      AND dn.nutrient_id = nutrient_id
                      AND dn.amount_per_100ml > 0
                ) THEN
                    RETURN QUERY SELECT drug_id, drug_name_vi, nutrient_id, nutrient_name, warning_message_vi, warning_message_en, severity, medication_time;
                END IF;
            END IF;
        END LOOP;

    RETURN;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 7. FUNCTION: Lấy danh sách thuốc cho một bệnh
-- ============================================================
CREATE OR REPLACE FUNCTION get_drugs_for_condition(
    p_condition_id INT
)
RETURNS TABLE(
    drug_id INT,
    name_vi VARCHAR(200),
    name_en VARCHAR(200),
    generic_name VARCHAR(200),
    drug_class VARCHAR(100),
    image_url TEXT,
    is_primary BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.drug_id,
        d.name_vi,
        d.name_en,
        d.generic_name,
        d.drug_class,
        d.image_url,
        dhc.is_primary
    FROM Drug d
    JOIN DrugHealthCondition dhc ON dhc.drug_id = d.drug_id
    WHERE dhc.condition_id = p_condition_id
      AND d.is_active = TRUE
    ORDER BY dhc.is_primary DESC, d.name_vi;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 8. FUNCTION: Thống kê lịch sử uống thuốc
-- ============================================================
CREATE OR REPLACE FUNCTION get_medication_history_stats(
    p_user_id INT,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
)
RETURNS TABLE(
    drug_id INT,
    drug_name_vi VARCHAR(200),
    total_taken INT,
    total_skipped INT,
    total_pending INT,
    on_time_count INT,
    late_count INT,
    earliest_taken TIMESTAMP,
    latest_taken TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d.drug_id,
        d.name_vi,
        COUNT(*) FILTER (WHERE ml.status = 'taken')::INT AS total_taken,
        COUNT(*) FILTER (WHERE ml.status = 'skipped')::INT AS total_skipped,
        COUNT(*) FILTER (WHERE ml.status = 'pending')::INT AS total_pending,
        COUNT(*) FILTER (WHERE ml.status = 'taken' AND ml.taken_at <= (ml.medication_date::TIMESTAMP + ml.medication_time + INTERVAL '30 minutes'))::INT AS on_time_count,
        COUNT(*) FILTER (WHERE ml.status = 'taken' AND ml.taken_at > (ml.medication_date::TIMESTAMP + ml.medication_time + INTERVAL '30 minutes'))::INT AS late_count,
        MIN(ml.taken_at) FILTER (WHERE ml.status = 'taken') AS earliest_taken,
        MAX(ml.taken_at) FILTER (WHERE ml.status = 'taken') AS latest_taken
    FROM MedicationLog ml
    JOIN Drug d ON d.drug_id = ml.drug_id
    WHERE ml.user_id = p_user_id
      AND (p_start_date IS NULL OR ml.medication_date >= p_start_date)
      AND (p_end_date IS NULL OR ml.medication_date <= p_end_date)
    GROUP BY d.drug_id, d.name_vi
    ORDER BY total_taken DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 9. VIEW: Thống kê thuốc cho admin dashboard
-- ============================================================
CREATE OR REPLACE VIEW DrugStatistics AS
SELECT 
    COUNT(*) FILTER (WHERE is_active = TRUE) AS active_drugs,
    COUNT(*) FILTER (WHERE is_active = FALSE) AS inactive_drugs,
    COUNT(*) AS total_drugs,
    COUNT(DISTINCT dhc.condition_id) AS conditions_covered
FROM Drug d
LEFT JOIN DrugHealthCondition dhc ON dhc.drug_id = d.drug_id;

-- ============================================================
-- 10. TRIGGER: Cập nhật updated_at cho Drug
-- ============================================================
CREATE OR REPLACE FUNCTION update_drug_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_drug_updated_at ON Drug;
CREATE TRIGGER trg_update_drug_updated_at
    BEFORE UPDATE ON Drug
    FOR EACH ROW
    EXECUTE FUNCTION update_drug_updated_at();

COMMENT ON TABLE Drug IS 'Bảng quản lý thuốc - Admin quản lý';
COMMENT ON TABLE DrugHealthCondition IS 'Liên kết thuốc với bệnh điều trị';
COMMENT ON TABLE DrugNutrientContraindication IS 'Tác dụng phụ: thuốc kỵ chất dinh dưỡng nào, trong bao lâu';
COMMENT ON FUNCTION check_drug_nutrient_interaction IS 'Kiểm tra tương tác thuốc-dinh dưỡng real-time khi user thêm meal/drink';
COMMENT ON FUNCTION get_drugs_for_condition IS 'Lấy danh sách thuốc điều trị một bệnh cụ thể';
COMMENT ON FUNCTION get_medication_history_stats IS 'Thống kê lịch sử uống thuốc của user';

COMMIT;

