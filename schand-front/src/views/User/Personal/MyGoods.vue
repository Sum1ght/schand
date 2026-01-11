<script setup>
import { deleteBatchGoodsAPI, deleteGoodsAPI, getGoodsPageAPI, updateGoodsAPI } from '@/api/goodsAPI'
import { Calendar, Delete, Document, Edit, Picture, Plus, Search, View, Goods, Warning, CircleCheck, CircleClose } from '@element-plus/icons-vue'
import { onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'

// 路由实例
const router = useRouter()

// 页面状态
const pageState = reactive({
    loading: false,
    dialogVisible: false,
    content: '',
    ids: [],
    name: '',
    pageNum: 1,
    pageSize: 10,
    total: 0,
    tableData: []
})

// 用户信息
const user = reactive(JSON.parse(localStorage.getItem('xm-user') || '{}'))

// 加载商品数据
const loadGoods = async (page) => {
    if (page) pageState.pageNum = page
    pageState.loading = true
    try {
        const res = await getGoodsPageAPI({
            pageNum: pageState.pageNum,
            pageSize: pageState.pageSize,
            name: pageState.name,
            userId: user.id // 只查询当前用户的商品
        })
        if (res.code === '200') {
            pageState.tableData = res.data?.list || []
            pageState.total = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '加载数据失败')
        }
    } catch (error) {
        console.error('加载数据出错:', error)
        ElMessage.error('加载数据出错')
    } finally {
        pageState.loading = false
    }
}

// 显示商品详情
const previewContent = (contentText) => {
    pageState.content = contentText
    pageState.dialogVisible = true
}

// 修改商品状态
const changeStatus = (row, status) => {
    ElMessageBox.confirm('您确定操作吗？', '确认操作', { type: 'warning' })
        .then(async () => {
            const formData = JSON.parse(JSON.stringify(row)) // 深拷贝数据
            formData.status = status
            try {
                const res = await updateGoodsAPI(formData)
                if (res.code === '200') {
                    ElMessage.success('操作成功')
                    loadGoods(1)
                } else {
                    ElMessage.error(res.msg || '操作失败')
                }
            } catch (error) {
                console.error('修改状态出错:', error)
                ElMessage.error('修改状态出错')
            }
        })
        .catch(() => { })
}

// 编辑商品
const handleEdit = (row) => {
    router.push('/goods/create?id=' + row.id)
}

// 删除商品
const deleteGoods = (id) => {
    ElMessageBox.confirm('您确定删除吗？', '确认删除', { type: 'warning' })
        .then(async () => {
            try {
                const res = await deleteGoodsAPI(id)
                if (res.code === '200') {
                    ElMessage.success('删除成功')
                    loadGoods(1)
                } else {
                    ElMessage.error(res.msg || '删除失败')
                }
            } catch (error) {
                console.error('删除出错:', error)
                ElMessage.error('删除出错')
            }
        })
        .catch(() => { })
}

// 单选商品
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
const deleteBatchGoods = () => {
    if (!pageState.ids.length) {
        ElMessage.warning('请选择数据')
        return
    }

    ElMessageBox.confirm('您确定批量删除这些数据吗？', '确认删除', { type: 'warning' })
        .then(async () => {
            try {
                const res = await deleteBatchGoodsAPI(pageState.ids)
                if (res.code === '200') {
                    ElMessage.success('批量删除成功')
                    loadGoods(1)
                } else {
                    ElMessage.error(res.msg || '批量删除失败')
                }
            } catch (error) {
                console.error('批量删除出错:', error)
                ElMessage.error('批量删除出错')
            }
        })
        .catch(() => { })
}

// 重置筛选条件
const resetSearch = () => {
    pageState.name = ''
    loadGoods(1)
}

// 搜索商品
const searchGoods = () => loadGoods(1)

// 分页变化
const handleCurrentChange = (page) => {
    loadGoods(page)
}

// 获取标签类型
const getTagType = (status) => {
    switch (status) {
        case '待审核': return 'info'
        case '通过': return 'success'
        case '拒绝': return 'danger'
        default: return 'info'
    }
}

// 获取标签图标
const getTagIcon = (status) => {
    switch (status) {
        case '待审核': return Warning
        case '通过': return CircleCheck
        case '拒绝': return CircleClose
        default: return Warning
    }
}

// 生命周期钩子
onMounted(() => {
    loadGoods(1)
})
</script>

<template>
    <div class="my-goods-container">
        <!-- 顶部卡片 -->
        <div class="goods-header-card">
            <div class="goods-title">
                <span class="title-icon"><el-icon>
                        <Goods />
                    </el-icon></span>
                <h2>我的商品</h2>
            </div>

            <!-- 搜索区域 -->
            <div class="search-container">
                <div class="search-inputs">
                    <div class="search-input-item">
                        <el-input v-model="pageState.name" placeholder="搜索商品名称" clearable @keyup.enter="searchGoods">
                            <template #prefix><el-icon>
                                    <Search />
                                </el-icon></template>
                        </el-input>
                    </div>
                </div>

                <div class="search-buttons">
                    <el-button type="primary" @click="searchGoods" :loading="pageState.loading">
                        <el-icon>
                            <Search />
                        </el-icon><span>查询</span>
                    </el-button>
                    <el-button @click="resetSearch" :disabled="pageState.loading">
                        <el-icon>
                            <View />
                        </el-icon><span>重置</span>
                    </el-button>
                    <el-button type="success" @click="router.push('/goods/create')">
                        <el-icon>
                            <Plus />
                        </el-icon><span>发布商品</span>
                    </el-button>
                    <el-button type="danger" :disabled="!pageState.ids.length" @click="deleteBatchGoods">
                        <el-icon>
                            <Delete />
                        </el-icon><span>批量删除</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 商品内容区域 -->
        <div class="goods-content">
            <div class="goods-container">
                <!-- 商品卡片列表 -->
                <transition-group name="fade" tag="div" class="goods-card-list">
                    <!-- 空状态 -->
                    <div v-if="pageState.tableData.length === 0 && !pageState.loading" class="empty-state" key="empty">
                        <el-empty description="暂无商品数据">
                            <template #image>
                                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
                            </template>
                        </el-empty>
                    </div>

                    <!-- 商品卡片 -->
                    <div v-for="(item, index) in pageState.tableData" :key="item.id" class="goods-card">
                        <!-- 复选框 -->
                        <div class="card-checkbox">
                            <el-checkbox @change="(val) => handleItemSelect(val, item)"
                                :checked="pageState.ids.includes(item.id)" />
                        </div>

                        <!-- 卡片头部 -->
                        <div class="goods-card-header">
                            <div class="goods-info">
                                <div class="goods-id">
                                    <span class="label">商品ID:</span>
                                    <span class="value">{{ item.id }}</span>
                                </div>
                                <div class="goods-date">
                                    <el-icon>
                                        <Calendar />
                                    </el-icon>
                                    <span>{{ item.date }}</span>
                                </div>
                            </div>
                            <div class="goods-status">
                                <div class="status-tag-wrapper">
                                    <el-tag :type="getTagType(item.status)" effect="light">
                                        <div class="tag-content">
                                            <el-icon class="tag-icon">
                                                <component :is="getTagIcon(item.status)" />
                                            </el-icon>
                                            <span class="tag-text">{{ item.status }}</span>
                                        </div>
                                    </el-tag>
                                </div>

                                <el-tag :type="item.saleStatus === '上架' ? 'success' : 'info'" style="margin-left: 8px;"
                                    size="small">
                                    {{ item.saleStatus }}
                                </el-tag>
                            </div>
                        </div>

                        <!-- 卡片内容 -->
                        <div class="goods-card-content">
                            <div class="goods-image-container">
                                <el-image
                                    :src="item.img || 'https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png'"
                                    fit="cover" :preview-src-list="item.img ? [item.img] : []" class="goods-image" lazy>
                                    <template #error>
                                        <div class="image-error"><el-icon>
                                                <Picture />
                                            </el-icon></div>
                                    </template>
                                </el-image>
                            </div>

                            <div class="goods-info">
                                <div class="goods-name">{{ item.name }}</div>
                                <div class="goods-meta">
                                    <div class="meta-item">
                                        <span class="label">分类:</span>
                                        <span class="value">{{ item.category || '未分类' }}</span>
                                    </div>
                                    <div class="meta-item">
                                        <span class="label">地址:</span>
                                        <span class="value">{{ item.address || '未设置' }}</span>
                                    </div>
                                    <div class="meta-item view-count">
                                        <el-icon>
                                            <View />
                                        </el-icon>
                                        <span>{{ item.readCount || 0 }} 浏览</span>
                                    </div>
                                </div>
                            </div>

                            <div class="goods-price">
                                <div class="total-price">￥{{ item.price }}</div>
                            </div>
                        </div>

                        <!-- 卡片底部 -->
                        <div class="goods-card-footer">
                            <div class="goods-actions">
                                <el-button type="primary" plain @click="previewContent(item.content)"
                                    class="action-button">
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
                                <el-button type="danger" @click="deleteGoods(item.id)" class="action-button">
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

        <!-- 商品详情弹窗 -->
        <el-dialog v-model="pageState.dialogVisible" title="商品详情" width="650px" destroy-on-close
            :close-on-click-modal="false" class="goods-detail-dialog">
            <template #header>
                <div class="dialog-header">
                    <el-icon class="dialog-icon">
                        <View />
                    </el-icon>
                    <span>商品详情</span>
                </div>
            </template>

            <div class="content-preview" v-html="pageState.content"></div>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
// 主容器样式
.my-goods-container {
    padding: 20px;
    min-height: calc(100vh - 120px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    // 顶部卡片样式
    .goods-header-card {
        max-width: 1000px;
        margin: 0 auto 20px;
        background-color: var(--el-bg-color, #fff);
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        padding: 24px;

        .goods-title {
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

    // 商品内容区域
    .goods-content {
        position: relative;
        min-height: 300px;

        // 商品容器
        .goods-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 24px;

            // 商品卡片列表
            .goods-card-list {
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

                // 商品卡片
                .goods-card {
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
                    .goods-card-header {
                        padding: 16px 20px;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        border-bottom: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color-page, #f5f7fa);

                        .goods-info {
                            display: flex;
                            align-items: center;
                            flex-wrap: wrap;
                            gap: 16px;
                            margin-left: 24px; // 为复选框留出空间

                            .goods-id {
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

                            .goods-date {
                                display: flex;
                                align-items: center;
                                color: var(--el-text-color-secondary);

                                .el-icon {
                                    margin-right: 6px;
                                }
                            }
                        }

                        .goods-status {
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

                                .el-icon {
                                    font-size: 16px;
                                    display: flex !important;
                                    align-items: center !important;
                                    justify-content: center !important;
                                    position: relative !important;
                                    top: 0 !important;
                                }

                                span {
                                    vertical-align: middle !important;
                                    line-height: 1 !important;
                                    position: relative !important;
                                    top: 0 !important;
                                }
                            }

                            .status-tag {
                                display: inline-flex !important;
                                align-items: center !important;

                                .status-icon {
                                    display: flex !important;
                                    align-items: center !important;
                                    justify-content: center !important;
                                    margin-right: 4px !important;
                                    position: relative !important;
                                    top: 0 !important;
                                }

                                .status-text {
                                    vertical-align: middle !important;
                                    line-height: 1 !important;
                                    position: relative !important;
                                    top: 0 !important;
                                }
                            }
                        }
                    }

                    // 卡片内容
                    .goods-card-content {
                        padding: 16px 20px;
                        display: flex;
                        gap: 16px;

                        .goods-image-container {
                            flex-shrink: 0;
                            width: 100px;
                            height: 100px;
                            border-radius: 8px;
                            overflow: hidden;
                            background-color: var(--el-fill-color-lighter);

                            .goods-image {
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

                        .goods-info {
                            flex: 1;
                            display: flex;
                            flex-direction: column;

                            .goods-name {
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

                            .goods-meta {
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

                        .goods-price {
                            display: flex;
                            flex-direction: column;
                            align-items: flex-end;
                            justify-content: center;
                            padding: 0 12px;

                            .total-price {
                                font-size: 20px;
                                font-weight: 600;
                                color: #f56c6c;
                            }
                        }
                    }

                    // 卡片底部
                    .goods-card-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color, #fff);

                        .goods-actions {
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

    // 详情弹窗
    :deep(.goods-detail-dialog) {
        .el-dialog__header {
            padding: 12px 20px;
        }

        .dialog-header {
            display: flex;
            align-items: center;
            gap: 8px;

            .dialog-icon {
                font-size: 18px;
                color: var(--el-color-primary);
            }

            span {
                font-size: 16px;
                font-weight: 600;
            }
        }

        .content-preview {
            max-height: 60vh;
            overflow-y: auto;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 4px;
            line-height: 1.6;
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
    .my-goods-container {
        padding: 12px;

        .goods-header-card {
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

        .goods-content {
            .goods-container {
                padding: 16px;

                .goods-card {
                    .goods-card-header {
                        flex-direction: column;
                        align-items: flex-start;
                        gap: 12px;

                        .goods-status {
                            align-items: flex-start;
                            width: 100%;
                        }
                    }

                    .goods-card-content {
                        flex-direction: column;

                        .goods-image-container {
                            width: 100%;
                            height: auto;
                            aspect-ratio: 1/1;
                            max-width: 200px;
                            margin: 0 auto;
                        }

                        .goods-price {
                            align-items: flex-start;
                            padding: 12px 0 0;
                        }
                    }

                    .goods-card-footer {
                        .goods-actions {
                            justify-content: center;
                        }
                    }
                }
            }
        }
    }
}
</style>