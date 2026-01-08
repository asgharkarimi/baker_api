const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const { auth, adminAuth } = require('../middleware/auth');
const { User, JobAd, JobSeeker, BakeryAd, EquipmentAd } = require('../models');

// آمار کلی (عمومی)
router.get('/', async (req, res) => {
  try {
    const [jobAdsCount, jobSeekersCount, bakeryAdsCount, equipmentAdsCount] = await Promise.all([
      JobAd.count({ where: { isActive: true } }),
      JobSeeker.count({ where: { isActive: true } }),
      BakeryAd.count({ where: { isActive: true } }),
      EquipmentAd.count({ where: { isActive: true } })
    ]);

    res.json({
      success: true,
      data: {
        totalJobAds: jobAdsCount,
        totalJobSeekers: jobSeekersCount,
        totalBakeryAds: bakeryAdsCount,
        totalEquipmentAds: equipmentAdsCount
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// آمار کامل (ادمین)
router.get('/admin', adminAuth, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const thisMonth = new Date();
    thisMonth.setDate(1);
    thisMonth.setHours(0, 0, 0, 0);

    const [
      totalUsers,
      activeUsers,
      newUsersToday,
      newUsersThisMonth,
      totalJobAds,
      activeJobAds,
      newJobAdsToday,
      totalJobSeekers,
      activeJobSeekers,
      totalBakeryAds,
      activeBakeryAds,
      totalEquipmentAds,
      activeEquipmentAds
    ] = await Promise.all([
      User.count(),
      User.count({ where: { isActive: true } }),
      User.count({ where: { createdAt: { [Op.gte]: today } } }),
      User.count({ where: { createdAt: { [Op.gte]: thisMonth } } }),
      JobAd.count(),
      JobAd.count({ where: { isActive: true } }),
      JobAd.count({ where: { createdAt: { [Op.gte]: today } } }),
      JobSeeker.count(),
      JobSeeker.count({ where: { isActive: true } }),
      BakeryAd.count(),
      BakeryAd.count({ where: { isActive: true } }),
      EquipmentAd.count(),
      EquipmentAd.count({ where: { isActive: true } })
    ]);

    res.json({
      success: true,
      data: {
        users: { total: totalUsers, active: activeUsers, newToday: newUsersToday, newThisMonth: newUsersThisMonth },
        jobAds: { total: totalJobAds, active: activeJobAds, newToday: newJobAdsToday },
        jobSeekers: { total: totalJobSeekers, active: activeJobSeekers },
        bakeryAds: { total: totalBakeryAds, active: activeBakeryAds },
        equipmentAds: { total: totalEquipmentAds, active: activeEquipmentAds }
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// آمار نمودار (ادمین)
router.get('/charts', adminAuth, async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 7;
    const data = [];

    for (let i = days - 1; i >= 0; i--) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      date.setHours(0, 0, 0, 0);

      const nextDate = new Date(date);
      nextDate.setDate(nextDate.getDate() + 1);

      const [users, jobAds, jobSeekers] = await Promise.all([
        User.count({ where: { createdAt: { [Op.gte]: date, [Op.lt]: nextDate } } }),
        JobAd.count({ where: { createdAt: { [Op.gte]: date, [Op.lt]: nextDate } } }),
        JobSeeker.count({ where: { createdAt: { [Op.gte]: date, [Op.lt]: nextDate } } })
      ]);

      data.push({
        date: date.toISOString().split('T')[0],
        users,
        jobAds,
        jobSeekers
      });
    }

    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
