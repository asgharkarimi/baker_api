const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const EquipmentAd = sequelize.define('EquipmentAd', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    field: 'user_id',
    references: { model: 'users', key: 'id' }
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT
  },
  price: {
    type: DataTypes.BIGINT,
    allowNull: false
  },
  condition: {
    type: DataTypes.ENUM('new', 'used'),
    defaultValue: 'used'
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false
  },
  province: {
    type: DataTypes.STRING
  },
  lat: {
    type: DataTypes.DECIMAL(10, 8)
  },
  lng: {
    type: DataTypes.DECIMAL(11, 8)
  },
  phoneNumber: {
    type: DataTypes.STRING(11),
    allowNull: false,
    field: 'phone_number'
  },
  images: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  videos: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    field: 'is_active'
  },
  isApproved: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_approved'
  },
  isPaid: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_paid'
  },
  views: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'equipment_ads'
});

module.exports = EquipmentAd;
