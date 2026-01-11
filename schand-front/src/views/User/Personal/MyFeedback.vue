<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/userStore'
import { getFeedbackPageAPI, deleteFeedbackAPI, deleteBatchFeedbackAPI } from '@/api/feedbackAPI'
import { Search, Delete, RefreshRight, CircleCheck, Timer, Message, Calendar } from '@element-plus/icons-vue'

// 路由实例
const router = useRouter()

// 用户store
const userStore = useUserStore()

// 页面状态
const pageState = reactive({
    loading: false,
    pageNum: 1,
    pageSize: 10,
    total: 0,
    tableData: [],
    ids: [],
    title: null
})

// 当前用户信息
const user = computed(() => userStore.userInfo)

// 加载反馈数据
const loadFeedbacks = async (page) => {
    if (page) pageState.pageNum = page
    pageState.loading = true

    try {
        const params = {
            pageNum: pageState.pageNum,
            pageSize: pageState.pageSize,
            title: pageState.title || undefined
        }

        const res = await getFeedbackPageAPI(params)

        if (res.code === '200') {
            pageState.tableData = res.data?.list || []
            pageState.total = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '加载反馈数据失败')
        }
    } catch (error) {
        console.error('加载反馈数据失败:', error)
        ElMessage.error('加载反馈数据失败')
    } finally {
        pageState.loading = false
    }
}

// 重置查询参数
const resetQuery = () => {
    pageState.title = null
    loadFeedbacks(1)
}

// 单个反馈选择
const handleItemSelect = (checked, item) => {
    if (checked) {
        if (!pageState.ids.includes(item.id)) {
            pageState.ids.push(item.id)
        }
    } else {
        const index = pageState.ids.indexOf(item.id)
        if (index > -1) {
            pageState.ids.splice(index, 1)
        }
    }
}

// 删除单条反馈
const deleteFeedback = (id) => {
    ElMessageBox.confirm(
        '确定要删除这条反馈记录吗？此操作不可恢复！',
        '删除确认',
        {
            confirmButtonText: '确定删除',
            cancelButtonText: '取消',
            type: 'warning',
            confirmButtonClass: 'el-button--danger'
        }
    ).then(async () => {
        try {
            const res = await deleteFeedbackAPI(id)

            if (res.code === '200') {
                ElMessage.success('删除成功')
                loadFeedbacks(pageState.pageNum)
            } else {
                ElMessage.error(res.msg || '删除失败')
            }
        } catch (error) {
            console.error('删除反馈失败:', error)
            ElMessage.error('删除反馈失败')
        }
    }).catch(() => { })
}

// 批量删除反馈
const batchDeleteFeedback = () => {
    if (!pageState.ids.length) {
        ElMessage.warning('请先选择要删除的反馈')
        return
    }

    ElMessageBox.confirm(
        `确定要删除选中的 ${pageState.ids.length} 条反馈记录吗？此操作不可恢复！`,
        '批量删除确认',
        {
            confirmButtonText: '确定删除',
            cancelButtonText: '取消',
            type: 'warning',
            confirmButtonClass: 'el-button--danger'
        }
    ).then(async () => {
        try {
            const res = await deleteBatchFeedbackAPI(pageState.ids)

            if (res.code === '200') {
                ElMessage.success('批量删除成功')
                loadFeedbacks(1)
                pageState.ids = []
            } else {
                ElMessage.error(res.msg || '批量删除失败')
            }
        } catch (error) {
            console.error('批量删除反馈失败:', error)
            ElMessage.error('批量删除反馈失败')
        }
    }).catch(() => { })
}

// 处理表格选择变化
const handleSelectionChange = (rows) => {
    pageState.ids = rows.map(row => row.id)
}

// 处理分页变化
const handleCurrentChange = (page) => {
    loadFeedbacks(page)
}

// 格式化日期
const formatDate = (dateString) => {
    if (!dateString) return ''
    const date = new Date(dateString)
    return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    })
}

// 获取状态标签类型
const getStatusType = (reply) => {
    return reply ? 'success' : 'warning'
}

// 获取状态文本
const getStatusText = (reply) => {
    return reply ? '已回复' : '待处理'
}

// 生命周期钩子
onMounted(() => {
    loadFeedbacks(1)
})
</script>

<template>
    <div class="my-feedback-container">
        <!-- 顶部卡片 -->
        <div class="feedback-header-card">
            <div class="feedback-title">
                <span class="title-icon"><el-icon>
                        <Message />
                    </el-icon></span>
                <h2>我的反馈</h2>
            </div>

            <!-- 搜索区域 -->
            <div class="search-container">
                <div class="search-inputs">
                    <div class="search-input-item">
                        <el-input v-model="pageState.title" placeholder="请输入关键字查询" clearable
                            @keyup.enter="loadFeedbacks(1)">
                            <template #prefix><el-icon>
                                    <Search />
                                </el-icon></template>
                        </el-input>
                    </div>
                </div>

                <div class="search-buttons">
                    <el-button type="primary" @click="loadFeedbacks(1)" :loading="pageState.loading">
                        <el-icon>
                            <Search />
                        </el-icon><span>查询</span>
                    </el-button>
                    <el-button @click="resetQuery" :disabled="pageState.loading">
                        <el-icon>
                            <RefreshRight />
                        </el-icon><span>重置</span>
                    </el-button>
                    <el-button type="danger" :disabled="!pageState.ids.length" @click="batchDeleteFeedback">
                        <el-icon>
                            <Delete />
                        </el-icon><span>批量删除</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 反馈内容区域 -->
        <div class="feedback-content">
            <div class="feedback-container">
                <!-- 反馈卡片列表 -->
                <transition-group name="fade" tag="div" class="feedback-card-list">
                    <!-- 空状态 -->
                    <div v-if="pageState.tableData.length === 0 && !pageState.loading" class="empty-state" key="empty">
                        <el-empty description="暂无反馈记录">
                            <template #image>
                                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
                            </template>
                        </el-empty>
                    </div>

                    <!-- 反馈卡片 -->
                    <div v-for="item in pageState.tableData" :key="item.id" class="feedback-card">
                        <!-- 复选框 -->
                        <div class="card-checkbox">
                            <el-checkbox @change="(val) => handleItemSelect(val, item)"
                                :checked="pageState.ids.includes(item.id)" />
                        </div>

                        <!-- 卡片头部 -->
                        <div class="feedback-card-header">
                            <div class="feedback-info">
                                <div class="feedback-id">
                                    <span class="label">反馈ID:</span>
                                    <span class="value">{{ item.id }}</span>
                                </div>
                                <div class="feedback-date">
                                    <el-icon>
                                        <Calendar />
                                    </el-icon>
                                    <span>{{ formatDate(item.createtime) }}</span>
                                </div>
                            </div>
                            <div class="feedback-status">
                                <el-tag :type="getStatusType(item.reply)" effect="light">
                                    <el-icon>
                                        <component :is="item.reply ? CircleCheck : Timer" />
                                    </el-icon>
                                    <span>{{ getStatusText(item.reply) }}</span>
                                </el-tag>
                            </div>
                        </div>

                        <!-- 卡片内容 -->
                        <div class="feedback-card-content">
                            <div class="feedback-main">
                                <div class="feedback-title-text">{{ item.title }}</div>
                                <div class="feedback-content-text">{{ item.content }}</div>

                                <div class="feedback-contact">
                                    <div class="contact-item" v-if="item.phone">
                                        <span class="label">联系电话:</span>
                                        <span class="value">{{ item.phone }}</span>
                                    </div>
                                    <div class="contact-item" v-if="item.email">
                                        <span class="label">联系邮箱:</span>
                                        <span class="value">{{ item.email }}</span>
                                    </div>
                                </div>

                                <div class="feedback-reply" v-if="item.reply">
                                    <div class="reply-title">回复内容:</div>
                                    <div class="reply-content">{{ item.reply }}</div>
                                </div>
                            </div>
                        </div>

                        <!-- 卡片底部 -->
                        <div class="feedback-card-footer">
                            <div class="feedback-actions">
                                <el-button type="danger" @click="deleteFeedback(item.id)" class="action-button">
                                    <el-icon>
                                        <Delete />
                                    </el-icon>
                                    删除
                                </el-button>
                            </div>
                        </div>
                    </div>
                </transition-group>

                <!-- 加载中状态 -->
                <div v-if="pageState.loading" class="loading-container">
                    <el-skeleton :rows="3" animated />
                    <el-skeleton style="margin-top: 20px" :rows="3" animated />
                </div>

                <!-- 分页 -->
                <div class="pagination-container" v-if="pageState.total > 0">
                    <el-pagination background @current-change="handleCurrentChange" :current-page="pageState.pageNum"
                        :page-size="pageState.pageSize" layout="total, prev, pager, next, jumper"
                        :total="pageState.total" />
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// 主容器样式
.my-feedback-container {
    padding: 20px;
    min-height: calc(100vh - 120px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    // 顶部卡片样式
    .feedback-header-card {
        max-width: 1000px;
        margin: 0 auto 20px;
        background-color: var(--el-bg-color, #fff);
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        padding: 24px;

        .feedback-title {
            display: flex;
            align-items: center;
            margin-bottom: 24px;

            .title-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 44px;
                height: 44px;
                border-radius: 12px;
                background: var(--el-color-primary-light-8);
                margin-right: 12px;

                .el-icon {
                    font-size: 24px;
                    color: var(--el-color-primary);
                }
            }

            h2 {
                font-size: 22px;
                font-weight: 600;
                color: var(--el-text-color-primary);
                margin: 0;
            }
        }

        // 搜索区域
        .search-container {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;

            .search-inputs {
                flex: 1;
                display: flex;
                flex-wrap: wrap;
                gap: 12px;

                .search-input-item {
                    min-width: 300px;
                    flex: 1;

                    :deep(.el-input__wrapper) {
                        border-radius: 8px;
                    }
                }
            }

            .search-buttons {
                display: flex;
                gap: 12px;
                flex-wrap: wrap;

                .el-button {
                    border-radius: 8px;
                    transition: all 0.3s ease;

                    &:hover {
                        transform: translateY(-2px);
                    }

                    .el-icon {
                        margin-right: 6px;
                    }
                }
            }
        }
    }

    // 反馈内容区域
    .feedback-content {
        position: relative;
        min-height: 300px;

        // 反馈容器
        .feedback-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 24px;

            // 反馈卡片列表
            .feedback-card-list {
                display: flex;
                flex-direction: column;
                gap: 16px;

                // 空状态
                .empty-state {
                    display: flex;
                    justify-content: center;
                    padding: 50px 0;

                    :deep(.el-empty__image) {
                        width: 200px;
                        height: 200px;
                    }

                    :deep(.el-empty__description) {
                        font-size: 16px;
                        color: var(--el-text-color-secondary);
                    }
                }

                // 反馈卡片
                .feedback-card {
                    position: relative;
                    background: var(--el-bg-color, #fff);
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
                    overflow: hidden;
                    transition: all 0.3s ease;

                    &:hover {
                        transform: translateY(-3px);
                        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
                    }

                    // 复选框
                    .card-checkbox {
                        position: absolute;
                        top: 10px;
                        left: 10px;
                        z-index: 2;
                    }

                    // 卡片头部
                    .feedback-card-header {
                        padding: 16px 20px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        border-bottom: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color-page, #f5f7fa);

                        .feedback-info {
                            display: flex;
                            align-items: center;
                            flex-wrap: wrap;
                            gap: 16px;
                            margin-left: 24px; // 为复选框留出空间

                            .feedback-id {
                                display: flex;
                                align-items: center;

                                .label {
                                    color: var(--el-text-color-secondary);
                                    margin-right: 6px;
                                }

                                .value {
                                    font-weight: 500;
                                    color: var(--el-text-color-primary);
                                }
                            }

                            .feedback-date {
                                display: flex;
                                align-items: center;
                                color: var(--el-text-color-secondary);

                                .el-icon {
                                    margin-right: 6px;
                                }
                            }
                        }

                        .feedback-status {
                            display: flex;
                            align-items: center;

                            :deep(.el-tag) {
                                padding: 6px 10px;
                                border-radius: 6px;
                                display: flex;
                                align-items: center;
                                gap: 6px;

                                .el-icon {
                                    font-size: 16px;
                                }
                            }
                        }
                    }

                    // 卡片内容
                    .feedback-card-content {
                        padding: 16px 20px;

                        .feedback-main {
                            display: flex;
                            flex-direction: column;
                            gap: 12px;

                            .feedback-title-text {
                                font-size: 16px;
                                font-weight: 600;
                                color: var(--el-text-color-primary);
                            }

                            .feedback-content-text {
                                color: var(--el-text-color-regular);
                                line-height: 1.6;
                                word-break: break-word;
                            }

                            .feedback-contact {
                                display: flex;
                                flex-wrap: wrap;
                                gap: 16px;
                                margin-top: 8px;

                                .contact-item {
                                    display: flex;
                                    align-items: center;

                                    .label {
                                        color: var(--el-text-color-secondary);
                                        margin-right: 8px;
                                    }

                                    .value {
                                        color: var(--el-text-color-primary);
                                    }
                                }
                            }

                            .feedback-reply {
                                margin-top: 10px;
                                padding: 12px;
                                background-color: var(--el-fill-color-light);
                                border-radius: 8px;

                                .reply-title {
                                    font-weight: 500;
                                    color: var(--el-color-success);
                                    margin-bottom: 8px;
                                }

                                .reply-content {
                                    line-height: 1.6;
                                    color: var(--el-text-color-primary);
                                }
                            }
                        }
                    }

                    // 卡片底部
                    .feedback-card-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color, #fff);

                        .feedback-actions {
                            display: flex;
                            justify-content: flex-end;
                            flex-wrap: wrap;
                            gap: 12px;

                            .action-button {
                                border-radius: 8px;
                                transition: all 0.3s ease;

                                &:hover {
                                    transform: translateY(-2px);
                                }

                                .el-icon {
                                    margin-right: 4px;
                                }
                            }
                        }
                    }
                }
            }

            // 加载中状态
            .loading-container {
                padding: 20px;
                background: var(--el-fill-color-light);
                border-radius: 12px;
                margin-bottom: 16px;
            }

            // 分页
            .pagination-container {
                margin-top: 24px;
                display: flex;
                justify-content: center;
            }
        }
    }
}

// 过渡动画
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

// 响应式布局
@media (max-width: 768px) {
    .my-feedback-container {
        padding: 12px;

        .feedback-header-card {
            padding: 16px;

            .search-container {
                flex-direction: column;

                .search-inputs {
                    flex-direction: column;

                    .search-input-item {
                        width: 100%;
                    }
                }

                .search-buttons {
                    width: 100%;
                    justify-content: space-between;
                }
            }
        }

        .feedback-content {
            .feedback-container {
                padding: 16px;

                .feedback-card {
                    .feedback-card-header {
                        flex-direction: column;
                        align-items: flex-start;
                        gap: 12px;

                        .feedback-status {
                            margin-left: 24px;
                        }
                    }

                    .feedback-card-content {
                        padding-top: 20px;
                    }

                    .feedback-card-footer {
                        .feedback-actions {
                            justify-content: center;
                        }
                    }
                }
            }
        }
    }
}
</style>