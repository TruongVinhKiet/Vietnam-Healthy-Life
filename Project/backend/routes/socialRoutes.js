const express = require('express');
const router = express.Router();
const socialController = require('../controllers/socialController');
const uploadController = require('../controllers/uploadController');
const authMiddleware = require('../utils/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// Community chat
router.get('/community/messages', socialController.getCommunityMessages);
router.post('/community/messages', socialController.postCommunityMessage);

// Message reactions
router.post('/messages/react', socialController.reactToMessage);

// Friend requests
router.post('/friends/request', socialController.sendFriendRequest);
router.get('/friends/requests', socialController.getFriendRequests);
router.post('/friends/requests/:request_id/respond', socialController.respondToFriendRequest);

// Friends
router.get('/friends', socialController.getFriends);

// Private messaging
router.get('/conversations/:friend_id', socialController.getOrCreatePrivateConversation);
router.get('/conversations/:conversation_id/messages', socialController.getPrivateMessages);
router.post('/conversations/:conversation_id/messages', socialController.sendPrivateMessage);

// User body measurements (for friends)
router.get('/users/:user_id/body-measurements', socialController.getUserBodyMeasurements);

// Image upload (avatars, community images, etc.)
router.post('/upload-image', uploadController.uploadBase64Image);

module.exports = router;

