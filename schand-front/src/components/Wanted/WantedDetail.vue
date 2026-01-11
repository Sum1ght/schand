<script setup>
/**
 * 悬赏详情页组件
 * 仅用于展示特定悬赏的详细信息
 */
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Timer, Money } from '@element-plus/icons-vue'
import { getHelpByIdAPI } from '@/api/wantedAPI'
import { getUserByIdAPI } from '@/api/userAPI'
import Comment from "@/components/Comment.vue"

// 路由实例
const route = useRoute()
const router = useRouter()

// 悬赏ID
const wantedId = ref(route.params.id)

// 响应式数据
const wantedInfo = ref(null)
const isLoading = ref(false)
const authorAvatar = ref('')

// 生命周期钩子
onMounted(() => {
    fetchWantedDetail()
})

// 获取悬赏详情
const fetchWantedDetail = async () => {
    if (!wantedId.value) return

    isLoading.value = true

    try {
        const res = await getHelpByIdAPI(wantedId.value)
        if (res.code === '200') {
            wantedInfo.value = res.data
            console.log("悬赏详情数据:", wantedInfo.value)

            // 如果没有用户信息，获取用户信息
            if (wantedInfo.value.userId && (!wantedInfo.value.userName || !wantedInfo.value.avatar)) {
                await loadAuthorInfo(wantedInfo.value.userId)
            } else {
                authorAvatar.value = wantedInfo.value.avatar
            }
        } else {
            ElMessage.error(res.msg || '获取悬赏详情失败')
        }
    } catch (error) {
        console.error('获取悬赏详情失败:', error)
        ElMessage.error('获取悬赏详情失败')
    } finally {
        isLoading.value = false
    }
}

// 获取作者信息（头像和用户名）
const loadAuthorInfo = async (userId) => {
    try {
        const res = await getUserByIdAPI(userId)
        if (res.code === '200' && res.data) {
            // 更新头像
            if (res.data.avatar) {
                authorAvatar.value = res.data.avatar
            }

            // 更新用户名（如果当前为空）
            if (res.data.username && (!wantedInfo.value.userName || wantedInfo.value.userName === '')) {
                wantedInfo.value.userName = res.data.username
            } else if (res.data.name && (!wantedInfo.value.userName || wantedInfo.value.userName === '')) {
                wantedInfo.value.userName = res.data.name
            }

            console.log("获取到的用户信息:", res.data)
        }
    } catch (error) {
        console.error('获取作者信息失败:', error)
    }
}

// 返回悬赏列表
const goBack = () => {
    router.push('/wanted')
}

// 格式化日期
const formatDate = (dateString) => {
    if (!dateString) return '无截止日期'

    // 使用本地化日期格式
    try {
        const date = new Date(dateString)
        return date.toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        })
    } catch (error) {
        return dateString
    }
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

// 获取悬赏状态类型
const getStatusType = (status) => {
    return status === '已解决' ? 'success' : 'danger'
}
</script>

<template>
    <div class="wanted-detail-container">
        <!-- 顶部导航栏 -->
        <el-card class="detail-card detail-header-card" shadow="hover">
            <div class="detail-nav">
                <el-button @click="goBack" text class="back-btn">
                    <el-icon>
                        <ArrowLeft />
                    </el-icon>
                    返回悬赏列表
                </el-button>
                <div class="page-title">悬赏详情</div>
            </div>
        </el-card>

        <!-- 加载中 -->
        <div v-if="isLoading" class="loading-container">
            <el-skeleton animated>
                <template #template>
                    <div style="padding: 20px;">
                        <el-skeleton-item variant="h1" style="width: 50%" />
                        <div style="display: flex; align-items: center; margin: 20px 0;">
                            <el-skeleton-item variant="circle" style="margin-right: 16px; width: 40px; height: 40px;" />
                            <el-skeleton-item variant="text" style="width: 30%" />
                        </div>
                        <el-skeleton-item variant="text" style="width: 100%; margin-bottom: 16px" />
                        <el-skeleton-item variant="text" style="width: 100%; margin-bottom: 16px" />
                        <el-skeleton-item variant="text" style="width: 90%; margin-bottom: 16px" />
                    </div>
                </template>
            </el-skeleton>
        </div>

        <!-- 主内容 -->
        <template v-else-if="wantedInfo">
            <!-- 悬赏信息卡片 -->
            <el-card class="detail-card" shadow="hover">
                <div class="detail-title-section">
                    <h1 class="detail-title">{{ wantedInfo.title }}</h1>
                    <el-tag :type="getStatusType(wantedInfo.solved)" effect="dark" size="large">
                        {{ wantedInfo.solved }}
                    </el-tag>
                </div>

                <div class="detail-meta">
                    <div class="publisher-info">
                        <el-avatar :src="authorAvatar || wantedInfo.avatar || ''" :size="40">
                            {{ wantedInfo.userName ? wantedInfo.userName.charAt(0).toUpperCase() : '?' }}
                        </el-avatar>
                        <div class="publisher-meta">
                            <div class="publisher-name">{{ wantedInfo.userName || '未知用户' }}</div>
                            <div class="publish-time">发布于：{{ formatDate(wantedInfo.time) }}</div>
                        </div>
                    </div>

                    <div class="meta-tags">
                        <div v-if="wantedInfo.price" class="meta-tag price-tag">
                            <el-icon>
                                <Money />
                            </el-icon>
                            <span>¥{{ wantedInfo.price }}</span>
                        </div>
                        <div v-if="wantedInfo.deadline" class="meta-tag" :style="getDeadlineStyle(wantedInfo.deadline)">
                            <el-icon>
                                <Timer />
                            </el-icon>
                            <span>{{ formatDate(wantedInfo.deadline) }}</span>
                        </div>
                    </div>
                </div>

                <div class="detail-content">
                    <div class="content-text" v-html="wantedInfo.content"></div>

                    <div v-if="wantedInfo.img" class="content-image">
                        <el-image :src="wantedInfo.img" :preview-src-list="[wantedInfo.img]" fit="contain"
                            class="main-image"></el-image>
                    </div>
                </div>
            </el-card>

            <!-- 评论区卡片 -->
            <el-card class="detail-card comment-card" shadow="hover">
                <div class="comment-container">
                    <Comment :fid="Number(wantedId)" module="help" theme="light" placeholder="留下你的回复与建议..." />
                </div>
            </el-card>
        </template>

        <!-- 无数据展示 -->
        <el-empty v-else description="找不到该悬赏信息" :image-size="200">
            <el-button type="primary" @click="goBack">返回列表</el-button>
        </el-empty>
    </div>
</template>

<style lang="scss" scoped>
.wanted-detail-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;

    @media (max-width: 768px) {
        padding: 16px 12px;
    }
}

.detail-card {
    border-radius: 8px;
    margin-bottom: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05) !important;
    background-color: #fff;
    transition: transform 0.3s, box-shadow 0.3s;

    &:hover {
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1) !important;
    }
}

.detail-header-card {
    background-color: #f7f9fc;
}

.detail-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .back-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #606266;
        font-weight: 500;
        font-size: 15px;

        &:hover {
            color: var(--el-color-primary);
        }
    }

    .page-title {
        font-size: 20px;
        font-weight: 600;
        color: #303133;
    }
}

.loading-container {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    margin-bottom: 24px;
}

.detail-title-section {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 24px;
    padding-bottom: 16px;
    border-bottom: 1px solid #f0f0f0;

    .detail-title {
        margin: 0;
        font-size: 24px;
        font-weight: 600;
        color: #303133;
        flex: 1;
        margin-right: 16px;
        line-height: 1.4;

        @media (max-width: 768px) {
            font-size: 20px;
        }
    }
}

.detail-meta {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    margin-bottom: 24px;
    background-color: #f9f9f9;
    padding: 16px;
    border-radius: 8px;

    @media (max-width: 768px) {
        flex-direction: column;
        gap: 16px;
    }

    .publisher-info {
        display: flex;
        align-items: center;
        gap: 12px;

        .publisher-meta {
            display: flex;
            flex-direction: column;

            .publisher-name {
                font-weight: 500;
                color: #303133;
                font-size: 15px;
            }

            .publish-time {
                font-size: 13px;
                color: #909399;
                margin-top: 4px;
            }
        }
    }

    .meta-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        align-items: center;

        .meta-tag {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 14px;
            color: #606266;
            background-color: rgba(235, 237, 240, 0.5);
            padding: 4px 12px;
            border-radius: 16px;

            &.price-tag {
                color: #ff6b00;
                font-weight: 500;
                background-color: rgba(255, 107, 0, 0.1);
            }
        }
    }
}

.detail-content {
    margin-bottom: 20px;

    .content-text {
        line-height: 1.7;
        color: #303133;
        word-break: break-word;
        font-size: 15px;

        ::v-deep(img) {
            max-width: 100%;
            height: auto;
            border-radius: 4px;
            margin: 8px 0;
        }

        ::v-deep(p) {
            margin: 12px 0;
        }

        ::v-deep(a) {
            color: var(--el-color-primary);
            text-decoration: none;

            &:hover {
                text-decoration: underline;
            }
        }

        ::v-deep(ul, ol) {
            padding-left: 24px;
            margin: 12px 0;
        }
    }

    .content-image {
        text-align: center;
        margin: 24px auto;

        .main-image {
            max-width: 100%;
            max-height: 500px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

            @media (max-width: 768px) {
                max-height: 300px;
            }
        }
    }
}

.comment-card {
    background-color: #fcfcfc;
}

.comment-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;

    h3 {
        margin: 0;
        font-weight: 500;
        color: #303133;
        font-size: 18px;
    }
}

.comment-container {
    padding: 8px 0;
    opacity: 1;
}
</style>