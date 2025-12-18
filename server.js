const express = require('express');
const cors = require('cors');
const path = require('path');
const dotenv = require('dotenv');
const http = require('http');
const { Server } = require('socket.io');

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*', methods: ['GET', 'POST'] }
});

const { sequelize } = require('./models');

// ذخیره کاربران آنلاین
const onlineUsers = new Map();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));

// Admin panel route - redirect /admin to /admin/index.html
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'public/admin/index.html'));
});

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

// WebSocket Events
io.on('connection', (socket) => {
  console.log('🔌 User connected:', socket.id);

  // ثبت کاربر
  socket.on('register', (userId) => {
    onlineUsers.set(userId, socket.id);
    console.log(`👤 User ${userId} registered with socket ${socket.id}`);
  });

  // ارسال پیام
  socket.on('sendMessage', (data) => {
    const { receiverId, message, senderId, messageType, mediaUrl, isEncrypted } = data;
    const receiverSocket = onlineUsers.get(receiverId);
    
    console.log(`📨 Message from ${senderId} to ${receiverId}`);
    
    if (receiverSocket) {
      io.to(receiverSocket).emit('newMessage', {
        senderId,
        message,
        messageType: messageType || 'text',
        mediaUrl,
        isEncrypted,
        createdAt: new Date().toISOString()
      });
      console.log(`✅ Message delivered to ${receiverId}`);
    } else {
      console.log(`⚠️ User ${receiverId} is offline`);
    }
  });

  // تایپ کردن
  socket.on('typing', ({ senderId, receiverId }) => {
    const receiverSocket = onlineUsers.get(receiverId);
    if (receiverSocket) {
      io.to(receiverSocket).emit('userTyping', { senderId });
    }
  });

  // قطع اتصال
  socket.on('disconnect', () => {
    for (const [userId, socketId] of onlineUsers.entries()) {
      if (socketId === socket.id) {
        onlineUsers.delete(userId);
        console.log(`👋 User ${userId} disconnected`);
        break;
      }
    }
  });
});

// Export io for use in routes
app.set('io', io);
app.set('onlineUsers', onlineUsers);

// Root route
app.get('/', (req, res) => {
  res.json({
    message: 'به API اپلیکیشن نانوایی خوش آمدید',
    version: '1.0.0',
    websocket: 'enabled',
    endpoints: {
      auth: '/api/auth',
      jobAds: '/api/job-ads',
      chat: '/api/chat (+ WebSocket)'
    }
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'خطای سرور', error: err.message });
});

const PORT = process.env.PORT || 3000;

sequelize.authenticate()
  .then(() => {
    console.log('✅ اتصال به MySQL برقرار شد');
    return sequelize.sync();
  })
  .then(() => {
    console.log('✅ جداول دیتابیس همگام‌سازی شدند');
    server.listen(PORT, () => {
      console.log(`🚀 سرور در پورت ${PORT} اجرا شد`);
      console.log(`🔌 WebSocket فعال است`);
      console.log(`📊 پنل مدیریت: http://localhost:${PORT}/admin`);
    });
  })
  .catch(err => {
    console.error('❌ خطا در اتصال به MySQL:', err.message);
    server.listen(PORT, () => {
      console.log(`🚀 سرور بدون دیتابیس در پورت ${PORT} اجرا شد`);
    });
  });
