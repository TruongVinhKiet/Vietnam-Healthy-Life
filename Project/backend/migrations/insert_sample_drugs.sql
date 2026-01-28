-- Insert sample drugs
INSERT INTO Drug (name_vi, name_en, generic_name, drug_class, description_vi, description_en)
VALUES 
  ('Paracetamol', 'Paracetamol', 'Acetaminophen', 'Analgesic', 'Thuốc giảm đau hạ sốt', 'Pain reliever and fever reducer'),
  ('Ibuprofen', 'Ibuprofen', 'Ibuprofen', 'NSAID', 'Thuốc chống viêm không steroid', 'Nonsteroidal anti-inflammatory drug'),
  ('Amoxicillin', 'Amoxicillin', 'Amoxicillin', 'Antibiotic', 'Kháng sinh nhóm penicillin', 'Penicillin antibiotic'),
  ('Vitamin C', 'Vitamin C', 'Ascorbic Acid', 'Vitamin', 'Bổ sung vitamin C', 'Vitamin C supplement'),
  ('Aspirin', 'Aspirin', 'Acetylsalicylic Acid', 'NSAID', 'Thuốc chống viêm và chống đông máu', 'Anti-inflammatory and antiplatelet'),
  ('Metformin', 'Metformin', 'Metformin HCl', 'Antidiabetic', 'Thuốc điều trị tiểu đường type 2', 'Type 2 diabetes medication'),
  ('Omeprazole', 'Omeprazole', 'Omeprazole', 'Proton Pump Inhibitor', 'Thuốc giảm acid dạ dày', 'Reduces stomach acid'),
  ('Cetirizine', 'Cetirizine', 'Cetirizine HCl', 'Antihistamine', 'Thuốc chống dị ứng', 'Antiallergy medication')
ON CONFLICT DO NOTHING;
