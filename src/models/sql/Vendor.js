module.exports = (sequelize, DataTypes) => {
  const Vendor = sequelize.define('Vendor', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    nama_vendor: { type: DataTypes.STRING(100), allowNull: false },
    kategori: { type: DataTypes.STRING(50) },
    kontak_person: { type: DataTypes.STRING(100) },
    telepon: { type: DataTypes.STRING(20) },
    email: { type: DataTypes.STRING(100) },
    alamat: { type: DataTypes.TEXT },
    kontrak_url: { type: DataTypes.STRING(255) },
    event_id: { type: DataTypes.INTEGER, allowNull: false },
    status: { type: DataTypes.ENUM('aktif', 'selesai', 'batal'), defaultValue: 'aktif' },
    catatan: { type: DataTypes.TEXT },
  }, {
    tableName: 'vendors',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  });

  Vendor.associate = (models) => {
    Vendor.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    Vendor.hasMany(models.Rundown, { foreignKey: 'vendor_id', as: 'rundowns' });
  };

  return Vendor;
};