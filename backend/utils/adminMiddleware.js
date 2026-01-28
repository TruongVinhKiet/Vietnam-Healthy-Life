const jwt = require('jsonwebtoken');
const adminService = require('../services/adminService');

const JWT_SECRET = process.env.JWT_SECRET || 'change_this_secret';

async function adminMiddleware(req, res, next) {
  const auth = req.headers['authorization'] || req.headers['Authorization'];
  if (!auth) return res.status(401).json({ error: 'Missing Authorization header' });

  const parts = auth.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') return res.status(401).json({ error: 'Invalid Authorization header format' });

  const token = parts[1];
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    // Debug logging for admin auth attempts
    console.log('[adminMiddleware] token payload:', { id: payload && payload.admin_id, role: payload && payload.role });
    if (!payload || payload.role !== 'admin') return res.status(403).json({ error: 'Admin access required' });
    const admin = await adminService.findById(payload.admin_id);
    if (!admin) return res.status(401).json({ error: 'Admin not found' });
    req.admin = admin;
    next();
  } catch (err) {
    console.error('adminMiddleware error', err.message);
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
}

module.exports = adminMiddleware;
