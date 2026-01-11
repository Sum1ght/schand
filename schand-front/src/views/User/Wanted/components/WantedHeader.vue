    <script setup>
    /**
     * 悬赏页面头部组件
     * 显示悬赏标题、搜索栏和发布悬赏按钮
     */
    import { ref, defineEmits } from 'vue'
    import { Aim, Edit, Search } from '@element-plus/icons-vue'

    // 事件定义
    const emit = defineEmits(['create-wanted', 'search'])

    // 搜索关键词
    const searchKeyword = ref('')

    // 处理发布悬赏
    const handleCreateWanted = () => {
        emit('create-wanted')
    }

    // 处理搜索
    const handleSearch = () => {
        emit('search', searchKeyword.value)
    }

    // 按回车键搜索
    const handleKeyDown = (e) => {
        if (e.key === 'Enter') {
            handleSearch()
        }
    }
</script>

    <template>
        <div class="wanted-header">
            <div class="header-left">
                <div class="title-icon">
                    <el-icon :size="24">
                        <Aim />
                    </el-icon>
                </div>
                <div class="title-content">
                    <h1 class="main-title">悬赏</h1>
                    <p class="subtitle">发布求购需求，找到您想要的物品</p>
                </div>
            </div>

            <div class="search-box">
                <el-input v-model="searchKeyword" placeholder="搜索求购信息" clearable @keydown="handleKeyDown">
                    <template #prefix>
                        <el-icon class="search-icon">
                            <Search />
                        </el-icon>
                    </template>
                    <template #append>
                        <el-button @click="handleSearch">搜索</el-button>
                    </template>
                </el-input>
            </div>

            <div class="header-right">
                <el-button type="warning" @click="handleCreateWanted" class="create-button">
                    <el-icon>
                        <Edit />
                    </el-icon>
                    发布悬赏
                </el-button>
            </div>
        </div>
    </template>

<style lang="scss" scoped>
.wanted-header {
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
            background: linear-gradient(135deg, #fdf5e6, #e6a23c);
            color: white;
            box-shadow: 0 4px 12px rgba(230, 162, 60, 0.2);
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

        .search-icon {
            color: var(--el-text-color-secondary);
        }
    }

    .header-right {
        @media (max-width: 768px) {
            align-self: flex-end;
        }

        .create-button {
            display: flex;
            align-items: center;
            gap: 6px;
            font-weight: 500;
        }
    }
}
</style>