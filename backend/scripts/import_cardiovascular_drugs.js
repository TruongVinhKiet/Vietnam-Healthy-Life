require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE
});

// NHÓM TIM MẠCH: Amlodipine, Losartan, Enalapril, Furosemide, Digoxin, Spironolactone, Warfarin, Rivaroxaban
const cardiovascularDrugs = [
  {
    drug_id: 24, // Furosemide
    name_vi: 'Furosemide',
    name_en: 'Furosemide',
    brand_name_vi: 'Lasix',
    brand_name_en: 'Lasix',
    generic_name: 'Furosemide',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'Thuốc lợi tiểu quai - Diuretic',
    strength: '20mg, 40mg (viên); 10mg/ml (tiêm)',
    packaging: 'Hộp 10 vỉ x 10 viên hoặc ống tiêm 2ml',
    dosage_form: 'Viên nén, dung dịch tiêm',
    
    indications_vi: 'Phù do suy tim, xơ gan, bệnh thận. Tăng huyết áp. Phù phổi cấp.',
    indications_en: 'Edema due to heart failure, cirrhosis, renal disease. Hypertension. Acute pulmonary edema.',
    
    dosage_adult_vi: 'Phù: 20-80mg/ngày buổi sáng, có thể tăng lên 600mg/ngày. Tăng huyết áp: 40mg x 2 lần/ngày. Phù phổi cấp: 40-80mg tiêm tĩnh mạch chậm.',
    dosage_adult_en: 'Edema: 20-80mg/day in morning, up to 600mg/day. Hypertension: 40mg twice daily. Acute pulmonary edema: 40-80mg IV slow push.',
    dosage_pediatric_vi: 'Trẻ em: 1-2mg/kg/lần, 1-2 lần/ngày. Tối đa 6mg/kg/ngày.',
    dosage_special_vi: 'Suy thận nặng: Cần liều cao hơn. Suy gan: Thận trọng, nguy cơ hôn mê gan.',
    
    contraindications_vi: 'Thiểu niệu/vô niệu, suy thận cấp không đáp ứng furosemide, hôn mê gan, mất nước/điện giải nặng, quá mẫn sulfonamide.',
    contraindications_en: 'Anuria, acute renal failure unresponsive to furosemide, hepatic coma, severe dehydration/electrolyte depletion.',
    
    warnings_vi: 'Theo dõi điện giải (K, Na, Mg), thể tích tuần hoàn, chức năng thận. Nguy cơ mất kali, natri, hạ huyết áp. Có thể gây điếc tai tạm thời với liều cao tiêm tĩnh mạch nhanh.',
    warnings_en: 'Monitor electrolytes (K, Na, Mg), volume status, renal function. Risk of hypokalemia, hyponatremia, hypotension. May cause temporary deafness with rapid high-dose IV.',
    
    common_side_effects_vi: 'Hạ kali máu, hạ natri máu, mất nước, hạ huyết áp tư thế, chóng mặt, đau đầu',
    common_side_effects_en: 'Hypokalemia, hyponatremia, dehydration, orthostatic hypotension, dizziness, headache',
    serious_side_effects_vi: 'Mất điện giải nghiêm trọng, suy thận, điếc tai (với liều cao IV), phản ứng dị ứng nghiêm trọng',
    serious_side_effects_en: 'Severe electrolyte depletion, renal failure, ototoxicity (high IV doses), severe allergic reactions',
    
    mechanism_of_action_vi: 'Ức chế tái hấp thu Na-K-2Cl ở quai Henle dày lên, tăng bài tiết nước, natri, kali, clo, magie.',
    mechanism_of_action_en: 'Inhibits Na-K-2Cl cotransporter in thick ascending loop of Henle, increasing excretion of water, sodium, potassium, chloride, magnesium.',
    pharmacokinetics_vi: 'Hấp thu 60-70% (uống). Khởi phát: 30-60 phút (uống), 5 phút (IV). Thời gian tác dụng: 6-8h (uống), 2h (IV). T1/2 = 1.5-2h.',
    pharmacokinetics_en: 'Absorption 60-70% (oral). Onset: 30-60min (oral), 5min (IV). Duration: 6-8h (oral), 2h (IV). T1/2 = 1.5-2h.',
    
    overdose_symptoms_vi: 'Mất nước nặng, hạ huyết áp, suy tuần hoàn, mất điện giải nghiêm trọng, rối loạn nhịp tim.',
    overdose_treatment_vi: 'Bù dịch, điện giải. Theo dõi huyết động, điện giải. Không có thuốc giải độc đặc hiệu.',
    
    pregnancy_category: 'C',
    pregnancy_notes_vi: 'Dùng khi lợi ích > nguy cơ. Có thể giảm thể tích tuần hoàn thai nhi. Ưu tiên thiazide liều thấp.',
    lactation_notes_vi: 'Bài tiết vào sữa mẹ với nồng độ thấp. Có thể ức chế tiết sữa.',
    
    storage_conditions_vi: 'Viên: Bảo quản dưới 30°C, tránh ánh sáng. Tiêm: 2-8°C, tránh ánh sáng.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/furosemide/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK499921/'
  },
  
  {
    drug_id: 25, // Digoxin
    name_vi: 'Digoxin',
    name_en: 'Digoxin',
    brand_name_vi: 'Lanoxin',
    brand_name_en: 'Lanoxin',
    generic_name: 'Digoxin',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'Cardiac Glycoside - Tăng co bóp tim',
    strength: '0.25mg (viên); 0.25mg/ml (tiêm)',
    packaging: 'Hộp 10 vỉ x 10 viên hoặc ống tiêm 2ml',
    dosage_form: 'Viên nén, dung dịch tiêm',
    
    indications_vi: 'Suy tim mạn tính với rung nhĩ. Rung nhĩ mạn tính (kiểm soát nhịp thất). Cuồng nhĩ.',
    indications_en: 'Chronic heart failure with atrial fibrillation. Chronic atrial fibrillation (rate control). Atrial flutter.',
    
    dosage_adult_vi: 'Liều nạp: 0.75-1.5mg chia nhiều lần trong 24h. Liều duy trì: 0.125-0.25mg/ngày. Người cao tuổi: 0.0625-0.125mg/ngày.',
    dosage_adult_en: 'Loading: 0.75-1.5mg divided over 24h. Maintenance: 0.125-0.25mg/day. Elderly: 0.0625-0.125mg/day.',
    dosage_pediatric_vi: 'Trẻ sơ sinh: Liều nạp 20-30 mcg/kg, duy trì 5-10 mcg/kg/ngày. Trẻ > 10 tuổi: Như người lớn.',
    dosage_special_vi: 'Suy thận: Giảm liều. CrCl 10-50: Giảm 25-75%. CrCl <10: Giảm 50-75% hoặc tăng khoảng cách liều.',
    
    contraindications_vi: 'Block nhĩ thất độ 2-3, hội chứng suy nút xoang, rối loạn nhịp thất, ngộ độc digitalis, WPW syndrome kèm rung nhĩ.',
    contraindications_en: 'AV block 2nd-3rd degree, sick sinus syndrome, ventricular arrhythmias, digitalis toxicity, WPW with AF.',
    
    warnings_vi: 'Cửa sổ điều trị hẹp. Theo dõi nồng độ digoxin máu, điện giải (K, Mg, Ca), ECG, chức năng thận. Hạ kali tăng nguy cơ độc tính.',
    warnings_en: 'Narrow therapeutic window. Monitor digoxin levels, electrolytes (K, Mg, Ca), ECG, renal function. Hypokalemia increases toxicity.',
    black_box_warning_vi: 'Nguy cơ ngộ độc digitalis cao, đặc biệt ở người cao tuổi, suy thận, mất điện giải. Theo dõi chặt chẽ.',
    
    common_side_effects_vi: 'Buồn nôn, nôn, tiêu chảy, chán ăn, mệt mỏi, nhìn vàng/xanh (triệu chứng ngộ độc)',
    common_side_effects_en: 'Nausea, vomiting, diarrhea, anorexia, fatigue, yellow/green vision (toxicity)',
    serious_side_effects_vi: 'Rối loạn nhịp tim (block nhĩ thất, ngoại tâm thu thất, nhịp nhanh thất), ngộ độc digitalis, rối loạn tâm thần',
    serious_side_effects_en: 'Arrhythmias (AV block, ventricular ectopy, VT), digitalis toxicity, mental disturbances',
    
    mechanism_of_action_vi: 'Ức chế Na-K ATPase, tăng Ca nội bào, tăng co bóp cơ tim. Tác dụng phó giao cảm: chậm dẫn truyền nhĩ thất.',
    mechanism_of_action_en: 'Inhibits Na-K ATPase, increases intracellular Ca, increases cardiac contractility. Parasympathetic effects: slows AV conduction.',
    pharmacokinetics_vi: 'Sinh khả dụng 70-80% (viên). Khởi phát: 0.5-2h (uống), 5-30 phút (IV). Thời gian tác dụng: 6-8 ngày. T1/2 = 36-48h (bình thường), dài hơn khi suy thận.',
    pharmacokinetics_en: 'Bioavailability 70-80% (tablets). Onset: 0.5-2h (oral), 5-30min (IV). Duration: 6-8 days. T1/2 = 36-48h (normal), longer in renal impairment.',
    
    overdose_symptoms_vi: 'Buồn nôn/nôn nặng, rối loạn nhịp tim (bradycardia, block, arrhythmia), nhìn vàng, lú lẫn, hạ kali máu.',
    overdose_treatment_vi: 'Ngừng digoxin. Atropine cho bradycardia. Kháng thể kháng digoxin (Digibind) cho ngộ độc nặng. Bù kali (nếu hạ kali).',
    
    pregnancy_category: 'C',
    pregnancy_notes_vi: 'Dùng khi cần thiết. Vượt qua nhau thai. Theo dõi nồng độ digoxin.',
    lactation_notes_vi: 'Bài tiết vào sữa mẹ với nồng độ tương tự máu mẹ. Thận trọng.',
    
    storage_conditions_vi: 'Bảo quản dưới 25°C, tránh ánh sáng và ẩm.',
    article_link_vi: 'https://www.vinmec.com/vie/benh/suy-tim/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK556025/'
  },
  
  {
    drug_id: 26, // Spironolactone
    name_vi: 'Spironolactone',
    name_en: 'Spironolactone',
    brand_name_vi: 'Aldactone',
    brand_name_en: 'Aldactone',
    generic_name: 'Spironolactone',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'Thuốc lợi tiểu giữ kali - Aldosterone Antagonist',
    strength: '25mg, 50mg, 100mg',
    packaging: 'Hộp 10 vỉ x 10 viên',
    dosage_form: 'Viên nén',
    
    indications_vi: 'Suy tim mạn tính (NYHA III-IV). Tăng huyết áp. Phù do xơ gan, hội chứng thận hư. Tăng aldosterone nguyên phát.',
    indications_en: 'Chronic heart failure (NYHA III-IV). Hypertension. Edema from cirrhosis, nephrotic syndrome. Primary hyperaldosteronism.',
    
    dosage_adult_vi: 'Suy tim: 12.5-25mg/ngày, tăng dần lên 25-50mg/ngày. Tăng huyết áp: 25-100mg/ngày. Phù: 100-400mg/ngày.',
    dosage_adult_en: 'Heart failure: 12.5-25mg/day, increase to 25-50mg/day. Hypertension: 25-100mg/day. Edema: 100-400mg/day.',
    dosage_pediatric_vi: 'Trẻ em: 1-3.3mg/kg/ngày chia 1-2 lần.',
    dosage_special_vi: 'Suy thận: Tránh nếu CrCl <30. Theo dõi kali chặt chẽ.',
    
    contraindications_vi: 'Tăng kali máu (>5.5 mmol/L), suy thận cấp, bệnh Addison, dùng eplerenone hoặc bổ sung kali.',
    contraindications_en: 'Hyperkalemia (>5.5 mmol/L), acute renal failure, Addison disease, concurrent eplerenone or potassium supplements.',
    
    warnings_vi: 'Nguy cơ tăng kali máu, đặc biệt khi dùng với ACE inhibitor/ARB. Theo dõi kali, creatinine thường xuyên. Có thể gây nữ hóa tuyến vú ở nam.',
    warnings_en: 'Risk of hyperkalemia, especially with ACE inhibitors/ARBs. Monitor potassium, creatinine regularly. May cause gynecomastia in males.',
    black_box_warning_vi: 'Có khả năng gây ung thư ở động vật thí nghiệm với liều cao. Chỉ dùng khi có chỉ định rõ ràng.',
    
    common_side_effects_vi: 'Tăng kali máu nhẹ, chóng mặt, đau đầu, buồn nôn, tiêu chảy, nữ hóa tuyến vú (nam), rối loạn kinh nguyệt (nữ)',
    common_side_effects_en: 'Mild hyperkalemia, dizziness, headache, nausea, diarrhea, gynecomastia (males), menstrual irregularities (females)',
    serious_side_effects_vi: 'Tăng kali máu nặng (rối loạn nhịp tim nguy hiểm), suy thận cấp, phản ứng dị ứng',
    serious_side_effects_en: 'Severe hyperkalemia (life-threatening arrhythmias), acute renal failure, allergic reactions',
    
    mechanism_of_action_vi: 'Đối kháng cạnh tranh với aldosterone tại thụ thể khoáng corticoid ở ống thận xa, giảm bài tiết kali, tăng bài tiết natri và nước.',
    mechanism_of_action_en: 'Competitive aldosterone antagonist at mineralocorticoid receptor in distal tubule, reduces potassium excretion, increases sodium and water excretion.',
    pharmacokinetics_vi: 'Hấp thu >90%. Chuyển hóa gan thành canrenone (hoạt tính). Khởi phát: 2-3 ngày. Thời gian tác dụng: 2-3 ngày sau ngừng thuốc. T1/2 = 1.4h (spironolactone), 13-24h (canrenone).',
    pharmacokinetics_en: 'Absorption >90%. Hepatic metabolism to canrenone (active). Onset: 2-3 days. Duration: 2-3 days after discontinuation. T1/2 = 1.4h (spironolactone), 13-24h (canrenone).',
    
    overdose_symptoms_vi: 'Mất nước, mất điện giải, tăng kali máu, hạ natri máu, buồn ngủ.',
    overdose_treatment_vi: 'Ngừng thuốc. Điều trị triệu chứng. Bù dịch, điện giải. Xử lý tăng kali máu (glucose-insulin, calcium, resin trao đổi ion).',
    
    pregnancy_category: 'C',
    pregnancy_notes_vi: 'Tránh dùng trong thai kỳ trừ khi thực sự cần thiết. Có tác dụng kháng androgen.',
    lactation_notes_vi: 'Chất chuyển hóa canrenone bài tiết vào sữa mẹ. Tránh cho con bú.',
    
    storage_conditions_vi: 'Bảo quản dưới 25°C, tránh ẩm.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/spironolactone/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK554421/'
  },
  
  {
    drug_id: 27, // Warfarin
    name_vi: 'Warfarin',
    name_en: 'Warfarin',
    brand_name_vi: 'Coumadin, Marevan',
    brand_name_en: 'Coumadin',
    generic_name: 'Warfarin Sodium',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'Thuốc chống đông máu - Vitamin K Antagonist',
    strength: '1mg, 2mg, 5mg',
    packaging: 'Hộp 10 vỉ x 10 viên (màu sắc khác nhau theo hàm lượng)',
    dosage_form: 'Viên nén',
    
    indications_vi: 'Phòng ngừa/điều trị huyết khối tĩnh mạch sâu, th栓 tắc phổi. Phòng ngừa tai biến mạch máu não ở bệnh nhân rung nhĩ. Van tim nhân tạo. Sau nhồi máu cơ tim.',
    indications_en: 'Prevention/treatment of deep vein thrombosis, pulmonary embolism. Stroke prevention in atrial fibrillation. Mechanical heart valves. Post-myocardial infarction.',
    
    dosage_adult_vi: 'Liều khởi đầu: 2-5mg/ngày. Điều chỉnh theo INR mục tiêu (thường 2-3). Liều duy trì thường 2-10mg/ngày. Kiểm tra INR thường xuyên.',
    dosage_adult_en: 'Initial: 2-5mg/day. Adjust based on target INR (usually 2-3). Maintenance typically 2-10mg/day. Monitor INR regularly.',
    dosage_pediatric_vi: 'Trẻ em: 0.1-0.2mg/kg/ngày (tối đa 10mg), điều chỉnh theo INR.',
    dosage_special_vi: 'Người cao tuổi, suy gan: Bắt đầu liều thấp (1-2mg). Theo dõi INR chặt chẽ hơn.',
    
    contraindications_vi: 'Chảy máu nội tạng đang diễn ra, phẫu thuật não/mắt/tủy sống gần đây, thai kỳ, tăng huyết áp nặng không kiểm soát, rối loạn đông máu nặng.',
    contraindications_en: 'Active internal bleeding, recent brain/eye/spinal surgery, pregnancy, severe uncontrolled hypertension, severe coagulation disorders.',
    
    warnings_vi: 'Cửa sổ điều trị hẹp. Nguy cơ chảy máu cao. Tương tác thuốc-thuốc, thuốc-thức ăn nhiều. Theo dõi INR thường xuyên (ban đầu mỗi 2-3 ngày, sau đó mỗi 4-8 tuần). Tránh ăn bưởi, rau xanh đậm (vitamin K cao) không đều.',
    warnings_en: 'Narrow therapeutic window. High bleeding risk. Many drug-drug, drug-food interactions. Monitor INR regularly (initially every 2-3 days, then every 4-8 weeks). Avoid inconsistent intake of grapefruit, dark green vegetables (high vitamin K).',
    black_box_warning_vi: 'Có thể gây chảy máu nghiêm trọng hoặc tử vong. Chảy máu có thể xảy ra ở bất kỳ vị trí nào. Nguy cơ cao hơn ở người cao tuổi. Theo dõi INR thường xuyên.',
    
    common_side_effects_vi: 'Chảy máu nhẹ (chảy máu cam, chảy máu nướu răng, bầm tím da), đau bụng, buồn nôn',
    common_side_effects_en: 'Minor bleeding (nosebleeds, gum bleeding, bruising), abdominal pain, nausea',
    serious_side_effects_vi: 'Chảy máu nặng (tiêu hóa, não, tiết niệu), hoại tử da, hội chứng ngón chân tím (purple toe syndrome)',
    serious_side_effects_en: 'Major bleeding (GI, intracranial, urinary), skin necrosis, purple toe syndrome',
    
    mechanism_of_action_vi: 'Ức chế vitamin K epoxide reductase, làm giảm tổng hợp các yếu tố đông máu phụ thuộc vitamin K (II, VII, IX, X) và protein C, S.',
    mechanism_of_action_en: 'Inhibits vitamin K epoxide reductase, reducing synthesis of vitamin K-dependent clotting factors (II, VII, IX, X) and proteins C, S.',
    pharmacokinetics_vi: 'Hấp thu nhanh, hoàn toàn. Liên kết protein 99%. Chuyển hóa gan qua CYP2C9. Khởi phát: 24-72h. Thời gian tác dụng: 2-5 ngày. T1/2 = 20-60h (trung bình 40h).',
    pharmacokinetics_en: 'Rapid, complete absorption. Protein binding 99%. Hepatic metabolism via CYP2C9. Onset: 24-72h. Duration: 2-5 days. T1/2 = 20-60h (mean 40h).',
    
    overdose_symptoms_vi: 'INR tăng cao, chảy máu (chảy máu nội tạng, chảy máu não, chảy máu tiêu hóa).',
    overdose_treatment_vi: 'Ngừng warfarin. Vitamin K (phytomenadione): 2.5-10mg uống hoặc IV chậm. FFP hoặc PCC cho chảy máu nặng. Theo dõi INR.',
    
    pregnancy_category: 'X',
    pregnancy_notes_vi: 'Chống chỉ định tuyệt đối. Gây dị tật thai nhi (warfarin embryopathy), chảy máu thai nhi. Chuyển sang heparin khi có thai.',
    lactation_notes_vi: 'Bài tiết rất ít vào sữa mẹ. Được coi là tương thích với cho con bú (AAP).',
    
    storage_conditions_vi: 'Bảo quản dưới 25°C, tránh ánh sáng, ẩm. Để xa tầm tay trẻ em.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/warfarin/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK470313/'
  },
  
  {
    drug_id: 28, // Rivaroxaban
    name_vi: 'Rivaroxaban',
    name_en: 'Rivaroxaban',
    brand_name_vi: 'Xarelto',
    brand_name_en: 'Xarelto',
    generic_name: 'Rivaroxaban',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'Thuốc chống đông máu - DOAC (Direct Oral Anticoagulant)',
    strength: '10mg, 15mg, 20mg',
    packaging: 'Hộp 1-3 vỉ x 10 viên bao phim',
    dosage_form: 'Viên nén bao phim',
    
    indications_vi: 'Phòng ngừa huyết khối tĩnh mạch sau phẫu thuật thay khớp háng/đầu gối. Phòng ngừa đột quỵ ở bệnh nhân rung nhĩ không do bệnh van tim. Điều trị huyết khối tĩnh mạch sâu, thuyên tắc phổi.',
    indications_en: 'Prevention of VTE after hip/knee replacement surgery. Stroke prevention in non-valvular atrial fibrillation. Treatment of DVT, pulmonary embolism.',
    
    dosage_adult_vi: 'Rung nhĩ: 20mg/ngày với bữa tối. Huyết khối tĩnh mạch sâu: 15mg x 2 lần/ngày x 3 tuần, sau đó 20mg/ngày. Phòng ngừa sau phẫu thuật: 10mg/ngày.',
    dosage_adult_en: 'Atrial fibrillation: 20mg once daily with evening meal. DVT: 15mg twice daily x 3 weeks, then 20mg once daily. Post-surgical prophylaxis: 10mg once daily.',
    dosage_special_vi: 'Suy thận CrCl 15-49: Giảm liều (AF: 15mg/ngày). CrCl <15: Tránh dùng. Suy gan Child-Pugh B-C: Chống chỉ định.',
    
    contraindications_vi: 'Chảy máu đang diễn ra có ý nghĩa lâm sàng, suy gan Child-Pugh B-C, thai kỳ.',
    contraindications_en: 'Active clinically significant bleeding, hepatic disease Child-Pugh B-C, pregnancy.',
    
    warnings_vi: 'Nguy cơ chảy máu. Không cần theo dõi INR nhưng không có thuốc giải độc đặc hiệu (chỉ có andexanet alfa, giá rất đắt). Ngừng thuốc trước phẫu thuật 24-48h. Dùng với bữa ăn để tăng hấp thu.',
    warnings_en: 'Bleeding risk. No INR monitoring needed but no specific antidote (only andexanet alfa, very expensive). Discontinue 24-48h before surgery. Take with food to increase absorption.',
    
    common_side_effects_vi: 'Chảy máu nhẹ (chảy máu cam, bầm tím), buồn nôn, đau bụng, chóng mặt',
    common_side_effects_en: 'Minor bleeding (epistaxis, bruising), nausea, abdominal pain, dizziness',
    serious_side_effects_vi: 'Chảy máu nặng (não, tiêu hóa, tiết niệu), chèn ép tủy sống/ngoài màng cứng (nếu gây tê tủy sống)',
    serious_side_effects_en: 'Major bleeding (intracranial, GI, urinary), spinal/epidural hematoma (with neuraxial anesthesia)',
    
    mechanism_of_action_vi: 'Ức chế trực tiếp yếu tố Xa, ngăn chặn chuyển prothrombin thành thrombin, làm gián đoạn quá trình đông máu.',
    mechanism_of_action_en: 'Direct factor Xa inhibitor, blocks conversion of prothrombin to thrombin, interrupting coagulation cascade.',
    pharmacokinetics_vi: 'Sinh khả dụng 80-100% (với thức ăn). Đạt đỉnh sau 2-4h. Liên kết protein 92-95%. Chuyển hóa gan CYP3A4/5, CYP2J2. T1/2 = 5-9h (trẻ), 11-13h (người cao tuổi).',
    pharmacokinetics_en: 'Bioavailability 80-100% (with food). Peak 2-4h. Protein binding 92-95%. Hepatic metabolism CYP3A4/5, CYP2J2. T1/2 = 5-9h (young), 11-13h (elderly).',
    
    overdose_symptoms_vi: 'Chảy máu (từ nhẹ đến nghiêm trọng).',
    overdose_treatment_vi: 'Ngừng thuốc. Than hoạt tính nếu uống gần đây. Andexanet alfa (thuốc giải độc, rất đắt) cho chảy máu nặng. PCC có thể cân nhắc.',
    
    pregnancy_category: 'C',
    pregnancy_notes_vi: 'Chống chỉ định. Gây chảy máu thai nhi và mẹ. Chuyển sang heparin nếu cần.',
    lactation_notes_vi: 'Không rõ bài tiết vào sữa mẹ. Tránh cho con bú.',
    
    storage_conditions_vi: 'Bảo quản dưới 30°C. Viên 15mg và 20mg: uống với thức ăn.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/rivaroxaban/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK493731/'
  }
];

// Cardiovascular drug interactions
const cardiovascularInteractions = [
  // Furosemide
  { drug_id: 24, interaction_type: 'drug', interacts_with: 'Aminoglycoside (Gentamicin)', severity: 'major', description_vi: 'Tăng nguy cơ độc tai và độc thận', clinical_effects_vi: 'Điếc tai vĩnh viễn, suy thận', management_vi: 'Theo dõi chức năng thận, thính lực. Tránh dùng kết hợp nếu có thể.' },
  { drug_id: 24, interaction_type: 'drug', interacts_with: 'Digoxin', severity: 'moderate', description_vi: 'Hạ kali do furosemide tăng độc tính digoxin', clinical_effects_vi: 'Ngộ độc digitalis, rối loạn nhịp tim', management_vi: 'Theo dõi kali máu, bổ sung kali nếu cần. Theo dõi triệu chứng ngộ độc digoxin.' },
  { drug_id: 24, interaction_type: 'drug', interacts_with: 'Lithium', severity: 'major', description_vi: 'Giảm thải trừ lithium, tăng nồng độ lithium máu', clinical_effects_vi: 'Ngộ độc lithium (run, buồn nôn, lú lẫn)', management_vi: 'Theo dõi nồng độ lithium. Có thể cần giảm liều lithium.' },
  
  // Digoxin
  { drug_id: 25, interaction_type: 'drug', interacts_with: 'Amiodarone', severity: 'major', description_vi: 'Tăng nồng độ digoxin 70-100%', clinical_effects_vi: 'Ngộ độc digitalis', management_vi: 'Giảm liều digoxin 50% khi bắt đầu amiodarone. Theo dõi nồng độ digoxin.' },
  { drug_id: 25, interaction_type: 'drug', interacts_with: 'Verapamil, Diltiazem', severity: 'moderate', description_vi: 'Tăng nồng độ digoxin, chậm nhịp tim cộng gộp', clinical_effects_vi: 'Ngộ độc digoxin, bradycardia nặng, block nhĩ thất', management_vi: 'Giảm liều digoxin. Theo dõi nhịp tim, ECG.' },
  { drug_id: 25, interaction_type: 'drug', interacts_with: 'Thuốc lợi tiểu (Furosemide, Hydrochlorothiazide)', severity: 'moderate', description_vi: 'Hạ kali tăng độc tính digoxin', clinical_effects_vi: 'Tăng nguy cơ rối loạn nhịp tim', management_vi: 'Theo dõi kali, bổ sung kali nếu cần.' },
  
  // Spironolactone
  { drug_id: 26, interaction_type: 'drug', interacts_with: 'ACE inhibitor (Enalapril)', severity: 'major', description_vi: 'Tăng nguy cơ tăng kali máu nghiêm trọng', clinical_effects_vi: 'Tăng kali máu, rối loạn nhịp tim nguy hiểm', management_vi: 'Dùng liều thấp spironolactone (12.5-25mg). Theo dõi kali máu thường xuyên (sau 1 tuần, sau 1 tháng, sau đó mỗi 3 tháng).' },
  { drug_id: 26, interaction_type: 'drug', interacts_with: 'ARB (Losartan)', severity: 'major', description_vi: 'Tăng nguy cơ tăng kali máu', clinical_effects_vi: 'Tăng kali máu, rối loạn nhịp tim', management_vi: 'Giống ACE inhibitor. Theo dõi kali chặt chẽ.' },
  { drug_id: 26, interaction_type: 'drug', interacts_with: 'NSAID (Ibuprofen)', severity: 'moderate', description_vi: 'Giảm tác dụng lợi tiểu, tăng nguy cơ tăng kali và suy thận', clinical_effects_vi: 'Giảm hiệu quả, tăng kali, suy thận', management_vi: 'Tránh dùng NSAID. Nếu cần, dùng liều thấp nhất, thời gian ngắn nhất. Theo dõi chức năng thận, kali.' },
  
  // Warfarin
  { drug_id: 27, interaction_type: 'drug', interacts_with: 'Aspirin, NSAID', severity: 'major', description_vi: 'Tăng nguy cơ chảy máu nghiêm trọng', clinical_effects_vi: 'Chảy máu tiêu hóa, chảy máu não', management_vi: 'Tránh dùng kết hợp. Nếu thực sự cần aspirin, dùng liều thấp (≤100mg) và theo dõi chặt chẽ. Cân nhắc bảo vệ dạ dày (PPI).' },
  { drug_id: 27, interaction_type: 'drug', interacts_with: 'Kháng sinh (Metronidazole, Cotrimoxazole)', severity: 'major', description_vi: 'Tăng tác dụng warfarin, tăng INR', clinical_effects_vi: 'INR tăng cao, nguy cơ chảy máu', management_vi: 'Theo dõi INR chặt chẽ khi bắt đầu/ngừng kháng sinh. Có thể cần giảm liều warfarin tạm thời.' },
  { drug_id: 27, interaction_type: 'food', interacts_with: 'Rau xanh đậm (cải xoăn, rau bina, súp lơ xanh)', severity: 'moderate', description_vi: 'Vitamin K trong rau làm giảm tác dụng warfarin', clinical_effects_vi: 'INR giảm, giảm hiệu quả chống đông', management_vi: 'Ăn rau xanh đều đặn, không thay đổi đột ngột lượng ăn. Không cần kiêng hoàn toàn.' },
  { drug_id: 27, interaction_type: 'food', interacts_with: 'Bưởi, nước ép bưởi', severity: 'moderate', description_vi: 'Ức chế CYP3A4, có thể tăng/giảm tác dụng warfarin không dự đoán', clinical_effects_vi: 'INR không ổn định', management_vi: 'Tránh ăn bưởi, uống nước bưởi.' },
  
  // Rivaroxaban
  { drug_id: 28, interaction_type: 'drug', interacts_with: 'Aspirin, NSAID, Clopidogrel', severity: 'major', description_vi: 'Tăng nguy cơ chảy máu nghiêm trọng', clinical_effects_vi: 'Chảy máu nặng (tiêu hóa, não)', management_vi: 'Tránh dùng kết hợp trừ khi lợi ích > nguy cơ (ví dụ: stent động mạch vành). Theo dõi chặt chẽ.' },
  { drug_id: 28, interaction_type: 'drug', interacts_with: 'Ketoconazole, Itraconazole (kháng nấm)', severity: 'major', description_vi: 'Ức chế CYP3A4 và P-gp mạnh, tăng nồng độ rivaroxaban 160%', clinical_effects_vi: 'Tăng nguy cơ chảy máu nghiêm trọng', management_vi: 'Chống chỉ định dùng kết hợp. Tránh tuyệt đối.' },
  { drug_id: 28, interaction_type: 'drug', interacts_with: 'Rifampicin, Carbamazepine', severity: 'major', description_vi: 'Tăng cường CYP3A4 và P-gp, giảm nồng độ rivaroxaban 50%', clinical_effects_vi: 'Giảm hiệu quả chống đông, tăng nguy cơ huyết khối', management_vi: 'Tránh dùng kết hợp. Nếu cần, cân nhắc thuốc chống đông khác.' }
];

// Cardiovascular side effects
const cardiovascularSideEffects = [
  // Furosemide
  { drug_id: 24, effect_name_vi: 'Hạ kali máu', frequency: 'very_common', severity: 'moderate', description_vi: 'Kali máu <3.5 mmol/L. Triệu chứng: mệt, yếu cơ, táo bón, rối loạn nhịp tim.', is_serious: false },
  { drug_id: 24, effect_name_vi: 'Hạ huyết áp tư thế', frequency: 'common', severity: 'mild', description_vi: 'Chóng mặt khi đứng dậy. Do mất nước, giảm thể tích tuần hoàn.', is_serious: false },
  { drug_id: 24, effect_name_vi: 'Điếc tai', frequency: 'rare', severity: 'severe', description_vi: 'Thường với liều cao IV nhanh. Có thể vĩnh viễn. Ù tai, giảm thính lực.', is_serious: true },
  { drug_id: 24, effect_name_vi: 'Suy thận cấp', frequency: 'uncommon', severity: 'severe', description_vi: 'Do mất nước nặng hoặc giảm tưới máu thận. Creatinine tăng, giảm lượng nước tiểu.', is_serious: true },
  
  // Digoxin
  { drug_id: 25, effect_name_vi: 'Buồn nôn, nôn', frequency: 'common', severity: 'mild', description_vi: 'Triệu chứng sớm của ngộ độc digitalis. Chán ăn, khó chịu bụng.', is_serious: false },
  { drug_id: 25, effect_name_vi: 'Nhìn vàng/xanh', frequency: 'uncommon', severity: 'moderate', description_vi: 'Rối loạn thị giác màu sắc. Dấu hiệu ngộ độc digitalis.', is_serious: false },
  { drug_id: 25, effect_name_vi: 'Bradycardia', frequency: 'common', severity: 'moderate', description_vi: 'Nhịp tim chậm <60 lần/phút. Có thể tiến triển thành block nhĩ thất.', is_serious: false },
  { drug_id: 25, effect_name_vi: 'Rối loạn nhịp thất', frequency: 'uncommon', severity: 'severe', description_vi: 'Ngoại tâm thu thất, nhịp nhanh thất. Nguy hiểm tính mạng. Dấu hiệu ngộ độc nặng.', is_serious: true },
  
  // Spironolactone
  { drug_id: 26, effect_name_vi: 'Tăng kali máu nhẹ', frequency: 'common', severity: 'mild', description_vi: 'Kali 5.0-5.5 mmol/L. Thường không có triệu chứng. Cần theo dõi.', is_serious: false },
  { drug_id: 26, effect_name_vi: 'Nữ hóa tuyến vú (nam)', frequency: 'common', severity: 'mild', description_vi: 'Phì đại tuyến vú, đau tuyến vú ở nam giới. Do tác dụng kháng androgen.', is_serious: false },
  { drug_id: 26, effect_name_vi: 'Rối loạn kinh nguyệt', frequency: 'common', severity: 'mild', description_vi: 'Kinh không đều, rong kinh ở phụ nữ.', is_serious: false },
  { drug_id: 26, effect_name_vi: 'Tăng kali máu nặng', frequency: 'uncommon', severity: 'severe', description_vi: 'Kali >6.0 mmol/L. Yếu cơ, rối loạn nhịp tim nguy hiểm. Cấp cứu ngay.', is_serious: true },
  
  // Warfarin
  { drug_id: 27, effect_name_vi: 'Bầm tím da', frequency: 'very_common', severity: 'mild', description_vi: 'Bầm tím dễ dàng sau va chạm nhẹ. Dấu hiệu thuốc đang có tác dụng.', is_serious: false },
  { drug_id: 27, effect_name_vi: 'Chảy máu nướu răng', frequency: 'common', severity: 'mild', description_vi: 'Chảy máu khi đánh răng. Cần vệ sinh răng miệng nhẹ nhàng.', is_serious: false },
  { drug_id: 27, effect_name_vi: 'Chảy máu não', frequency: 'rare', severity: 'severe', description_vi: 'Đau đầu dữ dội, yếu liệt, lú lẫn, hôn mê. Nguy hiểm tính mạng. Cấp cứu ngay.', is_serious: true },
  { drug_id: 27, effect_name_vi: 'Chảy máu tiêu hóa', frequency: 'uncommon', severity: 'severe', description_vi: 'Phân đen hoặc có máu tươi, nôn máu. Cấp cứu ngay.', is_serious: true },
  
  // Rivaroxaban
  { drug_id: 28, effect_name_vi: 'Bầm tím', frequency: 'common', severity: 'mild', description_vi: 'Bầm tím dưới da sau va chạm nhẹ.', is_serious: false },
  { drug_id: 28, effect_name_vi: 'Chảy máu nướu', frequency: 'common', severity: 'mild', description_vi: 'Chảy máu khi đánh răng, nhai thức ăn cứng.', is_serious: false },
  { drug_id: 28, effect_name_vi: 'Chảy máu não', frequency: 'rare', severity: 'severe', description_vi: 'Đột ngột đau đầu, yếu, rối loạn ý thức. Nguy hiểm tính mạng.', is_serious: true },
  { drug_id: 28, effect_name_vi: 'Chèn ép tủy sống', frequency: 'rare', severity: 'severe', description_vi: 'Sau gây tê tủy sống/ngoài màng cứng. Yếu chân, tiểu/đại tiện không kiểm soát. Phẫu thuật khẩn cấp.', is_serious: true }
];

async function importCardiovascularDrugs() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('═══════════════════════════════════════════════════════');
    console.log('   IMPORT DỮ LIỆU NHÓM TIM MẠCH (5 THUỐC)');
    console.log('═══════════════════════════════════════════════════════\n');
    
    // Update drugs
    for (const drug of cardiovascularDrugs) {
      const updateFields = Object.keys(drug)
        .filter(key => key !== 'drug_id')
        .map((key, index) => `${key} = $${index + 2}`)
        .join(', ');
      
      const values = [
        drug.drug_id,
        ...Object.keys(drug).filter(key => key !== 'drug_id').map(key => drug[key])
      ];
      
      await client.query(
        `UPDATE drug SET ${updateFields} WHERE drug_id = $1`,
        values
      );
      
      console.log(`✓ ${drug.name_vi} (${drug.drug_class})`);
    }
    
    console.log(`\n✅ Đã cập nhật ${cardiovascularDrugs.length} thuốc tim mạch\n`);
    
    // Import interactions
    console.log('─────────────────────────────────────────────────────');
    console.log('IMPORT TƯƠNG TÁC THUỐC TIM MẠCH\n');
    
    await client.query(
      'DELETE FROM drug_interaction WHERE drug_id IN (24, 25, 26, 27, 28)'
    );
    
    for (const interaction of cardiovascularInteractions) {
      await client.query(
        `INSERT INTO drug_interaction 
        (drug_id, interaction_type, interacts_with, severity, description_vi, clinical_effects_vi, management_vi)
        VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          interaction.drug_id,
          interaction.interaction_type,
          interaction.interacts_with,
          interaction.severity,
          interaction.description_vi,
          interaction.clinical_effects_vi,
          interaction.management_vi
        ]
      );
    }
    
    console.log(`✅ ${cardiovascularInteractions.length} tương tác\n`);
    
    // Import side effects
    console.log('─────────────────────────────────────────────────────');
    console.log('IMPORT TÁC DỤNG PHỤ TIM MẠCH\n');
    
    await client.query(
      'DELETE FROM drug_side_effect WHERE drug_id IN (24, 25, 26, 27, 28)'
    );
    
    for (const sideEffect of cardiovascularSideEffects) {
      await client.query(
        `INSERT INTO drug_side_effect 
        (drug_id, effect_name_vi, frequency, severity, description_vi, is_serious)
        VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          sideEffect.drug_id,
          sideEffect.effect_name_vi,
          sideEffect.frequency,
          sideEffect.severity,
          sideEffect.description_vi,
          sideEffect.is_serious
        ]
      );
    }
    
    console.log(`✅ ${cardiovascularSideEffects.length} tác dụng phụ\n`);
    
    await client.query('COMMIT');
    
    // Summary
    console.log('═══════════════════════════════════════════════════════');
    console.log('TÓM TẮT NHÓM TIM MẠCH');
    console.log('═══════════════════════════════════════════════════════');
    const totalDrugsWithData = await client.query(
      'SELECT COUNT(*) FROM drug WHERE brand_name_vi IS NOT NULL'
    );
    const totalInteractions = await client.query('SELECT COUNT(*) FROM drug_interaction');
    const totalSideEffects = await client.query('SELECT COUNT(*) FROM drug_side_effect');
    
    console.log(`✓ Tổng thuốc có dữ liệu đầy đủ: ${totalDrugsWithData.rows[0].count}`);
    console.log(`✓ Tổng tương tác: ${totalInteractions.rows[0].count}`);
    console.log(`✓ Tổng tác dụng phụ: ${totalSideEffects.rows[0].count}`);
    console.log('\n🎉 HOÀN THÀNH NHÓM TIM MẠCH!');
    console.log('═══════════════════════════════════════════════════════\n');
    
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Lỗi:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

importCardiovascularDrugs();
