<script setup>
/**
 * 圈子信息管理组件
 * 提供圈子的增删改查、批量操作和分页功能
 * 实现响应式布局和交互动效
 */
import {
  Connection,
  Delete,
  Document,
  Edit,
  Grid, List,
  Picture,
  Plus,
  RefreshRight,
  Search
} from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref } from 'vue'

// 导入API和Store
import {
  addCircleAPI,
  deleteBatchCircleAPI,
  deleteCircleAPI,
  getCirclesPageAPI,
  updateCircleAPI
} from '@/api/circleAPI'
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
  viewType: localStorage.getItem('circles-view-type') || 'table'
})

// ===== 表单状态 =====
const dialogState = reactive({
  visible: false,
  title: '圈子信息',
  mode: 'add', // add, edit
  loading: false
})

// ===== 数据状态 =====
const tableData = ref([])
const searchForm = reactive({
  name: '',
})
const formData = reactive({
  id: undefined,
  name: '',
  img: ''
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
  name: [
    { required: true, message: '请输入圈子名称', trigger: 'blur' },
    { min: 1, max: 30, message: '长度应为1-30个字符', trigger: 'blur' }
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
 * 加载圈子数据
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
    const res = await getCirclesPageAPI({
      pageNum: pagination.currentPage,
      pageSize: pagination.pageSize,
      name: searchForm.name.trim() || undefined
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
    console.error('加载圈子数据失败:', error)
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
  searchForm.name = ''
  loadData({ resetPage: true })

  nextTick(() => {
    if (searchInputRef.value) {
      searchInputRef.value.focus()
    }
  })
}

// ===== 文件上传处理 =====
/**
 * 文件上传成功处理
 * @param {Object} response - 上传响应结果
 */
const handleFileSuccess = (response) => {
  formData.img = response.data
}

// ===== 表单操作 =====
/**
 * 打开添加圈子表单
 */
const handleAdd = () => {
  dialogState.mode = 'add'
  dialogState.title = '添加圈子'
  Object.assign(formData, { id: undefined, name: '', img: '' })
  dialogState.visible = true

  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

/**
 * 打开编辑圈子表单
 * @param {Object} row - 表格行数据
 */
const handleEdit = (row) => {
  dialogState.mode = 'edit'
  dialogState.title = '编辑圈子'
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
      const isEdit = dialogState.mode === 'edit'
      const saveAPI = isEdit ? updateCircleAPI : addCircleAPI
      const res = await saveAPI(formData)

      if (res.code === '200') {
        ElNotification({
          title: isEdit ? '编辑成功' : '添加成功',
          message: isEdit
            ? `圈子"${formData.name}"已更新`
            : `圈子"${formData.name}"已创建`,
          type: 'success',
          duration: 2000
        })
        dialogState.visible = false
        loadData({ resetPage: !isEdit })
      } else {
        showError(res.msg || '操作失败')
      }
    } catch (error) {
      console.error('保存圈子信息失败:', error)
      showError('操作失败，请稍后重试')
    } finally {
      dialogState.loading = false
    }
  })
}

// ===== 删除操作 =====
/**
 * 删除单个圈子
 * @param {Object} row - 表格行数据
 */
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除圈子"${row.name}"吗？删除后不可恢复。`,
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

    const res = await deleteCircleAPI(row.id)

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
      console.error('删除圈子失败:', error)
      showError('操作失败，请稍后重试')
    }
  } finally {
    pageState.operating = false
  }
}

/**
 * 批量删除圈子
 */
const handleDeleteBatch = async () => {
  if (!selectedIds.value.length) {
    ElMessage.warning('请先选择要删除的数据')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedIds.value.length} 项圈子吗？删除后不可恢复。`,
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

    const res = await deleteBatchCircleAPI(selectedIds.value)

    if (res.code === '200') {
      ElNotification({
        title: '批量删除成功',
        message: `已删除 ${selectedIds.value.length} 项圈子数据`,
        type: 'success',
        duration: 2000
      })
      loadData({ resetPage: tableData.value.length === selectedIds.value.length })
    } else {
      showError(res.msg || '批量删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('批量删除圈子失败:', error)
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
  localStorage.setItem('circles-view-type', type)
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
  <div class="circles-manager">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon>
          <Connection />
        </el-icon>
        <h2>圈子管理</h2>
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
          <el-input ref="searchInputRef" v-model="searchForm.name" placeholder="请输入圈子名称" clearable
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
        <el-button type="primary" :icon="Plus" @click="handleAdd" :disabled="pageState.operating">
          新增圈子
        </el-button>

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
          }" table-layout="auto" class="circles-table" row-key="id">
          <!-- 选择列 -->
          <el-table-column type="selection" width="55" align="center" fixed="left" />

          <!-- 序号列 -->
          <el-table-column label="序号" width="80" align="center" sortable>
            <template #default="scope">{{ scope.$index + 1 }}</template>
          </el-table-column>

          <!-- 缩略图列 -->
          <el-table-column prop="img" label="缩略图" width="120" align="center">
            <template #default="{ row }">
              <el-image v-if="row.img" style="width: 70px; height: 70px; border-radius: 4px; object-fit: cover;"
                :src="row.img" :preview-src-list="[row.img]" fit="cover" :z-index="2000" preview-teleported />
              <div v-else class="empty-image">
                <el-icon>
                  <Picture />
                </el-icon>
              </div>
            </template>
          </el-table-column>

          <!-- 名称列 -->
          <el-table-column prop="name" label="圈子名称" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="name-cell">
                <el-icon>
                  <Document />
                </el-icon>
                <span>{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 操作列 -->
          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-tooltip content="编辑圈子" placement="top">
                  <el-button type="primary" link :icon="Edit" @click="handleEdit(row)" :loading="pageState.operating" />
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="删除圈子" placement="top">
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
                <div class="card-title">
                  <el-icon>
                    <Document />
                  </el-icon>
                  <h3>{{ item.name }}</h3>
                </div>
                <div class="card-id">#{{ item.id }}</div>
              </div>

              <div class="card-actions">
                <el-button type="primary" plain size="small" :icon="Edit" @click.stop="handleEdit(item)">
                  编辑
                </el-button>
                <el-button type="danger" plain size="small" :icon="Delete" @click.stop="handleDelete(item)">
                  删除
                </el-button>
              </div>
            </div>
          </template>

          <el-empty v-else description="暂无圈子数据" />
        </div>
      </template>

      <!-- 分页控制 -->
      <el-pagination v-if="tableData.length > 0 || pagination.total > 0" class="pagination" background
        :current-page="pagination.currentPage" :page-sizes="pagination.pageSizes" :page-size="pagination.pageSize"
        :layout="pagination.layout" :total="pagination.total" @size-change="handleSizeChange"
        @current-change="handlePageChange" />
    </el-card>

    <!-- 表单弹窗 -->
    <el-dialog v-model="dialogState.visible" :title="dialogState.title" width="550px" append-to-body destroy-on-close
      :close-on-click-modal="false" :draggable="true">
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" class="circles-form" status-icon>
        <el-form-item label="圈子名称" prop="name">
          <el-input v-model="formData.name" maxlength="30" show-word-limit placeholder="请输入圈子名称" clearable
            :disabled="dialogState.loading" />
        </el-form-item>

        <el-form-item label="缩略图" prop="img">
          <el-upload class="avatar-uploader" :action="'http://localhost:9090/files/upload'"
            :headers="{ token: user.token }" :show-file-list="false" :on-success="handleFileSuccess"
            :disabled="dialogState.loading">
            <el-image v-if="formData.img" :src="formData.img" fit="cover" class="avatar-preview" />
            <div v-else class="upload-placeholder">
              <el-icon>
                <Plus />
              </el-icon>
              <div class="upload-text">点击上传</div>
            </div>
          </el-upload>
          <div class="upload-tip">建议上传正方形图片，尺寸不超过2MB</div>
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
 * 圈子管理组件样式
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
.circles-manager {
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
    .circles-table {
      width: 100%;

      .name-cell {
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

      .empty-image {
        width: 70px;
        height: 70px;
        border-radius: 4px;
        background-color: #f5f7fa;
        display: flex;
        align-items: center;
        justify-content: center;

        .el-icon {
          font-size: 24px;
          color: var(--el-text-color-placeholder);
        }
      }
    }

    // 卡片视图
    .card-view {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
      gap: 16px;
      padding: 16px;

      .data-card-item {
        border: 1px solid #ebeef5;
        border-radius: $border-radius;
        padding: 0;
        transition: $transition-all;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        display: flex;
        flex-direction: column;

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

        .card-image {
          width: 100%;
          height: 160px;
          overflow: visible;
          position: relative;

          .el-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
          }

          &:hover .el-image {
            transform: scale(1.05);
          }

          .no-image {
            width: 100%;
            height: 100%;
            background-color: #f5f7fa;
            display: flex;
            align-items: center;
            justify-content: center;

            .el-icon {
              font-size: 36px;
              color: var(--el-text-color-placeholder);
            }
          }
        }

        .card-info {
          padding: 16px;
          display: flex;
          justify-content: space-between;
          align-items: flex-start;

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
              white-space: nowrap;
              overflow: visible;
              text-overflow: ellipsis;
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

        .card-actions {
          display: flex;
          justify-content: flex-end;
          gap: 8px;
          padding: 0 16px 16px;
          margin-top: auto;
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
.circles-form {
  margin: 16px 0;

  .avatar-uploader {
    .avatar-preview {
      width: 178px;
      height: 178px;
      display: block;
      object-fit: cover;
      border-radius: 6px;
    }

    .upload-placeholder {
      width: 178px;
      height: 178px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      border: 1px dashed var(--el-border-color);
      border-radius: 6px;
      cursor: pointer;
      transition: $transition-all;

      &:hover {
        border-color: $primary-color;
        background-color: rgba($primary-color, 0.05);
      }

      .el-icon {
        font-size: 28px;
        color: #8c939d;
        margin-bottom: 8px;
      }

      .upload-text {
        color: var(--el-text-color-secondary);
        font-size: 14px;
      }
    }
  }

  .upload-tip {
    font-size: 12px;
    color: var(--el-text-color-secondary);
    margin-top: 8px;
  }
}

// ===== 媒体查询 =====
@media screen and (max-width: 768px) {
  .circles-manager {
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
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
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