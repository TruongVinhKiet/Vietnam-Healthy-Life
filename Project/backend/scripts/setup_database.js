const fs = require("fs");
const path = require("path");
const db = require("../db");

async function setupDatabase() {
  try {
    console.log("Reading schema.sql...");
    const schemaPath = path.join(__dirname, "..", "migrations", "schema.sql");
    const sql = fs.readFileSync(schemaPath, "utf8");

    console.log("Executing schema.sql...");
    await db.query(sql);

    console.log("✅ Database setup completed successfully!");
    console.log("All tables, functions, and triggers have been created.");

    process.exit(0);
  } catch (error) {
    console.error("❌ Error setting up database:", error.message);
    console.error(error);
    process.exit(1);
  }
}

setupDatabase();
