package main

import (
	"financial-backend/config"
	"financial-backend/routes"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("🚀 启动财务管理系统后端服务 (Go + Gin)...\n")

	// 数据库配置
	dbConfig := &config.DatabaseConfig{
		Host:     "localhost",
		Port:     "3306",
		User:     "root",
		Password: "mysql123",
		DBName:   "financial_management",
	}

	// 初始化数据库
	if err := config.InitDatabase(dbConfig); err != nil {
		log.Fatalf("❌ 数据库连接失败: %v", err)
	}
	defer config.CloseDatabase()

	// 创建Gin实例
	r := gin.Default()

	// CORS中间件
	r.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	// 设置路由
	routes.SetupRoutes(r)

	// 启动服务器
	port := config.DefaultConfig().Port
	log.Printf("\n✅ 服务器已启动")
	log.Printf("📍 访问地址: http://localhost:%s", port)
	log.Printf("📚 健康检查: http://localhost:%s/api/health", port)
	log.Printf("\n可用接口:")
	log.Printf("  POST /api/auth/register - 用户注册")
	log.Printf("  POST /api/auth/login    - 用户登录")
	log.Printf("  GET  /api/auth/me       - 获取当前用户信息 (需认证)")
	log.Printf("  POST /api/auth/logout    - 退出登录 (需认证)")
	log.Printf("")

	r.Run(":" + port)
}
