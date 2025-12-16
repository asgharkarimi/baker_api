const express = require('express');
const router = express.Router();
const { Review, User } = require('../models');
const { auth } = require('../middleware/auth');

// دریافت نظرات یک آگهی
router.get('/:targetType/:targetId', async (req, res) => {
  try {
    const { targetType, targetId } = req.params;
    const { page = 1, limit = 20 } = req.query;

    const { count, rows } = await Review.findAndCountAll({
      where: { targetType, targetId, isApproved: true },
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'profileImage'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ثبت نظر
router.post('/', auth, async (req, res) => {
  try {
    const { targetType, targetId, rating, comment } = req.body;

    const review = await Review.create({
      userId: req.userId,
      targetType,
      targetId,
      rating,
      comment
    });

    res.status(201).json({ success: true, data: review });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// حذف نظر
router.delete('/:id', auth, async (req, res) => {
  try {
    const deleted = await Review.destroy({ where: { id: req.params.id, userId: req.userId } });
    if (!deleted) return res.status(404).json({ success: false, message: 'نظر یافت نشد' });
    res.json({ success: true, message: 'نظر حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
