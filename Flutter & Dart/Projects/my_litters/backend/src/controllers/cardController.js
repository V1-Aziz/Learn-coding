const cardService = require('../services/cardService');
const { success, error } = require('../utils/response');

exports.list = async (req, res) => {
  try {
    const cards = await cardService.listForUser(req.user.sub);
    return success(res, cards);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.link = async (req, res) => {
  try {
    const card = await cardService.link(req.user.sub, req.body);
    return success(res, card, 201);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

exports.block = async (req, res) => {
  try {
    const card = await cardService.setStatus(req.user.sub, req.params.id, 'blocked');
    return success(res, card);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};

exports.unblock = async (req, res) => {
  try {
    const card = await cardService.setStatus(req.user.sub, req.params.id, 'active');
    return success(res, card);
  } catch (err) {
    return error(res, err.message, err.status || 400);
  }
};
