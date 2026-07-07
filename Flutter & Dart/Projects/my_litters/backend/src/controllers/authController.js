const { z } = require('zod');
const authService = require('../services/authService');
const { success, error } = require('../utils/response');

const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(128),
  fullName: z.string().min(2).max(120),
  phone: z.string().min(6).max(20).optional(),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const handleZod = (res, err) => {
  const msg = err.errors?.map((e) => `${e.path.join('.')}: ${e.message}`).join('; ') || 'Invalid input';
  return error(res, msg, 400);
};

exports.signup = async (req, res) => {
  const parsed = signupSchema.safeParse(req.body);
  if (!parsed.success) return handleZod(res, parsed.error);
  try {
    const result = await authService.signup(parsed.data);
    return success(res, result, 201);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};

exports.login = async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) return handleZod(res, parsed.error);
  try {
    const result = await authService.login(parsed.data);
    return success(res, result);
  } catch (err) {
    return error(res, err.message, err.status || 401);
  }
};

exports.me = async (req, res) => {
  try {
    const user = await authService.me(req.user.sub);
    return success(res, user);
  } catch (err) {
    return error(res, err.message, err.status || 500);
  }
};
