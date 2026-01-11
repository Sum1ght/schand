<script setup>
/**
 * 全局导航栏组件
 * 提供全站导航、用户菜单和状态管理
 */
import { useUserStore } from '@/stores/userStore'
import { ElMessage } from 'element-plus'
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// 导入图标组件
import {
    Aim,
    Bell,
    ChatDotRound,
    Collection,
    Goods,
    Location,
    Message,
    Postcard,
    Promotion,
    ShoppingCart,
    SwitchButton,
    Tickets,
    User
} from '@element-plus/icons-vue'

// 状态管理
const userStore = useUserStore()
const router = useRouter()
const route = useRoute()

// 响应式状态
const isLoggedIn = computed(() => userStore.isLoggedIn())
const logoutVisible = ref(false)
const mobileMenuOpen = ref(false)
const scrolled = ref(false)
const notificationCount = ref(0)
const showNotificationDot = ref(false)

// 主导航菜单
const mainNavItems = [
    {
        path: '/square',
        name: '广场',
        icon: ShoppingCart,
        description: '浏览二手商品'
    },
    {
        path: '/community',
        name: '社区',
        icon: ChatDotRound,
        description: '交流互动分享'
    },
    {
        path: '/wanted',
        name: '悬赏',
        icon: Aim,
        description: '发布悬赏需求'
    },
    {
        path: '/notice',
        name: '公告',
        icon: Bell,
        description: '系统通知更新'
    },
    {
        path: '/feedback',
        name: '反馈',
        icon: Message,
        description: '提交意见建议'
    }
]

// 用户菜单项
const userMenuItems = [
    {
        path: '/personal/myinfo',
        name: '我的资料',
        icon: User,
        divider: false
    },
    {
        path: '/personal/myorder',
        name: '我的订单',
        icon: Tickets,
        divider: false
    },
    {
        path: '/personal/mygoods',
        name: '我的商品',
        icon: Goods,
        divider: false
    },
    {
        path: '/personal/mypost',
        name: '我的帖子',
        icon: Postcard,
        divider: false
    },
    {
        path: '/personal/mywanted',
        name: '我的悬赏',
        icon: Aim,
        divider: false
    },
    {
        path: '/personal/mycollection',
        name: '我的收藏',
        icon: Collection,
        divider: false
    },
    {
        path: '/personal/myaddress',
        name: '我的地址',
        icon: Location,
        divider: false
    },
    {
        path: '/personal/myfeedback',
        name: '我的反馈',
        icon: Message,
        divider: false
    }
]

// 获取当前活动路由
const activeRoute = computed(() => {
    return '/' + route.path.split('/')[1]
})

// 监听滚动事件，修改导航栏样式
const handleScroll = () => {
    scrolled.value = window.scrollY > 20
}

// 退出登录
const logout = () => {
    userStore.logout()
    router.push('/login')
    logoutVisible.value = false
    ElMessage.success('您已成功退出登录')
}

// 显示退出确认
const showLogoutConfirm = () => {
    logoutVisible.value = true
}

// 切换移动端菜单
const toggleMobileMenu = () => {
    mobileMenuOpen.value = !mobileMenuOpen.value
}

// 关闭移动端菜单
const closeMobileMenu = () => {
    mobileMenuOpen.value = false
}

// 路由跳转后关闭移动端菜单
watch(() => route.path, () => {
    closeMobileMenu()
})

// 检查是否有未读通知
const checkNotifications = () => {
    // 模拟获取未读通知数量的逻辑
    // 实际项目中可以从API获取未读数据
    const hasUnread = Math.random() > 0.5
    showNotificationDot.value = hasUnread
    if (hasUnread) {
        notificationCount.value = Math.floor(Math.random() * 5) + 1
    }
}

// 生命周期钩子
onMounted(() => {
    // 添加滚动监听
    window.addEventListener('scroll', handleScroll)
    handleScroll() // 初始检查

    // 检查通知状态
    checkNotifications()

    // 监听页面可见性变化，当用户返回页面时检查通知
    document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') {
            checkNotifications()
        }
    })
})

// 清理事件监听
onBeforeUnmount(() => {
    window.removeEventListener('scroll', handleScroll)
    document.removeEventListener('visibilitychange', checkNotifications)
})
</script>

<template>
    <nav class="app-navbar" :class="{ 'scrolled': scrolled }">
        <div class="container">
            <!-- 左侧Logo区域 -->
            <div class="logo-area">
                <RouterLink to="/" class="logo-link">
                    <div class="logo-wrapper">
                        <img src="@/assets/icons/shop.svg" alt="悠享二手交易网" class="logo-image">
                        <span class="logo-text">悠享二手交易网</span>
                        <span class="kaomoji">✧*｡٩(ˊᗜˋ*)و✧*｡</span>
                    </div>
                </RouterLink>

                <!-- 移动端菜单按钮 -->
                <div class="mobile-menu-toggle" @click="toggleMobileMenu">
                    <div class="hamburger" :class="{ 'active': mobileMenuOpen }">
                        <span></span>
                        <span></span>
                        <span></span>
                    </div>
                </div>
            </div>

            <!-- 中间菜单区域 -->
            <div class="menu-area" :class="{ 'mobile-open': mobileMenuOpen }">
                <transition name="fade-slide">
                    <ul class="menu-list" v-show="!mobileMenuOpen || (mobileMenuOpen && window.innerWidth <= 768)">
                        <li v-for="item in mainNavItems" :key="item.path">
                            <RouterLink :to="item.path" active-class="active" class="nav-link">
                                <el-tooltip :content="item.description" placement="bottom" :disabled="mobileMenuOpen"
                                    :show-after="300" :hide-after="100">
                                    <div class="nav-link-content">
                                        <el-icon class="nav-icon">
                                            <component :is="item.icon" />
                                        </el-icon>
                                        <span class="nav-text">{{ item.name }}</span>
                                    </div>
                                </el-tooltip>
                            </RouterLink>
                        </li>
                    </ul>
                </transition>
            </div>

            <!-- 右侧用户区域 -->
            <div class="user-area">
                <!-- 已登录状态 -->
                <template v-if="isLoggedIn">
                    <!-- 聊天按钮 -->
                    <div class="action-button chat-button" @click="router.push('/chat')">
                        <el-badge :is-dot="showNotificationDot" class="chat-badge">
                            <el-icon class="action-icon">
                                <Promotion />
                            </el-icon>
                        </el-badge>
                        <span class="action-text">私聊</span>
                    </div>

                    <!-- 用户菜单 -->
                    <el-dropdown trigger="hover" @visible-change="closeMobileMenu">
                        <div class="user-avatar">
                            <el-avatar :size="32"
                                :src="userStore.userInfo.avatar || 'src/assets/images/default_avatar.png'" />
                            <span class="username">{{ userStore.userInfo.username }}</span>
                        </div>

                        <template #dropdown>
                            <el-dropdown-menu>
                                <el-dropdown-item v-for="item in userMenuItems" :key="item.path"
                                    @click="router.push(item.path)" :divided="item.divider">
                                    <el-icon>
                                        <component :is="item.icon" />
                                    </el-icon>{{ item.name }}
                                </el-dropdown-item>
                                <el-dropdown-item divided @click="showLogoutConfirm">
                                    <el-icon>
                                        <SwitchButton />
                                    </el-icon>
                                    <span>退出登录</span>
                                </el-dropdown-item>
                            </el-dropdown-menu>
                        </template>
                    </el-dropdown>
                </template>

                <!-- 未登录状态 -->
                <template v-else>
                    <div class="login-btns">
                        <el-button type="primary" size="small" @click="router.push('/login')"
                            class="login-btn">登录</el-button>
                        <el-button size="small" @click="router.push('/register')" class="register-btn">注册</el-button>
                    </div>
                </template>
            </div>
        </div>

        <!-- 独立的退出确认对话框 -->
        <el-dialog v-model="logoutVisible" title="退出登录" width="300px" center destroy-on-close
            :modal-append-to-body="false" :append-to-body="true" :show-close="false" :close-on-click-modal="true"
            class="logout-dialog">
            <hr />
            <div class="logout-confirm-content">
                <p>确定要退出登录吗？(´;ω;`)</p>
            </div>
            <template #footer>
                <div class="dialog-footer">
                    <el-button type="primary" plain @click="logoutVisible = false">取消</el-button>
                    <el-button type="danger" plain @click="logout">确定</el-button>
                </div>
            </template>
        </el-dialog>

        <!-- 遮罩层 -->
        <div class="menu-overlay" :class="{ 'active': mobileMenuOpen }" @click="closeMobileMenu"></div>
    </nav>
</template>

<style scoped lang="scss">
// 变量定义
$navbar-height: 64px;
$navbar-height-scrolled: 54px;
$primary-color: #27ba9b;
$primary-gradient: linear-gradient(90deg, #27ba9b, #4a7bbd);
$text-color: #333;
$text-light: #606266;
$background-light: rgba(255, 255, 224, 0.95);
$background-transparent: #fff;
$box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
$box-shadow-hover: 0 4px 20px rgba(0, 0, 0, 0.12);
$transition-time: 0.3s;
$border-radius: 8px;

// 导航栏主体
.app-navbar {
    position: sticky;
    top: 0;
    z-index: 100;
    width: 100%;
    height: $navbar-height;
    background: $background-transparent;
    backdrop-filter: blur(10px);
    box-shadow: $box-shadow;
    transition: all $transition-time ease;

    &.scrolled {
        height: $navbar-height-scrolled;
        box-shadow: $box-shadow-hover;
        background: $background-light;

        .container {
            height: $navbar-height-scrolled;
        }

        .logo-image {
            height: 36px;
        }

        .logo-text {
            font-size: 18px;
        }

        .kaomoji {
            font-size: 16px;
            color: #ffb6c1;
        }
    }

    .kaomoji {
        font-size: 18px;
        color: #d8bfd8;
        margin-left: 20px;
    }

    .container {
        max-width: 90%;
        height: $navbar-height;
        margin: 0 auto;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0;
        transition: height $transition-time ease;
    }
}

// LOGO区域
.logo-area {
    display: flex;
    align-items: center;
    margin-right: 20px;
    z-index: 10;
    position: relative;

    .logo-link {
        text-decoration: none;

        &:hover .logo-wrapper {
            transform: translateY(-2px);
        }

        &:active .logo-wrapper {
            transform: translateY(0);
        }
    }

    .logo-wrapper {
        display: flex;
        align-items: center;
        transition: transform 0.25s ease;
    }

    .logo-image {
        height: 42px;
        margin-right: 12px;
        transition: height $transition-time ease;
    }

    .logo-text {
        font-size: 20px;
        font-weight: 700;
        color: $primary-color;
        letter-spacing: 0.5px;
        transition: font-size $transition-time ease;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
    }
}

// 汉堡菜单按钮
.mobile-menu-toggle {
    display: none;
    cursor: pointer;
    margin-left: 15px;

    .hamburger {
        width: 24px;
        height: 20px;
        position: relative;
        display: flex;
        flex-direction: column;
        justify-content: space-between;

        span {
            display: block;
            width: 100%;
            height: 2px;
            background-color: $text-color;
            border-radius: 2px;
            transition: all 0.3s ease;
            transform-origin: left center;
        }

        &.active {
            span:nth-child(1) {
                transform: rotate(45deg);
            }

            span:nth-child(2) {
                opacity: 0;
                transform: scaleX(0);
            }

            span:nth-child(3) {
                transform: rotate(-45deg);
            }
        }
    }
}

// 导航菜单区域
.menu-area {
    flex: 1;
    display: flex;
    justify-content: center;

    .menu-list {
        display: flex;
        list-style: none;
        margin: 0 auto;
        padding: 0;
        transition: opacity 0.3s ease, transform 0.3s ease;

        li {
            margin: 0 6px;
            position: relative;

            &::after {
                content: '';
                position: absolute;
                bottom: -6px;
                left: 50%;
                width: 0;
                height: 3px;
                background-color: $primary-color;
                transform: translateX(-50%);
                transition: width 0.3s ease;
                border-radius: 3px;
                opacity: 0;
            }

            &:hover::after {
                width: 20px;
                opacity: 0.5;
            }
        }
    }
}

// 导航链接
.nav-link {
    display: block;
    padding: 8px 16px;
    text-decoration: none;
    color: $text-color;
    border-radius: $border-radius;
    transition: all 0.25s ease;
    position: relative;
    overflow: hidden;

    &::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba($primary-color, 0.08);
        transform: translateY(100%);
        transition: transform 0.3s ease;
        z-index: -1;
        border-radius: $border-radius;
    }

    &:hover {
        color: $primary-color;

        &::before {
            transform: translateY(0);
        }

        .nav-icon {
            transform: translateY(-2px);
            color: $primary-color;
        }
    }

    &.active {
        color: $primary-color;
        background-color: rgba($primary-color, 0.08);
        font-weight: 500;

        &::before {
            transform: translateY(0);
        }

        .nav-icon {
            color: $primary-color;
        }

        &+li::after {
            width: 0;
        }
    }

    .nav-link-content {
        display: flex;
        align-items: center;
        gap: 6px;
    }

    .nav-icon {
        font-size: 18px;
        transition: all 0.3s ease;
    }

    .nav-text {
        font-size: 15px;
        font-weight: 500;
        letter-spacing: 0.3px;
    }
}

// 右侧用户区域
.user-area {
    display: flex;
    align-items: center;
    margin-left: 20px;
    z-index: 10;

    .action-button {
        display: flex;
        align-items: center;
        padding: 6px 14px;
        margin-right: 16px;
        border-radius: $border-radius;
        background-color: rgba($primary-color, 0.08);
        cursor: pointer;
        transition: all 0.3s ease;

        &:hover {
            background-color: rgba($primary-color, 0.15);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);

            .action-icon {
                transform: scale(1.1);
            }
        }

        &:active {
            transform: translateY(0);
        }

        .action-icon {
            font-size: 18px;
            color: $primary-color;
            margin-right: 6px;
            transition: all 0.3s ease;
        }

        .action-text {
            font-size: 14px;
            font-weight: 500;
            color: $text-color;
        }

        .chat-badge {
            :deep(.el-badge__content) {
                background-color: #f56c6c;
            }
        }
    }

    .user-avatar {
        display: flex;
        align-items: center;
        cursor: pointer;
        padding: 6px 14px;
        border-radius: $border-radius;
        transition: all 0.3s ease;
        background-color: rgba($primary-color, 0.08);

        &:hover {
            background-color: rgba($primary-color, 0.15);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);
        }

        &:active {
            transform: translateY(0);
        }

        .username {
            margin: 0 8px;
            font-size: 14px;
            font-weight: 500;
            color: $text-color;
            max-width: 100px;
            white-space: nowrap;
            text-overflow: ellipsis;
        }
    }
}

// 登录按钮组
.login-btns {
    display: flex;
    gap: 12px;

    .el-button {
        border-radius: $border-radius;
        transition: all 0.3s ease;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
        padding: 8px 16px;
        font-weight: 500;
        letter-spacing: 0.5px;

        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
        }

        &:active {
            transform: translateY(0);
        }
    }

    .login-btn {
        background: $primary-gradient;
        border: none;

        &:hover {
            background: linear-gradient(90deg, darken(#27ba9b, 5%), darken(#4a7bbd, 5%));
        }
    }
}

// 自定义下拉菜单
:deep(.el-dropdown-menu__item) {
    display: flex;
    align-items: center;
    padding: 10px 18px;
    transition: all 0.2s ease;

    &:hover {
        background-color: rgba(0, 0, 0, 0.03);
    }

    .el-icon {
        margin-right: 10px;
        font-size: 16px;
        color: $primary-color;
    }
}

// 退出确认对话框
.logout-dialog {
    border-radius: 8px;
    overflow: hidden;

    /* 防止抖动 */
    position: fixed;

    :deep(.el-dialog__header) {
        margin: 0;
        padding: 15px 20px;
        background-color: #f5f7fa;
        border-bottom: 1px solid #ebeef5;
    }

    :deep(.el-dialog__headerbtn) {
        top: 15px;
    }

    :deep(.el-dialog__title) {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
    }

    :deep(.el-dialog__body) {
        padding: 20px;
    }

    :deep(.el-dialog__footer) {
        padding: 10px 20px 15px;
        border-top: 1px solid #ebeef5;
    }

    /* 添加动画以减少抖动感 */
    &.dialog-fade-enter-active,
    &.dialog-fade-leave-active {
        transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
    }

    &.dialog-fade-enter-from,
    &.dialog-fade-leave-to {
        opacity: 0;
        transform: scale(0.9);
    }
}

.logout-confirm-content {
    text-align: center;
    padding: 10px 0;

    p {
        margin: 0;
        font-size: 15px;
        color: #606266;
    }
}

.dialog-footer {
    display: flex;
    justify-content: space-around;
}

// 遮罩层
.menu-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    z-index: 5;
    visibility: hidden;
    opacity: 0;
    transition: all 0.3s ease;
    backdrop-filter: blur(3px);

    &.active {
        visibility: visible;
        opacity: 1;
    }
}

// 动画效果
.fade-slide-enter-active,
.fade-slide-leave-active {
    transition: all 0.3s ease;
}

.fade-slide-enter-from,
.fade-slide-leave-to {
    opacity: 0;
    transform: translateY(-10px);
}

// 响应式布局
@media (max-width: 991px) {
    .app-navbar .container {
        max-width: 95%;
    }

    .nav-link {
        padding: 8px 12px;
    }

    .logo-text {
        font-size: 18px;
    }

    .user-avatar .username {
        max-width: 80px;
    }
}

@media (max-width: 768px) {
    .mobile-menu-toggle {
        display: block;
    }

    .app-navbar {
        height: $navbar-height;

        &.scrolled {
            height: $navbar-height;

            .container {
                height: $navbar-height;
            }
        }

        .container {
            height: $navbar-height;
        }
    }

    .logo-area {
        flex: 1;
        justify-content: space-between;
    }

    .menu-area {
        position: fixed;
        top: $navbar-height;
        left: 0;
        width: 100%;
        height: 0;
        background-color: $background-light;
        overflow: hidden;
        transition: height 0.3s ease;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        z-index: 20;

        &.mobile-open {
            height: calc(100vh - #{$navbar-height});
            overflow-y: auto;
        }

        .menu-list {
            flex-direction: column;
            padding: 20px;
            width: 100%;

            li {
                margin: 0 0 10px;
                width: 100%;

                &::after {
                    display: none;
                }

                &:last-child {
                    margin-bottom: 0;
                }
            }
        }
    }

    .nav-link {
        padding: 12px 16px;
        border-radius: $border-radius;
        margin-bottom: 8px;

        .nav-link-content {
            justify-content: center;
        }

        .nav-icon {
            font-size: 20px;
        }

        .nav-text {
            font-size: 16px;
        }
    }

    .user-area {
        margin-left: auto;

        .chat-button {
            display: none;
        }
    }

    .login-btns {
        gap: 8px;

        .el-button {
            padding: 6px 12px;
            font-size: 13px;
        }
    }
}

@media (max-width: 576px) {
    .logo-text {
        display: none;
    }

    .logo-image {
        margin-right: 0;
    }

    .user-avatar {
        padding: 6px 10px;

        .username {
            display: none;
        }
    }
}
</style>