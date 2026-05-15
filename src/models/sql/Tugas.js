module.exports = (sequelize, DataTypes) => {
  const Tugas = sequelize.define('Tugas', {
    id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
    event_id: { type: DataTypes.INTEGER, allowNull: false },
    rundown_id: { type: DataTypes.INTEGER },
    judul: { type: DataTypes.STRING(150), allowNull: false },
    deskripsi: { type: DataTypes.TEXT },
    assignee_id: { type: DataTypes.INTEGER, allowNull: false },
    divisi: { type: DataTypes.STRING(50) },
    prioritas: { type: DataTypes.ENUM('rendah', 'sedang', 'tinggi', 'kritis'), defaultValue: 'sedang' },
    status: { type: DataTypes.ENUM('belum', 'proses', 'selesai', 'terkendala'), defaultValue: 'belum' },
    deadline: { type: DataTypes.DATE },
    lampiran_url: { type: DataTypes.STRING(255) },
    catatan: { type: DataTypes.TEXT },
  }, {
    tableName: 'tugas',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
  });

  Tugas.associate = (models) => {
    Tugas.belongsTo(models.Event, { foreignKey: 'event_id', as: 'event' });
    Tugas.belongsTo(models.Rundown, { foreignKey: 'rundown_id', as: 'rundown' });
    Tugas.belongsTo(models.User, { foreignKey: 'assignee_id', as: 'assignee' });
  };

  return Tugas;
};