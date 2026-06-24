# 财务管理系统后端

基于 Node.js + Express 的财务管理系统后端API服务。

## 技术栈

- **运行时**: Node.js
- **框架**: Express.js
- **数据库**: MySQL 8.0 (utf8mb4)
- **密码加密**: bcryptjs
- **认证**: JWT (JSON Web Token)
- **数据验证**: express-validator

## 项目结构

```
backend/
├── .env                 # 环境配置
├── package.json         # 项目依赖
├── README.md            # 项目文档
└── src/
    ├── app.js           # 应用入口
    ├── config/
    │   └── database.js  # 数据库配置
    ├── middleware/
    │   └── auth.js      # JWT认证中间件
    ├── models/
    │   └── user.js      # 用户模型
    └── routes/
        └── auth.js      # 认证路由
```

## 环境配置

在 `.env` 文件中配置以下变量:

```env
# 数据库配置
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=mysql123
DB_NAME=financial_management

# JWT配置
JWT_SECRET=your_super_secret_jwt_key_change_in_production
JWT_EXPIRES_IN=7d

# 服务器配置
PORT=3000
```

## 安装和运行

```bash
# 进入后端目录
cd backend

# 安装依赖
npm install

# 开发模式运行 (支持热重载)
npm run dev

# 生产模式运行
npm start
```

## API 接口

### 认证接口

| 接口 | 方法 | 描述 | 参数 |
|------|------|------|------|
| `/api/auth/register` | POST | 用户注册 | username, password, confirmPassword |
| `/api/auth/login` | POST | 用户登录 | username, password |
| `/api/auth/me` | GET | 获取当前用户信息 | (需携带JWT) |
| `/api/auth/logout` | POST | 退出登录 | (需携带JWT) |

### 注册接口

**请求:**
```json
POST /api/auth/register
Content-Type: application/json

{
  "username": "testuser",
  "password": "123456",
  "confirmPassword": "123456"
}
```

**响应 (成功):**
```json
{
  "success": true,
  "message": "注册成功",
  "data": {
    "user": {
      "id": 1,
      "username": "testuser"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 登录接口

**请求:**
```json
POST /api/auth/login
Content-Type: application/json

{
  "username": "testuser",
  "password": "123456"
}
```

**响应 (成功):**
```json
{
  "success": true,
  "message": "登录成功",
  "data": {
    "user": {
      "id": 1,
      "username": "testuser",
      "nickname": null,
      "avatar_url": null
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 数据库表结构

后端使用 `financial_management` 数据库，请确保已执行 `004.数据库脚本/db_design.sql` 初始化数据库。

主要表:
- `users` - 用户表

## 注意事项

1. 密码使用 bcrypt 加密存储，安全可靠
2. JWT token 默认7天过期
3. 所有敏感接口需要携带 JWT token
4. API返回格式统一为 `{ success, message, data }`
