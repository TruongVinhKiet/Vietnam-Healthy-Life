const drinkService = require('../services/drinkService');

async function listAdminDrinks(req, res) {
  try {
    const isTemplateQuery = req.query.isTemplate ?? req.query.is_template;
    const isPublicQuery = req.query.isPublic ?? req.query.is_public;

    const filters = {
      isTemplate:
        isTemplateQuery === 'true'
          ? true
          : isTemplateQuery === 'false'
          ? false
          : undefined,
      isPublic:
        isPublicQuery === 'true'
          ? true
          : isPublicQuery === 'false'
          ? false
          : undefined,
      category: req.query.category,
      search: req.query.search,
      limit: req.query.limit ? parseInt(req.query.limit, 10) : undefined,
      offset: req.query.offset ? parseInt(req.query.offset, 10) : undefined,
    };

    const drinks = await drinkService.listAdminDrinks(filters);
    res.json({ success: true, drinks });
  } catch (err) {
    console.error('[drinkController] listAdminDrinks error', err);
    res.status(500).json({ error: 'Failed to load drinks' });
  }
}

async function getDrinkDetails(req, res) {
  try {
    const drinkId = parseInt(req.params.id, 10);
    if (!drinkId) return res.status(400).json({ error: 'Invalid drink id' });
    const drink = await drinkService.getDrinkDetail(drinkId, null, {
      bypassVisibility: true,
    });
    if (!drink) {
      return res.status(404).json({ error: 'Drink not found' });
    }
    res.json({ success: true, drink });
  } catch (err) {
    console.error('[drinkController] getDrinkDetails error', err);
    res.status(500).json({ error: 'Failed to load drink details' });
  }
}

async function upsertDrink(req, res) {
  try {
    const payload = req.body || {};
    const isUpdate = req.method === 'PUT' && req.params.id;
    // If this is a PUT request, include drink_id from URL params
    if (isUpdate) {
      payload.drink_id = parseInt(req.params.id, 10);
    }
    const drink = await drinkService.upsertDrink(payload, req.admin?.admin_id);
    
    // Log drink activity (create or update)
    if (req.user && req.user.user_id) {
      try {
        const db = require('../db');
        const action = isUpdate ? 'drink_updated' : 'drink_created';
        await db.query(
          "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
          [req.user.user_id, action]
        );
      } catch (e) {
        console.error("Failed to log drink activity", e);
      }
    }
    
    res.json({ success: true, drink });
  } catch (err) {
    console.error('[drinkController] upsertDrink error', err);
    res.status(400).json({ error: err.message || 'Failed to save drink' });
  }
}

async function deleteDrink(req, res) {
  try {
    const drinkId = parseInt(req.params.id, 10);
    if (!drinkId) {
      return res.status(400).json({ error: 'Invalid drink id' });
    }

    // Lấy thông tin drink hiện tại để biết tên tiếng Việt
    const existingDrink = await drinkService.getDrinkById(drinkId);
    if (!existingDrink) {
      return res.status(404).json({ error: 'Drink not found' });
    }

    await drinkService.deleteDrink(drinkId);

    // Đồng bộ: xóa TẤT CẢ các bản ghi AI_Analyzed_Meals có cùng tên với drink này
    // Xóa cả những cards đã được link và những cards chưa được link nhưng có cùng tên
    try {
      const db = require('../db');
      const vnName = existingDrink.vietnamese_name || existingDrink.name;
      if (vnName) {
        const result = await db.query(
          `
          DELETE FROM AI_Analyzed_Meals
          WHERE linked_drink_id = $1
             OR (item_type = 'drink' AND LOWER(TRIM(item_name)) = LOWER(TRIM($2)))
        `,
          [drinkId, vnName]
        );
        console.log(`[drinkController] Deleted AI cards for drink "${vnName}" (drinkId: ${drinkId})`);
      } else {
        await db.query(
          `DELETE FROM AI_Analyzed_Meals WHERE linked_drink_id = $1`,
          [drinkId]
        );
        console.log(`[drinkController] Deleted AI cards linked to drinkId: ${drinkId}`);
      }
    } catch (aiErr) {
      console.error('[drinkController] Failed to sync AI_Analyzed_Meals on drink delete:', aiErr);
    }
    
    // Log drink delete activity
    if (req.user && req.user.user_id) {
      try {
        const db = require('../db');
        await db.query(
          "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
          [req.user.user_id, "drink_deleted"]
        );
      } catch (e) {
        console.error("Failed to log drink_deleted activity", e);
      }
    }
    
    res.json({ success: true });
  } catch (err) {
    console.error('[drinkController] deleteDrink error', err);
    res.status(500).json({ error: 'Failed to delete drink' });
  }
}

async function checkNameExists(req, res) {
  try {
    const { name, vietnamese_name, drink_id } = req.query;
    const exists = await drinkService.checkNameExists({
      name,
      vietnamese_name,
      excludeDrinkId: drink_id ? parseInt(drink_id, 10) : null,
    });
    res.json({ exists, success: true });
  } catch (err) {
    console.error('[drinkController] checkNameExists error', err);
    res.status(500).json({ error: 'Failed to check name' });
  }
}

async function approveUserDrink(req, res) {
  try {
    const drinkId = parseInt(req.params.id, 10);
    if (!drinkId) {
      return res.status(400).json({ error: 'Invalid drink id' });
    }

    const updated = await drinkService.approveUserDrink(
      drinkId,
      req.admin?.admin_id
    );

    if (!updated) {
      return res.status(404).json({ error: 'Drink not found' });
    }

    return res.json({ success: true, drink: updated });
  } catch (err) {
    console.error('[drinkController] approveUserDrink error', err);
    return res.status(500).json({ error: 'Failed to approve drink' });
  }
}

module.exports = {
  listAdminDrinks,
  getDrinkDetails,
  upsertDrink,
  deleteDrink,
  checkNameExists,
  approveUserDrink,
};

