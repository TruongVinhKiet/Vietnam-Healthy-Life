-- Migration: Upgrade HealthCondition Table
-- Date: 2025-12-05
-- Description: Add new fields for comprehensive health condition management

-- Add new fields to healthcondition table
ALTER TABLE healthcondition 
ADD COLUMN IF NOT EXISTS article_link_vi TEXT,
ADD COLUMN IF NOT EXISTS article_link_en TEXT,
ADD COLUMN IF NOT EXISTS prevention_tips TEXT,
ADD COLUMN IF NOT EXISTS prevention_tips_vi TEXT,
ADD COLUMN IF NOT EXISTS severity_level VARCHAR(20) DEFAULT 'moderate' CHECK (severity_level IN ('mild', 'moderate', 'severe', 'critical')),
ADD COLUMN IF NOT EXISTS is_chronic BOOLEAN DEFAULT false;

-- Update comments
COMMENT ON COLUMN healthcondition.article_link_vi IS 'Link to Vietnamese medical article about this condition';
COMMENT ON COLUMN healthcondition.article_link_en IS 'Link to English medical article about this condition';
COMMENT ON COLUMN healthcondition.prevention_tips IS 'Prevention tips in English';
COMMENT ON COLUMN healthcondition.prevention_tips_vi IS 'Prevention tips in Vietnamese';
COMMENT ON COLUMN healthcondition.severity_level IS 'Severity level: mild, moderate, severe, critical';
COMMENT ON COLUMN healthcondition.is_chronic IS 'Whether this is a chronic condition requiring long-term management';

-- Insert sample data for hypertension (Cao huyết áp)
INSERT INTO healthcondition (
    condition_id, name_vi, name_en, category, description_vi, description, 
    causes, image_url, treatment_duration_reference, 
    article_link_vi, article_link_en, prevention_tips_vi, prevention_tips,
    severity_level, is_chronic
) VALUES (
    23115, 
    'Cao huyết áp', 
    'Hypertension', 
    'Tim mạch',
    'Cao huyết áp là tình trạng huyết áp tăng cao mạn tính. Huyết áp cao làm tăng nguy cơ mắc bệnh tim, đột quỵ, và các vấn đề sức khỏe nghiêm trọng khác.',
    'Hypertension is a chronic condition characterized by elevated blood pressure. High blood pressure increases the risk of heart disease, stroke, and other serious health problems.',
    'Ăn mặn, ít kali, stress, di truyền.',
    'https://cdn.tgdd.vn/Files/2021/06/15/1358975/cao-huyet-ap-nguyen-nhan-trieu-chung-dieu-tri-va-phong-ngua-202106151442072634.jpg',
    'Dài hạn',
    'https://vinmec.com/vie/benh/cao-huyet-ap-6314',
    'https://www.mayoclinic.org/diseases-conditions/high-blood-pressure/symptoms-causes/syc-20373410',
    'Hạn chế muối, tăng cường kali, tập thể dục đều đặn, giảm stress, tránh rượu bia.',
    'Limit salt intake, increase potassium, regular exercise, reduce stress, avoid alcohol.',
    'moderate',
    true
) ON CONFLICT (condition_id) DO UPDATE SET
    name_vi = EXCLUDED.name_vi,
    name_en = EXCLUDED.name_en,
    description_vi = EXCLUDED.description_vi,
    description = EXCLUDED.description,
    image_url = EXCLUDED.image_url,
    article_link_vi = EXCLUDED.article_link_vi,
    article_link_en = EXCLUDED.article_link_en,
    prevention_tips_vi = EXCLUDED.prevention_tips_vi,
    prevention_tips = EXCLUDED.prevention_tips,
    severity_level = EXCLUDED.severity_level,
    is_chronic = EXCLUDED.is_chronic,
    updated_at = NOW();

-- Insert sample data for diabetes type 2
INSERT INTO healthcondition (
    condition_id, name_vi, name_en, category, description_vi, description, 
    causes, image_url, treatment_duration_reference, 
    article_link_vi, article_link_en, prevention_tips_vi, prevention_tips,
    severity_level, is_chronic
) VALUES (
    3717, 
    'Đái tháo đường type 2', 
    'Diabetes mellitus type 2', 
    'Nội tiết',
    'Đái tháo đường type 2 là bệnh rối loạn chuyển hóa đường trong máu do cơ thể không sản xuất đủ insulin hoặc không sử dụng hiệu quả insulin.',
    'Type 2 diabetes is a metabolic disorder characterized by high blood sugar levels due to insulin resistance or insufficient insulin production.',
    'Béo phì, ít vận động, di truyền, chế độ ăn nhiều đường.',
    'https://cdn.tgdd.vn/Files/2022/02/01/1414070/tieu-duong-type-2-la-gi-nguyen-nhan-va-cach-phong-ngua-202202011434196274.jpg',
    'Dài hạn',
    'https://vinmec.com/vie/benh/dai-thao-duong-type-2-6521',
    'https://www.mayoclinic.org/diseases-conditions/type-2-diabetes/symptoms-causes/syc-20351193',
    'Duy trì cân nặng hợp lý, tập thể dục, ăn ít đường và tinh bột tinh chế, tăng chất xơ.',
    'Maintain healthy weight, regular exercise, limit sugar and refined carbs, increase fiber intake.',
    'moderate',
    true
) ON CONFLICT (condition_id) DO UPDATE SET
    name_vi = EXCLUDED.name_vi,
    name_en = EXCLUDED.name_en,
    description_vi = EXCLUDED.description_vi,
    description = EXCLUDED.description,
    image_url = EXCLUDED.image_url,
    article_link_vi = EXCLUDED.article_link_vi,
    article_link_en = EXCLUDED.article_link_en,
    prevention_tips_vi = EXCLUDED.prevention_tips_vi,
    prevention_tips = EXCLUDED.prevention_tips,
    severity_level = EXCLUDED.severity_level,
    is_chronic = EXCLUDED.is_chronic,
    updated_at = NOW();

-- Insert sample data for asthma
INSERT INTO healthcondition (
    condition_id, name_vi, name_en, category, description_vi, description, 
    causes, image_url, treatment_duration_reference, 
    article_link_vi, article_link_en, prevention_tips_vi, prevention_tips,
    severity_level, is_chronic
) VALUES (
    10788, 
    'Hen suyễn', 
    'Asthma', 
    'Hô hấp',
    'Hen suyễn là bệnh viêm mạn tính đường hô hấp gây khó thở, thở khò khè, và ho.',
    'Asthma is a chronic inflammatory disease of the airways causing breathing difficulties, wheezing, and coughing.',
    'Dị ứng, ô nhiễm không khí, di truyền, nhiễm trùng hô hấp.',
    'https://cdn.tgdd.vn/Files/2023/04/20/1521186/hen-suyen-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202304201558389831.jpg',
    'Dài hạn',
    'https://vinmec.com/vie/benh/hen-suyen-6312',
    'https://www.mayoclinic.org/diseases-conditions/asthma/symptoms-causes/syc-20369653',
    'Tránh chất gây dị ứng, không hút thuốc, giữ vệ sinh nhà cửa, tập thở.',
    'Avoid allergens, no smoking, keep home clean, breathing exercises.',
    'moderate',
    true
) ON CONFLICT (condition_id) DO UPDATE SET
    name_vi = EXCLUDED.name_vi,
    name_en = EXCLUDED.name_en,
    description_vi = EXCLUDED.description_vi,
    description = EXCLUDED.description,
    image_url = EXCLUDED.image_url,
    article_link_vi = EXCLUDED.article_link_vi,
    article_link_en = EXCLUDED.article_link_en,
    prevention_tips_vi = EXCLUDED.prevention_tips_vi,
    prevention_tips = EXCLUDED.prevention_tips,
    severity_level = EXCLUDED.severity_level,
    is_chronic = EXCLUDED.is_chronic,
    updated_at = NOW();

-- Add some food recommendations (foods to avoid and recommend)
-- For Hypertension (23115)
INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 23115, food_id, 'avoid', 'Thực phẩm nhiều muối làm tăng huyết áp'
FROM food 
WHERE name_vi ILIKE ANY(ARRAY['%muối%', '%nước mắm%', '%dưa muối%', '%thịt xông khói%', '%xúc xích%'])
ON CONFLICT DO NOTHING;

INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 23115, food_id, 'recommend', 'Giàu kali, giúp giảm huyết áp'
FROM food 
WHERE name_vi ILIKE ANY(ARRAY['%chuối%', '%rau bina%', '%khoai lang%', '%bơ%', '%cà chua%'])
ON CONFLICT DO NOTHING;

-- For Diabetes Type 2 (3717)
INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 3717, food_id, 'avoid', 'Chứa nhiều đường, tăng đường huyết nhanh'
FROM food 
WHERE name_vi ILIKE ANY(ARRAY['%kẹo%', '%bánh ngọt%', '%nước ngọt%', '%kem%', '%sữa đặc%'])
ON CONFLICT DO NOTHING;

INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 3717, food_id, 'recommend', 'Giàu chất xơ, kiểm soát đường huyết'
FROM food 
WHERE name_vi ILIKE ANY(ARRAY['%yến mạch%', '%đậu%', '%rau xanh%', '%quả óc chó%', '%cá hồi%'])
ON CONFLICT DO NOTHING;
