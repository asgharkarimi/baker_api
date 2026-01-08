const { User } = require('../models');
const sequelize = require('../config/database');

async function createAdmin() {
  try {
    await sequelize.authenticate();
    console.log('✅ اتصال به دیتابیس برقرار شد');

    const phone = process.env.ADMIN_PHONE || '09199541276';
    const name = process.env.ADMIN_NAME || 'Admin';

    const existing = await User.findOne({ where: { phone } });
    if (existing) {
      await existing.update({ role: 'admin', isActive: true, isVerified: true });
      console.log('✅ کاربر موجود به ادمین تبدیل شد:', phone);
    } else {
      await User.create({ phone, name, role: 'admin', isActive: true, isVerified: true });
      console.log('✅ ادمین جدید ساخته شد:', phone);
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ خطا:', error.message);
    process.exit(1);
  }
}

createAdmin();
