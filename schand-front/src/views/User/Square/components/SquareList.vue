<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { View, Star, Collection, Pointer, Grid, List } from '@element-plus/icons-vue'

const router = useRouter()

// 视图模式：grid 或 list
const viewMode = ref('grid')

// 切换视图模式
const toggleViewMode = () => {
    viewMode.value = viewMode.value === 'grid' ? 'list' : 'grid'
    // 存储到本地，保持用户偏好
    localStorage.setItem('goodsViewMode', viewMode.value)
}

// 接收父组件传递的数据
const props = defineProps({
    goodsList: {
        type: Array,
        default: () => []
    },
    loading: {
        type: Boolean,
        default: false
    },
    total: {
        type: Number,
        default: 0
    },
    pageNum: {
        type: Number,
        default: 1
    },
    pageSize: {
        type: Number,
        default: 8
    }
})

// 本地状态，用于控制加载状态和过渡效果
const localLoading = ref(props.loading)
const fadeItems = ref(false)

// 监听外部传入的loading属性
watch(() => props.loading, (newValue) => {
    // 先触发淡出效果，再设置loading状态
    if (newValue) {
        localLoading.value = true
    } else {
        // 给数据加载留一些时间进行过渡
        setTimeout(() => {
            localLoading.value = false
        }, 300)
    }
})

// 监听商品列表变化
watch(() => props.goodsList, () => {
    // 商品列表变化时，先触发淡出效果
    fadeItems.value = true
    // 然后重新淡入
    setTimeout(() => {
        fadeItems.value = false
    }, 150)
}, { deep: true })

// 定义子组件向父组件传递的事件
const emit = defineEmits(['page-change'])

// 跳转到商品详情页
const goToDetail = (goodsId) => {
    router.push(`/goods/detail/${goodsId}`)
}

// 处理页码变化
const handleCurrentChange = (currentPage) => {
    emit('page-change', currentPage)
}

// 计算当前范围的商品
const currentRangeText = computed(() => {
    const start = (props.pageNum - 1) * props.pageSize + 1
    const end = Math.min(props.pageNum * props.pageSize, props.total)
    return `${start} - ${end} / ${props.total}`
})

// 计算是否显示商品列表
const showGoodsList = computed(() => {
    return !localLoading.value && props.goodsList && props.goodsList.length > 0
})

// 计算是否显示空状态
const showEmpty = computed(() => {
    return !localLoading.value && (!props.goodsList || props.goodsList.length === 0)
})

// 货币格式化
const formatPrice = (price) => {
    return `¥ ${parseFloat(price).toFixed(2)}`
}

// 截取商品内容
const truncateContent = (content, length = 200) => {
    if (!content) return '暂无描述';
    return content.length > length ? content.slice(0, length) + '...' : content;
}

// 格式化时间
const formatDate = (dateStr) => {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

// 初始化视图模式 (从本地存储中获取)
onMounted(() => {
    const savedViewMode = localStorage.getItem('goodsViewMode');
    if (savedViewMode) {
        viewMode.value = savedViewMode;
    }
});
</script>

<template>
    <div class="goods-container">
        <div class="goods-list">
            <!-- 头部工具栏：商品数量统计和视图切换 -->
            <div class="goods-header" v-if="showGoodsList">
                <div class="goods-count">
                    <span>共找到 <b>{{ total }}</b> 件商品</span>
                    <span>当前显示: {{ currentRangeText }}</span>
                </div>
                <div class="view-toggle">
                    <el-tooltip content="网格视图" placement="top" :effect="viewMode === 'grid' ? 'light' : 'dark'">
                        <el-button :type="viewMode === 'grid' ? 'primary' : 'default'" circle
                            @click="viewMode = 'grid'">
                            <el-icon>
                                <Grid />
                            </el-icon>
                        </el-button>
                    </el-tooltip>
                    <el-tooltip content="列表视图" placement="top" :effect="viewMode === 'list' ? 'light' : 'dark'">
                        <el-button :type="viewMode === 'list' ? 'primary' : 'default'" circle
                            @click="viewMode = 'list'">
                            <el-icon>
                                <List />
                            </el-icon>
                        </el-button>
                    </el-tooltip>
                </div>
            </div>

            <!-- 加载动画 -->
            <div v-if="localLoading" class="loading-container">
                <el-skeleton :rows="4" animated />
                <el-skeleton :rows="4" animated />
                <el-skeleton :rows="4" animated />
            </div>

            <!-- 商品列表 - 网格视图 -->
            <transition name="fade">
                <div v-if="showGoodsList && viewMode === 'grid'" class="goods-grid"
                    :class="{ 'fade-items': fadeItems }">
                    <div v-for="item in goodsList" :key="item.id" class="goods-item" @click="goToDetail(item.id)">
                        <div class="goods-image">
                            <img :src="item.img || '/placeholder-image.jpg'" alt="商品图片" />
                        </div>
                        <div class="goods-info">
                            <div class="goods-name">{{ item.name }}</div>
                            <div class="goods-price">{{ formatPrice(item.price) }}</div>
                            <div class="goods-category" v-if="item.category">{{ item.category }}</div>
                        </div>
                        <!-- 商品统计信息 -->
                        <div class="goods-stats">
                            <div class="stat-item">
                                <el-icon>
                                    <View />
                                </el-icon>
                                <span>{{ item.views || item.readCount || 0 }}</span>
                            </div>
                            <div class="stat-item">
                                <el-icon>
                                    <Star />
                                </el-icon>
                                <span>{{ item.likes || item.likesCount || 0 }}</span>
                            </div>
                            <div class="stat-item">
                                <el-icon>
                                    <Collection />
                                </el-icon>
                                <span>{{ item.collections || item.collectCount || 0 }}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </transition>

            <!-- 商品列表 - 列表视图 -->
            <transition name="fade">
                <div v-if="showGoodsList && viewMode === 'list'" class="goods-list-view"
                    :class="{ 'fade-items': fadeItems }">
                    <div v-for="item in goodsList" :key="item.id" class="list-item" @click="goToDetail(item.id)">
                        <div class="list-item-left">
                            <div class="list-item-image">
                                <img :src="item.img || '/placeholder-image.jpg'" alt="商品图片" />
                            </div>
                        </div>
                        <div class="list-item-right">
                            <div class="list-item-header">
                                <h3 class="list-item-title">{{ item.name }}</h3>
                                <div class="list-item-price">{{ formatPrice(item.price) }}</div>
                            </div>
                            <div class="list-item-tags">
                                <el-tag size="small" type="info" v-if="item.category">{{ item.category }}</el-tag>
                                <el-tag size="small" type="success" v-if="item.saleStatus === '在售'">在售</el-tag>
                                <el-tag size="small" type="warning" v-else-if="item.saleStatus === '预售'">预售</el-tag>
                                <el-tag size="small" type="danger" v-else-if="item.saleStatus === '已售'">已售</el-tag>
                            </div>
                            <div class="list-item-content">
                                <p>{{ truncateContent(item.content) }}</p>
                            </div>
                            <div class="list-item-meta">
                                <div class="list-item-info">
                                    <span v-if="item.date">发布日期: {{ formatDate(item.date) }}</span>
                                    <span v-if="item.address">发布地点: {{ item.address }}</span>
                                    <span v-if="item.userName">发布者: {{ item.userName }}</span>
                                </div>
                                <div class="list-item-stats">
                                    <div class="stat-item">
                                        <el-icon>
                                            <View />
                                        </el-icon>
                                        <span>{{ item.views || item.readCount || 0 }}</span>
                                    </div>
                                    <div class="stat-item">
                                        <el-icon>
                                            <Star />
                                        </el-icon>
                                        <span>{{ item.likes || item.likesCount || 0 }}</span>
                                    </div>
                                    <div class="stat-item">
                                        <el-icon>
                                            <Collection />
                                        </el-icon>
                                        <span>{{ item.collections || item.collectCount || 0 }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </transition>

            <!-- 空状态 -->
            <transition name="fade">
                <el-empty v-if="showEmpty" description="暂无商品" class="empty-state" />
            </transition>

            <!-- 分页 -->
            <div class="pagination-container" v-if="goodsList.length > 0 && total > 0 && !localLoading">
                <el-pagination background @current-change="handleCurrentChange" :current-page="pageNum"
                    :page-size="pageSize" layout="total, prev, pager, next, jumper" :total="total">
                </el-pagination>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.goods-container {
    background-color: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
    padding: 20px;
}

.goods-list {
    width: 100%;
    min-height: 600px;
    position: relative;
    display: flex;
    flex-direction: column;
}

.goods-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #f0f0f0;
}

.view-toggle {
    display: flex;
    gap: 8px;
}

.goods-count {
    display: flex;
    gap: 20px;
    color: #606266;
    font-size: 14px;

    b {
        color: #409eff;
        font-weight: 600;
    }
}

.loading-container {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
    min-height: 400px;
}

/* 网格和列表视图的共同样式 */
.goods-grid,
.goods-list-view {
    margin-bottom: 50px;
    /* 确保底部留出统一的空间给分页器 */
    min-height: 400px;
    /* 保持最小高度一致 */
    transition: opacity 0.3s ease;

    &.fade-items {
        opacity: 0.6;
    }
}

/* 网格视图特有样式 */
.goods-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 20px;
}

/* 列表视图特有样式 */
.goods-list-view {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.goods-item {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
    transition: all 0.3s ease;
    cursor: pointer;
    height: 100%;
    display: flex;
    flex-direction: column;

    &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
    }
}

.goods-image {
    width: 100%;
    height: 200px;
    overflow: hidden;
    position: relative;

    &::after {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(rgba(0, 0, 0, 0), rgba(0, 0, 0, 0.02));
        opacity: 0;
        transition: opacity 0.3s;
    }

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
    }

    &:hover {
        &::after {
            opacity: 1;
        }

        img {
            transform: scale(1.05);
        }
    }
}

.goods-info {
    padding: 16px;
    flex-grow: 1;
}

.goods-name {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 8px;
    color: #303133;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    text-overflow: ellipsis;
    height: 48px;
}

.goods-price {
    font-size: 18px;
    font-weight: 600;
    color: #f56c6c;
    margin-bottom: 8px;
}

.goods-category {
    display: inline-block;
    font-size: 12px;
    background-color: #f5f7fa;
    color: #909399;
    padding: 2px 8px;
    border-radius: 12px;
}

.goods-stats {
    display: flex;
    justify-content: space-between;
    padding: 8px 16px;
    border-top: 1px solid #f0f0f0;
    background-color: #f9f9f9;

    .stat-item {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 12px;
        color: #909399;
        transition: color 0.2s;

        .el-icon {
            font-size: 14px;
        }

        &:hover {
            color: #409eff;
        }
    }
}

.list-item {
    display: flex;
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    transition: all 0.3s ease;
    cursor: pointer;
    border: 1px solid #f0f0f0;

    &:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
    }
}

.list-item-left {
    flex: 0 0 250px;
}

.list-item-image {
    width: 100%;
    height: 100%;
    overflow: hidden;

    img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
    }

    &:hover img {
        transform: scale(1.05);
    }
}

.list-item-right {
    flex: 1;
    padding: 20px;
    display: flex;
    flex-direction: column;
}

.list-item-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 10px;
}

.list-item-title {
    font-size: 18px;
    font-weight: 600;
    color: #303133;
    margin: 0;
    padding: 0;
    flex: 1;
}

.list-item-price {
    font-size: 20px;
    font-weight: 600;
    color: #f56c6c;
    margin-left: 15px;
}

.list-item-tags {
    display: flex;
    gap: 8px;
    margin-bottom: 12px;
}

.list-item-content {
    margin-bottom: 15px;
    color: #606266;
    font-size: 14px;
    line-height: 1.6;
    max-height: 120px;
    overflow: hidden;
    flex: 1;
}

.list-item-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: auto;
    border-top: 1px solid #f0f0f0;
    padding-top: 12px;
}

.list-item-info {
    display: flex;
    flex-wrap: wrap;
    gap: 15px;
    font-size: 13px;
    color: #909399;
}

.list-item-stats {
    display: flex;
    gap: 15px;

    .stat-item {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 13px;
        color: #909399;
        transition: color 0.2s;

        .el-icon {
            font-size: 15px;
        }

        &:hover {
            color: #409eff;
        }
    }
}

.pagination-container {
    display: flex;
    justify-content: center;
    margin-top: 20px;
    /* 减小顶部边距，依赖上方元素的margin-bottom保持间距 */
    padding-top: 20px;
    /* 保持内边距 */
    border-top: 1px solid #ebeef5;
    /* 恢复顶部边框 */
    position: relative;
    /* 确保定位一致 */
}

/* 添加淡入淡出动画 */
.fade-enter-active,
.fade-leave-active {
    transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.empty-state {
    padding: 120px 0;
    flex-grow: 1;
    display: flex;
    justify-content: center;
    align-items: center;
}

@media (max-width: 768px) {
    .goods-grid {
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
        gap: 15px;
    }

    .list-item {
        flex-direction: column;
    }

    .list-item-left {
        flex: auto;
        height: 180px;
    }

    .goods-image {
        height: 150px;
    }

    .goods-info {
        padding: 12px;
    }

    .goods-name {
        font-size: 14px;
        height: 42px;
    }

    .goods-price {
        font-size: 16px;
    }

    .goods-stats {
        padding: 6px 12px;

        .stat-item {
            font-size: 11px;

            .el-icon {
                font-size: 12px;
            }
        }
    }

    .list-item-header {
        flex-direction: column;
    }

    .list-item-price {
        margin-left: 0;
        margin-top: 5px;
    }

    .list-item-meta {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
    }

    .list-item-info {
        width: 100%;
    }

    .list-item-stats {
        width: 100%;
        justify-content: space-between;
    }
}
</style>