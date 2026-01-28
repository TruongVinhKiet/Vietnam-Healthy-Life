const express = require("express");
const path = require("path");
const fs = require("fs");
const multer = require("multer");
const auth = require("../utils/authMiddleware");

// Ensure destination folder exists
const ensureDir = (dir) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

const storage = multer.diskStorage({
  destination: function (_req, _file, cb) {
    const uploadDir = path.join(__dirname, "..", "uploads", "background-image");
    ensureDir(uploadDir);
    cb(null, uploadDir);
  },
  filename: function (_req, file, cb) {
    const ext = path.extname(file.originalname) || ".jpg";
    const base =
      path.basename(file.originalname, ext).replace(/[^a-zA-Z0-9_-]/g, "_") ||
      "background";
    cb(null, `${base}_${Date.now()}${ext}`);
  },
});

const upload = multer({ storage });

const router = express.Router();

// POST /upload/background-image
// field name: image (multipart/form-data)
router.post(
  "/background-image",
  auth,
  upload.single("image"),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" });
      }

      const fileUrl = `/uploads/background-image/${req.file.filename}`;
      return res.status(201).json({
        success: true,
        url: fileUrl,
        image_url: fileUrl,
        filename: req.file.filename,
      });
    } catch (err) {
      console.error("[upload] background-image error:", err);
      return res.status(500).json({ error: "Failed to upload image" });
    }
  }
);

module.exports = router;

