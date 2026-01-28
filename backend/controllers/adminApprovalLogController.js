const db = require('../db');

async function listApprovalLogs(req, res) {
  try {
    const {
      admin_id,
      item_type,
      item_id,
      item_name,
      action,
      start_date,
      end_date,
      limit = 50,
      offset = 0,
    } = req.query;

    const conditions = [];
    const params = [];
    let i = 1;

    if (admin_id) {
      conditions.push(`l.admin_id = $${i++}`);
      params.push(parseInt(admin_id, 10));
    }

    if (item_type) {
      conditions.push(`l.item_type = $${i++}`);
      params.push(String(item_type));
    }

    if (item_id) {
      const parsedItemId = parseInt(item_id, 10);
      if (!Number.isNaN(parsedItemId)) {
        conditions.push(`l.item_id = $${i++}`);
        params.push(parsedItemId);
      }
    }

    if (item_name) {
      conditions.push(`COALESCE(l.item_name, '') ILIKE $${i++}`);
      params.push(`%${String(item_name)}%`);
    }

    if (action) {
      conditions.push(`l.action = $${i++}`);
      params.push(String(action));
    }

    if (start_date) {
      conditions.push(`l.created_at >= $${i++}`);
      params.push(start_date);
    }

    if (end_date) {
      conditions.push(`l.created_at <= $${i++}`);
      params.push(end_date);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const listQuery = `
      SELECT
        l.log_id,
        l.admin_id,
        a.username AS admin_username,
        l.action,
        l.item_type,
        l.item_id,
        l.item_name,
        l.created_by_user,
        u.full_name AS user_full_name,
        u.email AS user_email,
        l.created_at
      FROM admin_approval_log l
      LEFT JOIN admin a ON a.admin_id = l.admin_id
      LEFT JOIN "User" u ON u.user_id = l.created_by_user
      ${where}
      ORDER BY l.created_at DESC
      LIMIT $${i++} OFFSET $${i++}
    `;

    const countQuery = `
      SELECT COUNT(*)::INT AS total
      FROM admin_approval_log l
      ${where}
    `;

    const limitNum = Math.min(Math.max(parseInt(limit, 10) || 50, 1), 200);
    const offsetNum = Math.max(parseInt(offset, 10) || 0, 0);

    const listParams = params.concat([limitNum, offsetNum]);

    const [listRes, countRes] = await Promise.all([
      db.query(listQuery, listParams),
      db.query(countQuery, params),
    ]);

    return res.json({
      success: true,
      data: listRes.rows,
      total: countRes.rows[0] ? countRes.rows[0].total : 0,
      limit: limitNum,
      offset: offsetNum,
    });
  } catch (err) {
    console.error('[adminApprovalLogController] listApprovalLogs error', err);
    return res.status(500).json({ error: 'Failed to load approval logs' });
  }
}

module.exports = {
  listApprovalLogs,
};
