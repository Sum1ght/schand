<script setup>
/**
 * 悬赏列表组件
 * 展示悬赏条目、状态和评论功能
 */
import { ref, computed, defineProps, defineEmits, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/userStore'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Timer, Money, User, ChatDotRound, Picture } from '@element-plus/icons-vue'
import Comment from "@/components/Comment.vue"
import { getHelpFrontPageAPI, updateHelpAPI } from '@/api/wantedAPI'
import { format } from 'date-fns'
import { zhCN } from 'date-fns/locale'

// 路由实例
const router = useRouter()
const userStore = useUserStore()

// 组件属性定义
const props = defineProps({
    // 悬赏列表
    wantedList: {
        type: Array,
        default: () => []
    },
    // 加载状态
    loading: {
        type: Boolean,
        default: false
    },
    // 总记录数
    total: {
        type: Number,
        default: 0
    },
    // 当前页码
    pageNum: {
        type: Number,
        default: 1
    },
    // 每页数量
    pageSize: {
        type: Number,
        default: 5
    },
    // 筛选条件
    filter: {
        type: String,
        default: 'all'
    }
})

// 事件定义
const emit = defineEmits(['page-change', 'item-click', 'comment-toggle'])

// 根据筛选条件过滤帖子列表
const filteredWantedList = computed(() => {
    if (!props.wantedList || props.wantedList.length === 0) {
        return []
    }

    // 计算所有滞留项，用于后续排除
    let stagnantIds = new Set()
    if (props.filter === 'unsolved' || props.filter === 'stagnant') {
        const now = new Date()
        const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        const stagnantItems = props.wantedList.filter(item => {
            if (!item.time) return false
            const publishTime = new Date(item.time)
            return publishTime < sevenDaysAgo && item.solved === '未解决'
        })
        stagnantIds = new Set(stagnantItems.map(item => item.id))
    }

    // 根据当前筛选条件过滤
    let result = []
    if (props.filter === 'all') {
        result = props.wantedList
    } else if (props.filter === 'unsolved') {
        // 未解决：严格匹配 '未解决'，排除滞留
        result = props.wantedList.filter(item =>
            item.solved && item.solved === '未解决' && !stagnantIds.has(item.id)
        )
    } else if (props.filter === 'solved') {
        // 已解决：严格匹配 '已解决'
        result = props.wantedList.filter(item =>
            item.solved && item.solved === '已解决'
        )
    } else if (props.filter === 'stagnant') {
        // 滞留：使用已计算的滞留ID
        result = props.wantedList.filter(item => stagnantIds.has(item.id))
    }

    return result
})

// 处理页码变更
const handlePageChange = (page) => {
    emit('page-change', page)
}

// 处理点击悬赏项
const handleItemClick = (id) => {
    router.push(`/wanted/detail/${id}`)
}

// 处理评论显示/隐藏
const handleCommentToggle = (item) => {
    emit('comment-toggle', item)
}

// 关闭悬赏
const closeWanted = (id, event) => {
    event.stopPropagation()
    ElMessageBox.confirm('确定要关闭此悬赏吗？关闭后将不再显示给其他用户', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            const res = await updateHelpAPI({
                id: id,
                solved: '已解决'
            })
            if (res.code === '200') {
                ElMessage.success('悬赏已关闭')
                emit('page-change', props.pageNum) // 重新加载当前页
            } else {
                ElMessage.error(res.msg || '关闭失败')
            }
        } catch (error) {
            console.error('关闭悬赏失败:', error)
            ElMessage.error('关闭失败')
        }
    }).catch(() => { })
}

// 格式化日期
const formatDate = (dateString) => {
    if (!dateString) return '无日期'

    try {
        const date = new Date(dateString)
        return format(date, 'yyyy-MM-dd', { locale: zhCN })
    } catch (error) {
        return dateString
    }
}

// 获取内容预览
const getContentPreview = (content) => {
    if (!content) return ''
    // 去除HTML标签
    const plainText = content.replace(/<[^>]+>/g, '')
    return plainText.length > 100 ? plainText.slice(0, 100) + '...' : plainText
}

// 获取截止日期样式
const getDeadlineStyle = (dateString) => {
    if (!dateString) return {}

    const date = new Date(dateString)
    const now = new Date()
    const diffTime = date.getTime() - now.getTime()
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

    if (diffDays < 0) {
        return { color: '#909399' } // 灰色-已过期
    } else if (diffDays <= 3) {
        return { color: '#F56C6C' } // 红色-即将到期
    } else if (diffDays <= 7) {
        return { color: '#E6A23C' } // 橙色-提示注意
    } else {
        return { color: '#67C23A' } // 绿色-正常
    }
}

// 获取预算价格样式
const getBudgetStyle = (budget) => {
    const price = parseFloat(budget)
    if (isNaN(price)) {
        return {}
    }

    if (price >= 1000) {
        return { color: '#F56C6C', fontWeight: 'bold' } // 红色加粗-高价
    } else if (price >= 500) {
        return { color: '#E6A23C', fontWeight: 'bold' } // 橙色加粗-中高价
    } else if (price >= 100) {
        return { color: '#67C23A' } // 绿色-正常价
    } else {
        return { color: '#909399' } // 灰色-低价
    }
}
</script>

<template>
    <div class="wanted-container">
        <div class="wanted-list">
            <!-- 头部工具栏：悬赏数量统计 -->
            <div class="wanted-header" v-if="!loading && filteredWantedList.length > 0">
                <div class="wanted-count">
                    <span>共找到 <b>{{
                        filter === 'all' ? total : filteredWantedList.length
                            }}</b> 条{{
                                filter === 'all' ? '悬赏' :
                                    filter === 'unsolved' ? '未解决悬赏' :
                                        filter === 'solved' ? '已解决悬赏' :
                                            '滞留悬赏'
                            }}</span>
                    <span>当前显示: {{ (pageNum - 1) * pageSize + 1 }} - {{ Math.min(pageNum * pageSize,
                        filter === 'all' ? total : filteredWantedList.length) }} / {{
                            filter === 'all' ? total : filteredWantedList.length }}</span>
                </div>
            </div>

            <!-- 加载状态 -->
            <div v-if="loading" class="skeleton-container">
                <el-skeleton :count="3" animated>
                    <template #template>
                        <div style="display: flex; margin-bottom: 20px; align-items: flex-start;">
                            <div style="margin-right: 16px;">
                                <el-skeleton-item variant="circle" style="width: 40px; height: 40px;" />
                            </div>
                            <div style="flex: 1;">
                                <el-skeleton-item variant="h3" style="width: 50%; margin-bottom: 12px;" />
                                <el-skeleton-item variant="text" style="width: 30%; margin-bottom: 8px;" />
                                <el-skeleton-item variant="text" style="width: 90%;" />
                            </div>
                        </div>
                    </template>
                </el-skeleton>
            </div>

            <!-- 悬赏列表 -->
            <transition-group name="fade-list" tag="div" class="wanted-items">
                <div v-for="item in filteredWantedList" :key="item.id" class="wanted-item"
                    @click="handleItemClick(item.id)">
                    <div class="wanted-item-content">
                        <img :src="item.avatar || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'"
                            alt="用户头像" class="user-avatar">
                        <div class="wanted-info">
                            <!-- 标题和状态 -->
                            <div class="wanted-header">
                                <h3 class="wanted-title">{{ item.title }}</h3>
                                <el-tag :type="item.solved === '未解决' ? 'danger' : 'success'" class="status-tag"
                                    size="small">
                                    {{ item.solved }}
                                </el-tag>
                            </div>

                            <!-- 内容预览 -->
                            <p class="content-preview">{{ getContentPreview(item.content) }}</p>

                            <!-- 用户信息和时间 -->
                            <div class="wanted-meta">
                                <div class="meta-user">
                                    <span class="meta-item">
                                        <el-icon>
                                            <User />
                                        </el-icon>
                                        {{ item.userName }}
                                    </span>
                                    <span class="meta-item">
                                        <el-icon>
                                            <Timer />
                                        </el-icon>
                                        {{ formatDate(item.time) }}
                                    </span>
                                </div>

                                <div class="meta-price" v-if="item.price">
                                    <span class="price-amount" :style="getBudgetStyle(item.price)">
                                        <el-icon>
                                            <Money />
                                        </el-icon>
                                        ¥{{ item.price }}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- 缩略图 -->
                        <div v-if="item.img" class="wanted-thumbnail">
                            <el-image :src="item.img" alt="悬赏图片" fit="cover" />
                        </div>
                    </div>
                </div>
            </transition-group>

            <!-- 空状态 -->
            <el-empty v-if="!loading && filteredWantedList.length === 0" description="暂无相关悬赏" class="empty-state">
                <template #description>
                    <p>暂时没有{{ filter !== 'all' ? '符合条件的' : '' }}悬赏信息</p>
                </template>
                <el-button type="primary" @click="$emit('page-change', 1)">返回第一页</el-button>
            </el-empty>

            <!-- 分页 -->
            <div class="pagination-container" v-if="!loading && filteredWantedList.length > 0">
                <el-pagination background @current-change="handlePageChange" :current-page="pageNum"
                    :page-size="pageSize" layout="total, prev, pager, next, jumper"
                    :total="filter === 'all' ? total : filteredWantedList.length" :pager-count="5">
                </el-pagination>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.wanted-container {
    background-color: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
    padding: 20px;
    margin-bottom: 24px;
}

.wanted-list {
    width: 100%;
    min-height: 400px;
    position: relative;
    display: flex;
    flex-direction: column;
}

.wanted-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #f0f0f0;
}

.wanted-count {
    display: flex;
    gap: 20px;
    color: #606266;
    font-size: 14px;
    margin: 20px;

    b {
        color: #409eff;
        font-weight: 600;
    }
}

.skeleton-container {
    padding: 20px 0;
    min-height: 300px;
}

.wanted-items {
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-bottom: 20px;
}

.wanted-item {
    background-color: #fff;
    margin-bottom: 20px;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    border: 1px solid #f0f0f0;
    transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
    cursor: pointer;

    &:hover {
        transform: translateY(-3px);
        box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
    }
}

.wanted-item-content {
    display: flex;
    padding: 16px;
    gap: 16px;
    position: relative;

    @media (max-width: 768px) {
        flex-direction: column;
    }
}

.user-avatar {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #f0f2f5;
    flex-shrink: 0;
}

.wanted-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    min-width: 0; // 确保弹性项可以收缩
}

.wanted-header {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
    padding-bottom: 0;
    border-bottom: none;
    gap: 10px;
    flex-wrap: wrap;

    .wanted-title {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        flex: 1;
        min-width: 0;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }

    .status-tag {
        flex-shrink: 0;
        font-size: 12px;
    }
}

.content-preview {
    margin-bottom: 12px;
    color: var(--el-text-color-regular);
    font-size: 14px;
    line-height: 1.6;
    flex: 1;
    overflow: hidden;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

.wanted-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-top: 1px solid #f5f5f5;
    padding-top: 12px;
    margin-top: auto;

    .meta-user {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
    }

    .meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
        color: var(--el-text-color-secondary);
        font-size: 13px;

        .el-icon {
            font-size: 14px;
        }
    }

    .meta-price {
        .price-amount {
            font-size: 16px;
            font-weight: 600;
            color: #f56c6c;
            display: flex;
            align-items: center;
            gap: 4px;

            .el-icon {
                font-size: 16px;
            }
        }
    }
}

.wanted-thumbnail {
    width: 120px;
    height: 120px;
    flex-shrink: 0;
    border-radius: 6px;
    overflow: hidden;

    .el-image {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    @media (max-width: 768px) {
        width: 100%;
        height: 180px;
        margin-top: 12px;
    }
}

.pagination-container {
    //!
    margin: 40px;
    padding-top: 20px;
    border-top: 1px solid #ebeef5;
    display: flex;
    justify-content: center;
}

.empty-state {
    padding: 60px 0;
    flex-grow: 1;
    display: flex;
    justify-content: center;
    align-items: center;
}

/* 列表过渡动画 */
.fade-list-enter-active,
.fade-list-leave-active {
    transition: all 0.4s ease;
}

.fade-list-enter-from {
    opacity: 0;
    transform: translateY(20px);
}

.fade-list-leave-to {
    opacity: 0;
    transform: translateX(-20px);
}

.fade-list-move {
    transition: transform 0.4s ease;
}
</style>