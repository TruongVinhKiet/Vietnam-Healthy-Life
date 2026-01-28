#!/usr/bin/env node
require("dotenv").config();
const { Pool } = require("pg");
const fs = require("fs");

const pool = new Pool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function importBackup() {
  try {
    console.log("📖 Đọc file backup...");
    let sql = fs.readFileSync("../../HealthBackup_Plain.sql", "utf8");

    // Remove comment lines and psql meta commands
    console.log("🔧 Xử lý file SQL...");
    const lines = sql.split("\n");
    const cleanedLines = [];

    for (const line of lines) {
      const trimmed = line.trim();
      // Skip comments, empty lines, and psql commands
      if (
        trimmed.startsWith("--") ||
        trimmed.startsWith("\\") ||
        trimmed === "" ||
        trimmed.startsWith("SET ") ||
        trimmed.startsWith("SELECT pg_catalog.")
      ) {
        continue;
      }
      cleanedLines.push(line);
    }

    sql = cleanedLines.join("\n");

    // Split into statements (rough split by semicolon at end of line)
    console.log("📝 Tách các SQL statements...");
    const statements = [];
    let currentStatement = "";
    let inFunction = false;
    let dollarQuoteCount = 0;

    for (const line of sql.split("\n")) {
      currentStatement += line + "\n";

      // Track if we're inside a function body
      if (line.includes("$$")) {
        dollarQuoteCount++;
      }

      if (
        line.includes("CREATE OR REPLACE FUNCTION") ||
        line.includes("CREATE FUNCTION")
      ) {
        inFunction = true;
        dollarQuoteCount = 0;
      }

      // End of function when we see closing $$; with even dollar quotes
      if (
        inFunction &&
        line.trim().endsWith("$$;") &&
        dollarQuoteCount % 2 === 0
      ) {
        statements.push(currentStatement.trim());
        currentStatement = "";
        inFunction = false;
        continue;
      }

      // Regular statement end
      if (!inFunction && line.trim().endsWith(";") && !line.includes("$$")) {
        statements.push(currentStatement.trim());
        currentStatement = "";
      }
    }

    console.log(`✅ Tìm thấy ${statements.length} statements`);

    // Execute statements one by one
    console.log("🚀 Bắt đầu import...\n");
    let successCount = 0;
    let skipCount = 0;
    let errorCount = 0;

    for (let i = 0; i < statements.length; i++) {
      const stmt = statements[i];
      if (stmt.length < 10) continue; // Skip very short statements

      // Get statement type for logging
      const stmtType = stmt.substring(0, 50).replace(/\s+/g, " ");

      try {
        // Replace CREATE FUNCTION with CREATE OR REPLACE
        let processedStmt = stmt.replace(
          /CREATE FUNCTION/gi,
          "CREATE OR REPLACE FUNCTION"
        );
        processedStmt = processedStmt.replace(
          /CREATE TABLE/gi,
          "CREATE TABLE IF NOT EXISTS"
        );

        await pool.query(processedStmt);
        successCount++;

        if (successCount % 10 === 0) {
          process.stdout.write(
            `\r✓ Đã xử lý: ${successCount}/${statements.length}`
          );
        }
      } catch (err) {
        // Skip some common errors
        if (
          err.message.includes("already exists") ||
          err.message.includes("does not exist") ||
          err.code === "42P07" || // duplicate table
          err.code === "42710"
        ) {
          // duplicate object
          skipCount++;
        } else {
          errorCount++;
          console.log(`\n⚠️  Lỗi tại statement ${i + 1}:`);
          console.log(`   ${stmtType}...`);
          console.log(`   ${err.message}`);

          if (errorCount > 10) {
            console.log("\n❌ Quá nhiều lỗi, dừng import.");
            break;
          }
        }
      }
    }

    console.log(`\n\n📊 Kết quả:`);
    console.log(`   ✓ Thành công: ${successCount}`);
    console.log(`   ⊘ Bỏ qua: ${skipCount}`);
    console.log(`   ✗ Lỗi: ${errorCount}`);

    if (errorCount === 0) {
      console.log("\n🎉 Import database hoàn tất!");
    }

    pool.end();
  } catch (err) {
    console.error("\n❌ Lỗi nghiêm trọng:", err.message);
    pool.end();
    process.exit(1);
  }
}

importBackup();
