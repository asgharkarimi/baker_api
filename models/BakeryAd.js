const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const BakeryAd = sequelize.define('BakeryAd', {
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
  type: {
    type: DataTypes.ENUM('sale', 'rent'),
    allowNull: false
  },
  salePrice: {
    type: DataTypes.BIGINT,
    field: 'sale_price'
  },
  rentDeposit: {
    type: DataTypes.BIGINT,
    field: 'rent_deposit'
  },
  monthlyRent: {
    type: DataTypes.BIGINT,
    field: 'monthly_rent'
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
  flourQuota: {
    type: DataTypes.INTEGER,
    field: 'flour_quota',
    comment: 'سهمیه آرد (کیسه در ماه)'
  },
  breadPrice: {
    type: DataTypes.INTEGER,
    field: 'bread_price',
    comment: 'قیمت نان (تومان)'
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
  tableName: 'bakery_ads'
});

module.exports = BakeryAd;
