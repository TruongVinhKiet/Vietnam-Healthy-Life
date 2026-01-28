/**
 * flexibleAuthMiddleware.js
 * Accept both user and admin tokens
 */

const jwt = require('jsonwebtoken');
const userService = require('../services/userService');
const adminService = require('../services/adminService');

const JWT_SECRET = process.env.JWT_SECRET || 'change_this_secret';

async function flexibleAuthMiddleware(req, res, next) {
  const auth = req.headers['authorization'] || req.headers['Authorization'];
  if (!auth) return res.status(401).json({ error: 'Missing Authorization header' });

  const parts = auth.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ error: 'Invalid Authorization header format' });
  }

  const token = parts[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    
    // Check if it's an admin token
    if (payload.role === 'admin' && payload.admin_id) {
      const admin = await adminService.findById(payload.admin_id);
      if (!admin) return res.status(401).json({ error: 'Admin not found' });
      req.admin = admin;
      req.isAdmin = true;
    } 
    // Otherwise it's a user token
    else if (payload.user_id) {
      const user = await userService.findById(payload.user_id);
      if (!user) return res.status(401).json({ error: 'User not found' });
      req.user = user;
      req.isAdmin = false;
    } 
    else {
      return res.status(401).json({ error: 'Invalid token payload' });
    }
    
    next();
  } catch (err) {
    console.error('flexibleAuthMiddleware error', err.message);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

module.exports = flexibleAuthMiddleware;
