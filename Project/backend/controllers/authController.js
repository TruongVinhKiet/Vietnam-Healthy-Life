const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const db = require("../db");
const userService = require("../services/userService");
const securityService = require("../services/securityService");
const nutrientTrackingService = require("../services/nutrientTrackingService");
const speakeasy = require("speakeasy");
const nodemailer = require("nodemailer");

const JWT_SECRET = process.env.JWT_SECRET || "change_this_secret";
const JWT_EXPIRES_IN = "7d";

function createTransporter() {
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: process.env.SMTP_SECURE === "true",
    auth: process.env.SMTP_USER
      ? { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS }
      : undefined,
  });
}

async function sendMail({ to, subject, html, text }) {
  const smtpHost = process.env.SMTP_HOST;
  if (!smtpHost) {
    console.log("[mail:fallback]", subject, text || html);
    return;
  }
  const transporter = createTransporter();
  await transporter.sendMail({
    from: process.env.SMTP_FROM || "no-reply@vnhl.local",
    to,
    subject,
    text,
    html,
  });
}

function buildEmailTemplate({ title, bodyLines, actionLabel, actionCode }) {
  const bodyHtml = bodyLines
    .map((line) => `<p style="margin:4px 0;color:#1f2937;">${line}</p>`)
    .join("");
  const actionHtml = actionCode
    ? `<div style="margin-top:12px;padding:12px 16px;border-radius:12px;background:#eef2ff;color:#111827;font-weight:700;display:inline-block;letter-spacing:3px;font-size:18px;">
      ${actionCode}
      <div style="font-size:12px;color:#4b5563;margin-top:4px;">${actionLabel || ""}</div>
    </div>`
    : "";
  const footer =
    '<p style="margin-top:16px;font-size:12px;color:#6b7280;">Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email hoặc liên hệ hỗ trợ.</p>';
  return `
  <div style="max-width:520px;margin:auto;padding:20px;font-family:Inter,Roboto,Arial,sans-serif;background:#f9fafb;border-radius:16px;border:1px solid #e5e7eb;">
    <h2 style="margin:0 0 12px;color:#111827;">${title}</h2>
    ${bodyHtml}
    ${actionHtml}
    ${footer}
  </div>`;
}

async function register(req, res) {
  const { full_name, email, password, age, gender, height_cm, weight_kg } =
    req.body;
  if (!email || !password)
    return res.status(400).json({ error: "Email và password là bắt buộc" });
  // Basic validation
  const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
  if (!emailRegex.test(email))
    return res.status(400).json({ error: "Email không hợp lệ" });
  if (typeof password !== "string" || password.length < 6)
    return res.status(400).json({ error: "Password phải ít nhất 6 kí tự" });

  try {
    const existing = await userService.findByEmail(email);
    if (existing)
      return res.status(409).json({ error: "Email đã được sử dụng" });

    const hashed = await bcrypt.hash(password, 10);
    const user = await userService.createUser({
      full_name,
      email,
      password_hash: hashed,
      age,
      gender,
      height_cm,
      weight_kg,
    });

    // Emit real-time event for admin dashboard (new user registered)
    try {
      const eventBus = require("../utils/eventBus");
      eventBus.emit("user_registered", {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        created_at: user.created_at,
      });
    } catch (e) {}

    const token = jwt.sign(
      { user_id: user.user_id, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );
    
    // Log registration activity
    try {
      const db = require("../db");
      await db.query(
        "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
        [user.user_id, "register"]
      );
    } catch (e) {
      console.error("Failed to log register activity", e);
    }
    
    res
      .status(201)
      .json({
        token,
        user: {
          user_id: user.user_id,
          full_name: user.full_name,
          email: user.email,
          age: user.age,
          gender: user.gender,
          height_cm: user.height_cm,
          weight_kg: user.weight_kg,
          avatar_url: user.avatar_url,
        },
      });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Login bằng full_name hoặc email
async function login(req, res) {
  const { identifier, password } = req.body; // identifier có thể là email hoặc full_name
  if (!identifier || !password)
    return res
      .status(400)
      .json({ error: "identifier và password là bắt buộc" });
  if (typeof password !== "string" || password.length === 0)
    return res.status(400).json({ error: "Password là bắt buộc" });

  try {
    const user = await userService.findByEmailOrName(identifier);
    if (!user)
      return res
        .status(401)
        .json({ error: "Không tìm thấy user hoặc sai thông tin" });

    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) {
      // increment failed attempts and possibly block
      try {
        const attempts = await securityService.incrementFailedAttempt(
          user.user_id
        );
        const threshold = await securityService.getLockThreshold(user.user_id);
        if (attempts >= threshold) {
          await securityService.blockUser(
            user.user_id,
            "Too many failed login attempts"
          );
          // create unlock code and email user
          try {
            const { code } = await securityService.createUnlockCode(
              user.user_id,
              900
            );
            const html = buildEmailTemplate({
              title: "Mở khóa tài khoản",
              bodyLines: [
                `Xin chào ${user.full_name || user.email},`,
                "Tài khoản của bạn đã bị khóa do nhập sai mật khẩu nhiều lần.",
                "Nhập mã bên dưới để mở khóa và đăng nhập lại.",
                "Mã có hiệu lực 15 phút.",
              ],
              actionLabel: "Nhập mã trên ứng dụng",
              actionCode: code,
            });
            await sendMail({
              to: user.email,
              subject: "[VietNam Healthy Life] Mã mở khóa tài khoản",
              html,
              text: `Mã mở khóa tài khoản của bạn: ${code}. Mã hết hạn sau 15 phút.`,
            });
          } catch (e) {
            console.error("Failed to send unlock email", e && e.message);
          }
          return res.status(403).json({
            blocked: true,
            unlock_required: true,
            reason: "Quá nhiều lần đăng nhập sai, tài khoản đã bị chặn",
          });
        }
      } catch (e) {
        console.error("Failed to increment failed_attempts", e && e.message);
      }
      return res
        .status(401)
        .json({ error: "Không tìm thấy user hoặc sai thông tin" });
    }

    // Note: Block status check removed - user_account_status table not implemented
    const db = require("../db");

    // Reset failed attempts on successful password
    try {
      await securityService.resetFailedAttempts(user.user_id);
    } catch (e) {}

    // If 2FA enabled, return temp token and require OTP
    try {
      const sec = await securityService.getUserSecurity(user.user_id);
      if (sec && sec.twofa_enabled) {
        const temp_token = jwt.sign(
          { user_id: user.user_id, email: user.email, purpose: "mfa" },
          JWT_SECRET,
          { expiresIn: "5m" }
        );
        return res.json({ mfa_required: true, temp_token });
      }
    } catch (e) {
      console.error("Error checking 2FA status", e && e.message);
    }

    // Update last_login timestamp
    try {
      await db.query(
        'UPDATE "User" SET last_login = now() WHERE user_id = $1',
        [user.user_id]
      );
    } catch (e) {
      console.error("Failed updating last_login", e);
    }

    const token = jwt.sign(
      { user_id: user.user_id, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );
    
    // Log login activity
    try {
      await db.query(
        "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
        [user.user_id, "login"]
      );
    } catch (e) {
      console.error("Failed to log login activity", e);
    }
    
    res.json({
      token,
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        age: user.age,
        gender: user.gender,
        height_cm: user.height_cm,
        weight_kg: user.weight_kg,
        avatar_url: user.avatar_url,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

async function me(req, res) {
  // If auth middleware not used, try to extract token and attach user
  if (req.user) {
    try {
      const user = await userService.findById(req.user.user_id);
      if (!user) return res.status(404).json({ error: "User not found" });
      const userResp = {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        age: user.age,
        gender: user.gender,
        height_cm: user.height_cm,
        weight_kg: user.weight_kg,
        avatar_url: user.avatar_url,
        activity_level: user.activity_level,
        diet_type: user.diet_type,
        allergies: user.allergies,
        health_goals: user.health_goals,
        goal_type: user.goal_type,
        goal_weight: user.goal_weight,
        activity_factor: user.activity_factor,
        bmr: user.bmr,
        tdee: user.tdee,
        daily_calorie_target: user.daily_calorie_target,
        daily_protein_target: user.daily_protein_target,
        daily_fat_target: user.daily_fat_target,
        daily_carb_target: user.daily_carb_target,
        daily_water_target: user.daily_water_target,
      };
      // attach today's aggregated totals (if any), using the same Vietnam-date
      // logic as waterService so that DailySummary.date comparisons always match.
      try {
        const db = require("../db");
        // Prefer date passed from client (already computed in Vietnam timezone),
        // fall back to DB-based Vietnam date when not provided.
        let isoDate = req.query.date;
        if (!isoDate) {
          const dateRes = await db.query(
            "SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date::text AS date"
          );
          isoDate = dateRes.rows[0].date;
        }
        console.log(
          "[/auth/me] primary branch VN date for user",
          user.user_id,
          "=>",
          isoDate
        );
        const ds = await db.query(
          // cast stored timestamp to date so it aligns with the Vietnam "day"
          "SELECT total_calories, total_protein, total_fat, total_carbs, total_water FROM DailySummary WHERE user_id = $1 AND date::date = $2::date LIMIT 1",
          [user.user_id, isoDate]
        );
        const today = ds.rows[0] || {
          total_calories: 0,
          total_protein: 0,
          total_fat: 0,
          total_carbs: 0,
          total_water: 0,
        };
        console.log("[/auth/me] DailySummary row for user", user.user_id, today);
        // also fetch last drink timestamp from WaterLog if available
        try {
          const last = await db.query(
            "SELECT created_at FROM WaterLog WHERE user_id = $1 AND log_date = $2::date ORDER BY created_at DESC LIMIT 1",
            [user.user_id, isoDate]
          );
          const lr = last.rows[0];
          today.last_drink_at = lr ? lr.created_at : null;
        } catch (e) {
          today.last_drink_at = null;
        }
        userResp.today_calories = Number(today.total_calories || 0);
        userResp.today_protein = Number(today.total_protein || 0);
        userResp.today_fat = Number(today.total_fat || 0);
        userResp.today_carbs = Number(today.total_carbs || 0);
        userResp.today_water = Number(today.total_water || 0);
        userResp.today_last_drink = today.last_drink_at
          ? new Date(today.last_drink_at).toISOString()
          : null;
      } catch (e) {
        // non-fatal: include zeros if DB query fails
        userResp.today_calories = 0;
        userResp.today_protein = 0;
        userResp.today_fat = 0;
        userResp.today_carbs = 0;
        console.error("Failed to read DailySummary for /me", e && e.message);
      }
      return res.json({ user: userResp });
    } catch (err) {
      console.error("me handler error", err);
      return res.status(500).json({ error: "Lỗi server" });
    }
  }

  // fallback: try to read Authorization header
  const auth = req.headers["authorization"] || req.headers["Authorization"];
  if (!auth)
    return res.status(401).json({ error: "Missing Authorization header" });
  try {
    const jwt = require("jsonwebtoken");
    const payload = jwt.verify(auth.split(" ")[1], JWT_SECRET);
    const user = await userService.findById(payload.user_id);
    if (!user) return res.status(404).json({ error: "User not found" });
    const userResp = {
      user_id: user.user_id,
      full_name: user.full_name,
      email: user.email,
      age: user.age,
      gender: user.gender,
      height_cm: user.height_cm,
      weight_kg: user.weight_kg,
      avatar_url: user.avatar_url,
      daily_water_target: user.daily_water_target,
    };
    try {
      const db = require("../db");
      // Prefer client-provided Vietnam date when available.
      let isoDate = req.query.date;
      if (!isoDate) {
        const dateRes = await db.query(
          "SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date::text AS date"
        );
        isoDate = dateRes.rows[0].date;
      }
      console.log(
        "[/auth/me] fallback branch VN date for user",
        user.user_id,
        "=>",
        isoDate
      );
      const ds = await db.query(
        "SELECT total_calories, total_protein, total_fat, total_carbs, total_water FROM DailySummary WHERE user_id = $1 AND date::date = $2::date LIMIT 1",
        [user.user_id, isoDate]
      );
      const today = ds.rows[0] || {
        total_calories: 0,
        total_protein: 0,
        total_fat: 0,
        total_carbs: 0,
        total_water: 0,
      };
      console.log(
        "[/auth/me] DailySummary row (fallback) for user",
        user.user_id,
        today
      );
      userResp.today_calories = Number(today.total_calories || 0);
      userResp.today_protein = Number(today.total_protein || 0);
      userResp.today_fat = Number(today.total_fat || 0);
      userResp.today_carbs = Number(today.total_carbs || 0);
    } catch (e) {
      userResp.today_calories = 0;
      userResp.today_protein = 0;
      userResp.today_fat = 0;
      userResp.today_carbs = 0;
      console.error(
        "Failed to read DailySummary for /me fallback",
        e && e.message
      );
    }
    return res.json({ user: userResp });
  } catch (err) {
    console.error(err);
    return res.status(401).json({ error: "Invalid token" });
  }
}

async function updateProfile(req, res) {
  // req.user is attached by authMiddleware
  const userId = req.user && req.user.user_id;
  console.log("updateProfile called for userId=", userId, "body=", req.body);
  if (!userId) return res.status(401).json({ error: "Unauthorized" });

  const {
    full_name,
    email,
    age,
    gender,
    height_cm,
    weight_kg,
    activity_level,
    diet_type,
    allergies,
    health_goals,
    goal_type,
    goal_weight,
    activity_factor,
    bmr,
    tdee,
    daily_calorie_target,
    daily_protein_target,
    daily_fat_target,
    daily_carb_target,
    avatar_url,
  } = req.body || {};

  // Basic validation
  if (email) {
    const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
    if (!emailRegex.test(email))
      return res.status(400).json({ error: "Email không hợp lệ" });
  }

  // numeric validations (if provided, must be numbers)
  const numericFields = {
    age,
    height_cm,
    weight_kg,
    goal_weight,
    activity_factor,
    bmr,
    tdee,
    daily_calorie_target,
    daily_protein_target,
    daily_fat_target,
    daily_carb_target,
  };
  for (const [k, v] of Object.entries(numericFields)) {
    if (v !== undefined && v !== null && v !== "") {
      if (typeof v !== "number" && isNaN(Number(v)))
        return res.status(400).json({ error: `${k} phải là số` });
    }
  }

  // Additional server-side numeric range checks to prevent DB numeric overflow
  const MAX_NUMERIC_ABS = 1e8 - 0.01; // NUMERIC(10,2) max absolute value is < 10^8
  for (const [k, v] of Object.entries(numericFields)) {
    if (v !== undefined && v !== null && v !== "") {
      const num = Number(v);
      if (!isFinite(num) || Math.abs(num) >= 1e8) {
        return res
          .status(400)
          .json({ error: `${k} vượt quá giới hạn cho phép` });
      }
      // basic non-negative checks for targets
      if (
        k.startsWith("daily_") ||
        k === "goal_weight" ||
        k === "activity_factor" ||
        k === "bmr" ||
        k === "tdee"
      ) {
        if (num < 0)
          return res.status(400).json({ error: `${k} phải là số không âm` });
      }
    }
  }

  try {
    const updated = await userService.updateUser(userId, {
      full_name,
      email,
      age,
      gender,
      height_cm,
      weight_kg,
      activity_level,
      diet_type,
      allergies,
      health_goals,
      goal_type,
      goal_weight,
      activity_factor,
      bmr,
      tdee,
      daily_calorie_target,
      daily_protein_target,
      daily_fat_target,
      daily_carb_target,
      avatar_url,
    });
    if (!updated) return res.status(404).json({ error: "User not found" });

    // Auto-create body measurement if height or weight changed
    if (
      (height_cm !== undefined && height_cm !== null) ||
      (weight_kg !== undefined && weight_kg !== null)
    ) {
      try {
        const db = require("../db");
        await db.query(
          `
          INSERT INTO BodyMeasurement (user_id, weight_kg, height_cm, source, notes)
          VALUES ($1, $2, $3, 'profile_update', 'Auto-created from profile update')
        `,
          [userId, updated.weight_kg, updated.height_cm]
        );
        console.log(
          "[updateProfile] Auto-created body measurement for user",
          userId
        );
      } catch (measurementErr) {
        console.error(
          "[updateProfile] Failed to create body measurement:",
          measurementErr
        );
      }
    }

    // After updating core fields, compute BMR and TDEE automatically when possible
    try {
      const weight = Number(updated.weight_kg);
      const height = Number(updated.height_cm);
      const a = Number(updated.age);
      const gen = (updated.gender || "").toString().toLowerCase();

      let computedBmr = null;
      let computedActivityFactor = Number(updated.activity_factor) || null;
      let computedTdee = null;

      const hasBio = !isNaN(weight) && !isNaN(height) && !isNaN(a) && a > 0;
      if (hasBio) {
        // Use Mifflin–St Jeor formula to match client-side calculation
        // Male: BMR = 10*W + 6.25*H - 5*A + 5
        // Female: BMR = 10*W + 6.25*H - 5*A - 161
        if (gen.startsWith("m") || gen === "male") {
          computedBmr = Math.round(
            10.0 * weight + 6.25 * height - 5.0 * a + 5.0
          );
        } else if (gen.startsWith("f") || gen === "female") {
          computedBmr = Math.round(
            10.0 * weight + 6.25 * height - 5.0 * a - 161.0
          );
        } else {
          // fallback: average of male and female Mifflin estimates
          const mBmr = 10.0 * weight + 6.25 * height - 5.0 * a + 5.0;
          const fBmr = 10.0 * weight + 6.25 * height - 5.0 * a - 161.0;
          computedBmr = Math.round((mBmr + fBmr) / 2.0);
        }

        // Determine activity factor: prefer explicit activity_factor; else map activity_level
        if (!computedActivityFactor) {
          const lvlRaw = (updated.activity_level || "")
            .toString()
            .toLowerCase()
            .trim();
          // mapping that includes English and Vietnamese phrases to activity factors
          const map = {
            // english
            sedentary: 1.2,
            light: 1.375,
            "lightly active": 1.375,
            moderate: 1.55,
            "moderately active": 1.55,
            active: 1.725,
            "very active": 1.9,
            extra: 1.9,
            // vietnamese common phrases
            "ít vận động": 1.2,
            "không vận động": 1.2,
            "vận động nhẹ": 1.375,
            "vận động ít": 1.375,
            "vận động vừa phải": 1.55,
            "vừa phải": 1.55,
            "vừa phải vận động": 1.55,
            vừa: 1.55,
            "năng động": 1.725,
            "rất năng động": 1.725,
            "cực kỳ năng động": 1.9,
            "rất nhiều": 1.9,
            // also accept numbers or factor strings
          };

          // try direct mapping
          computedActivityFactor = map[lvlRaw];

          // if still undefined, try to parse numeric-like strings
          if (!computedActivityFactor) {
            const asNum = Number(lvlRaw);
            if (!isNaN(asNum) && asNum > 0) computedActivityFactor = asNum;
          }

          // fallback default
          if (!computedActivityFactor) computedActivityFactor = 1.2;
        }

        computedTdee = Math.round(computedBmr * computedActivityFactor);
      }

      // persist computed values if available
      if (computedBmr !== null) {
        await userService.updateUser(userId, {
          bmr: computedBmr,
          tdee: computedTdee,
          activity_factor: computedActivityFactor,
        });
        // re-fetch latest
        const finalUser = await userService.findById(userId);
        const userResp = {
          user_id: finalUser.user_id,
          full_name: finalUser.full_name,
          email: finalUser.email,
          age: finalUser.age,
          gender: finalUser.gender,
          height_cm: finalUser.height_cm,
          weight_kg: finalUser.weight_kg,
          avatar_url: finalUser.avatar_url,
          activity_level: finalUser.activity_level,
          diet_type: finalUser.diet_type,
          allergies: finalUser.allergies,
          health_goals: finalUser.health_goals,
          goal_type: finalUser.goal_type,
          goal_weight: finalUser.goal_weight,
          activity_factor: finalUser.activity_factor,
          bmr: finalUser.bmr,
          tdee: finalUser.tdee,
          daily_calorie_target: finalUser.daily_calorie_target,
          daily_protein_target: finalUser.daily_protein_target,
          daily_fat_target: finalUser.daily_fat_target,
          daily_carb_target: finalUser.daily_carb_target,
          daily_water_target: finalUser.daily_water_target,
        };
        // Log activity
        try {
          await require("../db").query(
            "INSERT INTO UserActivityLog(user_id, action) VALUES ($1,$2)",
            [userId, "bmr_tdee_recomputed"]
          );
        } catch (e) {}
        return res.json({
          user: userResp,
          message: "BMR/TDEE đã được tính và lưu bởi server",
        });
      }
    } catch (e) {
      console.error("Error computing BMR/TDEE", e);
    }

    // Fallback: return updated row as-is
    const userResp = {
      user_id: updated.user_id,
      full_name: updated.full_name,
      email: updated.email,
      age: updated.age,
      gender: updated.gender,
      height_cm: updated.height_cm,
      weight_kg: updated.weight_kg,
      avatar_url: updated.avatar_url,
      activity_level: updated.activity_level,
      diet_type: updated.diet_type,
      allergies: updated.allergies,
      health_goals: updated.health_goals,
      goal_type: updated.goal_type,
      goal_weight: updated.goal_weight,
      activity_factor: updated.activity_factor,
      bmr: updated.bmr,
      tdee: updated.tdee,
      daily_calorie_target: updated.daily_calorie_target,
      daily_protein_target: updated.daily_protein_target,
      daily_fat_target: updated.daily_fat_target,
      daily_carb_target: updated.daily_carb_target,
      daily_water_target: updated.daily_water_target,
    };

    // Log profile update
    try {
      await require("../db").query(
        "INSERT INTO UserActivityLog(user_id, action) VALUES ($1,$2)",
        [userId, "profile_updated"]
      );
    } catch (e) {}
    return res.json({ user: userResp });
  } catch (err) {
    console.error("updateProfile outer error", err);
    // handle unique constraint violation on email
    if (err && err.code === "23505")
      return res.status(409).json({ error: "Email đã được sử dụng" });
    return res.status(500).json({ error: "Lỗi server" });
  }
}

async function recomputeTargets(req, res) {
  const userId = req.user && req.user.user_id;
  if (!userId) return res.status(401).json({ error: "Unauthorized" });

  try {
    const user = await userService.findById(userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    const weight = Number(user.weight_kg);
    const height = Number(user.height_cm);
    const a = Number(user.age);
    const gen = (user.gender || "").toString().toLowerCase();

    let computedBmr = null;
    let computedActivityFactor = Number(user.activity_factor) || null;
    let computedTdee = null;

    const hasBio = !isNaN(weight) && !isNaN(height) && !isNaN(a) && a > 0;
    if (!hasBio)
      return res
        .status(400)
        .json({
          error:
            "Insufficient profile data (age/height/weight) to compute BMR/TDEE",
        });

    // Use Mifflin–St Jeor formula (same as frontend)
    if (gen.startsWith("m") || gen === "male") {
      computedBmr = Math.round(10.0 * weight + 6.25 * height - 5.0 * a + 5.0);
    } else if (gen.startsWith("f") || gen === "female") {
      computedBmr = Math.round(10.0 * weight + 6.25 * height - 5.0 * a - 161.0);
    } else {
      const mBmr = 10.0 * weight + 6.25 * height - 5.0 * a + 5.0;
      const fBmr = 10.0 * weight + 6.25 * height - 5.0 * a - 161.0;
      computedBmr = Math.round((mBmr + fBmr) / 2.0);
    }

    if (!computedActivityFactor) {
      const lvlRaw = (user.activity_level || "")
        .toString()
        .toLowerCase()
        .trim();
      const map = {
        sedentary: 1.2,
        light: 1.375,
        "lightly active": 1.375,
        moderate: 1.55,
        "moderately active": 1.55,
        active: 1.725,
        "very active": 1.9,
        extra: 1.9,
        "ít vận động": 1.2,
        "không vận động": 1.2,
        "vận động nhẹ": 1.375,
        "vận động ít": 1.375,
        "vận động vừa phải": 1.55,
        "vừa phải": 1.55,
        "vừa phải vận động": 1.55,
        vừa: 1.55,
        "năng động": 1.725,
        "rất năng động": 1.725,
        "cực kỳ năng động": 1.9,
        "rất nhiều": 1.9,
      };
      computedActivityFactor = map[lvlRaw];
      if (!computedActivityFactor) {
        const asNum = Number(lvlRaw);
        if (!isNaN(asNum) && asNum > 0) computedActivityFactor = asNum;
      }
      if (!computedActivityFactor) computedActivityFactor = 1.2;
    }

    computedTdee = Math.round(computedBmr * computedActivityFactor);

    // --- compute daily calorie & macro targets ---
    // prefer explicit calorie_multiplier stored on user; otherwise infer from health_goals
    let multiplier = Number(user.calorie_multiplier);
    if (!isFinite(multiplier) || !(multiplier > 0)) {
      const hg = (user.health_goals || "").toString();
      if (hg === "Giảm") multiplier = 0.85;
      else if (hg === "Tăng") multiplier = 1.15;
      else multiplier = 1.0;
    }

    // macro percentages: prefer stored macro_* fields if present
    let pProtein = Number(user.macro_protein_pct);
    let pFat = Number(user.macro_fat_pct);
    let pCarb = Number(user.macro_carb_pct);
    if (
      !isFinite(pProtein) ||
      !isFinite(pFat) ||
      !isFinite(pCarb) ||
      pProtein + pFat + pCarb === 0
    ) {
      const hg = (user.health_goals || "").toString();
      if (hg === "Giảm") {
        pProtein = 30;
        pFat = 25;
        pCarb = 45;
      } else if (hg === "Tăng") {
        pProtein = 32.5;
        pFat = 25;
        pCarb = 42.5;
      } else {
        pProtein = 25;
        pFat = 25;
        pCarb = 50;
      }
    }

    const calcDailyCal = Math.round(computedTdee * multiplier);
    const calcProteinG = Math.round((calcDailyCal * (pProtein / 100.0)) / 4.0);
    const calcFatG = Math.round((calcDailyCal * (pFat / 100.0)) / 9.0);
    const calcCarbG = Math.round((calcDailyCal * (pCarb / 100.0)) / 4.0);

    await userService.updateUser(userId, {
      bmr: computedBmr,
      tdee: computedTdee,
      activity_factor: computedActivityFactor,
      daily_calorie_target: calcDailyCal,
      daily_protein_target: calcProteinG,
      daily_fat_target: calcFatG,
      daily_carb_target: calcCarbG,
    });
    const finalUser = await userService.findById(userId);

    const userResp = {
      user_id: finalUser.user_id,
      full_name: finalUser.full_name,
      email: finalUser.email,
      age: finalUser.age,
      gender: finalUser.gender,
      height_cm: finalUser.height_cm,
      weight_kg: finalUser.weight_kg,
      activity_level: finalUser.activity_level,
      diet_type: finalUser.diet_type,
      allergies: finalUser.allergies,
      health_goals: finalUser.health_goals,
      goal_type: finalUser.goal_type,
      goal_weight: finalUser.goal_weight,
      activity_factor: finalUser.activity_factor,
      bmr: finalUser.bmr,
      tdee: finalUser.tdee,
      daily_calorie_target: finalUser.daily_calorie_target,
      daily_protein_target: finalUser.daily_protein_target,
      daily_fat_target: finalUser.daily_fat_target,
      daily_carb_target: finalUser.daily_carb_target,
      daily_water_target: finalUser.daily_water_target,
    };

    try {
      await require("../db").query(
        "INSERT INTO UserActivityLog(user_id, action) VALUES ($1,$2)",
        [userId, "bmr_tdee_recomputed"]
      );
    } catch (e) {}
    return res.json({
      user: userResp,
      message: "BMR/TDEE đã được tính lại và lưu bởi server",
    });
  } catch (err) {
    console.error("recomputeTargets error", err);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

async function recomputeDailyTargets(req, res) {
  const userId = req.user && req.user.user_id;
  if (!userId) return res.status(401).json({ error: "Unauthorized" });

  try {
    const user = await userService.findById(userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    // Determine TDEE: prefer stored tdee, else try compute from bmr*activity_factor
    let tdee = Number(user.tdee);
    if (!isFinite(tdee) || tdee <= 0) {
      const b = Number(user.bmr);
      const af = Number(user.activity_factor);
      if (isFinite(b) && isFinite(af) && af > 0) {
        tdee = Math.round(b * af);
      }
    }

    if (!isFinite(tdee) || tdee <= 0) {
      return res
        .status(400)
        .json({ error: "Insufficient BMR/TDEE data to compute daily targets" });
    }

    // multiplier and macro percents logic (same defaults as other places)
    let multiplier = Number(user.calorie_multiplier);
    if (!isFinite(multiplier) || !(multiplier > 0)) {
      const hg = (user.health_goals || "").toString();
      if (hg === "Giảm") multiplier = 0.85;
      else if (hg === "Tăng") multiplier = 1.15;
      else multiplier = 1.0;
    }

    let pProtein = Number(user.macro_protein_pct);
    let pFat = Number(user.macro_fat_pct);
    let pCarb = Number(user.macro_carb_pct);
    if (
      !isFinite(pProtein) ||
      !isFinite(pFat) ||
      !isFinite(pCarb) ||
      pProtein + pFat + pCarb === 0
    ) {
      const hg = (user.health_goals || "").toString();
      if (hg === "Giảm") {
        pProtein = 30;
        pFat = 25;
        pCarb = 45;
      } else if (hg === "Tăng") {
        pProtein = 32.5;
        pFat = 25;
        pCarb = 42.5;
      } else {
        pProtein = 25;
        pFat = 25;
        pCarb = 50;
      }
    }

    const calcDailyCal = Math.round(tdee * multiplier);
    const calcProteinG = Math.round((calcDailyCal * (pProtein / 100.0)) / 4.0);
    const calcFatG = Math.round((calcDailyCal * (pFat / 100.0)) / 9.0);
    const calcCarbG = Math.round((calcDailyCal * (pCarb / 100.0)) / 4.0);

    // Persist only daily targets (do not change bmr/tdee/activity_factor)
    await userService.updateUser(userId, {
      daily_calorie_target: calcDailyCal,
      daily_protein_target: calcProteinG,
      daily_fat_target: calcFatG,
      daily_carb_target: calcCarbG,
    });

    const finalUser = await userService.findById(userId);
    try {
      await require("../db").query(
        "INSERT INTO UserActivityLog(user_id, action) VALUES ($1,$2)",
        [userId, "daily_targets_recomputed"]
      );
    } catch (e) {}
    return res.json({
      user: finalUser,
      message: "Mục tiêu hàng ngày đã được tính và lưu bởi server",
    });
  } catch (err) {
    console.error("recomputeDailyTargets error", err);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// 2FA status
async function twoFaStatus(req, res) {
  const userId = req.user && req.user.user_id;
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  try {
    const sec = await securityService.getUserSecurity(userId);
    return res.json({
      enabled: !!(sec && sec.twofa_enabled),
      lock_threshold:
        sec && sec.lock_threshold != null ? Number(sec.lock_threshold) : 5,
    });
  } catch (e) {
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Start enabling 2FA: verify password, generate secret, return otpauth_url
async function twoFaEnable(req, res) {
  const userId = req.user && req.user.user_id;
  const { current_password } = req.body || {};
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  if (!current_password)
    return res.status(400).json({ error: "Cần nhập mật khẩu hiện tại" });
  try {
    const dbx = require("../db");
    const r = await dbx.query(
      'SELECT email, full_name, password_hash FROM "User" WHERE user_id = $1',
      [userId]
    );
    const row = r.rows[0];
    if (!row) return res.status(404).json({ error: "User not found" });
    const ok = await bcrypt.compare(current_password, row.password_hash);
    if (!ok) return res.status(401).json({ error: "Sai mật khẩu" });
    const appName = process.env.TOTP_ISSUER || "MyDiary";
    const secret = speakeasy.generateSecret({
      name: `${appName} (${row.email})`,
    });
    await securityService.setTwoFaSecret(userId, secret.base32);
    return res.json({ base32: secret.base32, otpauth_url: secret.otpauth_url });
  } catch (e) {
    console.error("twoFaEnable error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Verify OTP to complete enabling 2FA
async function twoFaVerify(req, res) {
  const userId = req.user && req.user.user_id;
  const { otp } = req.body || {};
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  if (!otp) return res.status(400).json({ error: "Thiếu mã OTP" });
  try {
    const sec = await securityService.getUserSecurity(userId);
    if (!sec || !sec.twofa_secret)
      return res.status(400).json({ error: "Chưa khởi tạo 2FA" });
    const ok = speakeasy.totp.verify({
      secret: sec.twofa_secret,
      encoding: "base32",
      token: String(otp),
      window: 1,
    });
    if (!ok) return res.status(400).json({ error: "OTP không hợp lệ" });
    await securityService.enableTwoFa(userId);
    return res.json({ enabled: true });
  } catch (e) {
    console.error("twoFaVerify error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

async function twoFaDisable(req, res) {
  const userId = req.user && req.user.user_id;
  const { current_password } = req.body || {};
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  if (!current_password)
    return res.status(400).json({ error: "Cần nhập mật khẩu hiện tại" });
  try {
    const dbx = require("../db");
    const r = await dbx.query(
      'SELECT password_hash FROM "User" WHERE user_id = $1',
      [userId]
    );
    const row = r.rows[0];
    if (!row) return res.status(404).json({ error: "User not found" });
    const ok = await bcrypt.compare(current_password, row.password_hash);
    if (!ok) return res.status(401).json({ error: "Sai mật khẩu" });
    await securityService.disableTwoFa(userId);
    return res.json({ enabled: false });
  } catch (e) {
    console.error("twoFaDisable error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Verify MFA at login using temp_token
async function loginMfaVerify(req, res) {
  const { temp_token, otp } = req.body || {};
  if (!temp_token || !otp)
    return res.status(400).json({ error: "Thiếu temp_token hoặc OTP" });
  try {
    const payload = jwt.verify(temp_token, JWT_SECRET);
    if (payload.purpose !== "mfa")
      return res.status(400).json({ error: "Token không hợp lệ" });
    const user = await userService.findById(payload.user_id);
    if (!user) return res.status(404).json({ error: "User not found" });
    const sec = await securityService.getUserSecurity(user.user_id);
    if (!sec || !sec.twofa_enabled || !sec.twofa_secret)
      return res.status(400).json({ error: "2FA chưa được bật" });
    const ok = speakeasy.totp.verify({
      secret: sec.twofa_secret,
      encoding: "base32",
      token: String(otp),
      window: 1,
    });
    if (!ok) return res.status(400).json({ error: "OTP không hợp lệ" });
    // update last_login
    try {
      await require("../db").query(
        'UPDATE "User" SET last_login = now() WHERE user_id = $1',
        [user.user_id]
      );
    } catch (e) {}
    const token = jwt.sign(
      { user_id: user.user_id, email: user.email },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );
    return res.json({
      token,
      user: {
        user_id: user.user_id,
        full_name: user.full_name,
        email: user.email,
        age: user.age,
        gender: user.gender,
        height_cm: user.height_cm,
        weight_kg: user.weight_kg,
      },
    });
  } catch (e) {
    console.error("loginMfaVerify error", e);
    return res
      .status(401)
      .json({ error: "Temp token hết hạn hoặc không hợp lệ" });
  }
}

// Request password change code (email)
async function requestPasswordChangeCode(req, res) {
  const userId = req.user && req.user.user_id;
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  try {
    const dbx = require("../db");
    const r = await dbx.query(
      'SELECT email, full_name FROM "User" WHERE user_id = $1',
      [userId]
    );
    const row = r.rows[0];
    if (!row) return res.status(404).json({ error: "User not found" });
    const { code, expires_at } =
      await securityService.createPasswordChangeCodeJS(userId, 600);
    // Try to send email, fallback to console
    try {
      const html = buildEmailTemplate({
        title: "Yêu cầu đổi mật khẩu",
        bodyLines: [
          `Xin chào ${row.full_name || row.email},`,
          "Bạn vừa yêu cầu đổi mật khẩu. Nhập mã bên dưới trong ứng dụng để đặt mật khẩu mới.",
          "Mã có hiệu lực 10 phút.",
        ],
        actionLabel: "Mã xác nhận",
        actionCode: code,
      });
      await sendMail({
        to: row.email,
        subject: "[VietNam Healthy Life] Mã đổi mật khẩu",
        html,
        text: `Mã đổi mật khẩu của bạn: ${code}. Mã hết hạn sau 10 phút.`,
      });
    } catch (e) {
      console.log("Email send failed, printing code to console:", code);
    }
    return res.json({ sent: true, expires_at });
  } catch (e) {
    console.error("requestPasswordChangeCode error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Confirm password change
async function confirmPasswordChange(req, res) {
  const userId = req.user && req.user.user_id;
  const { code, new_password } = req.body || {};
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  if (!code || !new_password)
    return res.status(400).json({ error: "Thiếu code hoặc mật khẩu mới" });
  if (typeof new_password !== "string" || new_password.length < 6)
    return res.status(400).json({ error: "Mật khẩu mới phải ít nhất 6 kí tự" });
  try {
    const vr = await securityService.verifyPasswordChangeCode(
      userId,
      String(code)
    );
    if (!vr.ok)
      return res.status(400).json({ error: "Mã không hợp lệ hoặc đã hết hạn" });
    const hashed = await bcrypt.hash(new_password, 10);
    await userService.updateUser(userId, { password_hash: hashed });
    
    // Log password change activity
    try {
      const db = require("../db");
      await db.query(
        "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
        [userId, "password_changed"]
      );
    } catch (e) {
      console.error("Failed to log password_changed activity", e);
    }
    
    return res.json({ changed: true });
  } catch (e) {
    console.error("confirmPasswordChange error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Update security settings (lock threshold)
async function updateSecurity(req, res) {
  const userId = req.user && req.user.user_id;
  const { lock_threshold } = req.body || {};
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  const lt = Number(lock_threshold);
  if (!isFinite(lt) || lt < 3 || lt > 10)
    return res.status(400).json({ error: "lock_threshold phải từ 3 đến 10" });
  try {
    await securityService.setLockThreshold(userId, Math.round(lt));
    return res.json({ ok: true, lock_threshold: Math.round(lt) });
  } catch (e) {
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Request unlock code for blocked account (identifier: email or full_name)
async function requestUnlockCode(req, res) {
  const { identifier } = req.body || {};
  if (!identifier)
    return res.status(400).json({ error: "Thiếu identifier (email hoặc tên)" });
  try {
    const user = await userService.findByEmailOrName(identifier);
    if (!user) return res.status(404).json({ error: "Không tìm thấy tài khoản" });
    const { code } = await securityService.createUnlockCode(user.user_id, 900);
    const html = buildEmailTemplate({
      title: "Mã mở khóa tài khoản",
      bodyLines: [
        `Xin chào ${user.full_name || user.email},`,
        "Tài khoản của bạn đang bị khóa do nhập sai mật khẩu nhiều lần.",
        "Nhập mã bên dưới trong màn hình đăng nhập để mở khóa.",
        "Mã có hiệu lực 15 phút.",
      ],
      actionLabel: "Mã mở khóa",
      actionCode: code,
    });
    await sendMail({
      to: user.email,
      subject: "[VietNam Healthy Life] Mã mở khóa tài khoản",
      html,
      text: `Mã mở khóa tài khoản: ${code}. Mã hết hạn sau 15 phút.`,
    });
    return res.json({ sent: true });
  } catch (e) {
    console.error("requestUnlockCode error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Confirm unlock code and unblock account
async function confirmUnlockCode(req, res) {
  const { identifier, code } = req.body || {};
  if (!identifier || !code)
    return res.status(400).json({ error: "Thiếu identifier hoặc code" });
  try {
    const user = await userService.findByEmailOrName(identifier);
    if (!user) return res.status(404).json({ error: "Không tìm thấy tài khoản" });
    const vr = await securityService.verifyUnlockCode(user.user_id, String(code));
    if (!vr.ok)
      return res.status(400).json({ error: "Mã không hợp lệ hoặc đã hết hạn" });
    await securityService.unblockUser(user.user_id);
    return res.json({ unblocked: true });
  } catch (e) {
    console.error("confirmUnlockCode error", e);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

// Notifications aggregation
async function notifications(req, res) {
  const userId = req.user && req.user.user_id;
  if (!userId) return res.status(401).json({ error: "Unauthorized" });
  try {
    // Get security notifications (login, account status, etc)
    const securityNotifications = await securityService.getNotifications(
      userId
    );

    // Get nutrient notifications (deficiencies, warnings)
    let nutrientNotifications = [];
    try {
      nutrientNotifications =
        await nutrientTrackingService.getNutrientNotifications(userId, 20);
      // Transform to match security notification format
      nutrientNotifications = nutrientNotifications.map((n) => ({
        type: n.notification_type,
        at: n.created_at,
        message: n.title,
        detail: n.message,
        severity: n.severity,
        is_read: n.is_read,
        notification_id: n.notification_id,
        metadata: n.metadata,
      }));
    } catch (e) {
      console.error("Error fetching nutrient notifications:", e);
    }

    let dishNotifications = [];
    try {
      const result = await db.query(
        `
        SELECT
          notification_id,
          dish_id,
          notification_type,
          title,
          message,
          is_read,
          created_at
        FROM dishnotification
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT 20
        `,
        [userId]
      );

      dishNotifications = result.rows.map((n) => ({
        type: n.notification_type,
        at: n.created_at,
        message: n.title,
        detail: n.message,
        is_read: n.is_read,
        notification_id: n.notification_id,
        metadata: { dish_id: n.dish_id },
      }));
    } catch (e) {
      console.error("Error fetching dish notifications:", e);
    }

    let drinkNotifications = [];
    try {
      const result = await db.query(
        `
        SELECT
          notification_id,
          drink_id,
          notification_type,
          title,
          message,
          is_read,
          created_at
        FROM drinknotification
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT 20
        `,
        [userId]
      );

      drinkNotifications = result.rows.map((n) => ({
        type: n.notification_type,
        at: n.created_at,
        message: n.title,
        detail: n.message,
        is_read: n.is_read,
        notification_id: n.notification_id,
        metadata: { drink_id: n.drink_id },
      }));
    } catch (e) {
      console.error("Error fetching drink notifications:", e);
    }

    const allNotifications = [
      ...securityNotifications,
      ...nutrientNotifications,
      ...dishNotifications,
      ...drinkNotifications,
    ];
    allNotifications.sort((a, b) => new Date(b.at) - new Date(a.at));

    return res.json({ notifications: allNotifications });
  } catch (e) {
    return res.status(500).json({ error: "Lỗi server" });
  }
}

module.exports = {
  register,
  login,
  me,
  updateProfile,
  recomputeTargets,
  recomputeDailyTargets,
  twoFaStatus,
  twoFaEnable,
  twoFaVerify,
  twoFaDisable,
  loginMfaVerify,
  requestPasswordChangeCode,
  confirmPasswordChange,
  updateSecurity,
  requestUnlockCode,
  confirmUnlockCode,
  notifications,
};
/**
 * Submit unblock request (no auth token required because user cannot login while blocked)
 * Body: { identifier, message }
 */
async function submitUnblockRequest(req, res) {
  const { identifier, message } = req.body || {};
  if (!identifier)
    return res.status(400).json({ error: "identifier là bắt buộc" });
  try {
    const user = await userService.findByEmailOrName(identifier);
    if (!user) return res.status(404).json({ error: "Không tìm thấy user" });
    const db = require("../db");
    const statusRes = await db.query(
      "SELECT is_blocked, blocked_reason FROM user_account_status WHERE user_id = $1 LIMIT 1",
      [user.user_id]
    );
    const st = statusRes.rows[0];
    if (!st || !st.is_blocked)
      return res.status(400).json({ error: "Tài khoản không bị chặn" });
    // ensure no pending request
    const pending = await db.query(
      "SELECT 1 FROM user_unblock_request WHERE user_id = $1 AND status = $2 LIMIT 1",
      [user.user_id, "pending"]
    );
    if (pending.rows.length > 0)
      return res
        .status(409)
        .json({ error: "Đã có yêu cầu gỡ chặn đang chờ xử lý" });
    const ins = await db.query(
      "INSERT INTO user_unblock_request(user_id, message) VALUES ($1,$2) RETURNING request_id, created_at",
      [user.user_id, message || null]
    );
    // Emit event for admin dashboard
    try {
      const eventBus = require("../utils/eventBus");
      eventBus.emit("unblock_request_submitted", {
        user_id: user.user_id,
        request_id: ins.rows[0].request_id,
        message: message || null,
      });
    } catch (e) {}
    return res
      .status(201)
      .json({
        message: "Yêu cầu đã được gửi",
        request_id: ins.rows[0].request_id,
      });
  } catch (err) {
    console.error("submitUnblockRequest error", err);
    return res.status(500).json({ error: "Lỗi server" });
  }
}

module.exports.submitUnblockRequest = submitUnblockRequest;
