<script setup>
/**
 * 商品信息管理组件
 * 提供商品的查询、编辑、删除、批量操作和审核功能
 * 实现响应式布局和交互动效
 */
import {
  ArrowDown,
  Delete,
  Document,
  Edit,
  Goods,
  Grid,
  InfoFilled,
  List,
  More,
  Picture,
  RefreshRight,
  Search,
  SuccessFilled,
  View,
  WarningFilled
} from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref } from 'vue'

// 导入API和Store
import {
  deleteBatchGoodsAPI,
  deleteGoodsAPI,
  getGoodsPageAPI,
  updateGoodsAPI
} from '@/api/goodsAPI'
import { useUserStore } from '@/stores/userStore'
import { getAllCategoryAPI } from '@/api/categoryAPI'
import { getUserByIdAPI } from '@/api/userAPI'

// ===== 状态管理 =====
const userStore = useUserStore()
const user = computed(() => userStore.userInfo)

// ===== 组件引用 =====
const formRef = ref(null)
const tableRef = ref(null)
const searchInputRef = ref(null)

// ===== 页面状态 =====
const pageState = reactive({
  loading: false,
  refreshing: false,
  operating: false,
  searchExpanded: false,
  viewType: localStorage.getItem('goods-view-type') || 'table'
})

// ===== 对话框状态 =====
const dialogState = reactive({
  visible: false,
  detailVisible: false,
  title: '商品信息',
  mode: 'edit', // 只有编辑模式
  loading: false,
  detail: ''
})

// ===== 数据状态 =====
const tableData = ref([])
const searchForm = reactive({
  name: '',
})
const formData = reactive({})
const selectedIds = ref([])
const categoryList = ref([])
const userAvatars = ref({}) // 用于缓存用户头像

// ===== 分页控制 =====
const pagination = reactive({
  currentPage: 1,
  pageSize: 10,
  total: 0,
  pageSizes: [10, 20, 50, 100],
  layout: 'total, sizes, prev, pager, next, jumper'
})

// ===== 表单校验规则 =====
const formRules = {
  name: [
    { required: true, message: '请输入商品名称', trigger: 'blur' }
  ],
  price: [
    { required: true, message: '请输入价格', trigger: 'blur' }
  ],
  category: [
    { required: true, message: '请选择商品分类', trigger: 'change' }
  ]
}

// ===== 计算属性 =====
const hasSelected = computed(() => selectedIds.value.length > 0)
const selectionStatus = computed(() => {
  return {
    text: hasSelected.value
      ? `已选择 ${selectedIds.value.length} 项`
      : '请选择要操作的数据',
    type: hasSelected.value ? 'primary' : 'info'
  }
})

// ===== 数据加载 =====
/**
 * 加载商品数据
 * @param {Object} options - 加载选项
 * @param {Boolean} options.resetPage - 是否重置页码
 * @param {Boolean} options.showLoading - 是否显示加载状态
 */
const loadData = async (options = {}) => {
  const { resetPage = false, showLoading = true } = options

  if (resetPage) {
    pagination.currentPage = 1
  }

  if (showLoading) {
    pageState.loading = true
  } else {
    pageState.refreshing = true
  }

  try {
    const res = await getGoodsPageAPI({
      pageNum: pagination.currentPage,
      pageSize: pagination.pageSize,
      name: searchForm.name.trim() || undefined
    })

    if (res.code === '200') {
      tableData.value = res.data?.list || []
      pagination.total = res.data?.total || 0

      // 加载用户头像
      loadUserAvatars()

      // 如果当前页数据为空且不是第一页，尝试加载前一页
      if (tableData.value.length === 0 && pagination.currentPage > 1) {
        pagination.currentPage--
        loadData({ showLoading: false })
      }
    } else {
      showError(res.msg || '加载数据失败')
    }
  } catch (error) {
    console.error('加载商品数据失败:', error)
    showError('网络异常，请稍后重试')
  } finally {
    pageState.loading = false
    pageState.refreshing = false
  }
}

// 加载分类数据
const loadCategories = async () => {
  try {
    const res = await getAllCategoryAPI()
    if (res.code === '200') {
      categoryList.value = res.data || []
    } else {
      showError(res.msg || '获取分类列表失败')
    }
  } catch (error) {
    console.error('获取分类列表失败:', error)
    showError('网络异常，请稍后重试')
  }
}

// 获取用户头像
const loadUserAvatars = async () => {
  for (const item of tableData.value) {
    if (item.userId && !userAvatars.value[item.userId]) {
      try {
        const res = await getUserByIdAPI(item.userId)
        if (res.code === '200' && res.data) {
          userAvatars.value[item.userId] = res.data.avatar
        }
      } catch (error) {
        console.error('获取用户头像失败:', error)
      }
    }
  }
}

// ===== 搜索操作 =====
/**
 * 执行搜索
 */
const handleSearch = () => {
  loadData({ resetPage: true })
}

/**
 * 重置搜索条件
 */
const handleReset = () => {
  searchForm.name = ''
  loadData({ resetPage: true })

  nextTick(() => {
    if (searchInputRef.value) {
      searchInputRef.value.focus()
    }
  })
}

// ===== 表单操作 =====
/**
 * 打开编辑商品表单
 * @param {Object} row - 表格行数据
 */
const handleEdit = (row) => {
  dialogState.mode = 'edit'
  dialogState.title = '编辑商品'
  Object.assign(formData, JSON.parse(JSON.stringify(row)))
  dialogState.visible = true

  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

/**
 * 预览商品详情
 * @param {String} contentText - 商品详情内容
 */
const preview = (contentText) => {
  dialogState.detail = contentText
  dialogState.detailVisible = true
}

/**
 * 提交表单
 */
const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    dialogState.loading = true

    try {
      const res = await updateGoodsAPI(formData)

      if (res.code === '200') {
        ElNotification({
          title: '编辑成功',
          message: `商品"${formData.name}"已更新`,
          type: 'success',
          duration: 2000
        })
        dialogState.visible = false
        loadData({ resetPage: false })
      } else {
        showError(res.msg || '操作失败')
      }
    } catch (error) {
      console.error('保存商品信息失败:', error)
      showError('操作失败，请稍后重试')
    } finally {
      dialogState.loading = false
    }
  })
}

// ===== 审核操作 =====
/**
 * 更改商品审核状态
 * @param {Object} row - 表格行数据
 * @param {String} status - 目标状态
 */
const changeStatus = async (row, status) => {
  try {
    await ElMessageBox.confirm(`确定要将商品"${row.name}"的状态修改为"${status}"吗？`, '确认操作', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning',
      draggable: true,
      closeOnClickModal: false
    })

    pageState.operating = true

    const updatedData = JSON.parse(JSON.stringify(row))
    updatedData.status = status

    const res = await updateGoodsAPI(updatedData)

    if (res.code === '200') {
      ElMessage({
        message: '状态更新成功',
        type: 'success',
        duration: 2000
      })
      loadData({ resetPage: false })
    } else {
      showError(res.msg || '操作失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('更改状态失败:', error)
      showError('操作失败，请稍后重试')
    }
  } finally {
    pageState.operating = false
  }
}

// ===== 删除操作 =====
/**
 * 删除单个商品
 * @param {Object} row - 表格行数据
 */
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除商品"${row.name}"吗？删除后不可恢复。`,
      '删除确认',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'warning',
        draggable: true,
        closeOnClickModal: false
      }
    )

    pageState.operating = true

    const res = await deleteGoodsAPI(row.id)

    if (res.code === '200') {
      ElMessage({
        message: '删除成功',
        type: 'success',
        duration: 2000
      })
      loadData({ resetPage: tableData.value.length === 1 })
    } else {
      showError(res.msg || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除商品失败:', error)
      showError('操作失败，请稍后重试')
    }
  } finally {
    pageState.operating = false
  }
}

/**
 * 批量删除商品
 */
const handleDeleteBatch = async () => {
  if (!selectedIds.value.length) {
    ElMessage.warning('请先选择要删除的数据')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedIds.value.length} 项商品吗？删除后不可恢复。`,
      '批量删除确认',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'warning',
        draggable: true,
        closeOnClickModal: false
      }
    )

    pageState.operating = true

    const res = await deleteBatchGoodsAPI(selectedIds.value)

    if (res.code === '200') {
      ElNotification({
        title: '批量删除成功',
        message: `已删除 ${selectedIds.value.length} 项商品数据`,
        type: 'success',
        duration: 2000
      })
      loadData({ resetPage: tableData.value.length === selectedIds.value.length })
    } else {
      showError(res.msg || '批量删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除商品失败:', error)
      showError('操作失败，请稍后重试')
    }
  } finally {
    pageState.operating = false
  }
}

// ===== 表格事件处理 =====
/**
 * 处理表格选择变更
 * @param {Array} selection - 已选中行的数组
 */
const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id)
}

/**
 * 切换行选择状态
 * @param {Object} row - 表格行数据
 */
const toggleRowSelection = (row) => {
  if (!tableRef.value) return
  tableRef.value.toggleRowSelection(row)
}

/**
 * 切换视图类型
 * @param {String} type - 视图类型
 */
const changeViewType = (type) => {
  pageState.viewType = type
  localStorage.setItem('goods-view-type', type)
}

// ===== 分页事件处理 =====
/**
 * 处理页面变更
 * @param {Number} page - 新的页码
 */
const handlePageChange = (page) => {
  pagination.currentPage = page
  loadData()
}

/**
 * 处理每页条数变更
 * @param {Number} size - 新的每页条数
 */
const handleSizeChange = (size) => {
  pagination.pageSize = size
  pagination.currentPage = 1
  loadData()
}

// ===== 工具方法 =====
/**
 * 显示错误消息
 * @param {String} message - 错误信息
 */
const showError = (message) => {
  ElMessage({
    message,
    type: 'error',
    duration: 3000
  })
}

// ===== 生命周期钩子 =====
onMounted(() => {
  loadData()
  loadCategories()
})
</script>

<template>
  <div class="goods-manager">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon>
          <Goods />
        </el-icon>
        <h2>商品管理</h2>
      </div>
      <div class="header-extra">
        <el-tooltip content="刷新数据" placement="top">
          <el-button circle :icon="RefreshRight" :loading="pageState.refreshing"
            @click="loadData({ showLoading: false })" />
        </el-tooltip>

        <div class="view-toggle">
          <el-tooltip content="表格视图" placement="top" :effect="pageState.viewType === 'table' ? 'light' : 'dark'">
            <el-button :type="pageState.viewType === 'table' ? 'primary' : 'default'" circle
              @click="changeViewType('table')">
              <el-icon>
                <List />
              </el-icon>
            </el-button>
          </el-tooltip>
          <el-tooltip content="卡片视图" placement="top" :effect="pageState.viewType === 'card' ? 'light' : 'dark'">
            <el-button :type="pageState.viewType === 'card' ? 'primary' : 'default'" circle
              @click="changeViewType('card')">
              <el-icon>
                <Grid />
              </el-icon>
            </el-button>
          </el-tooltip>
        </div>
      </div>
    </div>

    <!-- 搜索卡片 -->
    <el-card class="search-card" shadow="hover" :body-style="{ padding: '16px' }">
      <div class="search-area">
        <div class="search-form">
          <el-input ref="searchInputRef" v-model="searchForm.name" placeholder="请输入商品名称" clearable
            @keyup.enter="handleSearch">
            <template #prefix>
              <el-icon>
                <Search />
              </el-icon>
            </template>
          </el-input>
        </div>

        <div class="search-buttons">
          <el-button type="primary" :icon="Search" @click="handleSearch" :loading="pageState.loading">
            查询
          </el-button>
          <el-button :icon="RefreshRight" @click="handleReset">
            重置
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 操作区域 -->
    <div class="operation-bar">
      <div class="left-actions">
        <el-button type="danger" :icon="Delete" @click="handleDeleteBatch"
          :disabled="!hasSelected || pageState.operating">
          批量删除
        </el-button>

        <el-tag :type="selectionStatus.type" effect="plain" class="selection-status" v-if="tableData.length > 0">
          {{ selectionStatus.text }}
        </el-tag>
      </div>

      <div class="right-actions">
        <!-- 预留位置用于其他功能 -->
      </div>
    </div>

    <!-- 数据展示区域 -->
    <el-card class="data-card" shadow="hover" :body-style="{ padding: '0px' }" v-loading="pageState.loading"
      element-loading-text="正在加载数据..." element-loading-background="rgba(255, 255, 255, 0.8)">
      <!-- 表格视图 -->
      <template v-if="pageState.viewType === 'table'">
        <el-table ref="tableRef" :data="tableData" style="width: 100%" border stripe highlight-current-row
          @selection-change="handleSelectionChange" empty-text="暂无数据" :header-cell-style="{
            background: 'var(--el-color-primary-light-9)',
            color: 'var(--el-color-primary-dark-2)',
            fontWeight: 'bold'
          }" table-layout="auto" class="goods-table" row-key="id">
          <!-- 选择列 -->
          <el-table-column type="selection" width="55" align="center" fixed="left" />

          <!-- 序号列 -->
          <el-table-column prop="id" label="ID" width="80" align="center" sortable />

          <!-- 名称列 -->
          <el-table-column prop="name" label="商品名称" min-width="150" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="name-cell">
                <el-icon>
                  <Document />
                </el-icon>
                <span>{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 价格列 -->
          <el-table-column prop="price" label="价格" width="100" align="center">
            <template #default="{ row }">
              <span class="price-tag">￥{{ row.price }}</span>
            </template>
          </el-table-column>

          <!-- 分类列 -->
          <el-table-column prop="category" label="商品分类" width="120" align="center">
            <template #default="{ row }">
              <el-tag type="info" effect="plain">{{ row.category || '未分类' }}</el-tag>
            </template>
          </el-table-column>

          <!-- 发布者列 -->
          <el-table-column prop="userName" label="发布者" width="160" align="center">
            <template #default="{ row }">
              <div class="publisher-cell">
                <el-avatar
                  :src="userAvatars[row.userId] || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'"
                  :size="32">
                </el-avatar>
                <span class="publisher-name">{{ row.userName }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 详情列 -->
          <el-table-column label="详情" width="100" align="center">
            <template #default="{ row }">
              <el-button type="info" link :icon="View" @click="preview(row.content)">
                查看
              </el-button>
            </template>
          </el-table-column>

          <!-- 地址列 -->
          <el-table-column prop="address" label="发货地址" min-width="150" show-overflow-tooltip />

          <!-- 图片列 -->
          <el-table-column prop="img" label="商品图片" width="100" align="center">
            <template #default="{ row }">
              <el-image v-if="row.img" style="width: 60px; height: 60px; border-radius: 4px; object-fit: cover;"
                :src="row.img" :preview-src-list="[row.img]" fit="cover" :z-index="2000" preview-teleported />
              <el-icon v-else style="font-size: 24px; color: var(--el-text-color-placeholder);">
                <Picture />
              </el-icon>
            </template>
          </el-table-column>

          <!-- 日期列 -->
          <el-table-column prop="date" label="上架日期" min-width="120" sortable />

          <!-- 状态列 -->
          <el-table-column prop="status" label="审核状态" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="row.status === '通过' ? 'success' : row.status === '拒绝' ? 'danger' : 'warning'"
                effect="light">
                {{ row.status || '待审核' }}
              </el-tag>
            </template>
          </el-table-column>

          <!-- 操作列 -->
          <el-table-column label="操作" min-width="220" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-tooltip content="编辑商品" placement="top">
                  <el-button type="primary" link :icon="Edit" @click="handleEdit(row)" :loading="pageState.operating" />
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="删除商品" placement="top">
                  <el-button type="danger" link :icon="Delete" @click="handleDelete(row)"
                    :loading="pageState.operating" />
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-dropdown trigger="click">
                  <el-button link :icon="More" />
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item @click="changeStatus(row, '通过')">
                        <el-icon>
                          <SuccessFilled />
                        </el-icon>
                        <span>审核通过</span>
                      </el-dropdown-item>
                      <el-dropdown-item @click="changeStatus(row, '拒绝')">
                        <el-icon>
                          <WarningFilled />
                        </el-icon>
                        <span>审核拒绝</span>
                      </el-dropdown-item>
                      <el-dropdown-item @click="changeStatus(row, '待审核')">
                        <el-icon>
                          <InfoFilled />
                        </el-icon>
                        <span>待审核</span>
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </template>

      <!-- 卡片视图 -->
      <template v-else-if="pageState.viewType === 'card'">
        <div class="card-view">
          <template v-if="tableData.length > 0">
            <div v-for="item in tableData" :key="item.id" class="data-card-item"
              :class="{ 'selected': selectedIds.includes(item.id) }" @click="toggleRowSelection(item)">
              <div class="card-header">
                <div class="card-title">
                  <el-icon>
                    <Document />
                  </el-icon>
                  <h3>{{ item.name }}</h3>
                </div>
                <div class="card-status">
                  <el-tag :type="item.status === '通过' ? 'success' : item.status === '拒绝' ? 'danger' : 'warning'"
                    size="small">
                    {{ item.status || '待审核' }}
                  </el-tag>
                </div>
              </div>

              <div class="card-content">
                <div class="card-image">
                  <el-image v-if="item.img" :src="item.img" fit="cover" :preview-src-list="[item.img]"
                    preview-teleported />
                  <div v-else class="no-image">
                    <el-icon>
                      <Picture />
                    </el-icon>
                  </div>
                </div>

                <div class="card-info">
                  <div class="info-item">
                    <span class="label">价格:</span>
                    <span class="value price">￥{{ item.price }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">分类:</span>
                    <span class="value">{{ item.category || '未分类' }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">发布者:</span>
                    <div class="publisher-info">
                      <el-avatar
                        :src="userAvatars[item.userId] || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'"
                        :size="28">
                      </el-avatar>
                      <span>{{ item.userName }}</span>
                    </div>
                  </div>
                  <div class="info-item">
                    <span class="label">发货地:</span>
                    <span class="value">{{ item.address }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">上架时间:</span>
                    <span class="value">{{ item.date }}</span>
                  </div>
                  <div class="info-item">
                    <span class="label">详情:</span>
                    <el-button type="info" link @click.stop="preview(item.content)">查看</el-button>
                  </div>
                </div>
              </div>

              <div class="card-actions">
                <el-button type="primary" size="small" :icon="Edit" @click.stop="handleEdit(item)">
                  编辑
                </el-button>
                <el-button type="danger" size="small" :icon="Delete" @click.stop="handleDelete(item)">
                  删除
                </el-button>
                <el-dropdown trigger="click" @click.stop>
                  <el-button size="small">
                    审核
                    <el-icon>
                      <ArrowDown />
                    </el-icon>
                  </el-button>
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item @click="changeStatus(item, '通过')">
                        <el-icon>
                          <SuccessFilled />
                        </el-icon> 通过
                      </el-dropdown-item>
                      <el-dropdown-item @click="changeStatus(item, '拒绝')">
                        <el-icon>
                          <WarningFilled />
                        </el-icon> 拒绝
                      </el-dropdown-item>
                      <el-dropdown-item @click="changeStatus(item, '待审核')">
                        <el-icon>
                          <InfoFilled />
                        </el-icon> 待审核
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
            </div>
          </template>

          <el-empty v-else description="暂无商品数据" />
        </div>
      </template>

      <!-- 分页控制 -->
      <el-pagination v-if="tableData.length > 0 || pagination.total > 0" class="pagination" background
        :current-page="pagination.currentPage" :page-sizes="pagination.pageSizes" :page-size="pagination.pageSize"
        :layout="pagination.layout" :total="pagination.total" @size-change="handleSizeChange"
        @current-change="handlePageChange" />
    </el-card>

    <!-- 编辑表单弹窗 -->
    <el-dialog v-model="dialogState.visible" :title="dialogState.title" width="600px" append-to-body destroy-on-close
      :close-on-click-modal="false" :draggable="true">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" class="goods-form" status-icon>
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="formData.name" maxlength="50" show-word-limit placeholder="请输入商品名称" clearable
            :disabled="dialogState.loading" />
        </el-form-item>

        <el-form-item label="价格" prop="price">
          <el-input-number v-model="formData.price" :min="0" :precision="2" :step="0.01" placeholder="请输入商品价格"
            :disabled="dialogState.loading" />
        </el-form-item>

        <el-form-item label="商品分类" prop="category">
          <el-select v-model="formData.category" placeholder="请选择商品分类" :disabled="dialogState.loading">
            <el-option v-for="category in categoryList" :key="category.id" :label="category.name"
              :value="category.name" />
          </el-select>
        </el-form-item>

        <el-form-item label="发布者" prop="userName">
          <el-input v-model="formData.userName" placeholder="发布者信息" :disabled="true" />
        </el-form-item>

        <el-form-item label="发货地址" prop="address">
          <el-input v-model="formData.address" placeholder="请输入发货地址" clearable :disabled="dialogState.loading" />
        </el-form-item>

        <el-form-item label="审核状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择审核状态" :disabled="dialogState.loading">
            <el-option label="待审核" value="待审核" />
            <el-option label="通过" value="通过" />
            <el-option label="拒绝" value="拒绝" />
          </el-select>
        </el-form-item>

        <el-form-item label="商品图片" prop="img">
          <div class="image-preview">
            <el-image v-if="formData.img" :src="formData.img" fit="cover"
              style="width: 100px; height: 100px; border-radius: 4px;" />
            <div v-else class="empty-image">
              <el-icon>
                <Picture />
              </el-icon>
              <span>暂无图片</span>
            </div>
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogState.visible = false" :disabled="dialogState.loading">
            取消
          </el-button>
          <el-button type="primary" @click="handleSubmit" :loading="dialogState.loading">
            保存
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 商品详情预览弹窗 -->
    <el-dialog v-model="dialogState.detailVisible" title="商品详情" width="700px" append-to-body destroy-on-close
      :draggable="true">
      <div class="detail-content" v-html="dialogState.detail"></div>
      <template #footer>
        <el-button @click="dialogState.detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
/**
 * 商品管理组件样式
 */

// ===== 变量定义 =====
// 主色调
$primary-color: var(--el-color-primary);
$primary-light: var(--el-color-primary-light-3);
$primary-lighter: var(--el-color-primary-light-7);
$primary-dark: var(--el-color-primary-dark-2);

// 尺寸
$border-radius: 8px;
$card-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
$hover-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);

// 动画
$transition-time: 0.3s;
$transition-all: all $transition-time ease-in-out;
$transition-transform: transform $transition-time cubic-bezier(0.34, 1.56, 0.64, 1);

// 全局滚动条设置
:deep(*) {
  &::-webkit-scrollbar {
    display: none;
  }

  scrollbar-width: none;
  -ms-overflow-style: none;
}

// ===== 组件容器 =====
.goods-manager {
  padding: 16px;
  min-height: 100%;
  overflow: visible;

  // 页面标题
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;

    .header-title {
      display: flex;
      align-items: center;
      gap: 8px;

      .el-icon {
        font-size: 20px;
        color: $primary-color;
      }

      h2 {
        margin: 0;
        font-size: 20px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }
    }

    .header-extra {
      display: flex;
      gap: 12px;
      align-items: center;

      .view-toggle {
        display: flex;
        gap: 8px;

        .el-button {
          transition: all 0.3s;

          &:hover {
            transform: translateY(-2px);
          }
        }
      }
    }
  }

  // 搜索区域
  .search-card {
    margin-bottom: 16px;
    border-radius: $border-radius;
    transition: $transition-all;
    border: 1px solid #ebeef5;

    &:hover {
      box-shadow: $card-shadow;
    }

    .search-area {
      display: flex;
      align-items: center;
      gap: 16px;
      flex-wrap: wrap;

      .search-form {
        flex: 1;
        min-width: 280px;

        .el-input {
          max-width: 400px;
        }
      }

      .search-buttons {
        display: flex;
        gap: 8px;
        white-space: nowrap;
      }
    }
  }

  // 操作按钮区
  .operation-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;

    .left-actions {
      display: flex;
      align-items: center;
      gap: 12px;

      .selection-status {
        margin-left: 8px;
        font-size: 13px;
      }
    }

    .right-actions {
      display: flex;
      gap: 8px;
    }
  }

  // 数据展示区
  .data-card {
    border-radius: $border-radius;
    overflow: hidden;
    transition: $transition-all;
    margin-bottom: 16px;

    &:hover {
      box-shadow: $card-shadow;
    }

    // 表格内容区
    .goods-table {
      width: 100%;

      .name-cell {
        display: flex;
        align-items: center;
        gap: 8px;

        .el-icon {
          color: $primary-color;
        }
      }

      .publisher-cell {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;

        .publisher-name {
          font-size: 14px;
        }
      }

      .action-buttons {
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .price-tag {
        color: #ff6b35;
        font-weight: 600;
      }
    }

    // 卡片视图
    .card-view {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 16px;
      padding: 16px;

      .data-card-item {
        border: 1px solid #ebeef5;
        border-radius: $border-radius;
        padding: 16px;
        transition: $transition-all;
        cursor: pointer;
        position: relative;
        overflow: hidden;

        &:hover {
          box-shadow: $card-shadow;
          transform: translateY(-4px);
          border-color: $primary-lighter;
        }

        &.selected {
          border-color: $primary-color;
          background-color: rgba($primary-color, 0.05);

          &::after {
            content: '';
            position: absolute;
            top: 0;
            right: 0;
            border: 12px solid transparent;
            border-top-color: $primary-color;
            border-right-color: $primary-color;
          }
        }

        .card-header {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
          margin-bottom: 16px;

          .card-title {
            display: flex;
            align-items: center;
            gap: 8px;
            flex: 1;

            .el-icon {
              color: $primary-color;
              font-size: 18px;
            }

            h3 {
              margin: 0;
              font-size: 16px;
              font-weight: 600;
              color: var(--el-text-color-primary);
              overflow: hidden;
              text-overflow: ellipsis;
              white-space: nowrap;
            }
          }
        }

        .card-content {
          display: flex;
          gap: 16px;
          margin-bottom: 16px;

          .card-image {
            width: 120px;
            height: 120px;
            border-radius: 4px;
            overflow: hidden;
            flex-shrink: 0;

            .el-image {
              width: 100%;
              height: 100%;
              object-fit: cover;
            }

            .no-image {
              width: 100%;
              height: 100%;
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              background-color: #f5f7fa;
              color: #909399;

              .el-icon {
                font-size: 32px;
                margin-bottom: 8px;
              }
            }
          }

          .card-info {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;

            .info-item {
              display: flex;
              align-items: center;

              .label {
                width: 70px;
                color: var(--el-text-color-secondary);
                flex-shrink: 0;
              }

              .value {
                flex: 1;
                color: var(--el-text-color-primary);

                &.price {
                  color: #ff6b35;
                  font-weight: 600;
                }

                .publisher-info {
                  display: flex;
                  align-items: center;
                  gap: 6px;
                }
              }
            }
          }
        }

        .card-actions {
          display: flex;
          justify-content: flex-end;
          gap: 8px;
        }
      }
    }

    // 分页控制器
    .pagination {
      padding: 16px;
      display: flex;
      justify-content: flex-end;
      background-color: var(--el-bg-color-page);
      border-top: 1px solid var(--el-border-color-lighter);
    }
  }
}

// ===== 弹窗样式 =====
.goods-form {
  margin: 16px 0;

  .image-preview {
    display: flex;
    align-items: center;

    .empty-image {
      width: 100px;
      height: 100px;
      border-radius: 4px;
      border: 1px dashed var(--el-border-color);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      color: var(--el-text-color-secondary);

      .el-icon {
        font-size: 24px;
        margin-bottom: 8px;
      }
    }
  }
}

.detail-content {
  max-height: 60vh;
  overflow-y: hidden;
  padding: 16px;
  background-color: var(--el-bg-color-page);
  border-radius: 4px;
  line-height: 1.6;
  word-break: break-word;
}

// ===== 媒体查询 =====
@media screen and (max-width: 768px) {
  .goods-manager {
    padding: 12px;

    .search-area {
      flex-direction: column;
      align-items: stretch;

      .search-form {
        margin-bottom: 12px;
      }
    }

    .operation-bar {
      flex-direction: column;
      align-items: flex-start;
      gap: 12px;

      .right-actions {
        align-self: flex-end;
      }
    }

    .card-view {
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));

      .data-card-item {
        .card-content {
          flex-direction: column;

          .card-image {
            width: 100%;
            height: 180px;
          }
        }
      }
    }
  }
}

// ===== 动画效果 =====
// 列表项进入/离开动画
.list-enter-active,
.list-leave-active {
  transition: all 0.5s ease;
}

.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateY(30px);
}

// 选择态动画
.selected-enter-active,
.selected-leave-active {
  transition: background-color 0.3s ease;
}

.selected-enter-from,
.selected-leave-to {
  background-color: transparent;
}
</style>