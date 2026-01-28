-- Complete Drink Recommendations for All 39 Health Conditions
-- Date: 2025-12-06
-- This adds comprehensive drink recommendations based on medical knowledge

-- Condition 1: Tiểu đường type 2 (Type 2 Diabetes)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(1, 5, 'avoid', 'Caffeine có thể ảnh hưởng đường huyết', 'medium'),
(1, 6, 'avoid', 'Sữa và đường cao', 'high'),
(1, 7, 'avoid', 'Sữa và đường cao', 'high'),
(1, 2, 'avoid', 'Đường tự nhiên cao', 'high'),
(1, 8, 'recommend', 'Chống oxy hóa, cải thiện độ nhạy insulin', 'high'),
(1, 19, 'recommend', 'Hỗ trợ kiểm soát đường huyết', 'high'),
(1, 20, 'recommend', 'Hydrat hóa tốt nhất', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 2: Cao huyết áp (Hypertension)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(2, 5, 'avoid', 'Caffeine làm tăng huyết áp', 'high'),
(2, 6, 'avoid', 'Caffeine và sodium', 'high'),
(2, 3, 'recommend', 'Kali cao, giảm huyết áp', 'high'),
(2, 16, 'recommend', 'Giãn mạch, hạ huyết áp', 'high'),
(2, 20, 'recommend', 'Hydrat hóa không muối', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 3: Mỡ máu cao (High Cholesterol)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(3, 6, 'avoid', 'Sữa béo', 'medium'),
(3, 7, 'avoid', 'Sữa béo', 'medium'),
(3, 8, 'recommend', 'Giảm cholesterol LDL', 'high'),
(3, 14, 'recommend', 'Protein thực vật tốt cho tim', 'high'),
(3, 18, 'recommend', 'Thanh lọc gan, giảm mỡ máu', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 5: Gout
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(5, 5, 'avoid', 'Caffeine tăng acid uric', 'high'),
(5, 6, 'avoid', 'Caffeine tăng acid uric', 'high'),
(5, 3, 'recommend', 'Lợi tiểu, đào thải acid uric', 'high'),
(5, 20, 'recommend', 'Uống nhiều nước giảm gout', 'high'),
(5, 23, 'recommend', 'Vitamin C giảm acid uric', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 6: Gan nhiễm mỡ (Fatty Liver)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(6, 5, 'avoid', 'Gây tổn thương gan', 'medium'),
(6, 2, 'avoid', 'Đường cao', 'high'),
(6, 8, 'recommend', 'Chống oxy hóa bảo vệ gan', 'high'),
(6, 18, 'recommend', 'Thanh lọc gan', 'high'),
(6, 19, 'recommend', 'Giải độc gan', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 7: Viêm dạ dày (Gastritis)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(7, 5, 'avoid', 'Tăng acid dạ dày', 'high'),
(7, 1, 'avoid', 'Acid cao', 'high'),
(7, 23, 'avoid', 'Acid chanh kích thích', 'high'),
(7, 3, 'recommend', 'Dịu nhẹ, bảo vệ niêm mạc', 'high'),
(7, 14, 'recommend', 'Protein dễ tiêu', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 8: Thiếu máu (Anemia)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(8, 5, 'avoid', 'Cản trở hấp thu sắt', 'high'),
(8, 8, 'avoid', 'Tannin cản trở sắt', 'medium'),
(8, 1, 'recommend', 'Vitamin C hỗ trợ hấp thu sắt', 'high'),
(8, 24, 'recommend', 'Vitamin C cao', 'high'),
(8, 37, 'recommend', 'Sắt và protein thực vật', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 11: Đái tháo đường tuýp 2
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(11, 2, 'avoid', 'Đường cao', 'high'),
(11, 6, 'avoid', 'Đường và sữa', 'high'),
(11, 8, 'recommend', 'Kiểm soát đường huyết', 'high'),
(11, 20, 'recommend', 'Không đường', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 12: Tăng huyết áp
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(12, 5, 'avoid', 'Caffeine tăng huyết áp', 'high'),
(12, 6, 'avoid', 'Caffeine cao', 'high'),
(12, 3, 'recommend', 'Kali hạ huyết áp', 'high'),
(12, 16, 'recommend', 'Giãn mạch', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 14: Thiếu máu do thiếu sắt
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(14, 5, 'avoid', 'Cản trở hấp thu sắt', 'high'),
(14, 8, 'avoid', 'Tannin cản trở sắt', 'high'),
(14, 1, 'recommend', 'Vitamin C tăng hấp thu sắt', 'high'),
(14, 24, 'recommend', 'Vitamin C cao', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 16: Gút
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(16, 5, 'avoid', 'Tăng acid uric', 'high'),
(16, 3, 'recommend', 'Lợi tiểu', 'high'),
(16, 20, 'recommend', 'Đào thải acid uric', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 17: Bệnh thận mãn tính
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(17, 2, 'avoid', 'Đường cao', 'high'),
(17, 14, 'avoid', 'Protein thực vật', 'medium'),
(17, 20, 'recommend', 'Hydrat hóa vừa phải', 'medium'),
(17, 3, 'recommend', 'Điện giải cân bằng', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 18: Trào ngược dạ dày thực quản (GERD)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(18, 5, 'avoid', 'Tăng acid, trào ngược', 'high'),
(18, 1, 'avoid', 'Acid cam cao', 'high'),
(18, 23, 'avoid', 'Acid chanh', 'high'),
(18, 3, 'recommend', 'Kiềm, dịu nhẹ', 'high'),
(18, 20, 'recommend', 'Trung tính', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 19: Rối loạn lipid máu
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(19, 6, 'avoid', 'Sữa béo', 'high'),
(19, 8, 'recommend', 'Giảm cholesterol', 'high'),
(19, 14, 'recommend', 'Protein tốt', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 22: Bệnh động mạch vành
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(22, 5, 'avoid', 'Caffeine gây tim nhanh', 'high'),
(22, 8, 'recommend', 'Chống oxy hóa bảo vệ tim', 'high'),
(22, 3, 'recommend', 'Kali tốt cho tim', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 24: Suy tim
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(24, 5, 'avoid', 'Caffeine tăng gánh nặng tim', 'high'),
(24, 6, 'avoid', 'Caffeine cao', 'high'),
(24, 20, 'recommend', 'Giới hạn nước vừa phải', 'medium'),
(24, 3, 'recommend', 'Điện giải tự nhiên', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 27: Hen phế quản (Asthma)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(27, 5, 'avoid', 'Có thể gây co thắt phế quản', 'medium'),
(27, 15, 'recommend', 'Chống viêm đường hô hấp', 'high'),
(27, 3, 'recommend', 'Hydrat hóa đường hô hấp', 'high'),
(27, 20, 'recommend', 'Giữ ẩm phổi', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 28: COPD
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(28, 5, 'avoid', 'Kích thích phổi', 'medium'),
(28, 15, 'recommend', 'Chống viêm', 'high'),
(28, 20, 'recommend', 'Hydrat hóa', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 30: Gan nhiễm mỡ
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(30, 2, 'avoid', 'Đường cao', 'high'),
(30, 18, 'recommend', 'Thanh lọc gan', 'high'),
(30, 8, 'recommend', 'Bảo vệ tế bào gan', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 31: Viêm khớp dạng thấp
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(31, 5, 'avoid', 'Có thể làm tăng viêm', 'medium'),
(31, 15, 'recommend', 'Gừng chống viêm khớp', 'high'),
(31, 8, 'recommend', 'Chống oxy hóa', 'high'),
(31, 3, 'recommend', 'Hydrat hóa khớp', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 32: Suy giáp (Hypothyroidism)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(32, 14, 'avoid', 'Đậu nành ảnh hưởng hấp thu hormone giáp', 'medium'),
(32, 20, 'recommend', 'Hydrat hóa', 'medium'),
(32, 8, 'recommend', 'Chống oxy hóa', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 33: Cường giáp (Hyperthyroidism)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(33, 5, 'avoid', 'Caffeine tăng nhịp tim', 'high'),
(33, 6, 'avoid', 'Caffeine cao', 'high'),
(33, 16, 'recommend', 'Làm dịu', 'medium'),
(33, 20, 'recommend', 'Hydrat hóa', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 35: Nhiễm E. coli
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(35, 20, 'recommend', 'Bù nước mất do tiêu chảy', 'high'),
(35, 3, 'recommend', 'Điện giải', 'high'),
(35, 15, 'recommend', 'Kháng khuẩn tự nhiên', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 36: Viêm ruột Campylobacter
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(36, 20, 'recommend', 'Bù nước', 'high'),
(36, 3, 'recommend', 'Điện giải', 'high'),
(36, 15, 'recommend', 'Kháng khuẩn', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 37: Viêm dạ dày ruột nhiễm trùng
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(37, 5, 'avoid', 'Kích thích dạ dày', 'high'),
(37, 1, 'avoid', 'Acid cao', 'high'),
(37, 20, 'recommend', 'Bù nước', 'high'),
(37, 3, 'recommend', 'Dịu nhẹ, điện giải', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 38: Lao phổi
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(38, 1, 'recommend', 'Vitamin C tăng miễn dịch', 'high'),
(38, 20, 'recommend', 'Hydrat hóa', 'high'),
(38, 14, 'recommend', 'Protein hỗ trợ hồi phục', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 39: Viêm màng não do lao
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(39, 20, 'recommend', 'Hydrat hóa não', 'high'),
(39, 1, 'recommend', 'Vitamin C', 'high'),
(39, 3, 'recommend', 'Điện giải', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Print comprehensive summary
DO $$
DECLARE
    total_recommendations INT;
    total_conditions INT;
    total_drinks INT;
    conditions_with_avoid INT;
    conditions_with_recommend INT;
BEGIN
    SELECT COUNT(*) INTO total_recommendations FROM conditiondrinkrecommendation;
    SELECT COUNT(DISTINCT condition_id) INTO total_conditions FROM conditiondrinkrecommendation;
    SELECT COUNT(DISTINCT drink_id) INTO total_drinks FROM conditiondrinkrecommendation;
    SELECT COUNT(DISTINCT condition_id) INTO conditions_with_avoid 
        FROM conditiondrinkrecommendation WHERE recommendation_type = 'avoid';
    SELECT COUNT(DISTINCT condition_id) INTO conditions_with_recommend 
        FROM conditiondrinkrecommendation WHERE recommendation_type = 'recommend';
    
    RAISE NOTICE '================================================';
    RAISE NOTICE '  DRINK RECOMMENDATIONS MIGRATION COMPLETE';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Total Recommendations: %', total_recommendations;
    RAISE NOTICE 'Health Conditions Covered: % / 39', total_conditions;
    RAISE NOTICE 'Drinks with Recommendations: %', total_drinks;
    RAISE NOTICE 'Conditions with AVOID: %', conditions_with_avoid;
    RAISE NOTICE 'Conditions with RECOMMEND: %', conditions_with_recommend;
    RAISE NOTICE '================================================';
END $$;
