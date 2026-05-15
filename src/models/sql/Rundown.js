module.exports = (sequelize, DataTypes) => {
  const Rundown = sequelize.define('Rundown', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    event_id: { type: DataTypes.INTEGER, allowNull: false },
    urutan: { type: DataTypes.INTEGER, allowNull: false },
    waktu_mulai: { type: DataTypes.TIME, allowNull: false },
    waktu_selesai: { type: DataTypes.TIME },
    judul_sesi: { type: DataTypes.STRING(150), allowNull: false },
    deskripsi: { type: DataTypes.TEXT },
    pic_id: { type: DataTypes.INTEGER },
    vendor_id: { type: DataTypes.INTEGER },
    status: { type: DataTypes.ENUM('belum', 'berjalan', 'selesai', 'ditunda'), defaultValue: 'belum' },
  }, {
    tableName: 'rundowns',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Rundown.associate = (models) => {
    Rundown.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    Rundown.belongsTo(models.User, { foreignKey: 'pic_id', as: 'pic' });
    Rundown.belongsTo(models.Vendor, { foreignKey: 'vendor_id', as: 'vendor' });
    Rundown.hasMany(models.Tugas, { foreignKey: 'rundown_id', as: 'tugas' });
  };

  return Rundown;
};