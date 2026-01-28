const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const adminService = require('../services/adminService');
const adminVerification = require('../services/adminVerificationService');
const nodemailer = require('nodemailer');
const adminImportService = require('../services/adminImportService');
const eventBus = require('../utils/eventBus');

function createTransporter() {
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    secure: process.env.SMTP_SECURE === 'true',
    auth: process.env.SMTP_USER
      ? { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS }
      : undefined,
  });
}

function buildEmailTemplate({ title, bodyLines, actionLabel, actionCode }) {
  const bodyHtml = bodyLines
    .map((line) => `<p style="margin:4px 0;color:#1f2937;">${line}</p>`)
    .join('');
  const actionHtml = actionCode
    ? `<div style="margin-top:12px;padding:12px 16px;border-radius:12px;background:#eef2ff;color:#111827;font-weight:700;display:inline-block;letter-spacing:3px;font-size:18px;">
        ${actionCode}
        <div style="font-size:12px;color:#4b5563;margin-top:4px;">${actionLabel || ''}</div>
      </div>`
    : '';
  const footer =
    '<p style="margin-top:16px;font-size:12px;color:#6b7280;">Nếu bạn không thực hiện yêu cầu này, hãy bỏ qua email hoặc liên hệ hỗ trợ.</p>';
  return `
  <div style="max-width:520px;margin:auto;padding:20px;font-family:Inter,Roboto,Arial,sans-serif;background:#f9fafb;border-radius:16px;border:1px solid #e5e7eb;">
    <h2 style="margin:0 0 12px;color:#111827;">${title}</h2>
    ${bodyHtml}
    ${actionHtml}
    ${footer}
  </div>`;
}

const JWT_SECRET = process.env.JWT_SECRET || 'change_this_secret';
const JWT_EXPIRES_IN = '7d';

async function login(req, res) {
  const { email, password } = req.body || {};
  if (!email || !password) return res.status(400).json({ error: 'Email và password là bắt buộc' });

  try {
    // lookup by username (the DB column is `username`) — frontend still sends email field
    const admin = await adminService.findByUsername(email);
    if (!admin) return res.status(401).json({ error: 'Không tìm thấy admin hoặc sai thông tin' });

    const ok = await bcrypt.compare(password, admin.password_hash);
    if (!ok) return res.status(401).json({ error: 'Không tìm thấy admin hoặc sai thông tin' });

  const token = jwt.sign({ admin_id: admin.admin_id, username: admin.username, role: 'admin' }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
  return res.json({ token, admin: { admin_id: admin.admin_id, username: admin.username } });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// export handlers (defined below)


async function register(req, res) {
  const { username, password, access_code } = req.body || {};
  const ADMIN_CODE = process.env.ADMIN_ACCESS_CODE || '123456';
  if (!username || !password || !access_code) return res.status(400).json({ error: 'username, password và access_code là bắt buộc' });
  if (access_code !== ADMIN_CODE) return res.status(403).json({ error: 'Mã cấp quyền không hợp lệ' });

  try {
    const existing = await adminService.findByUsername(username);
    if (existing) return res.status(409).json({ error: 'Admin đã tồn tại' });

    // create pending verification
    const bcryptLib = require('bcryptjs');
    const hashed = await bcryptLib.hash(password, 10);
    // generate 6-digit code
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
    await adminVerification.createPending({ username, password_hash: hashed, code, expires_at: expiresAt });

    // send email with code if SMTP configured, otherwise log to console
    const smtpHost = process.env.SMTP_HOST;
    if (smtpHost) {
      const html = buildEmailTemplate({
        title: 'Mã xác thực đăng ký quản trị viên',
        bodyLines: [
          `Xin chào ${username},`,
          'Bạn vừa đăng ký tài khoản quản trị. Nhập mã dưới đây để hoàn tất.',
          'Mã có hiệu lực 15 phút.',
        ],
        actionLabel: 'Nhập mã trên màn hình xác thực',
        actionCode: code,
      });
      try {
        const transporter = createTransporter();
        await transporter.sendMail({
          from: process.env.SMTP_FROM || 'no-reply@example.com',
          to: username,
          subject: '[VietNam Healthy Life] Mã xác thực quản trị viên',
          html,
          text: `Mã xác thực quản trị viên của bạn: ${code}. Mã có hiệu lực 15 phút.`,
        });
      } catch (mailErr) {
        console.error('Error sending admin verification email', mailErr);
        // fallback: log code
        console.log('Admin verification code for', username, ':', code);
      }
    } else {
      console.log('Admin verification code for', username, ':', code);
    }

    return res.status(202).json({ message: 'Verification code sent to email (or logged on server). Check your email and call /auth/admin/verify to complete registration.' });
  } catch (err) {
    console.error('admin register error', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// verify code and complete registration
async function verify(req, res) {
  const { username, code } = req.body || {};
  if (!username || !code) return res.status(400).json({ error: 'username và code là bắt buộc' });
  try {
    const pending = await adminVerification.findByUsernameAndCode(username, code);
    if (!pending) return res.status(400).json({ error: 'Mã không đúng hoặc đã hết hạn' });
    const now = new Date();
    if (new Date(pending.expires_at) < now) {
      // expired
      await adminVerification.deleteById(pending.verification_id);
      return res.status(400).json({ error: 'Mã đã hết hạn' });
    }
    // create admin record
    const created = await adminService.createAdmin({ username: pending.username, password_hash: pending.password_hash });
    // delete pending
    await adminVerification.deleteById(pending.verification_id);
    return res.status(201).json({ admin: { admin_id: created.admin_id, username: created.username } });
  } catch (err) {
    console.error('admin verify error', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// Admin-only bulk import of foods + nutrients
async function importFoods(req, res) {
  const payload = req.body && req.body.foods;
  if (!Array.isArray(payload)) return res.status(400).json({ error: 'Expected body { foods: [...] }' });
  try {
    const out = await adminImportService.bulkImportFoods(payload);
    return res.json(out);
  } catch (err) {
    console.error('admin importFoods error', err);
    return res.status(500).json({ error: 'Import failed' });
  }
}

module.exports = { login, register, verify, importFoods };
/**
 * Server-Sent Events endpoint for admin notifications (new user registered, unblock requests)
 * Usage: GET /admin/events (with admin auth)
 */
async function sse(req, res) {
  // Headers for SSE
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders && res.flushHeaders();

  const send = (type, data) => {
    res.write(`event: ${type}\n`);
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };

  // Initial hello
  send('hello', { t: Date.now() });

  const onUserRegistered = (payload) => send('user_registered', payload);
  const onUnblock = (payload) => send('unblock_request', payload);
  eventBus.on('user_registered', onUserRegistered);
  eventBus.on('unblock_request_submitted', onUnblock);

  req.on('close', () => {
    eventBus.off('user_registered', onUserRegistered);
    eventBus.off('unblock_request_submitted', onUnblock);
  });
}

/**
 * GET /admin/admins
 * Lấy danh sách tất cả admins (chỉ super_admin)
 */
async function getAllAdmins(req, res) {
  try {
    const db = require('../db');
    const result = await db.query(
      `SELECT admin_id, username, created_at 
       FROM admin 
       ORDER BY created_at DESC`
    );

    return res.json({
      success: true,
      admins: result.rows
    });
  } catch (error) {
    console.error('Get all admins error:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch admins'
    });
  }
}

module.exports.sse = sse;
module.exports.getAllAdmins = getAllAdmins;
