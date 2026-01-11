<script setup>
/**
 * 社区侧边栏面板组件
 * 展示圈子列表和推荐链接
 */
import { defineProps, defineEmits, ref, onMounted, computed } from 'vue'
import { Star, Bell, Sunny, Link, Grid } from '@element-plus/icons-vue'
import { getNewsList } from '@/api/newsAPI'

// 组件属性定义
const props = defineProps({
  // 圈子列表
  circles: {
    type: Array,
    default: () => []
  },
  // 加载状态
  loading: {
    type: Boolean,
    default: false
  },
  // 当前选中的圈子
  activeCircle: {
    type: String,
    default: '全部'
  }
})

// 事件定义
const emit = defineEmits(['circle-click'])

// 热点新闻数据
const news = ref({
  weibo: [],
  zhihu: [],
  wallstreetcn: []
})

// 新闻加载状态
const newsLoading = ref({
  weibo: true,
  zhihu: true,
  wallstreetcn: true
})

// 当前激活的新闻源
const activeNewsSource = ref('weibo')

// 加载热点新闻
const loadNews = async (platform) => {
  newsLoading.value[platform] = true
  try {
    const res = await getNewsList(platform)
    console.log(`获取${platform}新闻数据成功:`, res)

    // 从响应中获取数据
    if (res && res.items && res.items.length > 0) {
      news.value[platform] = res.items
    } else if (res && res.data && Array.isArray(res.data)) {
      news.value[platform] = res.data
    } else if (res && res.data && res.data.items) {
      news.value[platform] = res.data.items
    } else if (res && res.data && res.data.cards && res.data.cards[0] && res.data.cards[0].card_group) {
      news.value[platform] = res.data.cards[0].card_group
    } else {
      console.log(`${platform}数据结构异常，使用模拟数据`)
    }
  } catch (error) {
    console.error(`获取${platform}新闻数据失败:`, error)
  } finally {
    newsLoading.value[platform] = false
  }
}

// 处理切换新闻源
const handleNewsSourceChange = (source) => {
  activeNewsSource.value = source
}

// 当前显示的新闻
const currentNews = computed(() => {
  const platformData = news.value[activeNewsSource.value] || []

  return platformData.map(item => {
    // 统一新闻项数据格式
    return {
      title: item.title || item.desc || '热门资讯',
      url: item.url || item.scheme || item.link || item.uri || item.mobileUrl || '#',
      source: activeNewsSource.value,
      icon: getPlatformIcon(activeNewsSource.value)
    }
  })
})

// 获取平台图标
const getPlatformIcon = (platform) => {
  switch (platform) {
    case 'weibo':
      return 'https://weibo.com/favicon.ico'
    case 'zhihu':
      return 'https://static.zhihu.com/heifetz/favicon.ico'
    case 'wallstreetcn':
      return 'https://static.wscn.net/wscn/_static/favicon.png'
    default:
      return ''
  }
}

// 当前新闻源是否加载中
const isCurrentNewsLoading = computed(() => {
  return newsLoading.value[activeNewsSource.value]
})

onMounted(() => {
  // 加载各平台热点新闻
  loadNews('weibo')
  loadNews('zhihu')
  loadNews('wallstreetcn')
})

// 处理圈子点击
const handleCircleClick = (circleName) => {
  emit('circle-click', circleName)
}
</script>

<template>
  <div class="sidebar">
    <!-- 圈子卡片 -->
    <el-card class="circle-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>圈子分类</span>
        </div>
      </template>

      <!-- 加载状态 -->
      <el-skeleton v-if="loading" :rows="5" animated />

      <!-- 圈子列表 -->
      <div v-else class="circle-list">
        <!-- "全部"选项 -->
        <div class="circle-item" :class="{ active: activeCircle === '全部' }" @click="handleCircleClick('全部')">
          <div class="circle-avatar all">
            <el-icon>
              <Grid />
            </el-icon>
          </div>
          <span class="circle-name">全部</span>
        </div>

        <!-- 具体圈子选项 -->
        <div v-for="circle in circles" :key="circle.id" class="circle-item"
          :class="{ active: activeCircle === circle.name }" @click="handleCircleClick(circle.name)">
          <el-avatar :size="32" class="circle-avatar" :src="circle.img">
            {{ circle.name ? circle.name.charAt(0) : '?' }}
          </el-avatar>
          <span class="circle-name">{{ circle.name }}</span>
        </div>
      </div>
    </el-card>

    <!-- 热点新闻 -->
    <el-card class="recommend-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>热点新闻</span>
          <div class="news-tabs">
            <el-tag :type="activeNewsSource === 'weibo' ? 'danger' : 'info'" effect="plain" size="small"
              class="news-tab-item" @click="handleNewsSourceChange('weibo')">
              微博
            </el-tag>
            <el-tag :type="activeNewsSource === 'zhihu' ? 'danger' : 'info'" effect="plain" size="small"
              class="news-tab-item" @click="handleNewsSourceChange('zhihu')">
              知乎
            </el-tag>
            <el-tag :type="activeNewsSource === 'wallstreetcn' ? 'danger' : 'info'" effect="plain" size="small"
              class="news-tab-item" @click="handleNewsSourceChange('wallstreetcn')">
              华尔街
            </el-tag>
          </div>
        </div>
      </template>

      <!-- 新闻加载状态 -->
      <el-skeleton v-if="isCurrentNewsLoading" :rows="5" animated />

      <!-- 热点新闻列表 -->
      <div v-else class="recommend-links">
        <a v-for="(item, index) in currentNews" :key="index" :href="item.url" target="_blank" rel="noopener noreferrer"
          class="news-link" :title="item.title">
          <div class="news-icon">
            <img v-if="item.icon" :src="item.icon" alt="logo" class="source-icon" />
            <el-icon v-else-if="activeNewsSource === 'weibo'" class="platform-icon weibo-icon">
              <span class="custom-icon">微</span>
            </el-icon>
            <el-icon v-else-if="activeNewsSource === 'zhihu'" class="platform-icon zhihu-icon">
              <span class="custom-icon">知</span>
            </el-icon>
            <el-icon v-else-if="activeNewsSource === 'wallstreetcn'" class="platform-icon wallstreet-icon">
              <span class="custom-icon">华</span>
            </el-icon>
            <el-icon v-else>
              <Sunny />
            </el-icon>
          </div>
          <span class="news-title" :title="item.title">{{ item.title }}</span>
          <el-icon class="external-icon">
            <Link />
          </el-icon>
        </a>

        <!-- 没有新闻时显示空状态 -->
        <el-empty v-if="currentNews.length === 0" description="暂无热点新闻" :image-size="50" />
      </div>
    </el-card>
  </div>
</template>

<style lang="scss" scoped>
.sidebar {
  width: 260px;
  flex-shrink: 0;

  @media (max-width: 768px) {
    width: 100%;
    margin-bottom: 20px;
  }

  .circle-card,
  .recommend-card {
    margin-bottom: 20px;
    border-radius: 12px;
    transition: transform 0.3s;

    &:hover {
      transform: translateY(-3px);
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 16px;
    font-weight: 600;

    .news-tabs {
      display: flex;
      gap: 8px;

      .news-tab-item {
        cursor: pointer;
        transition: all 0.2s;

        &:hover {
          transform: translateY(-2px);
        }
      }
    }
  }

  .circle-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
    max-height: 320px;
    overflow-y: auto;

    &::-webkit-scrollbar {
      width: 4px;
    }

    &::-webkit-scrollbar-thumb {
      background-color: var(--el-border-color-lighter);
      border-radius: 4px;
    }

    .circle-item {
      display: flex;
      align-items: center;
      padding: 8px;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.2s ease;

      &:hover {
        background-color: var(--el-fill-color-light);
      }

      &.active {
        background-color: var(--el-color-primary-light-9);
        color: var(--el-color-primary);
      }

      .circle-avatar {
        background-color: var(--el-color-primary);
        color: #fff;
        margin-right: 12px;

        &.all {
          width: 32px;
          height: 32px;
          border-radius: 50%;
          background-color: var(--el-color-primary-light-3);
          display: flex;
          align-items: center;
          justify-content: center;
          margin-right: 12px;
          color: #fff;
        }
      }

      .circle-name {
        font-size: 14px;
        color: var(--el-text-color-primary);
      }
    }
  }

  .recommend-links {
    display: flex;
    flex-direction: column;
    gap: 12px;

    .news-link {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 14px;
      padding: 8px;
      border-radius: 6px;
      transition: all 0.2s ease;
      color: var(--el-text-color-primary);
      text-decoration: none;
      position: relative;

      &:hover {
        background-color: var(--el-fill-color-light);
        color: var(--el-color-primary);
      }

      .news-icon {
        width: 16px;
        height: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;

        .source-icon {
          width: 16px;
          height: 16px;
          object-fit: contain;
        }

        .platform-icon {
          font-size: 12px;
          height: 16px;
          width: 16px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 2px;

          &.weibo-icon {
            background-color: #e6162d;
            color: white;
          }

          &.zhihu-icon {
            background-color: #0084ff;
            color: white;
          }

          &.wallstreet-icon {
            background-color: #2a2a2a;
            color: white;
          }

          .custom-icon {
            font-size: 10px;
            line-height: 1;
            font-weight: bold;
          }
        }

        .el-icon {
          font-size: 16px;
          color: var(--el-color-danger);
        }
      }

      .news-title {
        flex: 1;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .external-icon {
        font-size: 14px;
        color: var(--el-text-color-secondary);
        margin-left: 4px;
      }
    }
  }
}
</style>