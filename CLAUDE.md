# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 在此代码仓库中工作时提供指导。

## 项目概述

这是一个名为"小熊记账"的单页Web应用（SPA），用于个人/小商户财务管理。整个应用是一个自包含的 `index.html` 文件，无需构建流程。

## 运行应用

在任意现代浏览器中直接打开 `index.html`：
```bash
open index.html
```

无需服务器、构建步骤或依赖项。应用使用 ECharts 从 CDN 获取图表支持。

## 架构

**单文件SPA**：所有 HTML、CSS 和 JavaScript 都集中在 `index.html` 中（约2700行）。状态管理使用原生JS模块模式，通过全局 `state` 对象实现。

**数据持久化**：所有数据存储在浏览器 LocalStorage 中，键名为 `xiaoxiong_accounting`。数据结构如下：
```javascript
{
  bills: [{ id, type, amount, categoryId, accountId, remark, date, createdAt }],
  accounts: [{ id, name, icon }],
  expenseCategories: [{ id, name, icon, color }],
  incomeCategories: [{ id, name, icon, color }],
  budget: { total: number, categories: { [categoryId]: number } }
}
```

**图表**：使用 ECharts 5.4.3（来自 jsDelivr CDN）。图表在统计视图激活时通过 `renderPieChart()` 和 `renderLineChart()` 懒加载初始化。

**视图**：五个主要视图通过 CSS 类切换管理：首页、账单、统计、账户、设置。所有弹窗共用一套遮罩层模式。

## 设计系统

详见 `design-philosophy.md` 获取完整设计语言。关键色值：
- 主色：`#FFB7C5`（樱花粉）
- 辅色：`#FFCCE0`（棉花糖粉）
- 强调/支出：`#FF8A9B`（珊瑚粉）
- 收入：`#7DD3C0`（薄荷绿）
- 背景：`#FFF9F5`（奶油白）
- 圆角：20px（卡片）、12px（按钮）、24px（大卡片）

## 关键实现说明

- 使用 Emoji 作为图标（非SVG图标）— Emoji 在各平台渲染一致
- 使用 CSS 自定义属性实现主题：所有颜色/间距在 `:root` 中定义
- 移动端优先的响应式设计：桌面端最大宽度500px，移动端全宽
- 通过 `env(safe-area-inset-*)` 支持 iOS 安全区域
- 图表监听 window resize 事件自动调整大小
- 分类颜色需在 `DEFAULT_EXPENSE_CATEGORIES` 和 `CATEGORY_COLORS` 中保持一致
