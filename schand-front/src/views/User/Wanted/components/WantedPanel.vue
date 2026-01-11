<script setup>
/**
 * 悬赏信息面板组件
 * 显示悬赏统计和快速筛选
 */
import { ref, onMounted, computed, watch } from 'vue'
import { Timer, PriceTag, Collection } from '@element-plus/icons-vue'
import { getHelpFrontPageAPI } from '@/api/wantedAPI'

// 定义组件属性
const props = defineProps({
    // 当前筛选条件
    activeFilter: {
        type: String,
        default: 'all'
    },
    // 是否可点击
    clickable: {
        type: Boolean,
        default: true
    }
})

// 定义事件
const emit = defineEmits(['filter-change', 'update-list', 'loading-complete'])

// 统计数据
const stats = ref({
    total: 0,        // 总悬赏数
    unsolved: 0,     // 未解决数
    solved: 0,       // 已解决数
    stagnant: 0      // 滞留数
})

// 存储所有悬赏数据
const allWantedList = ref([])

// 加载统计数据
const loadStats = async () => {
    try {
        // 不分页获取所有数据
        const res = await getHelpFrontPageAPI({
            pageSize: 9999,  // 设置足够大的页面大小
            pageNum: 1
        })

        if (res.code === '200' && res.data && res.data.list) {
            let helpList = res.data.list || []
            console.log("获取到所有悬赏数据, 总条数:", helpList.length)

            // 确保数据有效性，过滤掉可能的无效或重复数据
            helpList = helpList.filter(item => item && item.id)

            // 查找重复项并去重
            const uniqueIds = new Set()
            helpList = helpList.filter(item => {
                if (uniqueIds.has(item.id)) {
                    return false
                }
                uniqueIds.add(item.id)
                return true
            })

            // 保存经过处理的数据
            allWantedList.value = helpList

            // 计算统计数据
            calculateStats(helpList)

            // 将全部数据传递给父组件
            emit('update-list', helpList)

            // 通知数据加载完成
            emit('loading-complete')
        }
    } catch (error) {
        console.error('获取统计数据失败:', error)
        emit('loading-complete') // 即使出错也通知完成，避免永久加载状态
    }
}

// 计算统计数据
const calculateStats = (helpList) => {
    // 确保计数准确，手动分类并计数
    const total = helpList.length

    // 计算滞留：发布时间超过7天且未解决
    const now = new Date()
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
    const stagnantItems = helpList.filter(item => {
        if (!item.time) return false
        const publishTime = new Date(item.time)
        return publishTime < sevenDaysAgo && item.solved === '未解决'
    })
    const stagnant = stagnantItems.length

    // 提取所有滞留项的ID，用于后续排除
    const stagnantIds = new Set(stagnantItems.map(item => item.id))

    // 未解决：严格匹配 '未解决' 但排除掉滞留的
    const unsolved = helpList.filter(item =>
        item.solved && item.solved === '未解决' && !stagnantIds.has(item.id)
    ).length

    // 已解决：严格匹配 '已解决'
    const solved = helpList.filter(item =>
        item.solved && item.solved === '已解决'
    ).length

    // 更新统计数据
    stats.value = {
        total,
        unsolved,
        solved,
        stagnant
    }

    console.log("计算后统计结果:", stats.value, "滞留ID:", [...stagnantIds])
}

// 点击统计卡片时的处理函数
const handleCardClick = (key) => {
    if (props.clickable) {
        emit('filter-change', key)
        console.log('触发筛选器变更，类型:', key)
    }
}

// 生命周期钩子
onMounted(() => {
    loadStats()
})
</script>

<template>
    <div class="info-panel">
        <el-card shadow="hover" class="stats-card">
            <div class="stats-grid">
                <div class="stat-item" @click="handleCardClick('all')" :class="{ active: activeFilter === 'all' }">
                    <div class="stat-icon">
                        <el-icon>
                            <Collection />
                        </el-icon>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">{{ stats.total }}</div>
                        <div class="stat-label">全部悬赏</div>
                    </div>
                </div>

                <div class="stat-item" @click="handleCardClick('unsolved')"
                    :class="{ active: activeFilter === 'unsolved' }">
                    <div class="stat-icon orange">
                        <el-icon>
                            <PriceTag />
                        </el-icon>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">{{ stats.unsolved }}</div>
                        <div class="stat-label">未解决</div>
                    </div>
                </div>

                <div class="stat-item" @click="handleCardClick('solved')"
                    :class="{ active: activeFilter === 'solved' }">
                    <div class="stat-icon green">
                        <el-icon>
                            <PriceTag />
                        </el-icon>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">{{ stats.solved }}</div>
                        <div class="stat-label">已解决</div>
                    </div>
                </div>

                <div class="stat-item" @click="handleCardClick('stagnant')"
                    :class="{ active: activeFilter === 'stagnant' }">
                    <div class="stat-icon red">
                        <el-icon>
                            <Timer />
                        </el-icon>
                    </div>
                    <div class="stat-content">
                        <div class="stat-value">{{ stats.stagnant }}</div>
                        <div class="stat-label">滞留</div>
                    </div>
                </div>
            </div>
        </el-card>
    </div>
</template>

<style lang="scss" scoped>
.info-panel {
    margin-bottom: 24px;

    .stats-card {
        border-radius: 12px;
        box-shadow: var(--el-box-shadow-light);
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;

        @media (max-width: 768px) {
            grid-template-columns: repeat(2, 1fr);
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;

            &:hover {
                background-color: var(--el-fill-color-light);
            }

            &.active {
                background-color: var(--el-fill-color);
            }

            .stat-icon {
                width: 48px;
                height: 48px;
                border-radius: 12px;
                background-color: var(--el-color-primary-light-8);
                display: flex;
                align-items: center;
                justify-content: center;

                .el-icon {
                    font-size: 24px;
                    color: var(--el-color-primary);
                }

                &.orange {
                    background-color: var(--el-color-warning-light-8);

                    .el-icon {
                        color: var(--el-color-warning);
                    }
                }

                &.green {
                    background-color: var(--el-color-success-light-8);

                    .el-icon {
                        color: var(--el-color-success);
                    }
                }

                &.red {
                    background-color: var(--el-color-danger-light-8);

                    .el-icon {
                        color: var(--el-color-danger);
                    }
                }

                &.gray {
                    background-color: var(--el-color-info-light-8);

                    .el-icon {
                        color: var(--el-color-info);
                    }
                }
            }

            .stat-content {
                display: flex;
                flex-direction: column;

                .stat-value {
                    font-size: 24px;
                    font-weight: 600;
                    color: var(--el-text-color-primary);
                }

                .stat-label {
                    font-size: 14px;
                    color: var(--el-text-color-secondary);
                }
            }
        }
    }
}
</style>