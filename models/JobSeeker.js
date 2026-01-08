const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const JobSeeker = sequelize.define('JobSeeker', {
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
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  age: {
    type: DataTypes.INTEGER
  },
  experience: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  skills: {
    type: DataTypes.JSON,
    defaultValue: []
  },
  expectedSalary: {
    type: DataTypes.BIGINT,
    field: 'expected_salary'
  },
  location: {
    type: DataTypes.STRING
  },
  province: {
    type: DataTypes.STRING
  },
  phoneNumber: {
    type: DataTypes.STRING(11),
    field: 'phone_number'
  },
  description: {
    type: DataTypes.TEXT
  },
  profileImage: {
    type: DataTypes.STRING,
    field: 'profile_image'
  },
  isMarried: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_married'
  },
  isSmoker: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'is_smoker'
  },
  hasAddiction: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
    field: 'has_addiction'
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
  }
}, {
  tableName: 'job_seekers'
});

module.exports = JobSeeker;
