<script setup>
/**
 * 反馈信息管理组件
 * 提供反馈的查看、回复、删除、批量操作和分页功能
 * 实现响应式布局和交互动效
 */
import {
  Calendar,
  ChatDotRound,
  ChatLineRound,
  Delete,
  Grid, List,
  Message,
  Phone,
  RefreshRight,
  Search,
  User
} from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref } from 'vue'

// 导入API和Store
import {
  deleteBatchFeedbackAPI,
  deleteFeedbackAPI,
  getFeedbackPageAPI,
  updateFeedbackAPI
} from '@/api/feedbackAPI'
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
  viewType: localStorage.getItem('feedback-view-type') || 'table'
})

// ===== 表单状态 =====
const dialogState = reactive({
  visible: false,
  title: '反馈回复',
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
  phone: '',
  email: '',
  reply: '',
  createtime: '',
  userId: '',
  userName: ''
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
  reply: [
    { required: true, message: '请输入回复内容', trigger: 'blur' },
    { min: 1, max: 500, message: '长度应为1-500个字符', trigger: 'blur' }
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
 * 加载反馈数据
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
    const res = await getFeedbackPageAPI({
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
    console.error('加载反馈数据失败:', error)
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
 * 打开回复反馈表单
 * @param {Object} row - 表格行数据
 */
const handleEdit = (row) => {
  dialogState.title = '回复反馈'
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
      const res = await updateFeedbackAPI(formData)

      if (res.code === '200') {
        ElNotification({
          title: '回复成功',
          message: `已成功回复用户 ${formData.userName} 的反馈`,
          type: 'success',
          duration: 2000
        })
        dialogState.visible = false
        loadData()
      } else {
        showError(res.msg || '操作失败')
      }
    } catch (error) {
      console.error('回复反馈信息失败:', error)
      showError('操作失败，请稍后重试')
    } finally {
      dialogState.loading = false
    }
  })
}

// ===== 删除操作 =====
/**
 * 删除单个反馈
 * @param {Object} row - 表格行数据
 */
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除 ${row.userName} 的反馈"${row.title}"吗？删除后不可恢复。`,
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

    const res = await deleteFeedbackAPI(row.id)

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
      console.error('删除反馈失败:', error)
      showError('操作失败，请稍后重试')
    }
  } finally {
    pageState.operating = false
  }
}

/**
 * 批量删除反馈
 */
const handleDeleteBatch = async () => {
  if (!selectedIds.value.length) {
    ElMessage.warning('请先选择要删除的数据')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedIds.value.length} 项反馈吗？删除后不可恢复。`,
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

    const res = await deleteBatchFeedbackAPI(selectedIds.value)

    if (res.code === '200') {
      ElNotification({
        title: '批量删除成功',
        message: `已删除 ${selectedIds.value.length} 项反馈数据`,
        type: 'success',
        duration: 2000
      })
      loadData({ resetPage: tableData.value.length === selectedIds.value.length })
    } else {
      showError(res.msg || '批量删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除反馈失败:', error)
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
  localStorage.setItem('feedback-view-type', type)
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
  <div class="feedback-manager">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon>
          <Message />
        </el-icon>
        <h2>反馈管理</h2>
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
          <el-input ref="searchInputRef" v-model="searchForm.title" placeholder="请输入反馈主题关键词" clearable
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
          }" table-layout="auto" class="feedback-table" row-key="id">
          <!-- 选择列 -->
          <el-table-column type="selection" width="55" align="center" fixed="left" />

          <!-- 序号列 -->
          <el-table-column prop="id" label="ID" width="80" align="center" sortable />

          <!-- 主题列 -->
          <el-table-column prop="title" label="反馈主题" min-width="150" show-overflow-tooltip sortable>
            <template #default="{ row }">
              <div class="title-cell">
                <el-icon>
                  <ChatDotRound />
                </el-icon>
                <span>{{ row.title }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 内容列 -->
          <el-table-column prop="content" label="反馈内容" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">
              <el-tooltip :content="row.content" placement="top" :show-after="500">
                <span class="content-text">{{ row.content }}</span>
              </el-tooltip>
            </template>
          </el-table-column>

          <!-- 联系方式列 -->
          <el-table-column prop="phone" label="联系电话" width="120">
            <template #default="{ row }">
              <div class="phone-cell" v-if="row.phone">
                <el-icon>
                  <Phone />
                </el-icon>
                <span>{{ row.phone }}</span>
              </div>
              <span v-else class="empty-text">未提供</span>
            </template>
          </el-table-column>

          <!-- 邮箱列 -->
          <el-table-column prop="email" label="电子邮箱" width="180" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="email-cell" v-if="row.email">
                <el-icon>
                  <el-icon>
                    <Message />
                  </el-icon>
                </el-icon>
                <span>{{ row.email }}</span>
              </div>
              <span v-else class="empty-text">未提供</span>
            </template>
          </el-table-column>

          <!-- 回复列 -->
          <el-table-column prop="reply" label="回复内容" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">
              <div v-if="row.reply" class="reply-cell">
                <el-tooltip :content="row.reply" placement="top" :show-after="500">
                  <span class="reply-text">{{ row.reply }}</span>
                </el-tooltip>
              </div>
              <el-tag v-else type="info" size="small">未回复</el-tag>
            </template>
          </el-table-column>

          <!-- 时间列 -->
          <el-table-column prop="createtime" label="创建时间" width="180" sortable>
            <template #default="{ row }">
              <div class="time-cell">
                <el-icon>
                  <Calendar />
                </el-icon>
                <span>{{ row.createtime }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 用户列 -->
          <el-table-column prop="userName" label="提交人" width="120">
            <template #default="{ row }">
              <div class="user-cell">
                <el-icon>
                  <User />
                </el-icon>
                <span>{{ row.userName }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 操作列 -->
          <el-table-column label="操作" width="180" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-tooltip content="回复反馈" placement="top">
                  <el-button type="primary" link :icon="ChatLineRound" @click="handleEdit(row)"
                    :loading="pageState.operating" />
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="删除反馈" placement="top">
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
                    <ChatDotRound />
                  </el-icon>
                  <h3>{{ item.title }}</h3>
                </div>
                <div class="card-id">#{{ item.id }}</div>
              </div>

              <div class="card-content">
                <p class="feedback-content">{{ item.content }}</p>

                <div class="contact-info">
                  <div v-if="item.phone" class="info-item">
                    <el-icon>
                      <Phone />
                    </el-icon>
                    <span>{{ item.phone }}</span>
                  </div>
                  <div v-if="item.email" class="info-item">
                    <el-icon>
                      <el-icon>
                        <Message />
                      </el-icon>
                    </el-icon>
                    <span>{{ item.email }}</span>
                  </div>
                </div>

                <div class="reply-section" v-if="item.reply">
                  <div class="reply-title">回复内容：</div>
                  <div class="reply-content">{{ item.reply }}</div>
                </div>
                <el-tag v-else type="info" size="small">未回复</el-tag>
              </div>

              <div class="card-footer">
                <div class="user-time">
                  <div class="user-info">
                    <el-icon>
                      <User />
                    </el-icon>
                    <span>{{ item.userName }}</span>
                  </div>
                  <div class="time-info">
                    <el-icon>
                      <Calendar />
                    </el-icon>
                    <span>{{ item.createtime }}</span>
                  </div>
                </div>

                <div class="card-actions">
                  <el-button type="primary" plain size="small" :icon="ChatLineRound" @click.stop="handleEdit(item)">
                    回复
                  </el-button>
                  <el-button type="danger" plain size="small" :icon="Delete" @click.stop="handleDelete(item)">
                    删除
                  </el-button>
                </div>
              </div>
            </div>
          </template>

          <el-empty v-else description="暂无反馈数据" />
        </div>
      </template>

      <!-- 分页控制 -->
      <el-pagination v-if="tableData.length > 0 || pagination.total > 0" class="pagination" background
        :current-page="pagination.currentPage" :page-sizes="pagination.pageSizes" :page-size="pagination.pageSize"
        :layout="pagination.layout" :total="pagination.total" @size-change="handleSizeChange"
        @current-change="handlePageChange" />
    </el-card>

    <!-- 表单弹窗 -->
    <el-dialog v-model="dialogState.visible" :title="dialogState.title" width="600px" append-to-body destroy-on-close
      :close-on-click-modal="false" :draggable="true">
      <div class="feedback-details">
        <div class="feedback-info">
          <div class="info-item">
            <span class="label">反馈主题：</span>
            <span class="value">{{ formData.title }}</span>
          </div>
          <div class="info-item">
            <span class="label">反馈内容：</span>
            <div class="value content-box">{{ formData.content }}</div>
          </div>
          <div class="info-item">
            <span class="label">联系方式：</span>
            <span class="value">{{ formData.phone || '未提供' }}</span>
          </div>
          <div class="info-item">
            <span class="label">电子邮箱：</span>
            <span class="value">{{ formData.email || '未提供' }}</span>
          </div>
          <div class="info-item">
            <span class="label">提交时间：</span>
            <span class="value">{{ formData.createtime }}</span>
          </div>
          <div class="info-item">
            <span class="label">提交用户：</span>
            <span class="value">{{ formData.userName }}</span>
          </div>
        </div>

        <el-divider content-position="center">回复信息</el-divider>

        <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" class="feedback-form"
          status-icon>
          <el-form-item label="回复内容" prop="reply">
            <el-input v-model="formData.reply" type="textarea" :rows="4" maxlength="500" show-word-limit
              placeholder="请输入回复内容" :disabled="dialogState.loading" />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogState.visible = false" :disabled="dialogState.loading">
            取消
          </el-button>
          <el-button type="primary" @click="handleSubmit" :loading="dialogState.loading">
            提交回复
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped lang="scss">
/**
 * 反馈管理组件样式
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
    width: 6px;
    height: 6px;
  }

  &::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 3px;
  }

  &::-webkit-scrollbar-track {
    background-color: transparent;
  }

  scrollbar-width: thin;
  scrollbar-color: rgba(0, 0, 0, 0.2) transparent;
}

// ===== 组件容器 =====
.feedback-manager {
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  // 页面标题
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
    flex-shrink: 0;

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
    flex-shrink: 0;

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
    flex-shrink: 0;

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
    flex: 1;
    display: flex;
    flex-direction: column;
    min-height: 0;
    border-radius: $border-radius;
    overflow: hidden;
    transition: $transition-all;
    margin-bottom: 16px;

    &:hover {
      box-shadow: $card-shadow;
    }

    // 表格内容区
    .feedback-table {
      width: 100%;
      flex: 1;
      overflow: auto;

      .title-cell,
      .phone-cell,
      .email-cell,
      .time-cell,
      .user-cell {
        display: flex;
        align-items: center;
        gap: 8px;

        .el-icon {
          color: $primary-color;
        }
      }

      .content-text,
      .reply-text {
        color: var(--el-text-color-secondary);
        font-size: 14px;
      }

      .empty-text {
        color: var(--el-text-color-placeholder);
        font-style: italic;
        font-size: 13px;
      }

      .action-buttons {
        display: flex;
        justify-content: center;
        align-items: center;
      }
    }

    // 卡片视图
    .card-view {
      padding: 16px;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 16px;
      overflow-y: auto;
      flex: 1;

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
          margin-bottom: 16px;
          display: flex;
          flex-direction: column;
          gap: 12px;

          .feedback-content {
            color: var(--el-text-color-secondary);
            font-size: 14px;
            line-height: 1.5;
            margin: 0;
            padding: 0;
            max-height: 60px;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
          }

          .contact-info {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;

            .info-item {
              display: flex;
              align-items: center;
              gap: 6px;
              font-size: 13px;
              color: var(--el-text-color-secondary);

              .el-icon {
                color: $primary-color;
                font-size: 14px;
              }
            }
          }

          .reply-section {
            background-color: rgba($primary-color, 0.05);
            border-radius: 6px;
            padding: 8px 12px;
            margin-top: 6px;

            .reply-title {
              font-size: 13px;
              font-weight: 600;
              margin-bottom: 4px;
              color: $primary-dark;
            }

            .reply-content {
              font-size: 13px;
              color: var(--el-text-color-regular);
              line-height: 1.5;
              max-height: 60px;
              overflow: hidden;
              text-overflow: ellipsis;
              display: -webkit-box;
              -webkit-line-clamp: 2;
              -webkit-box-orient: vertical;
            }
          }
        }

        .card-footer {
          display: flex;
          flex-direction: column;
          gap: 12px;

          .user-time {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            color: var(--el-text-color-secondary);

            .user-info,
            .time-info {
              display: flex;
              align-items: center;
              gap: 4px;

              .el-icon {
                font-size: 14px;
                color: $primary-color;
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
    }

    // 分页控制器
    .pagination {
      padding: 16px;
      display: flex;
      justify-content: flex-end;
      background-color: var(--el-bg-color-page);
      border-top: 1px solid var(--el-border-color-lighter);
      flex-shrink: 0;
    }
  }
}

// ===== 弹窗样式 =====
.feedback-form {
  margin: 16px 0;
}

.feedback-details {
  .feedback-info {
    display: flex;
    flex-direction: column;
    gap: 12px;

    .info-item {
      display: flex;
      align-items: flex-start;

      .label {
        width: 100px;
        flex-shrink: 0;
        color: var(--el-text-color-secondary);
        text-align: right;
        padding-right: 12px;
      }

      .value {
        flex: 1;
        color: var(--el-text-color-primary);
        word-break: break-all;
      }

      .content-box {
        background-color: #f9f9f9;
        padding: 10px;
        border-radius: 4px;
        max-height: 120px;
        overflow-y: auto;
        line-height: 1.5;
      }
    }
  }
}

// ===== 媒体查询 =====
@media screen and (max-width: 768px) {
  .feedback-manager {
    padding: 0;

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
    }
  }

  .feedback-details {
    .feedback-info {
      .info-item {
        flex-direction: column;

        .label {
          width: 100%;
          text-align: left;
          margin-bottom: 4px;
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