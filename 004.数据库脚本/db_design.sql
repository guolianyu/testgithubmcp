-- ============================================
-- 个人/商户财务管理系统 数据库设计
-- 版本: V1.0
-- 创建日期: 2026-06-24
-- 说明: 基于 PRD V1.0.1 设计，支持多用户数据隔离
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `financial_management`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `financial_management`;

-- ============================================
-- 1. 用户表 (users)
-- ============================================
CREATE TABLE `users` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名(4-20位字母或数字)',
    `password_hash` VARCHAR(255) NOT NULL COMMENT 'SHA-256哈希后的密码',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `avatar_url` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常, 2-游客',
    `last_login_at` DATETIME DEFAULT NULL COMMENT '最后登录时间',
    `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted_at` DATETIME DEFAULT NULL COMMENT '删除时间(软删除)',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================
-- 2. 账本表 (ledgers)
-- ============================================
CREATE TABLE `ledgers` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账本ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
    `name` VARCHAR(50) NOT NULL COMMENT '账本名称',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '图标(emoji)',
    `color` VARCHAR(20) DEFAULT '#FFB7C5' COMMENT '主题颜色',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '账本描述',
    `is_default` TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认账本: 0-否, 1-是',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted_at` DATETIME DEFAULT NULL COMMENT '删除时间(软删除)',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_is_default` (`is_default`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_ledgers_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账本表(支持多账本)';

-- ============================================
-- 3. 账户表 (accounts) - 钱包/收款账户
-- ============================================
CREATE TABLE `accounts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账户ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
    `ledger_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '所属账本ID(可为NULL表示通用账户)',
    `name` VARCHAR(50) NOT NULL COMMENT '账户名称',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '图标(emoji)',
    `color` VARCHAR(20) DEFAULT '#7DD3C0' COMMENT '账户颜色',
    `type` VARCHAR(20) NOT NULL DEFAULT 'cash' COMMENT '账户类型: cash-现金, bank_card-银行卡, wechat-微信, alipay-支付宝, credit-信用卡, other-其他',
    `initial_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '初始余额',
    `current_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '当前余额(系统计算)',
    `card_number` VARCHAR(50) DEFAULT NULL COMMENT '卡号(后4位)',
    `credit_limit` DECIMAL(15,2) DEFAULT NULL COMMENT '信用卡额度',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted_at` DATETIME DEFAULT NULL COMMENT '删除时间(软删除)',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_ledger_id` (`ledger_id`),
    KEY `idx_type` (`type`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_accounts_ledger` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账户表(钱包/收款账户)';

-- ============================================
-- 4. 支出分类表 (expense_categories)
-- ============================================
CREATE TABLE `expense_categories` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `user_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '所属用户ID(NULL表示系统预设)',
    `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '图标(emoji)',
    `color` VARCHAR(20) DEFAULT '#FFB7C5' COMMENT '分类颜色',
    `parent_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '父分类ID(用于二级分类)',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
    `is_system` TINYINT NOT NULL DEFAULT 0 COMMENT '是否系统预设: 0-自定义, 1-系统预设',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0-未删除, 1-已删除',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_sort_order` (`sort_order`),
    CONSTRAINT `fk_expense_cate_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_expense_cate_parent` FOREIGN KEY (`parent_id`) REFERENCES `expense_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支出分类表';

-- ============================================
-- 5. 收入分类表 (income_categories)
-- ============================================
CREATE TABLE `income_categories` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分类ID',
    `user_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '所属用户ID(NULL表示系统预设)',
    `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
    `icon` VARCHAR(50) DEFAULT NULL COMMENT '图标(emoji)',
    `color` VARCHAR(20) DEFAULT '#7DD3C0' COMMENT '分类颜色',
    `parent_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '父分类ID(用于二级分类)',
    `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
    `is_system` TINYINT NOT NULL DEFAULT 0 COMMENT '是否系统预设: 0-自定义, 1-系统预设',
    `is_deleted` TINYINT NOT NULL DEFAULT 0 COMMENT '是否删除: 0-未删除, 1-已删除',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_parent_id` (`parent_id`),
    KEY `idx_sort_order` (`sort_order`),
    CONSTRAINT `fk_income_cate_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_income_cate_parent` FOREIGN KEY (`parent_id`) REFERENCES `income_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收入分类表';

-- ============================================
-- 6. 账单记录表 (bills) - 核心业务表
-- ============================================
CREATE TABLE `bills` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账单ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
    `ledger_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '所属账本ID',
    `type` VARCHAR(10) NOT NULL COMMENT '账单类型: expense-支出, income-收入',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '金额(支持小数)',
    `category_id` BIGINT UNSIGNED NOT NULL COMMENT '分类ID(支出或收入分类)',
    `account_id` BIGINT UNSIGNED NOT NULL COMMENT '账户ID',
    `transfer_account_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '转入账户ID(转账时使用)',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    `date` DATE NOT NULL COMMENT '账单日期',
    `time` TIME DEFAULT NULL COMMENT '账单时间',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted_at` DATETIME DEFAULT NULL COMMENT '删除时间(软删除)',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_ledger_id` (`ledger_id`),
    KEY `idx_type` (`type`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_account_id` (`account_id`),
    KEY `idx_date` (`date`),
    KEY `idx_created_at` (`created_at`),
    KEY `idx_user_date_type` (`user_id`, `date`, `type`),
    KEY `idx_user_category_date` (`user_id`, `category_id`, `date`),
    CONSTRAINT `fk_bills_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_bills_ledger` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_bills_account` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE RESTRICT,
    CONSTRAINT `fk_bills_transfer_account` FOREIGN KEY (`transfer_account_id`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
    CONSTRAINT `chk_bills_type` CHECK (`type` IN ('expense', 'income'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='账单记录表';

-- ============================================
-- 7. 预算表 (budgets)
-- ============================================
CREATE TABLE `budgets` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预算ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
    `ledger_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '所属账本ID',
    `year` INT NOT NULL COMMENT '预算年份',
    `month` INT NOT NULL COMMENT '预算月份',
    `type` VARCHAR(10) NOT NULL COMMENT '预算类型: total-总预算, category-分类预算',
    `category_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '分类ID(分类预算时使用)',
    `amount` DECIMAL(15,2) NOT NULL COMMENT '预算金额',
    `spent_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00 COMMENT '已消费金额(系统计算)',
    `remaining_amount` DECIMAL(15,2) GENERATED ALWAYS AS (amount - spent_amount) STORED COMMENT '剩余金额',
    `alert_threshold` DECIMAL(5,2) NOT NULL DEFAULT 80.00 COMMENT '预警阈值百分比',
    `alert_sent` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已发送预警: 0-否, 1-已发送80%预警, 2-已发送100%预警',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_ledger_id` (`ledger_id`),
    KEY `idx_year_month` (`year`, `month`),
    KEY `idx_type` (`type`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_user_ledger_year_month` (`user_id`, `ledger_id`, `year`, `month`),
    CONSTRAINT `fk_budgets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_budgets_ledger` FOREIGN KEY (`ledger_id`) REFERENCES `ledgers` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_budgets_category` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`) ON DELETE CASCADE,
    CONSTRAINT `chk_budgets_type` CHECK (`type` IN ('total', 'category')),
    CONSTRAINT `chk_budgets_month` CHECK (`month` >= 1 AND `month` <= 12)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='预算表';

-- ============================================
-- 8. 游客数据关联表 (tourist_data_mapping)
-- 用于游客模式数据合并到正式账号
-- ============================================
CREATE TABLE `tourist_data_mapping` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '映射ID',
    `tourist_user_id` BIGINT UNSIGNED NOT NULL COMMENT '游客用户ID',
    `正式_user_id` BIGINT UNSIGNED NOT NULL COMMENT '正式用户ID',
    `data_type` VARCHAR(20) NOT NULL COMMENT '数据类型: bills-账单, accounts-账户, categories-分类',
    `original_id` BIGINT UNSIGNED NOT NULL COMMENT '原(游客)数据ID',
    `new_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '合并后的新数据ID',
    `merged_at` DATETIME DEFAULT NULL COMMENT '合并时间',
    `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0-待合并, 1-已合并, 2-已丢弃',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_tourist_user_id` (`tourist_user_id`),
    KEY `idx_formal_user_id` (`正式_user_id`),
    KEY `idx_status` (`status`),
    CONSTRAINT `fk_tourist_mapping_tourist` FOREIGN KEY (`tourist_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_tourist_mapping_formal` FOREIGN KEY (`正式_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游客数据关联表';

-- ============================================
-- 9. 数据导出记录表 (data_exports)
-- ============================================
CREATE TABLE `data_exports` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '导出记录ID',
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '所属用户ID',
    `export_type` VARCHAR(20) NOT NULL COMMENT '导出类型: excel, csv, json',
    `date_from` DATE DEFAULT NULL COMMENT '导出数据起始日期',
    `date_to` DATE DEFAULT NULL COMMENT '导出数据截止日期',
    `file_url` VARCHAR(500) DEFAULT NULL COMMENT '导出文件URL(云存储)',
    `file_size` BIGINT DEFAULT NULL COMMENT '文件大小(字节)',
    `record_count` INT DEFAULT NULL COMMENT '导出记录数',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-失败, 1-成功, 2-处理中',
    `error_message` VARCHAR(500) DEFAULT NULL COMMENT '错误信息',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `expires_at` DATETIME DEFAULT NULL COMMENT '过期时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_created_at` (`created_at`),
    CONSTRAINT `fk_data_exports_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='数据导出记录表';

-- ============================================
-- 10. 系统预设分类数据(种子数据)
-- ============================================

-- 预设支出分类
INSERT INTO `expense_categories` (`id`, `user_id`, `name`, `icon`, `color`, `sort_order`, `is_system`) VALUES
(1, NULL, '餐饮', '🍜', '#FFB7C5', 1, 1),
(2, NULL, '交通', '🚗', '#B8E0D2', 2, 1),
(3, NULL, '购物', '🛒', '#FFDAB3', 3, 1),
(4, NULL, '娱乐', '🎮', '#D5AAFF', 4, 1),
(5, NULL, '居住', '🏠', '#FFEEBB', 5, 1),
(6, NULL, '医疗', '💊', '#FFB3BA', 6, 1),
(7, NULL, '教育', '📚', '#BAFFC9', 7, 1),
(8, NULL, '通讯', '📱', '#FFFFBA', 8, 1),
(9, NULL, '旅行', '✈️', '#BDE0FE', 9, 1),
(10, NULL, '人情', '🎁', '#FFAACC', 10, 1),
(11, NULL, '水果', '🍎', '#FFAAA5', 11, 1),
(12, NULL, '日用品', '🧴', '#CAFFBF', 12, 1),
(13, NULL, '其他', '📦', '#E0E0E0', 99, 1);

-- 预设收入分类
INSERT INTO `income_categories` (`id`, `user_id`, `name`, `icon`, `color`, `sort_order`, `is_system`) VALUES
(1, NULL, '工资', '💰', '#7DD3C0', 1, 1),
(2, NULL, '奖金', '🎉', '#FFD700', 2, 1),
(3, NULL, '兼职', '💼', '#B8E0D2', 3, 1),
(4, NULL, '理财', '📈', '#90EE90', 4, 1),
(5, NULL, '退款', '🔙', '#C9B8AF', 5, 1),
(6, NULL, '销售', '🛍️', '#FFB7C5', 6, 1),
(7, NULL, '服务', '🤝', '#D5AAFF', 7, 1),
(8, NULL, '其他', '📤', '#FFCCE0', 99, 1);

-- 商户预设收入分类
INSERT INTO `income_categories` (`id`, `user_id`, `name`, `icon`, `color`, `sort_order`, `is_system`) VALUES
(9, NULL, '商品销售', '🛒', '#FFB7C5', 6, 1),
(10, NULL, '服务收入', '🤝', '#B8E0D2', 7, 1),
(11, NULL, '批发', '📦', '#D5AAFF', 8, 1);

-- ============================================
-- 11. 视图定义 - 便于统计查询
-- ============================================

-- 月度支出统计视图
CREATE OR REPLACE VIEW `v_monthly_expense` AS
SELECT
    `b`.`user_id` AS `user_id`,
    `b`.`ledger_id` AS `ledger_id`,
    YEAR(`b`.`date`) AS `year`,
    MONTH(`b`.`date`) AS `month`,
    `ec`.`id` AS `category_id`,
    `ec`.`name` AS `category_name`,
    `ec`.`icon` AS `category_icon`,
    `ec`.`color` AS `category_color`,
    SUM(`b`.`amount`) AS `total_amount`,
    COUNT(*) AS `bill_count`
FROM `bills` `b`
INNER JOIN `expense_categories` `ec` ON `b`.`category_id` = `ec`.`id`
WHERE `b`.`deleted_at` IS NULL AND `b`.`type` = 'expense'
GROUP BY `b`.`user_id`, `b`.`ledger_id`, YEAR(`b`.`date`), MONTH(`b`.`date`), `ec`.`id`, `ec`.`name`, `ec`.`icon`, `ec`.`color`;

-- 月度收入统计视图
CREATE OR REPLACE VIEW `v_monthly_income` AS
SELECT
    `b`.`user_id` AS `user_id`,
    `b`.`ledger_id` AS `ledger_id`,
    YEAR(`b`.`date`) AS `year`,
    MONTH(`b`.`date`) AS `month`,
    `ic`.`id` AS `category_id`,
    `ic`.`name` AS `category_name`,
    `ic`.`icon` AS `category_icon`,
    `ic`.`color` AS `category_color`,
    SUM(`b`.`amount`) AS `total_amount`,
    COUNT(*) AS `bill_count`
FROM `bills` `b`
INNER JOIN `income_categories` `ic` ON `b`.`category_id` = `ic`.`id`
WHERE `b`.`deleted_at` IS NULL AND `b`.`type` = 'income'
GROUP BY `b`.`user_id`, `b`.`ledger_id`, YEAR(`b`.`date`), MONTH(`b`.`date`), `ic`.`id`, `ic`.`name`, `ic`.`icon`, `ic`.`color`;

-- 账户余额视图
CREATE OR REPLACE VIEW `v_account_balance` AS
SELECT
    `a`.`id` AS `account_id`,
    `a`.`user_id` AS `user_id`,
    `a`.`name` AS `account_name`,
    `a`.`type` AS `account_type`,
    `a`.`initial_balance` AS `initial_balance`,
    `a`.`current_balance` AS `current_balance`,
    COALESCE(`income`.`total_income`, 0) - COALESCE(`expense`.`total_expense`, 0) AS `calculated_balance`,
    `a`.`updated_at` AS `last_updated`
FROM `accounts` `a`
LEFT JOIN (
    SELECT `account_id`, SUM(`amount`) AS `total_income`
    FROM `bills` WHERE `type` = 'income' AND `deleted_at` IS NULL GROUP BY `account_id`
) `income` ON `a`.`id` = `income`.`account_id`
LEFT JOIN (
    SELECT `account_id`, SUM(`amount`) AS `total_expense`
    FROM `bills` WHERE `type` = 'expense' AND `deleted_at` IS NULL GROUP BY `account_id`
) `expense` ON `a`.`id` = `expense`.`account_id`
WHERE `a`.`deleted_at` IS NULL;

-- ============================================
-- 12. 存储过程 - 账户余额自动计算
-- ============================================

DELIMITER //

CREATE PROCEDURE `sp_calculate_account_balance`(IN p_account_id BIGINT)
BEGIN
    DECLARE v_initial DECIMAL(15,2);
    DECLARE v_income DECIMAL(15,2);
    DECLARE v_expense DECIMAL(15,2);
    DECLARE v_balance DECIMAL(15,2);

    SELECT `initial_balance` INTO v_initial FROM `accounts` WHERE `id` = p_account_id;

    SELECT COALESCE(SUM(`amount`), 0) INTO v_income
    FROM `bills`
    WHERE `account_id` = p_account_id AND `type` = 'income' AND `deleted_at` IS NULL;

    SELECT COALESCE(SUM(`amount`), 0) INTO v_expense
    FROM `bills`
    WHERE `account_id` = p_account_id AND `type` = 'expense' AND `deleted_at` IS NULL;

    SET v_balance = v_initial + v_income - v_expense;

    UPDATE `accounts` SET `current_balance` = v_balance WHERE `id` = p_account_id;
END //

DELIMITER ;

-- ============================================
-- 13. 存储过程 - 预算已消费金额更新
-- ============================================

DELIMITER //

CREATE PROCEDURE `sp_update_budget_spent`(IN p_user_id BIGINT, IN p_ledger_id BIGINT, IN p_year INT, IN p_month INT)
BEGIN
    -- 更新总预算已消费金额
    UPDATE `budgets` b
    SET `spent_amount` = (
        SELECT COALESCE(SUM(`amount`), 0)
        FROM `bills`
        WHERE `user_id` = p_user_id
          AND `ledger_id` = p_ledger_id
          AND `type` = 'expense'
          AND YEAR(`date`) = p_year
          AND MONTH(`date`) = p_month
          AND `deleted_at` IS NULL
    )
    WHERE b.`user_id` = p_user_id
      AND b.`ledger_id` = p_ledger_id
      AND b.`year` = p_year
      AND b.`month` = p_month
      AND b.`type` = 'total';

    -- 更新分类预算已消费金额
    UPDATE `budgets` b
    SET `spent_amount` = (
        SELECT COALESCE(SUM(`amount`), 0)
        FROM `bills`
        WHERE `user_id` = p_user_id
          AND `ledger_id` = p_ledger_id
          AND `type` = 'expense'
          AND `category_id` = b.`category_id`
          AND YEAR(`date`) = p_year
          AND MONTH(`date`) = p_month
          AND `deleted_at` IS NULL
    )
    WHERE b.`user_id` = p_user_id
      AND b.`ledger_id` = p_ledger_id
      AND b.`year` = p_year
      AND b.`month` = p_month
      AND b.`type` = 'category';
END //

DELIMITER ;

-- ============================================
-- 14. 触发器 - 账单创建/更新/删除时自动更新账户余额
-- ============================================

DELIMITER //

-- 账单创建后触发 - 增加收入/减少支出账户余额
CREATE TRIGGER `tr_bill_after_insert`
AFTER INSERT ON `bills`
FOR EACH ROW
BEGIN
    IF NEW.`type` = 'income' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` + NEW.`amount` WHERE `id` = NEW.`account_id`;
    ELSEIF NEW.`type` = 'expense' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` - NEW.`amount` WHERE `id` = NEW.`account_id`;
    END IF;
END//

-- 账单更新后触发 - 回滚旧余额,应用新余额
CREATE TRIGGER `tr_bill_after_update`
AFTER UPDATE ON `bills`
FOR EACH ROW
BEGIN
    -- 回滚旧记录影响
    IF OLD.`type` = 'income' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` - OLD.`amount` WHERE `id` = OLD.`account_id`;
    ELSEIF OLD.`type` = 'expense' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` + OLD.`amount` WHERE `id` = OLD.`account_id`;
    END IF;

    -- 应用新记录影响
    IF NEW.`type` = 'income' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` + NEW.`amount` WHERE `id` = NEW.`account_id`;
    ELSEIF NEW.`type` = 'expense' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` - NEW.`amount` WHERE `id` = NEW.`account_id`;
    END IF;
END//

-- 账单删除后触发 - 回滚余额
CREATE TRIGGER `tr_bill_after_delete`
AFTER DELETE ON `bills`
FOR EACH ROW
BEGIN
    IF OLD.`type` = 'income' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` - OLD.`amount` WHERE `id` = OLD.`account_id`;
    ELSEIF OLD.`type` = 'expense' THEN
        UPDATE `accounts` SET `current_balance` = `current_balance` + OLD.`amount` WHERE `id` = OLD.`account_id`;
    END IF;
END//

DELIMITER ;

-- ============================================
-- 15. 索引优化建议(可选)
-- ============================================
-- 对于大数据量场景,可考虑添加以下复合索引:
-- ALTER TABLE `bills` ADD INDEX `idx_user_ledger_date_type` (`user_id`, `ledger_id`, `date`, `type`);
-- ALTER TABLE `bills` ADD INDEX `idx_user_month_category` (`user_id`, `date`, `category_id`);

-- ============================================
-- 16. 数据库注释说明
-- ============================================
-- 1. 所有表使用 BIGINT UNSIGNED 作为主键,支持更大数据量
-- 2. 使用软删除(deleted_at),保护数据完整性
-- 3. 账户余额由触发器自动维护,确保数据一致性
-- 4. 预算已消费金额由存储过程计算,避免实时计算性能问题
-- 5. 所有时间字段使用 DATETIME,CET(中国时区)
-- 6. 金额使用 DECIMAL(15,2),支持最大999亿级别,精确到分
