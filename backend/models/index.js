const sequelize = require('../config/database');
const User = require('./User');
const JobAd = require('./JobAd');
const JobSeeker = require('./JobSeeker');
const BakeryAd = require('./BakeryAd');
const EquipmentAd = require('./EquipmentAd');
const Review = require('./Review');
const Chat = require('./Chat');
const Notification = require('./Notification');

// Associations
User.hasMany(JobAd, { foreignKey: 'userId', as: 'jobAds' });
JobAd.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(JobSeeker, { foreignKey: 'userId', as: 'jobSeekers' });
JobSeeker.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(BakeryAd, { foreignKey: 'userId', as: 'bakeryAds' });
BakeryAd.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(EquipmentAd, { foreignKey: 'userId', as: 'equipmentAds' });
EquipmentAd.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Review, { foreignKey: 'userId', as: 'reviews' });
Review.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Chat, { foreignKey: 'senderId', as: 'sentMessages' });
User.hasMany(Chat, { foreignKey: 'receiverId', as: 'receivedMessages' });
Chat.belongsTo(User, { foreignKey: 'senderId', as: 'sender' });
Chat.belongsTo(User, { foreignKey: 'receiverId', as: 'receiver' });

User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

module.exports = {
  sequelize,
  User,
  JobAd,
  JobSeeker,
  BakeryAd,
  EquipmentAd,
  Review,
  Chat,
  Notification
};
