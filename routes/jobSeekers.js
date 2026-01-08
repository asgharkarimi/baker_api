const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { JobSeeker, User } = require('../models');
const { auth } = require('../middleware/auth');

// کش ساده برای کارجوها (5 دقیقه)
let seekersCache = null;
let seekersCacheTime = 0;
const CACHE_DURATION = 5 * 60 * 1000; // 5 دقیقه

// رزومه‌های من - باید قبل از /:id باشه
router.get('/my/list', auth, async (req, res) => {
  try {
    const seekers = await JobSeeker.findAll({ where: { userId: req.userId }, order: [['createdAt', 'DESC']] });
    res.json({ success: true, data: seekers });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// دریافت همه کارجویان
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, location, maxSalary, search } = req.query;
    
    // اگه بدون فیلتر و صفحه اول بود، از کش استفاده کن
    const noFilters = !location && !maxSalary && !search;
    const isFirstPage = Number(page) === 1;
    
    if (noFilters && isFirstPage && seekersCache && (Date.now() - seekersCacheTime < CACHE_DURATION)) {
      console.log('📦 Using cached job seekers');
      return res.json(seekersCache);
    }
    
    // فقط کارجوهای فعال و تایید شده توسط ادمین
    const where = { isActive: true, isApproved: true };

    if (location) where.location = { [Op.like]: `%${location}%` };
    if (maxSalary) where.expectedSalary = { [Op.lte]: maxSalary };
    if (search) where.name = { [Op.like]: `%${search}%` };

    const { count, rows } = await JobSeeker.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'phone', 'profileImage'] }],
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    const response = { success: true, data: rows, total: count, page: Number(page), pages: Math.ceil(count / limit) };
    
    // کش کردن نتیجه صفحه اول بدون فیلتر
    if (noFilters && isFirstPage) {
      seekersCache = response;
      seekersCacheTime = Date.now();
      console.log('💾 Cached job seekers');
    }

    res.json(response);
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// دریافت یک کارجو
router.get('/:id', async (req, res) => {
  try {
    const seeker = await JobSeeker.findByPk(req.params.id, {
      include: [{ model: User, as: 'user', attributes: ['id', 'name', 'phone', 'profileImage'] }]
    });
    if (!seeker) return res.status(404).json({ success: false, message: 'کارجو یافت نشد' });
    res.json({ success: true, data: seeker });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ثبت رزومه
router.post('/', auth, async (req, res) => {
  try {
    // چک کردن اینکه کاربر ادمین هست یا نه
    const user = await User.findByPk(req.userId);
    const isAdmin = user && (user.role === 'admin' || user.phone === '09199541276');
    
    const seeker = await JobSeeker.create({ 
      ...req.body, 
      userId: req.userId,
      isApproved: isAdmin
    });
    res.status(201).json({ success: true, data: seeker });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ویرایش رزومه
router.put('/:id', auth, async (req, res) => {
  try {
    const seeker = await JobSeeker.findOne({ where: { id: req.params.id, userId: req.userId } });
    if (!seeker) return res.status(404).json({ success: false, message: 'کارجو یافت نشد' });

    await seeker.update(req.body);
    res.json({ success: true, data: seeker });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// حذف رزومه
router.delete('/:id', auth, async (req, res) => {
  try {
    const deleted = await JobSeeker.destroy({ where: { id: req.params.id, userId: req.userId } });
    if (!deleted) return res.status(404).json({ success: false, message: 'کارجو یافت نشد' });
    res.json({ success: true, message: 'رزومه حذف شد' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
