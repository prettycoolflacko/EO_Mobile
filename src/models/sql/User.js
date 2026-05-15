module.exports = (sequelize, DataTypes) => {
  const User = sequelize.define('User', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    email: { type: DataTypes.STRING(100), allowNull: false, unique: true },
    password_hash: { type: DataTypes.STRING(255), allowNull: false },
    role: { type: DataTypes.ENUM('admin', 'ketua', 'staf'), allowNull: false },
    divisi: { type: DataTypes.STRING(50) },
    phone: { type: DataTypes.STRING(20) },
    avatar_url: { type: DataTypes.STRING(255) },
    is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
  }, {
    tableName: 'users',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  User.associate = (models) => {
    User.hasMany(models.Event, { foreignKey: 'ketua_id', as: 'events_dipimpin' });
    User.hasMany(models.Tugas, { foreignKey: 'assignee_id', as: 'tugas_diterima' });
    User.hasMany(models.Rundown, { foreignKey: 'pic_id', as: 'rundowns_pic' });
    User.hasMany(models.LaporanKetua, { foreignKey: 'ketua_id', as: 'laporan' });
  };

  return User;
};