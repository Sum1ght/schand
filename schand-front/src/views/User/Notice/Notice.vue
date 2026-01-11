<script setup>
import { ref, reactive, computed, onMounted, watch, nextTick, onBeforeUnmount } from 'vue'
import { getAllNoticesAPI } from '@/api/noticeAPI'
import { Bell, Search, Filter, RefreshRight, Calendar, Loading, ArrowUp, ArrowDown, ArrowRight, ArrowLeft } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'

// 路由实例
const router = useRouter()

// 响应式状态
const state = reactive({
    loading: true, // 默认为加载状态，避免闪烁
    pageReady: false, // 控制整个页面的显示
    error: null,
    searchQuery: '',
    currentFilter: 'all',
    expandedNotice: null,
    categoryFilter: null,
    sortOrder: 'newest', // 'newest' 或 'oldest'
    isFilterPanelVisible: false,
    refreshing: false
})

// 公告数据
const noticeList = ref([])
// 搜索与筛选后的公告列表
const filteredNoticeList = computed(() => {
    let filtered = [...noticeList.value]

    // 搜索筛选
    if (state.searchQuery) {
        const query = state.searchQuery.toLowerCase()
        filtered = filtered.filter(notice =>
            notice.title.toLowerCase().includes(query) ||
            notice.content.toLowerCase().includes(query)
        )
    }

    // 分类筛选
    if (state.categoryFilter && state.categoryFilter !== 'all') {
        filtered = filtered.filter(notice => notice.category === state.categoryFilter)
    }

    // 排序
    filtered.sort((a, b) => {
        const dateA = new Date(a.time)
        const dateB = new Date(b.time)
        return state.sortOrder === 'newest' ? dateB - dateA : dateA - dateB
    })

    return filtered
})

// 提取公告分类
const noticeCategories = computed(() => {
    const categories = new Set(noticeList.value.map(item => item.category).filter(Boolean))
    return ['全部', ...categories]
})

// 获取公告最新修改时间
const lastUpdateTime = computed(() => {
    if (!noticeList.value.length) return null

    const dates = noticeList.value.map(notice => new Date(notice.time))
    const latestDate = new Date(Math.max(...dates))

    return latestDate.toLocaleString('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    })
})

// 监听路由进入事件
let removeRouterGuard = null
onMounted(() => {
    // 注册路由前置守卫，记录进入Notice页面的时间
    removeRouterGuard = router.beforeEach((to, from, next) => {
        // 如果路由包含Notice路径(当前组件路径)，预先设置loading状态
        if (to.path.includes('/notice') || to.name === 'Notice') {
            state.loading = true
            state.pageReady = false
        }
        next()
    })

    // 加载公告数据
    loadNotices()
})

// 组件卸载时移除路由守卫
onBeforeUnmount(() => {
    if (removeRouterGuard) {
        removeRouterGuard()
    }
})

// 加载公告数据
const loadNotices = async () => {
    state.loading = true
    state.error = null

    try {
        const res = await getAllNoticesAPI()

        if (res.code === '200') {
            // 为每条公告添加额外属性用于UI状态管理
            noticeList.value = (res.data || []).map(notice => ({
                ...notice,
                isExpanded: false,
                category: notice.category || '系统公告', // 默认分类
                isHighlighted: false
            }))
        } else {
            state.error = res.msg || '获取公告列表失败'
            ElMessage.error(state.error)
        }
    } catch (error) {
        console.error('获取公告列表失败:', error)
        state.error = '网络错误，请稍后再试'
        ElMessage.error(state.error)
    } finally {
        // 延迟结束加载状态，确保过渡平滑
        setTimeout(() => {
            state.loading = false
            // 页面内容准备就绪
            setTimeout(() => {
                state.pageReady = true
            }, 50)
        }, 300)
    }
}

// 刷新数据
const refreshNotices = async () => {
    if (state.refreshing) return

    state.refreshing = true
    await loadNotices()

    // 显示刷新成功动画
    setTimeout(() => {
        state.refreshing = false
    }, 600)
}

// 切换公告展开状态
const toggleNotice = (notice) => {
    showNoticeDetail(notice)
}

// 显示通知详情弹窗
const dialogVisible = ref(false)
const currentNotice = ref(null)
const currentIndex = ref(-1)

const showNoticeDetail = (notice) => {
    currentNotice.value = notice
    // 找到当前通知在过滤后列表中的索引
    currentIndex.value = filteredNoticeList.value.findIndex(item => item.id === notice.id)
    dialogVisible.value = true

    // 高亮显示效果
    notice.isHighlighted = true
    setTimeout(() => {
        notice.isHighlighted = false
    }, 500)
}

// 关闭通知详情弹窗
const closeNoticeDetail = () => {
    dialogVisible.value = false
    // 可以添加延迟清除内容，使关闭动画更自然
    setTimeout(() => {
        currentNotice.value = null
        currentIndex.value = -1
    }, 300)
}

// 查看上一条通知
const viewPreviousNotice = () => {
    if (currentIndex.value > 0) {
        currentIndex.value--
        currentNotice.value = filteredNoticeList.value[currentIndex.value]
    }
}

// 查看下一条通知
const viewNextNotice = () => {
    if (currentIndex.value < filteredNoticeList.value.length - 1) {
        currentIndex.value++
        currentNotice.value = filteredNoticeList.value[currentIndex.value]
    }
}

// 计算是否有上一条/下一条通知
const hasPrevious = computed(() => currentIndex.value > 0)
const hasNext = computed(() => currentIndex.value < filteredNoticeList.value.length - 1)

// 切换排序方式
const toggleSortOrder = () => {
    state.sortOrder = state.sortOrder === 'newest' ? 'oldest' : 'newest'
}

// 搜索处理
const handleSearch = () => {
    state.expandedNotice = null // 重置展开状态
}

// 清空搜索
const clearSearch = () => {
    state.searchQuery = ''
    state.expandedNotice = null
}

// 筛选处理
const filterByCategory = (category) => {
    state.categoryFilter = category === '全部' ? null : category
    state.expandedNotice = null // 重置展开状态
    state.isFilterPanelVisible = false // 关闭筛选面板
}

// 监听搜索输入，防抖处理
let searchTimeout
watch(() => state.searchQuery, () => {
    clearTimeout(searchTimeout)
    searchTimeout = setTimeout(() => {
        handleSearch()
    }, 300)
})
</script>

<template>
    <div class="notice-page" :class="{ 'page-ready': state.pageReady }">
        <!-- 容器开始 -->
        <div class="notice-container">
            <div class="notice-card">
                <!-- 头部区域 -->
                <div class="notice-header">
                    <div class="header-left">
                        <div class="title-icon">
                            <el-icon :size="24">
                                <Bell />
                            </el-icon>
                        </div>
                        <div class="title-content">
                            <h1 class="main-title">系统公告</h1>
                            <div class="subtitle" v-if="lastUpdateTime">
                                <el-icon>
                                    <Calendar />
                                </el-icon>
                                <span>最近更新：{{ lastUpdateTime }}</span>
                            </div>
                        </div>
                    </div>
                    <div class="header-right">
                        <el-tooltip content="刷新公告" placement="top">
                            <el-button :icon="RefreshRight" circle @click="refreshNotices" :loading="state.refreshing"
                                type="info" text />
                        </el-tooltip>
                    </div>
                </div>

                <!-- 工具栏 -->
                <div class="notice-toolbar">
                    <div class="search-box">
                        <el-input v-model="state.searchQuery" placeholder="搜索公告..." clearable @clear="clearSearch">
                            <template #prefix>
                                <el-icon>
                                    <Search />
                                </el-icon>
                            </template>
                        </el-input>
                    </div>

                    <div class="filter-actions">
                        <el-tooltip :content="`按${state.sortOrder === 'newest' ? '最早' : '最新'}排序`">
                            <el-button :icon="state.sortOrder === 'newest' ? ArrowDown : ArrowUp"
                                @click="toggleSortOrder" type="default" text />
                        </el-tooltip>

                        <el-popover placement="bottom-end" :width="200" trigger="click"
                            v-model:visible="state.isFilterPanelVisible">
                            <template #reference>
                                <el-button :icon="Filter" type="default" text />
                            </template>
                            <div class="filter-panel">
                                <div class="filter-title">按分类筛选</div>
                                <div class="filter-list">
                                    <div v-for="category in noticeCategories" :key="category"
                                        @click="filterByCategory(category)" class="filter-item"
                                        :class="{ 'active': category === '全部' ? !state.categoryFilter : category === state.categoryFilter }">
                                        {{ category }}
                                    </div>
                                </div>
                            </div>
                        </el-popover>
                    </div>
                </div>

                <!-- 公告列表区域 -->
                <div class="notice-content">
                    <div class="notice-list-container" :class="{ 'is-loading': state.loading }">
                        <!-- 加载状态 - 使用骨架屏 -->
                        <div v-if="state.loading" class="notice-loading">
                            <div class="skeleton-notice-item" v-for="i in 3" :key="i">
                                <div class="skeleton-header">
                                    <div class="skeleton-left">
                                        <div class="skeleton-badge"></div>
                                        <div class="skeleton-title"></div>
                                    </div>
                                    <div class="skeleton-time"></div>
                                </div>
                                <div class="skeleton-content" v-if="i === 1"></div>
                            </div>
                        </div>

                        <!-- 实际内容 -->
                        <transition-group name="notice-fade" tag="div" class="notice-list" v-else>
                            <!-- 空状态 -->
                            <div v-if="filteredNoticeList.length === 0" key="empty" class="notice-empty">
                                <el-empty description="暂无相关公告" :image-size="120">
                                    <template #description>
                                        <p>{{ state.searchQuery ? '没有找到匹配的公告' : '暂无系统公告' }}</p>
                                    </template>
                                    <el-button v-if="state.searchQuery" @click="clearSearch">清除搜索</el-button>
                                </el-empty>
                            </div>

                            <!-- 公告项 -->
                            <div v-for="notice in filteredNoticeList" :key="notice.id" class="notice-item" :class="{
                                'expanded': state.expandedNotice === notice.id,
                                'highlighted': notice.isHighlighted
                            }" @click="toggleNotice(notice)">
                                <div class="notice-item-header">
                                    <div class="notice-meta">
                                        <div class="notice-title-container">
                                            <span class="notice-badge"
                                                :class="`notice-badge-${notice.category === '系统公告' ? 'system' : 'normal'}`">{{
                                                    notice.category }}</span>
                                            <span class="notice-title">{{ notice.title }}</span>
                                        </div>
                                        <div class="notice-time">
                                            <el-icon>
                                                <Calendar />
                                            </el-icon>
                                            <time>{{ notice.time }}</time>
                                        </div>
                                    </div>
                                    <div class="notice-expand-icon">
                                        <el-icon>
                                            <arrow-right />
                                        </el-icon>
                                    </div>
                                </div>
                            </div>
                        </transition-group>
                    </div>
                </div>
            </div>
        </div>
        <!-- 容器结束 -->

        <!-- 通知详情弹窗 -->
        <el-dialog v-model="dialogVisible" :title="currentNotice?.title" width="700px"
            custom-class="notice-detail-dialog" top="5vh" destroy-on-close :close-on-click-modal="true"
            :show-close="true">
            <div class="notice-dialog-content" v-if="currentNotice">
                <div class="notice-dialog-header">
                    <div class="notice-dialog-meta">
                        <span class="notice-badge"
                            :class="`notice-badge-${currentNotice.category === '系统公告' ? 'system' : 'normal'}`">
                            {{ currentNotice.category }}
                        </span>
                        <span class="notice-time">
                            <el-icon>
                                <Calendar />
                            </el-icon>
                            <time>{{ currentNotice.time }}</time>
                        </span>
                    </div>
                </div>

                <el-divider />

                <div class="notice-dialog-body">
                    <div class="notice-html-content" v-html="currentNotice.content"></div>
                </div>

                <!-- 上一条/下一条导航 -->
                <div class="notice-navigation">
                    <el-button :disabled="!hasPrevious" @click="viewPreviousNotice" type="info" text
                        class="nav-button prev-button">
                        <el-icon><arrow-left /></el-icon> 上一条
                    </el-button>

                    <div class="navigation-indicator">
                        {{ currentIndex + 1 }}/{{ filteredNoticeList.length }}
                    </div>

                    <el-button :disabled="!hasNext" @click="viewNextNotice" type="info" text
                        class="nav-button next-button">
                        下一条 <el-icon><arrow-right /></el-icon>
                    </el-button>
                </div>
            </div>

            <template #footer>
                <div class="dialog-footer">
                    <el-button @click="closeNoticeDetail">关闭</el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
// 变量定义
$primary-color: #27ba9b;
$secondary-color: #2656b5;
$background-color: #f6f8fc;
$border-color: #ebeef5;
$text-primary: #303133;
$text-secondary: #606266;
$text-light: #909399;
$skeleton-color: #f2f2f2;
$skeleton-highlight: #e6e6e6;
$transition-time: 0.3s;
$card-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
$card-shadow-hover: 0 8px 24px rgba(0, 0, 0, 0.12);
$border-radius: 8px;
$spacing: 16px;

// 页面容器
.notice-page {
    width: 800px;
    max-width: 100%;
    margin: 0 auto;
    padding: 20px 16px;
    opacity: 0;
    transition: opacity 0.2s ease-in;
    min-height: calc(100vh - 120px);

    &.page-ready {
        opacity: 1;
    }
}

// 新增容器样式
.notice-container {
    display: flex;
    justify-content: center;
    padding: 20px 0;
}

// 新增卡片样式
.notice-card {
    width: 100%;
    background-color: white;
    border-radius: $border-radius;
    box-shadow: $card-shadow;
    padding: 30px;
    transition: all $transition-time;

    &:hover {
        box-shadow: $card-shadow-hover;
    }
}

// 头部区域
.notice-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;

    .header-left {
        display: flex;
        align-items: center;
        gap: 16px;

        .title-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: linear-gradient(135deg, lighten($primary-color, 40%), lighten($primary-color, 10%));
            color: white;
            box-shadow: 0 4px 12px rgba(39, 186, 155, 0.2);
        }

        .title-content {
            .main-title {
                font-size: 24px;
                font-weight: 600;
                color: $text-primary;
                margin: 0 0 4px;
            }

            .subtitle {
                font-size: 13px;
                color: $text-light;
                display: flex;
                align-items: center;
                gap: 4px;
            }
        }
    }
}

// 工具栏
.notice-toolbar {
    display: flex;
    margin-bottom: 20px;
    gap: 12px;

    .search-box {
        flex: 1;
    }

    .filter-actions {
        display: flex;
        gap: 8px;
    }
}

// 筛选面板
.filter-panel {
    padding: 8px 0;

    .filter-title {
        font-size: 14px;
        font-weight: 500;
        color: $text-primary;
        padding: 0 12px 8px;
        border-bottom: 1px solid $border-color;
        margin-bottom: 8px;
    }

    .filter-list {
        max-height: 200px;
        overflow-y: auto;

        .filter-item {
            padding: 8px 12px;
            cursor: pointer;
            font-size: 14px;
            color: $text-secondary;
            transition: all $transition-time;
            border-radius: 4px;
            margin: 0 4px;

            &:hover {
                background-color: #f5f7fa;
            }

            &.active {
                color: $primary-color;
                background-color: rgba(39, 186, 155, 0.1);
                font-weight: 500;
            }
        }
    }
}

// 公告内容区域
.notice-content {
    position: relative;
}

// 公告列表容器
.notice-list-container {
    background-color: white;
    border-radius: $border-radius;
    overflow: hidden;
    transition: box-shadow $transition-time, transform $transition-time;
    min-height: 280px;

    &.is-loading {
        transform: translateY(0);
    }
}

// 公告列表
.notice-list {
    min-height: 200px;
}

// 加载状态 - 自定义骨架屏
.notice-loading {
    padding: 16px;

    .skeleton-notice-item {
        padding: 16px;
        border-bottom: 1px solid $border-color;
        margin-bottom: 8px;
        animation: skeleton-pulse 1.5s ease-in-out infinite;

        &:last-child {
            border-bottom: none;
        }

        .skeleton-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;

            .skeleton-left {
                display: flex;
                align-items: center;
                gap: 8px;

                .skeleton-badge {
                    width: 60px;
                    height: 22px;
                    background-color: $skeleton-color;
                    border-radius: 4px;
                }

                .skeleton-title {
                    width: 220px;
                    height: 20px;
                    background-color: $skeleton-color;
                    border-radius: 4px;
                }
            }

            .skeleton-time {
                width: 100px;
                height: 16px;
                background-color: $skeleton-color;
                border-radius: 4px;
            }
        }

        .skeleton-content {
            width: 100%;
            height: 80px;
            background-color: $skeleton-color;
            border-radius: 4px;
            margin-top: 12px;
        }
    }
}

@keyframes skeleton-pulse {
    0% {
        opacity: 0.6;
    }

    50% {
        opacity: 0.8;
    }

    100% {
        opacity: 0.6;
    }
}

// 空状态
.notice-empty {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 40px 0;
    color: $text-light;
}

// 公告项
.notice-item {
    padding: 0;
    border-bottom: 1px solid $border-color;
    transition: all $transition-time;
    cursor: pointer;

    &:last-child {
        border-bottom: none;
    }

    &:hover {
        background-color: #f9fbfd;
    }

    &.expanded {
        background-color: #f9fbfd;
    }

    &.highlighted {
        animation: highlight 0.5s;
    }
}

// 公告项头部
.notice-item-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 20px;

    .notice-meta {
        flex: 1;

        .notice-title-container {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;

            .notice-title {
                font-size: 16px;
                font-weight: 500;
                color: $text-primary;
            }
        }

        .notice-time {
            font-size: 13px;
            color: $text-light;
            display: flex;
            align-items: center;
            gap: 4px;

            .el-icon {
                font-size: 14px;
            }
        }
    }

    .notice-expand-icon {
        margin-left: 16px;
        color: $text-light;
    }
}

// 公告类别标签
.notice-badge {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 2px 8px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 500;

    &.notice-badge-system {
        background-color: rgba($secondary-color, 0.1);
        color: $secondary-color;
    }

    &.notice-badge-normal {
        background-color: rgba($primary-color, 0.1);
        color: $primary-color;
    }
}

// 动画
@keyframes highlight {
    0% {
        background-color: rgba($primary-color, 0.15);
    }

    100% {
        background-color: #f9fbfd;
    }
}

// 列表项过渡动画
.notice-fade-enter-active,
.notice-fade-leave-active {
    transition: all 0.4s ease;
}

.notice-fade-enter-from,
.notice-fade-leave-to {
    opacity: 0;
    transform: translateY(20px);
}

.notice-fade-move {
    transition: transform 0.4s ease;
}

// 通知详情弹窗样式
:deep(.notice-detail-dialog) {
    border-radius: 12px;
    overflow: hidden;

    .el-dialog__header {
        padding: 20px 24px;
        border-bottom: 1px solid #ebeef5;
        margin-right: 0;
        background-color: #f8fafd;

        .el-dialog__title {
            font-size: 18px;
            font-weight: 600;
            color: $text-primary;
        }
    }

    .el-dialog__body {
        padding: 24px;
    }

    .el-dialog__footer {
        padding: 16px 24px;
        border-top: 1px solid #ebeef5;
        background-color: #f8fafd;
    }
}

.notice-dialog-content {
    .notice-dialog-header {
        margin-bottom: 12px;

        .notice-dialog-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;

            .notice-time {
                font-size: 14px;
                color: $text-light;
                display: flex;
                align-items: center;
                gap: 6px;
            }
        }
    }

    .notice-dialog-body {
        margin-top: 16px;
        max-height: 60vh;
        overflow-y: auto;

        &::-webkit-scrollbar {
            width: 6px;
            height: 6px;
        }

        &::-webkit-scrollbar-thumb {
            background-color: rgba(0, 0, 0, 0.2);
            border-radius: 3px;
        }

        &::-webkit-scrollbar-track {
            background-color: transparent;
        }

        .notice-html-content {
            line-height: 1.8;
            color: $text-secondary;
            font-size: 15px;

            :deep(p) {
                margin: 14px 0;
            }

            :deep(img) {
                max-width: 100%;
                border-radius: 6px;
                box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                margin: 16px 0;
            }

            :deep(h1),
            :deep(h2),
            :deep(h3) {
                margin-top: 24px;
                margin-bottom: 16px;
                color: $text-primary;
                font-weight: 600;
            }

            :deep(a) {
                color: $primary-color;
                text-decoration: none;
                transition: all 0.2s;

                &:hover {
                    color: darken($primary-color, 10%);
                    text-decoration: underline;
                }
            }

            :deep(ul),
            :deep(ol) {
                padding-left: 24px;
                margin: 16px 0;
            }

            :deep(pre),
            :deep(code) {
                background-color: #f5f7fa;
                border-radius: 4px;
                padding: 2px 6px;
                font-family: monospace;
                font-size: 14px;
            }

            :deep(pre) {
                padding: 16px;
                overflow-x: auto;

                code {
                    background: none;
                    padding: 0;
                }
            }

            :deep(blockquote) {
                border-left: 4px solid $primary-color;
                padding: 12px 24px;
                margin: 16px 0;
                background-color: rgba($primary-color, 0.05);
                border-radius: 0 4px 4px 0;
                color: $text-secondary;
                font-style: italic;
            }

            :deep(table) {
                width: 100%;
                border-collapse: collapse;
                margin: 16px 0;

                th,
                td {
                    border: 1px solid #ebeef5;
                    padding: 10px 12px;
                    text-align: left;
                }

                th {
                    background-color: #f8fafd;
                    font-weight: 600;
                    color: $text-primary;
                }

                tr:nth-child(even) {
                    background-color: #f9fbfd;
                }
            }
        }
    }

    .notice-navigation {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 24px;
        padding-top: 16px;
        border-top: 1px dashed #ebeef5;

        .nav-button {
            display: flex;
            align-items: center;
            gap: 4px;
            transition: all 0.2s;

            &:not(:disabled):hover {
                color: $primary-color;
                transform: translateY(-2px);
            }

            &.prev-button {
                padding-left: 0;
            }

            &.next-button {
                padding-right: 0;
            }
        }

        .navigation-indicator {
            font-size: 14px;
            color: $text-light;
            background-color: #f5f7fa;
            padding: 4px 10px;
            border-radius: 12px;
        }
    }
}

.dialog-footer {
    display: flex;
    justify-content: flex-end;
}

// 弹窗内容过渡动画
:deep(.el-dialog__body) {
    overflow: hidden;
}

.notice-html-content {
    animation: fade-in 0.3s ease-in-out;
}

@keyframes fade-in {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

// 响应式设计
@media (max-width: 992px) {
    .notice-page {
        width: 100%;
    }

    .notice-header {
        .header-left {
            .title-icon {
                width: 42px;
                height: 42px;
            }

            .title-content {
                .main-title {
                    font-size: 22px;
                }
            }
        }
    }
}

@media (max-width: 768px) {
    .notice-card {
        padding: 20px;
    }

    .notice-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;

        .header-right {
            align-self: flex-end;
        }
    }

    .notice-toolbar {
        flex-direction: column;
        gap: 12px;

        .filter-actions {
            justify-content: flex-end;
        }
    }

    .notice-item-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;

        .notice-expand-icon {
            align-self: flex-end;
            margin: 0;
        }
    }

    // 弹窗响应式
    :deep(.notice-detail-dialog) {
        width: 90% !important;
        margin: 0 auto;

        .el-dialog__header {
            padding: 16px;

            .el-dialog__title {
                font-size: 16px;
            }
        }

        .el-dialog__body {
            padding: 16px;
        }

        .el-dialog__footer {
            padding: 12px 16px;
        }
    }

    .notice-dialog-content {
        .notice-dialog-header {
            .notice-dialog-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }
        }

        .notice-navigation {
            flex-wrap: wrap;
            gap: 10px;

            .navigation-indicator {
                order: -1;
                width: 100%;
                text-align: center;
                margin-bottom: 8px;
            }
        }
    }
}

@media (max-width: 480px) {
    .notice-page {
        padding: 16px 12px;
    }

    .notice-card {
        padding: 16px;
    }

    .notice-item-header {
        padding: 14px 16px;
    }

    .notice-item-content {
        padding: 0 16px 16px;
    }

    // 弹窗进一步适配
    :deep(.notice-detail-dialog) {
        width: 95% !important;

        .el-dialog__body {
            padding: 12px;
        }
    }

    .notice-dialog-content {
        .notice-dialog-body {
            max-height: 50vh;
        }
    }
}
</style>