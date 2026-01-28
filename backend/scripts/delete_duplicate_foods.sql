-- Generated: 2025-12-05T07:50:26.023Z
-- Xóa 19 thực phẩm trùng tên không được sử dụng

BEGIN;

DELETE FROM food WHERE food_id IN (23, 21, 39, 20, 22, 18, 25, 24, 42, 28, 29, 59, 27, 30, 35, 32, 33, 72, 97);

-- Verify
SELECT COUNT(*) as deleted_count FROM food WHERE food_id IN (23, 21, 39, 20, 22, 18, 25, 24, 42, 28, 29, 59, 27, 30, 35, 32, 33, 72, 97);

COMMIT;
