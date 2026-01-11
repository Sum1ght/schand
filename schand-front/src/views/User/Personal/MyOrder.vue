<script setup>
/**
 * 我的订单页面
 * 包含购买订单和销售订单两大类型，支持订单搜索、状态筛选和状态变更功能
 */
import {
  getUserOrdersAPI,
  getUserSaleOrdersAPI,
  updateOrderAPI,
  deleteOrderAPI
} from '@/api/orderAPI'
import { useUserStore } from '@/stores/userStore'
import { computed, onMounted, reactive, watch, ref } from 'vue'
import { useRouter } from 'vue-router'

// 导入Element Plus图标组件
import {
  Tickets,
  Box,
  Calendar,
  CircleCheck,
  CircleClose,
  Close,
  Delete,
  Document,
  DocumentCopy,
  InfoFilled,
  Picture,
  RefreshRight,
  Search,
  ShoppingBag,
  Sell,
  Timer,
  Van,
  Wallet,
  Link
} from '@element-plus/icons-vue'

// ===== 状态管理 =====
const userStore = useUserStore()
const user = computed(() => userStore.userInfo)
const router = useRouter()

// 页面状态
const pageState = reactive({
  orderType: 'purchase', // purchase: 购买订单, sale: 售卖订单
  showDetail: false,
  activeOrder: null,
  loading: false,
  orders: [],
  total: 0,
  page: 1,
  pageSize: 10
})

// 物流信息表单弹窗状态
const shippingState = reactive({
  visible: false,
  loading: false,
  order: null
})

// 物流信息表单
const shippingForm = reactive({
  courierCompany: '',
  trackingNo: ''
})

// 搜索条件
const searchParams = reactive({
  goodsName: '',    // 商品名称
  orderNo: '',      // 订单编号
  status: ''        // 订单状态
})

// ===== 计算属性 =====

// 订单类型标签
const orderTypeOptions = [
  { label: '购买', value: 'purchase', icon: ShoppingBag },
  { label: '售卖', value: 'sale', icon: Sell }
]

// 订单状态选项
const orderStatusOptions = [
  { label: '全部状态', value: '' },
  { label: '待支付', value: '待支付' },
  { label: '待发货', value: '待发货' },
  { label: '待收货', value: '待收货' },
  { label: '已完成', value: '已完成' },
  { label: '已取消', value: '已取消' }
]

// 状态对应的样式
const statusTypeMap = {
  '已取消': { type: 'danger', icon: CircleClose },
  '待支付': { type: 'warning', icon: Timer },
  '待发货': { type: 'primary', icon: Box },
  '待收货': { type: 'info', icon: Van },
  '已完成': { type: 'success', icon: CircleCheck }
}

// 空状态提示信息
const emptyText = computed(() => {
  if (pageState.loading) return '正在加载订单数据...'
  if (pageState.orders.length === 0) {
    if (hasSearchParams.value) return '没有找到符合条件的订单'
    return pageState.orderType === 'purchase' ? '您还没有购买过商品' : '您还没有出售过商品'
  }
  return ''
})

// 是否有搜索条件
const hasSearchParams = computed(() =>
  Boolean(searchParams.goodsName || searchParams.orderNo || searchParams.status)
)

// 物流公司选项
const courierOptions = [
  { label: '顺丰速运', value: '顺丰速运', website: 'https://www.sf-express.com' },
  { label: '中通快递', value: '中通快递', website: 'https://www.zto.com' },
  { label: '圆通速递', value: '圆通速递', website: 'https://www.yto.net.cn' },
  { label: '韵达速递', value: '韵达速递', website: 'https://www.yundaex.com' },
  { label: '申通快递', value: '申通快递', website: 'https://www.sto.cn' },
  { label: '百世快递', value: '百世快递', website: 'https://www.800best.com' },
  { label: '邮政EMS', value: '邮政EMS', website: 'https://www.ems.com.cn' },
  { label: '京东物流', value: '京东物流', website: 'https://www.jdl.com' }
]

// 物流表单验证规则
const shippingRules = {
  courierCompany: [
    { required: true, message: '请选择快递公司', trigger: 'change' }
  ],
  trackingNo: [
    { required: true, message: '请输入快递单号', trigger: 'blur' },
    { min: 5, message: '快递单号长度至少为 5 个字符', trigger: 'blur' }
  ]
}

// 表单引用
const shippingFormRef = ref(null)

// ===== 方法 =====

// 获取订单列表
const getOrders = async () => {
  try {
    pageState.loading = true
    const apiCall = pageState.orderType === 'purchase' ? getUserOrdersAPI : getUserSaleOrdersAPI
    const { data } = await apiCall({
      pageNum: pageState.page,
      pageSize: pageState.pageSize,
      goodsName: searchParams.goodsName || undefined,
      orderNo: searchParams.orderNo || undefined,
      status: searchParams.status || undefined
    })

    pageState.orders = data?.list || []
    pageState.total = data?.total || 0
    console.log("pageState.orders", pageState.orders)
  } catch (error) {
    console.error('获取订单列表失败:', error)
    ElMessage.error('获取订单列表失败')
  } finally {
    pageState.loading = false
  }
}

// 更新订单状态
const updateOrderStatus = async (order, status) => {
  try {
    await ElMessageBox.confirm(
      `确定要${status === '已取消' ? '取消' : (status === '待收货' ? '发货' : '确认收货')}该订单吗？`,
      '操作确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    await updateOrderAPI({
      id: order.id,
      status
    })

    ElMessage.success('操作成功')
    getOrders()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更新订单状态失败:', error)
      ElMessage.error('操作失败')
    }
  }
}

// 查看订单详情
const viewOrderDetail = (order) => {
  pageState.activeOrder = { ...order }
  pageState.showDetail = true
}

// 检查用户对订单的操作权限
const canPerformAction = (order, action) => {
  if (!order) return false

  switch (action) {
    case 'cancel':
      return order.status === '待支付' && order.userId === user.value.id
    case 'ship':
      return order.status === '待发货' && order.saleId === user.value.id && pageState.orderType === 'sale'
    case 'receive':
      return order.status === '待收货' && order.userId === user.value.id && pageState.orderType === 'purchase'
    case 'pay':
      return order.status === '待支付' && order.userId === user.value.id
    default:
      return false
  }
}

// 切换订单类型
const changeOrderType = (type) => {
  if (pageState.orderType !== type) {
    pageState.orderType = type
    resetSearch()
  }
}

// 重置搜索条件
const resetSearch = () => {
  Object.keys(searchParams).forEach(key => {
    searchParams[key] = ''
  })
  getOrders()
}

// 搜索订单
const searchOrders = () => getOrders()

// 获取支付URL并跳转
const goToPay = (order) => {
  router.push({
    path: '/pay',
    query: {
      id: order.id,
      orderNo: order.orderNo
    }
  })
}

// 格式化价格显示
const formatPrice = (price) => {
  if (!price) return '¥0.00'
  return `¥${parseFloat(price).toFixed(2)}`
}

// 格式化时间显示
const formatTime = (timeStr) => {
  if (!timeStr) return '暂无记录'

  try {
    const date = new Date(timeStr)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).replace(/\//g, '-')
  } catch (e) {
    return timeStr
  }
}

// 计算订单剩余支付时间
const getPaymentTimeLeft = (orderTime) => {
  // 移除支付倒计时逻辑，返回空字符串
  return ''
}

// 监听页面变化
watch(() => pageState.page, getOrders)
watch(() => pageState.orderType, () => {
  pageState.page = 1
  getOrders()
})

// 初始化
onMounted(getOrders)

// 添加到methods部分
const copyToClipboard = (text) => {
  navigator.clipboard.writeText(text).then(() => {
    ElMessage({
      message: '已复制到剪贴板',
      type: 'success',
      duration: 1500
    });
  }).catch(() => {
    ElMessage.error('复制失败');
  });
};

// 删除订单
const deleteOrder = async (order) => {
  try {
    await ElMessageBox.confirm(
      '确定要删除该订单记录吗？删除后无法恢复。',
      '删除确认',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )

    await deleteOrderAPI(order.id)
    ElMessage.success('删除成功')
    getOrders()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除订单失败:', error)
      ElMessage.error('删除失败')
    }
  }
}

// 打开物流信息表单弹窗
const openShippingDialog = (order) => {
  shippingState.order = { ...order }
  shippingState.visible = true
  // 重置表单
  shippingForm.courierCompany = ''
  shippingForm.trackingNo = ''
}

// 提交物流信息
const submitShippingInfo = async () => {
  if (!shippingFormRef.value) return

  await shippingFormRef.value.validate(async (valid) => {
    if (!valid) return

    try {
      shippingState.loading = true

      // 提取物流信息，可以放在备注中记录
      const shippingInfo = `物流公司: ${shippingForm.courierCompany}, 单号: ${shippingForm.trackingNo}`
      console.log('发货信息:', shippingInfo)

      // 更新订单状态为待收货
      await updateOrderAPI({
        id: shippingState.order.id,
        status: '待收货'
      })

      // 关闭弹窗并刷新数据
      shippingState.visible = false
      ElMessage.success('发货成功')
      getOrders()
    } catch (error) {
      console.error('发货失败:', error)
      ElMessage.error('发货失败')
    } finally {
      shippingState.loading = false
    }
  })
}

// 访问快递公司官网
const visitCourierWebsite = (website) => {
  window.open(website, '_blank')
}
</script>

<template>
  <div class="my-order-container">
    <!-- 顶部卡片 -->
    <div class="order-header-card">
      <div class="order-title">
        <span class="title-icon">
          <el-icon>
            <Tickets />
          </el-icon>
        </span>
        <h2>我的订单</h2>
      </div>

      <!-- 订单类型选择 -->
      <div class="order-type-tabs">
        <div v-for="type in orderTypeOptions" :key="type.value" class="order-type-tab"
          :class="{ active: pageState.orderType === type.value }" @click="changeOrderType(type.value)">
          <el-icon>
            <component :is="type.icon" />
          </el-icon>
          <span>{{ type.label }}</span>
          <div class="tab-indicator"></div>
        </div>
      </div>

      <!-- 搜索区域 -->
      <div class="search-container">
        <div class="search-inputs">
          <div class="search-input-item">
            <el-input v-model="searchParams.goodsName" placeholder="搜索商品名称" clearable @keyup.enter="searchOrders">
              <template #prefix><el-icon>
                  <Search />
                </el-icon></template>
            </el-input>
          </div>

          <div class="search-input-item">
            <el-input v-model="searchParams.orderNo" placeholder="搜索订单编号" clearable @keyup.enter="searchOrders">
              <template #prefix><el-icon>
                  <Document />
                </el-icon></template>
            </el-input>
          </div>

          <div class="search-input-item">
            <el-select v-model="searchParams.status" placeholder="订单状态" clearable @change="searchOrders">
              <el-option v-for="option in orderStatusOptions" :key="option.value" :label="option.label"
                :value="option.value">
                <div class="status-option">
                  <el-icon v-if="option.value && statusTypeMap[option.value]">
                    <component :is="statusTypeMap[option.value].icon" />
                  </el-icon>
                  <span>{{ option.label }}</span>
                </div>
              </el-option>
            </el-select>
          </div>
        </div>

        <div class="search-buttons">
          <el-button type="primary" @click="searchOrders" :loading="pageState.loading">
            <el-icon>
              <Search />
            </el-icon><span>查询</span>
          </el-button>
          <el-button @click="resetSearch" :disabled="pageState.loading">
            <el-icon>
              <RefreshRight />
            </el-icon><span>重置</span>
          </el-button>
        </div>
      </div>
    </div>

    <!-- 订单内容区域 -->
    <div class="order-content">
      <div class="order-container">
        <!-- 订单卡片列表 -->
        <transition-group name="fade" tag="div" class="order-card-list">
          <!-- 空状态 -->
          <div v-if="pageState.orders.length === 0 && !pageState.loading" class="empty-state" key="empty">
            <el-empty :description="emptyText">
              <template #image>
                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
              </template>
            </el-empty>
          </div>

          <!-- 订单卡片 -->
          <div v-for="order in pageState.orders" :key="order.id" class="order-card">
            <!-- 卡片头部 -->
            <div class="order-card-header">
              <div class="order-info">
                <div class="order-no">
                  <span class="label">订单编号:</span>
                  <span class="value">{{ order.orderNo }}</span>
                </div>
                <div class="order-date">
                  <el-icon>
                    <Calendar />
                  </el-icon>
                  <span>{{ formatTime(order.time) }}</span>
                </div>
              </div>
              <div class="order-status">
                <el-tag :type="statusTypeMap[order.status]?.type || 'info'" effect="light">
                  <el-icon>
                    <component :is="statusTypeMap[order.status]?.icon" />
                  </el-icon>
                  <span>{{ order.status }}</span>
                </el-tag>
                <el-button type="danger" link class="delete-btn" @click.stop="deleteOrder(order)">
                  <el-icon>
                    <Delete />
                  </el-icon>
                </el-button>
              </div>
            </div>

            <!-- 卡片内容 -->
            <div class="order-card-content">
              <div class="goods-image-container">
                <el-image :src="order.goodsImg || 'https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png'"
                  fit="cover" :preview-src-list="order.goodsImg ? [order.goodsImg] : []" class="goods-image" lazy>
                  <template #error>
                    <div class="image-error"><el-icon>
                        <Picture />
                      </el-icon></div>
                  </template>
                </el-image>
              </div>

              <div class="goods-info">
                <div class="goods-name">{{ order.goodsName }}</div>
                <div class="order-meta">
                  <div v-if="pageState.orderType === 'purchase'" class="meta-item">
                    <span class="label">卖家:</span>
                    <span class="value">{{ order.saleName }}</span>
                  </div>
                  <div v-else class="meta-item">
                    <span class="label">买家:</span>
                    <span class="value">{{ order.user }}</span>
                  </div>
                </div>
              </div>

              <div class="order-price">
                <div class="total-price">{{ formatPrice(order.total) }}</div>
              </div>
            </div>

            <!-- 卡片底部 -->
            <div class="order-card-footer">
              <div class="order-actions">
                <!-- 购买订单的按钮 -->
                <template v-if="pageState.orderType === 'purchase'">
                  <!-- 取消按钮 -->
                  <el-button type="danger" v-if="canPerformAction(order, 'cancel')"
                    @click="updateOrderStatus(order, '已取消')" class="action-button">
                    <el-icon>
                      <Close />
                    </el-icon><span>取消订单</span>
                  </el-button>

                  <!-- 支付按钮 -->
                  <el-button type="warning" v-if="canPerformAction(order, 'pay')" @click="goToPay(order)"
                    class="action-button">
                    <el-icon>
                      <Wallet />
                    </el-icon><span>支付订单</span>
                  </el-button>

                  <!-- 收货按钮 -->
                  <el-button v-if="canPerformAction(order, 'receive')" type="success"
                    @click="updateOrderStatus(order, '已完成')" class="action-button">
                    <el-icon>
                      <CircleCheck />
                    </el-icon><span>确认收货</span>
                  </el-button>
                </template>

                <!-- 售卖订单的按钮 -->
                <template v-else>
                  <!-- 发货按钮 -->
                  <el-button v-if="canPerformAction(order, 'ship')" type="primary" @click="openShippingDialog(order)"
                    class="action-button">
                    <el-icon>
                      <Van />
                    </el-icon><span>去发货</span>
                  </el-button>
                </template>

                <!-- 查看详情按钮 -->
                <el-button type="info" plain @click="viewOrderDetail(order)" class="action-button">
                  <el-icon>
                    <InfoFilled />
                  </el-icon><span>查看详情</span>
                </el-button>
              </div>
            </div>
          </div>
        </transition-group>

        <!-- 加载中状态 -->
        <div v-if="pageState.loading" class="loading-container">
          <el-skeleton :rows="3" animated />
          <el-skeleton style="margin-top: 20px" :rows="3" animated />
        </div>

        <!-- 分页 -->
        <div class="pagination-container" v-if="pageState.total > 0">
          <el-pagination v-model:current-page="pageState.page" :page-size="pageState.pageSize" :total="pageState.total"
            @current-change="getOrders" layout="prev, pager, next, jumper" background />
        </div>
      </div>
    </div>

    <!-- 订单详情弹窗 -->
    <el-dialog v-model="pageState.showDetail" title="订单详情" width="650px" destroy-on-close :close-on-click-modal="false"
      class="order-detail-dialog">
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon">
            <InfoFilled />
          </el-icon>
          <span>订单详情</span>
        </div>
      </template>

      <div v-if="pageState.activeOrder" class="order-detail-content">
        <div class="detail-sections-wrapper">
          <!-- 订单状态卡片 -->
          <div class="detail-section status-section"
            :class="'status-' + (statusTypeMap[pageState.activeOrder.status]?.type || 'info')">
            <h3 class="section-title">订单状态</h3>
            <div class="status-content">
              <div class="status-icon">
                <el-icon>
                  <component :is="statusTypeMap[pageState.activeOrder.status]?.icon" />
                </el-icon>
              </div>
              <div class="status-value">{{ pageState.activeOrder.status }}</div>
            </div>
          </div>

          <div class="detail-columns">
            <!-- 左侧信息列 -->
            <div class="detail-column">
              <!-- 订单基本信息 -->
              <div class="detail-section basic-info-section">
                <h3 class="section-title">订单信息</h3>
                <div class="info-group">
                  <div class="info-item">
                    <span class="label">订单编号:</span>
                    <div class="value-container">
                      <span class="value order-number">{{ pageState.activeOrder.orderNo }}</span>
                      <el-button type="primary" link size="small"
                        @click="copyToClipboard(pageState.activeOrder.orderNo)" class="copy-btn">
                        <el-icon>
                          <DocumentCopy />
                        </el-icon>
                      </el-button>
                    </div>
                  </div>
                  <div class="info-item">
                    <span class="label">下单时间:</span>
                    <span class="value">{{ formatTime(pageState.activeOrder.time) }}</span>
                  </div>
                </div>
              </div>

              <!-- 交易信息 -->
              <div class="detail-section transaction-section">
                <h3 class="section-title">交易信息</h3>
                <div class="info-group">
                  <div class="info-item">
                    <span class="label">支付方式:</span>
                    <span class="value">在线支付</span>
                  </div>
                  <div class="info-item">
                    <span class="label">支付时间:</span>
                    <span class="value">{{ pageState.activeOrder.payTime ? formatTime(pageState.activeOrder.payTime) :
                      '未支付'
                    }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">支付单号:</span>
                    <div class="value-container" v-if="pageState.activeOrder.payNo">
                      <span class="value order-number">{{ pageState.activeOrder.payNo }}</span>
                      <el-button type="primary" link size="small" @click="copyToClipboard(pageState.activeOrder.payNo)"
                        class="copy-btn">
                        <el-icon>
                          <DocumentCopy />
                        </el-icon>
                      </el-button>
                    </div>
                    <span class="value" v-else>暂无</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 右侧信息列 -->
            <div class="detail-column">
              <!-- 商品信息 -->
              <div class="detail-section product-section">
                <h3 class="section-title">商品信息</h3>
                <div class="product-info-section">
                  <div class="product-image-container">
                    <el-image
                      :src="pageState.activeOrder.goodsImg || 'https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png'"
                      fit="cover" class="product-image" />
                  </div>
                  <div class="product-details">
                    <h3 class="product-name">{{ pageState.activeOrder.goodsName }}</h3>
                    <div class="product-price">{{ formatPrice(pageState.activeOrder.total) }}</div>
                  </div>
                </div>
              </div>

              <!-- 收货信息 -->
              <div class="detail-section shipping-section">
                <h3 class="section-title">收货信息</h3>
                <div class="info-group">
                  <div class="info-item">
                    <span class="label">收货人:</span>
                    <span class="value">{{ pageState.activeOrder.user }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">联系电话:</span>
                    <div class="value-container">
                      <span class="value phone-number">{{ pageState.activeOrder.phone }}</span>
                      <el-button type="primary" link size="small" @click="copyToClipboard(pageState.activeOrder.phone)"
                        class="copy-btn">
                        <el-icon>
                          <DocumentCopy />
                        </el-icon>
                      </el-button>
                    </div>
                  </div>
                  <div class="info-item address-item">
                    <span class="label">收货地址:</span>
                    <span class="value address-value">{{ pageState.activeOrder.address }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="pageState.showDetail = false">关闭</el-button>

          <!-- 根据订单类型和状态展示对应按钮 -->
          <template v-if="pageState.orderType === 'purchase'">
            <el-button v-if="pageState.activeOrder && canPerformAction(pageState.activeOrder, 'cancel')" type="danger"
              @click="updateOrderStatus(pageState.activeOrder, '已取消')">
              取消订单
            </el-button>

            <el-button v-if="pageState.activeOrder && canPerformAction(pageState.activeOrder, 'pay')" type="warning"
              @click="goToPay(pageState.activeOrder)">
              <el-icon>
                <Wallet />
              </el-icon>
              支付订单
            </el-button>

            <el-button v-if="pageState.activeOrder && canPerformAction(pageState.activeOrder, 'receive')" type="success"
              @click="updateOrderStatus(pageState.activeOrder, '已完成')">
              确认收货
            </el-button>
          </template>
          <template v-else>
            <el-button v-if="pageState.activeOrder && canPerformAction(pageState.activeOrder, 'ship')" type="primary"
              @click="openShippingDialog(pageState.activeOrder)">
              确认发货
            </el-button>
          </template>
        </div>
      </template>
    </el-dialog>

    <!-- 物流信息表单弹窗 -->
    <el-dialog v-model="shippingState.visible" title="物流信息" width="400px" destroy-on-close :close-on-click-modal="false"
      class="shipping-dialog">
      <template #header>
        <div class="dialog-header">
          <el-icon class="dialog-icon">
            <InfoFilled />
          </el-icon>
          <span>物流信息</span>
        </div>
      </template>

      <div v-if="shippingState.order" class="shipping-content">
        <div class="order-basic-info">
          <div class="order-info-item">
            <span class="label">订单编号:</span>
            <span class="value">{{ shippingState.order.orderNo }}</span>
          </div>
          <div class="order-info-item">
            <span class="label">商品名称:</span>
            <span class="value">{{ shippingState.order.goodsName }}</span>
          </div>
        </div>

        <el-divider content-position="center">填写物流信息</el-divider>

        <el-form ref="shippingFormRef" :model="shippingForm" :rules="shippingRules" label-position="top" status-icon>
          <el-form-item prop="courierCompany" label="快递公司">
            <el-select v-model="shippingForm.courierCompany" placeholder="请选择快递公司" class="full-width">
              <el-option v-for="option in courierOptions" :key="option.value" :label="option.label"
                :value="option.value">
                <div class="courier-option">
                  <span>{{ option.label }}</span>
                  <el-button type="primary" link size="small" @click.stop="visitCourierWebsite(option.website)">
                    官网
                    <el-icon class="el-icon--right">
                      <Link />
                    </el-icon>
                  </el-button>
                </div>
              </el-option>
            </el-select>
          </el-form-item>

          <el-form-item prop="trackingNo" label="快递单号">
            <el-input v-model="shippingForm.trackingNo" placeholder="请输入快递单号" maxlength="30" show-word-limit />
          </el-form-item>

          <div class="shipping-tips">
            <el-icon>
              <InfoFilled />
            </el-icon>
            <span>物流公司和快递单号仅用于买家查询物流状态，请确保信息准确</span>
          </div>
        </el-form>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="shippingState.visible = false" :disabled="shippingState.loading">取消</el-button>
          <el-button type="primary" @click="submitShippingInfo" :loading="shippingState.loading">确认发货</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
// 主容器样式
.my-order-container {
  padding: 20px;
  min-height: calc(100vh - 120px);
  background-color: var(--el-bg-color-page, #f5f7fa);

  // 顶部卡片样式
  .order-header-card {
    max-width: 1000px;
    margin: 0 auto 20px;
    background-color: var(--el-bg-color, #fff);
    border-radius: 12px;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
    padding: 24px;

    .order-title {
      display: flex;
      align-items: center;
      margin-bottom: 24px;

      .title-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 44px;
        height: 44px;
        border-radius: 12px;
        background: var(--el-color-primary-light-8);
        margin-right: 12px;

        .el-icon {
          font-size: 24px;
          color: var(--el-color-primary);
        }
      }

      h2 {
        font-size: 22px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        margin: 0;
      }
    }

    // 订单类型选项卡
    .order-type-tabs {
      display: flex;
      margin-bottom: 24px;
      border-bottom: 1px solid var(--el-border-color-light);

      .order-type-tab {
        position: relative;
        display: flex;
        align-items: center;
        padding: 16px 24px;
        cursor: pointer;
        color: var(--el-text-color-regular);
        transition: all 0.3s ease;
        margin-right: 20px;

        .el-icon {
          margin-right: 8px;
          font-size: 18px;
        }

        span {
          font-size: 16px;
          font-weight: 500;
        }

        .tab-indicator {
          position: absolute;
          bottom: -1px;
          left: 0;
          width: 100%;
          height: 3px;
          background-color: var(--el-color-primary);
          border-radius: 2px 2px 0 0;
          transform: scaleX(0);
          transition: transform 0.3s ease;
          transform-origin: center;
        }

        &:hover {
          color: var(--el-color-primary);
        }

        &.active {
          color: var(--el-color-primary);

          .tab-indicator {
            transform: scaleX(1);
          }
        }
      }
    }

    // 搜索区域
    .search-container {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;

      .search-inputs {
        flex: 1;
        display: flex;
        flex-wrap: wrap;
        gap: 12px;

        .search-input-item {
          min-width: 200px;
          flex: 1;

          :deep(.el-input__wrapper) {
            border-radius: 8px;
          }

          :deep(.el-select) {
            width: 100%;
          }
        }
      }

      .search-buttons {
        display: flex;
        gap: 12px;

        .el-button {
          border-radius: 8px;
          transition: all 0.3s ease;

          &:hover {
            transform: translateY(-2px);
          }

          .el-icon {
            margin-right: 6px;
          }
        }
      }
    }
  }

  // 订单内容区域
  .order-content {
    position: relative;
    min-height: 300px;

    // 订单容器
    .order-container {
      max-width: 1000px;
      margin: 0 auto;
      background-color: var(--el-bg-color, #fff);
      border-radius: 12px;
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
      padding: 24px;

      // 订单卡片列表
      .order-card-list {
        display: flex;
        flex-direction: column;
        gap: 16px;

        // 空状态
        .empty-state {
          display: flex;
          justify-content: center;
          padding: 50px 0;

          :deep(.el-empty__image) {
            width: 200px;
            height: 200px;
          }

          :deep(.el-empty__description) {
            font-size: 16px;
            color: var(--el-text-color-secondary);
          }
        }

        // 订单卡片
        .order-card {
          background: var(--el-bg-color, #fff);
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
          overflow: hidden;
          transition: all 0.3s ease;

          &:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
          }

          // 卡片头部
          .order-card-header {
            padding: 12px 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #f0f2f5;
            background-color: #f7f9fc;

            .order-info {
              display: flex;
              align-items: center;
              gap: 16px;

              @media (max-width: 576px) {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
              }

              .order-no {
                display: flex;
                align-items: center;
                font-size: 14px;

                .label {
                  color: #909399;
                  margin-right: 5px;
                }

                .value {
                  font-weight: 500;
                  color: #303133;
                }
              }

              .order-date {
                display: flex;
                align-items: center;
                gap: 4px;
                font-size: 13px;
                color: #606266;
              }
            }

            .order-status {
              display: flex;
              align-items: center;
              gap: 8px;

              .el-tag {
                display: flex;
                align-items: center;
                gap: 4px;
                padding: 4px 8px;

                .el-icon {
                  margin-right: 2px;
                }
              }

              .delete-btn {
                color: #909399;
                font-size: 16px;
                transition: all 0.2s;

                &:hover {
                  color: #f56c6c;
                  transform: scale(1.1);
                }
              }
            }
          }

          // 卡片内容
          .order-card-content {
            padding: 16px 20px;
            display: flex;
            gap: 16px;

            .goods-image-container {
              flex-shrink: 0;
              width: 100px;
              height: 100px;
              border-radius: 8px;
              overflow: hidden;
              background-color: var(--el-fill-color-lighter);

              .goods-image {
                width: 100%;
                height: 100%;
                transition: transform 0.3s ease;

                &:hover {
                  transform: scale(1.05);
                }
              }

              .image-error {
                width: 100%;
                height: 100%;
                display: flex;
                justify-content: center;
                align-items: center;
                color: var(--el-text-color-placeholder);

                .el-icon {
                  font-size: 32px;
                }
              }
            }

            .goods-info {
              flex: 1;
              display: flex;
              flex-direction: column;

              .goods-name {
                font-size: 16px;
                font-weight: 500;
                color: var(--el-text-color-primary);
                margin-bottom: 12px;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                -webkit-box-orient: vertical;
                overflow: hidden;
                text-overflow: ellipsis;
              }

              .order-meta {
                display: flex;
                flex-wrap: wrap;
                gap: 16px;
                color: var(--el-text-color-secondary);

                .meta-item {
                  display: flex;
                  align-items: center;

                  .label {
                    margin-right: 6px;
                  }

                  .value {
                    color: var(--el-text-color-primary);
                  }
                }
              }
            }

            .order-price {
              display: flex;
              flex-direction: column;
              align-items: flex-end;
              justify-content: center;
              padding: 0 12px;

              .total-price {
                font-size: 20px;
                font-weight: 600;
                color: var(--el-color-danger);
              }
            }
          }

          // 卡片底部
          .order-card-footer {
            padding: 16px 20px;
            border-top: 1px solid var(--el-border-color-lighter);
            background-color: var(--el-bg-color, #fff);

            .order-actions {
              display: flex;
              justify-content: flex-end;
              flex-wrap: wrap;
              gap: 12px;

              .action-button {
                border-radius: 8px;
                transition: all 0.3s ease;

                &:hover {
                  transform: translateY(-2px);
                }

                .el-icon {
                  margin-right: 4px;
                }
              }
            }
          }
        }
      }

      // 加载中状态
      .loading-container {
        padding: 20px;
        background: var(--el-fill-color-light);
        border-radius: 12px;
        margin-bottom: 16px;
      }

      // 分页
      .pagination-container {
        margin-top: 24px;
        display: flex;
        justify-content: center;
      }
    }
  }

  // 详情弹窗
  :deep(.order-detail-dialog) {
    .el-dialog__header {
      margin-right: 0;
      padding-bottom: 0;
      padding: 12px 20px;
    }

    .dialog-header {
      display: flex;
      align-items: center;
      gap: 8px;

      .dialog-icon {
        font-size: 18px;
        color: var(--el-color-primary);
      }

      span {
        font-size: 16px;
        font-weight: 600;
      }
    }

    .el-dialog__body {
      padding: 15px 20px;
    }

    .order-detail-content {
      .detail-sections-wrapper {
        display: flex;
        flex-direction: column;
        gap: 15px;

        // 订单状态区块特殊样式
        .status-section {
          margin-bottom: 15px;
          padding: 12px;
          border-radius: 8px;
          background-color: var(--el-bg-color, #fff);
          box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);

          .section-title {
            font-size: 14px;
            font-weight: 600;
            color: var(--el-text-color-primary);
            margin: 0 0 10px 0;
            padding-bottom: 8px;
            border-bottom: 1px solid var(--el-border-color-lighter);
            display: flex;
            align-items: center;
          }

          &.status-primary {
            background-color: rgba(var(--el-color-primary-rgb), 0.1);

            .status-icon {
              color: var(--el-color-primary);
            }

            .status-value {
              color: var(--el-color-primary);
            }
          }

          &.status-success {
            background-color: rgba(var(--el-color-success-rgb), 0.1);

            .status-icon {
              color: var(--el-color-success);
            }

            .status-value {
              color: var(--el-color-success);
            }
          }

          &.status-warning {
            background-color: rgba(var(--el-color-warning-rgb), 0.1);

            .status-icon {
              color: var(--el-color-warning);
            }

            .status-value {
              color: var(--el-color-warning);
            }
          }

          &.status-danger {
            background-color: rgba(var(--el-color-danger-rgb), 0.1);

            .status-icon {
              color: var(--el-color-danger);
            }

            .status-value {
              color: var(--el-color-danger);
            }
          }

          &.status-info {
            background-color: rgba(var(--el-color-info-rgb), 0.1);

            .status-icon {
              color: var(--el-color-info);
            }

            .status-value {
              color: var(--el-color-info);
            }
          }

          .status-content {
            display: flex;
            align-items: center;

            .status-icon {
              font-size: 24px;
              margin-right: 12px;
            }

            .status-value {
              font-size: 16px;
              font-weight: 600;
            }
          }
        }

        .detail-columns {
          display: flex;
          gap: 24px;

          @media (max-width: 768px) {
            flex-direction: column;
          }

          .detail-column {
            flex: 1;
            min-width: 0; // 防止内容溢出
          }

          .detail-section {
            margin-bottom: 20px;

            .section-title {
              font-size: 16px;
              font-weight: 600;
              margin-bottom: 12px;
              padding-bottom: 8px;
              border-bottom: 1px solid var(--el-border-color-lighter);
              color: var(--el-text-color-primary);
            }

            .info-group {
              .info-item {
                display: flex;
                margin-bottom: 12px;

                .label {
                  flex: 0 0 80px;
                  color: var(--el-text-color-secondary);
                }

                .value-container {
                  display: flex;
                  align-items: center;
                  flex: 1;
                  min-width: 0;
                  word-break: break-all;
                  gap: 4px;

                  .copy-btn {
                    padding: 0 4px;
                    height: 20px;
                    line-height: 20px;
                  }
                }

                .value {
                  flex: 1;
                  min-width: 0;
                  word-break: break-all;
                  color: var(--el-text-color-primary);
                }

                .order-number,
                .phone-number {
                  font-family: monospace;
                  letter-spacing: 0.5px;
                }

                &.address-item {
                  align-items: flex-start;

                  .address-value {
                    line-height: 1.5;
                  }
                }
              }
            }

            .product-info-section {
              display: flex;
              align-items: center;
              gap: 16px;

              .product-image-container {
                flex: 0 0 80px;
                width: 80px;
                height: 80px;

                .product-image {
                  width: 100%;
                  height: 100%;
                  border-radius: 6px;
                  object-fit: cover;
                }
              }

              .product-details {
                flex: 1;
                min-width: 0;

                .product-name {
                  font-size: 14px;
                  margin: 0 0 8px;
                  font-weight: 500;
                  color: var(--el-text-color-primary);
                  overflow: hidden;
                  text-overflow: ellipsis;
                  display: -webkit-box;
                  -webkit-line-clamp: 2;
                  -webkit-box-orient: vertical;
                }

                .product-price {
                  color: #f56c6c;
                  font-size: 16px;
                  font-weight: 600;
                }
              }
            }
          }
        }
      }
    }

    .el-dialog__footer {
      padding: 10px 20px 15px;
    }

    .dialog-footer {
      display: flex;
      justify-content: flex-end;
      gap: 10px;

      .el-button {
        padding: 8px 15px;
        border-radius: 6px;
        font-size: 13px;

        &:hover {
          transform: translateY(-2px);
        }
      }
    }
  }

  // 物流信息表单弹窗
  :deep(.shipping-dialog) {
    .el-dialog__header {
      margin-right: 0;
      padding-bottom: 0;
      padding: 12px 20px;
      background-color: #f7f9fc;
      border-bottom: 1px solid var(--el-border-color-lighter);
    }

    .dialog-header {
      display: flex;
      align-items: center;
      gap: 8px;

      .dialog-icon {
        font-size: 18px;
        color: var(--el-color-primary);
      }

      span {
        font-size: 16px;
        font-weight: 600;
      }
    }

    .el-dialog__body {
      padding: 20px;
    }

    .shipping-content {
      .order-basic-info {
        background-color: #f9fafc;
        border-radius: 8px;
        padding: 15px;
        margin-bottom: 15px;

        .order-info-item {
          display: flex;
          margin-bottom: 10px;

          &:last-child {
            margin-bottom: 0;
          }

          .label {
            font-weight: 500;
            color: var(--el-text-color-secondary);
            width: 80px;
            flex-shrink: 0;
          }

          .value {
            color: var(--el-text-color-primary);
            flex: 1;
            word-break: break-all;
          }
        }
      }

      .el-form {
        margin-top: 15px;
      }

      .courier-option {
        display: flex;
        justify-content: space-between;
        align-items: center;
        width: 100%;
      }

      .shipping-tips {
        display: flex;
        align-items: flex-start;
        background-color: rgba(var(--el-color-info-rgb), 0.1);
        padding: 8px 12px;
        border-radius: 4px;
        margin-top: 15px;
        font-size: 12px;
        color: var(--el-text-color-secondary);

        .el-icon {
          color: var(--el-color-info);
          margin-right: 6px;
          margin-top: 2px;
        }
      }

      :deep(.el-select) {
        width: 100%;
      }

      :deep(.el-form-item__label) {
        font-weight: 500;
      }

      :deep(.full-width) {
        width: 100%;
      }
    }

    .el-dialog__footer {
      padding: 10px 20px 15px;
      border-top: 1px solid var(--el-border-color-lighter);
    }

    .dialog-footer {
      display: flex;
      justify-content: flex-end;
      gap: 10px;

      .el-button {
        padding: 8px 15px;
        border-radius: 6px;
        font-size: 13px;

        &:hover {
          transform: translateY(-2px);
        }
      }
    }
  }
}

// 过渡动画
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

// 响应式布局
@media (max-width: 768px) {
  .my-order-container {
    padding: 12px;

    .order-header-card {
      padding: 16px;

      .order-type-tabs {
        overflow-x: auto;
        white-space: nowrap;

        .order-type-tab {
          padding: 12px 16px;
        }
      }

      .search-container {
        flex-direction: column;

        .search-inputs {
          flex-direction: column;

          .search-input-item {
            width: 100%;
          }
        }

        .search-buttons {
          width: 100%;
          justify-content: space-between;
        }
      }
    }

    .order-content {
      .order-container {
        padding: 16px;

        .order-card {
          .order-card-header {
            flex-direction: column;
            align-items: flex-start;
            gap: 12px;

            .order-status {
              align-items: flex-start;
              width: 100%;
            }
          }

          .order-card-content {
            flex-direction: column;

            .goods-image-container {
              width: 100%;
              height: auto;
              aspect-ratio: 1/1;
              max-width: 200px;
              margin: 0 auto;
            }

            .order-price {
              align-items: flex-start;
              padding: 12px 0 0;
            }
          }

          .order-card-footer {
            .order-actions {
              justify-content: center;
            }
          }
        }
      }
    }

    :deep(.order-detail-dialog) {
      .order-detail-content {
        .detail-sections-wrapper {
          .detail-columns {
            flex-direction: column;
            gap: 12px;
          }

          .status-section {
            .status-content {
              flex-direction: column;
              align-items: center;
              text-align: center;

              .status-icon {
                margin-right: 0;
                margin-bottom: 8px;
              }
            }
          }

          .product-section {
            .product-info-section {
              flex-direction: column;
              align-items: center;

              .product-image-container {
                width: 100px;
                height: 100px;
                margin: 0 auto 10px;
              }

              .product-details {
                width: 100%;

                .product-name {
                  text-align: center;
                }

                .product-price {
                  align-self: center;
                }
              }
            }
          }
        }
      }

      .dialog-footer {
        flex-wrap: wrap;
        justify-content: center;

        .el-button {
          min-width: 45%;
        }
      }
    }
  }
}
</style>