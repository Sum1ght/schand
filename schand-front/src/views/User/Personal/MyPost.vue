<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search, Delete, Plus, View, Picture, Edit, Document, Calendar, CircleCheck, CircleClose, Warning, Postcard } from '@element-plus/icons-vue'

import { useRouter } from 'vue-router'
import {
    getPostsPageAPI,
    deletePostsAPI,
    deleteBatchPostsAPI
} from '@/api/postAPI'
import { useUserStore } from '@/stores/userStore'

// 路由实例
const router = useRouter()

// 响应式数据
const tableData = ref([])  // 所有的数据
const pagination = reactive({
    pageNum: 1,   // 当前的页码
    pageSize: 10,  // 每页显示的个数
    total: 0,
})
const title = ref(null)
const userStore = useUserStore()
const ids = ref([])
const loading = ref(false)

// 加载帖子数据
const load = async (pageNum) => {
    try {
        loading.value = true
        if (pageNum) pagination.pageNum = pageNum

        const res = await getPostsPageAPI({
            pageNum: pagination.pageNum,
            pageSize: pagination.pageSize,
            title: title.value,
        })

        if (res.code === '200') {
            tableData.value = res.data?.list || []
            pagination.total = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '获取数据失败')
        }
    } catch (error) {
        console.error('加载数据失败:', error)
        ElMessage.error('加载数据失败')
    } finally {
        loading.value = false
    }
}

// 编辑数据
const handleEdit = (row) => {
    router.push('/post/create?id=' + row.id)
}

// 查看帖子详情
const viewPostDetail = (item) => {
    console.log(item)
    if (item.status === '待审核') {
        ElMessage.warning('该帖子正在审核中，暂时无法查看详情')
        return
    }
    if (item.status === '拒绝') {
        ElMessage.warning('该帖子审核未通过，请修改后重新提交')
        return
    }

    // 跳转到帖子详情页
    router.push('/post/detail/' + item.id)
}

// 删除数据
const del = async (id) => {
    try {
        const result = await ElMessageBox.confirm(
            '您确定删除吗？',
            '确认删除',
            { type: 'warning', confirmButtonText: '确定', cancelButtonText: '取消' }
        )

        if (result === 'confirm') {
            const res = await deletePostsAPI(id)

            if (res.code === '200') {
                ElMessage.success('删除成功')
                load(1)
            } else {
                ElMessage.error(res.msg || '删除失败')
            }
        }
    } catch (error) {
        // 用户取消操作，不做处理
        console.log('用户取消操作')
    }
}

// 选择变化
const handleSelectionChange = (rows) => {
    ids.value = rows.map(v => v.id)
}

// 单选帖子
const handleItemSelect = (checked, item) => {
    if (checked) {
        if (!ids.value.includes(item.id)) {
            ids.value.push(item.id)
        }
    } else {
        const index = ids.value.indexOf(item.id)
        if (index > -1) {
            ids.value.splice(index, 1)
        }
    }
}

// 批量删除
const delBatch = async () => {
    if (!ids.value.length) {
        ElMessage.warning('请选择数据')
        return
    }

    try {
        const result = await ElMessageBox.confirm(
            '您确定批量删除这些数据吗？',
            '确认删除',
            { type: 'warning', confirmButtonText: '确定', cancelButtonText: '取消' }
        )

        if (result === 'confirm') {
            const res = await deleteBatchPostsAPI(ids.value)

            if (res.code === '200') {
                ElMessage.success('批量删除成功')
                load(1)
            } else {
                ElMessage.error(res.msg || '批量删除失败')
            }
        }
    } catch (error) {
        // 用户取消操作，不做处理
        console.log('用户取消操作')
    }
}

// 重置搜索
const reset = () => {
    title.value = null
    load(1)
}

// 分页变化
const handleCurrentChange = (pageNum) => {
    load(pageNum)
}

// 生命周期钩子
onMounted(() => {
    load(1)
})
</script>

<template>
    <div class="my-post-container">
        <!-- 顶部卡片 -->
        <div class="post-header-card">
            <div class="post-title">
                <span class="title-icon"><el-icon>
                        <Postcard />
                    </el-icon></span>
                <h2>我的帖子</h2>
            </div>

            <!-- 搜索区域 -->
            <div class="search-container">
                <div class="search-inputs">
                    <div class="search-input-item">
                        <el-input v-model="title" placeholder="搜索帖子标题" clearable @keyup.enter="load(1)">
                            <template #prefix><el-icon>
                                    <Search />
                                </el-icon></template>
                        </el-input>
                    </div>
                </div>

                <div class="search-buttons">
                    <el-button type="primary" @click="load(1)" :loading="loading">
                        <el-icon>
                            <Search />
                        </el-icon><span>查询</span>
                    </el-button>
                    <el-button @click="reset" :disabled="loading">
                        <el-icon>
                            <View />
                        </el-icon><span>重置</span>
                    </el-button>
                    <el-button type="success" @click="router.push('/post/create')">
                        <el-icon>
                            <Plus />
                        </el-icon><span>发布帖子</span>
                    </el-button>
                    <el-button type="danger" :disabled="!ids.length" @click="delBatch">
                        <el-icon>
                            <Delete />
                        </el-icon><span>批量删除</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 帖子内容区域 -->
        <div class="post-content">
            <div class="post-container">
                <!-- 帖子卡片列表 -->
                <transition-group name="fade" tag="div" class="post-card-list">
                    <!-- 空状态 -->
                    <div v-if="tableData.length === 0 && !loading" class="empty-state" key="empty">
                        <el-empty description="暂无帖子数据">
                            <template #image>
                                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
                            </template>
                        </el-empty>
                    </div>

                    <!-- 帖子卡片 -->
                    <div v-for="item in tableData" :key="item.id" class="post-card">
                        <!-- 复选框 -->
                        <div class="card-checkbox">
                            <el-checkbox @change="(val) => handleItemSelect(val, item)"
                                :checked="ids.includes(item.id)" />
                        </div>

                        <!-- 卡片头部 -->
                        <div class="post-card-header">
                            <div class="post-info">
                                <div class="post-id">
                                    <span class="label">帖子ID:</span>
                                    <span class="value">{{ item.id }}</span>
                                </div>
                                <div class="post-date">
                                    <el-icon>
                                        <Calendar />
                                    </el-icon>
                                    <span>{{ item.time }}</span>
                                </div>
                            </div>
                            <div class="post-status">
                                <el-tag :type="{
                                    '待审核': 'info',
                                    '通过': 'success',
                                    '拒绝': 'danger'
                                }[item.status]" effect="light">
                                    <div class="tag-content">
                                        <el-icon class="tag-icon">
                                            <component :is="{
                                                '待审核': Warning,
                                                '通过': CircleCheck,
                                                '拒绝': CircleClose
                                            }[item.status]" />
                                        </el-icon>
                                        <span class="tag-text">{{ item.status }}</span>
                                    </div>
                                </el-tag>
                                <el-tag size="small" style="margin-left: 8px;" effect="plain">{{ item.circle }}</el-tag>
                            </div>
                        </div>

                        <!-- 卡片内容 -->
                        <div class="post-card-content">
                            <div class="post-image-container">
                                <el-image
                                    :src="item.img || 'https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png'"
                                    fit="cover" :preview-src-list="item.img ? [item.img] : []" class="post-image" lazy>
                                    <template #error>
                                        <div class="image-error"><el-icon>
                                                <Picture />
                                            </el-icon></div>
                                    </template>
                                </el-image>
                            </div>

                            <div class="post-info">
                                <div class="post-name">{{ item.title }}</div>
                                <div class="post-meta">
                                    <div class="meta-item view-count">
                                        <el-icon>
                                            <View />
                                        </el-icon>
                                        <span>{{ item.readCount || 0 }} 浏览</span>
                                    </div>
                                    <div class="meta-item">
                                        <span class="label">简介:</span>
                                        <span class="value">{{ item.descr }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 卡片底部 -->
                        <div class="post-card-footer">
                            <div class="post-actions">
                                <el-button type="primary" plain @click="viewPostDetail(item)" class="action-button">
                                    <el-icon>
                                        <Document />
                                    </el-icon>
                                    查看详情
                                </el-button>
                                <el-button type="primary" @click="handleEdit(item)"
                                    class="action-button">
                                    <el-icon>
                                        <Edit />
                                    </el-icon>
                                    编辑
                                </el-button>
                                <el-button type="danger" @click="del(item.id)" class="action-button">
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
                <div v-if="loading" class="loading-container">
                    <el-skeleton :rows="3" animated />
                    <el-skeleton style="margin-top: 20px" :rows="3" animated />
                </div>

                <!-- 分页 -->
                <div class="pagination-container" v-if="pagination.total > 0">
                    <el-pagination background @current-change="handleCurrentChange" :current-page="pagination.pageNum"
                        :page-size="pagination.pageSize" layout="total, prev, pager, next, jumper"
                        :total="pagination.total" />
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// 主容器样式
.my-post-container {
    padding: 20px;
    min-height: calc(100vh - 120px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    // 顶部卡片样式
    .post-header-card {
        max-width: 1000px;
        margin: 0 auto 20px;
        background-color: var(--el-bg-color, #fff);
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        padding: 24px;

        .post-title {
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

    // 内容区域
    .post-content {
        position: relative;
        min-height: 300px;

        // 帖子容器
        .post-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 24px;

            // 帖子卡片列表
            .post-card-list {
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

                // 帖子卡片
                .post-card {
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
                    .post-card-header {
                        padding: 16px 20px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        border-bottom: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color-page, #f5f7fa);

                        .post-info {
                            display: flex;
                            align-items: center;
                            flex-wrap: wrap;
                            gap: 16px;
                            margin-left: 24px; // 为复选框留出空间

                            .post-id {
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

                            .post-date {
                                display: flex;
                                align-items: center;
                                color: var(--el-text-color-secondary);

                                .el-icon {
                                    margin-right: 6px;
                                }
                            }
                        }

                        .post-status {
                            display: flex;
                            align-items: center;
                            gap: 8px;

                            .status-tag-wrapper {
                                :deep(.el-tag) {
                                    padding: 6px 10px;
                                    border-radius: 6px;

                                    .tag-content {
                                        display: flex;
                                        align-items: center;
                                        gap: 6px;

                                        .tag-icon {
                                            display: flex;
                                            align-items: center;
                                            justify-content: center;
                                            font-size: 16px;
                                        }

                                        .tag-text {
                                            display: inline-block;
                                            line-height: 1;
                                        }
                                    }
                                }
                            }

                            :deep(.el-tag) {
                                padding: 6px 10px;
                                border-radius: 6px;
                                display: flex;
                                align-items: center;
                                gap: 6px;

                                .tag-content {
                                    display: flex;
                                    align-items: center;
                                    gap: 6px;
                                }

                                .tag-icon {
                                    display: flex !important;
                                    align-items: center !important;
                                    justify-content: center !important;
                                    font-size: 16px !important;
                                    position: relative !important;
                                    top: 0 !important;
                                }

                                .tag-text {
                                    vertical-align: middle !important;
                                    line-height: 1 !important;
                                    position: relative !important;
                                    top: 0 !important;
                                }

                                .el-icon {
                                    font-size: 16px;
                                }
                            }
                        }
                    }

                    // 卡片内容
                    .post-card-content {
                        padding: 16px 20px;
                        display: flex;
                        gap: 16px;

                        .post-image-container {
                            flex-shrink: 0;
                            width: 100px;
                            height: 100px;
                            border-radius: 8px;
                            overflow: hidden;
                            background-color: var(--el-fill-color-lighter);

                            .post-image {
                                width: 100%;
                                height: 100%;
                                transition: transform 0.3s ease;

                                &:hover {
                                    transform: scale(1.05);
                                }
                            }

                            .image-error {
                                width: 100%;
                                height: 100%;
                                display: flex;
                                justify-content: center;
                                align-items: center;
                                color: var(--el-text-color-placeholder);

                                .el-icon {
                                    font-size: 32px;
                                }
                            }
                        }

                        .post-info {
                            flex: 1;
                            display: flex;
                            flex-direction: column;

                            .post-name {
                                font-size: 16px;
                                font-weight: 500;
                                color: var(--el-text-color-primary);
                                margin-bottom: 12px;
                                display: -webkit-box;
                                -webkit-line-clamp: 2;
                                -webkit-box-orient: vertical;
                                overflow: hidden;
                                text-overflow: ellipsis;
                            }

                            .post-meta {
                                display: flex;
                                flex-wrap: wrap;
                                gap: 16px;
                                color: var(--el-text-color-secondary);

                                .meta-item {
                                    display: flex;
                                    align-items: center;

                                    .label {
                                        margin-right: 6px;
                                    }

                                    .value {
                                        color: var(--el-text-color-primary);
                                        display: -webkit-box;
                                        -webkit-line-clamp: 2;
                                        -webkit-box-orient: vertical;
                                        overflow: hidden;
                                        text-overflow: ellipsis;
                                    }
                                }

                                .view-count {
                                    display: flex;
                                    align-items: center;
                                    gap: 4px;

                                    .el-icon {
                                        font-size: 14px;
                                    }
                                }
                            }
                        }
                    }

                    // 卡片底部
                    .post-card-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color, #fff);

                        .post-actions {
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
    .my-post-container {
        padding: 12px;

        .post-header-card {
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

        .post-content {
            .post-container {
                padding: 16px;

                .post-card {
                    .post-card-header {
                        flex-direction: column;
                        align-items: flex-start;
                        gap: 12px;

                        .post-status {
                            align-self: flex-start;
                            width: 100%;
                        }
                    }

                    .post-card-content {
                        flex-direction: column;

                        .post-image-container {
                            width: 100%;
                            height: auto;
                            aspect-ratio: 1/1;
                            max-width: 200px;
                            margin: 0 auto;
                        }
                    }

                    .post-card-footer {
                        .post-actions {
                            justify-content: center;
                        }
                    }
                }
            }
        }
    }
}
</style>