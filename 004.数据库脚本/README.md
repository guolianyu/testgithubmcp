# 数据库设计文档

## 概述

本文档基于 PRD V1.0.1 设计，支撑个人/商户财务管理系统核心功能。

## 核心设计原则

1. **多用户数据隔离** - 每个用户数据严格隔离，通过 `user_id` 外键关联
2. **软删除机制** - 所有业务表采用 `deleted_at` 软删除，保护数据安全
3. **触发器自动维护** - 账户余额由触发器自动计算，保证数据一致性
4. **账本支持** - 通过 `ledger_id` 支持多账本功能（V1.1）

## 表结构总览

| 表名 | 说明 | 核心字段 |
|------|------|---------|
| `users` | 用户表 | username, password_hash, status |
| `ledgers` | 账本表 | user_id, name, is_default |
| `accounts` | 账户表 | user_id, name, type, current_balance |
| `expense_categories` | 支出分类表 | name, icon, color, is_system |
| `income_categories` | 收入分类表 | name, icon, color, is_system |
| `bills` | 账单记录表(核心) | user_id, type, amount, category_id, account_id, date |
| `budgets` | 预算表 | year, month, type, amount, spent_amount |
| `tourist_data_mapping` | 游客数据合并表 | tourist_user_id, 正式_user_id, data_type |
| `data_exports` | 数据导出记录表 | export_type, file_url, status |

## 实体关系图

```
users (1) ─────< (N) ledgers
  │                    │
  │                    │
  ├────< (N) accounts  │
  │                    │
  ├────< (N) bills ────┼────> accounts
  │                    │
  ├────< (N) budgets   │
  │                    │
  ├────< (N) expense_categories
  │                    │
  └────< (N) income_categories
```

## 核心业务逻辑

### 账单创建/更新/删除
通过数据库触发器自动维护 `accounts.current_balance`：
- 支出账单 → 账户余额减少
- 收入账单 → 账户余额增加

### 预算管理
- 存储过程 `sp_update_budget_spent` 按月计算已消费金额
- 支持总预算和分类子预算
- 80%/100% 预警阈值

### 游客模式
- 游客创建独立 `user_id`（status=2）
- 正式注册后可选择「合并数据」或「清空重来」
- 通过 `tourist_data_mapping` 记录映射关系

## 预设分类(种子数据)

### 支出分类(13个)
🍜餐饮 🚗交通 🛒购物 🎮娱乐 🏠居住 💊医疗 📚教育 📱通讯 ✈️旅行 🎁人情 🍎水果 🧴日用品 📦其他

### 收入分类(8个+3个商户)
💰工资 🎉奖金 💼兼职 📈理财 🔙退款 🛍️销售 🤝服务 📤其他
🛒商品销售(商户) 📦批发(商户)

## 视图

| 视图名 | 说明 |
|--------|------|
| `v_monthly_expense` | 月度支出统计(按分类) |
| `v_monthly_income` | 月度收入统计(按分类) |
| `v_account_balance` | 账户余额视图(含计算验证) |

## 使用说明

### 初始化数据库
```bash
mysql -u root -p < db_design.sql
```

### 连接生产环境
```bash
mysql -h your_host -P 3306 -u your_user -p financial_management
```

## 扩展说明

- 初始余额(initial_balance)支持用户导入历史数据
- credit_limit 用于信用卡账户
- card_number 仅存储后4位保护隐私
- transfer_account_id 支持转账类型账单
