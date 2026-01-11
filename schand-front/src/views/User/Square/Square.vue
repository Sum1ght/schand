<script setup>
import { getAllCategoryAPI } from '@/api/categoryAPI'
import { getGoodsFrontPageAPI } from '@/api/goodsAPI'
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import SquareBanner from './components/SquareBanner.vue'
import SquareFilter from './components/SquareFilter.vue'
import SquareHeader from './components/SquareHeader.vue'
import SquareList from './components/SquareList.vue'

// 路由实例
const router = useRouter()

// 分类列表
const categoryList = ref([])
// 商品列表
const goodsList = ref([])
// 商品总数
const total = ref(0)
// 当前页码
const pageNum = ref(1)
// 每页商品数量
const pageSize = ref(8)
// 当前分类
const category = ref(null)
// 排序方式
const sort = ref(null)
// 是否加载中
const isLoading = ref(false)
// 搜索关键词
const searchKeyword = ref('')

// 加载分类数据
const loadCategory = async () => {
    try {
        const res = await getAllCategoryAPI()
        if (res.code === '200') {
            categoryList.value = res.data || []
        } else {
            ElMessage.error(res.msg || '获取分类列表失败')
        }
    } catch (error) {
        console.error('获取分类列表失败:', error)
        ElMessage.error('获取分类列表失败')
    }
}

// 加载商品数据
const loadGoods = async (page) => {
    if (page) pageNum.value = page
    isLoading.value = true

    try {
        const params = {
            pageNum: pageNum.value,
            pageSize: pageSize.value,
            category: category.value,
            sort: sort.value, // 直接使用排序值，不需要转换
            name: searchKeyword.value
        }
        console.log('加载商品请求参数:', params)

        // 调用API
        const res = await getGoodsFrontPageAPI(params)
        console.log('商品数据', res)
        if (res.code === '200') {
            goodsList.value = res.data?.list || []
            total.value = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '获取商品列表失败')
        }
    } catch (error) {
        console.error('获取商品列表失败:', error)
    } finally {
        isLoading.value = false
    }
}

// 处理分类变化
const handleCategoryChange = (categoryName) => {
    // 现在传递的是分类名称而不是ID
    category.value = categoryName
    loadGoods(1)
}

// 处理排序变化
const handleSortChange = (sortType) => {
    sort.value = sortType
    console.log('排序方式', sortType)
    loadGoods(1)
}

// 处理搜索
const handleSearch = (keyword) => {
    searchKeyword.value = keyword
    loadGoods(1)
}

// 处理页码变化
const handlePageChange = (page) => {
    loadGoods(page)
}

// 生命周期钩子
onMounted(() => {
    loadCategory()
    loadGoods(1)
})
</script>

<template>
    <div class="square-container">
        <!-- 使用SquareHeader组件 -->
        <SquareHeader :searchKeyword="searchKeyword" @update:keyword="searchKeyword = $event" @search="handleSearch" />

        <!-- 轮播图 -->
        <SquareBanner />

        <!-- 筛选工具栏 -->
        <div class="filter-section">
            <SquareFilter :categoryList="categoryList" @category-change="handleCategoryChange"
                @sort-change="handleSortChange" />
        </div>

        <!-- 商品列表 -->
        <div class="goods-section">
            <SquareList :goodsList="goodsList" :loading="isLoading" :total="total" :pageNum="pageNum"
                :pageSize="pageSize" @page-change="handlePageChange" />
        </div>
    </div>
</template>

<style lang="scss" scoped>
.square-container {
    width: 90%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px 0;
    min-height: calc(100vh - 250px);
    /* 确保整个容器至少有视口高度减去页眉页脚高度的高度 */
    display: flex;
    flex-direction: column;

    @media (max-width: 768px) {
        width: 95%;
        padding: 10px 0;
    }
}

.filter-section {
    margin: 20px 0;
    background-color: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.goods-section {
    margin-top: 20px;
    flex-grow: 1;
    /* 让商品区域占据剩余空间 */
}
</style>
