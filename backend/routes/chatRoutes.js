const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const adminChatController = require('../controllers/adminChatController');
const authMiddleware = require('../utils/authMiddleware');
const multer = require('multer');
const path = require('path');

// Configure multer for image uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/chat');
  },
  filename: (req, file, cb) => {
    // Keep original filename for mock data matching
    cb(null, file.originalname);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (extname && mimetype) {
      return cb(null, true);
    }
    cb(new Error('Only image files are allowed'));
  }
});

// ============================================================
// CHATBOT ROUTES
// ============================================================

// Get or create chatbot conversation
router.get('/chatbot/conversation', authMiddleware, chatController.getOrCreateConversation);

// Get messages for a conversation
router.get('/chatbot/conversation/:conversationId/messages', authMiddleware, chatController.getMessages);

// Send text message
router.post('/chatbot/conversation/:conversationId/message', authMiddleware, chatController.sendMessage);

// Analyze food image (now accepts base64 in JSON body)
router.post('/chatbot/conversation/:conversationId/analyze-image', 
  authMiddleware, 
  chatController.analyzeFoodImage
);

// Approve/reject nutrition analysis
router.post('/chatbot/message/:messageId/approve', authMiddleware, chatController.approveNutrition);

// ============================================================
// ADMIN CHAT ROUTES
// ============================================================

// Get or create admin conversation
router.get('/admin-chat/conversation', authMiddleware, adminChatController.getOrCreateConversation);

// Get messages for admin conversation
router.get('/admin-chat/conversation/:conversationId/messages', authMiddleware, adminChatController.getMessages);

// Send message to admin
router.post('/admin-chat/conversation/:conversationId/message', authMiddleware, adminChatController.sendMessage);

// Get unread count
router.get('/admin-chat/unread-count', authMiddleware, adminChatController.getUnreadCount);

module.exports = router;
