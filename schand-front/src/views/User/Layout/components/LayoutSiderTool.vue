<script setup>
/**
 * 侧边工具栏组件
 * 显示为右侧的小圆按钮，直接点击执行对应功能
 */
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowUp, ArrowDown, Share } from '@element-plus/icons-vue'

const route = useRoute()

// 计算当前页面的完整URL
const currentPageUrl = computed(() => {
    const baseUrl = window.location.origin
    return `${baseUrl}${route.fullPath}`
})

// 返回顶部
const scrollToTop = () => {
    window.scrollTo({
        top: 0,
        behavior: 'smooth'
    })
}

// 滚动到底部
const scrollToBottom = () => {
    window.scrollTo({
        top: document.documentElement.scrollHeight,
        behavior: 'smooth'
    })
}

// 分享页面（复制链接）
const sharePage = () => {
    try {
        navigator.clipboard.writeText(currentPageUrl.value).then(() => {
            ElMessage.success('链接已复制到剪贴板')
        })
    } catch (error) {
        console.error('复制链接失败:', error)
        ElMessage.error('复制链接失败，请手动复制')
    }
}
</script>

<template>
    <div class="sider-tool-container">
        <!-- 固定圆形按钮 -->
        <div class="tool-buttons">
            <div class="tool-button" @click="scrollToTop" title="返回顶部">
                <el-icon>
                    <ArrowUp />
                </el-icon>
            </div>

            <div class="tool-button" @click="scrollToBottom" title="前往底部">
                <el-icon>
                    <ArrowDown />
                </el-icon>
            </div>

            <div class="tool-button" @click="sharePage" title="分享页面">
                <el-icon>
                    <Share />
                </el-icon>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
.sider-tool-container {
    position: fixed;
    right: 20px;
    bottom: 120px;
    z-index: 999;
}

/* 圆形按钮组样式 */
.tool-buttons {
    display: flex;
    flex-direction: column;
    gap: 15px;

    .tool-button {
        width: 45px;
        height: 45px;
        border-radius: 50%;
        background-color: #fff;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
        transition: all 0.25s ease;
        color: #606266;

        &:hover {
            transform: scale(1.1);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            color: var(--el-color-primary);
        }

        &:active {
            transform: scale(0.95);
        }

        .el-icon {
            font-size: 20px;
        }
    }
}

/* 响应式调整 */
@media (max-width: 768px) {
    .sider-tool-container {
        bottom: 80px;
        right: 15px;
    }

    .tool-buttons .tool-button {
        width: 40px;
        height: 40px;

        .el-icon {
            font-size: 18px;
        }
    }
}
</style>
