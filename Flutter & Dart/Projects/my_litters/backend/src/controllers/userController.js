const userService = require('../services/userService');
const { success, error } = require('../utils/response');

// Convenience endpoints for the signed-in user — no id needed in URL.
exports.getMe = async (req, res) => {
  try {
    const user = await userService.getById(req.user.sub);
    return success(res, user);
  } catch (err) {
    return error(res, err.message, err.status || 404);
  }
};

exports.updateMe = async (req, res) => {
  try {
    const user = await userService.update(req.user.sub, req.body);
    return success(res, user);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

// Anyone authenticated can fetch their own record. Admins can fetch anyone.
exports.getUser = async (req, res) => {
  try {
    const targetId = req.params.id;
    if (req.user.role !== 'admin' && req.user.sub !== targetId) {
      return error(res, 'Forbidden', 403);
    }
    const user = await userService.getById(targetId);
    return success(res, user);
  } catch (err) {
    return error(res, err.message, err.status || 404);
  }
};

exports.updateUser = async (req, res) => {
  try {
    const targetId = req.params.id;
    if (req.user.role !== 'admin' && req.user.sub !== targetId) {
      return error(res, 'Forbidden', 403);
    }
    const user = await userService.update(targetId, req.body);
    return success(res, user);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};
