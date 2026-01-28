const https = require('https');

// Fetch current weather from OpenWeatherMap (requires WEATHER_API_KEY in env)
// Returns parsed JSON on success, or throws an Error.
function fetchWeatherOpenWeather(city) {
  const apiKey = process.env.WEATHER_API_KEY;
  if (!apiKey) throw new Error('WEATHER_API_KEY not configured');
  const q = encodeURIComponent(city);
  const path = `/data/2.5/weather?q=${q}&appid=${apiKey}&units=metric&lang=vi`;
  const options = { hostname: 'api.openweathermap.org', path, method: 'GET' };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
            resolve(parsed);
          } else {
            const msg = parsed && parsed.message ? parsed.message : `HTTP ${res.statusCode}`;
            reject(new Error(`Weather API error: ${msg}`));
          }
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on('error', (err) => reject(err));
    req.end();
  });
}

async function fetchWeather(city) {
  if (!city || String(city).trim().length === 0) throw new Error('City is required');
  // normalize simple city names, trim
  const c = String(city).trim();
  return fetchWeatherOpenWeather(c);
}

module.exports = { fetchWeather };
