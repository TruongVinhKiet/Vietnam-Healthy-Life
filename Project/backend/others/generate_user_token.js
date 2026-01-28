// Suppress all debug output
process.env.NODE_ENV = 'production';
const originalConsoleLog = console.log;
const originalConsoleError = console.error;
console.log = () => {};
console.error = () => {};

const db = require('./db');
const jwt = require('jsonwebtoken');

console.log = originalConsoleLog;
console.error = originalConsoleError;

async function generateToken() {
  try {
    const result = await db.query(
      'SELECT user_id, email FROM "User" WHERE email = $1',
      ['truonghoankiet1@gmail.com']
    );

    if (result.rows.length === 0) {
      process.stderr.write('User not found\n');
      process.exit(1);
    }

    const user = result.rows[0];
    const token = jwt.sign(
      {
        userId: user.user_id,
        email: user.email,
        role: 'user'
      },
      process.env.JWT_SECRET || 'default_secret',
      { expiresIn: '7d' }
    );

    // Output ONLY the token to stdout
    process.stdout.write(token);
    process.exit(0);
  } catch (error) {
    process.stderr.write(`Error: ${error}\n`);
    process.exit(1);
  }
}

generateToken();
