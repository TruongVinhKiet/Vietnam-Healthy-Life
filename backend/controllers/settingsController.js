const settingService = require('../services/settingService');
const weatherService = require('../services/weatherService');

async function getSettings(req, res) {
  try {
    const userId = req.user.user_id;
    const row = await settingService.getSettings(userId);
    return res.json(row || {});
  } catch (err) {
    console.error('getSettings error', err);
    return res.status(500).json({ error: 'Server error' });
  }
}

async function updateSettings(req, res) {
  try {
    const userId = req.user.user_id;
    const payload = req.body || {};

    // Whitelist allowed fields
    const allowed = [
      'theme','language','font_size','unit_system',
      'seasonal_ui_enabled','seasonal_mode','seasonal_custom_bg','falling_leaves_enabled',
      'weather_enabled','weather_effects_enabled','weather_city','weather_last_update','weather_last_data','background_image_url','background_image_enabled',
      'effect_intensity','wind_direction',
      // nutrition/macro preferences
      'calorie_multiplier','macro_protein_pct','macro_fat_pct','macro_carb_pct',
      // meal distribution percentages (Breakfast/Lunch/Snack/Dinner)
      'meal_pct_breakfast','meal_pct_lunch','meal_pct_snack','meal_pct_dinner',
      // meal time settings (Breakfast/Lunch/Snack/Dinner)
      'meal_time_breakfast','meal_time_lunch','meal_time_snack','meal_time_dinner'
    ];
    const fields = {};
    for (const k of allowed) {
      if (Object.prototype.hasOwnProperty.call(payload, k)) fields[k] = payload[k];
    }

    // initial upsert
    const updated = await settingService.upsertSettings(userId, fields);

    // Log settings change activity
    try {
      const db = require('../db');
      await db.query(
        "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
        [userId, "settings_changed"]
      );
    } catch (e) {
      console.error("Failed to log settings_changed activity", e);
    }

    // If weather is enabled and city provided, try to fetch current weather and persist it
    try {
      if (fields.weather_enabled === true && fields.weather_city) {
        // Fetch live weather (requires WEATHER_API_KEY in env)
        const weather = await weatherService.fetchWeather(fields.weather_city);
        // store last update and last data
        await settingService.upsertSettings(userId, { weather_last_data: weather, weather_last_update: new Date() });
        // re-read updated settings to return full object
        const fresh = await settingService.getSettings(userId);
        return res.json(fresh);
      }
    } catch (we) {
      // Don't fail the entire request if weather fetch fails; log and return current settings
      console.error('weather fetch failed', we && we.message ? we.message : we);
      return res.json(updated);
    }

    return res.json(updated);
  } catch (err) {
    console.error('updateSettings error', err);
    return res.status(500).json({ error: 'Server error' });
  }
}

async function refreshWeather(req, res) {
  try {
    const userId = req.user.user_id;
    const payload = req.body || {};
    // prefer explicit city in body, else fall back to stored setting
    let city = payload.city;
    if (!city) {
      const current = await settingService.getSettings(userId);
      city = current && current.weather_city;
    }
    if (!city) return res.status(400).json({ error: 'weather city required' });

    try {
      const weather = await weatherService.fetchWeather(city);
      await settingService.upsertSettings(userId, { weather_last_data: weather, weather_last_update: new Date(), weather_city: city });
      const fresh = await settingService.getSettings(userId);
      return res.json(fresh);
    } catch (we) {
      console.error('refreshWeather fetch failed', we && we.message ? we.message : we);
      return res.status(502).json({ error: 'Failed to fetch weather', detail: we && we.message ? we.message : String(we) });
    }
  } catch (err) {
    console.error('refreshWeather error', err);
    return res.status(500).json({ error: 'Server error' });
  }
}

module.exports = { getSettings, updateSettings, refreshWeather };

