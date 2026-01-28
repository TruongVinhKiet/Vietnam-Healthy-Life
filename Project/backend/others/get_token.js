const http = require('http');
const fs = require('fs');

const loginData = JSON.stringify({
  identifier: 'test@test.com',
  password: 'test'
});

const options = {
  hostname: 'localhost',
  port: 60491,
  path: '/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': loginData.length
  }
};

const req = http.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      if (response.token) {
        fs.writeFileSync('admin_token.txt', response.token);
        console.log('✓ Token saved to admin_token.txt');
        console.log('Token:', response.token);
      } else {
        console.log('✗ No token in response:', response);
      }
    } catch (e) {
      console.log('✗ Error parsing response:', data);
    }
  });
});

req.on('error', (e) => {
  console.log('✗ Request error:', e.message);
});

req.write(loginData);
req.end();
