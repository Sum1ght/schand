<script setup>
import { deleteBatchCollectAPI, deleteCollectAPI, getCollectPageAPI } from '@/api/collectAPI'
import { Collection, Delete, Link, Picture, Star } from '@element-plus/icons-vue'
import { onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'

// 路由实例
const router = useRouter()

// 页面状态
const pageState = reactive({
    loading: false,
    pageNum: 1,
    pageSize: 10,
    total: 0,
    tableData: [],
    ids: []
})

// 加载数据
const loadCollections = async (page) => {
    try {
        pageState.loading = true
        if (page) pageState.pageNum = page

        const res = await getCollectPageAPI({
            pageNum: pageState.pageNum,
            pageSize: pageState.pageSize,
        })

        if (res.code === '200') {
            pageState.tableData = res.data?.list || []
            pageState.total = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '获取收藏数据失败')
        }
    } catch (error) {
        console.error('加载收藏数据失败:', error)
        ElMessage.error('加载收藏数据失败')
    } finally {
        pageState.loading = false
    }
}

// 单个删除
const deleteCollection = async (id) => {
    try {
        const result = await ElMessageBox.confirm(
            '您确定取消收藏吗？',
            '确认取消收藏',
            { type: 'warning', confirmButtonText: '确定', cancelButtonText: '取消' }
        )

        if (result === 'confirm') {
            const res = await deleteCollectAPI(id)

            if (res.code === '200') {
                ElMessage.success('取消收藏成功')
                loadCollections(1)
            } else {
                ElMessage.error(res.msg || '取消收藏失败')
            }
        }
    } catch (error) {
        // 用户取消操作，不做处理
        console.log('用户取消操作')
    }
}

// 单选收藏
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

// 批量删除
const deleteBatchCollections = async () => {
    if (!pageState.ids.length) {
        ElMessage.warning('请选择要取消收藏的商品')
        return
    }

    try {
        const result = await ElMessageBox.confirm(
            '您确定批量取消收藏这些商品吗？',
            '确认取消收藏',
            { type: 'warning', confirmButtonText: '确定', cancelButtonText: '取消' }
        )

        if (result === 'confirm') {
            const res = await deleteBatchCollectAPI(pageState.ids)

            if (res.code === '200') {
                ElMessage.success('批量取消收藏成功')
                loadCollections(1)
            } else {
                ElMessage.error(res.msg || '批量取消收藏失败')
            }
        }
    } catch (error) {
        // 用户取消操作，不做处理
        console.log('用户取消操作')
    }
}

// 打开商品详情
const openGoodsDetail = (fid) => {
    router.push(`/goods/detail/${fid}`)
}

// 分页处理
const handleCurrentChange = (page) => {
    loadCollections(page)
}

// 生命周期钩子
onMounted(() => {
    loadCollections(1)
})
</script>

<template>
    <div class="my-collection-container">
        <!-- 顶部卡片 -->
        <div class="collection-header-card">
            <div class="collection-title">
                <span class="title-icon"><el-icon>
                        <Collection />
                    </el-icon></span>
                <h2>我的收藏</h2>
            </div>

            <!-- 按钮区域 -->
            <div class="action-container">
                <div class="action-buttons">
                    <el-button type="danger" :disabled="!pageState.ids.length" @click="deleteBatchCollections">
                        <el-icon>
                            <Delete />
                        </el-icon><span>批量取消收藏</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 收藏内容区域 -->
        <div class="collection-content">
            <div class="collection-container">
                <!-- 收藏卡片列表 -->
                <transition-group name="fade" tag="div" class="collection-card-list">
                    <!-- 空状态 -->
                    <div v-if="pageState.tableData.length === 0 && !pageState.loading" class="empty-state" key="empty">
                        <el-empty description="暂无收藏商品">
                            <template #image>
                                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
                            </template>
                        </el-empty>
                    </div>

                    <!-- 收藏卡片 -->
                    <div v-for="item in pageState.tableData" :key="item.id" class="collection-card">
                        <!-- 复选框 -->
                        <div class="card-checkbox">
                            <el-checkbox @change="(val) => handleItemSelect(val, item)"
                                :checked="pageState.ids.includes(item.id)" />
                        </div>

                        <!-- 卡片内容 -->
                        <div class="collection-card-content">
                            <div class="collection-image-container">
                                <el-image v-if="item.goodsImg" :src="item.goodsImg" :preview-src-list="[item.goodsImg]"
                                    class="collection-image" fit="cover" lazy>
                                    <template #error>
                                        <div class="image-error"><el-icon>
                                                <Picture />
                                            </el-icon></div>
                                    </template>
                                </el-image>
                                <div v-else class="image-error"><el-icon>
                                        <Picture />
                                    </el-icon></div>
                            </div>

                            <div class="collection-info">
                                <div class="collection-name">
                                    <el-icon color="#E6A23C">
                                        <Star />
                                    </el-icon>
                                    {{ item.goodsName }}
                                </div>
                                <div class="collection-meta">
                                    <div class="meta-item">
                                        <span class="label">收藏时间:</span>
                                        <span class="value">{{ item.createTime || '未知' }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- 卡片底部 -->
                        <div class="collection-card-footer">
                            <div class="collection-actions">
                                <el-button type="primary" plain @click="openGoodsDetail(item.fid)"
                                    class="action-button">
                                    <el-icon>
                                        <Link />
                                    </el-icon>
                                    查看详情
                                </el-button>
                                <el-button type="danger" @click="deleteCollection(item.id)" class="action-button">
                                    <el-icon>
                                        <Delete />
                                    </el-icon>
                                    取消收藏
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
                        :total="pageState.total" hide-on-single-page />
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// 主容器样式
.my-collection-container {
    padding: 20px;
    min-height: calc(100vh - 120px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    // 顶部卡片样式
    .collection-header-card {
        max-width: 1000px;
        margin: 0 auto 20px;
        background-color: var(--el-bg-color, #fff);
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        padding: 24px;

        .collection-title {
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
                background: var(--el-color-warning-light-8);
                margin-right: 12px;

                .el-icon {
                    font-size: 24px;
                    color: var(--el-color-warning);
                }
            }

            h2 {
                font-size: 22px;
                font-weight: 600;
                color: var(--el-text-color-primary);
                margin: 0;
            }
        }

        // 操作区域
        .action-container {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;

            .action-buttons {
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

    // 收藏内容区域
    .collection-content {
        position: relative;
        min-height: 300px;

        // 收藏容器
        .collection-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 24px;

            // 收藏卡片列表
            .collection-card-list {
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

                // 收藏卡片
                .collection-card {
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

                    // 卡片内容
                    .collection-card-content {
                        padding: 16px 20px;
                        display: flex;
                        gap: 16px;

                        .collection-image-container {
                            flex-shrink: 0;
                            width: 100px;
                            height: 100px;
                            border-radius: 8px;
                            overflow: hidden;
                            background-color: var(--el-fill-color-lighter);

                            .collection-image {
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

                        .collection-info {
                            flex: 1;
                            display: flex;
                            flex-direction: column;

                            .collection-name {
                                font-size: 16px;
                                font-weight: 500;
                                color: var(--el-text-color-primary);
                                margin-bottom: 12px;
                                display: flex;
                                align-items: center;
                                gap: 8px;
                            }

                            .collection-meta {
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
                            }
                        }
                    }

                    // 卡片底部
                    .collection-card-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color, #fff);

                        .collection-actions {
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
    .my-collection-container {
        padding: 12px;

        .collection-header-card {
            padding: 16px;

            .action-container {
                flex-direction: column;

                .action-buttons {
                    width: 100%;
                    justify-content: space-between;
                }
            }
        }

        .collection-content {
            .collection-container {
                padding: 16px;

                .collection-card {
                    .collection-card-content {
                        flex-direction: column;

                        .collection-image-container {
                            width: 100%;
                            height: auto;
                            aspect-ratio: 1/1;
                            max-width: 200px;
                            margin: 0 auto;
                        }
                    }

                    .collection-card-footer {
                        .collection-actions {
                            justify-content: center;
                        }
                    }
                }
            }
        }
    }
}
</style>