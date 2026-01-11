<script setup>
/**
 * 支付结果回调页面
 * 展示模拟支付结果信息，提供返回首页和查看订单选项
 */
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getOrderByIdAPI, updateOrderAPI } from '@/api/orderAPI'
import {
    CircleCheck,
    CircleClose,
    InfoFilled,
    HomeFilled,
    Document,
    Timer
} from '@element-plus/icons-vue'

// 路由和导航
const route = useRoute()
const router = useRouter()
const orderId = route.query.orderId
const payResult = route.query.payResult === 'true'

// 页面状态
const pageState = reactive({
    loading: true,
    redirectTimer: null,
    redirectSeconds: 5,
    orderUpdated: false
})

// 订单数据
const orderInfo = ref({})

// 获取订单信息并更新订单状态
const getOrderInfo = async () => {
    if (!orderId) {
        ElMessage.error('订单编号不存在')
        router.push('/personal/myorder')
        return
    }

    try {
        pageState.loading = true
        const { data } = await getOrderByIdAPI(orderId)

        if (!data) {
            ElMessage.error('订单不存在')
            router.push('/personal/myorder')
            return
        }

        orderInfo.value = data

        // 如果支付成功且订单状态还是待支付，则更新订单状态
        if (payResult && data.status === '待支付' && !pageState.orderUpdated) {
            await updateOrderStatus()
        }
    } catch (error) {
        console.error('获取订单信息失败:', error)
        ElMessage.error('获取订单信息失败')
    } finally {
        pageState.loading = false
        // 开始自动跳转倒计时
        startRedirectTimer()
    }
}

// 更新订单状态为待发货
const updateOrderStatus = async () => {
    try {
        // 由于订单状态已在 Pay.vue 中更新为"待发货"
        // 这里只需标记订单已更新，避免重复操作
        console.log('订单状态已在支付页面更新，无需重复操作')
        pageState.orderUpdated = true
    } catch (error) {
        console.error('更新订单状态操作失败:', error)
    }
}

// 格式化金额
const formatPrice = (price) => {
    if (!price && price !== 0) return '¥0.00'
    return `¥${Number(price).toFixed(2)}`
}

// 格式化时间
const formatTime = (time) => {
    if (!time) return '刚刚'
    return new Date(time).toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    }).replace(/\//g, '-')
}

// 查看订单
const viewOrder = () => {
    router.push('/personal/myorder')
}

// 返回首页
const goHome = () => {
    router.push('/')
}

// 开始自动跳转倒计时
const startRedirectTimer = () => {
    if (pageState.redirectTimer) {
        clearInterval(pageState.redirectTimer)
    }

    pageState.redirectSeconds = 10
    pageState.redirectTimer = setInterval(() => {
        pageState.redirectSeconds--

        if (pageState.redirectSeconds <= 0) {
            clearInterval(pageState.redirectTimer)
            viewOrder() // 自动跳转到订单列表
        }
    }, 1000)
}

// 组件挂载
onMounted(() => {
    getOrderInfo()
})

// 组件卸载前清理
onBeforeUnmount(() => {
    if (pageState.redirectTimer) {
        clearInterval(pageState.redirectTimer)
    }
})
</script>

<template>
    <div class="pay-result-page">
        <div class="result-container">
            <!-- 支付结果卡片 -->
            <div class="result-card" v-loading="pageState.loading">
                <!-- 顶部导航 -->
                <div class="page-nav">
                    <div class="back-button" @click="goHome">
                        <el-icon>
                            <HomeFilled />
                        </el-icon>
                        <span>返回首页</span>
                    </div>
                </div>

                <!-- 结果图标 -->
                <div class="result-icon" :class="{ 'success': payResult, 'error': !payResult }">
                    <el-icon v-if="payResult">
                        <CircleCheck />
                    </el-icon>
                    <el-icon v-else>
                        <CircleClose />
                    </el-icon>
                </div>

                <!-- 结果信息 -->
                <div class="result-info">
                    <h2 class="result-title">支付{{ payResult ? '成功' : '失败' }}</h2>
                    <div class="result-subtitle" v-if="payResult">
                        我们将尽快为您发货，收货期间请保持手机畅通
                    </div>
                    <div class="result-subtitle" v-else>
                        支付未成功，您可以查看订单重新支付或联系客服
                    </div>
                </div>

                <!-- 订单信息 -->
                <div class="order-info">
                    <div class="info-item">
                        <span class="label">订单金额：</span>
                        <span class="value amount">{{ formatPrice(orderInfo.total) }}</span>
                    </div>
                    <div class="info-item">
                        <span class="label">订单编号：</span>
                        <span class="value">{{ orderInfo.orderNo }}</span>
                    </div>
                    <div class="info-item">
                        <span class="label">商品名称：</span>
                        <span class="value">{{ orderInfo.goodsName }}</span>
                    </div>
                    <div class="info-item" v-if="payResult">
                        <span class="label">支付时间：</span>
                        <span class="value">{{ formatTime(new Date()) }}</span>
                    </div>
                </div>

                <!-- 订单图片预览 -->
                <div class="goods-preview" v-if="orderInfo.goodsImg">
                    <el-image :src="orderInfo.goodsImg" fit="cover" class="goods-image" />
                </div>

                <!-- 操作按钮 -->
                <div class="action-buttons">
                    <el-button type="primary" @click="viewOrder">
                        <el-icon>
                            <Document />
                        </el-icon>
                        <span>查看订单</span>
                    </el-button>
                    <el-button @click="goHome">
                        <el-icon>
                            <HomeFilled />
                        </el-icon>
                        <span>返回首页</span>
                    </el-button>
                </div>

                <!-- 自动跳转提示 -->
                <div class="auto-redirect" v-if="!pageState.loading">
                    <el-icon>
                        <Timer />
                    </el-icon>
                    <span>{{ pageState.redirectSeconds }}秒后自动跳转到订单页...</span>
                </div>

                <!-- 温馨提示 -->
                <div class="tips">
                    <div class="tip-icon">
                        <el-icon>
                            <InfoFilled />
                        </el-icon>
                    </div>
                    <div class="tip-text">
                        <p>温馨提示：</p>
                        <ol>
                            <li>订单状态更新可能会有延迟，请耐心等待</li>
                            <li>如对订单有疑问，请通过平台客服联系我们</li>
                            <li>您可以在"个人中心-我的订单"查看订单详情</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.pay-result-page {
    padding: 40px 20px;
    min-height: calc(100vh - 200px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    .result-container {
        max-width: 600px;
        margin: 0 auto;

        .result-card {
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            padding: 40px;
            text-align: center;
            position: relative;
            overflow: hidden;

            // 顶部导航
            .page-nav {
                position: absolute;
                top: 20px;
                left: 20px;
                z-index: 1;

                .back-button {
                    display: flex;
                    align-items: center;
                    font-size: 14px;
                    color: var(--el-text-color-secondary);
                    cursor: pointer;
                    transition: color 0.3s;

                    .el-icon {
                        margin-right: 4px;
                    }

                    &:hover {
                        color: var(--el-color-primary);
                    }
                }
            }

            // 结果图标
            .result-icon {
                display: flex;
                justify-content: center;
                margin: 10px 0 24px;

                .el-icon {
                    font-size: 80px;

                    // 默认颜色
                    color: var(--el-color-info);
                }

                &.success .el-icon {
                    color: var(--el-color-success);
                    animation: bounce 1s ease;
                }

                &.error .el-icon {
                    color: var(--el-color-danger);
                    animation: shake 0.5s ease;
                }
            }

            // 结果信息
            .result-info {
                margin-bottom: 30px;

                .result-title {
                    font-size: 28px;
                    font-weight: 600;
                    color: var(--el-text-color-primary);
                    margin: 0 0 16px;
                }

                .result-subtitle {
                    font-size: 16px;
                    color: var(--el-text-color-secondary);
                    max-width: 400px;
                    margin: 0 auto;
                    line-height: 1.6;
                }
            }

            // 订单信息
            .order-info {
                background-color: var(--el-bg-color-page, #f5f7fa);
                border-radius: 8px;
                padding: 20px;
                margin-bottom: 20px;

                .info-item {
                    display: flex;
                    justify-content: center;
                    margin-bottom: 12px;
                    font-size: 15px;

                    &:last-child {
                        margin-bottom: 0;
                    }

                    .label {
                        color: var(--el-text-color-secondary);
                        margin-right: 8px;
                    }

                    .value {
                        color: var(--el-text-color-primary);
                        font-weight: 500;

                        &.amount {
                            color: var(--el-color-danger);
                            font-weight: 600;
                        }
                    }
                }
            }

            // 商品图片预览
            .goods-preview {
                margin: 0 auto 20px;
                width: 120px;
                height: 120px;
                border-radius: 8px;
                overflow: hidden;
                border: 1px solid var(--el-border-color-lighter);

                .goods-image {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    transition: transform 0.3s;

                    &:hover {
                        transform: scale(1.05);
                    }
                }
            }

            // 操作按钮
            .action-buttons {
                display: flex;
                justify-content: center;
                gap: 16px;
                margin-bottom: 20px;

                .el-button {
                    min-width: 140px;
                    border-radius: 24px;
                    transition: all 0.3s;

                    .el-icon {
                        margin-right: 6px;
                    }

                    &:hover {
                        transform: translateY(-2px);
                    }
                }
            }

            // 自动跳转提示
            .auto-redirect {
                margin-bottom: 30px;
                font-size: 14px;
                color: var(--el-text-color-secondary);
                display: flex;
                align-items: center;
                justify-content: center;

                .el-icon {
                    margin-right: 6px;
                    color: var(--el-color-primary);
                }
            }

            // 温馨提示
            .tips {
                display: flex;
                align-items: flex-start;
                background-color: rgba(var(--el-color-info-rgb), 0.05);
                border-radius: 6px;
                padding: 12px 16px;
                text-align: left;

                .tip-icon {
                    margin-right: 10px;
                    margin-top: 2px;

                    .el-icon {
                        color: var(--el-color-info);
                        font-size: 16px;
                    }
                }

                .tip-text {
                    flex: 1;
                    font-size: 13px;
                    color: var(--el-text-color-secondary);
                    line-height: 1.6;

                    p {
                        margin: 0 0 6px;
                    }

                    ol {
                        margin: 0;
                        padding-left: 20px;

                        li {
                            margin-bottom: 4px;

                            &:last-child {
                                margin-bottom: 0;
                            }
                        }
                    }
                }
            }
        }
    }
}

// 动画
@keyframes bounce {

    0%,
    20%,
    50%,
    80%,
    100% {
        transform: translateY(0);
    }

    40% {
        transform: translateY(-20px);
    }

    60% {
        transform: translateY(-10px);
    }
}

@keyframes shake {

    0%,
    100% {
        transform: translateX(0);
    }

    10%,
    30%,
    50%,
    70%,
    90% {
        transform: translateX(-5px);
    }

    20%,
    40%,
    60%,
    80% {
        transform: translateX(5px);
    }
}

// 响应式适配
@media (max-width: 768px) {
    .pay-result-page {
        padding: 30px 16px;

        .result-container {
            .result-card {
                padding: 30px 20px;

                .result-icon {
                    .el-icon {
                        font-size: 60px;
                    }
                }

                .result-info {
                    .result-title {
                        font-size: 24px;
                    }

                    .result-subtitle {
                        font-size: 14px;
                    }
                }

                .action-buttons {
                    flex-direction: column;

                    .el-button {
                        width: 100%;
                    }
                }

                .order-info {
                    .info-item {
                        flex-direction: column;
                        margin-bottom: 16px;

                        .label {
                            margin-right: 0;
                            margin-bottom: 4px;
                        }
                    }
                }
            }
        }
    }
}
</style>