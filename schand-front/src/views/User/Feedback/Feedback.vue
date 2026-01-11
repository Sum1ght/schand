<script setup>
import { addFeedbackAPI } from '@/api/feedbackAPI'
import { useUserStore } from '@/stores/userStore'
import {
    Check,
    DocumentCopy,
    Edit,
    MagicStick,
    Message,
    MoreFilled,
    Phone,
    Star,
    Warning
} from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

// 路由实例
const router = useRouter()

// 获取用户信息
const userStore = useUserStore()

// 页面状态管理
const state = reactive({
    loading: false,
    submitting: false,
    submitted: false,
    pageReady: false,
    currentStep: 0,
    formValid: false,
    error: null,
    touchedFields: new Set(),
    feedbackTypes: [
        { label: '功能建议', value: 'feature', icon: Star, color: '#27ba9b' },
        { label: '问题反馈', value: 'bug', icon: Warning, color: '#e26237' },
        { label: '体验优化', value: 'ux', icon: MagicStick, color: '#1dc779' },
        { label: '其他意见', value: 'other', icon: MoreFilled, color: '#ffb302' }
    ]
})

// 表单数据
const form = reactive({
    title: '',
    content: '',
    phone: '',
    email: '',
    type: ''
})

// 表单引用
const formRef = ref(null)
const contentRef = ref(null)
const stepOneRef = ref(null)
const stepTwoRef = ref(null)

// 禁用下一步的计算属性
const isNextDisabled = computed(() => {
    if (state.currentStep === 0) {
        return !form.title || form.title.length < 2;
    } else if (state.currentStep === 1) {
        return !form.content || form.content.length < 5;
    }
    return false;
})

// 当前步骤按钮文本计算属性
const buttonText = computed(() => {
    if (state.currentStep === 0) return '继续';
    if (state.currentStep === 1) return '下一步';
    return '提交反馈';
})


// 表单验证规则
const rules = {
    title: [
        { required: true, message: '请输入主题', trigger: 'blur' },
        { min: 2, max: 50, message: '主题长度应在2-50个字符之间', trigger: 'blur' }
    ],
    content: [
        { required: true, message: '请输入内容', trigger: 'blur' },
        { min: 5, max: 1000, message: '内容长度应在5-1000个字符之间', trigger: 'blur' }
    ],
    phone: [
        { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
    ],
    email: [
        { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
    ]
}

// 监听用户输入，设置字段已触碰状态
watch(() => form.title, () => {
    state.touchedFields.add('title');
})

watch(() => form.content, () => {
    state.touchedFields.add('content');
})

// 验证表单字段
const validateForm = async (step) => {
    if (!formRef.value) return false;

    try {
        if (step === 0) {
            await formRef.value.validateField('title');
            return true;
        } else if (step === 1) {
            await formRef.value.validateField('content');
            return true;
        } else if (step === 2) {
            // 如果填写了联系方式，验证格式
            if (form.phone) await formRef.value.validateField('phone');
            if (form.email) await formRef.value.validateField('email');
            return true;
        } else {
            // 验证整个表单
            await formRef.value.validate();
            return true;
        }
    } catch (error) {
        return false;
    }
}

// 进入下一步
const nextStep = async () => {
    if (state.currentStep >= 2 || !await validateForm(state.currentStep)) {
        return;
    }

    state.currentStep++;

    // 表单字段聚焦
    nextTick(() => {
        if (state.currentStep === 1 && contentRef.value) {
            contentRef.value.focus();
        }
    });
}

// 返回上一步
const prevStep = () => {
    if (state.currentStep > 0) {
        state.currentStep--;
    }
}

// 类型切换处理
const handleTypeChange = (type) => {
    form.type = type;
}

// 提交表单
const submitFeedback = async () => {
    // 最终验证
    if (!await validateForm()) {
        ElMessage.warning('请完善必填信息');
        return;
    }

    state.submitting = true;

    try {
        // 准备提交数据
        const feedbackData = {
            title: form.title,
            content: form.content,
            userId: userStore.userInfo.id,
            type: form.type || 'other',
            phone: form.phone || '未提供',
            email: form.email || '未提供'
        }
        const res = await addFeedbackAPI(feedbackData);

        if (res.code === '200') {
            state.submitted = true;
            setTimeout(() => {
                ElMessage({
                    type: 'success',
                    message: '反馈提交成功，感谢您的宝贵意见！',
                    duration: 3000
                });
            }, 500);
        } else {
            throw new Error(res.msg || '提交失败');
        }
    } catch (error) {
        console.error('提交反馈失败:', error);
        state.error = error.message || '网络错误，请稍后再试';
        ElMessage.error(state.error);
    } finally {
        state.submitting = false;
    }
}

// 重置表单
const resetForm = () => {
    formRef.value?.resetFields();
    state.currentStep = 0;
    state.submitted = false;
    state.touchedFields.clear();
}

// 生命周期钩子
onMounted(() => {
    // 模拟页面加载
    state.loading = true;

    setTimeout(() => {
        state.loading = false;

        // 页面内容准备就绪
        setTimeout(() => {
            state.pageReady = true;

            // 自动聚焦标题输入框
            nextTick(() => {
                const titleInput = document.querySelector('.feedback-title-input input');
                if (titleInput) titleInput.focus();
            });
        }, 50);
    }, 300);
})
</script>

<template>
    <div class="feedback-page" :class="{ 'page-ready': state.pageReady }">
        <!-- 加载状态 -->
        <div v-if="state.loading" class="feedback-loading">
            <div class="skeleton-container">
                <div class="skeleton-header">
                    <div class="skeleton-title"></div>
                    <div class="skeleton-subtitle"></div>
                </div>
                <div class="skeleton-form">
                    <div class="skeleton-item" v-for="i in 4" :key="i"></div>
                </div>
            </div>
        </div>

        <!-- 提交成功 -->
        <div v-else-if="state.submitted" class="feedback-success">
            <div class="success-content">
                <div class="success-icon">
                    <el-icon class="success-icon-inner">
                        <Check />
                    </el-icon>
                </div>
                <h2 class="success-title">反馈提交成功</h2>
                <p class="success-message">
                    感谢您的反馈，我们将认真听取您的意见并积极改进！
                    <br>您的支持是我们前进的动力。
                </p>
                <div class="success-actions">
                    <el-button type="primary" @click="resetForm">再次提交</el-button>
                    <el-button @click="router.push('/')">返回首页</el-button>
                </div>
            </div>
        </div>

        <!-- 表单内容 -->
        <div v-else class="feedback-container">
            <div class="feedback-card">
                <!-- 头部信息 -->
                <div class="feedback-header">
                    <div class="header-icon">
                        <el-icon :size="24">
                            <Message />
                        </el-icon>
                    </div>
                    <div class="header-content">
                        <h2 class="main-title">用户反馈</h2>
                        <p class="subtitle">您的意见是我们进步的动力</p>
                    </div>
                </div>

                <!-- 步骤指示器 -->
                <div class="feedback-steps">
                    <div class="step-item" v-for="(step, index) in ['填写主题', '详细描述', '联系方式']" :key="index" :class="{
                        'active': state.currentStep === index,
                        'completed': state.currentStep > index
                    }">
                        <div class="step-number">{{ index + 1 }}</div>
                        <div class="step-label">{{ step }}</div>
                    </div>
                </div>

                <!-- 表单区域 -->
                <el-form :model="form" :rules="rules" ref="formRef" label-position="top" class="feedback-form"
                    @submit.native.prevent>
                    <!-- 步骤一：标题和类型 -->
                    <div class="form-step" v-show="state.currentStep === 0" ref="stepOneRef">
                        <div class="type-selector">
                            <h3 class="section-title">反馈类型</h3>
                            <div class="type-options">
                                <div v-for="type in state.feedbackTypes" :key="type.value" class="type-option"
                                    :class="{ 'active': form.type === type.value }"
                                    @click="handleTypeChange(type.value)">
                                    <div class="type-icon" :style="{ backgroundColor: `${type.color}15` }">
                                        <el-icon :style="{ color: type.color }">
                                            <component :is="type.icon" />
                                        </el-icon>
                                    </div>
                                    <span>{{ type.label }}</span>
                                </div>
                            </div>
                        </div>

                        <el-form-item label="反馈主题" prop="title">
                            <el-input v-model="form.title" class="feedback-title-input" placeholder="简要描述您的问题或建议"
                                :maxlength="50" show-word-limit :prefix-icon="Edit"></el-input>
                        </el-form-item>
                    </div>

                    <!-- 步骤二：详细内容 -->
                    <div class="form-step" v-show="state.currentStep === 1" ref="stepTwoRef">
                        <el-form-item label="详细描述" prop="content">
                            <el-input v-model="form.content" type="textarea" ref="contentRef"
                                placeholder="请详细描述您遇到的问题或建议，以便我们更好地理解和处理您的反馈" :rows="6" :maxlength="1000"
                                show-word-limit></el-input>
                        </el-form-item>
                    </div>

                    <!-- 步骤三：联系方式 -->
                    <div class="form-step" v-show="state.currentStep === 2">
                        <div class="contact-info">
                            <h3 class="section-title">联系方式 <span class="optional-tag">选填</span></h3>
                            <p class="section-desc">留下您的联系方式，方便我们及时回复</p>

                            <el-form-item label="手机号码" prop="phone">
                                <el-input v-model="form.phone" placeholder="请输入您的手机号码" :prefix-icon="Phone"></el-input>
                            </el-form-item>

                            <el-form-item label="电子邮箱" prop="email">
                                <el-input v-model="form.email" placeholder="请输入您的电子邮箱"
                                    :prefix-icon="Message"></el-input>
                            </el-form-item>

                            <div class="contact-notice">
                                <p>
                                    <el-icon>
                                        <DocumentCopy />
                                    </el-icon>
                                    提示：您提供的联系方式仅用于反馈处理，我们将保护您的隐私
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- 表单操作按钮 -->
                    <div class="form-actions">
                        <el-button v-if="state.currentStep > 0" @click="prevStep" plain>上一步</el-button>

                        <el-button v-if="state.currentStep < 2" type="primary" @click="nextStep"
                            :disabled="isNextDisabled">{{ buttonText }}</el-button>

                        <el-button v-else type="primary" @click="submitFeedback" :loading="state.submitting"
                            :disabled="!form.content">提交反馈</el-button>
                    </div>
                </el-form>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// 变量定义
$primary-color: #27ba9b;
$secondary-color: #2656b5;
$error-color: #cf4444;
$warning-color: #ffb302;
$background-color: #f6f8fc;
$border-color: #ebeef5;
$text-primary: #303133;
$text-secondary: #606266;
$text-light: #909399;
$skeleton-color: #f2f2f2;
$skeleton-highlight: #e6e6e6;
$transition-time: 0.3s;
$card-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
$card-shadow-hover: 0 8px 24px rgba(0, 0, 0, 0.12);
$border-radius: 8px;

// 页面容器
.feedback-page {
    width: 800px;
    max-width: 100%;
    margin: 0 auto;
    padding: 20px 16px;
    min-height: calc(100vh - 120px);
    opacity: 0;
    transition: opacity 0.2s ease-in;

    &.page-ready {
        opacity: 1;
    }
}

// 加载状态样式
.feedback-loading {
    height: 100%;
    padding: 20px 0;

    .skeleton-container {
        background-color: white;
        border-radius: $border-radius;
        box-shadow: $card-shadow;
        padding: 30px;

        .skeleton-header {
            margin-bottom: 30px;

            .skeleton-title {
                width: 150px;
                height: 24px;
                background-color: $skeleton-color;
                border-radius: 4px;
                margin-bottom: 10px;
                animation: skeleton-pulse 1.5s ease-in-out infinite;
            }

            .skeleton-subtitle {
                width: 250px;
                height: 16px;
                background-color: $skeleton-color;
                border-radius: 4px;
                animation: skeleton-pulse 1.5s ease-in-out infinite;
            }
        }

        .skeleton-form {
            .skeleton-item {
                height: 70px;
                margin-bottom: 20px;
                animation: skeleton-pulse 1.5s ease-in-out infinite;

                &:nth-child(1) {
                    width: 100%;
                    background-color: $skeleton-color;
                    border-radius: 4px;
                }

                &:nth-child(2) {
                    width: 100%;
                    height: 120px;
                    background-color: $skeleton-color;
                    border-radius: 4px;
                }

                &:nth-child(3),
                &:nth-child(4) {
                    width: 100%;
                    background-color: $skeleton-color;
                    border-radius: 4px;
                }
            }
        }
    }
}

@keyframes skeleton-pulse {
    0% {
        opacity: 0.6;
    }

    50% {
        opacity: 0.8;
    }

    100% {
        opacity: 0.6;
    }
}

// 反馈容器
.feedback-container {
    display: flex;
    justify-content: center;
    padding: 20px 0;
}

// 反馈卡片
.feedback-card {
    width: 100%;
    background-color: white;
    border-radius: $border-radius;
    box-shadow: $card-shadow;
    padding: 30px;
    transition: all $transition-time;

    &:hover {
        box-shadow: $card-shadow-hover;
    }
}

// 头部样式
.feedback-header {
    display: flex;
    align-items: center;
    margin-bottom: 30px;

    .header-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 48px;
        height: 48px;
        border-radius: 12px;
        background: linear-gradient(135deg, lighten($primary-color, 40%), lighten($primary-color, 10%));
        color: white;
        box-shadow: 0 4px 12px rgba(39, 186, 155, 0.2);
        margin-right: 16px;
    }

    .header-content {
        .main-title {
            font-size: 24px;
            font-weight: 600;
            color: $text-primary;
            margin: 0 0 4px;
        }

        .subtitle {
            font-size: 14px;
            color: $text-light;
            margin: 0;
        }
    }
}

// 步骤指示器
.feedback-steps {
    display: flex;
    justify-content: space-between;
    margin-bottom: 30px;
    position: relative;

    &::before {
        content: '';
        position: absolute;
        top: 16px;
        left: 0;
        width: 100%;
        height: 2px;
        background-color: $border-color;
        z-index: 1;
    }

    .step-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        position: relative;
        z-index: 2;

        .step-number {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background-color: white;
            border: 2px solid $border-color;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: $text-light;
            transition: all $transition-time;
            margin-bottom: 8px;
        }

        .step-label {
            font-size: 14px;
            color: $text-light;
            transition: all $transition-time;
        }

        &.active {
            .step-number {
                background-color: $primary-color;
                border-color: $primary-color;
                color: white;
            }

            .step-label {
                color: $primary-color;
                font-weight: 500;
            }
        }

        &.completed {
            .step-number {
                background-color: lighten($primary-color, 40%);
                border-color: $primary-color;
                color: $primary-color;
            }
        }
    }
}

// 表单样式
.feedback-form {
    .form-step {
        animation: fade-in 0.3s ease-in-out;
        min-height: 250px;
    }

    .section-title {
        font-size: 16px;
        font-weight: 500;
        color: $text-primary;
        margin-bottom: 16px;
        display: flex;
        align-items: center;

        .optional-tag {
            font-size: 12px;
            font-weight: normal;
            color: $text-light;
            background-color: #f5f7fa;
            padding: 2px 6px;
            border-radius: 4px;
            margin-left: 8px;
        }
    }

    .section-desc {
        font-size: 14px;
        color: $text-light;
        margin-bottom: 20px;
    }

    :deep(.el-form-item__label) {
        font-weight: 500;
    }

    :deep(.el-input__wrapper) {
        transition: box-shadow $transition-time;
    }

    :deep(.el-textarea__inner) {
        min-height: 120px;
        resize: vertical;
    }

    .type-selector {
        margin-bottom: 20px;

        .type-options {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;

            .type-option {
                flex: 1;
                min-width: 100px;
                padding: 12px;
                border-radius: 6px;
                border: 1px solid $border-color;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                gap: 8px;
                cursor: pointer;
                transition: all $transition-time;

                .type-icon {
                    width: 48px;
                    height: 48px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin-bottom: 4px;
                    transition: all $transition-time;

                    .el-icon {
                        font-size: 24px;
                    }
                }

                span {
                    font-size: 14px;
                    color: $text-secondary;
                }

                &:hover {
                    border-color: lighten($primary-color, 20%);
                    background-color: rgba($primary-color, 0.02);

                    .type-icon {
                        transform: scale(1.05);
                    }
                }

                &.active {
                    border-color: $primary-color;
                    background-color: rgba($primary-color, 0.05);

                    .type-icon {
                        transform: scale(1.1);
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                    }

                    span {
                        color: $primary-color;
                        font-weight: 500;
                    }
                }
            }
        }
    }

    .contact-notice {
        margin-top: 20px;
        background-color: #f8f9fa;
        border-radius: 6px;
        padding: 12px;

        p {
            margin: 0;
            font-size: 13px;
            color: $text-light;
            display: flex;
            align-items: center;
            gap: 6px;

            .el-icon {
                color: $warning-color;
            }
        }
    }

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 30px;

        .el-button {
            min-width: 100px;
        }
    }
}

// 成功提交状态
.feedback-success {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px 0;
    height: 100%;
    animation: fade-in 0.3s ease-in-out;

    .success-content {
        width: 100%;
        max-width: 500px;
        background-color: white;
        border-radius: $border-radius;
        box-shadow: $card-shadow;
        padding: 40px;
        text-align: center;

        .success-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background-color: rgba($primary-color, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;

            .success-icon-inner {
                font-size: 40px;
                color: $primary-color;
            }
        }

        .success-title {
            font-size: 24px;
            font-weight: 600;
            color: $text-primary;
            margin-bottom: 16px;
        }

        .success-message {
            font-size: 16px;
            color: $text-secondary;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .success-actions {
            display: flex;
            justify-content: center;
            gap: 16px;
        }
    }
}

// 动画
@keyframes fade-in {
    from {
        opacity: 0;
        transform: translateY(10px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

// 响应式调整
@media (max-width: 768px) {
    .feedback-card {
        padding: 20px;
    }

    .feedback-header {
        .header-content {
            .main-title {
                font-size: 20px;
            }
        }
    }

    .feedback-steps {
        .step-item {
            .step-label {
                font-size: 12px;
            }
        }
    }

    .feedback-form {
        .type-selector {
            .type-options {
                .type-option {
                    padding: 10px;
                    min-width: 80px;

                    .type-icon {
                        width: 40px;
                        height: 40px;

                        .el-icon {
                            font-size: 20px;
                        }
                    }
                }
            }
        }
    }

    .feedback-success {
        .success-content {
            padding: 30px 20px;
        }
    }
}

@media (max-width: 480px) {
    .feedback-steps {
        .step-item {
            .step-number {
                width: 30px;
                height: 30px;
                font-size: 14px;
            }

            .step-label {
                font-size: 12px;
            }
        }
    }

    .feedback-form {
        .form-actions {
            flex-direction: column;

            .el-button {
                width: 100%;
            }
        }
    }
}
</style>