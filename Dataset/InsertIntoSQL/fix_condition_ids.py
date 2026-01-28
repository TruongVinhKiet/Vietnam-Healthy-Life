# -*- coding: utf-8 -*-
import re

# Đọc file real_dataset_vietnam.sql
with open('real_dataset_vietnam.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# Mapping ID cũ sang ID mới (1001->11, 1002->12, ...)
id_mapping = {
    1001: 11, 1002: 12, 1003: 13, 1004: 14, 1005: 15, 
    1006: 16, 1007: 17, 1008: 18, 1009: 19, 1010: 20,
    1011: 21, 1012: 22, 1013: 23, 1014: 24, 1015: 25,
    1016: 26, 1017: 27, 1018: 28, 1019: 29, 1020: 30,
    1021: 31, 1022: 32, 1023: 33, 1024: 34, 1032: 35,
    1037: 36, 1080: 37, 1081: 38, 1088: 39
}

# Thay thế trong phần INSERT healthcondition
for old_id, new_id in id_mapping.items():
    # Thay trong INSERT VALUES
    content = re.sub(
        rf'\({old_id},',
        f'({new_id},',
        content
    )

# Thay thế trong phần drughealthcondition
for old_id, new_id in id_mapping.items():
    # Pattern: (drug_id, condition_id, ...)
    # Tìm các dòng có condition_id cũ
    content = re.sub(
        rf'(\([0-9]+, ){old_id}(,)',
        rf'\g<1>{new_id}\g<2>',
        content
    )

with open('real_dataset_vietnam.sql', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Đã sửa condition_id từ 1001-1088 sang 11-39")
print("\nMapping:")
for old_id, new_id in sorted(id_mapping.items()):
    print(f"  {old_id} -> {new_id}")
