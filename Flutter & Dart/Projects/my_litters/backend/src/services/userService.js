const prisma = require('../config/db');

const sanitize = ({ passwordHash, ...rest }) => rest;

exports.getById = async (id) => {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) {
    const e = new Error('User not found');
    e.status = 404;
    throw e;
  }
  return sanitize(user);
};

exports.update = async (id, data) => {
  const allowed = (({ fullName, phone, nationalId }) => ({ fullName, phone, nationalId }))(data);
  Object.keys(allowed).forEach((k) => allowed[k] === undefined && delete allowed[k]);
  const user = await prisma.user.update({ where: { id }, data: allowed });
  return sanitize(user);
};
