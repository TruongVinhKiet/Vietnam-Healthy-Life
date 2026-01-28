# Nutrient API – Tổng hợp yêu cầu cần bổ sung

## 1. Hiện trạng
- Các route nutrient hiện tại (vitamins, minerals, amino_acids, fatty_acids, fibers, fiber) **chỉ hỗ trợ GET** (lấy danh sách, lấy chi tiết, lấy RDA), **không có POST/PUT/DELETE** để tạo, cập nhật, xóa nutrient.
- Không có endpoint quản trị (admin) cho việc thêm/sửa/xóa nutrient.

## 2. Yêu cầu cần bổ sung cho AI/web admin
### a. Endpoint cần có
- **Tạo mới nutrient**: POST /admin/vitamins, /admin/minerals, /admin/amino_acids, /admin/fatty_acids, /admin/fibers
- **Cập nhật nutrient**: PUT /admin/vitamins/:id, ...
- **Xóa nutrient**: DELETE /admin/vitamins/:id, ...

### b. Trường dữ liệu cần thiết (payload)
- name (tên)
- code (mã, nếu có)
- unit (đơn vị)
- category/type (loại)
- description (mô tả, nếu có)
- rda (giá trị khuyến nghị, nếu có)

### c. Yêu cầu khác
- Có xác thực (auth) cho các endpoint admin
- Có validate dữ liệu đầu vào
- Có log/audit khi thêm/sửa/xóa

## 3. Ghi chú
- Khi bổ sung backend, cần cập nhật cả tài liệu API cho frontend/dev sử dụng.
- Nên chuẩn hóa các trường dữ liệu giữa các loại nutrient.

---
**File này dùng để tổng hợp các yêu cầu về nutrient API cho AI/web admin, sẽ cập nhật tiếp khi có thêm yêu cầu.**
