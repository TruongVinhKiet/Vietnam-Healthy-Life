const db = require('../db');

const getWaterPeriodSummary = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { date } = req.query;

        // Always derive "today" using Vietnam time (UTC+7) **from the DB**,
        // so it is perfectly aligned with WaterLog.log_date and DailySummary.date.
        let targetDate = date;
        if (!targetDate) {
            const result = await db.query(
                "SELECT (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date::text AS date"
            );
            targetDate = result.rows[0].date;
        }

        console.log(`[waterSummary] Getting water summary for user ${userId}, date ${targetDate}`);

        // Get all water logs with drink info
        const logsResult = await db.query(
            `
            SELECT 
                wl.water_log_id,
                wl.amount_ml,
                wl.drink_id,
                wl.drink_name AS user_drink_name,
                wl.hydration_ratio,
                wl.notes,
                wl.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh' AS local_time,
                d.vietnamese_name AS drink_name_vi,
                d.name AS drink_name_en,
                d.image_url
            FROM waterlog wl
            LEFT JOIN Drink d ON wl.drink_id = d.drink_id
            WHERE wl.user_id = $1
              AND wl.log_date = $2
            ORDER BY wl.created_at DESC
            `,
            [userId, targetDate]
        );

        console.log(`[waterSummary] Found ${logsResult.rows.length} water logs`);

        // Get nutrients for all drinks
        const nutrientResult = await db.query(
            `
            SELECT 
                wl.water_log_id,
                n.nutrient_code,
                n.name AS nutrient_name,
                n.unit,
                COALESCE(dn.amount_per_100ml, 0) * wl.amount_ml / 100.0 AS amount
            FROM waterlog wl
            JOIN DrinkNutrient dn ON wl.drink_id = dn.drink_id
            JOIN Nutrient n ON dn.nutrient_id = n.nutrient_id
            WHERE wl.user_id = $1
              AND wl.log_date = $2
              AND wl.drink_id IS NOT NULL
              AND n.nutrient_code IS NOT NULL
            `,
            [userId, targetDate]
        );

        console.log(`[waterSummary] Found ${nutrientResult.rows.length} nutrient records`);

        // Map nutrients by water_log_id
        const nutrientByLog = new Map();
        const nutrientTotals = {};

        nutrientResult.rows.forEach(row => {
            const logId = row.water_log_id;
            
            // Store by log for individual entries
            if (!nutrientByLog.has(logId)) nutrientByLog.set(logId, []);
            nutrientByLog.get(logId).push({
                nutrient_code: row.nutrient_code,
                nutrient_name: row.nutrient_name,
                unit: row.unit,
                amount: parseFloat(row.amount) || 0,
            });

            // Aggregate totals
            if (!nutrientTotals[row.nutrient_code]) {
                nutrientTotals[row.nutrient_code] = {
                    nutrient_code: row.nutrient_code,
                    nutrient_name: row.nutrient_name,
                    unit: row.unit,
                    amount: 0,
                };
            }
            nutrientTotals[row.nutrient_code].amount += parseFloat(row.amount) || 0;
        });

        // Sort nutrients by amount
        nutrientByLog.forEach(list => {
            list.sort((a, b) => b.amount - a.amount);
        });

        const topNutrients = Object.values(nutrientTotals)
            .sort((a, b) => b.amount - a.amount)
            .slice(0, 5);

        // Build entries list
        const entries = logsResult.rows.map(log => {
            const amountMl = parseFloat(log.amount_ml) || 0;
            const nutrientList = nutrientByLog.get(log.water_log_id) || [];
            
            // Determine drink name: prefer DB name, fallback to user input, null if unknown
            let drinkName = null;
            if (log.drink_name_vi) {
                drinkName = log.drink_name_vi;
            } else if (log.user_drink_name && log.user_drink_name.trim()) {
                drinkName = log.user_drink_name.trim();
            } else if (log.drink_name_en) {
                drinkName = log.drink_name_en;
            }

            console.log(`[waterSummary] Log ${log.water_log_id}: drink_id=${log.drink_id}, user_name="${log.user_drink_name}", vi="${log.drink_name_vi}", en="${log.drink_name_en}" => "${drinkName}"`);

            return {
                water_log_id: log.water_log_id,
                amount_ml: amountMl,
                drink_id: log.drink_id,
                drink_name: drinkName,
                hydration_ratio: parseFloat(log.hydration_ratio) || 1.0,
                notes: log.notes,
                image_url: log.image_url,
                logged_at: log.local_time,
                nutrients: nutrientList.slice(0, 3), // Top 3 per entry
            };
        });

        // Get water goal
        const goalResult = await db.query(
            `
            SELECT COALESCE(up.daily_water_target, u.daily_water_target, 2000) AS goal_ml
            FROM "User" u
            LEFT JOIN UserProfile up ON up.user_id = u.user_id
            WHERE u.user_id = $1
            `,
            [userId]
        );

        const goalMl = parseInt(goalResult.rows[0]?.goal_ml) || 2000;
        const totalMl = entries.reduce((sum, e) => sum + e.amount_ml, 0);

        const responseData = {
            date: targetDate,
            goal_ml: goalMl,
            total_ml: totalMl,
            percentage: goalMl > 0 ? Math.round((totalMl / goalMl) * 100) : 0,
            entries: entries,
            top_nutrients: topNutrients,
        };

        console.log(`[waterSummary] Response: ${totalMl}ml / ${goalMl}ml (${responseData.percentage}%), ${entries.length} entries`);

        res.json(responseData);
    } catch (error) {
        console.error('[waterSummary] Error:', error);
        res.status(500).json({ error: 'Failed to get water summary' });
    }
};

module.exports = {
    getWaterPeriodSummary
};
