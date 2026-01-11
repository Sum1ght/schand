<script setup>
/**
 * 用户信息管理组件
 * 提供用户的增删改查、批量操作和分页功能
 * 实现响应式布局和交互动效
 */
import {
  Delete, Edit,
  Grid, List,
  Plus,
  RefreshRight,
  Search,
  User
} from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref } from 'vue'

// 导入API和Store
import {
  addUserAPI,
  deleteBatchUserAPI,
  deleteUserAPI,
  getUserPageAPI,
  updateUserAPI
} from '@/api/userAPI'
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
  viewType: localStorage.getItem('user-view-type') || 'table'
})

// ===== 表单状态 =====
const dialogState = reactive({
  visible: false,
  title: '用户信息',
  mode: 'add', // add, edit
  loading: false
})

// ===== 数据状态 =====
const tableData = ref([])
const searchForm = reactive({
  username: ''
})
const formData = reactive({
  id: undefined,
  username: '',
  name: '',
  phone: '',
  email: '',
  avatar: '',
  role: '用户'
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
  username: [
    { required: true, message: '请输入账号', trigger: 'blur' },
    { min: 3, max: 20, message: '长度应为3-20个字符', trigger: 'blur' }
  ],
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' },
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' },
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
 * 加载用户数据
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
    const res = await getUserPageAPI({
      pageNum: pagination.currentPage,
      pageSize: pagination.pageSize,
      username: searchForm.username.trim() || undefined
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
    console.error('加载用户数据失败:', error)
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
  searchForm.username = ''
  loadData({ resetPage: true })

  nextTick(() => {
    if (searchInputRef.value) {
      searchInputRef.value.focus()
    }
  })
}

// ===== 表单操作 =====
/**
 * 打开添加用户表单
 */
const handleAdd = () => {
  dialogState.mode = 'add'
  dialogState.title = '添加用户'
  Object.assign(formData, {
    id: undefined,
    username: '',
    name: '',
    phone: '',
    email: '',
    avatar: '',
    role: '用户'
  })
  dialogState.visible = true

  nextTick(() => {
    formRef.value?.clearValidate()
  })
}

/**
 * 打开编辑用户表单
 * @param {Object} row - 表格行数据
 */
const handleEdit = (row) => {
  dialogState.mode = 'edit'
  dialogState.title = '编辑用户'
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
      const saveAPI = isEdit ? updateUserAPI : addUserAPI
      const res = await saveAPI(formData)

      if (res.code === '200') {
        ElNotification({
          title: isEdit ? '编辑成功' : '添加成功',
          message: isEdit
            ? `用户"${formData.username}"已更新`
            : `用户"${formData.username}"已创建`,
          type: 'success',
          duration: 2000
        })
        dialogState.visible = false
        loadData({ resetPage: !isEdit })
      } else {
        showError(res.msg || '操作失败')
      }
    } catch (error) {
      console.error('保存用户信息失败:', error)
      showError('操作失败，请稍后重试')
    } finally {
      dialogState.loading = false
    }
  })
}

// ===== 删除操作 =====
/**
 * 删除单个用户
 * @param {Object} row - 表格行数据
 */
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除用户"${row.username}"吗？删除后不可恢复。`,
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

    try {
      const res = await deleteUserAPI(row.id)

      if (res.code === '200') {
        ElMessage.success(`用户"${row.username}"已删除`)
        if (tableData.value.length === 1 && pagination.currentPage > 1) {
          pagination.currentPage--
        }
        loadData()
      } else {
        showError(res.msg || '删除失败')
      }
    } catch (error) {
      console.error('删除用户失败:', error)
      showError('删除失败，请稍后重试')
    } finally {
      pageState.operating = false
    }
  } catch (error) {
    // 用户取消，不做处理
  }
}

/**
 * 批量删除用户
 */
const handleBatchDelete = async () => {
  if (!hasSelected.value) {
    ElMessage.warning('请先选择要删除的数据')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedIds.value.length} 个用户吗？删除后不可恢复。`,
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

    try {
      const res = await deleteBatchUserAPI(selectedIds.value)

      if (res.code === '200') {
        ElMessage.success(`已成功删除 ${selectedIds.value.length} 个用户`)
        loadData({ resetPage: tableData.value.length === selectedIds.value.length })
      } else {
        showError(res.msg || '批量删除失败')
      }
    } catch (error) {
      console.error('批量删除用户失败:', error)
      showError('批量删除失败，请稍后重试')
    } finally {
      pageState.operating = false
    }
  } catch (error) {
    // 用户取消，不做处理
  }
}

// ===== 表格交互 =====
/**
 * 处理表格选择变化
 * @param {Array} selection - 选中的行
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
  localStorage.setItem('user-view-type', type)
}

/**
 * 处理分页变化
 * @param {Number} page - 页码
 */
const handlePageChange = (page) => {
  pagination.currentPage = page
  loadData()
}

/**
 * 处理每页条数变化
 * @param {Number} size - 每页条数
 */
const handleSizeChange = (size) => {
  pagination.pageSize = size
  loadData({ resetPage: true })
}

// ===== 图像处理 =====
/**
 * 头像上传成功处理
 * @param {Object} response - 上传响应
 */
const handleAvatarSuccess = (response) => {
  if (response.code === '200') {
    formData.avatar = response.data
    ElMessage.success('头像上传成功')
  } else {
    showError('头像上传失败: ' + (response.msg || '未知错误'))
  }
}

/**
 * 上传前文件校验
 * @param {File} file - 上传的文件
 */
const beforeAvatarUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('头像必须是图片文件')
  }
  if (!isLt2M) {
    ElMessage.error('头像大小不能超过 2MB')
  }

  return isImage && isLt2M
}

/**
 * 显示错误提示
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
  <div class="user-manager">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon>
          <User />
        </el-icon>
        <h2>用户管理</h2>
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
          <el-input ref="searchInputRef" v-model="searchForm.username" placeholder="请输入账号关键词" clearable
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
          新增用户
        </el-button>

        <el-button type="danger" :icon="Delete" @click="handleBatchDelete"
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
          }" table-layout="auto" class="user-table" row-key="id">
          <!-- 选择列 -->
          <el-table-column type="selection" width="55" align="center" fixed="left" />

          <!-- 序号列 -->
          <el-table-column prop="id" label="ID" width="80" align="center" sortable />

          <!-- 账号列 -->
          <el-table-column prop="username" label="账号" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="cell-with-icon">
                <el-icon>
                  <Key />
                </el-icon>
                <span>{{ row.username }}</span>
              </div>
            </template>
          </el-table-column>

          <!-- 姓名列 -->
          <el-table-column prop="name" label="姓名" min-width="120" show-overflow-tooltip />

          <!-- 电话列 -->
          <el-table-column prop="phone" label="电话" min-width="140" show-overflow-tooltip />

          <!-- 邮箱列 -->
          <el-table-column prop="email" label="邮箱" min-width="180" show-overflow-tooltip />

          <!-- 头像列 -->
          <el-table-column label="头像" width="100" align="center">
            <template #default="{ row }">
              <el-avatar v-if="row.avatar" :src="row.avatar" :size="40"
                @click="$event => row.avatar && $event.target.classList.toggle('avatar-preview')"
                class="avatar-in-table" />
              <el-avatar v-else :size="40">
                <el-icon>
                  <User />
                </el-icon>
              </el-avatar>
            </template>
          </el-table-column>

          <!-- 角色列 -->
          <el-table-column prop="role" label="角色" width="100" align="center">
            <template #default="{ row }">
              <el-tag type="primary">{{ row.role || '用户' }}</el-tag>
            </template>
          </el-table-column>

          <!-- 操作列 -->
          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-buttons">
                <el-tooltip content="编辑用户" placement="top">
                  <el-button type="primary" link :icon="Edit" @click="handleEdit(row)" :loading="pageState.operating" />
                </el-tooltip>

                <el-divider direction="vertical" />

                <el-tooltip content="删除用户" placement="top">
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
                  <el-avatar class="card-avatar" v-if="item.avatar" :src="item.avatar" :size="40" />
                  <el-avatar v-else class="card-avatar" :size="40">
                    <el-icon>
                      <User />
                    </el-icon>
                  </el-avatar>
                  <h3>{{ item.username }}</h3>
                </div>
                <div class="card-id">#{{ item.id }}</div>
              </div>

              <div class="card-content">
                <div class="info-item">
                  <div class="info-label">姓名</div>
                  <div class="info-value">{{ item.name || '未设置' }}</div>
                </div>
                <div class="info-item">
                  <div class="info-label">电话</div>
                  <div class="info-value">{{ item.phone || '未设置' }}</div>
                </div>
                <div class="info-item">
                  <div class="info-label">邮箱</div>
                  <div class="info-value text-ellipsis">{{ item.email || '未设置' }}</div>
                </div>
                <div class="info-item">
                  <div class="info-label">角色</div>
                  <div class="info-value">
                    <el-tag type="primary" size="small">{{ item.role || '用户' }}</el-tag>
                  </div>
                </div>
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

          <el-empty v-else description="暂无用户数据" />
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
      <el-form ref="formRef" :model="formData" :rules="formRules" label-width="100px" class="user-form" status-icon>
        <el-form-item label="账号" prop="username">
          <el-input v-model="formData.username" placeholder="请输入账号" clearable :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入姓名" clearable :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="formData.phone" placeholder="请输入电话" clearable :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="formData.email" placeholder="请输入邮箱" clearable :disabled="dialogState.loading" />
        </el-form-item>
        <el-form-item label="头像">
          <el-upload class="avatar-uploader" :action="'http://localhost:9090/files/upload'"
            :headers="{ token: user.token }" :show-file-list="false" :before-upload="beforeAvatarUpload"
            :on-success="handleAvatarSuccess" :disabled="dialogState.loading">
            <img v-if="formData.avatar" :src="formData.avatar" class="avatar-preview" />
            <el-icon v-else class="avatar-uploader-icon">
              <Plus />
            </el-icon>
            <div class="upload-tip">点击上传头像，图片不超过2MB</div>
          </el-upload>
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
 * 用户信息管理组件样式
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
.user-manager {
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
    .user-table {
      width: 100%;

      .cell-with-icon {
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

      .avatar-in-table {
        cursor: pointer;
        transition: $transition-all;
        border: 2px solid rgba(0, 0, 0, 0.1);

        &:hover {
          transform: scale(1.1);
          box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }

        &.avatar-preview {
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%) scale(4);
          z-index: 2000;
          box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
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

            .card-avatar {
              border: 2px solid rgba($primary-color, 0.2);
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

          .info-item {
            display: flex;
            margin-bottom: 8px;

            .info-label {
              width: 60px;
              color: var(--el-text-color-secondary);
              font-size: 14px;
            }

            .info-value {
              flex: 1;
              color: var(--el-text-color-primary);
              font-size: 14px;
              word-break: break-all;

              &.text-ellipsis {
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
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

  // 表单弹窗
  .user-form {
    margin: 16px 0;

    .avatar-uploader {
      display: flex;
      flex-direction: column;
      align-items: center;

      :deep(.el-upload) {
        border: 1px dashed var(--el-border-color);
        border-radius: $border-radius;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: $transition-all;

        &:hover {
          border-color: $primary-color;
        }
      }

      .avatar-uploader-icon {
        font-size: 28px;
        color: var(--el-text-color-placeholder);
        width: 100px;
        height: 100px;
        display: flex;
        justify-content: center;
        align-items: center;
      }

      .avatar-preview {
        width: 100px;
        height: 100px;
        display: block;
        object-fit: cover;
        border-radius: $border-radius;
        transition: $transition-all;

        &:hover {
          transform: scale(1.05);
          box-shadow: $card-shadow;
        }
      }

      .upload-tip {
        font-size: 12px;
        color: var(--el-text-color-secondary);
        margin-top: 8px;
      }
    }
  }
}

// ===== 媒体查询 =====
@media screen and (max-width: 768px) {
  .user-manager {
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