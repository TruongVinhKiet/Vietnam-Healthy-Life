const jwt = require('jsonwebtoken');
const fs = require('fs');

// Create a test token for user 9
const token = jwt.sign(
  { user_id: 9, email: 'hello@gmail.com' }, 
  'change_this_secret',
  { expiresIn: '7d' }
);

fs.writeFileSync('admin_token.txt', token);
console.log('✓ Test token created for user 9');
console.log('Token:', token);
