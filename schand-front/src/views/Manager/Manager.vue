<script setup>
/**
 * 后台管理系统布局组件
 * 提供响应式布局、主题切换、侧边栏折叠等功能
 */
import { useUserStore } from '@/stores/userStore'
import { useRouter, useRoute } from 'vue-router'
import { ref, reactive, computed, onMounted, watch, nextTick, onBeforeUnmount } from 'vue'
import { useFullscreen } from '@vueuse/core'
import {
    DataAnalysis, Menu, User, Sunny, Moon, Monitor, FullScreen,
    ArrowDown, ArrowRight, SwitchButton, Key, Avatar, UserFilled, Ticket,
    Goods, Connection, ChatDotRound, Search, Location, ChatLineSquare,
    Bell, Warning, Expand, Fold, Clock, Loading, Message, Aim, Coin, Postcard, Check
} from '@element-plus/icons-vue'
import httpInstance from '@/utils/http'

// ===== 状态管理 =====
const userStore = useUserStore()
const router = useRouter()
const route = useRoute()

// ===== 响应式数据 =====
// 用户信息
const user = computed(() => userStore.userInfo)

// 当前时间
const currentTime = ref(new Date().toLocaleString('zh-CN', { hour12: false }))
let clockTimer = null

// 页面状态
const pageState = reactive({
    isInitialized: false,     // 页面是否已初始化
    isLoading: true,          // 页面加载状态
    lastRoute: null,          // 上一个路由
})

// 导航与布局
const navState = reactive({
    isCollapse: false,        // 侧边栏是否折叠
    isMobile: false,          // 是否为移动设备
    mobileMenuVisible: false, // 移动设备侧边菜单是否可见
    activeSubmenu: [],        // 当前活动的子菜单
    tabNavs: []               // 标签导航项
})

// 全屏控制
const { isFullscreen, toggle: toggleFullscreen } = useFullscreen()

// 主题设置
const theme = ref(localStorage.getItem('admin-theme') || 'light')
const themeOptions = [
    { value: 'light', label: '浅色', icon: 'Sunny' },
    { value: 'dark', label: '深色', icon: 'Moon' },
    { value: 'auto', label: '跟随系统', icon: 'Monitor' }
]

// 计算属性
const sidebarWidth = computed(() => (
    navState.isCollapse ? '64px' : navState.isMobile ? '0' : '240px'
))

const delayedSidebarWidth = ref(sidebarWidth.value)

// ===== 菜单配置 =====
// 管理系统模块
const systemModules = [
    {
        id: 'dashboard',
        title: '仪表盘',
        icon: 'DataAnalysis',
        path: '/manager/dashboard'
    },
    {
        id: 'business',
        title: '业务管理',
        icon: 'Menu',
        path: '/manager/business',
        children: [
            { id: 'category', title: '分类信息', path: '/manager/category', icon: 'Coin' },
            { id: 'goods', title: '商品信息', path: '/manager/goods', icon: 'Goods' },
            { id: 'circles', title: '圈子信息', path: '/manager/circles', icon: 'Connection' },
            { id: 'posts', title: '帖子信息', path: '/manager/posts', icon: 'Postcard' },
            { id: 'wanted', title: '悬赏信息', path: '/manager/wanted', icon: 'Aim' },
            { id: 'address', title: '地址信息', path: '/manager/address', icon: 'Location' },
            { id: 'comment', title: '评论信息', path: '/manager/comment', icon: 'ChatLineSquare' },
            { id: 'notice', title: '公告信息', path: '/manager/notice', icon: 'Bell' },
            { id: 'feedback', title: '反馈信息', path: '/manager/feedback', icon: 'Message' }
        ]
    },
    {
        id: 'role',
        title: '角色管理',
        icon: 'User',
        path: '/manager/role',
        children: [
            { id: 'user', title: '用户信息', path: '/manager/user', icon: 'Avatar' },
            { id: 'admin', title: '管理员信息', path: '/manager/admin', icon: 'UserFilled' }
        ]
    }
]

// 获取当前活动模块
const activeModule = computed(() => {
    // 查找当前路由匹配的模块
    for (const module of systemModules) {
        if (module.path === route.path) return module

        if (module.children) {
            const child = module.children.find(child => child.path === route.path)
            if (child) return { ...child, parent: module }
        }
    }

    return null
})

// 面包屑
const breadcrumbs = computed(() => {
    // 查找当前路由对应的模块
    for (const module of systemModules) {
        if (module.children) {
            for (const subModule of module.children) {
                if (route.path === subModule.path) {
                    return [
                        {
                            path: module.path,
                            title: module.title,
                            icon: module.icon
                        },
                        {
                            path: subModule.path,
                            title: subModule.title || route.meta.name
                        }
                    ]
                }
            }
        } else if (route.path === module.path) {
            return [
                {
                    path: module.path,
                    title: module.title,
                    icon: module.icon
                }
            ]
        }
    }

    // 默认面包屑：未知页面
    return [
        {
            path: route.path,
            title: route.meta.name || '未知页面'
        }
    ]
})

// ===== 交互方法 =====
/**
 * 切换侧边栏折叠状态
 */
const toggleSidebar = () => {
    navState.isCollapse = !navState.isCollapse
    // 移动设备处理
    if (navState.isMobile) {
        navState.mobileMenuVisible = !navState.mobileMenuVisible
    }
}

/**
 * 切换主题
 */
const toggleTheme = () => {
    // 获取当前主题在选项中的索引
    const currentIndex = themeOptions.findIndex(option => option.value === theme.value)
    // 切换到下一个主题（循环）
    const nextIndex = (currentIndex + 1) % themeOptions.length
    theme.value = themeOptions[nextIndex].value

    // 保存并应用主题设置
    localStorage.setItem('admin-theme', theme.value)
    applyTheme(theme.value)
}

/**
 * 应用主题
 * @param {string} themeName - 主题名称
 */
const applyTheme = (themeName) => {
    // 自动主题根据系统偏好设置
    if (themeName === 'auto') {
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
        document.documentElement.setAttribute('data-theme', prefersDark ? 'dark' : 'light')
    } else {
        document.documentElement.setAttribute('data-theme', themeName)
    }
}

/**
 * 退出登录
 */
const logout = async () => {
    try {
        await ElMessageBox.confirm('确定要退出登录吗?', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
        })

        userStore.logout()
        router.push('/login')
        ElMessage.success('已安全退出登录')
    } catch (error) {
        // 用户取消，不做处理
    }
}

/**
 * 窗口尺寸变化处理
 */
const handleResize = () => {
    const width = window.innerWidth
    navState.isMobile = width <= 768

    // 在移动设备上自动折叠侧边栏
    if (navState.isMobile && !navState.isCollapse) {
        navState.isCollapse = true
        navState.mobileMenuVisible = false
    }
    // 在桌面设备上自动展开侧边栏（大屏幕）
    else if (!navState.isMobile && width > 1200 && navState.isCollapse) {
        navState.isCollapse = false
    }
}

/**
 * 获取对应组件的图标
 * @param {string} name - 图标名称
 * @returns {Component} 图标组件
 */
const getIconComponent = (name) => {
    const iconMap = {
        'DataAnalysis': DataAnalysis,
        'Menu': Menu,
        'User': User,
        'Sunny': Sunny,
        'Moon': Moon,
        'Monitor': Monitor,
        'Ticket': Ticket,
        'Goods': Goods,
        'Connection': Connection,
        'Postcard': Postcard,
        'Search': Search,
        'Location': Location,
        'ChatLineSquare': ChatLineSquare,
        'Bell': Bell,
        'Warning': Warning,
        'Avatar': Avatar,
        'UserFilled': UserFilled,
        'Aim': Aim,
        'Message': Message,
        'Coin': Coin
    }

    return iconMap[name] || null
}

/**
 * 点击面包屑导航
 * @param {string} path - 目标路径
 */
const handleBreadcrumbClick = (path) => {
    if (path && path !== route.path) {
        router.push(path);

        // 在移动设备上导航后自动折叠菜单
        if (navState.isMobile) {
            navState.mobileMenuVisible = false;
        }
    }
};

/**
 * 导航到模块
 * @param {string} path - 目标路径
 */
const navigateToModule = (path) => {
    if (path) {
        router.push(path);

        // 在移动设备上导航后自动折叠菜单
        if (navState.isMobile) {
            navState.mobileMenuVisible = false;
        }
    }
}

/**
 * 更新时钟显示
 */
const updateClock = () => {
    // 立即更新一次
    currentTime.value = new Date().toLocaleString('zh-CN', { hour12: false })

    // 每秒更新一次
    clockTimer = setInterval(() => {
        currentTime.value = new Date().toLocaleString('zh-CN', { hour12: false })
    }, 1000)
}

// ===== 密码修改相关 =====
const passwordDialogVisible = ref(false)
const passwordFormRef = ref(null)
const passwordForm = reactive({
    password: '',
    newPassword: '',
    confirmPassword: ''
})

// 表单验证规则
const validatePassword = (rule, value, callback) => {
    if (value === '') {
        callback(new Error('请确认密码'))
    } else if (value !== passwordForm.newPassword) {
        callback(new Error('确认密码错误'))
    } else {
        callback()
    }
}

const passwordRules = {
    password: [
        { required: true, message: '请输入原始密码', trigger: 'blur' },
    ],
    newPassword: [
        { required: true, message: '请输入新密码', trigger: 'blur' },
        { min: 6, message: '密码长度不能少于6个字符', trigger: 'blur' }
    ],
    confirmPassword: [
        { validator: validatePassword, required: true, trigger: 'blur' },
    ],
}

// 打开密码修改对话框
const openPasswordDialog = () => {
    passwordDialogVisible.value = true
    // 重置表单
    passwordForm.password = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
    // 等待DOM更新后重置验证
    nextTick(() => {
        passwordFormRef.value && passwordFormRef.value.resetFields()
    })
}

// 更新密码
const updatePassword = async () => {
    if (!passwordFormRef.value) return

    await passwordFormRef.value.validate(async (valid) => {
        if (valid) {
            try {
                const reqData = {
                    ...user.value,
                    password: passwordForm.password,
                    newPassword: passwordForm.newPassword,
                    confirmPassword: passwordForm.confirmPassword
                }

                const res = await httpInstance.put('/updatePassword', reqData)

                if (res.code === '200') {
                    // 成功更新
                    userStore.clearUserInfo() // 清除用户信息
                    ElMessage.success('修改密码成功，请重新登录')
                    passwordDialogVisible.value = false
                    router.push('/login')
                } else {
                    ElMessage.error(res.msg || '修改密码失败')
                }
            } catch (error) {
                console.error('修改密码失败:', error)
                ElMessage.error('修改密码失败')
            }
        }
    })
}

// 取消修改密码
const cancelPasswordUpdate = () => {
    passwordDialogVisible.value = false
}

// ===== 生命周期钩子 =====
onMounted(async () => {
    // 检查登录状态
    if (!userStore.isLoggedIn()) {
        router.push('/login')
        return
    }

    // 初始化主题
    applyTheme(theme.value)

    // 启动时钟更新
    updateClock()

    // 监听窗口大小变化
    window.addEventListener('resize', handleResize)

    // 初始化侧边栏状态
    handleResize()

    // 添加全屏事件监听
    document.addEventListener('fullscreenchange', () => {
        isFullscreen.value = !!document.fullscreenElement
    })

    // 监听系统主题变化（用于自动主题模式）
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
        if (theme.value === 'auto') {
            applyTheme('auto')
        }
    })

    // 处理滚动区域优化
    nextTick(() => {
        const scrollContainer = document.querySelector('.manager-container .el-scrollbar__wrap')
        if (scrollContainer) {
            scrollContainer.style.overflowX = 'hidden'
        }
    })

    // 标记页面已初始化
    pageState.isInitialized = true
    pageState.isLoading = false
})

// 添加侧边栏宽度变化的平滑过渡
let transitionTimeout = null
watch(sidebarWidth, (newWidth) => {
    clearTimeout(transitionTimeout)
    transitionTimeout = setTimeout(() => {
        delayedSidebarWidth.value = newWidth
    }, 50)
})

// 组件销毁时清理
onBeforeUnmount(() => {
    // 移除事件监听
    window.removeEventListener('resize', handleResize)
    document.removeEventListener('fullscreenchange', () => { })
    window.matchMedia('(prefers-color-scheme: dark)').removeEventListener('change', () => { })

    // 清理计时器
    clearTimeout(transitionTimeout)

    // 清理时钟计时器
    if (clockTimer) {
        clearInterval(clockTimer)
        clockTimer = null
    }
})
</script>

<template>
    <div class="manager-container"
        :class="[`theme-${theme}`, { 'mobile': navState.isMobile, 'collapsed': navState.isCollapse }]">
        <!-- 顶部导航 -->
        <header class="manager-header">
            <!-- 左侧区域：Logo和切换按钮 -->
            <div class="manager-header-left">
                <!-- 折叠按钮 -->
                <div class="sidebar-toggle" @click="toggleSidebar">
                    <el-icon>
                        <component :is="navState.isCollapse ? Expand : Fold" />
                    </el-icon>
                </div>

                <div class="logo-container">
                    <img src="@/assets/icons/shop.svg" alt="Logo" class="app-logo" />
                    <h1 class="title">悠享二手交易管理后台</h1>
                </div>
            </div>

            <!-- 右侧功能区 -->
            <div class="manager-header-right">
                <!-- 功能按钮组 -->
                <div class="action-buttons">
                    <!-- 主题切换 -->
                    <div class="action-btn theme-toggle" @click="toggleTheme">
                        <el-tooltip :content="`切换主题 (当前: ${themeOptions.find(t => t.value === theme)?.label})`"
                            placement="bottom">
                            <el-icon>
                                <component :is="getIconComponent(themeOptions.find(t => t.value === theme)?.icon)" />
                            </el-icon>
                        </el-tooltip>
                    </div>

                    <!-- 全屏切换 -->
                    <div class="action-btn fullscreen-toggle" @click="toggleFullscreen">
                        <el-tooltip :content="isFullscreen ? '退出全屏' : '全屏显示'" placement="bottom">
                            <el-icon><full-screen /></el-icon>
                        </el-tooltip>
                    </div>
                </div>

                <!-- 用户信息和下拉菜单 -->
                <el-dropdown trigger="hover" class="user-dropdown">
                    <div class="avatar-wrapper">
                        <el-avatar
                            :src="user.avatar || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'"
                            :size="40" />
                        <el-icon class="el-icon--right"><arrow-down /></el-icon>
                    </div>
                    <template #dropdown>
                        <el-dropdown-menu>
                            <el-dropdown-item @click="openPasswordDialog">
                                <el-icon>
                                    <key />
                                </el-icon>
                                <span class="dropdown-item-text">修改密码</span>
                            </el-dropdown-item>
                            <el-dropdown-item divided @click="logout">
                                <el-icon><switch-button /></el-icon>
                                <span class="dropdown-item-text">退出登录</span>
                            </el-dropdown-item>
                        </el-dropdown-menu>
                    </template>
                </el-dropdown>
            </div>
        </header>

        <!-- 面包屑导航区 -->
        <div class="breadcrumb-container">
            <div class="breadcrumb-left">
                <el-breadcrumb :separator-icon="ArrowRight">
                    <template v-for="(item, index) in breadcrumbs" :key="index">
                        <el-breadcrumb-item :to="{ path: item.path }" @click="handleBreadcrumbClick(item.path)">
                            <span class="breadcrumb-item-content">
                                <el-icon v-if="item.icon">
                                    <component :is="getIconComponent(item.icon)" />
                                </el-icon>
                                <span>{{ item.title }}</span>
                            </span>
                        </el-breadcrumb-item>
                    </template>
                </el-breadcrumb>
            </div>

            <div class="breadcrumb-right">
                <span class="time-display">
                    <el-icon>
                        <clock />
                    </el-icon>
                    {{ currentTime }}
                </span>
            </div>
        </div>

        <!-- 主体内容区 -->
        <el-scrollbar>
            <div class="manager-main">
                <!-- 侧边栏导航 -->
                <aside class="manager-sidebar" :style="{ width: delayedSidebarWidth }"
                    :class="{ 'mobile-visible': navState.mobileMenuVisible }">
                    <div class="sidebar-content">
                        <el-menu :default-active="route.path" router class="sidebar-menu"
                            :collapse="navState.isCollapse" :collapse-transition="true" :unique-opened="true">
                            <!-- 所有功能模块 -->
                            <template v-for="module in systemModules" :key="module.id">
                                <!-- 如果是有子菜单的模块 -->
                                <el-sub-menu :index="module.id" v-if="module.children && module.children.length"
                                    class="menu-group" popper-class="sidebar-popper">
                                    <template #title>
                                        <el-icon>
                                            <component :is="getIconComponent(module.icon)" />
                                        </el-icon>
                                        <span>{{ module.title }}</span>
                                    </template>

                                    <el-menu-item v-for="subItem in module.children" :key="subItem.id"
                                        :index="subItem.path" class="submenu-item">
                                        <el-icon v-if="subItem.icon">
                                            <component :is="getIconComponent(subItem.icon)" />
                                        </el-icon>
                                        <template #title>
                                            <span>{{ subItem.title }}</span>
                                        </template>
                                    </el-menu-item>
                                </el-sub-menu>

                                <!-- 如果是无子菜单的模块 -->
                                <el-menu-item v-else :index="module.path" class="menu-item">
                                    <el-icon>
                                        <component :is="getIconComponent(module.icon)" />
                                    </el-icon>
                                    <template #title>
                                        <span>{{ module.title }}</span>
                                    </template>
                                </el-menu-item>
                            </template>
                        </el-menu>
                    </div>
                </aside>

                <!-- 遮罩层（移动端） -->
                <div class="sidebar-overlay" v-if="navState.mobileMenuVisible" @click="toggleSidebar"></div>

                <!-- 主内容区域 -->
                <main class="manager-content" :class="{ 'expanded': navState.isCollapse }">
                    <!-- 加载状态 -->
                    <div class="page-loading" v-if="pageState.isLoading">
                        <el-icon class="loading-icon">
                            <loading />
                        </el-icon>
                        <span>加载中...</span>
                    </div>

                    <div v-else class="content-wrapper">
                        <transition name="fade-transform" mode="out-in">
                            <router-view v-slot="{ Component }">
                                <keep-alive>
                                    <component :is="Component" />
                                </keep-alive>
                            </router-view>
                        </transition>
                    </div>
                </main>
            </div>
        </el-scrollbar>

        <!-- 密码修改对话框 -->
        <el-dialog v-model="passwordDialogVisible" title="修改密码" width="500px" center destroy-on-close
            :close-on-click-modal="false" class="password-dialog">
            <el-form ref="passwordFormRef" :model="passwordForm" :rules="passwordRules" label-width="100px">
                <el-form-item label="原始密码" prop="password">
                    <el-input show-password v-model="passwordForm.password" placeholder="请输入原始密码" />
                </el-form-item>
                <el-form-item label="新密码" prop="newPassword">
                    <el-input show-password v-model="passwordForm.newPassword" placeholder="请输入新密码" />
                </el-form-item>
                <el-form-item label="确认新密码" prop="confirmPassword">
                    <el-input show-password v-model="passwordForm.confirmPassword" placeholder="请确认新密码" />
                </el-form-item>
            </el-form>
            <template #footer>
                <div class="dialog-footer">
                    <el-button @click="cancelPasswordUpdate">取消</el-button>
                    <el-button type="primary" @click="updatePassword">
                        <el-icon>
                            <check />
                        </el-icon> 确认修改
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style scoped lang="scss">
/**
 * 通知管理组件样式
 */

// ===== 变量定义 =====
// 主色调
$primary-color: var(--el-color-primary);
$primary-light: var(--el-color-primary-light-3);
$primary-lighter: var(--el-color-primary-light-7);
$primary-dark: var(--el-color-primary-dark-2);

// 灰色系
$gray-50: #f9fafb;
$gray-100: #f3f4f6;
$gray-200: #e5e7eb;
$gray-300: #d1d5db;
$gray-400: #9ca3af;
$gray-500: #6b7280;
$gray-600: #4b5563;
$gray-700: #374151;
$gray-800: #1f2937;
$gray-900: #111827;

$success-color: #67c23a;
$warning-color: #e6a23c;
$danger-color: #f56c6c;
$info-color: #909399;

$text-primary: #333;
$text-secondary: #666;
$text-tertiary: #999;

$bg-main: #f5f7fa;
$bg-content: #fff;
$bg-header: var(--gray-600);
$bg-sidebar: var(--gray-100);
$bg-menu-hover: rgba(0, 0, 0, 0.06);
$bg-menu-active: rgba(94, 118, 255, 0.15);

$border-color: #e6e6e6;
$border-radius-small: 4px;
$border-radius-medium: 8px;
$border-radius-large: 12px;

$shadow-light: 0 2px 6px rgba(0, 0, 0, 0.05);
$shadow-medium: 0 4px 16px rgba(0, 0, 0, 0.1);
$shadow-large: 0 8px 24px rgba(0, 0, 0, 0.15);

$font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
$transition-time: 0.3s;
$transition-bezier: cubic-bezier(0.34, 1.56, 0.64, 1);

// 深色主题变量
.theme-dark {
    --primary-color: #4e66ff;
    --primary-color-rgb: 78, 102, 255;
    --primary-hover: #3a55f5;
    --primary-light: rgba(78, 102, 255, 0.2);
    --primary-gradient: linear-gradient(135deg, #3a4dd1, #2e72d1);
    --secondary-gradient: linear-gradient(135deg, #385cca, #2d3caa);

    --text-primary: #e5e5e5;
    --text-secondary: #b8b8b8;
    --text-tertiary: #888;

    --bg-main: #1a1a1a;
    --bg-content: #242424;
    --bg-header: var(--gray-800);
    --bg-sidebar: var(--gray-900);
    --bg-menu-hover: rgba(255, 255, 255, 0.06);
    --bg-menu-active: rgba(78, 102, 255, 0.25);

    --border-color: #333;
    --shadow-light: 0 2px 6px rgba(0, 0, 0, 0.15);
    --shadow-medium: 0 4px 16px rgba(0, 0, 0, 0.3);
    --shadow-large: 0 8px 30px rgba(0, 0, 0, 0.4);
}

// ===== 全局样式 =====
.manager-container {
    display: flex;
    flex-direction: column;
    //! 限制高度
    height: 98vh;
    max-height: 100vh;
    color: var(--text-primary);
    background-color: var(--bg-main);
    font-family: var(--font-family);
    transition: background-color var(--transition-time) ease;
    overflow: hidden;
    margin: 0;
    padding: 0;
    box-sizing: border-box;

    &.mobile {
        .manager-header-left {
            .title {
                display: none;
            }
        }
    }

    // 整体滚动区域样式
    :deep(.el-scrollbar__wrap) {
        overflow-x: hidden;
    }
}

// ===== 顶部导航 =====
.manager-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 8px 0 0;
    height: 64px;
    background: var(--bg-header);
    color: gray;
    box-shadow: var(--shadow-light);
    position: relative;
    z-index: 100;
    transition: all var(--transition-time) ease;

    // 添加立体感投影
    &:after {
        content: '';
        position: absolute;
        left: 0;
        right: 0;
        bottom: -6px;
        height: 6px;
        background: linear-gradient(to bottom, rgba(0, 0, 0, 0.1), transparent);
        pointer-events: none;
    }

    // 左侧区域
    &-left {
        display: flex;
        align-items: center;
        height: 100%;

        // 折叠按钮
        .sidebar-toggle {
            width: 64px;
            height: 64px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            background-color: rgba(0, 0, 0, 0.1);

            &:hover {
                background-color: rgba(0, 0, 0, 0.2);
            }

            .el-icon {
                font-size: 20px;
                transition: transform 0.5s var(--transition-bezier);
            }

            &:hover .el-icon {
                transform: scale(1.2);
            }
        }

        .logo-container {
            display: flex;
            align-items: center;
            height: 100%;
            padding: 0 16px;

            .app-logo {
                height: 36px;
                margin-right: 16px;
                filter: brightness(1.2);
                transition: all var(--transition-time) ease;
            }

            .title {
                font-size: 18px;
                font-weight: 600;
                margin: 0;
                letter-spacing: 0.5px;
                white-space: nowrap;
                opacity: 1;
                transition: opacity var(--transition-time) ease;
                text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
            }
        }
    }

    // 右侧区域
    &-right {
        display: flex;
        align-items: center;
        padding-right: 8px;

        .action-buttons {
            display: flex;
            margin-right: 16px;

            .action-btn {
                width: 36px;
                height: 36px;
                border-radius: var(--border-radius-medium);
                display: flex;
                align-items: center;
                justify-content: center;
                margin-left: 8px;
                cursor: pointer;
                transition: all var(--transition-time) ease;
                background: rgba(255, 255, 255, 0.1);

                &:hover {
                    background: rgba(255, 255, 255, 0.2);
                    transform: translateY(-2px);
                }

                &:active {
                    transform: translateY(0);
                }

                .el-icon {
                    font-size: 18px;
                    filter: drop-shadow(0 1px 1px rgba(0, 0, 0, 0.2));
                }
            }
        }

        .user-dropdown {
            .avatar-wrapper {
                display: flex;
                align-items: center;
                padding: 4px 8px;
                border-radius: 24px;
                cursor: pointer;
                transition: all var(--transition-time) ease;
                background: rgba(255, 255, 255, 0.1);

                &:hover {
                    background: rgba(255, 255, 255, 0.2);
                }

                .el-avatar {
                    border: 2px solid rgba(255, 255, 255, 0.6);
                }

                .el-icon--right {
                    margin-left: 8px;
                }
            }

            :deep(.el-dropdown-menu__item) {
                display: flex;
                align-items: center;
                padding: 10px 16px;

                .el-icon {
                    margin-right: 8px;
                    font-size: 16px;
                }

                .dropdown-item-text {
                    font-size: 14px;
                }
            }
        }
    }
}

// ===== 面包屑导航 =====
.breadcrumb-container {
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    background-color: gray;
    box-shadow: var(--shadow-light);
    z-index: 90;
    position: relative;

    .theme-dark & {
        background-color: var(--gray-700);
    }

    .breadcrumb-left {
        display: flex;
        align-items: center;

        :deep(.el-breadcrumb) {
            font-size: 14px;

            .el-breadcrumb__item {
                .breadcrumb-item-content {
                    display: flex;
                    align-items: center;

                    .el-icon {
                        margin-right: 4px;
                        color: var(--primary-color);
                    }
                }

                &:last-child {
                    .el-breadcrumb__inner {
                        font-weight: 600;
                        color: var(--primary-color);
                    }
                }
            }
        }
    }

    .breadcrumb-right {
        .time-display {
            display: flex;
            align-items: center;
            color: var(--text-secondary);
            font-size: 13px;
            padding: 6px 12px;
            border-radius: 20px;

            .el-icon {
                margin-right: 6px;
                color: var(--primary-color);
            }
        }
    }
}

// ===== 主体区域 =====
.manager-main {
    display: flex;
    flex: 1;
    position: relative;
    min-height: calc(100vh - 112px); // 减去顶部导航和面包屑高度
    max-height: calc(100vh - 112px); // 限制最大高度
}

// ===== 侧边栏 =====
.manager-sidebar {
    background: var(--bg-sidebar);
    height: calc(100vh - 112px); // 减去顶部导航和面包屑高度
    position: relative;
    box-shadow: var(--shadow-light);
    transition: all var(--transition-time) var(--transition-bezier);
    z-index: 80;
    border-right: 1px solid var(--border-color);

    .sidebar-content {
        height: 100%;
        overflow-y: auto;
        overflow-x: hidden;

        // 隐藏原生滚动条
        &::-webkit-scrollbar {
            width: 0;
            height: 0;
        }
    }

    .sidebar-header {
        height: 48px;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 12px 0;
        background-color: rgba(var(--primary-color-rgb), 0.05);
        border-bottom: 1px solid var(--gray-200);

        .theme-dark & {
            background-color: rgba(var(--primary-color-rgb), 0.1);
            border-bottom-color: var(--gray-800);
        }


    }

    .sidebar-menu {
        border-right: none;
        background-color: transparent;
        transition: all var(--transition-time) var(--transition-bezier);

        &.el-menu--collapse {
            width: 64px;
        }

        :deep(.el-menu-item),
        :deep(.el-sub-menu__title) {
            height: 50px;
            line-height: 50px;
            font-size: 14px;
            color: var(--gray-700);
            border-radius: 0;
            margin: 4px 0;
            transition: all 0.25s var(--transition-bezier);

            // 添加左侧指示条
            position: relative;

            &:before {
                content: '';
                position: absolute;
                left: 0;
                top: 0;
                bottom: 0;
                width: 4px;
                background: transparent;
                transition: all 0.3s var(--transition-bezier);
            }

            &:hover {
                background-color: var(--gray-200);

                &:before {
                    background: var(--primary-color);
                    opacity: 0.5;
                }
            }

            .el-icon {
                color: var(--gray-600);
                margin-right: 8px;
                transition: all 0.3s var(--transition-bezier);
            }

            // 菜单项悬停时图标效果
            &:hover .el-icon {
                color: var(--primary-color);
                transform: scale(1.15);
            }

            .theme-dark & {
                color: var(--gray-300);

                &:hover {
                    background-color: var(--gray-800);
                }

                .el-icon {
                    color: var(--gray-400);
                }
            }
        }

        :deep(.el-menu-item.is-active) {
            background-color: var(--bg-menu-active);
            color: var(--primary-color);
            font-weight: 500;

            // 活动项左侧高亮条
            &:before {
                background: var(--primary-color);
                opacity: 1;
            }

            .el-icon {
                color: var(--primary-color);
                transform: scale(1.15);
            }
        }

        // 子菜单样式
        :deep(.el-menu--inline) {
            background-color: var(--gray-100);
            border-radius: var(--border-radius-small);

            .theme-dark & {
                background-color: rgba(255, 255, 255, 0.03);
            }

            .el-menu-item {
                min-width: unset;
                height: 40px;
                line-height: 40px;
                border-radius: var(--border-radius-small);
                margin: 4px 0;
                color: var(--gray-700);

                .theme-dark & {
                    color: var(--gray-400);
                }

                &.is-active {
                    color: var(--primary-color);
                    background-color: var(--bg-menu-active);
                }
            }
        }
    }

    // 弹出的子菜单样式
    :deep(.sidebar-popper) {
        border-radius: var(--border-radius-medium);
        overflow: hidden;
        box-shadow: var(--shadow-medium);
        border: 1px solid var(--border-color);

        .el-menu--popup {
            min-width: 180px;
        }

        .el-menu-item {
            height: 40px;
            line-height: 40px;
            margin: 4px 0;

            .el-icon {
                margin-right: 8px;
            }

            &.is-active {
                color: var(--primary-color);
                background-color: var(--bg-menu-active);
            }
        }
    }

    // 移动端样式
    &.mobile-visible {
        position: fixed;
        left: 0;
        top: 112px; // 顶部导航和面包屑高度
        width: 240px !important;
        z-index: 100;
        box-shadow: var(--shadow-large);
        animation: slideInFromLeft var(--transition-time) ease;
    }
}

// 移动端菜单遮罩
.sidebar-overlay {
    position: fixed;
    top: 112px; // 顶部导航和面包屑高度
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 90;
    animation: fadeIn var(--transition-time) ease;
    backdrop-filter: blur(2px);
}

// 内容区域
.manager-content {
    flex: 1;
    padding: 20px;
    transition: all var(--transition-time) var(--transition-bezier);
    overflow: auto;
    position: relative;
    background-color: var(--bg-main);
    background-image:
        radial-gradient(ellipse at top left, rgba(var(--primary-color-rgb), 0.05) 0%, transparent 50%),
        radial-gradient(ellipse at bottom right, rgba(var(--primary-color-rgb), 0.05) 0%, transparent 70%);
    max-height: 100%;

    // 隐藏原生滚动条
    &::-webkit-scrollbar {
        width: 0;
        height: 0;
    }

    .theme-dark & {
        background-image:
            radial-gradient(ellipse at top left, rgba(var(--primary-color-rgb), 0.1) 0%, transparent 60%),
            radial-gradient(ellipse at bottom right, rgba(var(--primary-color-rgb), 0.08) 0%, transparent 70%);
    }

    .content-wrapper {
        max-width: 1800px;
        margin: 0 auto;
        border-radius: var(--border-radius-large);
        min-height: calc(100vh - 152px); // 考虑顶部导航和面包屑
        max-height: calc(100vh - 152px); // 限制最大高度
        position: relative;
        overflow: visible;
    }

    // 加载状态
    .page-loading {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;

        .loading-icon {
            font-size: 36px;
            color: var(--primary-color);
            margin-bottom: 16px;
            animation: rotate 1.5s linear infinite;
            filter: drop-shadow(0 0 8px rgba(var(--primary-color-rgb), 0.4));
        }
    }

    // 子组件容器样式增强
    :deep(.el-card) {
        transition: all var(--transition-time) ease;
        border-color: rgba(var(--primary-color-rgb), 0.1);
        box-shadow: var(--shadow-light);
        overflow: visible;
        border-radius: var(--border-radius-medium);

        &:hover {
            box-shadow: var(--shadow-medium);
            transform: translateY(-2px);
        }

        // 卡片标题栏
        .el-card__header {
            padding: 12px 16px;
            font-weight: 500;
            border-bottom: 1px solid rgba(var(--primary-color-rgb), 0.1);
            background: linear-gradient(to right, rgba(var(--primary-color-rgb), 0.05), transparent);
        }
    }

    // 表格相关样式
    :deep(.el-table) {
        --el-table-border-color: rgba(var(--primary-color-rgb), 0.1);
        --el-table-header-bg-color: rgba(var(--primary-color-rgb), 0.05);
        --el-table-row-hover-bg-color: rgba(var(--primary-color-rgb), 0.03);

        .el-table__header-wrapper {
            th {
                background-color: rgba(var(--primary-color-rgb), 0.08);
                font-weight: 600;
            }
        }

        // 表格行高亮
        .el-table__row.highlight-row {
            background-color: rgba(var(--primary-color-rgb), 0.05);
        }
    }

    // 按钮组样式优化
    :deep(.el-button) {
        &+.el-button {
            margin-left: 8px;
        }

        // 主按钮阴影效果
        &.el-button--primary {
            box-shadow: 0 2px 6px rgba(var(--primary-color-rgb), 0.3);

            &:hover {
                box-shadow: 0 4px 12px rgba(var(--primary-color-rgb), 0.4);
                transform: translateY(-1px);
            }
        }
    }
}

// ===== 响应式适配 =====
@media (max-width: 768px) {
    .manager-header {
        padding: 0;

        &-left {
            .logo-container {
                .title {
                    display: none;
                }
            }
        }

        &-right {
            .user-dropdown {
                .avatar-wrapper {
                    padding: 4px;

                    .el-icon--right {
                        display: none;
                    }
                }
            }
        }
    }

    .manager-sidebar {
        position: fixed;
        left: -100%;
        width: 240px !important;
    }

    .manager-content {
        padding: 16px;
        width: 100% !important;
        max-height: calc(100vh - 112px);
    }

    .breadcrumb-container {
        .breadcrumb-right {
            display: none;
        }
    }
}

// ===== 动画效果 =====
// 淡入淡出
@keyframes fadeIn {
    from {
        opacity: 0;
    }

    to {
        opacity: 1;
    }
}

// 从左侧滑入
@keyframes slideInFromLeft {
    from {
        transform: translateX(-100%);
        opacity: 0;
    }

    to {
        transform: translateX(0);
        opacity: 1;
    }
}

// 旋转动画
@keyframes rotate {
    from {
        transform: rotate(0deg);
    }

    to {
        transform: rotate(360deg);
    }
}

// 页面内容切换过渡
.fade-transform-enter-active,
.fade-transform-leave-active {
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-transform-enter-from {
    transform: translateX(20px);
    opacity: 0;
}

.fade-transform-leave-to {
    transform: translateX(-20px);
    opacity: 0;
}

// 密码修改对话框
.password-dialog {
    :deep(.el-dialog__header) {
        padding: 20px 24px;
        font-weight: 600;
        border-bottom: 1px solid var(--border-color);
        margin-right: 0;
        text-align: left;
    }

    :deep(.el-dialog__body) {
        padding: 24px 24px 0;
    }

    :deep(.el-dialog__footer) {
        padding: 10px 24px 24px;
        border-top: none;
    }

    :deep(.el-form-item__label) {
        font-weight: 500;
    }

    :deep(.el-input__wrapper) {
        border-radius: 8px;
    }

    .dialog-footer {
        display: flex;
        justify-content: flex-end;
        gap: 12px;

        .el-button {
            padding: 10px 20px;

            .el-icon {
                margin-right: 4px;
            }
        }
    }
}
</style>