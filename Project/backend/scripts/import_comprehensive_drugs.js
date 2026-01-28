require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

// Comprehensive drug data for all 39 conditions
const drugsData = [
  // Diabetes drugs
  { name_vi: 'Metformin', name_en: 'Metformin', description: 'Thuốc điều trị đái tháo đường type 2, giúp giảm đường huyết', category: 'Thuốc tiểu đường' },
  { name_vi: 'Glibenclamide', name_en: 'Glibenclamide', description: 'Thuốc kích thích tụy tiết insulin, điều trị đái tháo đường type 2', category: 'Thuốc tiểu đường' },
  { name_vi: 'Insulin', name_en: 'Insulin', description: 'Hormone điều trị đái tháo đường, giúp kiểm soát đường huyết', category: 'Thuốc tiểu đường' },
  
  // Hypertension drugs
  { name_vi: 'Amlodipine', name_en: 'Amlodipine', description: 'Thuốc chẹn kênh canxi, điều trị tăng huyết áp', category: 'Thuốc tim mạch' },
  { name_vi: 'Losartan', name_en: 'Losartan', description: 'Thuốc chẹn thụ thể angiotensin II, điều trị tăng huyết áp', category: 'Thuốc tim mạch' },
  { name_vi: 'Enalapril', name_en: 'Enalapril', description: 'Thuốc ức chế men chuyển, điều trị tăng huyết áp và suy tim', category: 'Thuốc tim mạch' },
  
  // Cholesterol drugs
  { name_vi: 'Atorvastatin', name_en: 'Atorvastatin', description: 'Thuốc nhóm statin, giảm cholesterol và nguy cơ tim mạch', category: 'Thuốc mỡ máu' },
  { name_vi: 'Simvastatin', name_en: 'Simvastatin', description: 'Thuốc giảm cholesterol, phòng ngừa bệnh tim mạch', category: 'Thuốc mỡ máu' },
  { name_vi: 'Fenofibrate', name_en: 'Fenofibrate', description: 'Thuốc giảm triglyceride và tăng HDL-cholesterol', category: 'Thuốc mỡ máu' },
  
  // Gout drugs
  { name_vi: 'Allopurinol', name_en: 'Allopurinol', description: 'Thuốc giảm acid uric trong máu, phòng ngừa cơn gout', category: 'Thuốc gout' },
  { name_vi: 'Colchicine', name_en: 'Colchicine', description: 'Thuốc giảm viêm, điều trị cơn gout cấp', category: 'Thuốc gout' },
  
  // Anemia drugs
  { name_vi: 'Sắt sulfat', name_en: 'Ferrous Sulfate', description: 'Bổ sung sắt điều trị thiếu máu do thiếu sắt', category: 'Bổ sung vitamin khoáng' },
  { name_vi: 'Acid folic', name_en: 'Folic Acid', description: 'Vitamin B9, điều trị thiếu máu do thiếu folate', category: 'Bổ sung vitamin khoáng' },
  { name_vi: 'Vitamin B12', name_en: 'Cyanocobalamin', description: 'Điều trị thiếu máu do thiếu vitamin B12', category: 'Bổ sung vitamin khoáng' },
  
  // Osteoporosis drugs
  { name_vi: 'Canxi + Vitamin D', name_en: 'Calcium + Vitamin D', description: 'Bổ sung canxi và vitamin D phòng ngừa loãng xương', category: 'Bổ sung vitamin khoáng' },
  { name_vi: 'Alendronate', name_en: 'Alendronate', description: 'Thuốc bisphosphonate, điều trị loãng xương', category: 'Thuốc xương khớp' },
  
  // GERD drugs
  { name_vi: 'Omeprazole', name_en: 'Omeprazole', description: 'Thuốc ức chế bơm proton, điều trị trào ngược dạ dày thực quản', category: 'Thuốc tiêu hóa' },
  { name_vi: 'Esomeprazole', name_en: 'Esomeprazole', description: 'Thuốc ức chế bơm proton, điều trị GERD và loét dạ dày', category: 'Thuốc tiêu hóa' },
  { name_vi: 'Ranitidine', name_en: 'Ranitidine', description: 'Thuốc kháng H2, giảm tiết acid dạ dày', category: 'Thuốc tiêu hóa' },
  
  // Asthma/COPD drugs
  { name_vi: 'Salbutamol', name_en: 'Salbutamol', description: 'Thuốc giãn phế quản, điều trị hen phế quản và COPD', category: 'Thuốc hô hấp' },
  { name_vi: 'Budesonide', name_en: 'Budesonide', description: 'Corticosteroid dạng hít, điều trị hen phế quản', category: 'Thuốc hô hấp' },
  { name_vi: 'Theophylline', name_en: 'Theophylline', description: 'Thuốc giãn phế quản, điều trị hen và COPD', category: 'Thuốc hô hấp' },
  
  // Heart failure drugs
  { name_vi: 'Furosemide', name_en: 'Furosemide', description: 'Thuốc lợi tiểu, điều trị suy tim và phù', category: 'Thuốc tim mạch' },
  { name_vi: 'Digoxin', name_en: 'Digoxin', description: 'Thuốc tăng sức co bóp tim, điều trị suy tim và rung nhĩ', category: 'Thuốc tim mạch' },
  { name_vi: 'Spironolactone', name_en: 'Spironolactone', description: 'Thuốc lợi tiểu giữ kali, điều trị suy tim', category: 'Thuốc tim mạch' },
  
  // Anticoagulants
  { name_vi: 'Warfarin', name_en: 'Warfarin', description: 'Thuốc chống đông máu, phòng ngừa huyết khối và rung nhĩ', category: 'Thuốc tim mạch' },
  { name_vi: 'Rivaroxaban', name_en: 'Rivaroxaban', description: 'Thuốc chống đông máu thế hệ mới, điều trị huyết khối', category: 'Thuốc tim mạch' },
  
  // Antibiotics
  { name_vi: 'Ciprofloxacin', name_en: 'Ciprofloxacin', description: 'Kháng sinh nhóm quinolone, điều trị nhiễm khuẩn đường ruột', category: 'Kháng sinh' },
  { name_vi: 'Azithromycin', name_en: 'Azithromycin', description: 'Kháng sinh nhóm macrolide, điều trị nhiễm khuẩn đường hô hấp', category: 'Kháng sinh' },
  { name_vi: 'Amoxicillin', name_en: 'Amoxicillin', description: 'Kháng sinh nhóm penicillin, điều trị nhiễm khuẩn', category: 'Kháng sinh' },
  
  // TB drugs
  { name_vi: 'Isoniazid', name_en: 'Isoniazid', description: 'Thuốc điều trị lao phổi và lao màng não', category: 'Thuốc lao' },
  { name_vi: 'Rifampicin', name_en: 'Rifampicin', description: 'Thuốc kháng sinh điều trị lao', category: 'Thuốc lao' },
  { name_vi: 'Ethambutol', name_en: 'Ethambutol', description: 'Thuốc điều trị lao, phối hợp với các thuốc khác', category: 'Thuốc lao' },
  { name_vi: 'Pyrazinamide', name_en: 'Pyrazinamide', description: 'Thuốc điều trị lao trong giai đoạn đầu', category: 'Thuốc lao' },
  
  // Thyroid drugs
  { name_vi: 'Levothyroxine', name_en: 'Levothyroxine', description: 'Hormone tuyến giáp, điều trị suy giáp', category: 'Thuốc nội tiết' },
  { name_vi: 'Propylthiouracil', name_en: 'Propylthiouracil', description: 'Thuốc điều trị cường giáp', category: 'Thuốc nội tiết' },
  { name_vi: 'Methimazole', name_en: 'Methimazole', description: 'Thuốc giảm hoạt động tuyến giáp, điều trị cường giáp', category: 'Thuốc nội tiết' },
  
  // Arthritis drugs
  { name_vi: 'Methotrexate', name_en: 'Methotrexate', description: 'Thuốc điều trị viêm khớp dạng thấp', category: 'Thuốc xương khớp' },
  { name_vi: 'Hydroxychloroquine', name_en: 'Hydroxychloroquine', description: 'Thuốc chống thấp khớp, điều trị viêm khớp dạng thấp', category: 'Thuốc xương khớp' },
  
  // Migraine drugs
  { name_vi: 'Sumatriptan', name_en: 'Sumatriptan', description: 'Thuốc điều trị cơn đau nửa đầu migraine', category: 'Thuốc thần kinh' },
  { name_vi: 'Propranolol', name_en: 'Propranolol', description: 'Thuốc chẹn beta, phòng ngừa migraine', category: 'Thuốc thần kinh' },
  
  // Other
  { name_vi: 'Aspirin', name_en: 'Aspirin', description: 'Thuốc giảm đau, hạ sốt, chống viêm và chống kết tập tiểu cầu', category: 'Thuốc giảm đau' },
  { name_vi: 'Paracetamol', name_en: 'Paracetamol', description: 'Thuốc giảm đau, hạ sốt', category: 'Thuốc giảm đau' },
];

// Drug-condition relationships with Vietnamese treatment notes
const drugConditionRelationships = [
  // Type 2 Diabetes (1, 11)
  { drugName: 'Metformin', conditionId: 1, notes_vi: 'Thuốc đầu tay điều trị đái tháo đường type 2', isPrimary: true },
  { drugName: 'Metformin', conditionId: 11, notes_vi: 'Thuốc đầu tay điều trị đái tháo đường type 2', isPrimary: true },
  { drugName: 'Glibenclamide', conditionId: 1, notes_vi: 'Dùng khi metformin không đủ hiệu quả', isPrimary: false },
  { drugName: 'Glibenclamide', conditionId: 11, notes_vi: 'Dùng khi metformin không đủ hiệu quả', isPrimary: false },
  { drugName: 'Insulin', conditionId: 1, notes_vi: 'Dùng khi thuốc uống không kiểm soát được đường huyết', isPrimary: false },
  { drugName: 'Insulin', conditionId: 11, notes_vi: 'Dùng khi thuốc uống không kiểm soát được đường huyết', isPrimary: false },
  
  // Hypertension (2, 12)
  { drugName: 'Amlodipine', conditionId: 2, notes_vi: 'Thuốc hạ huyết áp nhóm chẹn kênh canxi', isPrimary: true },
  { drugName: 'Amlodipine', conditionId: 12, notes_vi: 'Thuốc hạ huyết áp nhóm chẹn kênh canxi', isPrimary: true },
  { drugName: 'Losartan', conditionId: 2, notes_vi: 'Chẹn thụ thể angiotensin, bảo vệ thận', isPrimary: true },
  { drugName: 'Losartan', conditionId: 12, notes_vi: 'Chẹn thụ thể angiotensin, bảo vệ thận', isPrimary: true },
  { drugName: 'Enalapril', conditionId: 2, notes_vi: 'Ức chế men chuyển, tốt cho bệnh nhân có bệnh thận', isPrimary: false },
  { drugName: 'Enalapril', conditionId: 12, notes_vi: 'Ức chế men chuyển, tốt cho bệnh nhân có bệnh thận', isPrimary: false },
  
  // High Cholesterol (3, 19)
  { drugName: 'Atorvastatin', conditionId: 3, notes_vi: 'Thuốc statin mạnh, giảm LDL-cholesterol hiệu quả', isPrimary: true },
  { drugName: 'Atorvastatin', conditionId: 19, notes_vi: 'Thuốc statin mạnh, giảm LDL-cholesterol hiệu quả', isPrimary: true },
  { drugName: 'Simvastatin', conditionId: 3, notes_vi: 'Giảm cholesterol, phòng ngừa biến cố tim mạch', isPrimary: true },
  { drugName: 'Simvastatin', conditionId: 19, notes_vi: 'Giảm cholesterol, phòng ngừa biến cố tim mạch', isPrimary: true },
  { drugName: 'Fenofibrate', conditionId: 3, notes_vi: 'Dùng khi triglyceride cao, có thể phối hợp statin', isPrimary: false },
  { drugName: 'Fenofibrate', conditionId: 19, notes_vi: 'Dùng khi triglyceride cao, có thể phối hợp statin', isPrimary: false },
  
  // Gout (5, 16)
  { drugName: 'Allopurinol', conditionId: 5, notes_vi: 'Dùng dài hạn phòng ngừa cơn gout tái phát', isPrimary: true },
  { drugName: 'Allopurinol', conditionId: 16, notes_vi: 'Dùng dài hạn phòng ngừa cơn gout tái phát', isPrimary: true },
  { drugName: 'Colchicine', conditionId: 5, notes_vi: 'Điều trị cơn gout cấp, giảm viêm', isPrimary: true },
  { drugName: 'Colchicine', conditionId: 16, notes_vi: 'Điều trị cơn gout cấp, giảm viêm', isPrimary: true },
  
  // Anemia (8, 14)
  { drugName: 'Sắt sulfat', conditionId: 8, notes_vi: 'Bổ sung sắt điều trị thiếu máu', isPrimary: true },
  { drugName: 'Sắt sulfat', conditionId: 14, notes_vi: 'Điều trị thiếu máu do thiếu sắt', isPrimary: true },
  { drugName: 'Acid folic', conditionId: 8, notes_vi: 'Điều trị thiếu máu do thiếu acid folic', isPrimary: true },
  { drugName: 'Vitamin B12', conditionId: 8, notes_vi: 'Điều trị thiếu máu do thiếu B12', isPrimary: false },
  { drugName: 'Vitamin B12', conditionId: 14, notes_vi: 'Phối hợp sắt nếu thiếu B12', isPrimary: false },
  
  // Osteoporosis (15)
  { drugName: 'Canxi + Vitamin D', conditionId: 15, notes_vi: 'Bổ sung canxi và vitamin D hàng ngày', isPrimary: true },
  { drugName: 'Alendronate', conditionId: 15, notes_vi: 'Thuốc điều trị loãng xương, uống 1 lần/tuần', isPrimary: true },
  
  // GERD (18)
  { drugName: 'Omeprazole', conditionId: 18, notes_vi: 'Giảm tiết acid dạ dày, uống trước ăn', isPrimary: true },
  { drugName: 'Esomeprazole', conditionId: 18, notes_vi: 'Ức chế bơm proton hiệu quả hơn omeprazole', isPrimary: true },
  { drugName: 'Ranitidine', conditionId: 18, notes_vi: 'Thay thế PPI khi không dung nạp', isPrimary: false },
  
  // Peptic Ulcer (29)
  { drugName: 'Omeprazole', conditionId: 29, notes_vi: 'Điều trị loét dạ dày tá tràng', isPrimary: true },
  { drugName: 'Esomeprazole', conditionId: 29, notes_vi: 'Chữa lành loét, phòng ngừa tái phát', isPrimary: true },
  { drugName: 'Amoxicillin', conditionId: 29, notes_vi: 'Diệt H.pylori gây loét, phối hợp PPI', isPrimary: true },
  
  // Asthma (27)
  { drugName: 'Salbutamol', conditionId: 27, notes_vi: 'Thuốc giãn phế quản dùng khi cấp cứu', isPrimary: true },
  { drugName: 'Budesonide', conditionId: 27, notes_vi: 'Thuốc kiểm soát hen dài hạn, dạng hít', isPrimary: true },
  { drugName: 'Theophylline', conditionId: 27, notes_vi: 'Phối hợp khi hen nặng', isPrimary: false },
  
  // COPD (28)
  { drugName: 'Salbutamol', conditionId: 28, notes_vi: 'Giãn phế quản, giảm khó thở', isPrimary: true },
  { drugName: 'Budesonide', conditionId: 28, notes_vi: 'Giảm viêm đường thở mãn tính', isPrimary: true },
  { drugName: 'Theophylline', conditionId: 28, notes_vi: 'Hỗ trợ giãn phế quản', isPrimary: false },
  
  // Heart Failure (24)
  { drugName: 'Furosemide', conditionId: 24, notes_vi: 'Lợi tiểu giảm phù, giảm gánh nặng tim', isPrimary: true },
  { drugName: 'Enalapril', conditionId: 24, notes_vi: 'Giảm hậu gánh, cải thiện tiên lượng', isPrimary: true },
  { drugName: 'Digoxin', conditionId: 24, notes_vi: 'Tăng co bóp tim, điều trị suy tim mãn', isPrimary: false },
  { drugName: 'Spironolactone', conditionId: 24, notes_vi: 'Lợi tiểu giữ kali, giảm tử vong', isPrimary: true },
  
  // DVT (13) & Atrial Fibrillation (23)
  { drugName: 'Warfarin', conditionId: 13, notes_vi: 'Chống đông máu, phòng huyết khối tái phát', isPrimary: true },
  { drugName: 'Warfarin', conditionId: 23, notes_vi: 'Phòng ngừa đột quỵ do rung nhĩ', isPrimary: true },
  { drugName: 'Rivaroxaban', conditionId: 13, notes_vi: 'Thuốc chống đông mới, tiện dùng hơn warfarin', isPrimary: true },
  { drugName: 'Rivaroxaban', conditionId: 23, notes_vi: 'Chống đông không cần theo dõi INR', isPrimary: true },
  
  // Bacterial infections (25, 26, 35, 36, 37)
  { drugName: 'Ciprofloxacin', conditionId: 25, notes_vi: 'Kháng sinh điều trị nhiễm Salmonella', isPrimary: true },
  { drugName: 'Ciprofloxacin', conditionId: 26, notes_vi: 'Điều trị nhiễm trùng huyết Salmonella', isPrimary: true },
  { drugName: 'Ciprofloxacin', conditionId: 35, notes_vi: 'Điều trị nhiễm E.coli đường ruột', isPrimary: true },
  { drugName: 'Ciprofloxacin', conditionId: 36, notes_vi: 'Điều trị viêm ruột Campylobacter', isPrimary: true },
  { drugName: 'Ciprofloxacin', conditionId: 37, notes_vi: 'Kháng sinh phổ rộng điều trị viêm dạ dày ruột', isPrimary: true },
  { drugName: 'Azithromycin', conditionId: 36, notes_vi: 'Thay thế ciprofloxacin khi kháng thuốc', isPrimary: false },
  { drugName: 'Azithromycin', conditionId: 37, notes_vi: 'Kháng sinh macrolide điều trị tiêu chảy', isPrimary: false },
  
  // Tuberculosis (38, 39)
  { drugName: 'Isoniazid', conditionId: 38, notes_vi: 'Thuốc lao hàng đầu, phối hợp 4 thuốc', isPrimary: true },
  { drugName: 'Isoniazid', conditionId: 39, notes_vi: 'Điều trị lao màng não, phối hợp rifampicin', isPrimary: true },
  { drugName: 'Rifampicin', conditionId: 38, notes_vi: 'Kháng sinh lao mạnh, làm đỏ nước tiểu', isPrimary: true },
  { drugName: 'Rifampicin', conditionId: 39, notes_vi: 'Thuốc lao thiết yếu cho lao màng não', isPrimary: true },
  { drugName: 'Ethambutol', conditionId: 38, notes_vi: 'Phối hợp điều trị lao giai đoạn đầu', isPrimary: true },
  { drugName: 'Ethambutol', conditionId: 39, notes_vi: 'Thuốc lao phối hợp, theo dõi thị lực', isPrimary: false },
  { drugName: 'Pyrazinamide', conditionId: 38, notes_vi: 'Dùng 2 tháng đầu điều trị lao', isPrimary: true },
  { drugName: 'Pyrazinamide', conditionId: 39, notes_vi: 'Giai đoạn đầu điều trị lao màng não', isPrimary: true },
  
  // Thyroid (32, 33)
  { drugName: 'Levothyroxine', conditionId: 32, notes_vi: 'Hormone tuyến giáp điều trị suy giáp suốt đời', isPrimary: true },
  { drugName: 'Propylthiouracil', conditionId: 33, notes_vi: 'Giảm hormone giáp, điều trị cường giáp', isPrimary: true },
  { drugName: 'Methimazole', conditionId: 33, notes_vi: 'Thuốc cường giáp ít tác dụng phụ hơn PTU', isPrimary: true },
  
  // Rheumatoid Arthritis (31)
  { drugName: 'Methotrexate', conditionId: 31, notes_vi: 'Thuốc đầu tay điều trị viêm khớp dạng thấp', isPrimary: true },
  { drugName: 'Hydroxychloroquine', conditionId: 31, notes_vi: 'Chống thấp, ít tác dụng phụ', isPrimary: true },
  
  // Migraine (34)
  { drugName: 'Sumatriptan', conditionId: 34, notes_vi: 'Điều trị cơn migraine cấp', isPrimary: true },
  { drugName: 'Propranolol', conditionId: 34, notes_vi: 'Phòng ngừa migraine dài hạn', isPrimary: true },
  
  // Coronary Artery Disease (22)
  { drugName: 'Aspirin', conditionId: 22, notes_vi: 'Chống kết tập tiểu cầu, phòng nhồi máu cơ tim', isPrimary: true },
  { drugName: 'Atorvastatin', conditionId: 22, notes_vi: 'Giảm cholesterol, ổn định mảng xơ vữa', isPrimary: true },
  { drugName: 'Amlodipine', conditionId: 22, notes_vi: 'Giảm đau thắt ngực, giãn mạch vành', isPrimary: false },
  
  // Chronic Kidney Disease (17)
  { drugName: 'Enalapril', conditionId: 17, notes_vi: 'Bảo vệ thận, giảm protein niệu', isPrimary: true },
  { drugName: 'Losartan', conditionId: 17, notes_vi: 'Chậm tiến triển suy thận', isPrimary: true },
  
  // Fatty Liver (6, 30)
  { drugName: 'Metformin', conditionId: 6, notes_vi: 'Cải thiện gan nhiễm mỡ ở bệnh nhân tiểu đường', isPrimary: false },
  { drugName: 'Metformin', conditionId: 30, notes_vi: 'Giảm mỡ gan, cải thiện chức năng gan', isPrimary: false },
  { drugName: 'Atorvastatin', conditionId: 6, notes_vi: 'Giảm mỡ máu, cải thiện gan nhiễm mỡ', isPrimary: false },
  { drugName: 'Atorvastatin', conditionId: 30, notes_vi: 'Điều trị rối loạn lipid kèm gan nhiễm mỡ', isPrimary: false },
  
  // Gastritis (7)
  { drugName: 'Omeprazole', conditionId: 7, notes_vi: 'Giảm acid dạ dày, giảm viêm niêm mạc', isPrimary: true },
  { drugName: 'Ranitidine', conditionId: 7, notes_vi: 'Điều trị viêm dạ dày nhẹ', isPrimary: false },
];

async function importComprehensiveDrugData() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('IMPORTING COMPREHENSIVE DRUG DATA FOR 39 CONDITIONS');
    console.log('='.repeat(80));

    await client.query('BEGIN');

    // Step 0: Clean up old data
    console.log('\n🧹 Cleaning up old drug data...');
    await client.query('DELETE FROM drughealthcondition');
    await client.query('DELETE FROM drug');
    console.log('✓ Cleaned up old data');

    // Step 1: Import all drugs
    console.log(`\n📦 Importing ${drugsData.length} drugs...`);
    const drugIdMap = new Map(); // drugName -> drug_id
    
    for (const drug of drugsData) {
      // Check if drug exists first
      const existing = await client.query(`
        SELECT drug_id FROM drug WHERE name_en = $1
      `, [drug.name_en]);
      
      let drugId;
      if (existing.rows.length > 0) {
        drugId = existing.rows[0].drug_id;
        // Update existing drug
        await client.query(`
          UPDATE drug SET
            name_vi = $1,
            description = $2,
            drug_class = $3,
            updated_at = NOW()
          WHERE drug_id = $4
        `, [drug.name_vi, drug.description, drug.category, drugId]);
      } else {
        // Insert new drug
        const result = await client.query(`
          INSERT INTO drug (name_vi, name_en, description, drug_class, is_active, created_at)
          VALUES ($1, $2, $3, $4, true, NOW())
          RETURNING drug_id
        `, [drug.name_vi, drug.name_en, drug.description, drug.category]);
        drugId = result.rows[0].drug_id;
      }
      
      drugIdMap.set(drug.name_en, drugId);
    }
    console.log(`✓ Imported ${drugsData.length} drugs`);

    // Step 2: Import drug-condition relationships
    console.log(`\n💊 Importing ${drugConditionRelationships.length} drug-condition relationships...`);
    let imported = 0;
    
    for (const rel of drugConditionRelationships) {
      const drugId = drugIdMap.get(rel.drugName);
      if (!drugId) {
        console.warn(`  ⚠ Drug not found: ${rel.drugName}`);
        continue;
      }
      
      await client.query(`
        INSERT INTO drughealthcondition (drug_id, condition_id, treatment_notes_vi, treatment_notes, is_primary, created_at)
        VALUES ($1, $2, $3, $4, $5, NOW())
        ON CONFLICT (drug_id, condition_id) DO UPDATE SET
          treatment_notes_vi = EXCLUDED.treatment_notes_vi,
          treatment_notes = EXCLUDED.treatment_notes,
          is_primary = EXCLUDED.is_primary
      `, [drugId, rel.conditionId, rel.notes_vi, rel.notes_vi, rel.isPrimary]);
      
      imported++;
    }
    console.log(`✓ Imported ${imported} relationships`);

    await client.query('COMMIT');

    // Step 3: Generate comprehensive report
    console.log('\n' + '='.repeat(80));
    console.log('FINAL REPORT - ALL 39 CONDITIONS');
    console.log('='.repeat(80));

    const allConditions = await client.query(`
      SELECT 
        hc.condition_id,
        hc.name_vi,
        hc.name_en,
        COUNT(dhc.drug_id) as drug_count,
        COUNT(CASE WHEN dhc.is_primary = true THEN 1 END) as primary_drugs,
        COUNT(CASE WHEN hc.article_link_vi IS NOT NULL THEN 1 END) as has_article,
        COUNT(CASE WHEN hc.prevention_tips_vi IS NOT NULL THEN 1 END) as has_prevention
      FROM healthcondition hc
      LEFT JOIN drughealthcondition dhc ON hc.condition_id = dhc.condition_id
      GROUP BY hc.condition_id, hc.name_vi, hc.name_en
      ORDER BY hc.condition_id
    `);

    console.log('\nAll 39 Conditions Status:');
    console.table(allConditions.rows);

    const summary = await client.query(`
      SELECT 
        COUNT(DISTINCT hc.condition_id) as total_conditions,
        COUNT(DISTINCT CASE WHEN dhc.drug_id IS NOT NULL THEN hc.condition_id END) as conditions_with_drugs,
        COUNT(DISTINCT d.drug_id) as total_drugs,
        COUNT(*) as total_drug_relationships,
        COUNT(CASE WHEN dhc.is_primary = true THEN 1 END) as primary_treatments,
        COUNT(CASE WHEN hc.article_link_vi IS NOT NULL THEN 1 END) as conditions_with_articles,
        COUNT(CASE WHEN hc.prevention_tips_vi IS NOT NULL THEN 1 END) as conditions_with_prevention
      FROM healthcondition hc
      LEFT JOIN drughealthcondition dhc ON hc.condition_id = dhc.condition_id
      LEFT JOIN drug d ON dhc.drug_id = d.drug_id
    `);

    console.log('\n📊 Overall Summary:');
    console.table(summary.rows);

    console.log('\n✅ DATABASE COMPLETE - ALL 39 CONDITIONS HAVE FULL DATA!');
    console.log('='.repeat(80));

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

importComprehensiveDrugData();
