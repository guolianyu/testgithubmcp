package handlers

import (
	"financial-backend/middleware"
	"financial-backend/models"
	"financial-backend/utils"
	"net/http"
	"regexp"

	"github.com/gin-gonic/gin"
)

// RegisterRequest 注册请求
type RegisterRequest struct {
	Username       string `json:"username" binding:"required"`
	Password       string `json:"password" binding:"required"`
	ConfirmPassword string `json:"confirmPassword" binding:"required"`
}

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// Register 注册处理
func Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "请求参数错误",
		})
		return
	}

	// 验证用户名格式（4-20位字母或数字）
	if len(req.Username) < 4 || len(req.Username) > 20 {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "用户名必须为4-20位字符",
		})
		return
	}
	if matched, _ := regexp.MatchString(`^[a-zA-Z0-9]+$`, req.Username); !matched {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "用户名只能包含字母和数字",
		})
		return
	}

	// 验证密码格式（6-20位）
	if len(req.Password) < 6 || len(req.Password) > 20 {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "密码必须为6-20位",
		})
		return
	}

	// 验证两次密码一致
	if req.Password != req.ConfirmPassword {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "两次输入的密码不一致",
		})
		return
	}

	// 检查用户名是否存在
	exists, err := models.IsUsernameExists(req.Username)
	if err != nil {
		c.JSON(http.StatusInternalServerError, middleware.Response{
			Success: false,
			Message:  "服务器内部错误",
		})
		return
	}
	if exists {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "用户名已存在",
		})
		return
	}

	// 创建用户
	user, err := models.CreateUser(req.Username, req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, middleware.Response{
			Success: false,
			Message:  "创建用户失败",
		})
		return
	}

	// 生成Token
	token, err := utils.GenerateToken(user.ID, user.Username)
	if err != nil {
		c.JSON(http.StatusInternalServerError, middleware.Response{
			Success: false,
			Message:  "生成令牌失败",
		})
		return
	}

	c.JSON(http.StatusCreated, middleware.Response{
		Success: true,
		Message: "注册成功",
		Data: gin.H{
			"user":  user.ToResponse(),
			"token": token,
		},
	})
}

// Login 登录处理
func Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, middleware.Response{
			Success: false,
			Message:  "请求参数错误",
		})
		return
	}

	// 查找用户
	user, err := models.FindUserByUsername(req.Username)
	if err != nil {
		c.JSON(http.StatusInternalServerError, middleware.Response{
			Success: false,
			Message:  "服务器内部错误",
		})
		return
	}
	if user == nil {
		c.JSON(http.StatusUnauthorized, middleware.Response{
			Success: false,
			Message:  "用户名或密码错误",
		})
		return
	}

	// 验证密码
	if !user.VerifyPassword(req.Password) {
		c.JSON(http.StatusUnauthorized, middleware.Response{
			Success: false,
			Message:  "用户名或密码错误",
		})
		return
	}

	// 检查用户状态
	if user.Status != 1 {
		c.JSON(http.StatusForbidden, middleware.Response{
			Success: false,
			Message:  "账号已被禁用",
		})
		return
	}

	// 更新最后登录信息
	clientIP := c.ClientIP()
	models.UpdateLastLogin(user.ID, clientIP)

	// 生成Token
	token, err := utils.GenerateToken(user.ID, user.Username)
	if err != nil {
		c.JSON(http.StatusInternalServerError, middleware.Response{
			Success: false,
			Message:  "生成令牌失败",
		})
		return
	}

	c.JSON(http.StatusOK, middleware.Response{
		Success: true,
		Message: "登录成功",
		Data: gin.H{
			"user":  user.ToResponse(),
			"token": token,
		},
	})
}

// GetMe 获取当前用户信息
func GetMe(c *gin.Context) {
	userID := c.GetInt64("userID")

	user, err := models.FindUserByID(userID)
	if err != nil || user == nil {
		c.JSON(http.StatusNotFound, middleware.Response{
			Success: false,
			Message: "用户不存在",
		})
		return
	}

	c.JSON(http.StatusOK, middleware.Response{
		Success: true,
		Data: gin.H{
			"user": user.ToResponse(),
		},
	})
}

// Logout 退出登录
func Logout(c *gin.Context) {
	c.JSON(http.StatusOK, middleware.Response{
		Success: true,
		Message: "退出登录成功",
	})
}
