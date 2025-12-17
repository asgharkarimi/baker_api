const express = require('express');
const router = express.Router();
const { Notification } = require('../models');
const { auth } = require('../middleware/auth');

// دریافت نوتیفیکیشن‌ها
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    const { count, rows } = await Notification.findAndCountAll({
      where: { userId: req.userId },
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    const unreadCount = await Notification.count({ where: { userId: req.userId, isRead: false } });

    res.json({ success: true, data: rows, total: count, unreadCount });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// علامت‌گذاری به عنوان خوانده شده
router.put('/:id/read', auth, async (req, res) => {
  try {
    await Notification.update({ isRead: true }, { where: { id: req.params.id, userId: req.userId } });
    const notification = await Notification.findByPk(req.params.id);
    res.json({ success: true, data: notification });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// علامت‌گذاری همه به عنوان خوانده شده
router.put('/read-all', auth, async (req, res) => {
  try {
    await Notification.update({ isRead: true }, { where: { userId: req.userId } });
    res.json({ success: true, message: 'همه نوتیفیکیشن‌ها خوانده شدند' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// حذف نوتیفیکیشن
router.delete('/:id', auth, async (req, res) => {
  try {
    await Notification.destroy({ where: { id: req.params.id, userId: req.userId } });
    res.json({ success: true, message: 'نوتیفیکیشن حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// حذف همه
router.delete('/', auth, async (req, res) => {
  try {
    await Notification.destroy({ where: { userId: req.userId } });
    res.json({ success: true, message: 'همه نوتیفیکیشن‌ها حذف شدند' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
