<script setup>
/**
 * 社区主页组件
 * 作为社区模块的入口，提供内容分发和整体布局
 */
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getPostsFrontPageAPI } from '@/api/postAPI'
import { getAllCirclesAPI } from '@/api/circleAPI'

// 引入子组件
import CommunityHeader from './components/CommunityHeader.vue'
import CommunitySiderBar from './components/CommunitySiderBar.vue'
import CommunityList from './components/CommunityList.vue'

// 路由实例
const router = useRouter()
const route = useRoute()

// 响应式数据
const circles = ref([]) // 圈子列表
const posts = ref([]) // 所有帖子
const total = ref(0) // 帖子总数
const isLoading = ref(false) // 加载状态
const activeTab = ref('new') // 激活的标签页
const viewMode = ref('grid') // 'grid' 或 'list'
const activeCircle = ref('全部') // 当前选择的圈子
const searchKeyword = ref('') // 搜索关键词

// 页面参数
const params = reactive({
  pageNum: 1,
  pageSize: 10 // 每页加载数量
})

// 计算属性：过滤后的帖子
const filteredPosts = computed(() => {
  // 如果没有搜索关键词，返回所有帖子
  if (!searchKeyword.value.trim()) {
    return posts.value
  }

  // 转换为小写进行不区分大小写的搜索
  const keyword = searchKeyword.value.toLowerCase()

  // 根据标题和用户名过滤帖子
  return posts.value.filter(post => {
    const titleMatch = post.title?.toLowerCase().includes(keyword)
    const userMatch = post.userName?.toLowerCase().includes(keyword)
    return titleMatch || userMatch
  })
})

// 生命周期钩子
onMounted(() => {
  // 初始化页面
  initPage()
})

// 初始化页面
const initPage = async () => {
  // 加载圈子数据
  await loadCircles()
  // 加载帖子数据
  await loadPosts()
}

// 加载圈子数据
const loadCircles = async () => {
  isLoading.value = true
  try {
    const res = await getAllCirclesAPI()
    if (res.code === '200') {
      circles.value = res.data || []
    } else {
      ElMessage.error(res.msg || '获取圈子列表失败')
    }
  } catch (error) {
    console.error('获取圈子列表失败:', error)
    ElMessage.error('获取圈子列表失败')
  } finally {
    isLoading.value = false
  }
}

// 更新加载帖子方法以处理分页和返回总数
const loadPosts = async (page) => {
  // 如果传入页码，则更新当前页码
  if (page) params.pageNum = page

  isLoading.value = true
  try {
    const requestParams = {
      pageNum: params.pageNum,
      pageSize: params.pageSize
    }

    // 如果选择了特定圈子，添加到请求参数
    if (activeCircle.value !== '全部') {
      requestParams.circle = activeCircle.value
    }

    const res = await getPostsFrontPageAPI(requestParams)

    if (res.code === '200') {
      posts.value = res.data?.list || []
      total.value = res.data?.total || 0 // 更新总数
    } else {
      ElMessage.error(res.msg || '获取帖子失败')
    }
  } catch (error) {
    console.error('获取帖子失败:', error)
    ElMessage.error('获取帖子失败')
  } finally {
    isLoading.value = false
  }
}

// 处理帖子点击
const handlePostClick = (postId) => {
  router.push(`/post/detail/${postId}`)
}

// 处理圈子点击
const handleCircleClick = (circleName) => {
  activeCircle.value = circleName
  searchKeyword.value = '' // 重置搜索关键词
  loadPosts() // 重新加载帖子数据
}

// 处理创建帖子
const handleCreatePost = () => {
  router.push('/post/create')
}

// 切换标签页
const handleTabChange = (tab) => {
  activeTab.value = tab
}

// 切换视图模式
const handleViewModeChange = (mode) => {
  viewMode.value = mode
}

// 处理搜索
const handleSearch = (keyword) => {
  searchKeyword.value = keyword
}

// 处理页码变更
const handlePageChange = (page) => {
  loadPosts(page)
}
</script>

<template>
  <div class="community-container">
    <!-- 社区主页内容 -->
    <div class="community-content">
      <!-- 页面头部 -->
      <CommunityHeader @create-post="handleCreatePost" @search="handleSearch" />

      <!-- 主要内容区 -->
      <div class="main-content">
        <!-- 左侧边栏 - 圈子导航和推荐 -->
        <CommunitySiderBar :circles="circles" :loading="isLoading" :active-circle="activeCircle"
          @circle-click="handleCircleClick" />

        <!-- 右侧内容区 - 帖子展示 -->
        <transition name="fade" mode="out-in">
          <CommunityList :key="activeCircle + '-' + activeTab + '-' + params.pageNum" :posts="filteredPosts"
            :loading="isLoading" :active-tab="activeTab" :view-mode="viewMode" :total="total" :page-num="params.pageNum"
            :page-size="params.pageSize" @tab-change="handleTabChange" @view-mode-change="handleViewModeChange"
            @post-click="handlePostClick" @page-change="handlePageChange" />
        </transition>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.community-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;

  @media (max-width: 768px) {
    padding: 16px;
  }
}

.main-content {
  display: flex;
  gap: 24px;

  @media (max-width: 768px) {
    flex-direction: column;
  }
}

/* 新增过渡效果 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
