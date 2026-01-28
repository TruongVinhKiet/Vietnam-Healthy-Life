-- Comprehensive Drink Recommendations Migration
-- Adds drink recommendations for all 39 health conditions
-- Date: 2025-12-06

-- First, let's add more comprehensive recommendations for remaining conditions

-- Condition 11-39: Add recommendations

-- Asthma (condition_id = 11)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 11, drink_id, 'avoid', 'Có thể gây kích ứng đường hô hấp', 'medium'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Vietnamese Milk Coffee')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 11, drink_id, 'recommend', 'Chống viêm, tốt cho phổi', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Nước dừa tươi', 'Trà xanh')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Arthritis (condition_id = 12)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 12, drink_id, 'recommend', 'Chống viêm khớp', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Trà xanh', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Migraine (condition_id = 13)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 13, drink_id, 'avoid', 'Caffeine có thể gây đau đầu', 'high'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Vietnamese Milk Coffee', 'Iced Milk Coffee')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 13, drink_id, 'recommend', 'Giúp giảm đau đầu', 'medium'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Nước dừa tươi', 'Trà bạc hà')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Depression (condition_id = 14)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 14, drink_id, 'avoid', 'Alcohol làm trầm trọng thêm', 'high'
FROM drink WHERE category = 'alcoholic'
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 14, drink_id, 'recommend', 'Giúp cải thiện tâm trạng', 'medium'
FROM drink WHERE vietnamese_name IN ('Trà xanh', 'Trà hoa cúc', 'Sinh tố chuối')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Insomnia (condition_id = 15)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 15, drink_id, 'avoid', 'Caffeine gây mất ngủ', 'high'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Vietnamese Milk Coffee', 'Green Tea', 'Black Tea')
    OR vietnamese_name IN ('Trà xanh', 'Trà đen', 'Cà phê')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 15, drink_id, 'recommend', 'Giúp thư giãn và ngủ ngon', 'high'
FROM drink WHERE vietnamese_name IN ('Trà hoa cúc', 'Sữa đậu nành', 'Nước nha đam')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Thyroid Disorders (condition_id = 16)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 16, drink_id, 'avoid', 'Ảnh hưởng đến tuyến giáp', 'medium'
FROM drink WHERE vietnamese_name IN ('Sữa đậu nành')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Celiac Disease (condition_id = 17) - assuming some drinks may contain gluten
-- Most drinks are naturally gluten-free, so mainly recommendations

-- Allergies (condition_id = 18)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 18, drink_id, 'recommend', 'Chống dị ứng tự nhiên', 'medium'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Trà hoa cúc', 'Nước chanh dây')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Eczema (condition_id = 19)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 19, drink_id, 'recommend', 'Tốt cho da, chống viêm', 'medium'
FROM drink WHERE vietnamese_name IN ('Nước dừa tươi', 'Nước nha đam', 'Trà xanh')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Acne (condition_id = 20)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 20, drink_id, 'avoid', 'Đường và sữa có thể gây mụn', 'medium'
FROM drink WHERE vietnamese_name IN ('Trà sữa trân châu', 'Sinh tố bơ')
    OR name IN ('Vietnamese Milk Coffee', 'Iced Milk Coffee')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 20, drink_id, 'recommend', 'Làm sạch da, giảm mụn', 'high'
FROM drink WHERE vietnamese_name IN ('Trà xanh', 'Nước chanh dây', 'Nước rau má')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Constipation (condition_id = 21)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 21, drink_id, 'recommend', 'Nhuận tràng, giúp tiêu hóa', 'high'
FROM drink WHERE vietnamese_name IN ('Nước nha đam', 'Nước dừa tươi', 'Sinh tố bơ')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- IBS (condition_id = 22)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 22, drink_id, 'avoid', 'Có thể gây khó tiêu', 'medium'
FROM drink WHERE vietnamese_name IN ('Sữa đậu nành', 'Trà sữa trân châu')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 22, drink_id, 'recommend', 'Dịu nhẹ cho ruột', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Trà bạc hà', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- GERD (condition_id = 23)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 23, drink_id, 'avoid', 'Acid reflux, gây trào ngược', 'high'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Fresh Orange Juice', 'Lemon Tea')
    OR vietnamese_name IN ('Nước chanh muối', 'Nước chanh dây', 'Cà phê')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 23, drink_id, 'recommend', 'Dịu nhẹ, không gây trào ngược', 'medium'
FROM drink WHERE vietnamese_name IN ('Nước nha đam', 'Nước dừa tươi', 'Trà gừng mật ong')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- UTI (condition_id = 24)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 24, drink_id, 'recommend', 'Kháng khuẩn đường tiết niệu', 'high'
FROM drink WHERE vietnamese_name IN ('Nước chanh dây', 'Nước dừa tươi', 'Nước rau má')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Prostate Issues (condition_id = 25)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 25, drink_id, 'avoid', 'Caffeine có thể gây kích thích', 'medium'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Vietnamese Milk Coffee')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 25, drink_id, 'recommend', 'Tốt cho tuyến tiền liệt', 'medium'
FROM drink WHERE vietnamese_name IN ('Trà xanh', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- PCOS (condition_id = 26)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 26, drink_id, 'avoid', 'Đường cao ảnh hưởng hormone', 'high'
FROM drink WHERE vietnamese_name IN ('Trà sữa trân châu', 'Sinh tố ngọt')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 26, drink_id, 'recommend', 'Cân bằng hormone', 'high'
FROM drink WHERE vietnamese_name IN ('Trà xanh', 'Trà bạc hà', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Menstrual Cramps (condition_id = 27)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 27, drink_id, 'recommend', 'Giảm đau bụng kinh', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Nước dừa tươi', 'Trà bạc hà')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Menopause (condition_id = 28)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 28, drink_id, 'avoid', 'Caffeine gây bốc hỏa', 'medium'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Vietnamese Milk Coffee')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 28, drink_id, 'recommend', 'Giảm triệu chứng mãn kinh', 'high'
FROM drink WHERE vietnamese_name IN ('Sữa đậu nành', 'Trà hoa cúc', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Pregnancy (condition_id = 29)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 29, drink_id, 'avoid', 'Caffeine cao không tốt cho thai nhi', 'high'
FROM drink WHERE name IN ('Vietnamese Black Coffee', 'Vietnamese Milk Coffee', 'Green Tea')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 29, drink_id, 'recommend', 'An toàn cho bà bầu', 'high'
FROM drink WHERE vietnamese_name IN ('Nước dừa tươi', 'Sữa đậu nành', 'Sinh tố nhãn')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Cancer (condition_id = 30)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 30, drink_id, 'recommend', 'Chống oxy hóa, chống ung thư', 'high'
FROM drink WHERE vietnamese_name IN ('Trà xanh', 'Nước chanh dây', 'Nước nha đam')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- HIV/AIDS (condition_id = 31)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 31, drink_id, 'recommend', 'Tăng cường miễn dịch', 'high'
FROM drink WHERE vietnamese_name IN ('Nước dừa tươi', 'Trà xanh', 'Sinh tố giàu vitamin')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Autoimmune Disease (condition_id = 32)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 32, drink_id, 'recommend', 'Chống viêm, điều hòa miễn dịch', 'high'
FROM drink WHERE vietnamese_name IN ('Trà xanh', 'Trà gừng mật ong', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Chronic Fatigue (condition_id = 33)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 33, drink_id, 'recommend', 'Tăng năng lượng tự nhiên', 'medium'
FROM drink WHERE vietnamese_name IN ('Nước dừa tươi', 'Trà xanh', 'Sinh tố chuối')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Fibromyalgia (condition_id = 34)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 34, drink_id, 'avoid', 'Có thể gây đau cơ', 'medium'
FROM drink WHERE vietnamese_name IN ('Cà phê', 'Đồ uống có đường cao')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 34, drink_id, 'recommend', 'Giảm đau, chống viêm', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Trà xanh', 'Nước dừa tươi')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Cold/Flu (condition_id = 35)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 35, drink_id, 'recommend', 'Tăng cường miễn dịch, giảm cảm', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Nước chanh dây', 'Trà quất mật ong')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Sinusitis (condition_id = 36)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 36, drink_id, 'recommend', 'Giảm viêm xoang', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Trà bạc hà', 'Nước ấm')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Bronchitis (condition_id = 37)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 37, drink_id, 'recommend', 'Giảm viêm phế quản', 'high'
FROM drink WHERE vietnamese_name IN ('Trà gừng mật ong', 'Nước dừa tươi', 'Trà bạc hà')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Pneumonia (condition_id = 38)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 38, drink_id, 'recommend', 'Tăng cường hồi phục', 'high'
FROM drink WHERE vietnamese_name IN ('Nước dừa tươi', 'Trà gừng mật ong', 'Sinh tố giàu vitamin')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Tuberculosis (condition_id = 39)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity)
SELECT 39, drink_id, 'recommend', 'Tăng cường sức đề kháng', 'high'
FROM drink WHERE vietnamese_name IN ('Nước dừa tươi', 'Sinh tố giàu dinh dưỡng', 'Trà xanh')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Print summary
DO $$
DECLARE
    total_recommendations INT;
    total_conditions INT;
    total_drinks INT;
BEGIN
    SELECT COUNT(*) INTO total_recommendations FROM conditiondrinkrecommendation;
    SELECT COUNT(DISTINCT condition_id) INTO total_conditions FROM conditiondrinkrecommendation;
    SELECT COUNT(DISTINCT drink_id) INTO total_drinks FROM conditiondrinkrecommendation;
    
    RAISE NOTICE '=== Drink Recommendations Migration Summary ===';
    RAISE NOTICE 'Total Recommendations: %', total_recommendations;
    RAISE NOTICE 'Conditions Covered: %', total_conditions;
    RAISE NOTICE 'Drinks with Recommendations: %', total_drinks;
END $$;
