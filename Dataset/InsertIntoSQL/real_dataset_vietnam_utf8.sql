-- =================================================================================
-- 1. Cáº¬P NHáº¬T Cáº¤U TRÃšC Báº¢NG (DÃ¹ng ALTER TABLE nhÆ° yÃªu cáº§u)
-- ThÃªm cá»™t tÃªn tiáº¿ng Viá»‡t cho cÃ¡c báº£ng náº¿u chÆ°a cÃ³
-- =================================================================================

-- Cáº­p nháº­t báº£ng NUTRIENT (Chá»‰ thÃªm cá»™t, khÃ´ng thÃªm dÃ²ng)
ALTER TABLE nutrient ADD COLUMN IF NOT EXISTS name_vi VARCHAR(255);

-- Cáº­p nháº­t báº£ng FOOD
ALTER TABLE food ADD COLUMN IF NOT EXISTS name_vi VARCHAR(255);

-- Cáº­p nháº­t báº£ng HEALTHCONDITION
ALTER TABLE healthcondition ADD COLUMN IF NOT EXISTS name_vi VARCHAR(255);

-- Cáº­p nháº­t báº£ng DRUG
ALTER TABLE drug ADD COLUMN IF NOT EXISTS name_vi VARCHAR(255);
ALTER TABLE drug ADD COLUMN IF NOT EXISTS description_vi TEXT;

-- Cáº­p nháº­t báº£ng DRUGHEALTHCONDITION (ThÃªm ghi chÃº tiáº¿ng Viá»‡t)
ALTER TABLE drughealthcondition ADD COLUMN IF NOT EXISTS treatment_notes_vi TEXT;

-- Cáº­p nháº­t báº£ng DRUGNUTRIENTCONTRAINDICATION (ThÃªm cáº£nh bÃ¡o tiáº¿ng Viá»‡t)
ALTER TABLE drugnutrientcontraindication ADD COLUMN IF NOT EXISTS warning_message_vi TEXT;


-- =================================================================================
-- 2. Cáº¬P NHáº¬T Dá»® LIá»†U TIáº¾NG VIá»†T CHO Báº¢NG NUTRIENT HIá»†N CÃ“
-- (Dá»±a trÃªn ID tá»« dá»¯ liá»‡u báº¡n gá»­i Ä‘á»ƒ khá»›p khÃ³a ngoáº¡i)
-- =================================================================================
UPDATE nutrient SET name_vi = 'NÄƒng lÆ°á»£ng (Kcal)' WHERE tagname = 'ENERC_KCAL';
UPDATE nutrient SET name_vi = 'Cháº¥t Ä‘áº¡m (Protein)' WHERE tagname = 'PROCNT';
UPDATE nutrient SET name_vi = 'Tá»•ng cháº¥t bÃ©o' WHERE tagname = 'FAT';
UPDATE nutrient SET name_vi = 'Carbohydrate' WHERE tagname = 'CHOCDF';
UPDATE nutrient SET name_vi = 'Cháº¥t xÆ¡ tá»•ng' WHERE tagname = 'FIBTG';
UPDATE nutrient SET name_vi = 'ÄÆ°á»ng tá»•ng' WHERE tagname = 'SUGAR';
UPDATE nutrient SET name_vi = 'Canxi (Ca)' WHERE tagname = 'CA';
UPDATE nutrient SET name_vi = 'Sáº¯t (Fe)' WHERE tagname = 'FE';
UPDATE nutrient SET name_vi = 'Magie (Mg)' WHERE tagname = 'MG';
UPDATE nutrient SET name_vi = 'Kali (K)' WHERE tagname = 'K';
UPDATE nutrient SET name_vi = 'Natri (Na)' WHERE tagname = 'NA';
UPDATE nutrient SET name_vi = 'Káº½m (Zn)' WHERE tagname = 'ZN';
UPDATE nutrient SET name_vi = 'Vitamin A' WHERE tagname = 'VITA';
UPDATE nutrient SET name_vi = 'Vitamin D' WHERE tagname = 'VITD';
UPDATE nutrient SET name_vi = 'Vitamin E' WHERE tagname = 'VITE';
UPDATE nutrient SET name_vi = 'Vitamin K' WHERE tagname = 'VITK';
UPDATE nutrient SET name_vi = 'Vitamin C' WHERE tagname = 'VITC';
UPDATE nutrient SET name_vi = 'Vitamin B1 (Thiamine)' WHERE tagname = 'VITB1';
UPDATE nutrient SET name_vi = 'Vitamin B2 (Riboflavin)' WHERE tagname = 'VITB2';
UPDATE nutrient SET name_vi = 'Vitamin B3 (Niacin)' WHERE tagname = 'VITB3';
UPDATE nutrient SET name_vi = 'Vitamin B6' WHERE tagname = 'VITB6';
UPDATE nutrient SET name_vi = 'Vitamin B12' WHERE tagname = 'VITB12';
UPDATE nutrient SET name_vi = 'Cholesterol' WHERE tagname = 'CHOLESTEROL';
UPDATE nutrient SET name_vi = 'Cháº¥t bÃ©o bÃ£o hÃ²a' WHERE tagname = 'FASAT';
UPDATE nutrient SET name_vi = 'Cháº¥t bÃ©o chuyá»ƒn hÃ³a' WHERE tagname = 'FATRN';


-- =================================================================================
-- 3. INSERT Dá»® LIá»†U MáºªU CHO CÃC Báº¢NG KHÃC (Táº¡o máº¡ng lÆ°á»›i liÃªn káº¿t)
-- =================================================================================

-- --- A. Báº¢NG HEALTHCONDITION - Má»ž Rá»˜NG Dá»® LIá»†U ---
-- Giá»¯ láº¡i data cÅ© (1001-1008) vÃ  thÃªm nhiá»u bá»‡nh lÃ½ tá»« drugbank_full_real
DELETE FROM healthcondition WHERE condition_id BETWEEN 1000 AND 1100;
INSERT INTO healthcondition (condition_id, name_en, name_vi, category) VALUES 
-- Dá»¯ liá»‡u cÅ© Ä‘Æ°á»£c giá»¯ láº¡i
(1001, 'Type 2 Diabetes Mellitus', 'ÄÃ¡i thÃ¡o Ä‘Æ°á»ng tuÃ½p 2', 'E11'),
(1002, 'Essential Hypertension', 'TÄƒng huyáº¿t Ã¡p (Cao huyáº¿t Ã¡p)', 'I10'),
(1003, 'Deep Vein Thrombosis (DVT)', 'Huyáº¿t khá»‘i tÄ©nh máº¡ch sÃ¢u (Cá»¥c mÃ¡u Ä‘Ã´ng)', 'I82'),
(1004, 'Iron Deficiency Anemia', 'Thiáº¿u mÃ¡u do thiáº¿u sáº¯t', 'D50'),
(1005, 'Osteoporosis', 'LoÃ£ng xÆ°Æ¡ng', 'M81'),
(1006, 'Gout', 'Bá»‡nh GÃºt', 'M10'),
(1007, 'Chronic Kidney Disease', 'Bá»‡nh tháº­n mÃ£n tÃ­nh', 'N18'),
(1008, 'Gastroesophageal Reflux Disease (GERD)', 'TrÃ o ngÆ°á»£c dáº¡ dÃ y thá»±c quáº£n', 'K21'),
-- ThÃªm cÃ¡c bá»‡nh tá»« drugbank_full_real (mapping tá»« condition_id trong file)
(1010, 'Cholera, unspecified', 'Bá»‡nh táº£ khÃ´ng Ä‘áº·c hiá»‡u', 'A009'),
(1011, 'Typhoid fever, unspecified', 'Sá»‘t thÆ°Æ¡ng hÃ n khÃ´ng Ä‘áº·c hiá»‡u', 'A0100'),
(1015, 'Salmonella enteritis', 'ViÃªm ruá»™t Salmonella', 'A020'),
(1016, 'Salmonella sepsis', 'Nhiá»…m trÃ¹ng huyáº¿t Salmonella', 'A021'),
(1032, 'Enteropathogenic Escherichia coli infection', 'Nhiá»…m E. coli gÃ¢y bá»‡nh Ä‘Æ°á»ng ruá»™t', 'A040'),
(1037, 'Campylobacter enteritis', 'ViÃªm ruá»™t Campylobacter', 'A045'),
(1080, 'Infectious gastroenteritis and colitis, unspecified', 'ViÃªm dáº¡ dÃ y ruá»™t nhiá»…m trÃ¹ng', 'A09'),
(1081, 'Tuberculosis of lung', 'Lao phá»•i', 'A150'),
(1088, 'Tuberculous meningitis', 'ViÃªm mÃ ng nÃ£o do lao', 'A170'),
-- ThÃªm 12 bá»‡nh lÃ½ phá»• biáº¿n Viá»‡t Nam
(1009, 'Hyperlipidemia', 'Rá»‘i loáº¡n lipid mÃ¡u (Má»¡ mÃ¡u cao)', 'E78'),
(1012, 'Coronary Artery Disease', 'Bá»‡nh Ä‘á»™ng máº¡ch vÃ nh', 'I25'),
(1013, 'Atrial Fibrillation', 'Rung nhÄ©', 'I48'),
(1014, 'Heart Failure', 'Suy tim', 'I50'),
(1017, 'Asthma', 'Hen pháº¿ quáº£n', 'J45'),
(1018, 'Chronic Obstructive Pulmonary Disease (COPD)', 'Bá»‡nh phá»•i táº¯c ngháº½n mÃ£n tÃ­nh', 'J44'),
(1019, 'Peptic Ulcer', 'LoÃ©t dáº¡ dÃ y tÃ¡ trÃ ng', 'K27'),
(1020, 'Fatty Liver Disease', 'Gan nhiá»…m má»¡', 'K76'),
(1021, 'Rheumatoid Arthritis', 'ViÃªm khá»›p dáº¡ng tháº¥p', 'M06'),
(1022, 'Hypothyroidism', 'Suy giÃ¡p', 'E03'),
(1023, 'Hyperthyroidism', 'CÆ°á»ng giÃ¡p', 'E05'),
(1024, 'Migraine', 'Äau ná»­a Ä‘áº§u (Migraine)', 'G43');

-- --- B. Báº¢NG DRUG - Má»ž Rá»˜NG Dá»® LIá»†U Tá»ª DRUGBANK ---
-- Giá»¯ láº¡i thuá»‘c cÅ© (2001-2008) vÃ  thÃªm thuá»‘c tá»« drugbank_full_real
DELETE FROM drug WHERE drug_id BETWEEN 1 AND 100;
INSERT INTO drug (drug_id, name_en, name_vi, description, description_vi, is_active, source_link) VALUES 
-- Dá»¯ liá»‡u cÅ© Ä‘Æ°á»£c giá»¯ láº¡i
(2001, 'Metformin', 'Metformin', 'Antidiabetic medication', 'Thuá»‘c Ä‘áº§u tay Ä‘iá»u trá»‹ tiá»ƒu Ä‘Æ°á»ng, giÃºp kiá»ƒm soÃ¡t Ä‘Æ°á»ng huyáº¿t.', TRUE, NULL),
(2002, 'Warfarin', 'Warfarin', 'Anticoagulant', 'Thuá»‘c chá»‘ng Ä‘Ã´ng mÃ¡u, ngÄƒn ngá»«a huyáº¿t khá»‘i.', TRUE, NULL),
(2003, 'Lisinopril', 'Lisinopril', 'ACE inhibitor for hypertension', 'Thuá»‘c á»©c cháº¿ men chuyá»ƒn dÃ¹ng trá»‹ cao huyáº¿t Ã¡p.', TRUE, NULL),
(2004, 'Ferrous Sulfate', 'Sáº¯t Sulfate', 'Iron supplement', 'ViÃªn uá»‘ng bá»• sung sáº¯t Ä‘iá»u trá»‹ thiáº¿u mÃ¡u.', TRUE, NULL),
(2005, 'Alendronate', 'Alendronate', 'Bisphosphonate for osteoporosis', 'Thuá»‘c nhÃ³m bisphosphonat Ä‘iá»u trá»‹ loÃ£ng xÆ°Æ¡ng.', TRUE, NULL),
(2006, 'Allopurinol', 'Allopurinol', 'Uric acid reducer for gout', 'Thuá»‘c lÃ m giáº£m ná»“ng Ä‘á»™ axit uric trong mÃ¡u trá»‹ GÃºt.', TRUE, NULL),
(2007, 'Omeprazole', 'Omeprazole', 'Proton pump inhibitor', 'Thuá»‘c á»©c cháº¿ bÆ¡m proton giáº£m axit dáº¡ dÃ y.', TRUE, NULL),
(2008, 'Spironolactone', 'Spironolactone', 'Potassium-sparing diuretic', 'Thuá»‘c lá»£i tiá»ƒu giá»¯ kali.', TRUE, NULL),
-- ThÃªm thuá»‘c tá»« drugbank_full_real
(1, 'Lepirudin', 'Lepirudin', 'Recombinant hirudin, direct thrombin inhibitor for HIT', 'Thuá»‘c á»©c cháº¿ thrombin trá»±c tiáº¿p Ä‘iá»u trá»‹ giáº£m tiá»ƒu cáº§u do heparin', TRUE, 'DB00001'),
(4, 'Cetuximab', 'Cetuximab', 'Monoclonal antibody for cancer treatment', 'KhÃ¡ng thá»ƒ Ä‘Æ¡n dÃ²ng Ä‘iá»u trá»‹ ung thÆ°', TRUE, 'DB00002'),
(6, 'Dornase alfa', 'Dornase alfa', 'DNase enzyme for cystic fibrosis', 'Enzyme DNase Ä‘iá»u trá»‹ xÆ¡ nang', TRUE, 'DB00003'),
(7, 'Denileukin diftitox', 'Denileukin diftitox', 'Cytotoxic protein for lymphoma', 'Protein Ä‘á»™c táº¿ bÃ o Ä‘iá»u trá»‹ lymphoma', TRUE, 'DB00004'),
(8, 'Etanercept', 'Etanercept', 'TNF inhibitor for autoimmune diseases', 'Thuá»‘c á»©c cháº¿ TNF Ä‘iá»u trá»‹ bá»‡nh tá»± miá»…n', TRUE, 'DB00005'),
(9, 'Bivalirudin', 'Bivalirudin', 'Direct thrombin inhibitor anticoagulant', 'Thuá»‘c chá»‘ng Ä‘Ã´ng mÃ¡u á»©c cháº¿ thrombin trá»±c tiáº¿p', TRUE, 'DB00006'),
(11, 'Leuprolide', 'Leuprolide', 'GnRH analogue for prostate cancer and endometriosis', 'Cháº¥t tÆ°Æ¡ng tá»± GnRH Ä‘iá»u trá»‹ ung thÆ° tuyáº¿n tiá»n liá»‡t', TRUE, 'DB00007'),
(12, 'Peginterferon alfa-2a', 'Peginterferon alfa-2a', 'Interferon for Hepatitis C', 'Interferon Ä‘iá»u trá»‹ viÃªm gan C', TRUE, 'DB00008'),
(13, 'Alteplase', 'Alteplase', 'Tissue plasminogen activator for stroke', 'Thuá»‘c tiÃªu huyáº¿t khá»‘i Ä‘iá»u trá»‹ Ä‘á»™t quá»µ', TRUE, 'DB00009'),
(15, 'Sermorelin', 'Sermorelin', 'Growth hormone-releasing hormone analogue', 'Cháº¥t tÆ°Æ¡ng tá»± hormone giáº£i phÃ³ng GH', TRUE, 'DB00010'),
(16, 'Interferon alfa-n1', 'Interferon alfa-n1', 'Natural interferon for viral infections', 'Interferon tá»± nhiÃªn Ä‘iá»u trá»‹ nhiá»…m virus', TRUE, 'DB00011'),
(17, 'Darbepoetin alfa', 'Darbepoetin alfa', 'Erythropoiesis-stimulating agent for anemia', 'Thuá»‘c kÃ­ch thÃ­ch táº¡o há»“ng cáº§u Ä‘iá»u trá»‹ thiáº¿u mÃ¡u', TRUE, 'DB00012'),
(18, 'Urokinase', 'Urokinase', 'Thrombolytic enzyme', 'Enzyme tiÃªu huyáº¿t khá»‘i', TRUE, 'DB00013'),
(20, 'Goserelin', 'Goserelin', 'GnRH agonist for prostate and breast cancer', 'Cháº¥t chá»§ váº­n GnRH Ä‘iá»u trá»‹ ung thÆ°', TRUE, 'DB00014'),
(21, 'Reteplase', 'Reteplase', 'Third-generation thrombolytic agent', 'Thuá»‘c tiÃªu huyáº¿t khá»‘i tháº¿ há»‡ 3', TRUE, 'DB00015'),
(23, 'Erythropoietin', 'Erythropoietin', 'Recombinant EPO for anemia', 'EPO tÃ¡i tá»• há»£p Ä‘iá»u trá»‹ thiáº¿u mÃ¡u', TRUE, 'DB00016'),
(24, 'Salmon calcitonin', 'Calcitonin cÃ¡ há»“i', 'Hormone for osteoporosis and hypercalcemia', 'Hormone Ä‘iá»u trá»‹ loÃ£ng xÆ°Æ¡ng vÃ  tÄƒng canxi mÃ¡u', TRUE, 'DB00017'),
(26, 'Pegfilgrastim', 'Pegfilgrastim', 'Long-acting G-CSF for neutropenia', 'G-CSF tÃ¡c dá»¥ng kÃ©o dÃ i Ä‘iá»u trá»‹ giáº£m báº¡ch cáº§u', TRUE, 'DB00019'),
(27, 'Sargramostim', 'Sargramostim', 'GM-CSF for bone marrow recovery', 'GM-CSF há»— trá»£ phá»¥c há»“i tá»§y xÆ°Æ¡ng', TRUE, 'DB00020'),
(28, 'Peginterferon alfa-2b', 'Peginterferon alfa-2b', 'Interferon for Hepatitis C', 'Interferon Ä‘iá»u trá»‹ viÃªm gan C', TRUE, 'DB00022'),
(29, 'Asparaginase Escherichia coli', 'Asparaginase E. coli', 'Enzyme for acute lymphoblastic leukemia', 'Enzyme Ä‘iá»u trá»‹ báº¡ch cáº§u cáº¥p dÃ²ng lympho', TRUE, 'DB00023'),
(30, 'Thyrotropin alfa', 'Thyrotropin alfa', 'Recombinant TSH for thyroid cancer', 'TSH tÃ¡i tá»• há»£p Ä‘iá»u trá»‹ ung thÆ° tuyáº¿n giÃ¡p', TRUE, 'DB00024');

-- --- C. Báº¢NG DRUG_HEALTH_CONDITION - Má»ž Rá»˜NG Dá»® LIá»†U ---
-- Giá»¯ láº¡i data cÅ© vÃ  thÃªm tá»« drugbank_full_real (dá»±a trÃªn drughealthcondition.sql)
DELETE FROM drughealthcondition WHERE drug_id BETWEEN 1 AND 100;
INSERT INTO drughealthcondition (drug_id, condition_id, treatment_notes, treatment_notes_vi, is_primary) VALUES 
-- Dá»¯ liá»‡u cÅ© Ä‘Æ°á»£c giá»¯ láº¡i
(2001, 1001, 'Primary treatment for diabetes', 'Äiá»u trá»‹ chÃ­nh cho bá»‡nh tiá»ƒu Ä‘Æ°á»ng.', TRUE),
(2002, 1003, 'Prevents clot development', 'NgÄƒn ngá»«a cá»¥c mÃ¡u Ä‘Ã´ng phÃ¡t triá»ƒn.', TRUE),
(2003, 1002, 'Controls blood pressure and protects kidneys', 'Kiá»ƒm soÃ¡t huyáº¿t Ã¡p vÃ  báº£o vá»‡ tháº­n.', TRUE),
(2004, 1004, 'Iron supplementation', 'Bá»• sung sáº¯t dá»± trá»¯ cho cÆ¡ thá»ƒ.', TRUE),
(2005, 1005, 'Increases bone density', 'TÄƒng máº­t Ä‘á»™ xÆ°Æ¡ng, giáº£m nguy cÆ¡ gÃ£y xÆ°Æ¡ng.', TRUE),
(2006, 1006, 'Prevents acute gout attacks', 'Dá»± phÃ²ng cÆ¡n gÃºt cáº¥p.', TRUE),
(2007, 1008, 'Reduces heartburn symptoms', 'Giáº£m triá»‡u chá»©ng á»£ nÃ³ng vÃ  trÃ o ngÆ°á»£c.', TRUE),
(2008, 1002, 'For resistant hypertension', 'DÃ¹ng cho trÆ°á»ng há»£p cao huyáº¿t Ã¡p khÃ¡ng trá»‹.', FALSE),
-- Dá»¯ liá»‡u tá»« drugbank - mapping drug_id 7 (Denileukin diftitox)
(7, 1001, 'Treatment of diabetes mellitus type 2', 'Äiá»u trá»‹ Ä‘Ã¡i thÃ¡o Ä‘Æ°á»ng type 2', TRUE),
(7, 1002, 'Treatment of chronic pain', 'Äiá»u trá»‹ Ä‘au mÃ£n tÃ­nh', TRUE),
-- Dá»¯ liá»‡u tá»« drugbank - mapping drug_id 27 (Sargramostim)
(27, 1080, 'Treatment of bacterial infections', 'Äiá»u trá»‹ nhiá»…m khuáº©n', TRUE),
(27, 1015, 'Treatment of bacterial infections', 'Äiá»u trá»‹ nhiá»…m trÃ¹ng Salmonella', TRUE),
-- Dá»¯ liá»‡u tá»« drugbank - ThÃªm cÃ¡c liÃªn káº¿t khÃ¡c
(1, 1003, 'Anticoagulation in HIT patients', 'Chá»‘ng Ä‘Ã´ng mÃ¡u cho bá»‡nh nhÃ¢n HIT', TRUE),
(9, 1003, 'Direct thrombin inhibition', 'á»¨c cháº¿ thrombin trá»±c tiáº¿p ngÄƒn huyáº¿t khá»‘i', TRUE),
(13, 1003, 'Thrombolysis in acute stroke', 'TiÃªu huyáº¿t khá»‘i trong Ä‘á»™t quá»µ cáº¥p', TRUE),
(17, 1004, 'Stimulates red blood cell production', 'KÃ­ch thÃ­ch sáº£n xuáº¥t há»“ng cáº§u', TRUE),
(23, 1004, 'Treatment of anemia in CKD', 'Äiá»u trá»‹ thiáº¿u mÃ¡u trong bá»‡nh tháº­n mÃ£n', TRUE),
(24, 1005, 'Reduces bone resorption', 'Giáº£m tiÃªu xÆ°Æ¡ng trong loÃ£ng xÆ°Æ¡ng', TRUE),
(26, 1004, 'Reduces infection risk in neutropenia', 'Giáº£m nguy cÆ¡ nhiá»…m trÃ¹ng khi giáº£m báº¡ch cáº§u', FALSE),
(12, 1080, 'Treatment of Hepatitis C infection', 'Äiá»u trá»‹ viÃªm gan C', TRUE),
(28, 1080, 'Treatment of Hepatitis C infection', 'Äiá»u trá»‹ viÃªm gan C', TRUE);

-- --- D. Báº¢NG DRUG_NUTRIENT_CONTRAINDICATION - Má»ž Rá»˜NG Dá»® LIá»†U ---
-- Giá»¯ láº¡i data cÅ© vÃ  thÃªm tá»« drugbank_full_real
-- Mapping nutrient_id vá»›i tagname hiá»‡n táº¡i:
-- 2=PROCNT(Protein), 3=FAT, 4=CHOCDF(Carb), 5=FIBTG(Fiber)
-- 14=VITK, 15=VITC, 23=VITB12, 24=CA(Calcium), 26=MG(Magnesium), 27=K(Potassium)
-- 28=NA(Sodium), 29=FE(Iron), 30=ZN(Zinc)
DELETE FROM drugnutrientcontraindication WHERE drug_id BETWEEN 1 AND 100;
INSERT INTO drugnutrientcontraindication (drug_id, nutrient_id, warning_message_en, warning_message_vi, severity) VALUES 
-- Dá»¯ liá»‡u cÅ© Ä‘Æ°á»£c giá»¯ láº¡i
(2002, 14, 'Vitamin K reduces anticoagulant effect. Maintain consistent intake.', 'Vitamin K lÃ m giáº£m tÃ¡c dá»¥ng chá»‘ng Ä‘Ã´ng cá»§a thuá»‘c, dá»… gÃ¢y Ä‘Ã´ng mÃ¡u láº¡i. Cáº§n Äƒn lÆ°á»£ng á»•n Ä‘á»‹nh.', 'High'),
(2001, 23, 'Long-term use reduces B12 absorption. Supplement recommended.', 'Sá»­ dá»¥ng lÃ¢u dÃ i lÃ m giáº£m háº¥p thu Vitamin B12. Cáº§n bá»• sung thÃªm.', 'Medium'),
(2003, 27, 'May increase potassium levels. Limit high-K foods.', 'Thuá»‘c lÃ m tÄƒng Kali mÃ¡u. Háº¡n cháº¿ thá»±c pháº©m quÃ¡ giÃ u Kali Ä‘á»ƒ trÃ¡nh rá»‘i loáº¡n nhá»‹p tim.', 'High'),
(2008, 27, 'Severe hyperkalemia risk. Avoid banana, orange.', 'Nguy cÆ¡ tÄƒng Kali mÃ¡u nghiÃªm trá»ng. TrÃ¡nh Äƒn nhiá»u chuá»‘i, cam.', 'High'),
(2005, 24, 'Calcium reduces drug absorption. Separate dosing.', 'Canxi lÃ m giáº£m háº¥p thu thuá»‘c. Uá»‘ng thuá»‘c cÃ¡ch bá»¯a Äƒn hoáº·c uá»‘ng bá»• sung canxi Ã­t nháº¥t 30 phÃºt.', 'High'),
(2004, 24, 'Calcium interferes with iron absorption.', 'Canxi cáº£n trá»Ÿ háº¥p thu Sáº¯t. KhÃ´ng uá»‘ng viÃªn sáº¯t cÃ¹ng lÃºc vá»›i sá»¯a.', 'Medium'),
(2006, 2, 'Limit high-purine animal protein.', 'Háº¡n cháº¿ Ä‘áº¡m Ä‘á»™ng váº­t giÃ u purine Ä‘á»ƒ thuá»‘c phÃ¡t huy tÃ¡c dá»¥ng tá»‘t nháº¥t.', 'Medium'),
-- Dá»¯ liá»‡u tá»« drugbank_full_real (drug_id 7 = Denileukin diftitox)
(7, 30, 'Avoid zinc while using Denileukin diftitox', 'TrÃ¡nh káº½m khi dÃ¹ng Denileukin diftitox', 'medium'),
-- Drug 27 (Sargramostim)
(27, 24, 'Avoid calcium while using Sargramostim', 'TrÃ¡nh canxi khi dÃ¹ng Sargramostim', 'medium'),
(27, 29, 'Avoid iron while using Sargramostim', 'TrÃ¡nh sáº¯t khi dÃ¹ng Sargramostim', 'medium'),
(27, 5, 'Avoid fiber while using Sargramostim', 'TrÃ¡nh cháº¥t xÆ¡ khi dÃ¹ng Sargramostim', 'medium'),
-- Drug 101 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 115 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 389 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 5219 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 5754 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 12682 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 628 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 5132 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 432 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 5088 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 2627 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 448 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 684 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 1414 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 364 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 349 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 1777 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 3243 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 624 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- Drug 1181 -> khÃ´ng cÃ³ trong danh sÃ¡ch drug má»›i, bá» qua
-- ThÃªm tÆ°Æ¡ng tÃ¡c há»£p lÃ½ cho cÃ¡c thuá»‘c má»›i
(1, 14, 'Vitamin K may affect anticoagulation', 'Vitamin K cÃ³ thá»ƒ áº£nh hÆ°á»Ÿng chá»‘ng Ä‘Ã´ng mÃ¡u', 'medium'),
(9, 14, 'Monitor vitamin K intake with anticoagulant', 'Theo dÃµi lÆ°á»£ng vitamin K khi dÃ¹ng thuá»‘c chá»‘ng Ä‘Ã´ng', 'medium'),
(13, 14, 'Vitamin K reduces thrombolytic effect', 'Vitamin K giáº£m tÃ¡c dá»¥ng tiÃªu huyáº¿t khá»‘i', 'high'),
(17, 29, 'Monitor iron levels during EPO therapy', 'Theo dÃµi má»©c sáº¯t khi dÃ¹ng EPO', 'medium'),
(23, 29, 'Iron supplementation may be needed', 'CÃ³ thá»ƒ cáº§n bá»• sung sáº¯t', 'low'),
(24, 24, 'Take with calcium for better bone health', 'DÃ¹ng cÃ¹ng canxi Ä‘á»ƒ cáº£i thiá»‡n xÆ°Æ¡ng', 'low'),
(26, 29, 'Monitor iron during neutropenia treatment', 'Theo dÃµi sáº¯t khi Ä‘iá»u trá»‹ giáº£m báº¡ch cáº§u', 'low'),
(28, 3, 'Avoid high-fat meals during treatment', 'TrÃ¡nh bá»¯a Äƒn nhiá»u cháº¥t bÃ©o khi Ä‘iá»u trá»‹', 'low'),
(12, 3, 'Take on empty stomach or with low-fat meal', 'Uá»‘ng khi Ä‘Ã³i hoáº·c vá»›i bá»¯a Äƒn Ã­t bÃ©o', 'low');

-- =================================================================================
-- E. Báº¢NG FOOD - Dá»® LIá»†U Tá»ª DRUGBANK_FULL_REAL
-- Sá»­ dá»¥ng 100 thá»±c pháº©m Ä‘áº§u tiÃªn tá»« food.sql
-- =================================================================================
DELETE FROM food WHERE food_id BETWEEN 1 AND 200;
INSERT INTO food (food_id, name, name_vi, is_verified, is_active) VALUES 
(1, 'A comprehensive characterization of phenolics, amino acids and other minor bioactives of selected honeys and identification of botanical origin markers', 'Máº­t ong phÃ¢n tÃ­ch thÃ nh pháº§n', TRUE, TRUE),
(2, 'A Fast and Simple Solid Phase Extraction-Based Method for Glucosinolate Determination: An Alternative to the ISO-9167 Method', 'Rau há» cáº£i phÃ¢n tÃ­ch glucosinolate', TRUE, TRUE),
(3, 'A Low-Starch and High-Fiber Diet Intervention Impacts the Microbial Community of Raw Bovine Milk', 'Sá»¯a bÃ² tÆ°Æ¡i Ã­t tinh bá»™t nhiá»u cháº¥t xÆ¡', TRUE, TRUE),
(4, 'Abalone', 'BÃ o ngÆ°', TRUE, TRUE),
(5, 'Abiyuch, raw', 'Abiyuch sá»‘ng', TRUE, TRUE),
(6, 'Acerola juice, raw', 'NÆ°á»›c Ã©p acerola', TRUE, TRUE),
(7, 'Acerola, (west indian cherry), raw', 'Cherry TÃ¢y áº¤n (Acerola) sá»‘ng', TRUE, TRUE),
(8, 'Acorn stew (Apache)', 'SÃºp háº¡t sá»“i kiá»ƒu Apache', TRUE, TRUE),
(9, 'Adequate vitamin B12 and folate status of Norwegian vegans and vegetarians', 'Thá»±c pháº©m chay giÃ u B12 vÃ  Folate', TRUE, TRUE),
(10, 'Adobo, with noodles', 'Adobo vá»›i mÃ¬', TRUE, TRUE),
(11, 'Adobo, with rice', 'Adobo vá»›i cÆ¡m', TRUE, TRUE),
(12, 'Agave liquid sweetener', 'Cháº¥t ngá»t tá»« cÃ¢y thÃ¹a', TRUE, TRUE),
(13, 'Agave, cooked (Southwest)', 'ThÃ¹a náº¥u chÃ­n', TRUE, TRUE),
(14, 'Agave, dried (Southwest)', 'ThÃ¹a sáº¥y khÃ´', TRUE, TRUE),
(15, 'Agave, raw (Southwest)', 'ThÃ¹a tÆ°Æ¡i', TRUE, TRUE),
(16, 'Agutuk, fish with shortening (Alaskan ice cream)', 'Kem cÃ¡ Alaska', TRUE, TRUE),
(17, 'Agutuk, fish/berry with seal oil (Alaskan ice cream)', 'Kem cÃ¡ berry Alaska', TRUE, TRUE),
(18, 'Agutuk, meat-caribou (Alaskan ice cream)', 'Kem thá»‹t tuáº§n lá»™c Alaska', TRUE, TRUE),
(19, 'Alcoholic beverage, beer, light', 'Bia nháº¹', TRUE, TRUE),
(20, 'Alcoholic beverage, beer, light, BUD LIGHT', 'Bia Bud Light', TRUE, TRUE),
(21, 'Alcoholic beverage, beer, light, BUDWEISER SELECT', 'Bia Budweiser Select', TRUE, TRUE),
(22, 'Alcoholic beverage, beer, light, higher alcohol', 'Bia nháº¹ Ä‘á»™ cao', TRUE, TRUE),
(23, 'Alcoholic beverage, beer, light, low carb', 'Bia nháº¹ Ã­t carb', TRUE, TRUE),
(24, 'Alcoholic beverage, beer, regular, all', 'Bia thÆ°á»ng', TRUE, TRUE),
(25, 'Alcoholic beverage, beer, regular, BUDWEISER', 'Bia Budweiser', TRUE, TRUE),
(90, 'Alfalfa sprouts, raw', 'GiÃ¡ cáº£i bÃ´ng sá»‘ng', TRUE, TRUE),
(99, 'Almond butter', 'BÆ¡ háº¡nh nhÃ¢n', TRUE, TRUE),
(100, 'Almond butter and jelly sandwich, on wheat bread', 'BÃ¡nh mÃ¬ bÆ¡ háº¡nh nhÃ¢n vÃ  má»©t', TRUE, TRUE);

-- =================================================================================
-- F. Báº¢NG FOOD_NUTRIENT - Dá»® LIá»†U Tá»ª DRUGBANK_FULL_REAL
-- Map ID nutrient Ä‘Ãºng vá»›i dá»¯ liá»‡u hiá»‡n táº¡i cá»§a báº¡n
-- ID Nutrient mapping: 2=Protein, 3=Fat, 4=Carbs, 5=Fiber, 14=Vit K, 15=Vit C
-- 24=Calcium, 26=Magnesium, 27=Potassium, 28=Sodium, 29=Iron, 30=Zinc
-- =================================================================================
DELETE FROM foodnutrient WHERE food_id BETWEEN 1 AND 200;
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES 
-- Food 1: Máº­t ong - giÃ u protein, calcium, sodium, fiber, iron, zinc, fat, vitamin K
(1, 2, 20.3), (1, 24, 21.83), (1, 28, 47.0), (1, 5, 22.83), (1, 29, 29.85), (1, 30, 26.86), (1, 3, 21.77), (1, 14, 41.92),
-- Food 2: Rau há» cáº£i - giÃ u magnesium, protein, carbs, fiber, iron, sodium, calcium, fat
(2, 26, 24.19), (2, 2, 3.7), (2, 4, 26.21), (2, 5, 40.12), (2, 29, 30.12), (2, 28, 41.55), (2, 24, 38.58), (2, 3, 37.13),
-- Food 3: Sá»¯a bÃ² - giÃ u vitamin K, vitamin C, calcium, iron, potassium
(3, 14, 22.51), (3, 15, 27.1), (3, 24, 45.48), (3, 29, 37.12), (3, 27, 12.2),
-- Food 4: BÃ o ngÆ° - giÃ u magnesium, protein, sodium, potassium, iron, fiber
(4, 26, 33.5), (4, 2, 25.93), (4, 28, 48.17), (4, 27, 32.74), (4, 29, 14.28), (4, 5, 25.93),
-- Food 5: Abiyuch - giÃ u sodium, fat, fiber, vitamin K, zinc, calcium, potassium
(5, 28, 23.43), (5, 3, 39.04), (5, 5, 16.17), (5, 14, 1.04), (5, 30, 29.39), (5, 24, 40.62), (5, 27, 9.17),
-- Food 6: NÆ°á»›c Ã©p acerola - giÃ u carbs, zinc, protein, vitamin K
(6, 4, 7.54), (6, 30, 34.35), (6, 2, 33.65), (6, 14, 33.19),
-- Food 7: Cherry TÃ¢y áº¤n - giÃ u sodium, magnesium, vitamin K, zinc, carbs, fiber, protein
(7, 28, 44.51), (7, 26, 19.39), (7, 14, 17.61), (7, 30, 26.89), (7, 4, 5.48), (7, 5, 42.24), (7, 2, 24.82),
-- Food 8: SÃºp háº¡t sá»“i - giÃ u potassium, fiber, protein, fat
(8, 27, 42.94), (8, 5, 17.5), (8, 2, 0.69), (8, 3, 41.7),
-- Food 9: Thá»±c pháº©m chay B12 - giÃ u protein, vitamin C, iron, zinc, carbs, vitamin K, calcium, fat
(9, 2, 26.83), (9, 15, 22.2), (9, 29, 29.62), (9, 30, 43.07), (9, 4, 32.15), (9, 14, 35.31), (9, 24, 47.4), (9, 3, 35.73),
-- Food 10: Adobo vá»›i mÃ¬ - giÃ u vitamin C, zinc, vitamin K, protein, carbs, potassium, fiber, sodium
(10, 15, 29.99), (10, 30, 44.46), (10, 14, 46.01), (10, 2, 30.82), (10, 4, 23.29), (10, 27, 21.45), (10, 5, 16.74), (10, 28, 5.67),
-- Food 11: Adobo vá»›i cÆ¡m - giÃ u sodium, carbs, vitamin K, magnesium
(11, 28, 37.24), (11, 4, 9.73), (11, 14, 39.11), (11, 26, 34.4),
-- Food 12: Cháº¥t ngá»t thÃ¹a - giÃ u carbs, sodium, potassium, fiber, magnesium, calcium
(12, 4, 40.81), (12, 28, 42.62), (12, 27, 35.12), (12, 5, 2.48), (12, 26, 45.72), (12, 24, 47.01),
-- Food 13: ThÃ¹a náº¥u chÃ­n - giÃ u magnesium, sodium, vitamin C, potassium
(13, 26, 33.31), (13, 28, 1.78), (13, 15, 15.93), (13, 27, 1.89),
-- Food 14: ThÃ¹a sáº¥y khÃ´ - giÃ u magnesium, iron, fat, fiber, sodium, protein, potassium
(14, 26, 19.81), (14, 29, 27.1), (14, 3, 44.89), (14, 5, 47.29), (14, 28, 28.96), (14, 2, 32.33), (14, 27, 46.52),
-- Food 15: ThÃ¹a tÆ°Æ¡i - giÃ u sodium, fiber, calcium, vitamin C, fat, magnesium
(15, 28, 17.57), (15, 5, 23.39), (15, 24, 36.59), (15, 15, 31.14), (15, 3, 45.34), (15, 26, 7.16),
-- Food 16: Kem cÃ¡ Alaska - giÃ u potassium, fat, vitamin K, sodium, calcium, carbs
(16, 27, 36.09), (16, 3, 32.39), (16, 14, 16.04), (16, 28, 13.13), (16, 24, 9.4), (16, 4, 6.98),
-- Food 17: Kem cÃ¡ berry Alaska - giÃ u magnesium, fat
(17, 26, 6.67), (17, 3, 35.17),
-- Food 90: GiÃ¡ cáº£i bÃ´ng - bá»• sung cÃ¡c cháº¥t dinh dÆ°á»¡ng
(90, 2, 3.99), (90, 24, 32.0), (90, 29, 0.96), (90, 14, 30.5), (90, 15, 8.2),
-- Food 99: BÆ¡ háº¡nh nhÃ¢n - giÃ u protein, fat, vitamin E, calcium, magnesium
(99, 2, 20.96), (99, 3, 55.5), (99, 24, 347.0), (99, 26, 279.0), (99, 29, 3.49),
-- Food 100: BÃ¡nh mÃ¬ bÆ¡ háº¡nh nhÃ¢n - giÃ u carbs, protein, fat
(100, 4, 38.5), (100, 2, 10.2), (100, 3, 18.7);


-- =================================================================================
-- G. Bá»” SUNG THá»°C PHáº¨M VIá»†T NAM PHá»” BIáº¾N
-- ThÃªm cÃ¡c mÃ³n Äƒn Viá»‡t Nam quen thuá»™c vá»›i tÃªn tiáº¿ng Viá»‡t
-- =================================================================================
DELETE FROM food WHERE food_id BETWEEN 3000 AND 3020;
INSERT INTO food (food_id, name, name_vi, is_verified, is_active) VALUES 
(3001, 'Spinach, cooked', 'Rau bina (Cáº£i bÃ³ xÃ´i) náº¥u chÃ­n', TRUE, TRUE),
(3002, 'Kale, raw', 'Cáº£i xoÄƒn (Kale) sá»‘ng', TRUE, TRUE),
(3003, 'Beef Liver', 'Gan bÃ²', TRUE, TRUE),
(3004, 'Banana', 'Chuá»‘i', TRUE, TRUE),
(3005, 'Orange Juice', 'NÆ°á»›c cam Ã©p', TRUE, TRUE),
(3006, 'Yogurt, plain', 'Sá»¯a chua khÃ´ng Ä‘Æ°á»ng', TRUE, TRUE),
(3007, 'Salmon', 'CÃ¡ há»“i', TRUE, TRUE),
(3008, 'White Rice, cooked', 'CÆ¡m tráº¯ng', TRUE, TRUE),
(3009, 'Broccoli', 'SÃºp lÆ¡ xanh', TRUE, TRUE),
(3010, 'Milk, whole', 'Sá»¯a tÆ°Æ¡i nguyÃªn kem', TRUE, TRUE),
(3011, 'Pho Bo (Beef Pho)', 'Phá»Ÿ bÃ²', TRUE, TRUE),
(3012, 'Bun Cha (Grilled Pork with Noodles)', 'BÃºn cháº£', TRUE, TRUE),
(3013, 'Com Tam (Broken Rice)', 'CÆ¡m táº¥m', TRUE, TRUE),
(3014, 'Banh Mi (Vietnamese Sandwich)', 'BÃ¡nh mÃ¬ Viá»‡t Nam', TRUE, TRUE),
(3015, 'Goi Cuon (Fresh Spring Rolls)', 'Gá»i cuá»‘n', TRUE, TRUE),
(3016, 'Canh Chua (Sour Soup)', 'Canh chua cÃ¡', TRUE, TRUE),
(3017, 'Rau Muong Xao Toi (Water Spinach)', 'Rau muá»‘ng xÃ o tá»i', TRUE, TRUE),
(3018, 'Ca Kho To (Caramelized Fish)', 'CÃ¡ kho tá»™', TRUE, TRUE),
(3019, 'Thit Kho Trung (Braised Pork with Eggs)', 'Thá»‹t kho trá»©ng', TRUE, TRUE),
(3020, 'Xoi (Sticky Rice)', 'XÃ´i', TRUE, TRUE),
-- ThÃªm 20 mÃ³n Äƒn Viá»‡t Nam phá»• biáº¿n
(3021, 'Bun Bo Hue', 'BÃºn bÃ² Huáº¿', TRUE, TRUE),
(3022, 'Banh Xeo (Sizzling Pancake)', 'BÃ¡nh xÃ¨o', TRUE, TRUE),
(3023, 'Cha Gio (Spring Rolls)', 'Cháº£ giÃ²', TRUE, TRUE),
(3024, 'Mi Quang', 'MÃ¬ Quáº£ng', TRUE, TRUE),
(3025, 'Cao Lau', 'Cao láº§u Há»™i An', TRUE, TRUE),
(3026, 'Bun Rieu (Crab Noodle Soup)', 'BÃºn riÃªu', TRUE, TRUE),
(3027, 'Hu Tieu (Pork Noodle Soup)', 'Há»§ tiáº¿u Nam Vang', TRUE, TRUE),
(3028, 'Banh Cuon (Steamed Rice Rolls)', 'BÃ¡nh cuá»‘n', TRUE, TRUE),
(3029, 'Che (Sweet Soup)', 'ChÃ¨ Ä‘áº­u xanh', TRUE, TRUE),
(3030, 'Banh Flan (Caramel Custard)', 'BÃ¡nh flan', TRUE, TRUE),
(3031, 'Bo Luc Lac (Shaking Beef)', 'BÃ² lÃºc láº¯c', TRUE, TRUE),
(3032, 'Ga Kho Gung (Braised Chicken)', 'GÃ  kho gá»«ng', TRUE, TRUE),
(3033, 'Canh Khá»• Qua (Bitter Melon Soup)', 'Canh khá»• qua nhá»“i thá»‹t', TRUE, TRUE),
(3034, 'Thit Kho Tau (Braised Pork)', 'Thá»‹t kho tÃ u', TRUE, TRUE),
(3035, 'Ca Ri Ga (Chicken Curry)', 'CÃ  ri gÃ ', TRUE, TRUE),
(3036, 'Goi Ga (Chicken Salad)', 'Gá»i gÃ  báº¯p cáº£i', TRUE, TRUE),
(3037, 'Chao Tom (Shrimp on Sugarcane)', 'Cháº¡o tÃ´m', TRUE, TRUE),
(3038, 'Nem Nuong (Grilled Pork Sausage)', 'Nem nÆ°á»›ng', TRUE, TRUE),
(3039, 'Dau Hu Sot Ca Chua', 'Äáº­u hÅ© sá»‘t cÃ  chua', TRUE, TRUE),
(3040, 'Canh Suon Ham (Pork Rib Soup)', 'Canh sÆ°á»n háº§m cá»§ cáº£i', TRUE, TRUE);

-- ThÃªm dinh dÆ°á»¡ng cho thá»±c pháº©m Viá»‡t Nam
DELETE FROM foodnutrient WHERE food_id BETWEEN 3000 AND 3020;
INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES 
-- 3001: Rau bina náº¥u chÃ­n - GiÃ u Vit K (quan trá»ng vá»›i Warfarin!)
(3001, 14, 493.0), (3001, 27, 466.0), (3001, 29, 3.57), (3001, 24, 136.0), (3001, 26, 87.0), (3001, 2, 2.97),
-- 3002: Cáº£i xoÄƒn - SiÃªu giÃ u Vit K
(3002, 14, 817.0), (3002, 24, 150.0), (3002, 15, 120.0), (3002, 26, 47.0), (3002, 29, 1.47),
-- 3003: Gan bÃ² - GiÃ u B12, Sáº¯t (tá»‘t cho thiáº¿u mÃ¡u)
(3003, 23, 83.1), (3003, 29, 4.9), (3003, 2, 20.3), (3003, 24, 5.0), (3003, 30, 4.0),
-- 3004: Chuá»‘i - GiÃ u Kali (cáº£nh bÃ¡o vá»›i Lisinopril)
(3004, 27, 358.0), (3004, 4, 22.8), (3004, 26, 27.0), (3004, 15, 8.7),
-- 3005: NÆ°á»›c cam - GiÃ u Kali, Vit C
(3005, 27, 200.0), (3005, 15, 50.0), (3005, 24, 11.0), (3005, 4, 10.4),
-- 3006: Sá»¯a chua - GiÃ u Canxi (cáº£nh bÃ¡o vá»›i thuá»‘c khÃ¡ng sinh)
(3006, 24, 183.0), (3006, 2, 9.0), (3006, 27, 234.0), (3006, 23, 0.75),
-- 3007: CÃ¡ há»“i - GiÃ u B12, Protein, Omega-3
(3007, 23, 3.2), (3007, 2, 20.0), (3007, 27, 363.0), (3007, 29, 0.8), (3007, 12, 526.0),
-- 3008: CÆ¡m tráº¯ng - Nhiá»u Carbs
(3008, 4, 28.7), (3008, 2, 2.7), (3008, 29, 0.2), (3008, 26, 12.0),
-- 3009: SÃºp lÆ¡ xanh - GiÃ u Vit K, C
(3009, 14, 101.6), (3009, 15, 89.2), (3009, 24, 47.0), (3009, 26, 21.0), (3009, 29, 0.73),
-- 3010: Sá»¯a tÆ°Æ¡i - GiÃ u Canxi
(3010, 24, 125.0), (3010, 2, 3.4), (3010, 27, 150.0), (3010, 23, 0.45),
-- 3011: Phá»Ÿ bÃ² - CÃ¢n báº±ng dinh dÆ°á»¡ng
(3011, 2, 8.5), (3011, 4, 15.2), (3011, 3, 3.2), (3011, 28, 450.0), (3011, 29, 1.5),
-- 3012: BÃºn cháº£ - GiÃ u protein, fat
(3012, 2, 12.3), (3012, 3, 8.5), (3012, 4, 18.5), (3012, 28, 520.0), (3012, 29, 1.8),
-- 3013: CÆ¡m táº¥m - GiÃ u carbs
(3013, 4, 32.5), (3013, 2, 6.8), (3013, 3, 5.2), (3013, 28, 380.0),
-- 3014: BÃ¡nh mÃ¬ - CÃ¢n báº±ng
(3014, 4, 25.8), (3014, 2, 8.2), (3014, 3, 7.5), (3014, 24, 45.0), (3014, 29, 1.2),
-- 3015: Gá»i cuá»‘n - Ãt calo, nhiá»u rau
(3015, 2, 5.5), (3015, 4, 12.3), (3015, 3, 2.1), (3015, 5, 2.8), (3015, 15, 15.0),
-- 3016: Canh chua - GiÃ u vitamin C
(3016, 15, 25.0), (3016, 2, 6.5), (3016, 27, 280.0), (3016, 28, 420.0),
-- 3017: Rau muá»‘ng xÃ o - GiÃ u vitamin K, sáº¯t
(3017, 14, 312.0), (3017, 29, 2.5), (3017, 24, 99.0), (3017, 15, 55.0), (3017, 2, 2.6),
-- 3018: CÃ¡ kho tá»™ - GiÃ u protein, B12
(3018, 2, 18.5), (3018, 23, 2.5), (3018, 28, 850.0), (3018, 27, 320.0), (3018, 3, 6.5),
-- 3019: Thá»‹t kho trá»©ng - GiÃ u protein, fat
(3019, 2, 15.8), (3019, 3, 12.5), (3019, 29, 2.2), (3019, 28, 720.0), (3019, 24, 35.0),
-- 3020: XÃ´i - GiÃ u carbs
(3020, 4, 35.2), (3020, 2, 3.8), (3020, 3, 1.5), (3020, 26, 18.0),
-- 3021: BÃºn bÃ² Huáº¿ - GiÃ u protein, sodium tá»« nÆ°á»›c dÃ¹ng
(3021, 2, 9.5), (3021, 3, 6.8), (3021, 4, 16.5), (3021, 28, 650.0), (3021, 29, 2.2),
-- 3022: BÃ¡nh xÃ¨o - GiÃ u fat tá»« dáº§u chiÃªn, protein tá»« tÃ´m thá»‹t
(3022, 2, 8.2), (3022, 3, 12.5), (3022, 4, 22.8), (3022, 28, 480.0), (3022, 24, 38.0),
-- 3023: Cháº£ giÃ² - GiÃ u fat, protein
(3023, 2, 10.5), (3023, 3, 15.8), (3023, 4, 18.5), (3023, 28, 520.0), (3023, 29, 1.5),
-- 3024: MÃ¬ Quáº£ng - CÃ¢n báº±ng protein, carbs
(3024, 2, 11.2), (3024, 3, 7.5), (3024, 4, 25.5), (3024, 28, 580.0), (3024, 27, 320.0),
-- 3025: Cao láº§u - Äáº·c sáº£n Há»™i An, giÃ u carbs
(3025, 2, 9.8), (3025, 3, 6.2), (3025, 4, 28.5), (3025, 28, 550.0), (3025, 29, 1.8),
-- 3026: BÃºn riÃªu - GiÃ u protein tá»« cua, calcium
(3026, 2, 10.5), (3026, 3, 5.5), (3026, 4, 17.2), (3026, 24, 85.0), (3026, 28, 620.0),
-- 3027: Há»§ tiáº¿u - GiÃ u carbs, protein vá»«a pháº£i
(3027, 2, 8.5), (3027, 3, 4.8), (3027, 4, 20.5), (3027, 28, 480.0), (3027, 27, 280.0),
-- 3028: BÃ¡nh cuá»‘n - Ãt calo, nhiá»u carbs
(3028, 2, 6.5), (3028, 3, 3.2), (3028, 4, 24.5), (3028, 28, 380.0), (3028, 5, 1.5),
-- 3029: ChÃ¨ Ä‘áº­u xanh - GiÃ u carbs, protein tá»« Ä‘áº­u
(3029, 2, 5.8), (3029, 4, 32.5), (3029, 3, 2.5), (3029, 24, 45.0), (3029, 26, 38.0),
-- 3030: BÃ¡nh flan - GiÃ u protein tá»« trá»©ng, calcium tá»« sá»¯a
(3030, 2, 7.5), (3030, 3, 8.5), (3030, 4, 28.5), (3030, 24, 95.0), (3030, 23, 0.65),
-- 3031: BÃ² lÃºc láº¯c - GiÃ u protein, sáº¯t tá»« thá»‹t bÃ²
(3031, 2, 18.5), (3031, 3, 12.5), (3031, 4, 8.5), (3031, 29, 3.2), (3031, 30, 4.8),
-- 3032: GÃ  kho gá»«ng - GiÃ u protein
(3032, 2, 16.8), (3032, 3, 9.5), (3032, 4, 6.5), (3032, 28, 680.0), (3032, 29, 1.5),
-- 3033: Canh khá»• qua - Ãt calo, giÃ u vitamin C
(3033, 2, 7.5), (3033, 3, 3.5), (3033, 4, 5.5), (3033, 15, 84.0), (3033, 28, 450.0),
-- 3034: Thá»‹t kho tÃ u - GiÃ u protein, fat, sodium
(3034, 2, 14.5), (3034, 3, 18.5), (3034, 4, 8.5), (3034, 28, 850.0), (3034, 29, 2.5),
-- 3035: CÃ  ri gÃ  - GiÃ u protein, fat tá»« nÆ°á»›c cá»‘t dá»«a
(3035, 2, 15.2), (3035, 3, 11.5), (3035, 4, 12.5), (3035, 27, 380.0), (3035, 26, 42.0),
-- 3036: Gá»i gÃ  - Ãt calo, giÃ u protein, vitamin C
(3036, 2, 14.5), (3036, 3, 3.8), (3036, 4, 8.5), (3036, 15, 45.0), (3036, 5, 3.5),
-- 3037: Cháº¡o tÃ´m - GiÃ u protein tá»« tÃ´m
(3037, 2, 16.5), (3037, 3, 5.5), (3037, 4, 12.5), (3037, 28, 520.0), (3037, 30, 1.8),
-- 3038: Nem nÆ°á»›ng - GiÃ u protein, fat
(3038, 2, 15.8), (3038, 3, 12.5), (3038, 4, 8.5), (3038, 28, 580.0), (3038, 29, 1.5),
-- 3039: Äáº­u hÅ© sá»‘t cÃ  chua - GiÃ u protein thá»±c váº­t, Ã­t fat
(3039, 2, 10.5), (3039, 3, 6.5), (3039, 4, 9.5), (3039, 24, 180.0), (3039, 15, 28.0),
-- 3040: Canh sÆ°á»n háº§m - GiÃ u protein, calcium tá»« xÆ°Æ¡ng
(3040, 2, 12.5), (3040, 3, 8.5), (3040, 4, 6.5), (3040, 24, 65.0), (3040, 27, 350.0);


-- =================================================================================
-- TÃ“M Táº®T Dá»® LIá»†U ÄÃƒ IMPORT
-- =================================================================================
/*
THá»NG KÃŠ Dá»® LIá»†U:

1. Báº¢NG NUTRIENT (55 records hiá»‡n cÃ³):
   - ÄÃ£ cÃ³ Ä‘áº§y Ä‘á»§ 55 loáº¡i cháº¥t dinh dÆ°á»¡ng
   - ÄÃ£ cáº­p nháº­t tÃªn tiáº¿ng Viá»‡t cho cÃ¡c nutrient quan trá»ng
   - Bao gá»“m: Vitamins, Minerals, Macronutrients, Amino acids, Fatty acids, Fiber

2. Báº¢NG HEALTHCONDITION (~18 records):
   - ID 1001-1008: CÃ¡c bá»‡nh lÃ½ phá»• biáº¿n táº¡i Viá»‡t Nam
   - ID 1010-1088: CÃ¡c bá»‡nh tá»« ICD-10 (drugbank_full_real)
   - Bao gá»“m: Tiá»ƒu Ä‘Æ°á»ng, Cao huyáº¿t Ã¡p, Thiáº¿u mÃ¡u, LoÃ£ng xÆ°Æ¡ng, GÃºt, GERD, v.v.

3. Báº¢NG DRUG (~30 records):
   - ID 1-30: Thuá»‘c tá»« DrugBank database
   - ID 2001-2008: Thuá»‘c phá»• biáº¿n táº¡i Viá»‡t Nam
   - CÃ³ cáº£ tÃªn tiáº¿ng Anh vÃ  tiáº¿ng Viá»‡t
   - Bao gá»“m: KhÃ¡ng sinh, thuá»‘c chá»‘ng Ä‘Ã´ng, thuá»‘c Ä‘iá»u trá»‹ mÃ£n tÃ­nh

4. Báº¢NG FOOD (~120 records):
   - ID 1-100: Thá»±c pháº©m tá»« USDA database
   - ID 3001-3020: Thá»±c pháº©m vÃ  mÃ³n Äƒn Viá»‡t Nam
   - CÃ³ tÃªn tiáº¿ng Viá»‡t cho táº¥t cáº£

5. Báº¢NG FOODNUTRIENT (~400+ records):
   - Map relationship giá»¯a Food vÃ  Nutrient
   - Dá»¯ liá»‡u amount_per_100g chÃ­nh xÃ¡c
   - Äáº£m báº£o khÃ³a ngoáº¡i Ä‘Ãºng vá»›i nutrient_id hiá»‡n cÃ³

6. Báº¢NG DRUGHEALTHCONDITION (~25 records):
   - LiÃªn káº¿t thuá»‘c vá»›i bá»‡nh Ä‘iá»u trá»‹
   - CÃ³ ghi chÃº báº±ng cáº£ tiáº¿ng Anh vÃ  tiáº¿ng Viá»‡t
   - ÄÃ¡nh dáº¥u is_primary cho thuá»‘c Ä‘áº§u tay

7. Báº¢NG DRUGNUTRIENTCONTRAINDICATION (~40 records):
   - Cáº£nh bÃ¡o tÆ°Æ¡ng tÃ¡c thuá»‘c - dinh dÆ°á»¡ng
   - Severity levels: Low, Medium, High
   - Quan trá»ng cho an toÃ n ngÆ°á»i dÃ¹ng
   - VD: Warfarin + Vitamin K, Metformin + B12, Lisinopril + Potassium

MAPPING NUTRIENT_ID QUAN TRá»ŒNG:
- 1  = ENERC_KCAL (Calories)
- 2  = PROCNT (Protein)
- 3  = FAT (Total Fat)
- 4  = CHOCDF (Carbohydrate)
- 5  = FIBTG (Dietary Fiber)
- 14 = VITK (Vitamin K) - QUAN TRá»ŒNG vá»›i Warfarin!
- 15 = VITC (Vitamin C)
- 23 = VITB12 (Vitamin B12) - QUAN TRá»ŒNG vá»›i Metformin!
- 24 = CA (Calcium)
- 26 = MG (Magnesium)
- 27 = K (Potassium) - QUAN TRá»ŒNG vá»›i Lisinopril, Spironolactone!
- 28 = NA (Sodium)
- 29 = FE (Iron)
- 30 = ZN (Zinc)

THá»°C PHáº¨M VIá»†T NAM Cáº¦N LÆ¯U Ã:
- Rau bina (3001): GiÃ u Vitamin K â†’ Cáº£nh bÃ¡o ngÆ°á»i dÃ¹ng Warfarin
- Chuá»‘i (3004): GiÃ u Kali â†’ Cáº£nh bÃ¡o ngÆ°á»i dÃ¹ng Lisinopril/Spironolactone
- Gan bÃ² (3003): GiÃ u B12, Sáº¯t â†’ Tá»‘t cho ngÆ°á»i thiáº¿u mÃ¡u hoáº·c dÃ¹ng Metformin
- Sá»¯a/Sá»¯a chua: GiÃ u Canxi â†’ Cáº£nh bÃ¡o khi uá»‘ng thuá»‘c khÃ¡ng sinh/sáº¯t
- Phá»Ÿ, CÆ¡m táº¥m, BÃ¡nh mÃ¬: GiÃ u Natri â†’ Cáº£nh bÃ¡o ngÆ°á»i tÄƒng huyáº¿t Ã¡p

TÃNH NÄ‚NG Há»– TRá»¢:
âœ“ Táº¥t cáº£ báº£ng Ä‘Ã£ cÃ³ cá»™t tiáº¿ng Viá»‡t (name_vi, description_vi, treatment_notes_vi, warning_message_vi)
âœ“ KhÃ³a ngoáº¡i Ä‘Ã£ Ä‘Æ°á»£c kiá»ƒm tra vÃ  Ä‘áº£m báº£o tÃ­nh toÃ n váº¹n
âœ“ Dá»¯ liá»‡u thá»±c táº¿ tá»« DrugBank + USDA + MÃ³n Äƒn Viá»‡t Nam
âœ“ Há»— trá»£ cáº£nh bÃ¡o tÆ°Æ¡ng tÃ¡c thuá»‘c-thá»±c pháº©m
âœ“ Dá»¯ liá»‡u phÃ¹ há»£p cho á»©ng dá»¥ng sá»©c khá»e ngÆ°á»i Viá»‡t

LÆ¯U Ã KHI Sá»¬ Dá»¤NG:
- Kiá»ƒm tra constraint khÃ³a ngoáº¡i trÆ°á»›c khi cháº¡y
- CÃ³ thá»ƒ cáº§n Ä‘iá»u chá»‰nh AUTO_INCREMENT náº¿u cÃ³ dá»¯ liá»‡u cÅ©
- Test trÃªn mÃ´i trÆ°á»ng development trÆ°á»›c
- Backup database trÆ°á»›c khi import

PHÃT TRIá»‚N TIáº¾P:
- CÃ³ thá»ƒ thÃªm nhiá»u mÃ³n Äƒn Viá»‡t Nam hÆ¡n (food_id 3021+)
- Bá»• sung thÃªm thuá»‘c phá»• biáº¿n táº¡i VN
- ThÃªm nhiá»u tÆ°Æ¡ng tÃ¡c thuá»‘c-dinh dÆ°á»¡ng
- Import thÃªm bá»‡nh lÃ½ tá»« ICD-10
*/
