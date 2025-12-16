const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { uploadImage, uploadVideo, uploadMultiple } = require('../middleware/upload');
const path = require('path');
const fs = require('fs');

// آپلود تک عکس
router.post('/image', auth, uploadImage.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'فایلی انتخاب نشده' });
    }
    
    const fileUrl = `/uploads/images/${req.file.filename}`;
    res.json({ 
      success: true, 
      data: { 
        url: fileUrl,
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// آپلود چند عکس
router.post('/images', auth, uploadMultiple.array('images', 10), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'فایلی انتخاب نشده' });
    }
    
    const files = req.files.map(file => ({
      url: `/uploads/images/${file.filename}`,
      filename: file.filename,
      originalName: file.originalname,
      size: file.size
    }));
    
    res.json({ success: true, data: files });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// آپلود ویدیو
router.post('/video', auth, uploadVideo.single('video'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'فایلی انتخاب نشده' });
    }
    
    const fileUrl = `/uploads/videos/${req.file.filename}`;
    res.json({ 
      success: true, 
      data: { 
        url: fileUrl,
        filename: req.file.filename,
        originalName: req.file.originalname,
        size: req.file.size
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// حذف فایل
router.delete('/:type/:filename', auth, async (req, res) => {
  try {
    const { type, filename } = req.params;
    const validTypes = ['images', 'videos'];
    
    if (!validTypes.includes(type)) {
      return res.status(400).json({ success: false, message: 'نوع فایل نامعتبر' });
    }
    
    const filePath = path.join(__dirname, '..', 'uploads', type, filename);
    
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      res.json({ success: true, message: 'فایل حذف شد' });
    } else {
      res.status(404).json({ success: false, message: 'فایل یافت نشد' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
