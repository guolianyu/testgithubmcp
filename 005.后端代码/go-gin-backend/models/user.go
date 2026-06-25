package models

import (
	"database/sql"
	"financial-backend/config"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// User 用户模型
type User struct {
	ID           int64      `json:"id"`
	Username     string     `json:"username"`
	PasswordHash string     `json:"-"`
	Nickname     *string    `json:"nickname"`
	AvatarURL    *string    `json:"avatar_url"`
	Email        *string    `json:"email"`
	Phone        *string    `json:"phone"`
	Status       int        `json:"status"` // 0-禁用, 1-正常, 2-游客
	LastLoginAt  *time.Time `json:"last_login_at"`
	LastLoginIP  *string    `json:"last_login_ip"`
	CreatedAt    time.Time  `json:"created_at"`
}

// UserResponse 用户响应（不包含密码）
type UserResponse struct {
	ID        int64   `json:"id"`
	Username  string  `json:"username"`
	Nickname  *string `json:"nickname"`
	AvatarURL *string `json:"avatar_url"`
}

// ToResponse 转换为用户响应
func (u *User) ToResponse() *UserResponse {
	return &UserResponse{
		ID:        u.ID,
		Username:  u.Username,
		Nickname:  u.Nickname,
		AvatarURL: u.AvatarURL,
	}
}

// FindUserByUsername 根据用户名查找用户
func FindUserByUsername(username string) (*User, error) {
	user := &User{}
	query := `SELECT id, username, password_hash, nickname, avatar_url, email, phone, status, last_login_at, last_login_ip, created_at
			  FROM users WHERE username = ? AND deleted_at IS NULL`

	err := config.DB.QueryRow(query, username).Scan(
		&user.ID, &user.Username, &user.PasswordHash, &user.Nickname,
		&user.AvatarURL, &user.Email, &user.Phone, &user.Status,
		&user.LastLoginAt, &user.LastLoginIP, &user.CreatedAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return user, nil
}

// FindUserByID 根据ID查找用户
func FindUserByID(id int64) (*User, error) {
	user := &User{}
	query := `SELECT id, username, password_hash, nickname, avatar_url, email, phone, status, created_at
			  FROM users WHERE id = ? AND deleted_at IS NULL`

	var createdAt sql.NullTime
	err := config.DB.QueryRow(query, id).Scan(
		&user.ID, &user.Username, &user.PasswordHash, &user.Nickname,
		&user.AvatarURL, &user.Email, &user.Phone, &user.Status, &createdAt,
	)

	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if createdAt.Valid {
		user.CreatedAt = createdAt.Time
	}
	return user, nil
}

// CreateUser 创建新用户
func CreateUser(username, password string) (*User, error) {
	// 密码哈希
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	result, err := config.DB.Exec(
		`INSERT INTO users (username, password_hash, status, created_at, updated_at)
		 VALUES (?, ?, 1, NOW(), NOW())`,
		username, string(hashedPassword),
	)
	if err != nil {
		return nil, err
	}

	id, err := result.LastInsertId()
	if err != nil {
		return nil, err
	}

	return &User{
		ID:       id,
		Username: username,
		Status:   1,
		CreatedAt: time.Now(),
	}, nil
}

// VerifyPassword 验证密码
func (u *User) VerifyPassword(password string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(u.PasswordHash), []byte(password))
	return err == nil
}

// UpdateLastLogin 更新最后登录信息
func UpdateLastLogin(id int64, ip string) error {
	_, err := config.DB.Exec(
		`UPDATE users SET last_login_at = NOW(), last_login_ip = ? WHERE id = ?`,
		ip, id,
	)
	return err
}

// IsUsernameExists 检查用户名是否存在
func IsUsernameExists(username string) (bool, error) {
	var count int
	err := config.DB.QueryRow(`SELECT COUNT(*) FROM users WHERE username = ?`, username).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
