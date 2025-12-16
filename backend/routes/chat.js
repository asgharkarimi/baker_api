const express = require('express');
const router = express.Router();
const { Op } = require('sequelize');
const sequelize = require('../config/database');
const { Chat, User } = require('../models');
const { auth } = require('../middleware/auth');

// دریافت لیست مکالمات
router.get('/conversations', auth, async (req, res) => {
  try {
    const conversations = await Chat.findAll({
      where: {
        [Op.or]: [
          { senderId: req.userId },
          { receiverId: req.userId }
        ]
      },
      attributes: [
        [sequelize.fn('DISTINCT', sequelize.literal(`CASE WHEN sender_id = ${req.userId} THEN receiver_id ELSE sender_id END`)), 'partnerId']
      ],
      raw: true
    });

    const partnerIds = conversations.map(c => c.partnerId);
    const partners = await User.findAll({
      where: { id: partnerIds },
      attributes: ['id', 'name', 'phone', 'profileImage']
    });

    // Get last message for each conversation
    const result = await Promise.all(partners.map(async (partner) => {
      const lastMessage = await Chat.findOne({
        where: {
          [Op.or]: [
            { senderId: req.userId, receiverId: partner.id },
            { senderId: partner.id, receiverId: req.userId }
          ]
        },
        order: [['createdAt', 'DESC']]
      });

      const unreadCount = await Chat.count({
        where: { senderId: partner.id, receiverId: req.userId, isRead: false }
      });

      return {
        partner,
        lastMessage,
        unreadCount
      };
    }));

    res.json({ success: true, data: result });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// دریافت پیام‌های یک مکالمه
router.get('/messages/:recipientId', auth, async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    const recipientId = req.params.recipientId;

    const { count, rows } = await Chat.findAndCountAll({
      where: {
        [Op.or]: [
          { senderId: req.userId, receiverId: recipientId },
          { senderId: recipientId, receiverId: req.userId }
        ]
      },
      order: [['createdAt', 'DESC']],
      offset: (page - 1) * limit,
      limit: Number(limit)
    });

    // Mark as read
    await Chat.update(
      { isRead: true },
      { where: { senderId: recipientId, receiverId: req.userId, isRead: false } }
    );

    res.json({ success: true, data: rows.reverse(), total: count });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// ارسال پیام
router.post('/send', auth, async (req, res) => {
  try {
    const { receiverId, message } = req.body;

    const chat = await Chat.create({
      senderId: req.userId,
      receiverId,
      message
    });

    res.status(201).json({ success: true, data: chat });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
