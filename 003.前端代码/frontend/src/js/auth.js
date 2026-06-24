/**
 * 认证工具模块
 * 用于处理前端用户登录状态
 */

const AUTH_API_URL = 'http://localhost:3000/api';

/**
 * 获取存储的用户信息
 */
function getStoredUser() {
    const userStr = localStorage.getItem('user');
    return userStr ? JSON.parse(userStr) : null;
}

/**
 * 获取存储的 token
 */
function getStoredToken() {
    return localStorage.getItem('token');
}

/**
 * 检查用户是否已登录
 */
function isLoggedIn() {
    const token = getStoredToken();
    const user = getStoredUser();
    return !!token && !!user;
}

/**
 * 保存用户登录数据
 */
function saveAuthData(user, token) {
    localStorage.setItem('user', JSON.stringify(user));
    localStorage.setItem('token', token);
}

/**
 * 清除用户登录数据
 */
function clearAuthData() {
    localStorage.removeItem('user');
    localStorage.removeItem('token');
}

/**
 * 获取当前用户信息（从服务器验证）
 */
async function fetchCurrentUser() {
    const token = getStoredToken();
    if (!token) return null;

    try {
        const response = await fetch(`${AUTH_API_URL}/auth/me`, {
            method: 'GET',
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });

        const data = await response.json();
        if (data.success) {
            // 更新本地用户数据
            saveAuthData(data.data.user, token);
            return data.data.user;
        } else {
            // token 失效，清除登录状态
            clearAuthData();
            return null;
        }
    } catch (error) {
        console.error('获取用户信息失败:', error);
        return getStoredUser();
    }
}

/**
 * 退出登录
 */
async function logout() {
    const token = getStoredToken();

    if (token) {
        try {
            await fetch(`${AUTH_API_URL}/auth/logout`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`
                }
            });
        } catch (error) {
            console.error('退出登录请求失败:', error);
        }
    }

    clearAuthData();
    // 跳转到登录页
    window.location.href = 'login.html';
}

/**
 * 格式化用户数据显示
 */
function formatUserDisplay() {
    const user = getStoredUser();
    if (!user) return '未登录';
    return user.nickname || user.username;
}
