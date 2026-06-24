const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/user');
const { generateToken, auth } = require('../middleware/auth');

const router = express.Router();

/**
 * 注册
 * POST /api/auth/register
 */
router.post('/register', [
  body('username')
    .trim()
    .isLength({ min: 4, max: 20 })
    .withMessage('用户名必须为4-20位字母或数字')
    .matches(/^[a-zA-Z0-9]+$/)
    .withMessage('用户名只能包含字母和数字'),
  body('password')
    .isLength({ min: 6, max: 20 })
    .withMessage('密码必须为6-20位'),
  body('confirmPassword')
    .custom((value, { req }) => {
      if (value !== req.body.password) {
        throw new Error('两次输入的密码不一致');
      }
      return true;
    })
], async (req, res) => {
  try {
    // 验证请求
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg
      });
    }

    const { username, password } = req.body;

    // 检查用户名是否已存在
    const exists = await User.isUsernameExists(username);
    if (exists) {
      return res.status(400).json({
        success: false,
        message: '用户名已存在'
      });
    }

    // 创建用户
    const user = await User.create({ username, password });

    // 生成token
    const token = generateToken(user.id);

    res.status(201).json({
      success: true,
      message: '注册成功',
      data: {
        user: {
          id: user.id,
          username: user.username
        },
        token
      }
    });
  } catch (error) {
    console.error('注册错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

/**
 * 登录
 * POST /api/auth/login
 */
router.post('/login', [
  body('username').trim().notEmpty().withMessage('用户名不能为空'),
  body('password').notEmpty().withMessage('密码不能为空')
], async (req, res) => {
  try {
    // 验证请求
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: errors.array()[0].msg
      });
    }

    const { username, password } = req.body;

    // 查找用户
    const user = await User.findByUsername(username);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: '用户名或密码错误'
      });
    }

    // 验证密码
    const isValidPassword = await User.verifyPassword(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({
        success: false,
        message: '用户名或密码错误'
      });
    }

    // 检查用户状态
    if (user.status !== 1) {
      return res.status(403).json({
        success: false,
        message: '账号已被禁用'
      });
    }

    // 更新最后登录信息
    await User.updateLastLogin(user.id, req.ip);

    // 生成token
    const token = generateToken(user.id);

    res.json({
      success: true,
      message: '登录成功',
      data: {
        user: {
          id: user.id,
          username: user.username,
          nickname: user.nickname,
          avatar_url: user.avatar_url
        },
        token
      }
    });
  } catch (error) {
    console.error('登录错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

/**
 * 获取当前用户信息
 * GET /api/auth/me
 */
router.get('/me', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        user: req.user
      }
    });
  } catch (error) {
    console.error('获取用户信息错误:', error);
    res.status(500).json({
      success: false,
      message: '服务器内部错误'
    });
  }
});

/**
 * 退出登录
 * POST /api/auth/logout
 */
router.post('/logout', auth, (req, res) => {
  // 在实际应用中，这里可以将token加入黑名单
  res.json({
    success: true,
    message: '退出登录成功'
  });
});

module.exports = router;
