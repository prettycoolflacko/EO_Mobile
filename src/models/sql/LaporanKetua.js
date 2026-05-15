module.exports = (sequelize, DataTypes) => {
  const LaporanKetua = sequelize.define('LaporanKetua', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    event_id: { type: DataTypes.INTEGER },
    ketua_id: { type: DataTypes.INTEGER },
    judul: { type: DataTypes.STRING(150) },
    konten: { type: DataTypes.TEXT },
    file_url: { type: DataTypes.STRING(255) },
    tanggal: { type: DataTypes.DATEONLY },
  }, {
    tableName: 'laporan_ketua',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
  });

  LaporanKetua.associate = (models) => {
    LaporanKetua.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    LaporanKetua.belongsTo(models.User, { foreignKey: 'ketua_id', as: 'ketua' });
  };

  return LaporanKetua;
};