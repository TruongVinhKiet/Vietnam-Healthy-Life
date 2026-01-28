require("dotenv").config();
const express = require("express");
const cors = require("cors");
const db = require("../db");

const authRoutes = require("../routes/auth");
const adminRoutes = require("../routes/admin");
const settingsRoutes = require("../routes/settings");
const mealsRoutes = require("../routes/meals");
const waterRoutes = require("../routes/water");
const vitaminsRoutes = require("../routes/vitamins");
const mineralsRoutes = require("../routes/minerals");
const aminoRoutes = require("../routes/amino_acids");
const fibersRoutes = require("../routes/fibers");
const fattyRoutes = require("../routes/fatty_acids");
const mealTargetsRoutes = require("../routes/mealTargets");
const mealEntriesRoutes = require("../routes/mealEntries");
const nutrientTrackingRoutes = require("../routes/nutrientTracking");
const foodRoutes = require("../routes/foodRoutes");
const mealHistoryRoutes = require("../routes/mealHistoryRoutes");
const portionRoutes = require("../routes/portionRoutes");
const recipeRoutes = require("../routes/recipeRoutes");
const mealTemplateRoutes = require("../routes/mealTemplateRoutes");
const dishRoutes = require("../routes/dishes");
const publicFoodRoutes = require("../routes/foods");
const chatRoutes = require("../routes/chatRoutes");
const socialRoutes = require("../routes/socialRoutes");
const debugRoutes = require("../routes/debugRoutes");
const healthRoutes = require("../routes/health");
const aiAnalysisRoutes = require("../routes/aiAnalysis");
const uploadRoutes = require("../routes/upload");

// ensure Admin table exists (no default admin created)
async function ensureAdmin() {
  try {
    await db.query(`CREATE TABLE IF NOT EXISTS admin (
      admin_id SERIAL PRIMARY KEY,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
    )`);

    // table to hold pending admin registrations with verification codes
    await db.query(`CREATE TABLE IF NOT EXISTS admin_verification (
      verification_id SERIAL PRIMARY KEY,
      username TEXT NOT NULL,
      password_hash TEXT NOT NULL,
      code TEXT NOT NULL,
      expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
      created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
    )`);
    console.log("Ensured admin table exists (no default admin inserted)");
  } catch (err) {
    console.error("Error ensuring Admin table:", err);
  }
}

// Ensure profile columns exist on the User table (add missing columns introduced by newer client)
async function ensureUserProfileColumns() {
  try {
    // Add any new columns used by the app if they do not already exist
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS activity_level TEXT`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS diet_type TEXT`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS allergies TEXT`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS health_goals TEXT`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS goal_type TEXT`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS goal_weight NUMERIC`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS activity_factor NUMERIC`
    );
    await db.query(`ALTER TABLE "User" ADD COLUMN IF NOT EXISTS bmr NUMERIC`);
    await db.query(`ALTER TABLE "User" ADD COLUMN IF NOT EXISTS tdee NUMERIC`);
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS daily_calorie_target NUMERIC`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS daily_protein_target NUMERIC`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS daily_fat_target NUMERIC`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS daily_carb_target NUMERIC`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS daily_water_target NUMERIC`
    );
    await db.query(
      `ALTER TABLE "User" ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ`
    );
    console.log("Ensured User profile columns exist");
  } catch (err) {
    console.error("Error ensuring User profile columns:", err);
  }
}

// ensure WaterLog and DailySummary water column exists
async function ensureWaterInfrastructure() {
  try {
    await db.query(`CREATE TABLE IF NOT EXISTS WaterLog (
      water_log_id SERIAL PRIMARY KEY,
      user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
      amount_ml NUMERIC NOT NULL,
      log_date DATE NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    )`);
    // ensure DailySummary has total_water
    await db.query(
      `ALTER TABLE DailySummary ADD COLUMN IF NOT EXISTS total_water NUMERIC(10,2) DEFAULT 0`
    );
    // ensure unique index on (user_id, date) so ON CONFLICT upserts work
    await db.query(
      `CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_summary_user_date ON DailySummary(user_id, date)`
    );
    console.log(
      "Ensured WaterLog table, DailySummary.total_water and unique index exist"
    );
  } catch (err) {
    console.error("Error ensuring water infrastructure:", err);
  }
}

// Ensure meal tables exist (user_meal_targets, meal_entries, user_meal_summaries)
async function ensureMealTables() {
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS user_meal_targets (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
        target_date DATE NOT NULL DEFAULT CURRENT_DATE,
        meal_type VARCHAR(16) NOT NULL,
        target_kcal NUMERIC(10,2) DEFAULT 0,
        target_carbs NUMERIC(10,2) DEFAULT 0,
        target_protein NUMERIC(10,2) DEFAULT 0,
        target_fat NUMERIC(10,2) DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT now(),
        updated_at TIMESTAMPTZ DEFAULT now()
      );
      CREATE UNIQUE INDEX IF NOT EXISTS ux_user_meal_targets_user_date_meal ON user_meal_targets(user_id, target_date, meal_type);

      CREATE TABLE IF NOT EXISTS meal_entries (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
        entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
        meal_type VARCHAR(16) NOT NULL,
        food_id INTEGER,
        weight_g NUMERIC(10,2),
        kcal NUMERIC(10,2) DEFAULT 0,
        carbs NUMERIC(10,2) DEFAULT 0,
        protein NUMERIC(10,2) DEFAULT 0,
        fat NUMERIC(10,2) DEFAULT 0,
        created_at TIMESTAMPTZ DEFAULT now()
      );

      CREATE TABLE IF NOT EXISTS user_meal_summaries (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
        summary_date DATE NOT NULL DEFAULT CURRENT_DATE,
        meal_type VARCHAR(16) NOT NULL,
        consumed_kcal NUMERIC(12,2) DEFAULT 0,
        consumed_carbs NUMERIC(12,2) DEFAULT 0,
        consumed_protein NUMERIC(12,2) DEFAULT 0,
        consumed_fat NUMERIC(12,2) DEFAULT 0,
        updated_at TIMESTAMPTZ DEFAULT now()
      );
    `);
    console.log(
      "Ensured meal tables exist (user_meal_targets, meal_entries, user_meal_summaries)"
    );
  } catch (err) {
    console.error("Error ensuring meal tables:", err);
  }
}

// Ensure dish soft-delete column exists (is_deleted)
async function ensureDishSoftDeleteColumn() {
  try {
    await db.query(`ALTER TABLE dish ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE`);
    console.log('Ensured dish.is_deleted column exists');
  } catch (err) {
    console.error('Error ensuring dish.is_deleted column:', err);
  }
}

// Ensure UserSetting table and required columns exist
async function ensureUserSettingsTable() {
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS UserSetting (
        user_id INT PRIMARY KEY REFERENCES "User"(user_id) ON DELETE CASCADE,
        theme VARCHAR(50) DEFAULT 'default',
        language VARCHAR(20) DEFAULT 'vi',
        font_size NUMERIC(4,2) DEFAULT 14,
        unit_system VARCHAR(20) DEFAULT 'metric',
        seasonal_ui_enabled BOOLEAN DEFAULT FALSE,
        seasonal_mode VARCHAR(50),
        seasonal_custom_bg TEXT,
        falling_leaves_enabled BOOLEAN DEFAULT FALSE,
        weather_enabled BOOLEAN DEFAULT FALSE,
        weather_effects_enabled BOOLEAN DEFAULT FALSE,
        weather_city VARCHAR(200),
        weather_last_update TIMESTAMPTZ,
        weather_last_data JSONB,
        background_image_url TEXT,
        background_image_enabled BOOLEAN DEFAULT FALSE,
        effect_intensity NUMERIC(5,2) DEFAULT 1.0,
        wind_direction VARCHAR(20),
        calorie_multiplier NUMERIC(6,3) DEFAULT 1.0,
        macro_protein_pct NUMERIC(5,2) DEFAULT 20.0,
        macro_fat_pct NUMERIC(5,2) DEFAULT 30.0,
        macro_carb_pct NUMERIC(5,2) DEFAULT 50.0,
        meal_pct_breakfast NUMERIC(5,2) DEFAULT 25.0,
        meal_pct_lunch NUMERIC(5,2) DEFAULT 35.0,
        meal_pct_snack NUMERIC(5,2) DEFAULT 10.0,
        meal_pct_dinner NUMERIC(5,2) DEFAULT 30.0,
        meal_time_breakfast TIME DEFAULT '07:00:00',
        meal_time_lunch TIME DEFAULT '11:00:00',
        meal_time_snack TIME DEFAULT '13:00:00',
        meal_time_dinner TIME DEFAULT '18:00:00',
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      )
    `);

    const columns = [
      ["theme", "VARCHAR(50) DEFAULT 'default'"],
      ["language", "VARCHAR(20) DEFAULT 'vi'"],
      ["font_size", "NUMERIC(4,2) DEFAULT 14"],
      ["unit_system", "VARCHAR(20) DEFAULT 'metric'"],
      ["seasonal_ui_enabled", "BOOLEAN DEFAULT FALSE"],
      ["seasonal_mode", "VARCHAR(50)"],
      ["seasonal_custom_bg", "TEXT"],
      ["falling_leaves_enabled", "BOOLEAN DEFAULT FALSE"],
      ["weather_enabled", "BOOLEAN DEFAULT FALSE"],
      ["weather_effects_enabled", "BOOLEAN DEFAULT FALSE"],
      ["weather_city", "VARCHAR(200)"],
      ["weather_last_update", "TIMESTAMPTZ"],
      ["weather_last_data", "JSONB"],
      ["background_image_url", "TEXT"],
      ["background_image_enabled", "BOOLEAN DEFAULT FALSE"],
      ["effect_intensity", "NUMERIC(5,2) DEFAULT 1.0"],
      ["wind_direction", "VARCHAR(20)"],
      ["calorie_multiplier", "NUMERIC(6,3) DEFAULT 1.0"],
      ["macro_protein_pct", "NUMERIC(5,2) DEFAULT 20.0"],
      ["macro_fat_pct", "NUMERIC(5,2) DEFAULT 30.0"],
      ["macro_carb_pct", "NUMERIC(5,2) DEFAULT 50.0"],
      ["meal_pct_breakfast", "NUMERIC(5,2) DEFAULT 25.0"],
      ["meal_pct_lunch", "NUMERIC(5,2) DEFAULT 35.0"],
      ["meal_pct_snack", "NUMERIC(5,2) DEFAULT 10.0"],
      ["meal_pct_dinner", "NUMERIC(5,2) DEFAULT 30.0"],
      ["meal_time_breakfast", "TIME DEFAULT '07:00:00'"],
      ["meal_time_lunch", "TIME DEFAULT '11:00:00'"],
      ["meal_time_snack", "TIME DEFAULT '13:00:00'"],
      ["meal_time_dinner", "TIME DEFAULT '18:00:00'"],
    ];

    for (const [name, definition] of columns) {
      await db.query(
        `ALTER TABLE UserSetting ADD COLUMN IF NOT EXISTS ${name} ${definition}`
      );
    }

    await db.query(`
      INSERT INTO UserSetting (user_id)
      SELECT u.user_id
      FROM "User" u
      WHERE NOT EXISTS (
        SELECT 1 FROM UserSetting s WHERE s.user_id = u.user_id
      )
    `);

    console.log("Ensured UserSetting table and columns exist");
  } catch (err) {
    console.error("Error ensuring UserSetting table/columns:", err);
  }
}

async function ensureManualNutritionLogTable() {
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS UserNutrientManualLog (
        log_id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
        log_date DATE NOT NULL DEFAULT CURRENT_DATE,
        nutrient_id INT NOT NULL,
        nutrient_type VARCHAR(20) NOT NULL,
        nutrient_code VARCHAR(50) NOT NULL,
        nutrient_name VARCHAR(150),
        unit VARCHAR(20),
        amount NUMERIC(14,4) NOT NULL DEFAULT 0,
        source VARCHAR(30),
        source_ref TEXT,
        metadata JSONB,
        created_at TIMESTAMPTZ DEFAULT NOW(),
        updated_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);

    // Add unique constraint (not just index) so ON CONFLICT works
    await db.query(`
      DO $$ BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint 
          WHERE conname = 'ux_manual_nutrient_user_date_nutrient_type'
          AND conrelid = 'UserNutrientManualLog'::regclass
        ) THEN
          ALTER TABLE UserNutrientManualLog 
          ADD CONSTRAINT ux_manual_nutrient_user_date_nutrient_type 
          UNIQUE (user_id, log_date, nutrient_id, nutrient_type);
        END IF;
      END $$;
    `);

    await db.query(`
      CREATE INDEX IF NOT EXISTS idx_manual_nutrient_date
      ON UserNutrientManualLog(log_date)
    `);

    console.log("Ensured UserNutrientManualLog table exists");
  } catch (err) {
    console.error("Error ensuring UserNutrientManualLog table:", err);
  }
}

async function ensureHealthAndMedicationTables() {
  try {
    // Create healthcondition table
    await db.query(`
      CREATE TABLE IF NOT EXISTS healthcondition (
        condition_id SERIAL PRIMARY KEY,
        condition_code VARCHAR(50) UNIQUE,
        condition_name VARCHAR(200) NOT NULL,
        description TEXT,
        category VARCHAR(100),
        severity_level VARCHAR(20),
        icd_code VARCHAR(20),
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Create userhealthcondition table
    await db.query(`
      CREATE TABLE IF NOT EXISTS userhealthcondition (
        user_condition_id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
        condition_id INT NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
        diagnosed_date DATE,
        status VARCHAR(20) DEFAULT 'active',
        severity VARCHAR(20),
        notes TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_id, condition_id)
      )
    `);

    // Add diagnosed_date column if it doesn't exist (fix for diagnosis_date error)
    await db.query(`
      ALTER TABLE userhealthcondition 
      ADD COLUMN IF NOT EXISTS diagnosed_date DATE
    `);

    // Add missing columns to healthcondition if they don't exist
    await db.query(`
      ALTER TABLE healthcondition 
      ADD COLUMN IF NOT EXISTS condition_code VARCHAR(50)
    `);
    
    await db.query(`
      ALTER TABLE healthcondition 
      ADD COLUMN IF NOT EXISTS condition_name VARCHAR(200)
    `);
    
    await db.query(`
      ALTER TABLE healthcondition 
      ADD COLUMN IF NOT EXISTS name_vi VARCHAR(200)
    `);
    
    await db.query(`
      ALTER TABLE healthcondition 
      ADD COLUMN IF NOT EXISTS description_vi TEXT
    `);

    // Create usermedication table
    await db.query(`
      CREATE TABLE IF NOT EXISTS usermedication (
        user_medication_id SERIAL PRIMARY KEY,
        user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
        medication_name VARCHAR(200) NOT NULL,
        dosage VARCHAR(100),
        frequency VARCHAR(100),
        start_date DATE,
        end_date DATE,
        status VARCHAR(20) DEFAULT 'active',
        notes TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Create medicationlog table
    await db.query(`
      CREATE TABLE IF NOT EXISTS medicationlog (
        log_id SERIAL PRIMARY KEY,
        user_medication_id INT NOT NULL REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
        medication_date DATE NOT NULL,
        time_scheduled TIME,
        time_taken TIME,
        status VARCHAR(20) DEFAULT 'pending',
        notes TEXT,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);

    // Create medicationschedule table
    await db.query(`
      CREATE TABLE IF NOT EXISTS medicationschedule (
        schedule_id SERIAL PRIMARY KEY,
        user_medication_id INT NOT NULL REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
        time_of_day TIME NOT NULL,
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(user_medication_id, time_of_day)
      )
    `);

    // Add missing columns to medicationlog if they don't exist
    await db.query(`
      ALTER TABLE medicationlog 
      ADD COLUMN IF NOT EXISTS user_medication_id INT
    `);
    
    await db.query(`
      ALTER TABLE medicationlog 
      ADD COLUMN IF NOT EXISTS medication_date DATE
    `);

    // Create indexes only if columns exist
    await db.query(`CREATE INDEX IF NOT EXISTS idx_healthcondition_name ON healthcondition(condition_name)`);
    await db.query(`CREATE INDEX IF NOT EXISTS idx_userhealthcondition_user ON userhealthcondition(user_id)`);
    await db.query(`CREATE INDEX IF NOT EXISTS idx_usermedication_user ON usermedication(user_id)`);
    
    // Check if medicationlog has the required columns before creating index
    const checkMedicationLog = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'medicationlog' 
      AND column_name IN ('user_medication_id', 'medication_date')
    `);
    
    if (checkMedicationLog.rows.length === 2) {
      await db.query(`CREATE INDEX IF NOT EXISTS idx_medicationlog_user_date ON medicationlog(user_medication_id, medication_date)`);
    }

    console.log("Ensured health and medication tables exist");
  } catch (err) {
    console.error("Error ensuring health and medication tables:", err);
  }
}

const app = express();

// Enable JSON parsing with larger limit for image uploads
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ limit: "50mb", extended: true }));

// Enable CORS
app.use(cors());

// Serve static files (uploaded images)
app.use("/uploads", express.static("uploads"));

// Health check
app.get("/health", (req, res) => res.json({ status: "ok" }));

// List users (limit 100)
app.get("/users", async (req, res) => {
  try {
    const result = await db.query(
      'SELECT user_id, full_name, email, age, gender, height_cm, weight_kg, created_at FROM "User" ORDER BY user_id LIMIT $1',
      [100]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "DB error" });
  }
});

// Get user by id
app.get("/users/:id", async (req, res) => {
  const id = parseInt(req.params.id, 10);
  if (Number.isNaN(id)) return res.status(400).json({ error: "invalid id" });
  try {
    const result = await db.query(
      'SELECT user_id, full_name, email, age, gender, height_cm, weight_kg, created_at FROM "User" WHERE user_id = $1',
      [id]
    );
    if (result.rows.length === 0)
      return res.status(404).json({ error: "Not found" });
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "DB error" });
  }
});

// Create user (minimal)
// Legacy simple user endpoint kept for compatibility (optional)
app.post("/users", async (req, res) => {
  const { full_name, email, password, age, gender, height_cm, weight_kg } =
    req.body;
  if (!email || !password)
    return res.status(400).json({ error: "email and password required" });

  try {
    const bcrypt = require("bcryptjs");
    const hashed = await bcrypt.hash(password, 10);
    const q = `INSERT INTO "User" (full_name, email, password_hash, age, gender, height_cm, weight_kg) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING user_id, full_name, email, age, gender, height_cm, weight_kg, created_at`;
    const values = [
      full_name || null,
      email,
      hashed,
      age || null,
      gender || null,
      height_cm || null,
      weight_kg || null,
    ];
    const result = await db.query(q, values);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    if (err.code === "23505") {
      // unique_violation
      return res.status(409).json({ error: "Email already exists" });
    }
    res.status(500).json({ error: "DB error" });
  }
});

// mount auth routes
app.use("/auth", authRoutes);
// mount admin routes (example admin-protected endpoints)
app.use("/admin", adminRoutes);
// admin chat routes
const adminChatRoutes = require("../routes/adminChat");
app.use("/admin/chat", adminChatRoutes);
// mount user settings routes
app.use("/settings", settingsRoutes);
// mount meals routes (meal creation / meal items)
app.use("/meals", mealsRoutes);
// mount water logging route
app.use("/water", waterRoutes);
// vitamins (list + per-user recommended amounts if authorized)
app.use("/vitamins", vitaminsRoutes);
// minerals (mirrors vitamins endpoints)
app.use("/minerals", mineralsRoutes);
// amino acids
app.use("/amino_acids", aminoRoutes);
// fibers (dietary fiber totals and details)
app.use("/fibers", fibersRoutes);
// fatty acids (total + per-item recommendations)
app.use("/fatty-acids", fattyRoutes);
// meal targets (per-day per-meal targets)
app.use("/meal-targets", mealTargetsRoutes);
// meal entries (detailed + action)
app.use("/meal-entries", mealEntriesRoutes);
// nutrient tracking and notifications
app.use("/nutrients", nutrientTrackingRoutes);
// food management (admin routes)
app.use("/admin/foods", foodRoutes);
// meal history and quick add
app.use("/meal-history", mealHistoryRoutes);
// portion size helper
app.use("/portions", portionRoutes);
// recipe builder
app.use("/recipes", recipeRoutes);
// meal templates
app.use("/meal-templates", mealTemplateRoutes);
// dish management
app.use("/dishes", dishRoutes);

// --- Redundant explicit admin delete route (diagnostic + fallback) ---
// Some environments/proxies can cause method/route mismatches; keep an
// explicit handler to ensure admin delete requests are logged and handled.
try {
  const adminMiddleware = require('../utils/adminMiddleware');
  const { requireRole } = require('../utils/roleMiddleware');
  const dishController = require('../controllers/dishController');

  app.delete(
    '/dishes/admin/:id',
    adminMiddleware,
    requireRole(['super_admin', 'content_manager', 'analyst']),
    async (req, res) => {
      console.log('[fallback delete] Admin delete called for dish id=', req.params.id);
      // Delegate to controller
      return dishController.deleteDish(req, res);
    }
  );
} catch (e) {
  console.error('[others/index] Failed to install fallback admin delete route:', e);
}
// public food search
app.use("/foods", publicFoodRoutes);
// chat system (chatbot + admin messaging)
app.use("/chat", chatRoutes);
app.use("/social", socialRoutes);
// Dev debug endpoints (no auth) - remove in production
app.use("/debug", debugRoutes);
// health conditions management
app.use("/health", healthRoutes);
// AI image analysis
app.use("/api", aiAnalysisRoutes);
// Upload background image
app.use("/upload", uploadRoutes);
// drug and medication management
const drugRoutes = require("../routes/drugs");
app.use("/api/medications", drugRoutes);

// Advanced feature routes
const suggestionsRoutes = require("../routes/suggestions");
const portionsAPIRoutes = require("../routes/portions");
const recipesAPIRoutes = require("../routes/recipes");
const fiberRoutes = require("../routes/fiber");
const permissionsRoutes = require("../routes/permissions");
const smartSuggestionRoutes = require("../routes/smartSuggestionRoutes");

app.use("/api/suggestions", suggestionsRoutes);
app.use("/api/smart-suggestions", smartSuggestionRoutes);
// Daily meal suggestions (full day meal planning)
const dailyMealSuggestionRoutes = require("../routes/dailyMealSuggestions");
app.use("/api/suggestions/daily-meals", dailyMealSuggestionRoutes);
app.use("/api/portions", portionsAPIRoutes);
app.use("/api/recipes", recipesAPIRoutes);
app.use("/api/fiber", fiberRoutes);
app.use("/api/permissions", permissionsRoutes);
// body measurement tracking
const bodyMeasurementController = require("../controllers/bodyMeasurementController");
const authMiddleware = require("../utils/authMiddleware");
const bodyMeasurementRoutes = require("express").Router();
bodyMeasurementRoutes.get(
  "/latest",
  authMiddleware,
  bodyMeasurementController.getLatest
);
bodyMeasurementRoutes.get(
  "/history",
  authMiddleware,
  bodyMeasurementController.getHistory
);
bodyMeasurementRoutes.get(
  "/statistics",
  authMiddleware,
  bodyMeasurementController.getStatistics
);
bodyMeasurementRoutes.post(
  "/",
  authMiddleware,
  bodyMeasurementController.addMeasurement
);
app.use("/body-measurement", bodyMeasurementRoutes);

// health condition management
const healthConditionController = require("../controllers/healthConditionController");
const medicationController = require("../controllers/medicationController");
const healthConditionRoutes = require("express").Router();
const medicationRoutes = require("express").Router();
// admin endpoints
healthConditionRoutes.get(
  "/conditions",
  healthConditionController.getAllConditions
);
healthConditionRoutes.get(
  "/conditions/:id",
  healthConditionController.getConditionById
);
healthConditionRoutes.post(
  "/conditions",
  healthConditionController.createCondition
);
healthConditionRoutes.put(
  "/conditions/:id",
  healthConditionController.updateCondition
);
healthConditionRoutes.delete(
  "/conditions/:id",
  healthConditionController.deleteCondition
);
healthConditionRoutes.post(
  "/conditions/:id/nutrient-effects",
  healthConditionController.addNutrientEffect
);
healthConditionRoutes.post(
  "/conditions/:id/food-restrictions",
  healthConditionController.addFoodRestriction
);
// user endpoints (auth required)
healthConditionRoutes.get(
  "/user/conditions",
  authMiddleware,
  healthConditionController.getUserConditions
);
healthConditionRoutes.post(
  "/user/conditions",
  authMiddleware,
  healthConditionController.addUserCondition
);
healthConditionRoutes.put(
  "/user/conditions/:id/status",
  authMiddleware,
  healthConditionController.updateUserConditionStatus
);
healthConditionRoutes.patch(
  "/user/conditions/:id/extend",
  authMiddleware,
  healthConditionController.extendTreatment
);
healthConditionRoutes.patch(
  "/user/conditions/:id/recover",
  authMiddleware,
  healthConditionController.markRecovered
);
healthConditionRoutes.get(
  "/user/adjusted-rda",
  authMiddleware,
  healthConditionController.getAdjustedRDA
);
healthConditionRoutes.get(
  "/user/restricted-foods",
  authMiddleware,
  healthConditionController.getRestrictedFoods
);
app.use("/health", healthConditionRoutes);

// medication tracking
medicationRoutes.get(
  "/today",
  authMiddleware,
  medicationController.getTodayMedication
);
medicationRoutes.get(
  "/statistics",
  authMiddleware,
  medicationController.getMedicationStatistics
);
medicationRoutes.get(
  "/logs",
  authMiddleware,
  medicationController.getMedicationLogs
);
medicationRoutes.post(
  "/taken",
  authMiddleware,
  medicationController.markMedicationTaken
);
medicationRoutes.get(
  "/calendar-dates",
  authMiddleware,
  medicationController.getMedicationDates
);
app.use("/medications", medicationRoutes);

// create admin table + default admin on startup
ensureAdmin().catch((err) => console.error(err));
// ensure user profile columns exist (safe to call on every startup)
ensureUserProfileColumns().catch((err) => console.error(err));
// ensure water infra exists
ensureWaterInfrastructure().catch((err) => console.error(err));
// ensure meal tables exist
ensureMealTables().catch((err) => console.error(err));
// ensure user setting table/columns exist
ensureUserSettingsTable().catch((err) => console.error(err));
// ensure manual nutrient log table exists
ensureManualNutritionLogTable().catch((err) => console.error(err));
// ensure health and medication tables exist
ensureHealthAndMedicationTables().catch((err) => console.error(err));
// ensure dish soft-delete column exists
ensureDishSoftDeleteColumn().catch((err) => console.error(err));

const port = process.env.PORT || 60491;
const host = process.env.HOST || '0.0.0.0'; // Listen on all network interfaces
app.listen(port, host, () => {
  console.log(`Server listening on ${host}:${port}`);
  console.log(`Access from emulator: http://10.0.2.2:${port}`);
  console.log(`Access from local network: http://<your-ip>:${port}`);
});
