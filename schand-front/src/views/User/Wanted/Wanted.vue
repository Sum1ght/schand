<script setup>
/**
 * 悬赏主页组件
 * 作为悬赏模块的入口，提供内容展示和交互功能
 */
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'

// 引入子组件
import WantedHeader from './components/WantedHeader.vue'
import WantedPanel from './components/WantedPanel.vue'
import WantedList from './components/WantedList.vue'

// 路由实例
const router = useRouter()

// 响应式数据
const allWantedList = ref([])  // 所有悬赏数据
const wantedList = ref([])     // 当前页显示的悬赏列表
const isLoading = ref(false)   // 加载状态
const title = ref('')          // 搜索关键词
const activeFilter = ref('all') // 当前筛选条件

// 分页参数
const pageConfig = reactive({
    pageNum: 1,
    pageSize: 5
})

// 根据筛选条件和搜索词过滤数据
const filteredWantedList = computed(() => {
    // 先根据标题搜索过滤
    let result = allWantedList.value

    if (title.value) {
        result = result.filter(item =>
            item.title && item.title.toLowerCase().includes(title.value.toLowerCase())
        )
    }

    // 计算所有滞留项，用于后续排除
    let stagnantIds = new Set()
    if (activeFilter.value === 'unsolved' || activeFilter.value === 'stagnant') {
        const now = new Date()
        const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
        const stagnantItems = result.filter(item => {
            if (!item.time) return false
            const publishTime = new Date(item.time)
            return publishTime < sevenDaysAgo && item.solved === '未解决'
        })
        stagnantIds = new Set(stagnantItems.map(item => item.id))
    }

    // 再根据状态筛选 - 使用更严格的匹配条件
    if (activeFilter.value === 'unsolved') {
        // 未解决：严格匹配 '未解决'，排除滞留
        result = result.filter(item =>
            item.solved && item.solved === '未解决' && !stagnantIds.has(item.id)
        )
    } else if (activeFilter.value === 'solved') {
        // 已解决：严格匹配 '已解决'
        result = result.filter(item => item.solved && item.solved === '已解决')
    } else if (activeFilter.value === 'stagnant') {
        // 滞留：使用已计算的滞留ID
        result = result.filter(item => stagnantIds.has(item.id))
    }

    // 对结果进行按时间排序(最新的在前面)
    return result.sort((a, b) => {
        if (!a.time) return 1
        if (!b.time) return -1
        return new Date(b.time) - new Date(a.time)
    })
})

// 计算当前页数据
const paginatedWantedList = computed(() => {
    const start = (pageConfig.pageNum - 1) * pageConfig.pageSize
    const end = start + pageConfig.pageSize
    return filteredWantedList.value.slice(start, end)
})

// 更新所有悬赏数据
const updateAllWantedList = (list) => {
    allWantedList.value = list
    // 重置到第一页
    pageConfig.pageNum = 1
    updateCurrentPageData()
}

// 更新当前页显示数据
const updateCurrentPageData = () => {
    wantedList.value = paginatedWantedList.value

    // 如果当前页没有数据且不是第一页，回到上一页
    if (wantedList.value.length === 0 && pageConfig.pageNum > 1) {
        pageConfig.pageNum--
        updateCurrentPageData()
    }

    console.log(`当前筛选: ${activeFilter.value}, 总数: ${filteredWantedList.value.length}, 页码: ${pageConfig.pageNum}, 当前页数据: ${wantedList.value.length}`)
}

// 处理搜索
const handleSearch = (keyword) => {
    title.value = keyword
    pageConfig.pageNum = 1 // 重置到第一页
    updateCurrentPageData()
}

// 处理页码变化
const handlePageChange = (page) => {
    pageConfig.pageNum = page
    updateCurrentPageData()
}

// 处理评论展示/隐藏
const handleCommentToggle = (item) => {
    item.showComment = !item.showComment
}

// 处理筛选变化
const handleFilterChange = (filter) => {
    activeFilter.value = filter
    pageConfig.pageNum = 1 // 重置到第一页
    updateCurrentPageData()
}

// 跳转到发布悬赏页面
const goToAddWanted = () => {
    router.push('/wanted/create')
}

// 处理悬赏点击
const handleItemClick = (id) => {
    router.push(`/wanted/detail/${id}`)
}

// 处理数据加载完成
const handleLoadingComplete = () => {
    isLoading.value = false
}

// 生命周期钩子
onMounted(() => {
    // 初始化显示，WantedPanel组件会负责获取并传递数据
    isLoading.value = true
})
</script>

<template>
    <div class="wanted-container">
        <!-- 页面头部 -->
        <WantedHeader @create-wanted="goToAddWanted" @search="handleSearch" />

        <!-- 统计信息面板 -->
        <WantedPanel :active-filter="activeFilter" @filter-change="handleFilterChange"
            @update-list="updateAllWantedList" @loading-complete="handleLoadingComplete" />

        <!-- 悬赏列表 -->
        <WantedList :wanted-list="wantedList" :loading="isLoading" :total="filteredWantedList.length"
            :page-num="pageConfig.pageNum" :page-size="pageConfig.pageSize" :filter="activeFilter"
            @page-change="handlePageChange" @item-click="handleItemClick" @comment-toggle="handleCommentToggle" />
    </div>
</template>

<style lang="scss" scoped>
.wanted-container {
    width: 100%;
    max-width: 960px;
    margin: 24px auto;
    padding: 0 16px;

    @media (max-width: 768px) {
        margin: 16px auto;
    }

    @media (max-width: 576px) {
        padding: 0 12px;
    }
}
</style>