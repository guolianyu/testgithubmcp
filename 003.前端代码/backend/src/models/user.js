const { pool } = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
  /**
   * 根据用户名查找用户
   */
  static async findByUsername(username) {
    const [rows] = await pool.execute(
      'SELECT * FROM users WHERE username = ? AND deleted_at IS NULL',
      [username]
    );
    return rows[0] || null;
  }

  /**
   * 根据ID查找用户
   */
  static async findById(id) {
    const [rows] = await pool.execute(
      'SELECT id, username, nickname, avatar_url, email, phone, status, created_at FROM users WHERE id = ? AND deleted_at IS NULL',
      [id]
    );
    return rows[0] || null;
  }

  /**
   * 创建新用户
   */
  static async create({ username, password, nickname = null, email = null }) {
    const passwordHash = await bcrypt.hash(password, 10);

    const [result] = await pool.execute(
      `INSERT INTO users (username, password_hash, nickname, email, status, created_at)
       VALUES (?, ?, ?, ?, 1, NOW())`,
      [username, passwordHash, nickname, email]
    );

    return {
      id: result.insertId,
      username,
      nickname,
      email
    };
  }

  /**
   * 验证密码
   */
  static async verifyPassword(plainPassword, hashedPassword) {
    return bcrypt.compare(plainPassword, hashedPassword);
  }

  /**
   * 更新最后登录信息
   */
  static async updateLastLogin(id, ip) {
    await pool.execute(
      'UPDATE users SET last_login_at = NOW(), last_login_ip = ? WHERE id = ?',
      [ip, id]
    );
  }

  /**
   * 检查用户名是否存在
   */
  static async isUsernameExists(username) {
    const [rows] = await pool.execute(
      'SELECT COUNT(*) as count FROM users WHERE username = ?',
      [username]
    );
    return rows[0].count > 0;
  }
}

module.exports = User;
