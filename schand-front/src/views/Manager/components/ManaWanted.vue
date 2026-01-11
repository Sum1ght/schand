<script setup>
/**
 * 求购信息管理组件
 * 提供求购信息的增删改查、批量操作和分页功能
 * 实现响应式布局和交互动效
 */
import {
  Aim,
  Check, Close,
  Delete,
  Document,
  Edit,
  Grid, List,
  RefreshRight,
  Search
} from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref } from 'vue'

// 导入API和Store
import {
  deleteBatchHelpAPI,
  deleteHelpAPI,
  getHelpPageAPI,
  updateHelpAPI
} from '@/api/wantedAPI'
import { useUserStore } from '@/stores/userStore'

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
  viewType: localStorage.getItem('wanted-view-type') || 'table'
})

// ===== 表单状态 =====
const dialogState = reactive({
  visible: false,
  title: '求购信息',
  mode: 'edit', // 只有编辑模式
  loading: false
})

// ===== 数据状态 =====
const tableData = ref([])
const searchForm = reactive({
  title: '',
})
const formData = reactive({
  id: undefined,
  title: '',
  content: '',
  img: '',
  status: '',
  solved: ''
})
const selectedIds = ref([])

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
  title: [
    { required: true, message: '请输入标题', trigger: 'blur' },
    { min: 1, max: 100, message: '长度应为1-100个字符', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入内容', trigger: 'blur' }
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
 * 加载求购数据
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
    const res = await getHelpPageAPI({
      pageNum: pagination.currentPage,
      pageSize: pagination.pageSize,
      title: searchForm.title.trim() || undefined
    })

    if (res.code === '200') {
      tableData.value = res.data?.list || []
      pagination.total = res.data?.total || 0

      // 如果当前页数据为空且不是第一页，尝试加载前一页
      if (tableData.value.length === 0 && pagination.currentPage > 1) {
        pagination.currentPage--
        loadData({ showLoading: false })
      }
    } else {
      showError(res.msg || '加载数据失败')
    }
  } catch (error) {
    console.error('加载求购数据失败:', error)
    showError('网络异常，请稍后重试')
  } finally {
    pageState.loading = false
    pageState.refreshing = false
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
  searchForm.title = ''
  loadData({ resetPage: true })

  nextTick(() => {
    if (searchInputRef.value) {
      searchInputRef.value.focus()
    }
  })
}

// ===== 表单操作 =====
/**
 * 打开编辑求购表单
 * @param {Object} row - 表格行数据
 */
const handleEdit = (row) => {
  dialogState.title = '编辑求购信息'
  Object.assign(formData, JSON.parse(JSON.stringify(row)))
  dialogState.visible = true

  nextTick(() => {
    formRef.value?.clearValidate()
  })
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
      const res = await updateHelpAPI(formData)

      if (res.code === '200') {
        ElNotification({
          title: '编辑成功',
          message: `求购信息"${formData.title}"已更新`,
          type: 'success',
          duration: 2000
        })
        dialogState.visible = false
        loadData()
      } else {
        showError(res.msg || '操作失败')
      }
    } catch (error) {
      console.error('保存求购信息失败:', error)
      showError('操作失败，请稍后重试')
    } finally {
      dialogState.loading = false
    }
  })
}

// ===== 审核操作 =====
/**
 * 更改审核状态
 * @param {Object} row - 表格行数据
 * @param {String} status - 新状态
 */
const changeStatus = async (row, status) => {
  const statusText = status === '通过' ? '通过审核' : '拒绝审核'

  try {
    await ElMessageBox.confirm(
      `确定要将该求购信息${statusText}吗？`,
      '审核确认',
      {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: status === '通过' ? 'success' : 'warning',
        draggable: true,
        closeOnClickModal: false
      }
    )

    pageState.operating = true

    const updatedData = JSON.parse(JSON.stringify(row))
    updatedData.status = status

    const res = await updateHelpAPI(updatedData)

    if (res.code === '200') {
      ElMessage({
        message: `${statusText}成功`,
        type: 'success',
        duration: 2000
      })
      loadData()
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
 * 删除单个求购信息
 * @param {Object} row - 表格行数据
 */
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除标题为"${row.title}"的求购信息吗？删除后不可恢复。`,
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

    const res = await deleteHelpAPI(row.id)

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
      console.error('删除求购信息失败:', error)
      showError('操作失败，请稍后重试')
    }
  } finally {
    pageState.operating = false
  }
}

/**
 * 批量删除求购信息
 */
const handleDeleteBatch = async () => {
  if (!selectedIds.value.length) {
    ElMessage.warning('请先选择要删除的数据')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedIds.value.length} 项求购信息吗？删除后不可恢复。`,
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

    const res = await deleteBatchHelpAPI(selectedIds.value)

    if (res.code === '200') {
      ElNotification({
        title: '批量删除成功',
        message: `已删除 ${selectedIds.value.length} 项求购信息数据`,
        type: 'success',
        duration: 2000
      })
      loadData({ resetPage: tableData.value.length === selectedIds.value.length })
    } else {
      showError(res.msg || '批量删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除求购信息失败:', error)
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
  localStorage.setItem('wanted-view-type', type)
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
})
</script>

<template>
  <div class="wanted-manager">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon>
          <Aim />
        </el-icon>
        <h2>悬赏管理</h2>
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
          <el-input ref="searchInputRef" v-model="searchForm.title" placeholder="请输入标题关键字查询" clearable
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
        <!-- 预留位置用于导出等功能 -->
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
          }" table-layout="auto" class="wanted-table" row-key="id">
          <!-- 选择列 -->
          <el-table-column type="selection" width="55" align="center" fixed="left" />

          <!-- 序号列 -->
          <el-table-column prop="id" label="序号" width="70" align="center" sortable />

          <!-- 标题列 -->
          <el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip sortable>
            <template #default="{ row }">
              <div class="title-cell">
                <el-icon>
                  <Document />
                </el-icon>
                <span>{{ row.title }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 内容列 -->
          <el-table-column prop="content" label="内容" min-width="200" show-overflow-tooltip />

          <!-- 图片列 -->
          <el-table-column prop="img" label="图片" width="100">
            <template #default="scope">
              <el-image v-if="scope.row.img" style="width: 50px; height: 50px; object-fit: cover;" :src="scope.row.img"
                :preview-src-list="[scope.row.img]" fit="cover" />
            </template>
          </el-table-column>

          <!-- 用户信息列 -->
          <el-table-column prop="userName" label="用户信息" width="120">
            <template #default="{ row }">
              <div class="user-info">
                <div class="user-name">{{ row.userName }}</div>
                <div class="user-id">ID: {{ row.userId }}</div>
              </div>
            </template>
          </el-table-column>

          <!-- 发布时间列 -->
          <el-table-column prop="time" label="发布时间" width="160" />

          <!-- 解决状态列 -->
          <el-table-column prop="solved" label="解决状态" width="100" align="center">
            <template #default="scope">
              <el-tag type="danger" v-if="scope.row.solved === '未解决'">未解决</el-tag>
              <el-tag type="success" v-if="scope.row.solved === '已解决'">已解决</el-tag>
            </template>
          </el-table-column>

          <!-- 审核状态列 -->
          <el-table-column prop="status" label="审核状态" width="100" align="center">
            <template #default="scope">
              <el-tag type="info" v-if="scope.row.status === '待审核'">待审核</el-tag>
              <el-tag type="success" v-if="scope.row.status === '通过'">通过</el-tag>
              <el-tag type="danger" v-if="scope.row.status === '拒绝'">拒绝</el-tag>
            </template>
          </el-table-column>

          <!-- 操作列 -->
          <el-table-column label="操作" width="220" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-tooltip content="审核通过" placement="top">
                  <el-button type="success" link :icon="Check" @click="changeStatus(row, '通过')"
                    :loading="pageState.operating">
                    通过
                  </el-button>
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="审核拒绝" placement="top">
                  <el-button type="warning" link :icon="Close" @click="changeStatus(row, '拒绝')"
                    :loading="pageState.operating">
                    拒绝
                  </el-button>
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="编辑信息" placement="top">
                  <el-button type="primary" link :icon="Edit" @click="handleEdit(row)" :loading="pageState.operating" />
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="删除求购" placement="top">
                  <el-button type="danger" link :icon="Delete" @click="handleDelete(row)"
                    :loading="pageState.operating" />
                </el-tooltip>
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
                  <h3>{{ item.title }}</h3>
                </div>
                <div class="card-id">#{{ item.id }}</div>
              </div>

              <div class="card-content">
                <div class="info-item">
                  <div class="label">内容：</div>
                  <div class="value">{{ item.content }}</div>
                </div>

                <div class="info-grid">
                  <div class="info-item">
                    <div class="label">用户：</div>
                    <div class="value">{{ item.userName }}</div>
                  </div>
                  <div class="info-item">
                    <div class="label">时间：</div>
                    <div class="value">{{ item.time }}</div>
                  </div>
                </div>

                <div class="info-grid">
                  <div class="info-item">
                    <div class="label">解决状态：</div>
                    <div class="value">
                      <el-tag size="small" :type="item.solved === '已解决' ? 'success' : 'danger'">
                        {{ item.solved }}
                      </el-tag>
                    </div>
                  </div>
                  <div class="info-item">
                    <div class="label">审核状态：</div>
                    <div class="value">
                      <el-tag size="small"
                        :type="item.status === '通过' ? 'success' : item.status === '待审核' ? 'info' : 'danger'">
                        {{ item.status }}
                      </el-tag>
                    </div>
                  </div>
                </div>

                <div class="image-preview" v-if="item.img">
                  <el-image :src="item.img" fit="cover" :preview-src-list="[item.img]" />
                </div>
              </div>

              <div class="card-actions">
                <el-button type="success" plain size="small" :icon="Check" @click.stop="changeStatus(item, '通过')">
                  通过
                </el-button>
                <el-button type="warning" plain size="small" :icon="Close" @click.stop="changeStatus(item, '拒绝')">
                  拒绝
                </el-button>
                <el-button type="primary" plain size="small" :icon="Edit" @click.stop="handleEdit(item)">
                  编辑
                </el-button>
                <el-button type="danger" plain size="small" :icon="Delete" @click.stop="handleDelete(item)">
                  删除
                </el-button>
              </div>
            </div>
          </template>

          <el-empty v-else description="暂无求购数据" />
        </div>
      </template>

      <!-- 分页控制 -->
      <el-pagination v-if="tableData.length > 0 || pagination.total > 0" class="pagination" background
        :current-page="pagination.currentPage" :page-sizes="pagination.pageSizes" :page-size="pagination.pageSize"
        :layout="pagination.layout" :total="pagination.total" @size-change="handleSizeChange"
        @current-change="handlePageChange" />
    </el-card>

    <!-- 表单弹窗 -->
    <el-dialog v-model="dialogState.visible" :title="dialogState.title" width="500px" append-to-body destroy-on-close
      :close-on-click-modal="false" :draggable="true">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" class="wanted-form" status-icon>
        <el-form-item label="标题" prop="title">
          <el-input v-model="formData.title" maxlength="100" show-word-limit placeholder="请输入标题" clearable
            :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input type="textarea" v-model="formData.content" placeholder="请输入内容" rows="4"
            :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="图片" prop="img">
          <el-input v-model="formData.img" placeholder="请输入图片URL" clearable :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="审核状态" prop="status">
          <el-select v-model="formData.status" placeholder="请选择审核状态" :disabled="dialogState.loading">
            <el-option label="待审核" value="待审核" />
            <el-option label="通过" value="通过" />
            <el-option label="拒绝" value="拒绝" />
          </el-select>
        </el-form-item>
        <el-form-item label="解决状态" prop="solved">
          <el-select v-model="formData.solved" placeholder="请选择解决状态" :disabled="dialogState.loading">
            <el-option label="未解决" value="未解决" />
            <el-option label="已解决" value="已解决" />
          </el-select>
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
  </div>
</template>

<style scoped lang="scss">
/**
 * 求购管理组件样式
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
.wanted-manager {
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
    overflow: visible;
    transition: $transition-all;
    margin-bottom: 16px;

    &:hover {
      box-shadow: $card-shadow;
    }

    // 表格内容区
    .wanted-table {
      width: 100%;

      .title-cell {
        display: flex;
        align-items: center;
        gap: 8px;

        .el-icon {
          color: $primary-color;
        }
      }

      .action-buttons {
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .user-info {
        display: flex;
        flex-direction: column;
        gap: 3px;

        .user-name {
          font-weight: 500;
        }

        .user-id {
          font-size: 12px;
          color: var(--el-text-color-secondary);
        }
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
        overflow: visible;

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
          margin-bottom: 12px;

          .card-title {
            display: flex;
            align-items: center;
            gap: 8px;

            .el-icon {
              color: $primary-color;
              font-size: 18px;
            }

            h3 {
              margin: 0;
              font-size: 16px;
              font-weight: 600;
              color: var(--el-text-color-primary);
            }
          }

          .card-id {
            color: var(--el-text-color-secondary);
            font-size: 13px;
            background: $primary-lighter;
            padding: 2px 8px;
            border-radius: 12px;
          }
        }

        .card-content {
          display: flex;
          flex-direction: column;
          gap: 12px;
          margin-bottom: 16px;

          .info-item {
            display: flex;
            gap: 8px;

            .label {
              color: var(--el-text-color-secondary);
              font-size: 14px;
              white-space: nowrap;
            }

            .value {
              flex: 1;
              color: var(--el-text-color-primary);
              font-size: 14px;
              word-break: break-word;
            }
          }

          .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
          }

          .image-preview {
            margin-top: 8px;

            .el-image {
              width: 100%;
              height: 120px;
              border-radius: 4px;
              border: 1px solid var(--el-border-color-lighter);
            }
          }
        }

        .card-actions {
          display: flex;
          flex-wrap: wrap;
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
.wanted-form {
  margin: 16px 0;
}

// ===== 媒体查询 =====
@media screen and (max-width: 768px) {
  .wanted-manager {
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
      grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
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