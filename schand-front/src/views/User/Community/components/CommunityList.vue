<script setup>
/**
 * 帖子面板组件
 * 显示帖子列表和标签切换功能
 */
import { defineProps, defineEmits, computed } from 'vue'
import { Sunny, Clock, View, User } from '@element-plus/icons-vue'

// 组件属性定义
const props = defineProps({
  // 所有帖子
  posts: {
    type: Array,
    default: () => []
  },
  // 加载状态
  loading: {
    type: Boolean,
    default: false
  },
  // 激活的标签
  activeTab: {
    type: String,
    default: 'new'
  },
  // 视图模式
  viewMode: {
    type: String,
    default: 'grid'
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
    default: 10
  }
})

// 事件定义
const emit = defineEmits(['tab-change', 'view-mode-change', 'post-click', 'page-change'])

// 按最新发布时间排序的帖子
const newPosts = computed(() => {
  if (!props.posts || props.posts.length === 0) return []

  // 复制数组以避免修改原始数据
  return [...props.posts].sort((a, b) => {
    // 将时间字符串转换为时间戳进行比较
    const timeA = new Date(a.time).getTime()
    const timeB = new Date(b.time).getTime()
    // 降序排列，最新的在前面
    return timeB - timeA
  })
})

// 按阅读量排序的帖子
const hotPosts = computed(() => {
  if (!props.posts || props.posts.length === 0) return []

  // 复制数组以避免修改原始数据
  return [...props.posts].sort((a, b) => {
    // 按阅读数降序排列
    return b.readCount - a.readCount
  })
})

// 当前显示的帖子列表
const displayPosts = computed(() => {
  return props.activeTab === 'new' ? newPosts.value : hotPosts.value
})

// 处理标签切换
const handleTabChange = (tab) => {
  emit('tab-change', tab)
}

// 处理视图模式切换
const toggleViewMode = () => {
  const newMode = props.viewMode === 'grid' ? 'list' : 'grid'
  emit('view-mode-change', newMode)
}

// 处理帖子点击
const handlePostClick = (postId) => {
  emit('post-click', postId)
}

// 添加处理页码变更的方法
const handlePageChange = (page) => {
  emit('page-change', page)
}
</script>

<template>
  <div class="content-area">
    <!-- 帖子区域 -->
    <el-card class="post-card" shadow="hover">
      <template #header>
        <div class="card-header with-tabs">
          <div class="header-tabs">
            <div class="tab-item" :class="{ active: activeTab === 'new' }" @click="handleTabChange('new')">
              <el-icon>
                <Clock />
              </el-icon>
              看个新鲜
            </div>
            <div class="tab-item" :class="{ active: activeTab === 'hot' }" @click="handleTabChange('hot')">
              <el-icon>
                <Sunny />
              </el-icon>
              看个热闹
            </div>
          </div>

          <div class="header-actions">
            <el-button @click="toggleViewMode" :icon="viewMode === 'grid' ? 'Menu' : 'Grid'" text circle />
          </div>
        </div>
      </template>

      <!-- 加载骨架屏 -->
      <div v-if="loading" class="skeleton-container">
        <el-skeleton :count="3" animated>
          <template #template>
            <div style="display: flex; margin-bottom: 20px; align-items: flex-start;">
              <div style="margin-right: 16px;">
                <el-skeleton-item variant="image" style="width: 120px; height: 120px;" />
              </div>
              <div style="flex: 1;">
                <el-skeleton-item variant="h3" style="width: 70%; margin-bottom: 12px;" />
                <el-skeleton-item variant="text" style="width: 50%; margin-bottom: 8px;" />
                <el-skeleton-item variant="text" style="width: 90%;" />
              </div>
            </div>
          </template>
        </el-skeleton>
      </div>

      <!-- 帖子列表 -->
      <transition name="fade-transform" mode="out-in">
        <div :key="activeTab + (viewMode === 'grid' ? '-grid' : '-list')" v-if="!loading" class="post-list">
          <div v-for="post in displayPosts" :key="post.id" class="post-item"
            :class="{ 'list-mode': viewMode === 'list' }" @click="handlePostClick(post.id)">
            <div v-if="post.img" class="post-image">
              <el-image :src="post.img" fit="cover" loading="lazy" />
            </div>

            <div class="post-info">
              <div class="post-title">{{ post.title }}</div>
              <div class="post-description" v-if="post.descr">{{ post.descr }}</div>

              <div class="post-meta">
                <el-tag size="small" type="info" effect="plain" class="post-tag">
                  {{ post.circle }}
                </el-tag>
                <span class="post-author">
                  <el-icon>
                    <User />
                  </el-icon>
                  {{ post.userName }}
                </span>
                <span class="post-time">
                  <el-icon>
                    <Clock />
                  </el-icon>
                  {{ post.time }}</span>
                <span class="post-views">
                  <el-icon>
                    <View />
                  </el-icon>
                  {{ post.readCount }}
                </span>
              </div>
            </div>
          </div>

          <el-empty v-if="displayPosts.length === 0" description="暂无帖子"></el-empty>
        </div>
      </transition>

      <!-- 分页组件 -->
      <div class="pagination-container" v-if="!loading && displayPosts.length > 0 && total > 0">
        <el-pagination background @current-change="handlePageChange" :current-page="pageNum" :page-size="pageSize"
          layout="total, prev, pager, next, jumper" :total="total">
        </el-pagination>
      </div>
    </el-card>
  </div>
</template>

<style lang="scss" scoped>
.content-area {
  flex: 1;

  .post-card {
    border-radius: 12px;

    .card-header.with-tabs {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .header-tabs {
        display: flex;
        gap: 24px;

        .tab-item {
          display: flex;
          align-items: center;
          gap: 6px;
          font-size: 16px;
          font-weight: 500;
          color: var(--el-text-color-regular);
          cursor: pointer;
          padding: 4px 0;
          position: relative;

          &::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 0;
            height: 3px;
            background-color: var(--el-color-primary);
            transition: width 0.3s ease;
          }

          &.active {
            color: var(--el-color-primary);

            &::after {
              width: 100%;
            }
          }

          &:hover:not(.active) {
            color: var(--el-text-color-primary);
          }
        }
      }

      .header-actions {
        display: flex;
        align-items: center;
        gap: 8px;
      }
    }
  }

  .post-list {
    display: flex;
    flex-direction: column;
    gap: 20px;

    .post-item {
      display: flex;
      cursor: pointer;
      border-radius: 8px;
      padding: 12px;
      transition: all 0.3s ease;

      &:hover {
        background-color: var(--el-fill-color-light);
        transform: translateY(-3px);
        box-shadow: var(--el-box-shadow-light);
      }

      .post-image {
        width: 120px;
        height: 120px;
        border-radius: 8px;
        margin-right: 16px;
        overflow: hidden;
        flex-shrink: 0;

        .el-image {
          width: 100%;
          height: 100%;
          object-fit: cover;
        }
      }

      .post-info {
        flex: 1;
        display: flex;
        flex-direction: column;
      }

      .post-title {
        font-size: 18px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        margin-bottom: 8px;
        /* 设置单行文本溢出省略 */
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .post-description {
        font-size: 14px;
        color: var(--el-text-color-regular);
        margin-bottom: 12px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
      }

      .post-meta {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 12px;
        color: var(--el-text-color-secondary);

        .post-tag {
          font-size: 12px;
        }

        .post-author {
          font-weight: 500;
        }

        .post-views {
          display: flex;
          align-items: center;
          gap: 4px;
        }
      }

      &.list-mode {
        flex-direction: column;

        .post-image {
          width: 100%;
          height: 200px;
          margin-right: 0;
          margin-bottom: 12px;
        }
      }
    }
  }
}

/* 动画过渡效果 */
.fade-transform-enter-active,
.fade-transform-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-transform-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.fade-transform-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.skeleton-container {
  padding: 12px;
}

/* 分页容器样式 */
.pagination-container {
  margin-top: 24px;
  display: flex;
  justify-content: center;

  .el-pagination {
    padding: 0;
    margin: 0;
    font-weight: normal;

    button:not(:disabled) {
      background-color: var(--el-color-white);
      color: var(--el-text-color-primary);

      &:hover {
        color: var(--el-color-primary);
      }
    }

    .el-pager li:not(.is-disabled).is-active {
      background-color: var(--el-color-primary);
      color: var(--el-color-white);
    }
  }
}
</style>