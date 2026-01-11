<template>
    <div class="square-header">
        <div class="header-left">
            <div class="title-icon">
                <el-icon :size="24">
                    <ShoppingCart />
                </el-icon>
            </div>
            <div class="title-content">
                <h1 class="main-title">广场</h1>
                <p class="subtitle">浏览和发现优质二手商品</p>
            </div>
        </div>
        <div class="search-box">
            <el-input v-model="keyword" placeholder="搜索商品..." clearable
                @clear="$emit('update:keyword', ''); $emit('search', '')" @keyup.enter="$emit('search', keyword)">
                <template #prefix>
                    <el-icon>
                        <Search />
                    </el-icon>
                </template>
                <template #append>
                    <el-button @click="$emit('search', keyword)">搜索</el-button>
                </template>
            </el-input>
        </div>
        <div class="header-right">
            <el-button type="primary" @click="toCreateGoods">
                <el-icon>
                    <Edit />
                </el-icon>
                发布商品
            </el-button>
        </div>
    </div>
</template>

<script setup>
import { ref, toRefs, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ShoppingCart, Search, Edit } from '@element-plus/icons-vue'

const props = defineProps({
    searchKeyword: {
        type: String,
        default: ''
    }
})

const emit = defineEmits(['update:keyword', 'search'])
const router = useRouter()

// 本地搜索关键词，双向绑定到父组件
const keyword = ref(props.searchKeyword)

// 监听prop变化更新本地值
watch(() => props.searchKeyword, (newVal) => {
    keyword.value = newVal
})

// 监听本地值变化更新父组件
watch(keyword, (newVal) => {
    emit('update:keyword', newVal)
})

// 跳转到发布商品页面
const toCreateGoods = () => {
    router.push('/goods/create')
}
</script>

<style lang="scss" scoped>
.square-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    gap: 20px;

    @media (max-width: 768px) {
        flex-direction: column;
        align-items: stretch;
    }

    .header-left {
        display: flex;
        align-items: center;

        .title-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: linear-gradient(135deg, #f0f9ff, #409eff);
            color: white;
            box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
            margin-right: 16px;
        }

        .title-content {
            .main-title {
                font-size: 24px;
                font-weight: 600;
                margin: 0 0 4px;
                color: #303133;
            }

            .subtitle {
                font-size: 14px;
                color: #909399;
                margin: 0;
            }
        }
    }

    .search-box {
        flex: 1;
        max-width: 400px;

        @media (max-width: 768px) {
            max-width: 100%;
            order: 2;
        }
    }

    .header-right {
        @media (max-width: 768px) {
            align-self: flex-end;
        }
    }
}
</style>
