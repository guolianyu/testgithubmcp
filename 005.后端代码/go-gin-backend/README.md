# 财务管理系统后端 (Go + Gin)

基于 Go + Gin 的财务管理系统后端API服务。

## 技术栈

- **语言**: Go 1.24
- **框架**: Gin Web Framework
- **数据库**: MySQL 8.0 (utf8mb4)
- **密码加密**: bcrypt
- **认证**: JWT (JSON Web Token)

## 项目结构

```
go-gin-backend/
├── go.mod              # Go模块文件
├── main.go             # 应用入口
├── config/
│   ├── config.go       # 数据库配置
│   └── server.go       # 服务器配置
├── models/
│   └── user.go         # 用户模型
├── handlers/
│   └── auth.go         # 认证处理器
├── middleware/
│   └── auth.go         # JWT认证中间件
├── routes/
│   └── routes.go       # 路由配置
└── utils/
    └── jwt.go          # JWT工具
```

## 安装和运行

```bash
# 进入后端目录
cd 005.后端代码/go-gin-backend

# 下载依赖
go mod tidy

# 运行
go run main.go
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

**响应:**
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

**响应:**
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

## 数据库配置

数据库配置在 `main.go` 中:

```go
dbConfig := &config.DatabaseConfig{
    Host:     "localhost",
    Port:     "3306",
    User:     "root",
    Password: "mysql123",
    DBName:   "financial_management",
}
```
