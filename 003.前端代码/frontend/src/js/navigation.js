/**
 * 财务管家 - 共享导航组件
 * Financial Steward - Shared Navigation Components
 */

// 页面名称到图标和链接的映射
const PAGE_CONFIG = {
    'dashboard': { icon: 'dashboard', label: '首页', href: 'dashboard.html' },
    'transactions': { icon: 'receipt_long', label: '账单', href: 'transactions.html' },
    'statistics': { icon: 'bar_chart', label: '统计', href: 'statistics.html' },
    'settings': { icon: 'settings', label: '设置', href: 'settings.html' }
};

/**
 * 创建顶部导航栏
 * @param {Object} options 配置选项
 * @param {string} options.title 页面标题
 * @param {boolean} options.showBack 是否显示返回按钮
 * @param {string} options.backHref 返回链接
 * @param {boolean} options.showUser 是否显示用户图标
 */
function createHeader({ title = '财务管家', showBack = false, backHref = '#', showUser = false }) {
    return `
    <header class="fixed top-0 left-0 right-0 z-50 bg-white/95 backdrop-blur-xl border-b border-rose-100/20">
        <div class="max-w-lg mx-auto h-14 flex items-center justify-between px-4">
            ${showBack ? `
                <a href="${backHref}" class="flex items-center gap-2 text-primary hover:text-primary-container transition-colors">
                    <span class="material-symbols-outlined text-2xl">arrow_back</span>
                </a>
            ` : `
                <div class="flex items-center gap-2">
                    <span class="text-xl">🧸</span>
                    <h1 class="text-lg font-bold text-primary">${title}</h1>
                </div>
            `}
            <div class="flex items-center gap-2">
                ${showUser ? `
                    <button class="w-10 h-10 rounded-full bg-primary-container/30 flex items-center justify-center" onclick="toggleUserMenu()">
                        <span class="material-symbols-outlined text-primary">account_circle</span>
                    </button>
                ` : ''}
            </div>
        </div>
    </header>
    `;
}

/**
 * 创建底部标签栏
 * @param {string} currentPage 当前页面标识
 */
function createTabBar(currentPage) {
    const tabs = ['dashboard', 'transactions', 'statistics', 'settings'];
    return `
    <nav class="tab-bar">
        ${tabs.map(page => {
            const config = PAGE_CONFIG[page];
            const isActive = currentPage === page;
            return `
            <a href="${config.href}" class="tab-item ${isActive ? 'active' : ''}">
                <span class="material-symbols-outlined">${config.icon}</span>
                <span>${config.label}</span>
            </a>
            `;
        }).join('')}
    </nav>
    `;
}

/**
 * 创建快速记账按钮
 */
function createAddButton() {
    return `
    <a href="add-record.html" class="fixed bottom-20 left-1/2 -translate-x-1/2 z-40 bg-sakura-gradient text-white px-6 py-3 rounded-full shadow-lg flex items-center gap-2 font-semibold hover:brightness-105 active:scale-95 transition-all">
        <span class="material-symbols-outlined">add</span>
        <span>记一笔</span>
    </a>
    `;
}

/**
 * 初始化页面导航
 * @param {string} currentPage 当前页面标识
 * @param {Object} options 额外配置
 */
function initNavigation(currentPage, options = {}) {
    const { showTabBar = true, showAddButton = false, title = '财务管家' } = options;

    // 如果页面有 header-placeholder 或 tabbar-placeholder，替换它们
    const headerPlaceholder = document.getElementById('header-placeholder');
    const tabbarPlaceholder = document.getElementById('tabbar-placeholder');
    const addButtonPlaceholder = document.getElementById('add-button-placeholder');

    if (headerPlaceholder) {
        headerPlaceholder.outerHTML = createHeader({
            title,
            showBack: options.showBack || false,
            backHref: options.backHref || '#',
            showUser: options.showUser !== false
        });
    }

    if (tabbarPlaceholder && showTabBar) {
        tabbarPlaceholder.outerHTML = createTabBar(currentPage);
    }

    if (addButtonPlaceholder && showAddButton) {
        addButtonPlaceholder.outerHTML = createAddButton();
    }
}

/**
 * 用户菜单切换
 */
function toggleUserMenu() {
    const menu = document.getElementById('user-menu');
    if (menu) {
        menu.classList.toggle('hidden');
    }
}

/**
 * 页面跳转帮助函数
 */
function navigateTo(page) {
    window.location.href = `${page}.html`;
}
