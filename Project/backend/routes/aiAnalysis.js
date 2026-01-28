const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const auth = require('../utils/authMiddleware');
const ctrl = require('../controllers/aiAnalysisController');

// ============================================================
// MULTER CONFIGURATION - Upload ảnh vào uploads/ai_analysis/
// ============================================================
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = path.join(__dirname, '../uploads/ai_analysis');
    
    // Tạo thư mục nếu chưa có
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    // Keep original filename for mock data matching
    const originalName = file.originalname;
    cb(null, originalName);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB max
  },
  fileFilter: function (req, file, cb) {
    // Chỉ chấp nhận ảnh
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Chỉ chấp nhận file ảnh (JPEG, PNG, GIF, WEBP)'));
    }
  }
});

// ============================================================
// ROUTES
// ============================================================

/**
 * POST /api/ai-analyze-image
 * Phân tích hình ảnh thức ăn/đồ uống bằng AI
 * Body: multipart/form-data với field "image"
 */
router.post('/analyze-image', auth, upload.single('image'), ctrl.analyzeImage);

/**
 * POST /api/ai-analyzed-meals/:id/accept
 * Chấp nhận kết quả phân tích và cập nhật vào hệ thống
 */
router.post('/ai-analyzed-meals/:id/accept', auth, ctrl.acceptAnalysis);

/**
 * DELETE /api/ai-analyzed-meals/:id
 * Từ chối và xóa kết quả phân tích
 */
router.delete('/ai-analyzed-meals/:id', auth, ctrl.rejectAnalysis);

/**
 * GET /api/ai-analyzed-meals
 * Lấy danh sách meals đã phân tích bởi AI
 * Query params: ?accepted=true/false&limit=50&offset=0
 */
router.get('/ai-analyzed-meals', auth, ctrl.getAnalyzedMeals);

module.exports = router;
