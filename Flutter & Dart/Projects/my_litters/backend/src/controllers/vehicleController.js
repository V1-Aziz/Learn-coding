const vehicleService = require('../services/vehicleService');
const { success, error } = require('../utils/response');

exports.list = async (req, res) => {
  try {
    const vehicles = await vehicleService.listForUser(req.user.sub);
    return success(res, vehicles);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.create = async (req, res) => {
  try {
    const vehicle = await vehicleService.create(req.user.sub, req.body);
    return success(res, vehicle, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

exports.remove = async (req, res) => {
  try {
    const result = await vehicleService.removeForUser(req.user.sub, req.params.id);
    return success(res, result);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};
