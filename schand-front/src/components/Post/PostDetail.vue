<script setup>
/**
 * 帖子详情页组件
 * 展示帖子详细内容和评论
 */
import { getPostsByIdAPI, updatePostsCountAPI } from '@/api/postAPI'
import { getUserByIdAPI } from '@/api/userAPI'
import Comment from "@/components/Comment.vue"
import { ArrowLeft, Share, View } from '@element-plus/icons-vue'
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// 路由实例
const route = useRoute()
const router = useRouter()

// 响应式数据
const id = ref(route.params.id)
const post = ref({})
const isLoading = ref(true)
const authorAvatar = ref('')

// 创建分享链接
const shareLink = computed(() => {
  const baseUrl = window.location.origin
  return `${baseUrl}/posts/detail/${id.value}`
})

// 生命周期钩子
onMounted(() => {
  // 初始化详情页
  initDetail()
})

// 初始化详情页
const initDetail = async () => {
  if (!id.value) {
    ElMessage.error('缺少帖子ID')
    router.push('/community')
    return
  }

  // 更新阅读数并加载详情
  await updateReadCount()
}

// 更新阅读数并加载帖子详情
const updateReadCount = async () => {
  try {
    await updatePostsCountAPI(id.value)
    loadPostDetail()
  } catch (error) {
    console.error('更新阅读数失败:', error)
    ElMessage.error('更新阅读数失败')
    isLoading.value = false
  }
}

// 加载帖子详情
const loadPostDetail = async () => {
  isLoading.value = true
  try {
    const res = await getPostsByIdAPI(id.value)
    if (res.code === '200') {
      post.value = res.data || {}
      // 设置页面标题
      document.title = `${post.value.title || '帖子详情'} - 社区`

      // 获取作者头像
      if (post.value.userId) {
        await loadAuthorAvatar(post.value.userId)
      }
    } else {
      ElMessage.error(res.msg || '获取帖子详情失败')
    }
  } catch (error) {
    console.error('获取帖子详情失败:', error)
    ElMessage.error('获取帖子详情失败')
  } finally {
    isLoading.value = false
  }
}

// 获取作者头像
const loadAuthorAvatar = async (userId) => {
  try {
    const res = await getUserByIdAPI(userId)
    if (res.code === '200' && res.data && res.data.avatar) {
      authorAvatar.value = res.data.avatar
    }
  } catch (error) {
    console.error('获取作者头像失败:', error)
  }
}

// 返回列表页
const goBack = () => {
  router.push('/community')
}

// 分享帖子
const sharePost = async () => {
  try {
    await navigator.clipboard.writeText(shareLink.value)
    ElMessage.success('链接已复制到剪贴板')
  } catch (error) {
    console.error('复制链接失败:', error)
    ElMessage.warning('复制链接失败，请手动复制')
  }
}

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return ''

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
</script>

<template>
  <div class="post-detail-container">
    <!-- 顶部导航栏 -->
    <el-card class="detail-card header-card" shadow="hover">
      <div class="detail-nav">
        <el-button @click="goBack" text class="back-btn">
          <el-icon>
            <ArrowLeft />
          </el-icon>
          返回帖子列表
        </el-button>
        <div class="page-title">帖子详情</div>
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
    <template v-else-if="post.id">
      <!-- 帖子信息卡片 -->
      <el-card class="detail-card" shadow="hover">
        <div class="detail-title-section">
          <h1 class="detail-title">{{ post.title }}</h1>
          <el-tag v-if="post.circle" size="large" effect="plain" type="info">{{ post.circle }}</el-tag>
        </div>

        <div class="detail-meta">
          <div class="publisher-info">
            <el-avatar :size="40" :src="authorAvatar" class="author-avatar">
              {{ post.userName ? post.userName.charAt(0).toUpperCase() : '?' }}
            </el-avatar>
            <div class="publisher-meta">
              <div class="publisher-name">{{ post.userName }}</div>
              <div class="publish-time">发布于：{{ formatDate(post.time) }}</div>
            </div>
          </div>

          <div class="meta-tags">
            <div class="meta-tag">
              <el-icon>
                <View />
              </el-icon>
              <span>{{ post.readCount || 0 }} 阅读</span>
            </div>
            <div class="meta-tag share-tag" @click="sharePost">
              <el-icon>
                <Share />
              </el-icon>
              <span>分享</span>
            </div>
          </div>
        </div>

        <div class="post-content">
          <!-- 帖子图片 -->
          <div v-if="post.img" class="content-image">
            <el-image :src="post.img" fit="contain" :preview-src-list="[post.img]" class="main-image" loading="lazy" />
          </div>

          <!-- 帖子正文 -->
          <div class="content-text" v-html="post.content"></div>
        </div>
      </el-card>

      <!-- 评论区卡片 -->
      <el-card class="detail-card comment-card" shadow="hover">
        <div class="comment-container">
          <Comment :fid="id" module="posts" theme="light" placeholder="写下你的评论..." />
        </div>
      </el-card>
    </template>

    <!-- 无数据展示 -->
    <el-empty v-else description="找不到该帖子信息" :image-size="200">
      <el-button type="primary" @click="goBack">返回列表</el-button>
    </el-empty>
  </div>
</template>

<style lang="scss" scoped>
.post-detail-container {
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

.header-card {
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

    .author-avatar {
      background-color: var(--el-color-primary);
      color: #fff;
      font-weight: bold;
    }

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

      &.share-tag {
        cursor: pointer;
        color: var(--el-color-primary);
        background-color: rgba(64, 158, 255, 0.1);
        transition: all 0.3s ease;

        &:hover {
          background-color: rgba(64, 158, 255, 0.2);
          transform: scale(1.05);
        }
      }
    }
  }
}

.post-content {
  margin-bottom: 20px;

  .content-text {
    line-height: 1.7;
    color: #303133;
    word-break: break-word;
    font-size: 15px;

    ::v-deep(img) {
      max-width: 100%;
      height: auto;
      border-radius: 8px;
      margin: 12px 0;
    }

    ::v-deep(p) {
      margin: 12px 0;
    }

    ::v-deep(h1, h2, h3, h4, h5, h6) {
      margin-top: 24px;
      margin-bottom: 16px;
      font-weight: 600;
      line-height: 1.4;
    }

    ::v-deep(blockquote) {
      border-left: 4px solid var(--el-border-color);
      padding: 12px 16px;
      background-color: var(--el-fill-color-light);
      color: var(--el-text-color-regular);
      margin: 16px 0;
    }

    ::v-deep(a) {
      color: var(--el-color-primary);
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }

    ::v-deep(pre, code) {
      background-color: var(--el-fill-color-light);
      border-radius: 4px;
      font-family: monospace;
    }

    ::v-deep(pre) {
      padding: 16px;
      overflow-x: auto;
      margin: 16px 0;
    }

    ::v-deep(code) {
      padding: 2px 6px;
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

.comment-container {
  padding: 8px 0;
  opacity: 1;
}
</style>