<script setup>
import { ArrowDown, ArrowUp, Sort, CaretTop, CaretBottom, Money, Timer, Star } from '@element-plus/icons-vue'
import { ref, computed } from 'vue'

// 接收父传子属性
const props = defineProps({
    categoryList: {
        type: Array,
        default: () => []
    }
})

// 定义子传父事件
const emit = defineEmits(['category-change', 'sort-change'])

// 选中的分类
const selectedCategory = ref(null)
// 选中的排序方式
const selectedSort = ref(null)
// 过滤器是否折叠状态（只显示分类部分）
const isCollapsed = ref(false)

// 切换折叠状态
const toggleCollapse = () => {
    isCollapsed.value = !isCollapsed.value
}

// 处理分类变化
// 1. 如果点击的是当前已选中的分类，则取消选中（设置为null）
// 2. 如果点击的是其他分类，则选中该分类 
const handleCategoryChange = (categoryName) => {
    selectedCategory.value = categoryName === selectedCategory.value ? null : categoryName
    emit('category-change', selectedCategory.value)
}

// 处理排序变化
const handleSortChange = (value) => {
    selectedSort.value = value
    emit('sort-change', value)
}

// 获取价格排序按钮的图标
const getPriceIcon = computed(() => {
    if (selectedSort.value === '最昂贵') {
        return ArrowDown
    } else if (selectedSort.value === '最便宜') {
        return ArrowUp
    }
    return Money
})

// 获取时间排序按钮的图标
const getTimeIcon = computed(() => {
    if (selectedSort.value === '最新') {
        return ArrowDown
    } else if (selectedSort.value === '最早') {
        return ArrowUp
    }
    return Timer
})

// 获取热度排序按钮的图标
const getHotIcon = computed(() => {
    if (selectedSort.value === '最热') {
        return ArrowDown
    } else if (selectedSort.value === '最冷') {
        return ArrowUp
    }
    return Star
})

</script>

<template>
    <div class="filter-toolbar">
        <!-- 分类 -->
        <div class="section category-section">
            <div class="section-header">
                <div class="section-title">商品分类</div>
                <div class="collapse-control" @click="toggleCollapse">
                    <el-icon>
                        <component :is="isCollapsed ? CaretBottom : CaretTop" />
                    </el-icon>
                </div>
            </div>
            <div class="category-list">
                <div class="category-item" :class="{ active: selectedCategory === null }"
                    @click="handleCategoryChange(null)">
                    全部
                </div>
                <div v-for="category in categoryList" :key="category.id" class="category-item"
                    :class="{ active: selectedCategory === category.name }"
                    @click="handleCategoryChange(category.name)">
                    {{ category.name }}
                </div>
            </div>
        </div>

        <!-- 其他部分（当未折叠时显示） -->
        <transition name="collapse">
            <div v-show="!isCollapsed" class="collapsible-sections">
                <!-- 排序 -->
                <div class="section sort-section">
                    <div class="section-title">排序方式</div>
                    <div class="sort-buttons">
                        <!-- 默认排序按钮 -->
                        <el-button :type="selectedSort === null ? 'primary' : 'default'" @click="handleSortChange(null)"
                            class="sort-btn">
                            <el-icon>
                                <Sort />
                            </el-icon>
                            <span>默认排序</span>
                        </el-button>

                        <!-- 价格排序按钮 -->
                        <el-dropdown trigger="hover" @command="handleSortChange" class="sort-dropdown">
                            <el-button
                                :type="selectedSort && (selectedSort === '最昂贵' || selectedSort === '最便宜') ? 'primary' : 'default'"
                                class="sort-btn">
                                <el-icon>
                                    <component :is="getPriceIcon" />
                                </el-icon>
                                <span>价格</span>
                            </el-button>
                            <template #dropdown>
                                <el-dropdown-menu>
                                    <el-dropdown-item command="最便宜">
                                        <el-icon>
                                            <ArrowUp />
                                        </el-icon>
                                        <span>最便宜（升序）</span>
                                    </el-dropdown-item>
                                    <el-dropdown-item command="最昂贵">
                                        <el-icon>
                                            <ArrowDown />
                                        </el-icon>
                                        <span>最昂贵（降序）</span>
                                    </el-dropdown-item>
                                </el-dropdown-menu>
                            </template>
                        </el-dropdown>

                        <!-- 时间排序按钮 -->
                        <el-dropdown trigger="hover" @command="handleSortChange" class="sort-dropdown">
                            <el-button
                                :type="selectedSort && (selectedSort === '最早' || selectedSort === '最新') ? 'primary' : 'default'"
                                class="sort-btn">
                                <el-icon>
                                    <component :is="getTimeIcon" />
                                </el-icon>
                                <span>时间</span>
                            </el-button>
                            <template #dropdown>
                                <el-dropdown-menu>
                                    <el-dropdown-item command="最早">
                                        <el-icon>
                                            <ArrowUp />
                                        </el-icon>
                                        <span>最早（升序）</span>
                                    </el-dropdown-item>
                                    <el-dropdown-item command="最新">
                                        <el-icon>
                                            <ArrowDown />
                                        </el-icon>
                                        <span>最新（降序）</span>
                                    </el-dropdown-item>
                                </el-dropdown-menu>
                            </template>
                        </el-dropdown>

                        <!-- 热度排序按钮 -->
                        <el-dropdown trigger="hover" @command="handleSortChange" class="sort-dropdown">
                            <el-button
                                :type="selectedSort && (selectedSort === '最热' || selectedSort === '最冷') ? 'primary' : 'default'"
                                class="sort-btn">
                                <el-icon>
                                    <component :is="getHotIcon" />
                                </el-icon>
                                <span>热度</span>
                            </el-button>
                            <template #dropdown>
                                <el-dropdown-menu>
                                    <!-- command是点击事件handleSortChange的参数 -->
                                    <el-dropdown-item command="最冷">
                                        <el-icon>
                                            <ArrowUp />
                                        </el-icon>
                                        <span>无人问津（升序）</span>
                                    </el-dropdown-item>
                                    <el-dropdown-item command="最热">
                                        <el-icon>
                                            <ArrowDown />
                                        </el-icon>
                                        <span>门庭若市（降序）</span>
                                    </el-dropdown-item>
                                </el-dropdown-menu>
                            </template>
                        </el-dropdown>
                    </div>
                </div>
            </div>
        </transition>
    </div>
</template>

<style lang="scss" scoped>
.filter-toolbar {
    padding: 20px;
    border-radius: 8px;
    background-color: #fff;
}

.section {
    margin-bottom: 20px;
    padding-bottom: 20px;
    border-bottom: 1px solid #ebeef5;

    &:last-child {
        margin-bottom: 0;
        padding-bottom: 0;
        border-bottom: none;
    }
}

.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    //! 控制分类标题与折叠按钮的边距
    margin-bottom: 5px;
}

.section-title {
    font-size: 16px;
    font-weight: 600;
    margin-bottom: 20px;
    color: #303133;
}

.collapse-control {
    cursor: pointer;
    border-radius: 10px;
    transition: all 0.5s;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 28px;
    width: 28px;
    background-color: #f5f7fa;

    &:hover {
        background-color: #e6f4ff;
        color: #409eff;
    }

    .el-icon {
        font-size: 16px;
    }
}

//! 由vue的transition组件提供，自动添加和移除
/* 折叠动画相关样式 */
.collapse-enter-active,
.collapse-leave-active {
    transition: all 0.5s ease-in-out;
    max-height: 1000px;
    opacity: 1;
    overflow: hidden;
}

.collapse-enter-from,
.collapse-leave-to {
    max-height: 0;
    opacity: 0;
    overflow: hidden;
}

/* 分类部分 */
.category-list {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
}

.category-item {
    padding: 8px 16px;
    border-radius: 20px;
    background-color: #f2f3f5;
    cursor: pointer;
    transition: all 0.3s ease;
    font-size: 14px;
    border: 1px solid transparent;
    color: #606266;

    &:hover {
        background-color: #e6f4ff;
        color: #409eff;
        border-color: #c6e2ff;
    }

    &.active {
        background-color: #e6f4ff;
        color: #409eff;
        border-color: #c6e2ff;
        font-weight: 500;
    }
}

/* 排序按钮组 */
.sort-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.sort-btn {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 10px 15px;
    font-size: 14px;

    .el-icon {
        font-size: 14px;
    }
}

.sort-dropdown {
    margin: 0;
}

/* 下拉菜单项样式 */
:deep(.el-dropdown-menu) {
    padding: 6px 0;

    .el-dropdown-item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 16px;
        font-size: 14px;
        line-height: 1.5;

        .el-icon {
            margin-right: 4px;
        }
    }
}

/* 响应式样式 */
@media (max-width: 768px) {
    .filter-toolbar {
        padding: 16px;
    }

    .sort-buttons {
        justify-content: space-between;

        .sort-btn {
            padding: 8px 12px;
            font-size: 13px;
        }
    }
}
</style>