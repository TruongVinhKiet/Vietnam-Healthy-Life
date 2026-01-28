#!/usr/bin/env node
require("dotenv").config();
const { Pool } = require("pg");
const fs = require("fs");
const path = require("path");

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Các migration files theo thứ tự ưu tiên
const MIGRATION_ORDER = [
  "schema.sql",
  "Create.sql",
  "create_health_tables.sql",
  "minimal_schema.sql",
  "2025_create_user_meal_tables.sql",
  "2025_create_advanced_tables.sql",
  "2025_dish_management.sql",
  "2025_health_condition_system.sql",
  "2025_add_dish_recommendations.sql",
  "2025_drug_medication_system.sql",
  "2025_chat_system.sql",
  "2025_body_measurement_tracking.sql",
  "2025_water_enhancements.sql",
  "2025_drink_notifications.sql",
  "2025_admin_approval_log.sql",
  "2025_add_fiber_fatty_acids.sql",
  "2025_add_essential_amino_acids.sql",
  "2025_add_macro_columns.sql",
  "2025_add_meal_distribution_columns.sql",
  "2025_add_daily_summary_trigger_for_meal_entries.sql",
  "2025_add_fiber_fatty_trigger_for_meal_entries.sql",
  "2025_rbac_permissions.sql",
  "2025_security_features.sql",
  "2025_user_blocking.sql",
  "2025_add_community_chat_and_social_features.sql",
  "2025_add_activity_log_triggers.sql",
  "2025_add_water_reset_trigger.sql",
  "2025_fix_missing_template_dish_nutrients.sql",
];

async function runMigration(fileName) {
  const filePath = path.join(__dirname, "../migrations", fileName);

  if (!fs.existsSync(filePath)) {
    console.log(`   ⊘ Bỏ qua ${fileName} (không tìm thấy)`);
    return { skipped: true };
  }

  try {
    const sql = fs.readFileSync(filePath, "utf8");

    // Skip empty files
    if (sql.trim().length === 0) {
      console.log(`   ⊘ Bỏ qua ${fileName} (file rỗng)`);
      return { skipped: true };
    }

    await pool.query(sql);
    console.log(`   ✓ ${fileName}`);
    return { success: true };
  } catch (err) {
    // Skip if already exists
    if (
      err.code === "42P07" || // duplicate table
      err.code === "42710" || // duplicate object
      err.code === "42P13" || // cannot change return type
      err.message.includes("already exists")
    ) {
      console.log(`   ⊘ ${fileName} (đã tồn tại)`);
      return { skipped: true };
    }

    console.log(`   ✗ ${fileName}`);
    console.log(`      Lỗi: ${err.message}`);
    return { error: err.message };
  }
}

async function importDatabase() {
  console.log("🚀 Bắt đầu import database từ migrations...\n");

  let successCount = 0;
  let skipCount = 0;
  let errorCount = 0;
  const errors = [];

  for (const fileName of MIGRATION_ORDER) {
    const result = await runMigration(fileName);

    if (result.success) successCount++;
    else if (result.skipped) skipCount++;
    else if (result.error) {
      errorCount++;
      errors.push({ file: fileName, error: result.error });
    }
  }

  console.log(`\n📊 Kết quả:`);
  console.log(`   ✓ Thành công: ${successCount}`);
  console.log(`   ⊘ Bỏ qua: ${skipCount}`);
  console.log(`   ✗ Lỗi: ${errorCount}`);

  if (errors.length > 0 && errors.length <= 5) {
    console.log(`\n⚠️  Chi tiết lỗi:`);
    errors.forEach((e) => {
      console.log(`   - ${e.file}: ${e.error}`);
    });
  }

  if (errorCount === 0) {
    console.log("\n🎉 Import database hoàn tất!");
  } else {
    console.log(
      "\n⚠️  Import hoàn tất với một số lỗi (có thể là do cấu trúc đã tồn tại)"
    );
  }

  pool.end();
}

importDatabase();
