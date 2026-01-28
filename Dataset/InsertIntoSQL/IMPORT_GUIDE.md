# HƯỚNG DẪN NHẬP DỮ LIỆU VÀO POSTGRESQL

## Thông tin kết nối
- **Database:** Health
- **Host:** localhost
- **Port:** 5432
- **User:** postgres
- **Password:** Kiet2004

## Cách 1: Sử dụng script tự động (Khuyến nghị)

### Trên Windows:
```cmd
cd "d:\dataset\Dữ liệu mẫu"
import_data.bat
```

### Trên Linux/macOS:
```bash
cd "/d/dataset/Dữ liệu mẫu"
chmod +x import_data.sh
./import_data.sh
```

## Cách 2: Nhập từng file thủ công

### Windows PowerShell:
```powershell
cd "d:\dataset\Dữ liệu mẫu"
$env:PGPASSWORD="Kiet2004"

# 1. Nhập dữ liệu cơ bản
psql -h localhost -p 5432 -U postgres -d Health -f "real_dataset_vietnam.sql"

# 2. Nhập dữ liệu mở rộng
psql -h localhost -p 5432 -U postgres -d Health -f "extended_tables_vietnam.sql"

# 3. Nhập dữ liệu bổ sung
psql -h localhost -p 5432 -U postgres -d Health -f "additional_data_extended.sql"

# 4. Nhập dữ liệu dinh dưỡng món ăn
psql -h localhost -p 5432 -U postgres -d Health -f "dishnutrient_data.sql"

# 5. Nhập dữ liệu dinh dưỡng đồ uống
psql -h localhost -p 5432 -U postgres -d Health -f "drinknutrient_data.sql"
```

### Linux/macOS Terminal:
```bash
cd "/d/dataset/Dữ liệu mẫu"
export PGPASSWORD=Kiet2004

# 1. Nhập dữ liệu cơ bản
psql -h localhost -p 5432 -U postgres -d Health -f "real_dataset_vietnam.sql"

# 2. Nhập dữ liệu mở rộng
psql -h localhost -p 5432 -U postgres -d Health -f "extended_tables_vietnam.sql"

# 3. Nhập dữ liệu bổ sung
psql -h localhost -p 5432 -U postgres -d Health -f "additional_data_extended.sql"

# 4. Nhập dữ liệu dinh dưỡng món ăn
psql -h localhost -p 5432 -U postgres -d Health -f "dishnutrient_data.sql"

# 5. Nhập dữ liệu dinh dưỡng đồ uống
psql -h localhost -p 5432 -U postgres -d Health -f "drinknutrient_data.sql"
```

## Cách 3: Sử dụng pgAdmin hoặc DBeaver

1. Mở pgAdmin/DBeaver
2. Kết nối đến database `Health`
3. Mở Query Tool
4. Load từng file SQL theo thứ tự:
   - real_dataset_vietnam.sql
   - extended_tables_vietnam.sql
   - additional_data_extended.sql
   - dishnutrient_data.sql
   - drinknutrient_data.sql
5. Execute từng file

## Kiểm tra sau khi nhập

```sql
-- Kiểm tra số lượng records trong các bảng
SELECT 'nutrient' as table_name, COUNT(*) as total FROM nutrient
UNION ALL
SELECT 'food', COUNT(*) FROM food
UNION ALL
SELECT 'healthcondition', COUNT(*) FROM healthcondition
UNION ALL
SELECT 'drug', COUNT(*) FROM drug
UNION ALL
SELECT 'dish', COUNT(*) FROM dish
UNION ALL
SELECT 'drink', COUNT(*) FROM drink
UNION ALL
SELECT 'dishnutrient', COUNT(*) FROM dishnutrient
UNION ALL
SELECT 'drinknutrient', COUNT(*) FROM drinknutrient
UNION ALL
SELECT 'foodnutrient', COUNT(*) FROM foodnutrient
UNION ALL
SELECT 'drughealthcondition', COUNT(*) FROM drughealthcondition
UNION ALL
SELECT 'drugnutrientcontraindication', COUNT(*) FROM drugnutrientcontraindication
ORDER BY table_name;
```

## Xử lý lỗi thường gặp

### Lỗi: "column tagname does not exist"
- File `real_dataset_vietnam.sql` có phần UPDATE nutrient bằng tagname
- Nếu bảng nutrient không có cột `tagname`, bạn có thể:
  1. **Bỏ qua lỗi này** - không ảnh hưởng đến các INSERT khác
  2. **Xóa/comment phần UPDATE nutrient** (dòng 27-55 trong file)
  3. **Sửa lại cột đúng** nếu bảng có cột khác (ví dụ: `name`, `nutrient_code`)

### Lỗi: "duplicate key value violates unique constraint"
- Có thể do đã nhập dữ liệu trước đó
- Giải pháp:
  ```sql
  -- Xóa dữ liệu cũ (CẢNH BÁO: Mất hết dữ liệu)
  TRUNCATE TABLE drinknutrient CASCADE;
  TRUNCATE TABLE dishnutrient CASCADE;
  TRUNCATE TABLE foodnutrient CASCADE;
  TRUNCATE TABLE food CASCADE;
  TRUNCATE TABLE drugnutrientcontraindication CASCADE;
  TRUNCATE TABLE drughealthcondition CASCADE;
  TRUNCATE TABLE drug CASCADE;
  TRUNCATE TABLE healthcondition CASCADE;
  -- Sau đó chạy lại script import
  ```

### Lỗi: "permission denied"
- Đảm bảo user `postgres` có quyền INSERT vào database
- Kiểm tra lại password trong file `.env`

## Backup trước khi nhập (Khuyến nghị)

```bash
# Backup database
pg_dump -h localhost -p 5432 -U postgres -d Health -F c -b -v -f "Health_backup_$(date +%Y%m%d_%H%M%S).backup"
```

## Restore nếu có lỗi

```bash
# Restore từ backup
pg_restore -h localhost -p 5432 -U postgres -d Health -v "Health_backup_YYYYMMDD_HHMMSS.backup"
```

## Ghi chú

- Thứ tự nhập file **rất quan trọng** do ràng buộc khóa ngoại
- Script đã có kiểm tra lỗi và dừng nếu có vấn đề
- Thời gian nhập ước tính: 1-3 phút tùy cấu hình máy
- Nên backup database trước khi nhập dữ liệu mẫu

## Hỗ trợ

Nếu gặp lỗi, kiểm tra:
1. PostgreSQL đã chạy chưa: `pg_ctl status`
2. Database `Health` đã tồn tại chưa
3. Các bảng đã được tạo chưa (schema phải có trước)
4. Quyền user postgres có đầy đủ không
