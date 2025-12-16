const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { adminAuth } = require('../middleware/auth');
const { User, JobAd, JobSeeker, BakeryAd, EquipmentAd, Review, Notification } = require('../models');

// ==================== داشبورد ====================
router.get('/dashboard', adminAuth, async (req, res) => {
  try {
    const [users, jobAds, jobSeekers, bakeryAds, equipmentAds, reviews] = await Promise.all([
      User.count(),
      JobAd.count(),
      JobSeeker.count(),
      BakeryAd.count(),
      EquipmentAd.count(),
      Review.count()
    ]);

    const recentUsers = await User.findAll({
      order: [['createdAt', 'DESC']],
      limit: 5,
      attributes: { exclude: ['password', 'verificationCode'] }
    });

    const recentJobAds = await JobAd.findAll({
      order: [['createdAt', 'DESC']],
      limit: 5,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }]
    });

    res.json({
      success: true,
      data: {
        counts: { users, jobAds, jobSeekers, bakeryAds, equipmentAds, reviews },
        recentUsers,
        recentJobAds
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== مدیریت کاربران ====================
router.get('/users', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, role, isActive } = req.query;
    const where = {};

    if (search) {
      where[Op.or] = [
        { name: { [Op.like]: `%${search}%` } },
        { phone: { [Op.like]: `%${search}%` } }
      ];
    }
    if (role) where.role = role;
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const { count, rows } = await User.findAndCountAll({
      where,
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

router.put('/users/:id', adminAuth, async (req, res) => {
  try {
    const { role, isActive, isVerified } = req.body;
    await User.update({ role, isActive, isVerified }, { where: { id: req.params.id } });
    const user = await User.findByPk(req.params.id, { attributes: { exclude: ['password'] } });
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/users/:id', adminAuth, async (req, res) => {
  try {
    await User.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'کاربر حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== مدیریت آگهی‌های شغلی ====================
router.get('/job-ads', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, isActive, isApproved } = req.query;
    const where = {};

    if (search) where.title = { [Op.like]: `%${search}%` };
    if (isActive !== undefined) where.isActive = isActive === 'true';
    if (isApproved !== undefined) where.isApproved = isApproved === 'true';

    const { count, rows } = await JobAd.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/job-ads/:id', adminAuth, async (req, res) => {
  try {
    await JobAd.update(req.body, { where: { id: req.params.id } });
    const ad = await JobAd.findByPk(req.params.id);
    res.json({ success: true, data: ad });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/job-ads/:id/approve', adminAuth, async (req, res) => {
  try {
    await JobAd.update({ isApproved: true }, { where: { id: req.params.id } });
    const ad = await JobAd.findByPk(req.params.id);

    await Notification.create({
      userId: ad.userId,
      title: 'آگهی تایید شد',
      message: `آگهی "${ad.title}" شما تایید شد`,
      type: 'success'
    });

    res.json({ success: true, data: ad });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/job-ads/:id', adminAuth, async (req, res) => {
  try {
    await JobAd.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'آگهی حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== مدیریت کارجویان ====================
router.get('/job-seekers', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, isActive } = req.query;
    const where = {};

    if (search) where.name = { [Op.like]: `%${search}%` };
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const { count, rows } = await JobSeeker.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/job-seekers/:id', adminAuth, async (req, res) => {
  try {
    await JobSeeker.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'کارجو حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== مدیریت آگهی‌های نانوایی ====================
router.get('/bakery-ads', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, type, isActive } = req.query;
    const where = {};

    if (search) where.title = { [Op.like]: `%${search}%` };
    if (type) where.type = type;
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const { count, rows } = await BakeryAd.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/bakery-ads/:id', adminAuth, async (req, res) => {
  try {
    await BakeryAd.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'آگهی حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== مدیریت آگهی‌های تجهیزات ====================
router.get('/equipment-ads', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, condition, isActive } = req.query;
    const where = {};

    if (search) where.title = { [Op.like]: `%${search}%` };
    if (condition) where.condition = condition;
    if (isActive !== undefined) where.isActive = isActive === 'true';

    const { count, rows } = await EquipmentAd.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/equipment-ads/:id', adminAuth, async (req, res) => {
  try {
    await EquipmentAd.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'آگهی حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== مدیریت نظرات ====================
router.get('/reviews', adminAuth, async (req, res) => {
  try {
    const { page = 1, limit = 20, isApproved } = req.query;
    const where = {};

    if (isApproved !== undefined) where.isApproved = isApproved === 'true';

    const { count, rows } = await Review.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.put('/reviews/:id/approve', adminAuth, async (req, res) => {
  try {
    await Review.update({ isApproved: true }, { where: { id: req.params.id } });
    const review = await Review.findByPk(req.params.id);
    res.json({ success: true, data: review });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

router.delete('/reviews/:id', adminAuth, async (req, res) => {
  try {
    await Review.destroy({ where: { id: req.params.id } });
    res.json({ success: true, message: 'نظر حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ==================== ارسال نوتیفیکیشن ====================
router.post('/notifications/send', adminAuth, async (req, res) => {
  try {
    const { userId, title, message, type = 'info' } = req.body;

    if (userId === 'all') {
      const users = await User.findAll({ where: { isActive: true }, attributes: ['id'] });
      const notifications = users.map(u => ({ userId: u.id, title, message, type }));
      await Notification.bulkCreate(notifications);
      res.json({ success: true, message: `نوتیفیکیشن به ${users.length} کاربر ارسال شد` });
    } else {
      await Notification.create({ userId, title, message, type });
      res.json({ success: true, message: 'نوتیفیکیشن ارسال شد' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
