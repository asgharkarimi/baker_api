const express = require('express');
const router = express.Router();
const { User } = require('../models');
const { auth, adminAuth } = require('../middleware/auth');

// دریافت اطلاعات کاربر
router.get('/:id', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: ['id', 'name', 'phone', 'profileImage', 'createdAt']
    });
    if (!user) return res.status(404).json({ success: false, message: 'کاربر یافت نشد' });
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// لیست کاربران (ادمین)
router.get('/', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;

    const { count, rows } = await User.findAndCountAll({
      attributes: { exclude: ['password', 'verificationCode'] },
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
