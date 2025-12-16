const express = require('express');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const { sequelize } = require('./models');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files - uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Static files - admin panel
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));

// API Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/job-ads', require('./routes/jobAds'));
app.use('/api/job-seekers', require('./routes/jobSeekers'));
app.use('/api/bakery-ads', require('./routes/bakeryAds'));
app.use('/api/equipment-ads', require('./routes/equipmentAds'));
app.use('/api/users', require('./routes/users'));
app.use('/api/reviews', require('./routes/reviews'));
app.use('/api/chat', require('./routes/chat'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/upload', require('./routes/upload'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/statistics', require('./routes/statistics'));

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'به API اپلیکیشن نانوایی خوش آمدید',
    version: '1.0.0',
    database: 'MySQL',
    endpoints: {
      auth: '/api/auth',
      jobAds: '/api/job-ads',
      jobSeekers: '/api/job-seekers',
      bakeryAds: '/api/bakery-ads',
      equipmentAds: '/api/equipment-ads',
      admin: '/admin'
    }
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'خطای سرور', error: err.message });
});

const PORT = process.env.PORT || 3000;

// Connect to MySQL and start server
sequelize.authenticate()
  .then(() => {
    console.log('✅ اتصال به MySQL برقرار شد');
    return sequelize.sync();
  })
  .then(() => {
    console.log('✅ جداول دیتابیس همگام‌سازی شدند');
    app.listen(PORT, () => {
      console.log(`🚀 سرور در پورت ${PORT} اجرا شد`);
      console.log(`📊 پنل مدیریت: http://localhost:${PORT}/admin`);
    });
  })
  .catch(err => {
    console.error('❌ خطا در اتصال به MySQL:', err.message);
    // Start server without DB for testing
    app.listen(PORT, () => {
      console.log(`🚀 سرور بدون دیتابیس در پورت ${PORT} اجرا شد`);
    });
  });
