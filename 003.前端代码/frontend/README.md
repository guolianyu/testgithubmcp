# 财务管家 (Financial Steward)

> 💗 让记账变成一件温暖又开心的事

一个面向个人用户和小微商户的轻量级 Web 端财务管理工具，主打**简单、可爱、温暖、无广告**。

## 📁 项目结构

```
frontend/
├── src/
│   ├── pages/           # HTML 页面
│   │   ├── login.html       # 登录页
│   │   ├── register.html    # 注册页
│   │   ├── dashboard.html   # 首页/仪表板
│   │   ├── add-record.html  # 记一笔
│   │   ├── transactions.html # 账单/交易明细
│   │   ├── statistics.html   # 统计报表
│   │   └── settings.html    # 设置页
│   ├── css/
│   │   └── styles.css       # 共享样式（Tailwind CSS）
│   ├── js/
│   │   └── navigation.js   # 共享导航组件
│   └── assets/             # 静态资源
├── financial_manager_system/
│   └── DESIGN.md           # 设计规范文档
└── README.md
```

## 🚀 快速开始

### 运行方式

直接在浏览器中打开 `src/pages/` 目录下的任意 HTML 文件即可。

推荐访问顺序：
1. 打开 [login.html](src/pages/login.html) 登录
2. 或直接访问 [dashboard.html](src/pages/dashboard.html) 游客体验

### 技术栈

- **CSS 框架**: [Tailwind CSS](https://tailwindcss.com/) (CDN)
- **字体**: [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans) + [Noto Sans SC](https://fonts.google.com/specimen/Noto+Sans+SC)
- **图标**: [Material Symbols](https://fonts.google.com/icons) (Outlined style)

## 🎨 设计规范

详细设计规范请参考 [DESIGN.md](financial_manager_system/DESIGN.md)

### 品牌色彩

| 用途 | 色值 | 说明 |
|------|------|------|
| 主色 | `#864e5a` | 玫瑰粉 |
| 主色容器 | `#ffb7c5` | 樱花粉 |
| 背景 | `#fbf9f8` | 奶油白 |
| 卡片背景 | `#FFF0F3` | 淡粉白 |
| 收入色 | `#7DD3C0` | 薄荷绿 |
| 支出色 | `#FF8A9B` | 珊瑚粉 |

### 页面导航

所有页面通过侧边栏导航相互链接：

```
┌─────────────────────────────────────────────────┐
│  🧸 财务管家                    [用户头像]      │
├──────────┬──────────────────────────────────────┤
│          │                                       │
│ 🏠 首页   │         主内容区域                    │
│ 📋 交易   │                                       │
│ 📊 统计   │                                       │
│ ⚙️ 设置   │                                       │
│          │                                       │
│ [💗 记一笔]                                      │
└──────────┴──────────────────────────────────────┘
```

## 📱 页面说明

| 页面 | 文件 | 说明 |
|------|------|------|
| 登录 | [login.html](src/pages/login.html) | 用户名+密码登录 |
| 注册 | [register.html](src/pages/register.html) | 新用户注册 |
| 首页 | [dashboard.html](src/pages/dashboard.html) | 财务概览、快捷操作 |
| 记一笔 | [add-record.html](src/pages/add-record.html) | 新增收支记录 |
| 交易明细 | [transactions.html](src/pages/transactions.html) | 账单列表、筛选搜索 |
| 统计报表 | [statistics.html](src/pages/statistics.html) | 收支分析、图表 |
| 设置 | [settings.html](src/pages/settings.html) | 个人信息、偏好设置 |

## 🔗 页面跳转关系

```
login.html ←→ register.html
      ↓ (登录后)
dashboard.html
      ↓
├── add-record.html (快速记账)
├── transactions.html (交易明细)
├── statistics.html (统计报表)
└── settings.html (设置)
                ↓
         login.html (退出登录)
```

## 📦 功能模块

### P0 核心功能 (V1.0)
- [x] 记一笔 - 支出/收入记录
- [x] 账单列表 - 查看/编辑/删除
- [x] 月度统计 - 收支图表
- [x] 账户管理 - 预设+自定义账户
- [x] 分类管理 - 预设+自定义分类
- [x] 预算管理 - 月度总预算+分类预算
- [x] 数据导出 - CSV/Excel

### P1 重要功能 (V1.0.1)
- [ ] 用户注册/登录
- [ ] 多用户数据隔离
- [ ] 游客模式

### P2 增强功能 (后续版本)
- [ ] 多账本
- [ ] 数据导入
- [ ] 预算提醒

## 🎯 开发指南

### 添加新页面

1. 在 `src/pages/` 创建新的 HTML 文件
2. 引入必要的 CDN 资源：

```html
<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>

<!-- Material Symbols -->
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
```

3. 复制 Tailwind 配置（从现有页面）
4. 添加导航链接到侧边栏

### Tailwind 配置参考

```js
tailwind.config = {
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "primary": "#864e5a",
        "primary-container": "#ffb7c5",
        // ... 更多颜色
      },
      borderRadius: {
        "lg": "0.5rem",
        "xl": "0.75rem",
        "xxl": "1.5rem",
        "full": "9999px"
      }
    }
  }
}
```

## 📄 License

本项目仅供学习参考。
