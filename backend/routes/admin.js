const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const sequelize = require('../config/database');
const { adminAuth } = require('../middleware/auth');
const { User, JobAd, JobSeeker, BakeryAd, EquipmentAd, Review, Notification, Chat } = require('../models');

// ==================== داشبورد ====================
router.get('/dashboard', adminAuth, async (req, res) => {
  try {
    // آمار کلی
    const [users, jobAds, jobSeekers, bakeryAds, equipmentAds, reviews, chats] = await Promise.all([
      User.count(),
      JobAd.count(),
      JobSeeker.count(),
      BakeryAd.count(),
      EquipmentAd.count(),
      Review.count(),
      Chat.count()
    ]);

    // آمار در انتظار تایید
    const [pendingJobAds, pendingJobSeekers] = await Promise.all([
      JobAd.count({ where: { isApproved: false } }),
      JobSeeker.count({ where: { isApproved: false } })
    ]);

    // کاربران آنلاین
    const onlineUsers = await User.count({ where: { isOnline: true } });

    // آمار امروز
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const [todayUsers, todayJobAds, todayJobSeekers, todayChats] = await Promise.all([
      User.count({ where: { createdAt: { [Op.gte]: today } } }),
      JobAd.count({ where: { createdAt: { [Op.gte]: today } } }),
      JobSeeker.count({ where: { createdAt: { [Op.gte]: today } } }),
      Chat.count({ where: { createdAt: { [Op.gte]: today } } })
    ]);

    // آمار هفته گذشته (روزانه)
    const weeklyStats = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);
      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);

      const [dayUsers, dayJobAds, dayJobSeekers] = await Promise.all([
        User.count({ where: { createdAt: { [Op.gte]: date, [Op.lt]: nextDate } } }),
        JobAd.count({ where: { createdAt: { [Op.gte]: date, [Op.lt]: nextDate } } }),
        JobSeeker.count({ where: { createdAt: { [Op.gte]: date, [Op.lt]: nextDate } } })
      ]);

      weeklyStats.push({
        date: date.toLocaleDateString('fa-IR', { weekday: 'short' }),
        users: dayUsers,
        jobAds: dayJobAds,
        jobSeekers: dayJobSeekers
      });
    }

    // آخرین کاربران
    const recentUsers = await User.findAll({
      order: [['createdAt', 'DESC']],
      limit: 5,
      attributes: { exclude: ['password', 'verificationCode'] }
    });

    // آخرین آگهی‌ها
    const recentJobAds = await JobAd.findAll({
      order: [['createdAt', 'DESC']],
      limit: 5,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }]
    });

    // آمار استان‌ها
    const locationStats = await JobAd.findAll({
      attributes: ['location', [sequelize.fn('COUNT', sequelize.col('location')), 'count']],
      group: ['location'],
      order: [[sequelize.literal('count'), 'DESC']],
      limit: 5
    });

    res.json({
      success: true,
      data: {
        counts: { users, jobAds, jobSeekers, bakeryAds, equipmentAds, reviews, chats },
        pending: { jobAds: pendingJobAds, jobSeekers: pendingJobSeekers },
        onlineUsers,
        today: { users: todayUsers, jobAds: todayJobAds, jobSeekers: todayJobSeekers, chats: todayChats },
        weeklyStats,
        locationStats: locationStats.map(l => ({ location: l.location, count: l.get('count') })),
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
    if (isActive === 'true' || isActive === 'false') where.isActive = isActive === 'true';
    if (isApproved === 'true' || isApproved === 'false') where.isApproved = isApproved === 'true';

    console.log('📋 Admin job-ads query:', { page, search, isActive, isApproved, where });

    const { count, rows } = await JobAd.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    console.log('📋 Found job ads:', count);
    res.json({ success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) });
  } catch (error) {
    console.error('❌ Error:', error.message);
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
    const { page = 1, limit = 20, search, isActive, isApproved } = req.query;
    const where = {};

    if (search) where.name = { [Op.like]: `%${search}%` };
    if (isActive === 'true' || isActive === 'false') where.isActive = isActive === 'true';
    if (isApproved === 'true' || isApproved === 'false') where.isApproved = isApproved === 'true';

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

router.put('/job-seekers/:id/approve', adminAuth, async (req, res) => {
  try {
    await JobSeeker.update({ isApproved: true }, { where: { id: req.params.id } });
    const seeker = await JobSeeker.findByPk(req.params.id);

    await Notification.create({
      userId: seeker.userId,
      title: 'پروفایل تایید شد',
      message: 'پروفایل کارجوی شما تایید شد',
      type: 'success'
    });

    res.json({ success: true, data: seeker });
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

// ==================== پاک کردن کل دیتابیس ====================
router.delete('/reset-database', adminAuth, async (req, res) => {
  try {
    // پاک کردن با ترتیب صحیح (اول جداول وابسته)
    await Chat.destroy({ where: {} });
    await Notification.destroy({ where: {} });
    await Review.destroy({ where: {} });
    await JobAd.destroy({ where: {} });
    await JobSeeker.destroy({ where: {} });
    await BakeryAd.destroy({ where: {} });
    await EquipmentAd.destroy({ where: {} });
    await User.destroy({ where: {} });
    
    res.json({ success: true, message: 'دیتابیس با موفقیت پاک شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// پاک کردن فقط داده‌ها (بدون کاربران)
router.delete('/clear-data', adminAuth, async (req, res) => {
  try {
    await Chat.destroy({ where: {} });
    await Notification.destroy({ where: {} });
    await Review.destroy({ where: {} });
    await JobAd.destroy({ where: {} });
    await JobSeeker.destroy({ where: {} });
    await BakeryAd.destroy({ where: {} });
    await EquipmentAd.destroy({ where: {} });
    
    res.json({ success: true, message: 'داده‌ها پاک شدند (کاربران حفظ شدند)' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
