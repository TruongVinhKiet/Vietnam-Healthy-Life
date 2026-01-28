require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE
});

// Comprehensive drug data based on real medical information
const comprehensiveDrugData = [
  {
    drug_id: 2,
    name_vi: 'Metformin',
    name_en: 'Metformin',
    brand_name_vi: 'Glucophage, Gluformin',
    brand_name_en: 'Glucophage',
    generic_name: 'Metformin Hydrochloride',
    active_ingredient: 'Metformin HCl',
    drug_class: 'Thuốc đái tháo đường',
    therapeutic_class: 'Biguanide - Hạ đường huyết',
    strength: '500mg, 850mg, 1000mg',
    packaging: 'Hộp 3 vỉ x 10 viên nén bao phim',
    dosage_form: 'Viên nén bao phim',
    
    indications_vi: 'Điều trị đái tháo đường type 2, đặc biệt ở bệnh nhân thừa cân/béo phì khi chế độ ăn và tập luyện không đủ hiệu quả. Phòng ngừa biến chứng tim mạch ở bệnh nhân đái tháo đường.',
    indications_en: 'Treatment of type 2 diabetes mellitus, especially in overweight patients when diet and exercise alone are insufficient.',
    
    dosage_adult_vi: 'Liều khởi đầu: 500mg, 1-2 lần/ngày sau ăn. Tăng dần 500mg mỗi tuần. Liều tối đa: 2000-2550mg/ngày, chia 2-3 lần.',
    dosage_adult_en: 'Initial: 500mg once or twice daily with meals. Increase by 500mg weekly. Maximum: 2000-2550mg/day in 2-3 divided doses.',
    dosage_pediatric_vi: 'Trẻ ≥10 tuổi: Bắt đầu 500mg/ngày, tối đa 2000mg/ngày chia 2 lần.',
    dosage_pediatric_en: 'Children ≥10 years: Start 500mg/day, max 2000mg/day in 2 divided doses.',
    dosage_special_vi: 'Suy thận eGFR 30-60: Giảm liều 50%. eGFR <30: Chống chỉ định. Suy gan: Tránh dùng.',
    dosage_special_en: 'Renal impairment eGFR 30-60: Reduce 50%. eGFR <30: Contraindicated. Hepatic impairment: Avoid.',
    
    contraindications_vi: 'Suy thận nặng (eGFR <30), nhiễm toan chuyển hóa, suy tim nặng, sốc, suy gan, nghiện rượu, quá mẫn với metformin.',
    contraindications_en: 'Severe renal impairment (eGFR <30), metabolic acidosis, severe heart failure, shock, hepatic impairment, alcoholism.',
    
    warnings_vi: 'Nguy cơ nhiễm toan lactic (hiếm nhưng nghiêm trọng). Ngừng thuốc trước phẫu thuật hoặc tiêm thuốc cản quang có iod 48h. Theo dõi chức năng thận định kỳ. Có thể thiếu vitamin B12 khi dùng lâu dài.',
    warnings_en: 'Risk of lactic acidosis (rare but serious). Discontinue 48h before surgery or contrast procedures. Monitor renal function regularly.',
    
    common_side_effects_vi: 'Buồn nôn, tiêu chảy, đau bụng, chướng hơi, giảm ngon miệng (thường tự hết sau 1-2 tuần)',
    common_side_effects_en: 'Nausea, diarrhea, abdominal pain, bloating, decreased appetite',
    serious_side_effects_vi: 'Nhiễm toan lactic (hiếm), thiếu vitamin B12, hạ đường huyết khi dùng kết hợp insulin/sulfonylurea',
    serious_side_effects_en: 'Lactic acidosis (rare), vitamin B12 deficiency, hypoglycemia when combined with insulin',
    
    mechanism_of_action_vi: 'Giảm sản xuất glucose ở gan, tăng độ nhạy insulin ở mô ngoại vi, giảm hấp thu glucose ở ruột.',
    mechanism_of_action_en: 'Decreases hepatic glucose production, increases insulin sensitivity, reduces intestinal glucose absorption.',
    pharmacokinetics_vi: 'Hấp thu: 50-60%, đạt nồng độ đỉnh sau 2-3h. Không liên kết protein. Không chuyển hóa gan. Thải trừ qua thận (90%), T1/2 = 4-8.7h.',
    pharmacokinetics_en: 'Absorption: 50-60%, peak 2-3h. No protein binding. Not metabolized. Renal excretion (90%), T1/2 = 4-8.7h.',
    
    overdose_symptoms_vi: 'Hạ đường huyết, buồn nôn/nôn, tiêu chảy, đau bụng. Nguy cơ nhiễm toan lactic với liều rất cao.',
    overdose_treatment_vi: 'Điều trị triệu chứng. Glucose nếu hạ đường huyết. Lọc máu nếu nhiễm toan lactic.',
    
    pregnancy_category: 'B',
    pregnancy_notes_vi: 'Có thể dùng trong thai kỳ nếu lợi ích > nguy cơ. Insulin vẫn là lựa chọn ưu tiên.',
    lactation_notes_vi: 'Bài tiết vào sữa mẹ với nồng độ thấp. Cân nhắc lợi ích/nguy cơ khi cho con bú.',
    
    storage_conditions_vi: 'Bảo quản nơi khô mát, nhiệt độ dưới 30°C. Tránh ánh sáng trực tiếp. Để xa tầm tay trẻ em.',
    
    article_link_vi: 'https://www.vinmec.com/vie/benh/dai-thao-duong-type-2/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK518983/',
    reference_sources: JSON.stringify(['American Diabetes Association Guidelines 2024', 'WHO Essential Medicines List', 'Vietnam National Drug Information 2024'])
  },
  
  {
    drug_id: 3,
    name_vi: 'Glibenclamide',
    brand_name_vi: 'Daonil, Euglucon',
    generic_name: 'Glibenclamide',
    drug_class: 'Thuốc đái tháo đường',
    therapeutic_class: 'Sulfonylurea - Hạ đường huyết',
    strength: '2.5mg, 5mg',
    packaging: 'Hộp 10 vỉ x 10 viên',
    dosage_form: 'Viên nén',
    
    indications_vi: 'Điều trị đái tháo đường type 2 khi chế độ ăn uống và metformin đơn độc không đủ hiệu quả.',
    dosage_adult_vi: 'Liều khởi đầu: 2.5-5mg/ngày, uống trước bữa sáng. Tăng dần 2.5mg mỗi tuần. Liều tối đa: 15-20mg/ngày chia 2 lần.',
    dosage_special_vi: 'Suy thận/gan nặng: Chống chỉ định. Người cao tuổi: Bắt đầu với liều thấp 1.25-2.5mg/ngày.',
    
    contraindications_vi: 'Đái tháo đường type 1, hôn mê đái tháo đường, nhiễm toan ceton, suy gan/thận nặng, quá mẫn sulfonylurea.',
    warnings_vi: 'Nguy cơ hạ đường huyết cao, đặc biệt ở người cao tuổi. Tránh bỏ bữa ăn. Theo dõi đường huyết thường xuyên.',
    
    common_side_effects_vi: 'Hạ đường huyết, tăng cân, buồn nôn, đau bụng',
    serious_side_effects_vi: 'Hạ đường huyết nặng, rối loạn máu (hiếm), phản ứng dị ứng',
    
    mechanism_of_action_vi: 'Kích thích tuyến tụy tiết insulin bằng cách đóng kênh kali phụ thuộc ATP trên tế bào beta.',
    pharmacokinetics_vi: 'Hấp thu nhanh, đạt đỉnh sau 2-4h. Liên kết protein 99%. Chuyển hóa gan. T1/2 = 10h.',
    
    pregnancy_category: 'C',
    pregnancy_notes_vi: 'Chống chỉ định trong thai kỳ. Chuyển sang insulin khi mang thai.',
    lactation_notes_vi: 'Chống chỉ định khi cho con bú. Có thể gây hạ đường huyết cho trẻ.',
    
    storage_conditions_vi: 'Bảo quản nơi khô mát, dưới 25°C. Tránh ẩm.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/glibenclamide/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK519051/'
  },
  
  {
    drug_id: 4,
    name_vi: 'Insulin',
    brand_name_vi: 'Lantus, Novorapid, Humalog',
    generic_name: 'Insulin Human/Analog',
    drug_class: 'Thuốc đái tháo đường',
    therapeutic_class: 'Insulin - Hạ đường huyết',
    strength: '100 IU/ml',
    packaging: 'Lọ 10ml hoặc bút tiêm',
    dosage_form: 'Dung dịch tiêm',
    
    indications_vi: 'Điều trị đái tháo đường type 1, type 2 không kiểm soát được bằng thuốc uống, đái tháo đường thai kỳ, tình trạng cấp cứu (hôn mê, nhiễm toan ceton).',
    dosage_adult_vi: 'Liều cá thể hóa dựa trên đường huyết. Thường 0.5-1 UI/kg/ngày. Insulin nền (basal): 1-2 lần/ngày. Insulin tác dụng nhanh: trước mỗi bữa ăn.',
    dosage_pediatric_vi: 'Trẻ em type 1: 0.5-1 UI/kg/ngày. Thanh thiếu niên đang phát triển: có thể cần 1-1.5 UI/kg/ngày.',
    
    contraindications_vi: 'Hạ đường huyết, quá mẫn với insulin hoặc tá dược.',
    warnings_vi: 'Nguy cơ hạ đường huyết. Không được tiêm tĩnh mạch (trừ insulin regular trong cấp cứu). Xoay vị trí tiêm để tránh loạn dưỡng mô mỡ. Bảo quản đúng cách.',
    black_box_warning_vi: 'Hạ đường huyết có thể đe dọa tính mạng. Giáo dục bệnh nhân nhận biết và xử lý hạ đường huyết.',
    
    common_side_effects_vi: 'Hạ đường huyết, phản ứng tại chỗ tiêm (đau, đỏ), tăng cân nhẹ',
    serious_side_effects_vi: 'Hạ đường huyết nặng (co giật, hôn mê), phù mạch, sốc phản vệ (rất hiếm), hạ kali máu',
    
    mechanism_of_action_vi: 'Thúc đẩy hấp thu glucose vào tế bào, ức chế phân giải glycogen, giảm sản xuất glucose ở gan, thúc đẩy tổng hợp protein và lipid.',
    pharmacokinetics_vi: 'Khởi phát và thời gian tác dụng phụ thuộc loại insulin: Rapid (15 phút-4h), Short (30 phút-6-8h), Intermediate (1-2h, 12-18h), Long-acting (1-2h, 24h+).',
    
    overdose_symptoms_vi: 'Hạ đường huyết: đói, run, vã mồ hôi, hồi hộp, rối loạn ý thức, co giật, hôn mê.',
    overdose_treatment_vi: 'Glucose đường uống nếu tỉnh. Tiêm glucose 10-25% tĩnh mạch hoặc glucagon 1mg tiêm bắp nếu bất tỉnh.',
    
    pregnancy_category: 'B',
    pregnancy_notes_vi: 'An toàn, là thuốc ưu tiên cho đái tháo đường thai kỳ. Nhu cầu insulin thay đổi trong thai kỳ.',
    lactation_notes_vi: 'An toàn khi cho con bú. Insulin không qua sữa mẹ đáng kể.',
    
    storage_conditions_vi: 'Lọ chưa mở: Bảo quản tủ lạnh 2-8°C. Đang sử dụng: Nhiệt độ phòng <30°C, dùng trong 28 ngày. Không đông lạnh. Tránh ánh sáng.',
    article_link_vi: 'https://www.vinmec.com/vie/benh/dai-thao-duong-type-1/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK557815/'
  },
  
  {
    drug_id: 5,
    name_vi: 'Amlodipine',
    brand_name_vi: 'Norvasc, Amlostad',
    generic_name: 'Amlodipine Besylate',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'Calcium Channel Blocker - Hạ huyết áp',
    strength: '5mg, 10mg',
    packaging: 'Hộp 3 vỉ x 10 viên',
    dosage_form: 'Viên nén',
    
    indications_vi: 'Điều trị tăng huyết áp, đau thắt ngực ổn định, đau thắt ngực Prinzmetal.',
    dosage_adult_vi: 'Tăng huyết áp: Bắt đầu 5mg/ngày, có thể tăng lên 10mg/ngày. Đau thắt ngực: 5-10mg/ngày.',
    dosage_pediatric_vi: 'Trẻ 6-17 tuổi: 2.5-5mg/ngày.',
    dosage_special_vi: 'Suy gan: Bắt đầu 2.5mg/ngày. Người cao tuổi: Bắt đầu 2.5mg/ngày.',
    
    contraindications_vi: 'Quá mẫn amlodipine, hạ huyết áp nặng (<90/60 mmHg), sốc tim.',
    warnings_vi: 'Theo dõi huyết áp. Tăng tần suất đau thắt ngực khi bắt đầu điều trị (hiếm). Thận trọng ở bệnh nhân suy tim.',
    
    common_side_effects_vi: 'Phù mắt cá chân, đau đầu, mệt mỏi, đỏ mặt, hồi hộp',
    serious_side_effects_vi: 'Phù nặng, hạ huyết áp nặng, nhồi máu cơ tim (rất hiếm)',
    
    mechanism_of_action_vi: 'Ức chế dòng canxi vào tế bào cơ trơn mạch máu và cơ tim, gây giãn mạch, giảm sức cản ngoại vi, hạ huyết áp.',
    pharmacokinetics_vi: 'Hấp thu chậm, đạt đỉnh sau 6-12h. Sinh khả dụng 64-90%. Liên kết protein 93%. Chuyển hóa gan. T1/2 = 30-50h.',
    
    pregnancy_category: 'C',
    pregnancy_notes_vi: 'Dùng khi lợi ích > nguy cơ. Ưu tiên methyldopa, labetalol trong thai kỳ.',
    lactation_notes_vi: 'Bài tiết vào sữa mẹ. Thận trọng khi cho con bú.',
    
    storage_conditions_vi: 'Bảo quản dưới 30°C, nơi khô mát.',
    article_link_vi: 'https://www.vinmec.com/vie/benh/tang-huyet-ap/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK519508/'
  },
  
  {
    drug_id: 6,
    name_vi: 'Losartan',
    brand_name_vi: 'Cozaar, Losar',
    generic_name: 'Losartan Potassium',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'ARB (Angiotensin Receptor Blocker) - Hạ huyết áp',
    strength: '50mg, 100mg',
    packaging: 'Hộp 3 vỉ x 10 viên',
    dosage_form: 'Viên nén bao phim',
    
    indications_vi: 'Tăng huyết áp, suy tim, bảo vệ thận ở bệnh nhân đái tháo đường type 2 có protein niệu, giảm nguy cơ đột quỵ ở bệnh nhân tăng huyết áp có phì đại thất trái.',
    dosage_adult_vi: 'Tăng huyết áp: 50mg/ngày, có thể tăng lên 100mg/ngày. Suy tim: Bắt đầu 12.5mg/ngày, tăng dần.',
    dosage_pediatric_vi: 'Trẻ ≥6 tuổi: 0.7mg/kg/ngày (tối đa 50mg/ngày).',
    dosage_special_vi: 'Suy gan: Giảm liều khởi đầu xuống 25mg/ngày.',
    
    contraindications_vi: 'Quá mẫn, thai kỳ (trimester 2-3), dùng kết hợp aliskiren ở bệnh nhân đái tháo đường.',
    warnings_vi: 'Nguy cơ hạ huyết áp, tăng kali máu, suy giảm chức năng thận. Theo dõi kali và creatinine.',
    black_box_warning_vi: 'Chống chỉ định ở thai kỳ từ tháng thứ 4. Gây tổn thương thai nhi và tử vong.',
    
    common_side_effects_vi: 'Chóng mặt, mệt mỏi, hạ huyết áp tư thế, tăng kali máu nhẹ',
    serious_side_effects_vi: 'Tăng kali máu nặng, suy thận cấp, phù mạch (hiếm)',
    
    mechanism_of_action_vi: 'Chặn thụ thể angiotensin II type 1 (AT1), giảm co mạch và tiết aldosterone, hạ huyết áp.',
    pharmacokinetics_vi: 'Hấp thu nhanh, sinh khả dụng 33%. Chuyển hóa gan thành chất chuyển hóa hoạt tính. T1/2 = 2h (losartan), 6-9h (chất chuyển hóa).',
    
    pregnancy_category: 'D',
    pregnancy_notes_vi: 'Chống chỉ định từ trimester 2. Ngừng ngay khi phát hiện mang thai.',
    lactation_notes_vi: 'Không rõ bài tiết vào sữa mẹ. Cân nhắc ngừng thuốc hoặc ngừng cho con bú.',
    
    storage_conditions_vi: 'Bảo quản dưới 30°C, tránh ẩm.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/losartan/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK526065/'
  },
  
  {
    drug_id: 7,
    name_vi: 'Enalapril',
    brand_name_vi: 'Renitec, Envas',
    generic_name: 'Enalapril Maleate',
    drug_class: 'Thuốc tim mạch',
    therapeutic_class: 'ACE Inhibitor - Hạ huyết áp',
    strength: '5mg, 10mg, 20mg',
    packaging: 'Hộp 3 vỉ x 10 viên',
    dosage_form: 'Viên nén',
    
    indications_vi: 'Tăng huyết áp, suy tim, rối loạn chức năng thất trái không triệu chứng.',
    dosage_adult_vi: 'Tăng huyết áp: 5-10mg/ngày, tối đa 40mg/ngày. Suy tim: Bắt đầu 2.5mg/ngày, tăng dần lên 10-20mg/ngày chia 2 lần.',
    dosage_special_vi: 'Suy thận: Giảm liều. CrCl 30-80: Bắt đầu 5mg/ngày. CrCl <30: Bắt đầu 2.5mg/ngày.',
    
    contraindications_vi: 'Quá mẫn, tiền sử phù mạch do ACE inhibitor, thai kỳ, dùng kết hợp aliskiren ở bệnh nhân đái tháo đường.',
    warnings_vi: 'Nguy cơ hạ huyết áp lần đầu, tăng kali máu, suy thận, ho khan. Theo dõi kali, creatinine. Phù mạch cần ngừng thuốc ngay.',
    black_box_warning_vi: 'Chống chỉ định trong thai kỳ. Gây tổn thương thai nhi và tử vong.',
    
    common_side_effects_vi: 'Ho khan (5-10%), chóng mặt, hạ huyết áp, mệt mỏi, đau đầu',
    serious_side_effects_vi: 'Phù mạch (0.1-0.2%), tăng kali máu nặng, suy thận cấp, giảm bạch cầu (hiếm)',
    
    mechanism_of_action_vi: 'Ức chế enzyme chuyển angiotensin (ACE), giảm angiotensin II, giảm co mạch và tiết aldosterone. Tăng bradykinin (gây ho).',
    pharmacokinetics_vi: 'Tiền chất, chuyển thành enalaprilat (hoạt tính) sau hấp thu. Sinh khả dụng 60%. T1/2 = 11h (enalaprilat).',
    
    pregnancy_category: 'D',
    pregnancy_notes_vi: 'Chống chỉ định. Ngừng ngay khi mang thai.',
    lactation_notes_vi: 'Bài tiết vào sữa mẹ với nồng độ thấp. Sử dụng thận trọng.',
    
    storage_conditions_vi: 'Bảo quản dưới 30°C, nơi khô mát.',
    article_link_vi: 'https://www.vinmec.com/vie/thuoc/enalapril/',
    article_link_en: 'https://www.ncbi.nlm.nih.gov/books/NBK482398/'
  }
];

// Drug interactions for the first 7 drugs
const drugInteractions = [
  // Metformin interactions
  { drug_id: 2, interaction_type: 'food', interacts_with: 'Rượu / Alcohol', severity: 'major', description_vi: 'Rượu làm tăng nguy cơ nhiễm toan lactic khi dùng metformin', clinical_effects_vi: 'Nguy cơ nhiễm toan lactic, hạ đường huyết', management_vi: 'Tránh uống rượu. Nếu uống, chỉ lượng nhỏ với thức ăn.' },
  { drug_id: 2, interaction_type: 'drug', interacts_with: 'Thuốc cản quang có iod', severity: 'major', description_vi: 'Thuốc cản quang có thể gây suy thận cấp, tăng nguy cơ nhiễm toan lactic', clinical_effects_vi: 'Suy thận cấp, nhiễm toan lactic', management_vi: 'Ngừng metformin trước 48h khi chụp có cản quang. Chỉ dùng lại sau 48h nếu chức năng thận bình thường.' },
  { drug_id: 2, interaction_type: 'drug', interacts_with: 'Insulin, Sulfonylurea', severity: 'moderate', description_vi: 'Tăng nguy cơ hạ đường huyết khi phối hợp', clinical_effects_vi: 'Hạ đường huyết', management_vi: 'Theo dõi đường huyết thường xuyên. Có thể cần giảm liều insulin/sulfonylurea.' },
  
  // Glibenclamide interactions
  { drug_id: 3, interaction_type: 'drug', interacts_with: 'Beta-blocker (Propranolol)', severity: 'moderate', description_vi: 'Che dấu triệu chứng hạ đường huyết (run, hồi hộp)', clinical_effects_vi: 'Khó phát hiện hạ đường huyết', management_vi: 'Theo dõi đường huyết kỹ lưỡng. Giáo dục bệnh nhân nhận biết triệu chứng khác (đói, vã mồ hôi).' },
  { drug_id: 3, interaction_type: 'food', interacts_with: 'Rượu', severity: 'major', description_vi: 'Rượu tăng nguy cơ hạ đường huyết', clinical_effects_vi: 'Hạ đường huyết nặng, có thể kéo dài', management_vi: 'Tránh uống rượu, đặc biệt khi đói.' },
  
  // Insulin interactions
  { drug_id: 4, interaction_type: 'drug', interacts_with: 'Corticosteroid', severity: 'moderate', description_vi: 'Tăng đường huyết, đối kháng tác dụng insulin', clinical_effects_vi: 'Tăng nhu cầu insulin', management_vi: 'Tăng liều insulin. Theo dõi đường huyết chặt chẽ.' },
  { drug_id: 4, interaction_type: 'drug', interacts_with: 'Salicylate liều cao (Aspirin)', severity: 'moderate', description_vi: 'Tăng tác dụng hạ đường huyết của insulin', clinical_effects_vi: 'Hạ đường huyết', management_vi: 'Giảm liều insulin có thể cần thiết. Theo dõi đường huyết.' },
  
  // Amlodipine interactions
  { drug_id: 5, interaction_type: 'food', interacts_with: 'Bưởi / Grapefruit', severity: 'moderate', description_vi: 'Bưởi ức chế CYP3A4, tăng nồng độ amlodipine trong máu', clinical_effects_vi: 'Tăng nguy cơ hạ huyết áp, phù mạch', management_vi: 'Tránh ăn bưởi hoặc uống nước bưởi trong khi điều trị.' },
  { drug_id: 5, interaction_type: 'drug', interacts_with: 'Simvastatin liều cao', severity: 'moderate', description_vi: 'Amlodipine tăng nồng độ simvastatin', clinical_effects_vi: 'Tăng nguy cơ tổn thương cơ (myopathy)', management_vi: 'Giới hạn simvastatin ≤20mg/ngày khi dùng với amlodipine.' },
  
  // Losartan interactions
  { drug_id: 6, interaction_type: 'drug', interacts_with: 'Thuốc lợi tiểu giữ kali, Bổ sung kali', severity: 'major', description_vi: 'Tăng nguy cơ tăng kali máu', clinical_effects_vi: 'Tăng kali máu nặng, rối loạn nhịp tim', management_vi: 'Tránh dùng kết hợp. Nếu cần, theo dõi kali máu thường xuyên.' },
  { drug_id: 6, interaction_type: 'drug', interacts_with: 'NSAID (Ibuprofen, Naproxen)', severity: 'moderate', description_vi: 'Giảm tác dụng hạ huyết áp, tăng nguy cơ suy thận', clinical_effects_vi: 'Giảm hiệu quả hạ áp, suy thận', management_vi: 'Theo dõi huyết áp và chức năng thận. Sử dụng NSAID liều thấp nhất, thời gian ngắn nhất.' },
  
  // Enalapril interactions
  { drug_id: 7, interaction_type: 'drug', interacts_with: 'Bổ sung kali, Thuốc lợi tiểu giữ kali', severity: 'major', description_vi: 'Tăng nguy cơ tăng kali máu nghiêm trọng', clinical_effects_vi: 'Tăng kali máu, rối loạn nhịp tim nguy hiểm', management_vi: 'Tránh dùng kết hợp. Nếu cần thiết, theo dõi kali máu chặt chẽ.' },
  { drug_id: 7, interaction_type: 'drug', interacts_with: 'Lithium', severity: 'moderate', description_vi: 'Tăng nồng độ lithium trong máu', clinical_effects_vi: 'Ngộ độc lithium (run, lú lẫn, buồn nôn)', management_vi: 'Theo dõi nồng độ lithium máu khi bắt đầu/ngừng enalapril.' }
];

// Drug side effects for the first 7 drugs
const drugSideEffects = [
  // Metformin
  { drug_id: 2, effect_name_vi: 'Tiêu chảy', frequency: 'very_common', severity: 'mild', description_vi: 'Phân lỏng, đi ngoài nhiều lần. Thường giảm sau 1-2 tuần.', is_serious: false },
  { drug_id: 2, effect_name_vi: 'Buồn nôn', frequency: 'very_common', severity: 'mild', description_vi: 'Cảm giác khó chịu ở dạ dày. Uống thuốc sau ăn để giảm.', is_serious: false },
  { drug_id: 2, effect_name_vi: 'Nhiễm toan lactic', frequency: 'rare', severity: 'severe', description_vi: 'Tích tụ acid lactic trong máu. Triệu chứng: mệt, khó thở, đau bụng, rối loạn nhịp tim.', is_serious: true },
  { drug_id: 2, effect_name_vi: 'Thiếu Vitamin B12', frequency: 'common', severity: 'moderate', description_vi: 'Dùng lâu dài giảm hấp thu B12. Triệu chứng: mệt, thiếu máu, tê bì.', is_serious: false },
  
  // Glibenclamide
  { drug_id: 3, effect_name_vi: 'Hạ đường huyết', frequency: 'common', severity: 'moderate', description_vi: 'Đói, run, vã mồ hôi, hồi hộp, chóng mặt. Cần ăn ngay thức ăn có đường.', is_serious: false },
  { drug_id: 3, effect_name_vi: 'Tăng cân', frequency: 'common', severity: 'mild', description_vi: 'Tăng cân 1-2kg trong vài tháng đầu.', is_serious: false },
  { drug_id: 3, effect_name_vi: 'Hạ đường huyết nặng', frequency: 'uncommon', severity: 'severe', description_vi: 'Co giật, lú lẫn, hôn mê. Cần cấp cứu ngay.', is_serious: true },
  
  // Insulin
  { drug_id: 4, effect_name_vi: 'Hạ đường huyết', frequency: 'very_common', severity: 'moderate', description_vi: 'Phụ thuộc liều và chế độ ăn. Đói, run, vã mồ hôi.', is_serious: false },
  { drug_id: 4, effect_name_vi: 'Phản ứng tại chỗ tiêm', frequency: 'common', severity: 'mild', description_vi: 'Đau, đỏ, ngứa tại vị trí tiêm. Xoay vị trí tiêm.', is_serious: false },
  { drug_id: 4, effect_name_vi: 'Loạn dưỡng mô mỡ', frequency: 'common', severity: 'mild', description_vi: 'Khối u mỡ hoặc hủy mô mỡ tại chỗ tiêm. Do tiêm cùng chỗ nhiều lần.', is_serious: false },
  { drug_id: 4, effect_name_vi: 'Hạ đường huyết nặng', frequency: 'uncommon', severity: 'severe', description_vi: 'Co giật, hôn mê, có thể tử vong nếu không điều trị kịp thời.', is_serious: true },
  
  // Amlodipine
  { drug_id: 5, effect_name_vi: 'Phù mắt cá chân', frequency: 'very_common', severity: 'mild', description_vi: 'Sưng ở chân, mắt cá. Giảm khi nâng chân cao.', is_serious: false },
  { drug_id: 5, effect_name_vi: 'Đau đầu', frequency: 'common', severity: 'mild', description_vi: 'Đau đầu nhẹ, thường giảm sau vài ngày.', is_serious: false },
  { drug_id: 5, effect_name_vi: 'Đỏ mặt', frequency: 'common', severity: 'mild', description_vi: 'Cảm giác nóng, đỏ mặt. Do giãn mạch.', is_serious: false },
  
  // Losartan
  { drug_id: 6, effect_name_vi: 'Chóng mặt', frequency: 'common', severity: 'mild', description_vi: 'Chóng mặt khi đứng dậy đột ngột (hạ huyết áp tư thế).', is_serious: false },
  { drug_id: 6, effect_name_vi: 'Tăng kali máu', frequency: 'common', severity: 'moderate', description_vi: 'Tăng kali nhẹ. Cần theo dõi xét nghiệm.', is_serious: false },
  { drug_id: 6, effect_name_vi: 'Phù mạch', frequency: 'rare', severity: 'severe', description_vi: 'Sưng mặt, môi, lưỡi, thanh quản. Cấp cứu ngay.', is_serious: true },
  
  // Enalapril
  { drug_id: 7, effect_name_vi: 'Ho khan', frequency: 'common', severity: 'mild', description_vi: 'Ho khan, không đờm. Do tích tụ bradykinin. Có thể cần đổi thuốc.', is_serious: false },
  { drug_id: 7, effect_name_vi: 'Chóng mặt', frequency: 'common', severity: 'mild', description_vi: 'Chóng mặt, đặc biệt lần đầu dùng thuốc.', is_serious: false },
  { drug_id: 7, effect_name_vi: 'Phù mạch', frequency: 'rare', severity: 'severe', description_vi: 'Sưng mặt, môi, lưỡi. Ngừng thuốc ngay và cấp cứu.', is_serious: true }
];

async function importComprehensiveDrugData() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('=== BẮT ĐẦU IMPORT DỮ LIỆU TOÀN DIỆN CHO THUỐC ===\n');
    
    // Update drugs with comprehensive data
    for (const drug of comprehensiveDrugData) {
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
      
      console.log(`✓ Updated: ${drug.name_vi}`);
    }
    
    console.log(`\n✅ Đã cập nhật ${comprehensiveDrugData.length} thuốc\n`);
    
    // Import drug interactions
    console.log('=== IMPORT TƯƠNG TÁC THUỐC ===\n');
    
    // Clear existing interactions for these drugs
    await client.query(
      'DELETE FROM drug_interaction WHERE drug_id IN (2, 3, 4, 5, 6, 7)'
    );
    
    for (const interaction of drugInteractions) {
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
    
    console.log(`✅ Đã import ${drugInteractions.length} tương tác thuốc\n`);
    
    // Import side effects
    console.log('=== IMPORT TÁC DỤNG PHỤ ===\n');
    
    // Clear existing side effects for these drugs
    await client.query(
      'DELETE FROM drug_side_effect WHERE drug_id IN (2, 3, 4, 5, 6, 7)'
    );
    
    for (const sideEffect of drugSideEffects) {
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
    
    console.log(`✅ Đã import ${drugSideEffects.length} tác dụng phụ\n`);
    
    await client.query('COMMIT');
    
    // Summary
    console.log('=== TÓM TẮT ===');
    const drugCount = await client.query('SELECT COUNT(*) FROM drug WHERE brand_name_vi IS NOT NULL');
    const interactionCount = await client.query('SELECT COUNT(*) FROM drug_interaction');
    const sideEffectCount = await client.query('SELECT COUNT(*) FROM drug_side_effect');
    
    console.log(`✓ Thuốc có dữ liệu đầy đủ: ${drugCount.rows[0].count}`);
    console.log(`✓ Tổng tương tác: ${interactionCount.rows[0].count}`);
    console.log(`✓ Tổng tác dụng phụ: ${sideEffectCount.rows[0].count}`);
    console.log('\n🎉 HOÀN THÀNH!');
    
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Lỗi:', err.message);
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

importComprehensiveDrugData();
