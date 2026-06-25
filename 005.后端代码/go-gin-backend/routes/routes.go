package routes

import (
	"financial-backend/handlers"
	"financial-backend/middleware"

	"github.com/gin-gonic/gin"
)

// SetupRoutes 设置路由
func SetupRoutes(r *gin.Engine) {
	// API路由组
	api := r.Group("/api")

	// 健康检查
	api.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"success":  true,
			"message":  "服务运行正常",
			"timestamp": gin.H{},
		})
	})

	// 认证路由
	auth := api.Group("/auth")
	{
		auth.POST("/register", handlers.Register)
		auth.POST("/login", handlers.Login)
		auth.GET("/me", middleware.AuthMiddleware(), handlers.GetMe)
		auth.POST("/logout", middleware.AuthMiddleware(), handlers.Logout)
	}
}
