module.exports = (sequelize, DataTypes) => {
  const Event = sequelize.define('Event', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    nama_event: { type: DataTypes.STRING(150), allowNull: false },
    deskripsi: { type: DataTypes.TEXT },
    lokasi: { type: DataTypes.STRING(200) },
    tanggal_mulai: { type: DataTypes.DATEONLY, allowNull: false },
    tanggal_selesai: { type: DataTypes.DATEONLY, allowNull: false },
    status: { type: DataTypes.ENUM('draft', 'aktif', 'selesai', 'batal'), defaultValue: 'draft' },
    ketua_id: { type: DataTypes.INTEGER, allowNull: false },
  }, {
    tableName: 'events',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Event.associate = (models) => {
    Event.belongsTo(models.User, { foreignKey: 'ketua_id', as: 'ketua' });
    Event.hasMany(models.Vendor, { foreignKey: 'event_id', as: 'vendors' });
    Event.hasMany(models.Rundown, { foreignKey: 'event_id', as: 'rundowns' });
    Event.hasMany(models.Tugas, { foreignKey: 'event_id', as: 'tugas' });
    Event.hasMany(models.LaporanKetua, { foreignKey: 'event_id', as: 'laporan' });
  };

  return Event;
};