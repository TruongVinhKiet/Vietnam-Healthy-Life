-- Migration: Comprehensive Drug Management System Upgrade
-- Date: 2025-12-05
-- Description: Add detailed fields for complete drug information

-- ===== 1. UPGRADE DRUG TABLE =====
-- Add comprehensive fields to existing drug table
ALTER TABLE drug ADD COLUMN IF NOT EXISTS brand_name_vi VARCHAR(255);
ALTER TABLE drug ADD COLUMN IF NOT EXISTS brand_name_en VARCHAR(255);
ALTER TABLE drug ADD COLUMN IF NOT EXISTS active_ingredient TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS therapeutic_class VARCHAR(255);
ALTER TABLE drug ADD COLUMN IF NOT EXISTS strength VARCHAR(100); -- Hàm lượng (e.g., "500mg", "10mg/ml")
ALTER TABLE drug ADD COLUMN IF NOT EXISTS packaging VARCHAR(255); -- Quy cách (e.g., "Hộp 3 vỉ x 10 viên")

-- Indications (Chỉ định)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS indications_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS indications_en TEXT;

-- Dosage (Liều dùng - Cách dùng)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS dosage_adult_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS dosage_adult_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS dosage_pediatric_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS dosage_pediatric_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS dosage_special_vi TEXT; -- Liều đặc biệt (suy gan, thận)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS dosage_special_en TEXT;

-- Contraindications (Chống chỉ định)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS contraindications_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS contraindications_en TEXT;

-- Warnings (Cảnh báo & thận trọng)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS warnings_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS warnings_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS black_box_warning_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS black_box_warning_en TEXT;

-- Side Effects (Tác dụng phụ)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS common_side_effects_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS common_side_effects_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS serious_side_effects_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS serious_side_effects_en TEXT;

-- Pharmacology (Dược lực học & dược động học)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS mechanism_of_action_vi TEXT; -- Cơ chế tác dụng
ALTER TABLE drug ADD COLUMN IF NOT EXISTS mechanism_of_action_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS pharmacokinetics_vi TEXT; -- ADME
ALTER TABLE drug ADD COLUMN IF NOT EXISTS pharmacokinetics_en TEXT;

-- Overdose (Quá liều & xử lý)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS overdose_symptoms_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS overdose_symptoms_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS overdose_treatment_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS overdose_treatment_en TEXT;

-- Pregnancy & Lactation (Phụ nữ có thai - cho con bú)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS pregnancy_category VARCHAR(10); -- FDA category (A, B, C, D, X)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS pregnancy_notes_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS pregnancy_notes_en TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS lactation_notes_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS lactation_notes_en TEXT;

-- Storage (Điều kiện bảo quản)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS storage_conditions_vi TEXT;
ALTER TABLE drug ADD COLUMN IF NOT EXISTS storage_conditions_en TEXT;

-- References (Link bài báo uy tín)
ALTER TABLE drug ADD COLUMN IF NOT EXISTS article_link_vi TEXT; -- Link bài viết tiếng Việt
ALTER TABLE drug ADD COLUMN IF NOT EXISTS article_link_en TEXT; -- Link bài viết tiếng Anh/quốc tế
ALTER TABLE drug ADD COLUMN IF NOT EXISTS reference_sources TEXT; -- JSON array of sources

-- ===== 2. CREATE DRUG INTERACTION TABLE =====
-- Tương tác thuốc-thuốc, thuốc-thức ăn, thuốc-bệnh lý
CREATE TABLE IF NOT EXISTS drug_interaction (
    interaction_id SERIAL PRIMARY KEY,
    drug_id INTEGER NOT NULL REFERENCES drug(drug_id) ON DELETE CASCADE,
    interaction_type VARCHAR(50) NOT NULL, -- 'drug', 'food', 'disease'
    interacts_with VARCHAR(255) NOT NULL, -- Tên thuốc/thức ăn/bệnh lý tương tác
    severity VARCHAR(50), -- 'major', 'moderate', 'minor'
    description_vi TEXT,
    description_en TEXT,
    clinical_effects_vi TEXT, -- Ảnh hưởng lâm sàng
    clinical_effects_en TEXT,
    management_vi TEXT, -- Khuyến nghị xử lý
    management_en TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for better performance
CREATE INDEX IF NOT EXISTS idx_drug_interaction_drug_id ON drug_interaction(drug_id);
CREATE INDEX IF NOT EXISTS idx_drug_interaction_type ON drug_interaction(interaction_type);

-- ===== 3. CREATE DRUG SIDE EFFECT TABLE =====
-- Chi tiết tác dụng phụ với tần suất
CREATE TABLE IF NOT EXISTS drug_side_effect (
    side_effect_id SERIAL PRIMARY KEY,
    drug_id INTEGER NOT NULL REFERENCES drug(drug_id) ON DELETE CASCADE,
    effect_name_vi VARCHAR(255) NOT NULL,
    effect_name_en VARCHAR(255),
    frequency VARCHAR(50), -- 'very_common' (>10%), 'common' (1-10%), 'uncommon' (0.1-1%), 'rare' (<0.1%)
    severity VARCHAR(50), -- 'mild', 'moderate', 'severe'
    description_vi TEXT,
    description_en TEXT,
    is_serious BOOLEAN DEFAULT false, -- Tác dụng phụ nghiêm trọng
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_drug_side_effect_drug_id ON drug_side_effect(drug_id);
CREATE INDEX IF NOT EXISTS idx_drug_side_effect_severity ON drug_side_effect(severity);

-- ===== 4. ADD COMMENTS FOR DOCUMENTATION =====
COMMENT ON TABLE drug IS 'Comprehensive drug information with detailed pharmaceutical data';
COMMENT ON COLUMN drug.strength IS 'Drug strength/concentration (e.g., 500mg, 10mg/ml)';
COMMENT ON COLUMN drug.pregnancy_category IS 'FDA pregnancy category: A, B, C, D, X';
COMMENT ON COLUMN drug.article_link_vi IS 'Link to Vietnamese medical article/reference';
COMMENT ON COLUMN drug.article_link_en IS 'Link to international medical article/reference';

COMMENT ON TABLE drug_interaction IS 'Drug interactions: drug-drug, drug-food, drug-disease';
COMMENT ON COLUMN drug_interaction.interaction_type IS 'Type: drug, food, disease';
COMMENT ON COLUMN drug_interaction.severity IS 'Severity: major, moderate, minor';

COMMENT ON TABLE drug_side_effect IS 'Detailed side effects with frequency and severity';
COMMENT ON COLUMN drug_side_effect.frequency IS 'very_common (>10%), common (1-10%), uncommon (0.1-1%), rare (<0.1%)';

-- ===== 5. SAMPLE DATA FOR TESTING =====
-- Update existing Metformin record with comprehensive data
UPDATE drug 
SET 
    brand_name_vi = 'Glucophage, Gluformin',
    brand_name_en = 'Glucophage, Metformin HCl',
    active_ingredient = 'Metformin Hydrochloride',
    therapeutic_class = 'Thuốc điều trị đái tháo đường / Antidiabetic - Biguanide',
    strength = '500mg, 850mg, 1000mg',
    packaging = 'Hộp 3 vỉ x 10 viên nén bao phim',
    
    indications_vi = 'Điều trị đái tháo đường type 2, đặc biệt ở bệnh nhân thừa cân/béo phì khi chế độ ăn và tập luyện không đủ hiệu quả. Phòng ngừa biến chứng tim mạch ở bệnh nhân đái tháo đường.',
    indications_en = 'Treatment of type 2 diabetes mellitus, especially in overweight patients when diet and exercise alone are insufficient. Prevention of cardiovascular complications in diabetic patients.',
    
    dosage_adult_vi = 'Liều khởi đầu: 500mg, 1-2 lần/ngày sau ăn. Tăng dần 500mg mỗi tuần. Liều tối đa: 2000-2550mg/ngày, chia 2-3 lần.',
    dosage_adult_en = 'Initial dose: 500mg once or twice daily with meals. Increase by 500mg weekly. Maximum dose: 2000-2550mg/day in 2-3 divided doses.',
    dosage_pediatric_vi = 'Trẻ ≥10 tuổi: Bắt đầu 500mg/ngày, tối đa 2000mg/ngày chia 2 lần.',
    dosage_pediatric_en = 'Children ≥10 years: Start 500mg/day, maximum 2000mg/day in 2 divided doses.',
    dosage_special_vi = 'Suy thận eGFR 30-60: Giảm liều 50%. eGFR <30: Chống chỉ định. Suy gan: Tránh dùng.',
    dosage_special_en = 'Renal impairment eGFR 30-60: Reduce dose by 50%. eGFR <30: Contraindicated. Hepatic impairment: Avoid use.',
    
    contraindications_vi = 'Suy thận nặng (eGFR <30), nhiễm toan chuyển hóa, suy tim nặng, sốc, suy gan, nghiện rượu, quá mẫn với metformin.',
    contraindications_en = 'Severe renal impairment (eGFR <30), metabolic acidosis, severe heart failure, shock, hepatic impairment, alcoholism, hypersensitivity to metformin.',
    
    warnings_vi = 'Nguy cơ nhiễm toan lactic (hiếm nhưng nghiêm trọng). Ngừng thuốc trước phẫu thuật hoặc tiêm thuốc cản quang có iod 48h. Theo dõi chức năng thận định kỳ. Có thể thiếu vitamin B12 khi dùng lâu dài.',
    warnings_en = 'Risk of lactic acidosis (rare but serious). Discontinue 48h before surgery or iodinated contrast procedures. Monitor renal function regularly. May cause vitamin B12 deficiency with long-term use.',
    
    common_side_effects_vi = 'Buồn nôn, tiêu chảy, đau bụng, chướng hơi, giảm ngon miệng (thường tự hết sau 1-2 tuần)',
    common_side_effects_en = 'Nausea, diarrhea, abdominal pain, bloating, decreased appetite (usually resolve after 1-2 weeks)',
    serious_side_effects_vi = 'Nhiễm toan lactic (hiếm), thiếu vitamin B12, hạ đường huyết khi dùng kết hợp insulin/sulfonylurea',
    serious_side_effects_en = 'Lactic acidosis (rare), vitamin B12 deficiency, hypoglycemia when combined with insulin/sulfonylurea',
    
    mechanism_of_action_vi = 'Giảm sản xuất glucose ở gan, tăng độ nhạy insulin ở mô ngoại vi, giảm hấp thu glucose ở ruột.',
    mechanism_of_action_en = 'Decreases hepatic glucose production, increases insulin sensitivity in peripheral tissues, reduces intestinal glucose absorption.',
    pharmacokinetics_vi = 'Hấp thu: 50-60%, đạt nồng độ đỉnh sau 2-3h. Không liên kết protein huyết tương. Không chuyển hóa gan. Thải trừ qua thận (90%), T1/2 = 4-8.7h.',
    pharmacokinetics_en = 'Absorption: 50-60%, peak in 2-3h. No plasma protein binding. Not metabolized. Renal excretion (90%), T1/2 = 4-8.7h.',
    
    overdose_symptoms_vi = 'Hạ đường huyết, buồn nôn/nôn, tiêu chảy, đau bụng. Nguy cơ nhiễm toan lactic với liều rất cao.',
    overdose_symptoms_en = 'Hypoglycemia, nausea/vomiting, diarrhea, abdominal pain. Risk of lactic acidosis with very high doses.',
    overdose_treatment_vi = 'Điều trị triệu chứng. Glucose nếu hạ đường huyết. Lọc máu nếu nhiễm toan lactic.',
    overdose_treatment_en = 'Symptomatic treatment. Glucose for hypoglycemia. Hemodialysis for lactic acidosis.',
    
    pregnancy_category = 'B',
    pregnancy_notes_vi = 'Có thể dùng trong thai kỳ nếu lợi ích > nguy cơ. Insulin vẫn là lựa chọn ưu tiên.',
    pregnancy_notes_en = 'May be used during pregnancy if benefits outweigh risks. Insulin remains preferred choice.',
    lactation_notes_vi = 'Bài tiết vào sữa mẹ với nồng độ thấp. Cân nhắc lợi ích/nguy cơ khi cho con bú.',
    lactation_notes_en = 'Excreted in breast milk at low levels. Weigh benefits/risks when breastfeeding.',
    
    storage_conditions_vi = 'Bảo quản nơi khô mát, nhiệt độ dưới 30°C. Tránh ánh sáng trực tiếp. Để xa tầm tay trẻ em.',
    storage_conditions_en = 'Store in a cool, dry place below 30°C. Protect from light. Keep out of reach of children.',
    
    article_link_vi = 'https://tapdoctinh.vn/metformin-dieu-tri-dai-thao-duong',
    article_link_en = 'https://www.ncbi.nlm.nih.gov/books/NBK518983/',
    reference_sources = '["American Diabetes Association Guidelines 2024", "WHO Essential Medicines List", "UpToDate - Metformin", "Vietnam National Drug Information 2024"]'
WHERE name_en = 'Metformin' OR name_vi LIKE '%Metformin%';

-- Insert sample drug interactions for Metformin
INSERT INTO drug_interaction (drug_id, interaction_type, interacts_with, severity, description_vi, description_en, clinical_effects_vi, clinical_effects_en, management_vi, management_en)
SELECT 
    drug_id,
    'food',
    'Rượu / Alcohol',
    'major',
    'Rượu làm tăng nguy cơ nhiễm toan lactic khi dùng metformin',
    'Alcohol increases risk of lactic acidosis with metformin',
    'Nguy cơ nhiễm toan lactic, hạ đường huyết',
    'Risk of lactic acidosis, hypoglycemia',
    'Tránh uống rượu khi đang dùng metformin. Nếu uống, chỉ với lượng nhỏ và có ăn kèm.',
    'Avoid alcohol while taking metformin. If consumed, only in small amounts with food.'
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

INSERT INTO drug_interaction (drug_id, interaction_type, interacts_with, severity, description_vi, description_en, clinical_effects_vi, clinical_effects_en, management_vi, management_en)
SELECT 
    drug_id,
    'drug',
    'Thuốc cản quang có iod / Iodinated contrast media',
    'major',
    'Thuốc cản quang có thể gây suy thận cấp, tăng nguy cơ nhiễm toan lactic',
    'Contrast media may cause acute renal failure, increasing lactic acidosis risk',
    'Suy thận cấp, nhiễm toan lactic',
    'Acute renal failure, lactic acidosis',
    'Ngừng metformin trước 48h khi chụp có cản quang. Chỉ dùng lại sau 48h nếu chức năng thận bình thường.',
    'Discontinue metformin 48h before contrast imaging. Resume 48h after if renal function is normal.'
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

INSERT INTO drug_interaction (drug_id, interaction_type, interacts_with, severity, description_vi, description_en, clinical_effects_vi, clinical_effects_en, management_vi, management_en)
SELECT 
    drug_id,
    'drug',
    'Insulin, Sulfonylurea',
    'moderate',
    'Tăng nguy cơ hạ đường huyết khi phối hợp',
    'Increased risk of hypoglycemia when combined',
    'Hạ đường huyết',
    'Hypoglycemia',
    'Theo dõi đường huyết thường xuyên. Có thể cần giảm liều insulin/sulfonylurea.',
    'Monitor blood glucose frequently. May need to reduce insulin/sulfonylurea dose.'
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

-- Insert sample side effects for Metformin
INSERT INTO drug_side_effect (drug_id, effect_name_vi, effect_name_en, frequency, severity, description_vi, description_en, is_serious)
SELECT 
    drug_id,
    'Tiêu chảy',
    'Diarrhea',
    'very_common',
    'mild',
    'Phân lỏng, đi ngoài nhiều lần. Thường giảm sau 1-2 tuần.',
    'Loose stools, frequent bowel movements. Usually resolves after 1-2 weeks.',
    false
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

INSERT INTO drug_side_effect (drug_id, effect_name_vi, effect_name_en, frequency, severity, description_vi, description_en, is_serious)
SELECT 
    drug_id,
    'Buồn nôn',
    'Nausea',
    'very_common',
    'mild',
    'Cảm giác khó chịu ở dạ dày, muốn nôn. Uống thuốc sau ăn để giảm.',
    'Stomach discomfort, feeling like vomiting. Take with food to reduce.',
    false
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

INSERT INTO drug_side_effect (drug_id, effect_name_vi, effect_name_en, frequency, severity, description_vi, description_en, is_serious)
SELECT 
    drug_id,
    'Nhiễm toan lactic',
    'Lactic Acidosis',
    'rare',
    'severe',
    'Tích tụ acid lactic trong máu. Triệu chứng: mệt, khó thở, đau bụng, rối loạn nhịp tim.',
    'Accumulation of lactic acid in blood. Symptoms: fatigue, breathing difficulty, abdominal pain, arrhythmia.',
    true
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

INSERT INTO drug_side_effect (drug_id, effect_name_vi, effect_name_en, frequency, severity, description_vi, description_en, is_serious)
SELECT 
    drug_id,
    'Thiếu Vitamin B12',
    'Vitamin B12 Deficiency',
    'common',
    'moderate',
    'Dùng lâu dài có thể giảm hấp thu B12. Triệu chứng: mệt, thiếu máu, tê bì chân tay.',
    'Long-term use may reduce B12 absorption. Symptoms: fatigue, anemia, numbness in extremities.',
    false
FROM drug WHERE name_en = 'Metformin' LIMIT 1;

-- ===== 6. CREATE UPDATE TRIGGER =====
CREATE OR REPLACE FUNCTION update_drug_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_drug_timestamp ON drug;
CREATE TRIGGER trigger_update_drug_timestamp
    BEFORE UPDATE ON drug
    FOR EACH ROW
    EXECUTE FUNCTION update_drug_updated_at();

DROP TRIGGER IF EXISTS trigger_update_drug_interaction_timestamp ON drug_interaction;
CREATE TRIGGER trigger_update_drug_interaction_timestamp
    BEFORE UPDATE ON drug_interaction
    FOR EACH ROW
    EXECUTE FUNCTION update_drug_updated_at();

DROP TRIGGER IF EXISTS trigger_update_drug_side_effect_timestamp ON drug_side_effect;
CREATE TRIGGER trigger_update_drug_side_effect_timestamp
    BEFORE UPDATE ON drug_side_effect
    FOR EACH ROW
    EXECUTE FUNCTION update_drug_updated_at();

-- ===== MIGRATION COMPLETE =====
-- Check results
SELECT 'Migration completed successfully!' AS status;
SELECT 'Total drugs: ' || COUNT(*) FROM drug;
SELECT 'Total interactions: ' || COUNT(*) FROM drug_interaction;
SELECT 'Total side effects: ' || COUNT(*) FROM drug_side_effect;
