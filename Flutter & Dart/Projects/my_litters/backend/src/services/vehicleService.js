const prisma = require('../config/db');

exports.listForUser = (userId) =>
  prisma.vehicle.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
  });

exports.create = async (userId, { plateNumber, make, model, year, fuelType }) => {
  if (!plateNumber || !fuelType) {
    const e = new Error('plateNumber and fuelType are required');
    e.status = 400;
    throw e;
  }
  return prisma.vehicle.create({
    data: { userId, plateNumber, make, model, year, fuelType },
  });
};

exports.removeForUser = async (userId, vehicleId) => {
  const v = await prisma.vehicle.findUnique({ where: { id: vehicleId } });
  if (!v || v.userId !== userId) {
    const e = new Error('Vehicle not found');
    e.status = 404;
    throw e;
  }
  await prisma.vehicle.delete({ where: { id: vehicleId } });
  return { id: vehicleId };
};
