const fs = require('fs').promises;
const path = require('path');

async function ensureDir(dir) {
  try {
    await fs.mkdir(dir, { recursive: true });
  } catch (err) {
    console.error('Failed to create upload directory:', err.message);
    throw err;
  }
}

exports.uploadBase64Image = async (req, res) => {
  try {
    const { image_data, folder = 'chat', filename } = req.body;

    if (!image_data) {
      return res.status(400).json({ error: 'No image data provided' });
    }

    const matches = image_data.match(/^data:image\/(\w+);base64,(.+)$/);
    if (!matches) {
      return res.status(400).json({ error: 'Invalid image format' });
    }

    const imageType = matches[1];
    const base64Data = matches[2];
    const buffer = Buffer.from(base64Data, 'base64');

    const safeFolder = folder.replace(/[^a-zA-Z0-9_-]/g, '');
    const uploadDir = path.join(__dirname, '..', 'uploads', safeFolder || 'chat');
    await ensureDir(uploadDir);

    const timestamp = Date.now();
    const safeFilename = filename
      ? filename.replace(/[^a-zA-Z0-9_-]/g, '_')
      : `${safeFolder || 'img'}_${timestamp}`;
    const finalFilename = `${safeFilename}_${timestamp}.${imageType}`;
    const filePath = path.join(uploadDir, finalFilename);

    await fs.writeFile(filePath, buffer);

    const imageUrl = `/uploads/${safeFolder || 'chat'}/${finalFilename}`;

    res.json({ success: true, imageUrl });
  } catch (error) {
    console.error('Error uploading image:', error);
    res.status(500).json({ error: 'Failed to upload image' });
  }
};

