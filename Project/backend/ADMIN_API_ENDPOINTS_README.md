# Danh sách endpoint và payload cho các entity quản trị

## 1. Foods
- **Tạo mới:**
  - Endpoint: `POST /api/foods`
  - Payload mẫu:
    ```json
    {
      "name": "string",                // bắt buộc
      "category": "string",
      "description": "string",
      "image_url": "string",
      "serving_size_g": number,
      "nutrients": [
        { "nutrient_id": number, "amount_per_100g": number }
      ]
    }
    ```
- **Cập nhật:**
  - Endpoint: `PUT /api/foods/:id`
  - Payload: giống như tạo mới

---

## 2. Dishes
- **Tạo mới:**
  - Endpoint: `POST /dishes/admin/create`
  - Payload mẫu:
    ```json
    {
      "name": "string",                // bắt buộc
      "vietnamese_name": "string",
      "category": "string",
      "is_template": boolean,
      "ingredients": [ /* ... */ ],
      "description": "string",
      "image_url": "string"
    }
    ```
- **Cập nhật:**
  - Endpoint: `PUT /dishes/admin/:id`
  - Payload: giống như tạo mới

---

## 3. Drinks
- **Tạo mới:**
  - Endpoint: `POST /drinks/admin`
  - Payload mẫu:
    ```json
    {
      "name": "string",                // bắt buộc
      "vietnamese_name": "string",
      "description": "string",
      "hydration_ratio": number,
      "default_volume_ml": number,
      "category": "string"
    }
    ```
- **Cập nhật:**
  - Endpoint: `PUT /drinks/admin/:id`
  - Payload: giống như tạo mới

---

## 4. Nutrients
Để làm sau chưa cần đụng tới 

---

## 5. Health Conditions
- **Tạo mới:**
  - Endpoint: `POST /health/conditions`
  - Payload mẫu:
    ```json
    {
      "name_vi": "string",             // bắt buộc
      "name_en": "string",
      "category": "string",
      "description": "string",
      "description_vi": "string",
      "causes": "string",
      "treatment_duration_reference": "string",
      "image_url": "string",
      "article_link_vi": "string",
      "article_link_en": "string",
      "prevention_tips_vi": "string",
      "prevention_tips": "string",
      "severity_level": "string",
      "is_chronic": boolean
    }
    ```
- **Cập nhật:**
  - Endpoint: `PUT /health/conditions/:id`
  - Payload: giống như tạo mới

---

## 6. Drugs
- **Tạo mới:**
  - Endpoint: `POST /api/admin/drugs`
  - Payload mẫu:
    ```json
    {
      "name_vi": "string",             // bắt buộc
      "name_en": "string",
      "generic_name": "string",
      "drug_class": "string",
      "description": "string",
      "image_url": "string",
      "source_link": "string",
      "dosage_form": "string",
      "is_active": boolean,
      "condition_ids": [
        {
          "condition_id": number,
          "is_primary": boolean,
          "treatment_notes": "string"
        }
      ],
      "contraindications": [
        {
          "nutrient_id": number,
          "avoid_hours_before": number,
          "avoid_hours_after": number,
          "warning_message_vi": "string",
          "warning_message_en": "string",
          "severity": "string"
        }
      ]
    }
    ```
- **Cập nhật:**
  - Endpoint: `PUT /api/admin/drugs/:id`
  - Payload: giống như tạo mới

---

**Lưu ý:**
- Các trường bắt buộc có ghi chú rõ.
- Nếu cần chi tiết validation, kiểm tra lại controller/service backend.
- Nutrients hiện chưa có endpoint tạo/cập nhật, sẽ bổ sung sau.