<!-- eslint-disable vue/multi-word-component-names -->
<script setup>
/**
 * 订单支付页面
 * 展示订单支付信息，提供支付倒计时和支付方式选择
 */
import { getOrderByIdAPI, updateOrderAPI } from '@/api/orderAPI'
import {
    ArrowLeft,
    Document,
    InfoFilled,
    Timer,
    Wallet
} from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

// 路由参数和导航
const route = useRoute()
const router = useRouter()
const orderNo = route.query.orderNo

// 订单数据状态
const orderInfo = ref({})
const loading = ref(true)

// 支付倒计时相关状态
const countdown = reactive({
    total: 30 * 60, // 默认30分钟倒计时
    minutes: 30,
    seconds: 0,
    timer: null,
    expired: false
})

// 支付方式选择
const paymentMethod = ref('alipay') // 默认支付宝支付

// 模拟支付弹窗状态
const mockPayDialogVisible = ref(false)
const mockPayLoading = ref(false)
const mockPaySuccess = ref(false)
const password = ref('')

// 格式化金额
const formatPrice = (price) => {
    if (!price && price !== 0) return '¥0.00'
    return `¥${Number(price).toFixed(2)}`
}

// 格式化日期为标准格式 yyyy-MM-dd HH:mm:ss
const formatDate = (date) => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

// 获取订单信息
const getOrderInfo = async () => {
    if (!orderNo) {
        ElMessage.error('订单编号不存在')
        router.push('/personal/myorder')
        return
    }

    try {
        loading.value = true
        const { data } = await getOrderByIdAPI(route.query.orderId || route.query.id)

        if (!data) {
            ElMessage.error('订单不存在')
            router.push('/personal/myorder')
            return
        }

        orderInfo.value = data

        // 如果订单已支付或已取消，跳转到订单列表
        if (data.status !== '待支付') {
            ElMessage.warning('当前订单无需支付')
            router.push('/personal/myorder')
            return
        }

        // 初始化倒计时
        startCountdown()
    } catch (error) {
        console.error('获取订单信息失败:', error)
        ElMessage.error('获取订单信息失败')
    } finally {
        loading.value = false
    }
}

// 开始倒计时
const startCountdown = () => {
    // 清除可能存在的计时器
    if (countdown.timer) {
        clearInterval(countdown.timer)
    }

    // 计算剩余支付时间，一般从下单时间算起30分钟
    const orderTime = new Date(orderInfo.value.time || Date.now())
    const expirationTime = new Date(orderTime.getTime() + 30 * 60 * 1000) // 30分钟后
    const now = new Date()

    // 计算剩余秒数
    let remainingSeconds = Math.max(0, Math.floor((expirationTime - now) / 1000))

    // 如果已过期
    if (remainingSeconds <= 0) {
        countdown.minutes = 0
        countdown.seconds = 0
        countdown.expired = true
        // 订单已过期，立即执行取消操作
        cancelOrder().then(() => {
            ElMessageBox.alert('支付时间已过期，订单已自动取消', '支付超时', {
                confirmButtonText: '返回订单列表',
                callback: () => {
                    router.push('/personal/myorder')
                }
            })
        })
        return
    }

    // 更新倒计时状态
    updateCountdownDisplay(remainingSeconds)

    // 设置定时器
    countdown.timer = setInterval(() => {
        remainingSeconds--

        if (remainingSeconds <= 0) {
            clearInterval(countdown.timer)
            countdown.expired = true
            countdown.minutes = 0
            countdown.seconds = 0

            // 倒计时结束，立即执行取消订单操作
            cancelOrder().then(() => {
                ElMessageBox.alert('支付时间已过期，订单已自动取消', '支付超时', {
                    confirmButtonText: '返回订单列表',
                    callback: () => {
                        router.push('/personal/myorder')
                    }
                })
            }).catch(error => {
                console.error('自动取消订单失败:', error)
                ElMessage.error('订单取消失败，请刷新页面')
            })

        } else {
            updateCountdownDisplay(remainingSeconds)
        }
    }, 1000)
}

// 更新倒计时显示
const updateCountdownDisplay = (totalSeconds) => {
    countdown.minutes = Math.floor(totalSeconds / 60)
    countdown.seconds = totalSeconds % 60
    countdown.total = totalSeconds
}

// 取消订单
const cancelOrder = async () => {
    try {
        if (orderInfo.value.status !== '已取消') {
            // 只有非已取消状态的订单才需要执行取消操作
            const res = await updateOrderAPI({
                id: orderInfo.value.id,
                status: '已取消'
            })

            if (res.code === '200') {
                console.log('订单已自动取消')
                // 更新本地订单状态
                orderInfo.value.status = '已取消'
                return true
            } else {
                throw new Error(res.msg || '取消订单失败')
            }
        }
        return true
    } catch (error) {
        console.error('取消订单失败:', error)
        ElMessage.error('取消订单失败')
        throw error
    }
}

// 返回订单列表
const goBack = () => {
    router.push('/personal/myorder')
}

// 前往支付
const goToPay = () => {
    if (countdown.expired) {
        ElMessage.warning('支付时间已过期，订单已自动取消')
        return
    }

    // 显示模拟支付弹窗
    mockPayDialogVisible.value = true
    password.value = ''
    mockPaySuccess.value = false
}

// 确认模拟支付
const confirmMockPay = async () => {
    if (!password.value) {
        ElMessage.warning('请输入支付密码')
        return
    }

    mockPayLoading.value = true

    try {
        // 模拟支付过程，1.5秒后完成
        await new Promise(resolve => setTimeout(resolve, 1500))
        mockPayLoading.value = false
        mockPaySuccess.value = true

        // 生成支付单号
        const timestamp = new Date().getTime().toString()
        const randomPart = Math.floor(Math.random() * 1000000).toString().padStart(6, '0')
        const payNo = `PAY${timestamp}${randomPart}`

        // 更新订单状态为待发货
        await updateOrderAPI({
            id: orderInfo.value.id,
            status: '待发货',
            payTime: formatDate(new Date()), // 格式化为yyyy-MM-dd HH:mm:ss格式
            payNo: payNo.substring(0, 200) // 确保不超过varchar(255)长度限制
        })

        // 2秒后自动跳转到支付结果页
        setTimeout(() => {
            mockPayDialogVisible.value = false

            // 跳转到支付结果页面
            router.push({
                path: '/payback',
                query: {
                    orderId: orderInfo.value.id,
                    payResult: 'true'
                }
            })
        }, 2000)
    } catch (error) {
        console.error('支付过程中出错:', error)
        mockPayLoading.value = false
        mockPaySuccess.value = false
        ElMessage.error('支付失败，请稍后重试')
    }
}

// 生命周期钩子
onMounted(() => {
    getOrderInfo()
})

onBeforeUnmount(() => {
    // 清除计时器
    if (countdown.timer) {
        clearInterval(countdown.timer)
    }
})
</script>

<template>
    <div class="pay-page">
        <div class="pay-container">
            <!-- 页面标题 -->
            <div class="page-header">
                <div class="back-button" @click="goBack">
                    <el-icon>
                        <ArrowLeft />
                    </el-icon>
                    <span>返回订单列表</span>
                </div>
                <h1 class="page-title">订单支付</h1>
            </div>

            <!-- 支付信息卡片 -->
            <el-card class="pay-info-card" shadow="hover" v-loading="loading">
                <div class="pay-info">
                    <div class="pay-info-header">
                        <div class="status-icon">
                            <el-icon>
                                <Timer />
                            </el-icon>
                        </div>
                        <div class="status-info">
                            <div class="status-title">等待支付</div>
                            <div class="countdown" :class="{ 'expiring': countdown.total < 300 }">
                                <span>剩余支付时间：</span>
                                <span class="time">{{ countdown.minutes.toString().padStart(2, '0') }}:{{
                                    countdown.seconds.toString().padStart(2, '0') }}</span>
                            </div>
                            <div class="tip">
                                超时未支付，订单将自动取消
                            </div>
                        </div>
                    </div>
                    <div class="pay-amount">
                        <span class="label">应付金额</span>
                        <span class="amount">{{ formatPrice(orderInfo.total) }}</span>
                    </div>
                </div>
            </el-card>

            <!-- 订单信息卡片 -->
            <el-card class="order-info-card" shadow="hover" v-loading="loading">
                <template #header>
                    <div class="card-header">
                        <el-icon>
                            <Document />
                        </el-icon>
                        <span>订单信息</span>
                    </div>
                </template>
                <div class="order-details">
                    <div class="order-item">
                        <span class="label">订单编号</span>
                        <span class="value order-no">{{ orderInfo.orderNo }}</span>
                    </div>
                    <div class="order-item">
                        <span class="label">商品名称</span>
                        <span class="value">{{ orderInfo.goodsName }}</span>
                    </div>
                    <div class="order-item">
                        <span class="label">收货地址</span>
                        <span class="value address">{{ orderInfo.address }}</span>
                    </div>
                    <div class="order-item">
                        <span class="label">联系方式</span>
                        <span class="value">{{ orderInfo.phone }}</span>
                    </div>
                </div>
            </el-card>

            <!-- 支付方式卡片 -->
            <el-card class="payment-method-card" shadow="hover">
                <template #header>
                    <div class="card-header">
                        <el-icon>
                            <Wallet />
                        </el-icon>
                        <span>选择支付方式</span>
                    </div>
                </template>
                <div class="payment-methods">
                    <div class="method-item" :class="{ active: paymentMethod === 'alipay' }"
                        @click="paymentMethod = 'alipay'">
                        <div class="method-icon alipay"></div>
                        <div class="method-name">支付宝</div>
                        <div class="check-mark" v-if="paymentMethod === 'alipay'"></div>
                    </div>
                    <div class="method-item disabled">
                        <div class="method-icon wechat"></div>
                        <div class="method-name">微信支付</div>
                        <div class="disabled-mask">
                            <span>暂未开通</span>
                        </div>
                    </div>
                </div>
            </el-card>

            <!-- 操作按钮 -->
            <div class="action-buttons">
                <el-button @click="goBack">取消</el-button>
                <el-button type="primary" @click="goToPay" :disabled="countdown.expired">
                    <el-icon>
                        <Wallet />
                    </el-icon>
                    <span>立即支付</span>
                </el-button>
            </div>

            <!-- 温馨提示 -->
            <div class="payment-tips">
                <div class="tip-title">
                    <el-icon>
                        <InfoFilled />
                    </el-icon>
                    <span>温馨提示</span>
                </div>
                <ol class="tip-list">
                    <li>请在订单有效期内完成支付，超时订单将自动取消</li>
                    <li>支付成功后，订单状态可能会有一定延迟，可随时在订单列表查看最新状态</li>
                    <li>如遇到支付问题，请联系平台客服获取帮助</li>
                </ol>
            </div>
        </div>

        <!-- 模拟支付弹窗 -->
        <el-dialog v-model="mockPayDialogVisible" title="支付确认" width="400px" :close-on-click-modal="false"
            :close-on-press-escape="false" :show-close="!mockPayLoading && !mockPaySuccess" center>
            <div class="mock-pay-dialog">
                <!-- 支付信息 -->
                <div class="pay-info-box">
                    <div class="pay-amount-large">{{ formatPrice(orderInfo.total) }}</div>
                    <div class="pay-order-info">
                        <div class="pay-merchant">悠享二手交易平台收款</div>
                        <div class="pay-order-no">订单号: {{ orderInfo.orderNo }}</div>
                    </div>
                </div>

                <!-- 支付密码输入 -->
                <div class="password-input-area" v-if="!mockPayLoading && !mockPaySuccess">
                    <div class="input-label">
                        <span>请输入支付密码</span>
                        <a class="forget-link">忘记密码?</a>
                    </div>
                    <el-input v-model="password" type="password" show-password maxlength="6" placeholder="请输入6位数字密码"
                        class="password-input" @keyup.enter="confirmMockPay" />
                    <div class="input-tip">密码为任意6位数字即可</div>
                </div>

                <!-- 加载状态 -->
                <div class="pay-loading-area" v-if="mockPayLoading">
                    <el-icon class="loading-icon"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg"
                            data-v-029747aa="">
                            <path fill="currentColor"
                                d="M512 64a32 32 0 0 1 32 32v192a32 32 0 0 1-64 0V96a32 32 0 0 1 32-32zm0 640a32 32 0 0 1 32 32v192a32 32 0 1 1-64 0V736a32 32 0 0 1 32-32zm448-192a32 32 0 0 1-32 32H736a32 32 0 1 1 0-64h192a32 32 0 0 1 32 32zm-640 0a32 32 0 0 1-32 32H96a32 32 0 0 1 0-64h192a32 32 0 0 1 32 32zM195.2 195.2a32 32 0 0 1 45.3 0L376.8 331.5a32 32 0 0 1-45.3 45.3L195.2 240.5a32 32 0 0 1 0-45.3zm452.6 452.6a32 32 0 0 1 45.3 0l136.3 136.3a32 32 0 1 1-45.3 45.3L647.8 692.8a32 32 0 0 1 0-45.3zM828.8 195.2a32 32 0 0 1 0 45.3L692.8 376.8a32 32 0 0 1-45.3-45.3l136.3-136.3a32 32 0 0 1 45.3 0zm-452.6 452.6a32 32 0 0 1 0 45.3L240.5 828.8a32 32 0 0 1-45.3-45.3l136.3-136.3a32 32 0 0 1 45.3 0z">
                            </path>
                        </svg></el-icon>
                    <span class="loading-text">正在支付，请稍候...</span>
                </div>

                <!-- 支付成功 -->
                <div class="pay-success-area" v-if="mockPaySuccess">
                    <div class="success-icon">
                        <el-icon><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" data-v-029747aa="">
                                <path fill="currentColor"
                                    d="M512 64a448 448 0 1 1 0 896 448 448 0 0 1 0-896zm-55.808 536.384-99.52-99.584a38.4 38.4 0 1 0-54.336 54.336l126.72 126.72a38.272 38.272 0 0 0 54.336 0l262.4-262.464a38.4 38.4 0 1 0-54.272-54.336L456.192 600.384z">
                                </path>
                            </svg></el-icon>
                    </div>
                    <div class="success-text">支付成功</div>
                    <div class="success-tip">即将跳转到订单详情页...</div>
                </div>
            </div>

            <template #footer>
                <div class="dialog-footer" v-if="!mockPayLoading && !mockPaySuccess">
                    <el-button @click="mockPayDialogVisible = false">取消</el-button>
                    <el-button type="primary" @click="confirmMockPay" :disabled="!password">
                        确认支付
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style scoped lang="scss">
.pay-page {
    padding: 30px 20px;
    min-height: calc(100vh - 200px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    .pay-container {
        max-width: 800px;
        margin: 0 auto;

        // 页面标题
        .page-header {
            display: flex;
            align-items: center;
            margin-bottom: 24px;
            position: relative;

            .back-button {
                position: absolute;
                left: 0;
                display: flex;
                align-items: center;
                color: var(--el-text-color-regular);
                cursor: pointer;
                transition: color 0.3s;

                .el-icon {
                    margin-right: 6px;
                }

                &:hover {
                    color: var(--el-color-primary);
                }
            }

            .page-title {
                width: 100%;
                text-align: center;
                font-size: 22px;
                font-weight: 600;
                color: var(--el-text-color-primary);
                margin: 0;
            }
        }

        // 支付信息卡片
        .pay-info-card {
            margin-bottom: 20px;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s;

            &:hover {
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            }

            .pay-info {
                padding: 10px;

                .pay-info-header {
                    display: flex;
                    align-items: center;
                    padding: 20px;
                    background-color: rgba(var(--el-color-warning-rgb), 0.05);
                    border-radius: 8px;

                    .status-icon {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        width: 60px;
                        height: 60px;
                        background-color: var(--el-color-warning);
                        border-radius: 50%;
                        margin-right: 20px;

                        .el-icon {
                            font-size: 30px;
                            color: #fff;
                        }
                    }

                    .status-info {
                        flex: 1;

                        .status-title {
                            font-size: 18px;
                            font-weight: 600;
                            color: var(--el-color-warning);
                            margin-bottom: 8px;
                        }

                        .countdown {
                            font-size: 16px;
                            margin-bottom: 6px;

                            .time {
                                font-weight: 600;
                                color: var(--el-color-warning);
                                font-family: monospace;
                                font-size: 18px;
                            }

                            &.expiring .time {
                                color: var(--el-color-danger);
                                animation: blink 1s infinite;
                            }
                        }

                        .tip {
                            font-size: 13px;
                            color: var(--el-text-color-secondary);
                        }
                    }
                }

                .pay-amount {
                    display: flex;
                    justify-content: flex-end;
                    align-items: center;
                    padding: 20px 0 10px;
                    border-top: 1px solid var(--el-border-color-lighter);
                    margin-top: 20px;

                    .label {
                        font-size: 16px;
                        color: var(--el-text-color-regular);
                        margin-right: 12px;
                    }

                    .amount {
                        font-size: 24px;
                        font-weight: 600;
                        color: var(--el-color-danger);
                    }
                }
            }
        }

        // 订单信息卡片
        .order-info-card {
            margin-bottom: 20px;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s;

            &:hover {
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            }

            .card-header {
                display: flex;
                align-items: center;

                .el-icon {
                    margin-right: 10px;
                    color: var(--el-color-primary);
                }

                span {
                    font-size: 16px;
                    font-weight: 600;
                }
            }

            .order-details {
                padding: 10px 0;

                .order-item {
                    display: flex;
                    margin-bottom: 14px;
                    font-size: 14px;
                    line-height: 1.6;

                    &:last-child {
                        margin-bottom: 0;
                    }

                    .label {
                        width: 80px;
                        flex-shrink: 0;
                        color: var(--el-text-color-secondary);
                    }

                    .value {
                        flex: 1;
                        color: var(--el-text-color-primary);

                        &.order-no {
                            font-family: monospace;
                            letter-spacing: 0.5px;
                        }

                        &.address {
                            word-break: break-all;
                        }
                    }
                }
            }
        }

        // 支付方式卡片
        .payment-method-card {
            margin-bottom: 24px;
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.3s;

            &:hover {
                box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
            }

            .card-header {
                display: flex;
                align-items: center;

                .el-icon {
                    margin-right: 10px;
                    color: var(--el-color-primary);
                }

                span {
                    font-size: 16px;
                    font-weight: 600;
                }
            }

            .payment-methods {
                display: flex;
                flex-wrap: wrap;
                gap: 20px;
                padding: 10px 0;

                .method-item {
                    position: relative;
                    width: 120px;
                    height: 70px;
                    border: 1px solid var(--el-border-color);
                    border-radius: 8px;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    cursor: pointer;
                    transition: all 0.3s;

                    &:hover:not(.disabled) {
                        border-color: var(--el-color-primary);
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
                    }

                    &.active {
                        border-color: var(--el-color-primary);
                        background-color: rgba(var(--el-color-primary-rgb), 0.05);
                    }

                    .method-icon {
                        width: 40px;
                        height: 40px;
                        background-size: contain;
                        background-repeat: no-repeat;
                        background-position: center;
                        margin-bottom: 6px;

                        &.alipay {
                            background-image: url('https://cdn.cnbj1.fds.api.mi-img.com/mi-mall/7b6b02396368c9314528c0bbd85a2e06.png');
                        }

                        &.wechat {
                            background-image: url('https://cdn.cnbj1.fds.api.mi-img.com/mi-mall/c66f98cff8649bd5ba722c2e8067c6ca.jpg');
                        }
                    }

                    .method-name {
                        font-size: 13px;
                        color: var(--el-text-color-primary);
                    }

                    .check-mark {
                        position: absolute;
                        right: -1px;
                        top: -1px;
                        width: 0;
                        height: 0;
                        border: 12px solid transparent;
                        border-top-color: var(--el-color-primary);
                        border-right-color: var(--el-color-primary);
                        border-top-right-radius: 8px;

                        &::after {
                            content: "";
                            position: absolute;
                            top: -10px;
                            right: -10px;
                            width: 5px;
                            height: 10px;
                            border: 2px solid #fff;
                            border-top: 0;
                            border-left: 0;
                            transform: rotate(45deg);
                        }
                    }

                    &.disabled {
                        cursor: not-allowed;
                        opacity: 0.7;

                        .disabled-mask {
                            position: absolute;
                            top: 0;
                            left: 0;
                            right: 0;
                            bottom: 0;
                            background-color: rgba(255, 255, 255, 0.8);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            border-radius: 8px;

                            span {
                                padding: 2px 8px;
                                background-color: rgba(0, 0, 0, 0.3);
                                color: #fff;
                                font-size: 12px;
                                border-radius: 10px;
                            }
                        }
                    }
                }
            }
        }

        // 操作按钮
        .action-buttons {
            display: flex;
            justify-content: center;
            gap: 16px;
            margin-bottom: 30px;

            .el-button {
                width: 180px;
                height: 48px;
                border-radius: 24px;
                font-size: 16px;
                transition: all 0.3s;

                &:hover {
                    transform: translateY(-2px);
                }

                .el-icon {
                    margin-right: 6px;
                }
            }
        }

        // 温馨提示
        .payment-tips {
            background-color: rgba(var(--el-color-info-rgb), 0.05);
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 30px;

            .tip-title {
                display: flex;
                align-items: center;
                margin-bottom: 12px;
                color: var(--el-color-info);

                .el-icon {
                    margin-right: 6px;
                }

                span {
                    font-weight: 600;
                }
            }

            .tip-list {
                margin: 0;
                padding-left: 24px;
                color: var(--el-text-color-secondary);
                font-size: 13px;
                line-height: 1.6;

                li {
                    margin-bottom: 6px;

                    &:last-child {
                        margin-bottom: 0;
                    }
                }
            }
        }
    }
}

// 动画
@keyframes blink {
    0% {
        opacity: 1;
    }

    50% {
        opacity: 0.5;
    }

    100% {
        opacity: 1;
    }
}

// 响应式适配
@media screen and (max-width: 768px) {
    .pay-page {
        padding: 20px 16px;

        .pay-container {
            .pay-info-card {
                .pay-info {
                    .pay-info-header {
                        flex-direction: column;
                        text-align: center;

                        .status-icon {
                            margin-right: 0;
                            margin-bottom: 16px;
                        }
                    }

                    .pay-amount {
                        flex-direction: column;
                        align-items: center;

                        .label {
                            margin-right: 0;
                            margin-bottom: 8px;
                        }
                    }
                }
            }

            .payment-methods {
                justify-content: center;
            }

            .action-buttons {
                flex-direction: column;
                align-items: center;

                .el-button {
                    width: 100%;
                }
            }
        }
    }
}

// 模拟支付弹窗样式
.mock-pay-dialog {
    .pay-info-box {
        text-align: center;
        padding-bottom: 20px;
        margin-bottom: 20px;
        border-bottom: 1px solid var(--el-border-color-lighter);

        .pay-amount-large {
            font-size: 32px;
            font-weight: 600;
            color: var(--el-color-danger);
            margin-bottom: 10px;
        }

        .pay-order-info {
            font-size: 14px;
            color: var(--el-text-color-secondary);

            .pay-merchant {
                margin-bottom: 6px;
                font-weight: 500;
                color: var(--el-text-color-primary);
            }

            .pay-order-no {
                font-size: 13px;
            }
        }
    }

    .password-input-area {
        padding: 0 10px;

        .input-label {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;

            .forget-link {
                color: var(--el-color-primary);
                font-size: 13px;
                cursor: pointer;

                &:hover {
                    text-decoration: underline;
                }
            }
        }

        .password-input {
            margin-bottom: 10px;

            :deep(.el-input__wrapper) {
                padding: 0 15px;
                height: 50px;

                .el-input__inner {
                    font-size: 18px;
                    letter-spacing: 5px;
                    text-align: center;
                }
            }
        }

        .input-tip {
            font-size: 12px;
            color: var(--el-text-color-secondary);
            text-align: center;
        }
    }

    .pay-loading-area,
    .pay-success-area {
        padding: 30px 0;
        text-align: center;

        .loading-icon {
            font-size: 48px;
            color: var(--el-color-primary);
            margin-bottom: 20px;
            animation: spin 1.5s linear infinite;
        }

        .loading-text {
            font-size: 16px;
            color: var(--el-text-color-primary);
        }

        .success-icon {
            font-size: 60px;
            color: var(--el-color-success);
            margin-bottom: 20px;
            animation: scale-in 0.5s ease;
        }

        .success-text {
            font-size: 24px;
            color: var(--el-color-success);
            font-weight: 600;
            margin-bottom: 10px;
        }

        .success-tip {
            font-size: 14px;
            color: var(--el-text-color-secondary);
        }
    }
}

@keyframes spin {
    0% {
        transform: rotate(0deg);
    }

    100% {
        transform: rotate(360deg);
    }
}

@keyframes scale-in {
    0% {
        transform: scale(0);
        opacity: 0;
    }

    100% {
        transform: scale(1);
        opacity: 1;
    }
}
</style>