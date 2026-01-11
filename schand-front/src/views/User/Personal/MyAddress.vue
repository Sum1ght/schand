<script setup>
import { ref, reactive, onMounted } from 'vue'

import { Location, Edit, Delete, Plus, Phone, User } from '@element-plus/icons-vue'
import {
    getAddressPageAPI,
    addAddressAPI,
    updateAddressAPI,
    deleteAddressAPI,
    deleteBatchAddressAPI
} from '@/api/addressAPI.js'

// 表单引用
const formRef = ref(null)

// 页面状态
const pageState = reactive({
    loading: false,
    pageNum: 1,
    pageSize: 10,
    total: 0,
    tableData: [],
    ids: []
})

// 对话框可见性
const dialogVisible = ref(false)

// 表单数据
const form = reactive({})

// 用户信息
const user = reactive(JSON.parse(localStorage.getItem('xm-user') || '{}'))

// 表单验证规则
const rules = {
    name: [
        { required: true, message: '请输入联系人姓名', trigger: 'blur' }
    ],
    address: [
        { required: true, message: '请输入联系地址', trigger: 'blur' }
    ],
    phone: [
        { required: true, message: '请输入联系电话', trigger: 'blur' },
        { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
    ]
}

// 加载地址数据
const loadAddresses = async (page) => {
    try {
        pageState.loading = true
        if (page) pageState.pageNum = page

        const res = await getAddressPageAPI({
            pageNum: pageState.pageNum,
            pageSize: pageState.pageSize,
            userId: user.id
        })

        if (res.code === '200') {
            pageState.tableData = res.data?.list || []
            pageState.total = res.data?.total || 0
        } else {
            ElMessage.error(res.msg || '获取地址列表失败')
        }
    } catch (error) {
        console.error('加载地址数据失败:', error)
        ElMessage.error('加载地址数据失败')
    } finally {
        pageState.loading = false
    }
}

// 处理新增地址
const handleAdd = () => {
    Object.keys(form).forEach(key => delete form[key])
    dialogVisible.value = true
}

// 处理编辑地址
const handleEdit = (row) => {
    Object.assign(form, JSON.parse(JSON.stringify(row)))
    dialogVisible.value = true
}

// 保存地址
const saveAddress = () => {
    if (!formRef.value) return

    formRef.value.validate(async (valid) => {
        if (valid) {
            try {
                // 添加用户ID
                form.userId = user.id

                const api = form.id ? updateAddressAPI : addAddressAPI
                const res = await api(form)

                if (res.code === '200') {
                    ElMessage.success('保存成功')
                    dialogVisible.value = false
                    loadAddresses(1)
                } else {
                    ElMessage.error(res.msg || '保存失败')
                }
            } catch (error) {
                console.error('保存地址失败:', error)
                ElMessage.error('保存地址失败')
            }
        }
    })
}

// 单个地址选择
const handleItemSelect = (checked, item) => {
    if (checked) {
        if (!pageState.ids.includes(item.id)) {
            pageState.ids.push(item.id)
        }
    } else {
        const index = pageState.ids.indexOf(item.id)
        if (index > -1) {
            pageState.ids.splice(index, 1)
        }
    }
}

// 删除单个地址
const deleteAddress = (id) => {
    ElMessageBox.confirm('确定要删除这个地址吗？', '删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            const res = await deleteAddressAPI(id)

            if (res.code === '200') {
                ElMessage.success('删除成功')
                loadAddresses(1)
            } else {
                ElMessage.error(res.msg || '删除失败')
            }
        } catch (error) {
            console.error('删除地址失败:', error)
            ElMessage.error('删除地址失败')
        }
    }).catch(() => { })
}

// 批量删除地址
const deleteBatchAddresses = () => {
    if (!pageState.ids.length) {
        ElMessage.warning('请选择要删除的地址')
        return
    }

    ElMessageBox.confirm(`确定要删除选中的 ${pageState.ids.length} 个地址吗？`, '批量删除确认', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            const res = await deleteBatchAddressAPI(pageState.ids)

            if (res.code === '200') {
                ElMessage.success('批量删除成功')
                loadAddresses(1)
            } else {
                ElMessage.error(res.msg || '批量删除失败')
            }
        } catch (error) {
            console.error('批量删除地址失败:', error)
            ElMessage.error('批量删除地址失败')
        }
    }).catch(() => { })
}

// 处理表格选择变化
const handleSelectionChange = (rows) => {
    pageState.ids = rows.map(row => row.id)
}

// 处理分页变化
const handleCurrentChange = (page) => {
    loadAddresses(page)
}

// 生命周期钩子
onMounted(() => {
    loadAddresses(1)
})
</script>

<template>
    <div class="my-address-container">
        <!-- 顶部卡片 -->
        <div class="address-header-card">
            <div class="address-title">
                <span class="title-icon"><el-icon>
                        <Location />
                    </el-icon></span>
                <h2>我的收货地址</h2>
            </div>

            <!-- 按钮区域 -->
            <div class="action-container">
                <div class="action-buttons">
                    <el-button type="primary" @click="handleAdd">
                        <el-icon>
                            <Plus />
                        </el-icon><span>新增地址</span>
                    </el-button>
                    <el-button type="danger" :disabled="!pageState.ids.length" @click="deleteBatchAddresses">
                        <el-icon>
                            <Delete />
                        </el-icon><span>批量删除</span>
                    </el-button>
                </div>
            </div>
        </div>

        <!-- 地址内容区域 -->
        <div class="address-content">
            <div class="address-container">
                <!-- 地址卡片列表 -->
                <transition-group name="fade" tag="div" class="address-card-list">
                    <!-- 空状态 -->
                    <div v-if="pageState.tableData.length === 0 && !pageState.loading" class="empty-state" key="empty">
                        <el-empty description="暂无收货地址">
                            <template #image>
                                <img src="https://img.alicdn.com/tfs/TB1l65ihAL0gK0jSZFxXXXWHVXa-300-250.svg" />
                            </template>
                        </el-empty>
                    </div>

                    <!-- 地址卡片 -->
                    <div v-for="item in pageState.tableData" :key="item.id" class="address-card">
                        <!-- 复选框 -->
                        <div class="card-checkbox">
                            <el-checkbox @change="(val) => handleItemSelect(val, item)"
                                :checked="pageState.ids.includes(item.id)" />
                        </div>

                        <!-- 卡片内容 -->
                        <div class="address-card-content">
                            <div class="address-info">
                                <div class="address-header">
                                    <div class="contact-info">
                                        <el-icon>
                                            <User />
                                        </el-icon>
                                        <span class="contact-name">{{ item.name }}</span>
                                    </div>
                                    <div class="phone-info">
                                        <el-icon>
                                            <Phone />
                                        </el-icon>
                                        <span>{{ item.phone }}</span>
                                    </div>
                                </div>

                                <div class="address-detail">
                                    <el-icon>
                                        <Location />
                                    </el-icon>
                                    <span>{{ item.address }}</span>
                                </div>
                            </div>
                        </div>

                        <!-- 卡片底部 -->
                        <div class="address-card-footer">
                            <div class="address-actions">
                                <el-button type="primary" @click="handleEdit(item)" class="action-button">
                                    <el-icon>
                                        <Edit />
                                    </el-icon>
                                    编辑
                                </el-button>
                                <el-button type="danger" @click="deleteAddress(item.id)" class="action-button">
                                    <el-icon>
                                        <Delete />
                                    </el-icon>
                                    删除
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
                    <el-pagination background @current-change="handleCurrentChange" :current-page="pageState.pageNum"
                        :page-size="pageState.pageSize" layout="total, prev, pager, next, jumper"
                        :total="pageState.total" hide-on-single-page />
                </div>
            </div>
        </div>

        <!-- 地址表单对话框 -->
        <el-dialog v-model="dialogVisible" :title="form.id ? '编辑收货地址' : '新增收货地址'" width="40%"
            :close-on-click-modal="false" destroy-on-close center>
            <el-form :model="form" label-width="100px" :rules="rules" ref="formRef" class="address-form">
                <el-form-item label="联系人" prop="name">
                    <el-input v-model="form.name" placeholder="请输入联系人姓名">
                        <template #prefix>
                            <el-icon>
                                <User />
                            </el-icon>
                        </template>
                    </el-input>
                </el-form-item>
                <el-form-item label="联系地址" prop="address">
                    <el-input v-model="form.address" placeholder="请输入详细地址">
                        <template #prefix>
                            <el-icon>
                                <Location />
                            </el-icon>
                        </template>
                    </el-input>
                </el-form-item>
                <el-form-item label="联系电话" prop="phone">
                    <el-input v-model="form.phone" placeholder="请输入联系电话">
                        <template #prefix>
                            <el-icon>
                                <Phone />
                            </el-icon>
                        </template>
                    </el-input>
                </el-form-item>
            </el-form>

            <template #footer>
                <div class="dialog-footer">
                    <el-button @click="dialogVisible = false">取 消</el-button>
                    <el-button type="primary" @click="saveAddress">确 定</el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
// 主容器样式
.my-address-container {
    padding: 20px;
    min-height: calc(100vh - 120px);
    background-color: var(--el-bg-color-page, #f5f7fa);

    // 顶部卡片样式
    .address-header-card {
        max-width: 1000px;
        margin: 0 auto 20px;
        background-color: var(--el-bg-color, #fff);
        border-radius: 12px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
        padding: 24px;

        .address-title {
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

        // 操作区域
        .action-container {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;

            .action-buttons {
                display: flex;
                gap: 12px;
                flex-wrap: wrap;

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

    // 地址内容区域
    .address-content {
        position: relative;
        min-height: 300px;

        // 地址容器
        .address-container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: var(--el-bg-color, #fff);
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
            padding: 24px;

            // 地址卡片列表
            .address-card-list {
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

                // 地址卡片
                .address-card {
                    position: relative;
                    background: var(--el-bg-color, #fff);
                    border-radius: 12px;
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
                    overflow: hidden;
                    transition: all 0.3s ease;

                    &:hover {
                        transform: translateY(-3px);
                        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
                    }

                    // 复选框
                    .card-checkbox {
                        position: absolute;
                        top: 10px;
                        left: 10px;
                        z-index: 2;
                    }

                    // 卡片内容
                    .address-card-content {
                        padding: 16px 20px 16px 40px; // 左侧增加空间，容纳复选框

                        .address-info {
                            display: flex;
                            flex-direction: column;
                            gap: 16px;

                            .address-header {
                                display: flex;
                                justify-content: space-between;
                                flex-wrap: wrap;
                                gap: 10px;

                                .contact-info,
                                .phone-info {
                                    display: flex;
                                    align-items: center;
                                    gap: 8px;

                                    .el-icon {
                                        color: var(--el-color-primary);
                                    }

                                    .contact-name {
                                        font-weight: 600;
                                        font-size: 16px;
                                    }
                                }
                            }

                            .address-detail {
                                display: flex;
                                align-items: flex-start;
                                gap: 8px;
                                padding-top: 5px;

                                .el-icon {
                                    margin-top: 3px;
                                    color: var(--el-color-success);
                                }

                                span {
                                    flex: 1;
                                    line-height: 1.5;
                                    color: var(--el-text-color-primary);
                                }
                            }
                        }
                    }

                    // 卡片底部
                    .address-card-footer {
                        padding: 16px 20px;
                        border-top: 1px solid var(--el-border-color-lighter);
                        background-color: var(--el-bg-color, #fff);

                        .address-actions {
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

// 表单样式
.address-form {
    padding: 10px 20px;

    :deep(.el-input__wrapper) {
        box-shadow: 0 0 0 1px #dcdfe6 inset;
        transition: all 0.3s;

        &:hover {
            box-shadow: 0 0 0 1px #c0c4cc inset;
        }

        &.is-focus {
            box-shadow: 0 0 0 1px #409EFF inset;
        }
    }

    :deep(.el-form-item__label) {
        font-weight: 600;
        color: #606266;
    }
}

// 响应式布局
@media (max-width: 768px) {
    .my-address-container {
        padding: 12px;

        .address-header-card {
            padding: 16px;

            .action-container {
                flex-direction: column;

                .action-buttons {
                    width: 100%;
                    justify-content: space-between;
                }
            }
        }

        .address-content {
            .address-container {
                padding: 16px;

                .address-card {
                    .address-card-content {
                        padding: 30px 16px 16px 16px;

                        .address-info {
                            .address-header {
                                flex-direction: column;
                                align-items: flex-start;
                            }
                        }
                    }

                    .address-card-footer {
                        .address-actions {
                            justify-content: center;
                        }
                    }
                }
            }
        }
    }
}
</style>