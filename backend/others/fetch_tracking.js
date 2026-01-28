const http = require('http');

const options = {
  hostname: 'localhost',
  port: 60491,
  path: '/nutrients/tracking/daily',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

const req = http.request(options, res => {
  let data = '';
  res.on('data', chunk => { data += chunk; });
  res.on('end', () => {
    try {
      console.log('Status:', res.statusCode);
      const parsed = JSON.parse(data);
      console.log(JSON.stringify(parsed, null, 2).slice(0, 800));
    } catch (e) {
      console.error('Parse error', e, data);
    }
    process.exit(0);
  });
});

req.on('error', error => {
  console.error('Request error', error);
  process.exit(1);
});

req.end();
