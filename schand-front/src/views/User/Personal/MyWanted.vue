<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
    getHelpPageAPI,
    addHelpAPI,
    updateHelpAPI,
    deleteHelpAPI,
    deleteBatchHelpAPI
} from '@/api/wantedAPI'
import { useUserStore } from '@/stores/userStore'
import { Search, Delete, Plus, View, Picture, Edit, Document, Aim, Calendar, CircleCheck, CircleClose, Warning } from '@element-plus/icons-vue'

// 路由实例
const router = useRouter()

// 响应式数据
const pageState = reactive({
    loading: false,
    dialogVisible: false,
    ids: [],
    title: '',
    pageNum: 1,
    pageSize: 10,
    total: 0,
    tableData: []
})

// 表单引用
const formRef = ref(null)
const form = reactive({})

// 使用Pinia的userStore替代localStorage
const userStore = useUserStore()
const user = reactive(userStore.userInfo)

// 表单验证规则
const rules = {
    title: [
        { required: true, message: '请输入标题', trigger: 'blur' },
        { min: 2, max: 50, message: '标题长度应在2-50个字符之间', trigger: 'blur' }
    ],
    content: [
        { required: true, message: '请输入内容', trigger: 'blur' },
        { min: 5, max: 500, message: '内容长度应在5-500个字符之间', trigger: 'blur' }
    ],
    solved: [
        { required: true, message: '请选择是否解决', trigger: 'change' }
    ]
}

// 加载数据
const loadWanted = async (page) => {
    if (page) pageState.pageNum = page
    pageState.loading = true
    try {
        const res = await getHelpPageAPI({
            pageNum: pageState.pageNum,
            pageSize: pageState.pageSize,
            title: pageState.title
        })

        if (res.code === '200') {
            pageState.tableData = res.data?.list || []
            pageState.total = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '获取数据失败')
        }
    } catch (error) {
        console.error('加载数据失败:', error)
        ElMessage.error('加载数据失败')
    } finally {
        pageState.loading = false
    }
}

// 编辑数据
const handleEdit = (row) => {
    console.log('编辑悬赏，ID:', row.id)
    // 确保ID是数字类型
    const wantedId = parseInt(row.id)
    if (isNaN(wantedId)) {
        ElMessage.error('无效的悬赏ID')
        return
    }
    // 使用query参数传递ID
    router.push({
        path: '/wanted/create',
        query: { id: wantedId }
    })
}

// 新增数据
const handleAdd = () => {
    router.push('/wanted/create')
}

// 查看悬赏详情
const viewWantedDetail = (item) => {
    if (item.status === '待审核') {
        ElMessage.warning('该悬赏需求正在审核中，暂时无法查看详情')
        return
    }
    if (item.status === '拒绝') {
        ElMessage.warning('该悬赏需求审核未通过，请修改后重新提交')
        return
    }
    // 跳转到悬赏详情页
    router.push('/wanted/detail/' + item.id)
}

// 删除数据
const deleteWanted = async (id) => {
    try {
        const result = await ElMessageBox.confirm(
            '您确定删除吗？',
            '确认删除',
            { type: 'warning', confirmButtonText: '确定', cancelButtonText: '取消' }
        )

        if (result === 'confirm') {
            const res = await deleteHelpAPI(id)

            if (res.code === '200') {
                ElMessage.success('删除成功')
                loadWanted(1)
            } else {
                ElMessage.error(res.msg || '删除失败')
            }
        }
    } catch (error) {
        // 用户取消操作，不做处理
        console.log('用户取消操作')
    }
}

// 单选悬赏
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

// 表格选择变化
const handleSelectionChange = (rows) => {
    pageState.ids = rows.map(v => v.id)
}

// 批量删除
const deleteBatchWanted = async () => {
    if (!pageState.ids.length) {
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
            const res = await deleteBatchHelpAPI(pageState.ids)

            if (res.code === '200') {
                ElMessage.success('批量删除成功')
                loadWanted(1)
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
const resetSearch = () => {
    pageState.title = ''
    loadWanted(1)
}

// 搜索商品
const searchWanted = () => loadWanted(1)

// 分页变化
const handleCurrentChange = (page) => {
    loadWanted(page)
}

// 生命周期钩子
onMounted(() => {
    loadWanted(1)
})
</script>

<template>
    <div class="my-wanted-container">
        <!-- 顶部卡片 -->
        <div class="wanted-header-card">
            <div class="wanted-title">
                <span class="title-icon"><el-icon>
                        <Aim />
                    </el-icon></span>
                <h2>我的悬赏</h2>
            </div>

            <!-- 搜索区域 -->
            <div class="search-container">
                <div class="search-inputs">
                    <div class="search-input-item">
                        <el-input v-model="pageState.title" placeholder="搜索悬赏标题" clearable @keyup.enter="searchWanted">
                            <template #prefix><el-icon>
                                    <Search />
                                </el-icon></template>
                        </el-input>
                    </div>
                </div>

                <div class="search-buttons">
                    <el-button type="primary" @click="searchWanted" :loading="pageState.loading">
                        <el-icon>
                            <Search />
                        </el-icon><span>查询</span>
                    </el-button>
                    <el-button @click="resetSearch" :disabled="pageState.loading">
                        <el-icon>
                            <View />
                        </el-icon><span>重置</span>
                    </el-button>
                    <el-button type="success" @click="handleAdd">
                        <el-icon>
                            <Plus />
                        </el-icon><span>发布悬赏</span>
                    </el-button>
                    <el-button type="danger" :disabled="!pageState.ids.length" @click="deleteBatchWanted">
                        <el-icon>
                            <Delete />
                        </el-icon><span>批量删除</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 悬赏内容区域 -->
        <div class="wanted-content">
            <div class="wanted-container">
                <!-- 悬赏卡片列表 -->
                <transition-group name="fade" tag="div" class="wanted-card-list">
                    <!-- 空状态 -->
                    <div v-if="pageState.tableData.length === 0 && !pageState.loading" class="empty-state" key="empty">
                        <el-empty description="暂无悬赏数据">
                            <template #image>
                                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
                            </template>
                        </el-empty>
                    </div>

                    <!-- 悬赏卡片 -->
                    <div v-for="item in pageState.tableData" :key="item.id" class="wanted-card">
                        <!-- 复选框 -->
                        <div class="card-checkbox">
                            <el-checkbox @change="(val) => handleItemSelect(val, item)"
                                :checked="pageState.ids.includes(item.id)" />
                        </div>

                        <!-- 卡片头部 -->
                        <div class="wanted-card-header">
                            <div class="wanted-info">
                                <div class="wanted-id">
                                    <span class="label">悬赏ID:</span>
                                    <span class="value">{{ item.id }}</span>
                                </div>
                                <div class="wanted-date">
                                    <el-icon>
                                        <Calendar />
                                    </el-icon>
                                    <span>{{ item.time }}</span>
                                </div>
                            </div>
                            <div class="wanted-status">
                                <div class="status-tag-wrapper">
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
                                </div>
                                <el-tag :type="item.solved === '未解决' ? 'danger' : 'success'" size="small"
                                    style="margin-left: 8px;">
                                    {{ item.solved }}
                                </el-tag>
                            </div>
                        </div>

                        <!-- 卡片内容 -->
                        <div class="wanted-card-content">
                            <div class="wanted-image-container">
                                <el-image
                                    :src="item.img || 'https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png'"
                                    fit="cover" :preview-src-list="item.img ? [item.img] : []" class="wanted-image"
                                    lazy>
                                    <template #error>
                                        <div class="image-error"><el-icon>
                                                <Picture />
                                            </el-icon></div>
                                    </template>
                                </el-image>
                            </div>

                            <div class="wanted-info">
                                <div class="wanted-name">标题: {{ item.title }}</div>
                                <div class="wanted-meta">
                                    <div class="meta-item description">
                                        <span class="label">内容:</span>
                                        <span class="value" v-html="item.content"></span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 卡片底部 -->
                        <div class="wanted-card-footer">
                            <div class="wanted-actions">
                                <el-button type="primary" plain @click="viewWantedDetail(item)" class="action-button">
                                    <el-icon>
                                        <Document />
                                    </el-icon>
                                    查看详情
                                </el-button>
                                <el-button type="primary" @click="handleEdit(item)" class="action-button">
                                    <el-icon>
                                        <Edit />
                                    </el-icon>
                                    编辑
                                </el-button>
                                <el-button type="danger" @click="deleteWanted(item.id)" class="action-button">
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
.my-wanted-container {
    padding: 20px;
    min-height: calc(100vh - 120px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    // 顶部卡片样式
    .wanted-header-card {
        max-width: 1000px;
        margin: 0 auto 20px;
        background-color: var(--el-bg-color, #fff);
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        padding: 24px;

        .wanted-title {
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

    // 悬赏内容区域
    .wanted-content {
        position: relative;
        min-height: 300px;

        // 悬赏容器
        .wanted-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 24px;

            // 悬赏卡片列表
            .wanted-card-list {
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

                // 悬赏卡片
                .wanted-card {
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
                    .wanted-card-header {
                        padding: 16px 20px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        border-bottom: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color-page, #f5f7fa);

                        .wanted-info {
                            display: flex;
                            align-items: center;
                            flex-wrap: wrap;
                            gap: 16px;
                            margin-left: 24px; // 为复选框留出空间

                            .wanted-id {
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

                            .wanted-date {
                                display: flex;
                                align-items: center;
                                color: var(--el-text-color-secondary);

                                .el-icon {
                                    margin-right: 6px;
                                }
                            }
                        }

                        .wanted-status {
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
                    }

                    // 卡片内容
                    .wanted-card-content {
                        padding: 16px 20px;
                        display: flex;
                        gap: 16px;

                        .wanted-image-container {
                            flex-shrink: 0;
                            width: 100px;
                            height: 100px;
                            border-radius: 8px;
                            overflow: hidden;
                            background-color: var(--el-fill-color-lighter);

                            .wanted-image {
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

                        .wanted-info {
                            flex: 1;
                            display: flex;
                            flex-direction: column;

                            .wanted-name {
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

                            .wanted-meta {
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

                                .description {
                                    width: 100%;
                                }
                            }
                        }
                    }

                    // 卡片底部
                    .wanted-card-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color, #fff);

                        .wanted-actions {
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
    .my-wanted-container {
        padding: 12px;

        .wanted-header-card {
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

        .wanted-content {
            .wanted-container {
                padding: 16px;

                .wanted-card {
                    .wanted-card-header {
                        flex-direction: column;
                        align-items: flex-start;
                        gap: 12px;

                        .wanted-status {
                            align-self: flex-start;
                            width: 100%;
                        }
                    }

                    .wanted-card-content {
                        flex-direction: column;

                        .wanted-image-container {
                            width: 100%;
                            height: auto;
                            aspect-ratio: 1/1;
                            max-width: 200px;
                            margin: 0 auto;
                        }
                    }

                    .wanted-card-footer {
                        .wanted-actions {
                            justify-content: center;
                        }
                    }
                }
            }
        }
    }
}
</style>