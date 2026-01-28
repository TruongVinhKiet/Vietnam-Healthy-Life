-- Migration: Enrich Nutrient table with image_url, benefits, and contraindications
-- Adds user-facing data for vitamins, minerals, fibers, fatty acids, and amino acids

BEGIN;

-- ============================================================
-- VITAMINS
-- ============================================================

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/484/small/vitamin-a-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Tốt cho thị lực, tăng cường miễn dịch, hỗ trợ sức khỏe da'
WHERE UPPER(nutrient_code) = 'VITA';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/499/small/vitamin-c-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Tăng sức đề kháng, chống oxy hóa, hỗ trợ hấp thụ sắt'
WHERE UPPER(nutrient_code) = 'VITC';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/491/small/vitamin-d-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Tăng cường hấp thụ canxi, hỗ trợ sức khỏe xương và răng'
WHERE UPPER(nutrient_code) = 'VITD';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/495/small/vitamin-e-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Chống oxy hóa mạnh, bảo vệ tế bào, hỗ trợ sức khỏe da'
WHERE UPPER(nutrient_code) = 'VITE';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/497/small/vitamin-k-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Hỗ trợ đông máu, tăng cường sức khỏe xương'
WHERE UPPER(nutrient_code) = 'VITK';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/487/small/vitamin-b1-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Hỗ trợ chuyển hóa năng lượng, tăng cường hệ thần kinh'
WHERE UPPER(nutrient_code) = 'VITB1';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/488/small/vitamin-b2-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Hỗ trợ chuyển hóa năng lượng, sức khỏe da và mắt'
WHERE UPPER(nutrient_code) = 'VITB2';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/489/small/vitamin-b3-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Hỗ trợ chuyển hóa năng lượng, sức khỏe tim mạch'
WHERE UPPER(nutrient_code) = 'VITB3';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ chuyển hóa năng lượng, sản xuất hormone'
WHERE UPPER(nutrient_code) = 'VITB5';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/490/small/vitamin-b6-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Hỗ trợ chức năng não, chuyển hóa protein'
WHERE UPPER(nutrient_code) = 'VITB6';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ chuyển hóa năng lượng, sức khỏe tóc và da'
WHERE UPPER(nutrient_code) = 'VITB7';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sản xuất DNA, phát triển thai nhi'
WHERE UPPER(nutrient_code) = 'VITB9';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/016/130/486/small/vitamin-b12-icon-in-flat-style-pill-capsule-illustration-on-white-isolated-background-drug-business-concept-vector.jpg',
  benefits = 'Hỗ trợ hệ thần kinh, sản xuất hồng cầu'
WHERE UPPER(nutrient_code) = 'VITB12';

-- ============================================================
-- MINERALS
-- ============================================================

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/025/065/326/small/calcium-icon-mineral-capsule-gold-vitamin-drop-pill-vector.jpg',
  benefits = 'Tăng cường xương và răng chắc khỏe, hỗ trợ co cơ'
WHERE UPPER(nutrient_code) = 'CA';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ xương và răng, chuyển hóa năng lượng'
WHERE UPPER(nutrient_code) = 'P';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/025/065/330/small/magnesium-icon-mineral-capsule-gold-vitamin-drop-pill-vector.jpg',
  benefits = 'Hỗ trợ co cơ, hệ thần kinh, chuyển hóa năng lượng'
WHERE UPPER(nutrient_code) = 'MG';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/025/065/331/small/potassium-icon-mineral-capsule-gold-vitamin-drop-pill-vector.jpg',
  benefits = 'Điều hòa huyết áp, cân bằng điện giải'
WHERE UPPER(nutrient_code) = 'K';

UPDATE Nutrient SET 
  benefits = 'Cân bằng điện giải, điều hòa huyết áp'
WHERE UPPER(nutrient_code) = 'NA';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/025/065/328/small/iron-icon-mineral-capsule-gold-vitamin-drop-pill-vector.jpg',
  benefits = 'Sản xuất hồng cầu, vận chuyển oxy'
WHERE UPPER(nutrient_code) = 'FE';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/025/065/337/small/zinc-icon-mineral-capsule-gold-vitamin-drop-pill-vector.jpg',
  benefits = 'Tăng cường miễn dịch, lành vết thương'
WHERE UPPER(nutrient_code) = 'ZN';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ chuyển hóa sắt, sức khỏe tim mạch'
WHERE UPPER(nutrient_code) = 'CU';

UPDATE Nutrient SET 
  benefits = 'Chống oxy hóa, chuyển hóa năng lượng'
WHERE UPPER(nutrient_code) = 'MN';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ tuyến giáp, chuyển hóa năng lượng'
WHERE UPPER(nutrient_code) = 'I';

UPDATE Nutrient SET 
  image_url = 'https://static.vecteezy.com/system/resources/thumbnails/025/065/333/small/selenium-icon-mineral-capsule-gold-vitamin-drop-pill-vector.jpg',
  benefits = 'Chống oxy hóa mạnh, hỗ trợ tuyến giáp'
WHERE UPPER(nutrient_code) = 'SE';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ chuyển hóa đường, điều hòa insulin'
WHERE UPPER(nutrient_code) = 'CR';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ chuyển hóa năng lượng và protein'
WHERE UPPER(nutrient_code) = 'MO';

UPDATE Nutrient SET 
  benefits = 'Tăng cường men răng, phòng ngừa sâu răng'
WHERE UPPER(nutrient_code) = 'F';

-- ============================================================
-- DIETARY FIBER
-- ============================================================

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ tiêu hóa, kiểm soát đường huyết, giảm cholesterol'
WHERE UPPER(nutrient_code) = 'FIBTG';

UPDATE Nutrient SET 
  benefits = 'Giảm cholesterol, kiểm soát đường huyết'
WHERE UPPER(nutrient_code) = 'FIB_SOL';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ nhu động ruột, phòng táo bón'
WHERE UPPER(nutrient_code) = 'FIB_INSOL';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ vi sinh đường ruột, kiểm soát đường huyết'
WHERE UPPER(nutrient_code) = 'FIB_RS';

UPDATE Nutrient SET 
  benefits = 'Giảm cholesterol, tăng cường miễn dịch'
WHERE UPPER(nutrient_code) = 'FIB_BGLU';

-- ============================================================
-- FATTY ACIDS
-- ============================================================

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sức khỏe tim mạch, giảm cholesterol xấu'
WHERE UPPER(nutrient_code) = 'FAMS';

UPDATE Nutrient SET 
  benefits = 'Chống viêm, hỗ trợ sức khỏe não bộ'
WHERE UPPER(nutrient_code) = 'FAPU';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sức khỏe tim mạch, chống viêm, phát triển não bộ'
WHERE UPPER(nutrient_code) = 'FAEPA';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ phát triển não bộ và thị lực, chống viêm'
WHERE UPPER(nutrient_code) = 'FADHA';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sức khỏe tim mạch, chống viêm'
WHERE UPPER(nutrient_code) = 'FAEPA_DHA';

UPDATE Nutrient SET 
  benefits = 'Chống viêm, hỗ trợ sức khỏe da'
WHERE UPPER(nutrient_code) = 'FA18_2N6C';

UPDATE Nutrient SET 
  benefits = 'Chống viêm, hỗ trợ sức khỏe tim mạch'
WHERE UPPER(nutrient_code) = 'FA18_3N3';

-- ============================================================
-- AMINO ACIDS
-- ============================================================

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ tăng trưởng cơ, phục hồi mô'
WHERE UPPER(nutrient_code) = 'AMINO_HIS';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ tăng trưởng cơ, trao đổi chất năng lượng'
WHERE UPPER(nutrient_code) = 'AMINO_ILE';

UPDATE Nutrient SET 
  benefits = 'Tăng trưởng và phục hồi cơ, điều hòa đường huyết'
WHERE UPPER(nutrient_code) = 'AMINO_LEU';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ tăng trưởng, sản xuất collagen'
WHERE UPPER(nutrient_code) = 'AMINO_LYS';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sản xuất protein, chống oxy hóa'
WHERE UPPER(nutrient_code) = 'AMINO_MET';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sản xuất neurotransmitter, cải thiện tâm trạng'
WHERE UPPER(nutrient_code) = 'AMINO_PHE';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ sản xuất collagen, miễn dịch'
WHERE UPPER(nutrient_code) = 'AMINO_THR';

UPDATE Nutrient SET 
  benefits = 'Hỗ trợ giấc ngủ, cải thiện tâm trạng'
WHERE UPPER(nutrient_code) = 'AMINO_TRP';

UPDATE Nutrient SET 
  benefits = 'Tăng trưởng và phục hồi cơ, chuyển hóa năng lượng'
WHERE UPPER(nutrient_code) = 'AMINO_VAL';

-- ============================================================
-- CONTRAINDICATIONS (Example data - adjust based on medical guidance)
-- ============================================================

-- Vitamin C contraindications
INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Tráo ngược dạ dày', 'Liều cao có thể gây kích ứng dạ dày'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'VITC'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

-- Iron contraindications
INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Hemochromatosis', 'Không dùng bổ sung sắt'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'FE'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Viêm loét dạ dày', 'Có thể gây kích ứng'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'FE'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

-- Vitamin K contraindications
INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Đang dùng thuốc chống đông máu', 'Tương tác với warfarin'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'VITK'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

-- Potassium contraindications
INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Bệnh thận mạn', 'Hạn chế bổ sung kali'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'K'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

-- Sodium contraindications
INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Tăng huyết áp', 'Hạn chế natri'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'NA'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

INSERT INTO NutrientContraindication(nutrient_id, condition_name, note)
SELECT n.nutrient_id, 'Suy tim', 'Hạn chế natri'
FROM Nutrient n WHERE UPPER(n.nutrient_code) = 'NA'
ON CONFLICT (nutrient_id, condition_name) DO NOTHING;

COMMIT;

