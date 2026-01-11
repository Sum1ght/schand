<script setup>
/**
 * 商品详情页组件
 * 展示特定商品的详细信息
 */
import { getAllAddressAPI } from '@/api/addressAPI'
import { addChatGroupAPI } from '@/api/chatAPI'
import { addCollectAPI } from '@/api/collectAPI'
import { getGoodsByIdAPI, updateGoodsReadCountAPI } from '@/api/goodsAPI'
import { addLikesAPI } from '@/api/likeAPI'
import { addOrderAPI } from '@/api/orderAPI'
import { getUserByIdAPI } from '@/api/userAPI'
import { ArrowLeft, ChatDotRound, Check, Collection, Goods, Location, Money, Plus, ShoppingCartFull, Star, Wallet, View, Pointer } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import Comment from "@/components/Comment.vue"
import { useUserStore } from '@/stores/userStore'

// 路由实例
const route = useRoute()
const router = useRouter()

// 路由参数中的商品ID
const goodsId = ref(route.params.id)

// 用户sotre
const userStore = useUserStore()

//* 商品数据
// {
//     id: 1,                          // 商品ID
//     name: "苹果 iPhone 13 Pro Max",  // 商品名称
//     price: 5000.00,                 // 商品价格
//     content: "",                    // 商品详情内容
//     address: "北京市朝阳区",         // 发货地址
//     img: "http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png", // 商品图片
//     date: "2024-09-25 00:00:00",    // 发布时间
//     status: "通过",                  // 审核状态
//     category: "电子产品",            // 商品分类
//     userId: 1,                      // 发布者ID
//     saleStatus: "上架",             // 销售状态
//     readCount: 70,                  // 阅读数
//     userName: "用户1",              // 发布者名称
//     sort: null,                     // 排序字段
//     userLikes: false,               // 当前用户是否点赞
//     userCollect: false,             // 当前用户是否收藏
//     likesCount: 0,                  // 点赞数
//     collectCount: 0                 // 收藏数
// }
const goodsInfo = ref({})

// 收货地址列表
const addressList = ref([])

// 订单表单
const orderForm = ref({
    goodsId: null,
    addressId: null
})

// 选择地址
const selectedAddress = ref(null)

// 统一管理点赞收藏状态
const goodsState = ref({
    liked: false,
    collected: false,
    likesCount: 0,
    collectCount: 0
})

// 标志
const isDialogVisible = ref(false)
const isLoading = ref(true)

// 获取卖家头像
const getSellerAvator = async (userId) => {
    const res = await getUserByIdAPI(userId)
    goodsInfo.value.avatar = res.data.avatar
}

// 获取商品详情
const loadGoodsInfo = async () => {
    isLoading.value = true

    try {
        // 调用API
        const res = await getGoodsByIdAPI(goodsId.value)
        goodsInfo.value = res.data || {}
        console.log('商品详情', res.data)

        // 初始化状态
        goodsState.value.liked = goodsInfo.value.userLikes || false
        goodsState.value.collected = goodsInfo.value.userCollect || false
        goodsState.value.likesCount = goodsInfo.value.likesCount || 0
        goodsState.value.collectCount = goodsInfo.value.collectCount || 0

        // 获取卖家头像
        getSellerAvator(goodsInfo.value.userId)
    } catch (error) {
        console.error('获取商品详情出错:', error)
        ElMessage.error('获取商品详情失败')
    } finally {
        isLoading.value = false
    }
}

// 加载收货地址
const loadAddressList = async () => {
    try {
        // 调用API
        const res = await getAllAddressAPI({ userId: userStore.userInfo.id })
        addressList.value = res.data || []
    } catch (error) {
        console.error('获取地址列表出错:', error)
        ElMessage.error('获取地址列表失败')
    }
}

// 点赞商品
const handleLike = async () => {
    // 立即反馈用户操作
    goodsState.value.liked = !goodsState.value.liked
    goodsState.value.likesCount += goodsState.value.liked ? 1 : -1

    // 确保点赞数不为负数
    goodsState.value.likesCount = Math.max(0, goodsState.value.likesCount)

    // 调用API
    try {
        await addLikesAPI({ fid: goodsInfo.value.id, module: 'goods' })
    } catch (error) {
        // 如果请求出错，恢复状态
        goodsState.value.liked = !goodsState.value.liked
        goodsState.value.likesCount += goodsState.value.liked ? 1 : -1
        goodsState.value.likesCount = Math.max(0, goodsState.value.likesCount)

        console.error('点赞出错:', error)
        ElMessage.error('点赞失败')
    }
}

// 收藏商品
const handleCollect = async () => {
    // 立即反馈用户操作
    goodsState.value.collected = !goodsState.value.collected
    goodsState.value.collectCount += goodsState.value.collected ? 1 : -1

    // 确保收藏数不为负数
    goodsState.value.collectCount = Math.max(0, goodsState.value.collectCount)

    try {
        // 调用API
        await addCollectAPI({ fid: goodsInfo.value.id, module: 'goods' })
    } catch (error) {
        // 如果请求出错，恢复状态
        goodsState.value.collected = !goodsState.value.collected
        goodsState.value.collectCount += goodsState.value.collected ? 1 : -1
        goodsState.value.collectCount = Math.max(0, goodsState.value.collectCount)

        console.error('收藏出错:', error)
        ElMessage.error('操作失败')
    }
}

// 打开购买对话框
const openBuyDialog = () => {
    // 验证当前用户
    if (!userStore.userInfo.id) {
        ElMessage.warning('请先登录')
        router.push('/login')
        return
    }

    // 如果有地址，默认选中第一个
    if (addressList.value.length > 0) {
        orderForm.value.goodsId = goodsInfo.value.id
        orderForm.value.addressId = addressList.value[0].id
        selectedAddress.value = addressList.value[0]
    } else {
        ElMessage.warning('请先添加收货地址')
        router.push('/personal/myaddress')
        return
    }

    isDialogVisible.value = true
}

// 监听地址选择变化
const handleAddressChange = () => {
    const selectedAddr = addressList.value.find(addr => addr.id === orderForm.value.addressId)
    if (selectedAddr) {
        selectedAddress.value = selectedAddr
    }
}

// 提交订单
const submitOrder = async () => {
    // 简单验证
    if (!orderForm.value.addressId) {
        ElMessage.warning('请选择收货地址')
        return
    }

    try {
        // 调用API
        const res = await addOrderAPI(orderForm.value)
        console.log("addOrderAPI返回", res)
        ElMessage.success('下单成功')
        isDialogVisible.value = false

        // 询问用户是否立即支付
        ElMessageBox.confirm(
            '订单已创建成功，是否立即前往支付？',
            '下单成功',
            {
                confirmButtonText: '去支付',
                cancelButtonText: '稍后支付',
                type: 'success'
            }
        ).then(() => {
            router.push('/personal/myorder')
        }).catch(() => {
            router.push('/square')
        })
    } catch (error) {
        console.error('下单出错:', error)
        ElMessage.error('下单失败')
    }
}

// 联系卖家
const contactSeller = async (userId) => {
    // 验证当前用户
    if (!userStore.userInfo.id) {
        ElMessage.warning('请先登录')
        return
    }
    try {
        // 调用API
        await addChatGroupAPI({
            chatUserId: userId,
            userId: userStore.userInfo.id
        })
        //* console > elmessage > router
        ElMessage.success('已成功连接卖家')
        router.push('/chat')
    } catch (error) {
        console.error('聊天出错:', error)
        ElMessage.error('连接卖家失败')
    }
}

// 生命周期钩子
onMounted(() => {
    // 更新浏览数并加载详情
    updateGoodsReadCountAPI(goodsId.value).then(() => {
        loadGoodsInfo()
    })
    // 加载收货地址
    loadAddressList()
})
</script>

<template>
    <div class="goods-detail-container">
        <!-- 顶部导航栏 -->
        <el-card class="detail-card header-card" shadow="hover">
            <div class="detail-nav">
                <el-button @click="router.push('/square')" text class="back-btn">
                    <el-icon>
                        <ArrowLeft />
                    </el-icon>
                    返回广场
                </el-button>
                <div class="page-title">商品详情</div>
            </div>
        </el-card>

        <!-- 加载中 -->
        <div v-if="isLoading" class="loading-container">
            <el-skeleton animated>
                <template #template>
                    <div style="padding: 20px;">
                        <el-skeleton-item variant="h1" style="width: 50%" />
                        <div style="display: flex; align-items: center; margin: 20px 0;">
                            <el-skeleton-item variant="circle" style="margin-right: 16px; width: 40px; height: 40px;" />
                            <el-skeleton-item variant="text" style="width: 30%" />
                        </div>
                        <el-skeleton-item variant="text" style="width: 100%; margin-bottom: 16px" />
                        <el-skeleton-item variant="text" style="width: 100%; margin-bottom: 16px" />
                        <el-skeleton-item variant="text" style="width: 90%; margin-bottom: 16px" />
                    </div>
                </template>
            </el-skeleton>
        </div>

        <!-- 主内容 -->
        <template v-else-if="goodsInfo">
            <!-- 商品信息卡片 -->
            <el-card class="detail-card" shadow="hover">
                <div class="goods-main-info">
                    <!-- 商品图片 -->
                    <div class="goods-image-container">
                        <el-image :src="goodsInfo.img" :preview-src-list="[goodsInfo.img]" fit="cover"
                            class="goods-image"></el-image>
                    </div>

                    <!-- 商品概览信息 -->
                    <div class="goods-info-container">
                        <div class="detail-title-section">
                            <h1 class="detail-title">{{ goodsInfo.name }}</h1>
                        </div>
                        <!-- 价格 -->
                        <div class="goods-price">
                            <el-icon>
                                <Money />
                            </el-icon>
                            <span>¥{{ goodsInfo.price }}</span>
                        </div>
                        <!-- 数据 -->
                        <div class="detail-meta">
                            <!-- 发布者 -->
                            <div class="publisher-info">
                                <el-avatar
                                    :src="goodsInfo.avatar || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'"
                                    :size="40"></el-avatar>
                                <div class="publisher-meta">
                                    <div class="publisher-name">{{ goodsInfo.userName }}</div>
                                    <div class="publish-time">发布于：{{ goodsInfo.date }}</div>
                                </div>
                                <el-button type="primary" size="small" @click="contactSeller(goodsInfo.userId)"
                                    class="contact-btn" plain>
                                    <el-icon>
                                        <ChatDotRound />
                                    </el-icon>
                                    联系卖家
                                </el-button>
                            </div>
                            <!-- 浏览/点赞/收藏/发货地 -->
                            <div class="meta-tags">
                                <div class="meta-tag">
                                    <el-icon>
                                        <View />
                                    </el-icon>
                                    <span>浏览:{{ goodsInfo.readCount }}</span>
                                </div>
                                <div class="meta-tag">
                                    <el-icon>
                                        <Pointer />
                                    </el-icon>
                                    <span>点赞:
                                        <span class="count-number">
                                            {{ goodsState.likesCount }}
                                        </span>
                                    </span>
                                </div>
                                <div class="meta-tag">
                                    <el-icon>
                                        <Star />
                                    </el-icon>
                                    <span>收藏:
                                        <span class="count-number">
                                            {{ goodsState.collectCount }}
                                        </span>
                                    </span>
                                </div>
                                <div class="meta-tag">
                                    <el-icon>
                                        <Location />
                                    </el-icon>
                                    <span>发货地:  {{ goodsInfo.address }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- 互动按钮组 -->
                        <div class="goods-actions">
                            <!-- 点赞 -->
                            <el-button @click="handleLike" :type="goodsState.liked ? 'danger' : 'default'"
                                class="action-button" :class="{ 'is-active': goodsState.liked }">
                                <el-icon>
                                    <Star />
                                </el-icon>
                                {{ goodsState.liked ? '已点赞' : '点赞' }}
                            </el-button>
                            <!-- 收藏 -->
                            <el-button @click="handleCollect" :type="goodsState.collected ? 'warning' : 'default'"
                                class="action-button" :class="{ 'is-active': goodsState.collected }">
                                <el-icon>
                                    <Collection />
                                </el-icon>
                                {{ goodsState.collected ? '已收藏' : '收藏' }}
                            </el-button>
                            <!-- 购买 -->
                            <el-button @click="openBuyDialog" type="danger" class="action-button buy-button">
                                <el-icon>
                                    <ShoppingCartFull />
                                </el-icon>
                                立即购买
                            </el-button>
                        </div>
                    </div>
                </div>

                <!-- 商品详情内容 -->
                <div class="content-container">
                    <div class="content-text" v-html="goodsInfo.content"></div>
                </div>
            </el-card>

            <!-- 评论区卡片 -->
            <el-card class="detail-card comment-card" shadow="hover">
                <div class="comment-container">
                    <Comment :fid="Number(goodsId)" module="goods" theme="light" placeholder="分享你对这个商品的看法..." />
                </div>
            </el-card>
        </template>

        <!-- 无数据展示 -->
        <el-empty v-else description="找不到该商品信息" :image-size="200">
            <el-button type="primary" @click="router.push('/goods')">返回列表</el-button>
        </el-empty>

        <!-- 购买对话框 -->
        <el-dialog title="确认订单信息" v-model="isDialogVisible" width="550px" :close-on-click-modal="false" destroy-on-close
            custom-class="order-confirm-dialog">
            <div class="order-form">
                <!-- 顶部标题 -->
                <div class="order-header">
                    <div class="step-indicator">
                        <div class="step active">
                            <div class="step-icon">1</div>
                            <div class="step-label">确认订单</div>
                        </div>
                        <div class="step-divider"></div>
                        <div class="step">
                            <div class="step-icon">2</div>
                            <div class="step-label">支付</div>
                        </div>
                        <div class="step-divider"></div>
                        <div class="step">
                            <div class="step-icon">3</div>
                            <div class="step-label">完成</div>
                        </div>
                    </div>
                </div>

                <!-- 商品信息预览 -->
                <div class="order-section" v-if="goodsInfo">
                    <div class="section-header">
                        <div class="section-title">
                            <el-icon>
                                <Goods />
                            </el-icon>
                            <span>商品信息</span>
                        </div>
                    </div>
                    <div class="order-goods-preview">
                        <el-image :src="goodsInfo.img" fit="cover" class="goods-image"></el-image>
                        <div class="goods-info">
                            <div class="goods-name text-ellipsis">{{ goodsInfo.name }}</div>
                            <div class="goods-meta">物品状态：{{ goodsInfo.state || '二手' }}</div>
                            <div class="goods-price">¥{{ goodsInfo.price }}</div>
                        </div>
                    </div>
                </div>

                <!-- 收货地址选择 -->
                <div class="order-section">
                    <div class="section-header">
                        <div class="section-title">
                            <el-icon>
                                <Location />
                            </el-icon>
                            <span>收货地址</span>
                        </div>
                        <el-button type="primary" link size="small" @click="router.push('/personal/myaddress')">
                            <el-icon>
                                <Plus />
                            </el-icon>添加新地址
                        </el-button>
                    </div>

                    <div class="address-empty" v-if="addressList.length === 0">
                        <el-empty description="暂无收货地址" :image-size="80">
                            <el-button type="primary" @click="router.push('/personal/myaddress')">
                                去添加地址
                            </el-button>
                        </el-empty>
                    </div>

                    <div class="address-selection" v-else>
                        <el-radio-group v-model="orderForm.addressId" @change="handleAddressChange">
                            <el-radio v-for="item in addressList" :key="item.id" :label="item.id" class="address-radio">
                                <div class="address-content">
                                    <div class="address-row">
                                        <span class="address-name">{{ item.name }}</span>
                                        <span class="address-phone">{{ item.phone }}</span>
                                        <span class="address-phone">{{ item.address }}</span>
                                    </div>
                                </div>
                            </el-radio>
                        </el-radio-group>
                    </div>
                </div>

                <!-- 订单摘要 -->
                <div class="order-section">
                    <div class="section-header">
                        <div class="section-title">
                            <el-icon>
                                <Wallet />
                            </el-icon>
                            <span>支付信息</span>
                        </div>
                    </div>
                    <div class="payment-details">
                        <div class="payment-row">
                            <span class="payment-label">商品金额</span>
                            <span class="payment-value">¥{{ goodsInfo?.price || 0 }}</span>
                        </div>
                        <div class="payment-row">
                            <span class="payment-label">运费</span>
                            <span class="payment-value">¥0.00</span>
                        </div>
                        <div class="payment-divider"></div>
                        <div class="payment-row total">
                            <span class="payment-label">实付金额</span>
                            <span class="total-amount">¥{{ goodsInfo?.price || 0 }}</span>
                        </div>
                    </div>
                </div>
            </div>
            <template #footer>
                <div class="dialog-footer">
                    <div class="footer-summary">
                        <span class="summary-text">共1件商品，实付：</span>
                        <span class="summary-price">¥{{ goodsInfo?.price || 0 }}</span>
                    </div>
                    <div class="footer-buttons">
                        <el-button @click="isDialogVisible = false">取 消</el-button>
                        <el-button type="primary" @click="submitOrder">
                            <el-icon>
                                <Check />
                            </el-icon>确认下单
                        </el-button>
                    </div>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
.goods-detail-container {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;

    @media (max-width: 768px) {
        padding: 16px 12px;
    }
}

.detail-card {
    border-radius: 8px;
    margin-bottom: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05) !important;
    background-color: #fff;
    transition: transform 0.3s, box-shadow 0.3s;

    &:hover {
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1) !important;
    }
}

.header-card {
    background-color: #f7f9fc;
}

.detail-nav {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .back-btn {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #606266;
        font-weight: 500;

        &:hover {
            color: var(--el-color-primary);
        }
    }

    .page-title {
        font-size: 20px;
        font-weight: 600;
        color: #303133;
    }
}

.loading-container {
    background-color: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    margin-bottom: 24px;
}

.goods-main-info {
    display: flex;
    margin-bottom: 30px;

    @media (max-width: 768px) {
        flex-direction: column;
    }
}

.goods-image-container {
    width: 350px;
    height: 350px;
    margin-right: 30px;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

    @media (max-width: 768px) {
        width: 100%;
        height: auto;
        margin-right: 0;
        margin-bottom: 20px;
    }

    .goods-image {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
}

.goods-info-container {
    flex: 1;
}

.detail-title-section {
    margin-bottom: 15px;

    .detail-title {
        margin: 0;
        font-size: 24px;
        font-weight: 600;
        color: #303133;
        line-height: 1.4;

        @media (max-width: 768px) {
            font-size: 20px;
        }
    }
}

.goods-price {
    font-size: 28px;
    font-weight: 700;
    color: #ff6b00;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 5px;
}

.detail-meta {
    background-color: #f9f9f9;
    padding: 16px;
    border-radius: 8px;
    margin-bottom: 20px;

    .publisher-info {
        display: flex;
        align-items: center;
        margin-bottom: 15px;

        .publisher-meta {
            margin-left: 12px;
            flex: 1;

            .publisher-name {
                font-weight: 500;
                color: #303133;
                font-size: 15px;
            }

            .publish-time {
                font-size: 13px;
                color: #909399;
                margin-top: 4px;
            }
        }

        .contact-btn {
            font-size: 13px;
        }
    }

    .meta-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;

        .meta-tag {
            margin-right: 16px;
            font-size: 14px;
            color: var(--el-text-color-secondary);
            display: flex;
            align-items: center;

            .el-icon {
                margin-right: 4px;
                font-size: 16px;
            }

            .count-number {
                color: var(--el-text-color-primary);
                font-weight: 500;
            }
        }
    }
}

.goods-actions {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;

    .action-button {
        display: flex;
        align-items: center;
        gap: 5px;
        transition: all 0.3s ease;
        position: relative;
        overflow: hidden;

        &:active {
            transform: scale(0.95);
        }

        &.is-active {
            font-weight: 500;
            transform: scale(1.02);
        }

        .el-icon {
            transition: transform 0.3s ease;
        }

        &:hover .el-icon {
            transform: scale(1.2);
        }

        &.buy-button {
            margin-left: auto;
        }
    }
}

.content-container {
    margin-top: 20px;
    padding-top: 20px;
    border-top: 1px solid #ebeef5;
    background-color: #f9fafc;
    border-radius: 8px;
    padding: 24px;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);

    .content-text {
        line-height: 1.7;
        color: #303133;
        word-break: break-word;
        font-size: 15px;
        padding: 4px;

        ::v-deep(img) {
            max-width: 100%;
            height: auto;
            border-radius: 4px;
            margin: 8px 0;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        ::v-deep(p) {
            margin: 12px 0;
        }

        ::v-deep(a) {
            color: var(--el-color-primary);
            text-decoration: none;

            &:hover {
                text-decoration: underline;
            }
        }

        ::v-deep(ul, ol) {
            padding-left: 24px;
            margin: 12px 0;
        }

        ::v-deep(h1, h2, h3, h4, h5, h6) {
            margin: 16px 0 12px;
            color: #303133;
        }

        ::v-deep(table) {
            width: 100%;
            border-collapse: collapse;
            margin: 16px 0;

            th,
            td {
                border: 1px solid #ebeef5;
                padding: 8px 12px;
            }

            th {
                background-color: #f5f7fa;
            }
        }

        ::v-deep(blockquote) {
            margin: 16px 0;
            padding: 8px 16px;
            border-left: 4px solid #409EFF;
            background-color: #ecf5ff;
            color: #606266;
        }

        ::v-deep(code) {
            background-color: #f5f7fa;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: Consolas, Monaco, 'Andale Mono', monospace;
            color: #f56c6c;
            font-size: 14px;
        }

        ::v-deep(pre) {
            background-color: #282c34;
            padding: 16px;
            border-radius: 4px;
            overflow-x: auto;

            code {
                background-color: transparent;
                color: #abb2bf;
                padding: 0;
            }
        }
    }
}

.comment-card {
    background-color: #fcfcfc;
}

.comment-container {
    padding: 8px 0;
    max-height: 2000px;
    overflow: hidden;
    transition: max-height 0.5s ease, opacity 0.5s ease;
    opacity: 1;
}

.address-selection {
    max-height: 300px;
    overflow-y: auto;
    margin-bottom: 16px;

    .section-title {
        font-weight: 500;
        margin-bottom: 12px;
        color: #303133;
        font-size: 16px;
    }

    .address-radio {
        display: flex;
        width: 100%;
        margin-bottom: 12px;
        padding: 14px 16px;
        border-radius: 8px;
        border: 1px solid #e4e7ed;
        transition: all 0.25s ease;
        background-color: #f0f6ff;
        position: relative;

        &:hover {
            background-color: #e6f1ff;
            transform: translateY(-2px);
            border-color: #c6e0ff;
        }

        &.is-checked {
            border-color: var(--el-color-primary);
            background-color: #ecf5ff;
            box-shadow: 0 2px 8px rgba(64, 158, 255, 0.15);
        }

        .address-content {
            margin-left: 6px;
            align-items: center;
            flex: 1;
        }

        .address-row {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;

            .address-name {
                font-weight: 600;
                color: #303133;
                font-size: 16px;
            }

            .address-phone {
                color: #606266;
                font-size: 15px;
            }
        }
    }

    .no-address {
        text-align: center;
        padding: 20px;
        color: #909399;
    }
}

.el-dialog.order-confirm-dialog {
    border-radius: 12px;
    overflow: hidden;

    :deep(.el-dialog__header) {
        margin: 0;
        padding: 18px 24px;
        border-bottom: 1px solid #ebeef5;
        background-color: #f7f9fc;

        .el-dialog__title {
            font-weight: 600;
            font-size: 18px;
            color: #303133;
        }
    }

    :deep(.el-dialog__body) {
        padding: 0;
    }

    :deep(.el-dialog__footer) {
        padding: 16px 24px;
        border-top: 1px solid #ebeef5;
        background-color: #f7f9fc;
    }
}

.order-form {
    .order-header {
        padding: 24px 20px;
        border-bottom: 1px solid #f0f2f5;

        .step-indicator {
            display: flex;
            align-items: center;
            justify-content: space-between;

            .step {
                display: flex;
                flex-direction: column;
                align-items: center;
                flex: 1;

                .step-icon {
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    background-color: #ebeef5;
                    color: #909399;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-weight: 600;
                    margin-bottom: 8px;
                    transition: all 0.3s;
                }

                .step-label {
                    font-size: 14px;
                    color: #909399;
                    transition: all 0.3s;
                }

                &.active {
                    .step-icon {
                        background-color: var(--el-color-primary);
                        color: white;
                    }

                    .step-label {
                        color: var(--el-color-primary);
                        font-weight: 500;
                    }
                }
            }

            .step-divider {
                height: 1px;
                background-color: #ebeef5;
                flex: 1;
                margin: 0 10px;
                margin-bottom: 20px;
            }
        }
    }

    .order-section {
        padding: 20px 24px;
        border-bottom: 1px solid #f0f2f5;

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;

            .section-title {
                display: flex;
                align-items: center;
                gap: 8px;
                font-weight: 600;
                font-size: 16px;
                color: #303133;

                .el-icon {
                    color: var(--el-color-primary);
                }
            }
        }
    }

    .order-goods-preview {
        display: flex;
        align-items: center;
        padding: 16px;
        background-color: #f9fafc;
        border-radius: 8px;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);

        .goods-image {
            width: 80px;
            height: 80px;
            border-radius: 8px;
            object-fit: cover;
            margin-right: 16px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }

        .goods-info {
            flex: 1;

            .goods-name {
                font-weight: 500;
                color: #303133;
                margin-bottom: 6px;
                line-height: 1.4;
                font-size: 16px;
            }

            .goods-meta {
                color: #909399;
                font-size: 13px;
                margin-bottom: 8px;
            }

            .goods-price {
                color: #ff6b00;
                font-weight: 600;
                font-size: 20px;
                margin-bottom: 0;
            }
        }
    }

    .text-ellipsis {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .address-empty {
        padding: 20px 0;
        text-align: center;
    }

    .address-selection {
        max-height: 220px;
        overflow-y: auto;
        scrollbar-width: thin;
        border-radius: 8px;

        &::-webkit-scrollbar {
            width: 6px;
        }

        &::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }

        &::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 10px;
        }
    }

    .payment-details {
        background-color: #f8fafc;
        border-radius: 8px;
        padding: 16px;
        margin-top: 12px;

        .payment-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;

            .payment-label {
                color: #606266;
                font-size: 14px;
            }

            .payment-value {
                font-size: 14px;
                color: #303133;
            }

            &.total {
                margin-top: 8px;
                margin-bottom: 0;

                .payment-label {
                    font-weight: 500;
                    color: #303133;
                }

                .total-amount {
                    font-size: 18px;
                    font-weight: 600;
                    color: #f56c6c;
                }
            }
        }

        .payment-divider {
            height: 1px;
            background-color: #ebeef5;
            margin: 12px 0;
        }
    }
}

.dialog-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;

    .footer-summary {
        display: flex;
        align-items: center;

        .summary-text {
            font-size: 14px;
            color: #606266;
        }

        .summary-price {
            font-size: 18px;
            font-weight: 600;
            color: #f56c6c;
            margin-left: 8px;
        }
    }

    .footer-buttons {
        display: flex;
        gap: 12px;
    }
}
</style>