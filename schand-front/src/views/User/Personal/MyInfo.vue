<script setup>
/**
 * 个人信息页面
 */
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowRight, Check, Close, Document, Edit, EditPen, Key, Lock, Message, Phone, Setting, UploadFilled, User, UserFilled, Loading, InfoFilled, ArrowDown } from '@element-plus/icons-vue'
import { updateUserAPI } from '@/api/userAPI'
import { updatePasswordAPI } from '@/api/webAPI'
import { uploadFileAPI } from '@/api/fileAPI'
import { useUserStore } from '@/stores/userStore'

// 用户状态管理
const userStore = useUserStore()
const router = useRouter()

// 表单refs
const infoFormRef = ref(null)
const passwordFormRef = ref(null)

// 复制用户信息，避免直接修改store中的状态
const userForm = reactive({
    ...userStore.userInfo
})

// 密码修改相关状态
const passwordForm = reactive({
    password: '',
    newPassword: '',
    confirmPassword: ''
})
const passwordDialogVisible = ref(false)

// 页面状态管理
const isEditing = ref(false)
const loading = reactive({
    saveInfo: false,
    uploadAvatar: false,
    savePassword: false
})

// 表单验证规则
const infoRules = {
    name: [
        { required: true, message: '请输入姓名', trigger: 'blur' },
        { min: 2, max: 20, message: '姓名长度应为2-20个字符', trigger: 'blur' }
    ],
    phone: [
        { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
    ],
    email: [
        { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
    ]
}

const passwordRules = {
    password: [
        { required: true, message: '请输入原始密码', trigger: 'blur' },
        { min: 6, message: '密码长度至少为6个字符', trigger: 'blur' }
    ],
    newPassword: [
        { required: true, message: '请输入新密码', trigger: 'blur' },
        { min: 6, message: '密码长度至少为6个字符', trigger: 'blur' }
    ],
    confirmPassword: [
        { required: true, message: '请确认新密码', trigger: 'blur' },
        {
            validator: (rule, value, callback) => {
                if (value === '') {
                    callback(new Error('请确认新密码'))
                } else if (value !== passwordForm.newPassword) {
                    callback(new Error('两次输入的密码不一致'))
                } else {
                    callback()
                }
            },
            trigger: 'blur'
        }
    ]
}

// 计算属性
const avatarUrl = computed(() => userForm.avatar || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png')
const isFormChanged = computed(() => {
    return userForm.name !== userStore.userInfo.name ||
        userForm.phone !== userStore.userInfo.phone ||
        userForm.email !== userStore.userInfo.email
})

// 密码强度计算
const passwordStrengthClass = computed(() => {
    if (!passwordForm.newPassword) return ''

    const password = passwordForm.newPassword
    let strength = 0

    // 长度检查
    if (password.length >= 8) strength += 1

    // 包含大写字母
    if (/[A-Z]/.test(password)) strength += 1

    // 包含小写字母
    if (/[a-z]/.test(password)) strength += 1

    // 包含数字
    if (/[0-9]/.test(password)) strength += 1

    // 包含特殊字符
    if (/[^A-Za-z0-9]/.test(password)) strength += 1

    if (strength <= 2) return 'weak'
    if (strength <= 4) return 'medium'
    return 'strong'
})

const passwordStrengthText = computed(() => {
    switch (passwordStrengthClass.value) {
        case 'weak': return '弱'
        case 'medium': return '中等'
        case 'strong': return '强'
        default: return ''
    }
})

// 头像上传前检查
const beforeAvatarUpload = (file) => {
    const isImage = file.type.startsWith('image/')
    const isLt2M = file.size / 1024 / 1024 < 2

    if (!isImage) {
        ElMessage.error('上传头像图片只能是图片格式!')
        return false
    }
    if (!isLt2M) {
        ElMessage.error('上传头像图片大小不能超过 2MB!')
        return false
    }
    return true
}

// 使用API函数上传头像
const handleAvatarUpload = async (options) => {
    try {
        loading.uploadAvatar = true
        const { file } = options

        // 调用API函数上传文件
        const res = await uploadFileAPI(file)

        if (res.code === '200') {
            userForm.avatar = res.data
            userStore.updateUserInfo({ avatar: res.data })
            ElMessage.success('头像上传成功')
        } else {
            ElMessage.error(res.msg || '头像上传失败')
        }
    } catch (error) {
        console.error('头像上传失败:', error)
        ElMessage.error('头像上传失败，请稍后重试')
    } finally {
        loading.uploadAvatar = false
    }
}

// 启用编辑模式
const enableEditing = () => {
    isEditing.value = true
}

// 取消编辑
const cancelEditing = () => {
    ElMessageBox.confirm('确定要放弃当前修改吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(() => {
        // 重置表单为store中的数据
        Object.assign(userForm, userStore.userInfo)
        isEditing.value = false
        infoFormRef.value?.clearValidate()
    }).catch(() => { })
}

// 保存用户信息
const saveUserInfo = async () => {
    if (!infoFormRef.value) return

    try {
        await infoFormRef.value.validate()

        if (!isFormChanged.value) {
            isEditing.value = false
            return
        }

        loading.saveInfo = true

        // 构建更新请求数据
        const updateData = {
            id: userStore.userInfo.id,
            name: userForm.name,
            phone: userForm.phone,
            email: userForm.email
        }

        const res = await updateUserAPI(updateData)
        if (res.code === '200') {
            ElMessage({
                type: 'success',
                message: '个人信息更新成功',
                duration: 1500
            })
            // 更新store中的用户信息
            userStore.updateUserInfo(updateData)
            isEditing.value = false
        } else {
            ElMessage.error(res.msg || '保存失败')
        }
    } catch (error) {
        console.error('验证或更新用户信息失败:', error)
    } finally {
        loading.saveInfo = false
    }
}

// 打开修改密码对话框
const openPasswordDialog = () => {
    // 重置密码表单
    Object.keys(passwordForm).forEach(key => {
        passwordForm[key] = ''
    })
    passwordDialogVisible.value = true
}

// 修改密码
const updatePassword = async () => {
    if (!passwordFormRef.value) return

    try {
        await passwordFormRef.value.validate()
        loading.savePassword = true

        // 构建密码更新请求数据
        const passwordData = {
            username: userStore.userInfo.username,
            password: passwordForm.password,
            newPassword: passwordForm.newPassword,
            role: userStore.userInfo.role || 'USER'
        }

        const res = await updatePasswordAPI(passwordData)

        if (res.code === '200') {
            ElMessage({
                type: 'success',
                message: '密码修改成功，请重新登录',
                duration: 1500
            })
            passwordDialogVisible.value = false

            // 延迟后重定向到登录页
            setTimeout(() => {
                userStore.logout()
                router.push('/login')
            }, 1500)
        } else {
            ElMessage.error(res.msg || '密码修改失败')
        }
    } catch (error) {
        console.error('密码修改失败:', error)
    } finally {
        loading.savePassword = false
    }
}

// 初始化
onMounted(() => {
    // 复制用户信息到表单
    Object.assign(userForm, userStore.userInfo)
})
</script>

<template>
    <div class="my-info-container">
        <!-- 顶部信息栏 -->
        <div class="page-header">
            <div class="header-content">
                <div class="title-section">
                    <h1 class="main-title">
                        <el-icon class="title-icon">
                            <InfoFilled />
                        </el-icon>
                        我的资料
                    </h1>
                    <p class="description">在这里您可以查看和修改个人资料信息，保持您的账户信息最新</p>
                </div>
                <div class="user-summary">
                    <el-avatar :size="80" :src="avatarUrl" class="header-avatar" />
                    <div class="user-basic-info">
                        <h2 class="username">{{ userStore.userInfo.username }}</h2>
                        <p class="user-meta">
                            <span class="joined-date">用户ID: {{ userStore.userInfo.id || '未知' }}</span>
                            <span class="joined-date">注册时间: {{ userStore.userInfo.registerTime ? new
                                Date(userStore.userInfo.registerTime).toLocaleDateString() : '未知' }}</span>
                            <el-tag size="small" type="success" effect="light">{{ userStore.userInfo.role === 'ADMIN' ?
                                '管理员' : '普通用户' }}</el-tag>
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- 主要内容区 -->
        <div class="main-content">
            <el-row :gutter="20">
                <!-- 左侧信息卡片 -->
                <el-col :xs="24" :sm="24" :md="16" :lg="16">
                    <el-card class="info-card">
                        <template #header>
                            <div class="card-header">
                                <span class="header-title">
                                    <el-icon>
                                        <Document />
                                    </el-icon>
                                    基本资料
                                </span>
                                <div class="header-actions">
                                    <template v-if="!isEditing">
                                        <el-button type="primary" @click="enableEditing" :icon="Edit"
                                            class="action-btn edit-btn" size="small">
                                            编辑资料
                                        </el-button>
                                    </template>
                                </div>
                            </div>
                        </template>

                        <!-- 表单区域 -->
                        <el-form ref="infoFormRef" :model="userForm" :rules="infoRules" label-position="top"
                            class="info-form" :disabled="!isEditing">
                            <el-row :gutter="20">
                                <el-col :xs="24" :sm="24" :md="24">
                                    <el-form-item label="姓名" prop="name">
                                        <el-input v-model="userForm.name" placeholder="请输入姓名" :prefix-icon="User" />
                                    </el-form-item>
                                </el-col>
                                <el-col :xs="24" :sm="24" :md="24">
                                    <el-form-item label="手机号码" prop="phone">
                                        <el-input v-model="userForm.phone" placeholder="请输入手机号码" :prefix-icon="Phone" />
                                    </el-form-item>
                                </el-col>
                                <el-col :xs="24" :sm="24" :md="24">
                                    <el-form-item label="电子邮箱" prop="email">
                                        <el-input v-model="userForm.email" placeholder="请输入电子邮箱"
                                            :prefix-icon="Message" />
                                    </el-form-item>
                                </el-col>
                            </el-row>

                            <!-- 表单操作按钮 -->
                            <div class="form-actions" v-if="isEditing">
                                <el-button @click="cancelEditing" :icon="Close" class="action-btn cancel-btn">
                                    取消
                                </el-button>
                                <el-button type="primary" @click="saveUserInfo" :loading="loading.saveInfo"
                                    :icon="Check" class="action-btn save-btn">
                                    保存更改
                                </el-button>
                            </div>
                        </el-form>
                    </el-card>
                </el-col>

                <!-- 右侧工具卡片 -->
                <el-col :xs="24" :sm="24" :md="8" :lg="8">
                    <el-card class="avatar-card">
                        <template #header>
                            <div class="card-header">
                                <span class="header-title">
                                    <el-icon>
                                        <UserFilled />
                                    </el-icon>
                                    个人头像
                                </span>
                            </div>
                        </template>
                        <div class="avatar-content">
                            <el-upload class="avatar-uploader" :auto-upload="true" :show-file-list="false"
                                :http-request="handleAvatarUpload" :before-upload="beforeAvatarUpload">
                                <div class="avatar-wrapper">
                                    <el-avatar :src="avatarUrl" :size="120" class="user-avatar"
                                        :class="{ 'avatar-loading': loading.uploadAvatar }" />
                                    <div class="avatar-overlay">
                                        <el-icon v-if="loading.uploadAvatar">
                                            <Loading />
                                        </el-icon>
                                        <template v-else>
                                            <el-icon>
                                                <UploadFilled />
                                            </el-icon>
                                            <span>更换头像</span>
                                        </template>
                                    </div>
                                </div>
                            </el-upload>
                            <p class="avatar-tip">点击头像上传新照片，建议使用正方形图片</p>
                        </div>
                    </el-card>

                    <el-card class="tool-card">
                        <template #header>
                            <div class="card-header">
                                <span class="header-title">
                                    <el-icon>
                                        <Setting />
                                    </el-icon>
                                    安全设置
                                </span>
                            </div>
                        </template>
                        <div class="tool-items">
                            <div class="tool-item" @click="openPasswordDialog">
                                <div class="tool-icon">
                                    <el-icon>
                                        <Lock />
                                    </el-icon>
                                </div>
                                <div class="tool-info">
                                    <h3>修改密码</h3>
                                    <p>定期更换密码可以保护账户安全</p>
                                </div>
                                <div class="tool-action">
                                    <el-icon>
                                        <ArrowRight />
                                    </el-icon>
                                </div>
                            </div>
                        </div>
                    </el-card>
                </el-col>
            </el-row>
        </div>

        <!-- 修改密码对话框 -->
        <el-dialog v-model="passwordDialogVisible" title="修改密码" width="460px" :close-on-click-modal="false"
            destroy-on-close center class="password-dialog">
            <div class="password-header">
                <el-icon class="password-icon">
                    <Lock />
                </el-icon>
                <div class="password-title-info">
                    <h3>设置新密码</h3>
                    <p>强密码可以保护您的账户安全</p>
                </div>
            </div>

            <el-form ref="passwordFormRef" :model="passwordForm" :rules="passwordRules" label-position="top"
                class="password-form">
                <el-form-item label="当前密码" prop="password">
                    <el-input v-model="passwordForm.password" type="password" show-password placeholder="请输入当前密码"
                        :prefix-icon="Lock" />
                </el-form-item>

                <el-divider content-position="center">
                    <el-icon style="margin: 0 8px; opacity: 0.7;">
                        <ArrowDown />
                    </el-icon>
                </el-divider>

                <el-form-item label="新密码" prop="newPassword">
                    <el-input v-model="passwordForm.newPassword" type="password" show-password placeholder="请输入新密码"
                        :prefix-icon="Key" />
                    <div class="password-strength" v-if="passwordForm.newPassword">
                        <div class="strength-label">密码强度:</div>
                        <div class="strength-meter">
                            <div class="strength-bar" :class="passwordStrengthClass"></div>
                        </div>
                        <div class="strength-text" :class="passwordStrengthClass">{{ passwordStrengthText }}</div>
                    </div>
                </el-form-item>

                <el-form-item label="确认新密码" prop="confirmPassword">
                    <el-input v-model="passwordForm.confirmPassword" type="password" show-password
                        placeholder="请再次输入新密码" :prefix-icon="Check" />
                </el-form-item>

                <div class="password-tips">
                    <p><el-icon>
                            <InfoFilled />
                        </el-icon> 密码建议：</p>
                    <ul>
                        <li>长度至少8位字符</li>
                        <li>包含大小写字母、数字和特殊字符</li>
                        <li>避免使用常见词组和个人信息</li>
                    </ul>
                </div>
            </el-form>

            <template #footer>
                <div class="dialog-footer">
                    <el-button @click="passwordDialogVisible = false" class="cancel-btn">取消</el-button>
                    <el-button type="primary" @click="updatePassword" :loading="loading.savePassword"
                        class="confirm-btn">
                        确认修改
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
.my-info-container {
    min-height: 100%;
    background-color: var(--el-bg-color-page, #f2f3f5);

    // 顶部信息栏
    .page-header {
        background: linear-gradient(135deg, var(--el-color-primary), var(--el-color-primary-light-3));
        padding: 40px 0;
        color: white;
        margin-bottom: 30px;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);

        .header-content {
            width: 94%;
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;

            .title-section {
                flex: 1;
                min-width: 300px;

                .main-title {
                    margin: 0 0 8px;
                    font-size: 28px;
                    font-weight: 600;
                    display: flex;
                    align-items: center;

                    .title-icon {
                        margin-right: 12px;
                        font-size: 20px;
                        color: rgba(255, 255, 255, 0.85);
                        background-color: rgba(255, 255, 255, 0.2);
                        padding: 6px;
                        border-radius: 50%;
                        transition: all 0.3s;
                        vertical-align: middle;
                        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);

                        &:hover {
                            transform: rotate(15deg);
                            background-color: rgba(255, 255, 255, 0.3);
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
                        }
                    }
                }

                .description {
                    margin: 0;
                    opacity: 0.9;
                    font-size: 16px;
                    max-width: 500px;
                }
            }

            .user-summary {
                display: flex;
                align-items: center;
                gap: 15px;
                background: rgba(255, 255, 255, 0.1);
                padding: 15px;
                border-radius: 12px;
                backdrop-filter: blur(5px);

                .header-avatar {
                    border: 3px solid rgba(255, 255, 255, 0.6);
                }

                .user-basic-info {
                    .username {
                        margin: 0 0 5px;
                        font-size: 20px;
                        font-weight: 600;
                    }

                    .user-meta {
                        margin: 0;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        font-size: 14px;
                        opacity: 0.9;
                    }
                }
            }
        }
    }

    // 主内容区
    .main-content {
        width: 94%;
        max-width: 1200px;
        margin: 0 auto 40px;

        .info-card,
        .avatar-card,
        .tool-card {
            margin-bottom: 20px;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            overflow: hidden;

            &:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 20px rgba(0, 0, 0, 0.09);
            }

            .card-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 15px 20px;

                .header-title {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 16px;
                    font-weight: 600;
                    color: var(--el-text-color-primary);

                    .el-icon {
                        color: var(--el-color-primary);
                    }
                }
            }
        }

        // 表单样式
        .info-form {
            padding: 20px;

            :deep(.el-form-item__label) {
                font-weight: 500;
                color: var(--el-text-color-regular);
            }

            :deep(.el-input__wrapper) {
                border-radius: 8px;

                &:hover {
                    box-shadow: 0 0 0 1px var(--el-color-primary-light-5) inset;
                }
            }

            .form-actions {
                display: flex;
                justify-content: flex-end;
                gap: 12px;
                margin-top: 20px;

                .action-btn {
                    min-width: 100px;
                    border-radius: 6px;
                    transition: all 0.3s;

                    &:hover {
                        transform: translateY(-2px);
                    }
                }
            }
        }

        // 头像卡片样式
        .avatar-card {
            .avatar-content {
                padding: 20px;
                display: flex;
                flex-direction: column;
                align-items: center;

                .avatar-wrapper {
                    position: relative;
                    cursor: pointer;
                    margin-bottom: 16px;
                    border-radius: 50%;
                    overflow: hidden;

                    .user-avatar {
                        border: 4px solid var(--el-color-primary-light-8);
                        transition: all 0.3s;

                        &.avatar-loading {
                            filter: brightness(0.8);
                        }
                    }

                    .avatar-overlay {
                        position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        display: flex;
                        flex-direction: column;
                        justify-content: center;
                        align-items: center;
                        background: rgba(0, 0, 0, 0.5);
                        color: white;
                        opacity: 0;
                        transition: opacity 0.3s;

                        .el-icon {
                            font-size: 24px;
                            margin-bottom: 6px;
                        }
                    }

                    &:hover .avatar-overlay {
                        opacity: 1;
                    }
                }

                .avatar-tip {
                    text-align: center;
                    color: var(--el-text-color-secondary);
                    font-size: 14px;
                    margin: 0;
                }
            }
        }

        // 工具卡片样式
        .tool-card {
            .tool-items {
                padding: 10px;

                .tool-item {
                    display: flex;
                    align-items: center;
                    gap: 15px;
                    padding: 15px;
                    border-radius: 8px;
                    cursor: pointer;
                    transition: all 0.3s;

                    &:hover {
                        background-color: var(--el-color-primary-light-9);

                        .tool-action {
                            transform: translateX(4px);
                        }
                    }

                    .tool-icon {
                        width: 40px;
                        height: 40px;
                        border-radius: 8px;
                        background-color: var(--el-color-primary-light-8);
                        display: flex;
                        justify-content: center;
                        align-items: center;

                        .el-icon {
                            font-size: 20px;
                            color: var(--el-color-primary);
                        }
                    }

                    .tool-info {
                        flex: 1;

                        h3 {
                            margin: 0 0 4px;
                            font-size: 16px;
                            font-weight: 500;
                            color: var(--el-text-color-primary);
                        }

                        p {
                            margin: 0;
                            font-size: 13px;
                            color: var(--el-text-color-secondary);
                        }
                    }

                    .tool-action {
                        color: var(--el-color-primary);
                        transition: transform 0.3s;
                    }
                }
            }
        }
    }

    // 对话框样式
    :deep(.password-dialog) {
        .el-dialog__header {
            margin-right: 0;
            padding-bottom: 0;
        }

        .el-dialog__body {
            padding-top: 10px;
        }
    }

    .password-header {
        display: flex;
        align-items: center;
        gap: 15px;
        margin-bottom: 20px;

        .password-icon {
            font-size: 24px;
            color: white;
            background-color: var(--el-color-primary);
            padding: 12px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(var(--el-color-primary-rgb), 0.3);
        }

        .password-title-info {
            h3 {
                margin: 0 0 5px;
                font-size: 18px;
                font-weight: 600;
                color: var(--el-text-color-primary);
            }

            p {
                margin: 0;
                font-size: 14px;
                color: var(--el-text-color-secondary);
            }
        }
    }

    .password-form {
        padding: 10px 0;

        :deep(.el-form-item__label) {
            font-weight: 500;
        }

        :deep(.el-input__wrapper) {
            border-radius: 8px;
        }

        .password-strength {
            margin-top: 8px;
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;

            .strength-label {
                color: var(--el-text-color-secondary);
                font-size: 13px;
            }

            .strength-meter {
                flex: 1;
                height: 6px;
                background-color: #e9e9e9;
                border-radius: 3px;
                overflow: hidden;

                .strength-bar {
                    height: 100%;
                    transition: width 0.3s ease;

                    &.weak {
                        width: 30%;
                        background-color: var(--el-color-danger);
                    }

                    &.medium {
                        width: 60%;
                        background-color: var(--el-color-warning);
                    }

                    &.strong {
                        width: 100%;
                        background-color: var(--el-color-success);
                    }
                }
            }

            .strength-text {
                font-size: 13px;
                font-weight: 500;

                &.weak {
                    color: var(--el-color-danger);
                }

                &.medium {
                    color: var(--el-color-warning);
                }

                &.strong {
                    color: var(--el-color-success);
                }
            }
        }

        .password-tips {
            margin-top: 20px;
            padding: 12px 15px;
            background-color: var(--el-color-info-light-9);
            border-radius: 8px;

            p {
                margin: 0 0 8px;
                font-weight: 500;
                font-size: 14px;
                color: var(--el-text-color-primary);
                display: flex;
                align-items: center;

                .el-icon {
                    color: var(--el-color-info);
                    margin-right: 5px;
                }
            }

            ul {
                margin: 0;
                padding-left: 20px;

                li {
                    margin-bottom: 4px;
                    font-size: 13px;
                    color: var(--el-text-color-secondary);

                    &:last-child {
                        margin-bottom: 0;
                    }
                }
            }
        }
    }

    .dialog-footer {
        display: flex;
        justify-content: center;
        gap: 16px;
        padding-top: 10px;

        .el-button {
            min-width: 100px;
            border-radius: 8px;
            transition: all 0.25s ease;

            &:hover {
                transform: translateY(-2px);
            }

            &.confirm-btn {
                padding: 12px 25px;
                font-weight: 500;
            }
        }
    }

    // 响应式调整
    @media (max-width: 768px) {
        .my-info-container {
            .page-header {
                padding: 30px 0;

                .header-content {
                    flex-direction: column;
                    align-items: flex-start;

                    .title-section {
                        .main-title {
                            font-size: 24px;
                        }

                        .description {
                            font-size: 14px;
                        }
                    }

                    .user-summary {
                        width: 100%;
                    }
                }
            }

            .main-content {
                width: 100%;
                padding: 0 10px;
            }
        }

        .password-form {
            .password-strength {
                flex-direction: column;
                align-items: flex-start;

                .strength-meter {
                    width: 100%;
                }
            }
        }
    }
}
</style>
