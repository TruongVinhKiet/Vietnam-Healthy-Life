/**
 * imageUploadController.js
 * Handle image uploads for dishes
 */

const fs = require('fs').promises;
const path = require('path');

// Create uploads directory if not exists
const UPLOAD_DIR = path.join(__dirname, '..', 'uploads', 'dishes');

async function ensureUploadDir() {
  try {
    await fs.mkdir(UPLOAD_DIR, { recursive: true });
  } catch (err) {
    console.error('Failed to create upload directory:', err);
  }
}

ensureUploadDir();

/**
 * Upload dish image (base64)
 * POST /api/dishes/upload-image
 */
async function uploadDishImage(req, res) {
  try {
    const { imageData, filename } = req.body;

    if (!imageData) {
      return res.status(400).json({ error: 'No image data provided' });
    }

    // Extract base64 data
    const matches = imageData.match(/^data:image\/(\w+);base64,(.+)$/);
    if (!matches) {
      return res.status(400).json({ error: 'Invalid image format' });
    }

    const imageType = matches[1]; // png, jpg, etc.
    const base64Data = matches[2];
    const buffer = Buffer.from(base64Data, 'base64');

    // Generate unique filename
    const timestamp = Date.now();
    const safeFilename = filename 
      ? filename.replace(/[^a-zA-Z0-9_-]/g, '_')
      : `dish_${timestamp}`;
    const finalFilename = `${safeFilename}_${timestamp}.${imageType}`;
    const filePath = path.join(UPLOAD_DIR, finalFilename);

    // Save file
    await fs.writeFile(filePath, buffer);

    // Return URL (relative path for serving)
    const imageUrl = `/uploads/dishes/${finalFilename}`;

    res.json({
      success: true,
      imageUrl,
      filename: finalFilename
    });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ error: 'Failed to upload image' });
  }
}

/**
 * Delete dish image
 * DELETE /api/dishes/delete-image
 */
async function deleteDishImage(req, res) {
  try {
    const { imageUrl } = req.body;

    if (!imageUrl) {
      return res.status(400).json({ error: 'No image URL provided' });
    }

    // Extract filename from URL
    const filename = path.basename(imageUrl);
    const filePath = path.join(UPLOAD_DIR, filename);

    // Check if file exists and delete
    try {
      await fs.unlink(filePath);
      res.json({ success: true, message: 'Image deleted' });
    } catch (err) {
      if (err.code === 'ENOENT') {
        res.json({ success: true, message: 'Image not found (already deleted)' });
      } else {
        throw err;
      }
    }
  } catch (error) {
    console.error('Error deleting image:', error);
    res.status(500).json({ error: 'Failed to delete image' });
  }
}

module.exports = {
  uploadDishImage,
  deleteDishImage
};
