const db = require("../db");
const drinkService = require("./drinkService");

async function createWaterEntry(userId, amountMl, date, options = {}) {
  const client = await db.pool.connect();
  try {
    await client.query("BEGIN");

    // Get the date to use (either provided by client or current date in Vietnam timezone)
    let isoDate;
    if (date) {
      // If client sends a plain YYYY-MM-DD string, use it directly to avoid
      // timezone shifts from JavaScript Date parsing.
      if (typeof date === "string" && /^\d{4}-\d{2}-\d{2}$/.test(date)) {
        isoDate = date;
      } else {
        const logDate = new Date(date);
        isoDate = logDate.toISOString().slice(0, 10);
      }
    } else {
      // Use Vietnam timezone (UTC+7) for current date
      const dateResult = await client.query(
        "SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date::text as date"
      );
      isoDate = dateResult.rows[0].date;
    }
    console.error(
      "[waterService] Creating entry for user",
      userId,
      "amount",
      amountMl,
      "date",
      isoDate
    );

    let drinkInfo = null;
    let effectiveRatio = 1.0;
    let drinkName = options.drink_name || null;
    let drinkId = options.drink_id || null;
    if (drinkId) {
      drinkInfo = await drinkService.getDrinkById(drinkId);
      if (!drinkInfo) {
        throw new Error("Drink not found");
      }
      effectiveRatio = options.hydration_ratio
        ? Number(options.hydration_ratio)
        : Number(drinkInfo.hydration_ratio || 1);
      drinkName =
        drinkName || drinkInfo.vietnamese_name || drinkInfo.name || "Drink";
    } else {
      if (options.hydration_ratio) {
        effectiveRatio = Number(options.hydration_ratio);
      }
      if (!drinkName) drinkName = "Nước lọc";
    }
    if (!Number.isFinite(effectiveRatio) || effectiveRatio <= 0) {
      effectiveRatio = 1.0;
    }
    if (effectiveRatio > 1.2) effectiveRatio = 1.2;

    const hydratedAmount = amountMl * effectiveRatio;

    const seenBeforeDrink =
      drinkId &&
      (
        await client.query(
          "SELECT 1 FROM WaterLog WHERE user_id = $1 AND drink_id = $2 LIMIT 1",
          [userId, drinkId]
        )
      ).rowCount > 0;

    const insertLog = `INSERT INTO WaterLog (user_id, amount_ml, log_date, drink_id, drink_name, hydration_ratio, notes)
      VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING water_log_id`;
    const logResult = await client.query(insertLog, [
      userId,
      amountMl,
      isoDate,
      drinkId,
      drinkName,
      effectiveRatio,
      options.notes || null,
    ]);
    console.error(
      "[waterService] Inserted WaterLog ID:",
      logResult.rows[0]?.water_log_id
    );

    const upsert = `INSERT INTO DailySummary (user_id, date, total_water) VALUES ($1,$2,$3)
      ON CONFLICT (user_id, date) DO UPDATE SET total_water = DailySummary.total_water + EXCLUDED.total_water`;
    const upsertResult = await client.query(upsert, [
      userId,
      isoDate,
      hydratedAmount,
    ]);
    console.error(
      "[waterService] Upsert affected rows:",
      upsertResult.rowCount
    );

    if (drinkId) {
      await client.query(
        `
        INSERT INTO DrinkStatistics (drink_id, log_count, unique_users, last_logged_at)
        VALUES ($1, 1, 1, NOW())
        ON CONFLICT (drink_id) DO UPDATE SET
          log_count = DrinkStatistics.log_count + 1,
          unique_users = DrinkStatistics.unique_users + $2,
          last_logged_at = NOW(),
          updated_at = NOW()
      `,
        [drinkId, seenBeforeDrink ? 0 : 1]
      );
    }

    // Get updated totals BEFORE commit
    const ds = await client.query(
      "SELECT total_calories, total_protein, total_fat, total_carbs, total_water FROM DailySummary WHERE user_id = $1 AND date = $2 LIMIT 1",
      [userId, isoDate]
    );

    console.error("[waterService] Query returned", ds.rows.length, "rows");
    if (ds.rows.length > 0) {
      console.error("[waterService] Row data:", ds.rows[0]);
    }

    const totals = ds.rows[0] || {
      total_calories: 0,
      total_protein: 0,
      total_fat: 0,
      total_carbs: 0,
      total_water: 0,
    };
    const last = await client.query(
      "SELECT created_at, drink_name FROM WaterLog WHERE user_id = $1 AND log_date = $2 ORDER BY created_at DESC LIMIT 1",
      [userId, isoDate]
    );
    const lastRow = last.rows[0];

    await client.query("COMMIT");

    // Convert PostgreSQL numeric strings to numbers for frontend
    const normalizedTotals = {
      total_calories: Number(totals.total_calories) || 0,
      total_protein: Number(totals.total_protein) || 0,
      total_fat: Number(totals.total_fat) || 0,
      total_carbs: Number(totals.total_carbs) || 0,
      total_water: Number(totals.total_water) || 0,
    };

    // return today's totals and last drink timestamp
    return Object.assign({}, normalizedTotals, {
      last_drink_at: lastRow ? lastRow.created_at : null,
      last_drink_name: lastRow ? lastRow.drink_name : drinkName,
    });
  } catch (err) {
    console.error("[waterService] ERROR:", err.message, err.stack);
    await client.query("ROLLBACK");
    throw err;
  } finally {
    client.release();
  }
}

async function getDrinkCatalog(userId) {
  return drinkService.listDrinksForUser(userId);
}

async function getWaterTimeline(userId, targetDate) {
  const dateResult = targetDate
    ? { rows: [{ date: targetDate }] }
    : await db.query("SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date::text as date");
  const isoDate = dateResult.rows[0].date;

  const hourlyRes = await db.query(
    `
    SELECT EXTRACT(HOUR FROM (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh'))::int AS hour,
           SUM(amount_ml) AS total_ml
    FROM waterlog
    WHERE user_id = $1 AND log_date = $2
    GROUP BY hour
    ORDER BY hour
  `,
    [userId, isoDate]
  );

  const entriesRes = await db.query(
    `
    SELECT created_at, amount_ml,
           drink_name, drink_id
    FROM waterlog
    WHERE user_id = $1 AND log_date = $2
    ORDER BY created_at ASC
  `,
    [userId, isoDate]
  );

  const goalRes = await db.query(
    `
    SELECT COALESCE(up.daily_water_target, u.daily_water_target, 2000) AS goal
    FROM "User" u
    LEFT JOIN UserProfile up ON up.user_id = u.user_id
    WHERE u.user_id = $1
  `,
    [userId]
  );

  const totalDay = hourlyRes.rows.reduce(
    (sum, item) => sum + Number(item.total_ml || 0),
    0
  );

  return {
    date: isoDate,
    goal_ml: Number(goalRes.rows[0]?.goal || 2000),
    total_ml: totalDay,
    hourly: hourlyRes.rows.map((row) => ({
      hour: row.hour,
      total_ml: Number(row.total_ml || 0),
    })),
    entries: entriesRes.rows.map((row) => ({
      created_at: row.created_at,
      amount_ml: Number(row.amount_ml || 0),
      drink_name: row.drink_name,
      drink_id: row.drink_id,
    })),
  };
}

module.exports = { createWaterEntry, getDrinkCatalog, getWaterTimeline };
