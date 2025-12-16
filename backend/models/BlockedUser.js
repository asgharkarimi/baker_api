const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const BlockedUser = sequelize.define('BlockedUser', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'user_id',
    references: { model: 'users', key: 'id' }
  },
  blockedUserId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    field: 'blocked_user_id',
    references: { model: 'users', key: 'id' }
  }
}, {
  tableName: 'blocked_users',
  indexes: [
    { unique: true, fields: ['user_id', 'blocked_user_id'] }
  ]
});

module.exports = BlockedUser;
