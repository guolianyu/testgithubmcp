require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { testConnection } = require('./config/database');
const authRoutes = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志中间件
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// API路由
app.use('/api/auth', authRoutes);

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: '服务运行正常',
    timestamp: new Date().toISOString()
  });
});

// 404处理
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: '接口不存在'
  });
});

// 错误处理
app.use((err, req, res, next) => {
  console.error('服务器错误:', err);
  res.status(500).json({
    success: false,
    message: '服务器内部错误'
  });
});

// 启动服务器
async function startServer() {
  console.log('🚀 启动财务管理系统后端服务...\n');

  // 测试数据库连接
  const dbConnected = await testConnection();
  if (!dbConnected) {
    console.error('❌ 无法连接到数据库，请检查配置');
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`\n✅ 服务器已启动`);
    console.log(`📍 访问地址: http://localhost:${PORT}`);
    console.log(`📚 API文档: http://localhost:${PORT}/api/health`);
    console.log(`\n可用接口:`);
    console.log(`  POST /api/auth/register - 用户注册`);
    console.log(`  POST /api/auth/login    - 用户登录`);
    console.log(`  GET  /api/auth/me       - 获取当前用户信息`);
    console.log(`  POST /api/auth/logout    - 退出登录`);
    console.log('');
  });
}

startServer();
