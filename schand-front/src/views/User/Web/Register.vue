<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { registerAPI } from '@/api/webAPI'

import { User, Lock, Message, Phone } from '@element-plus/icons-vue'

const router = useRouter()

// 注册表单数据
const registerForm = reactive({
    username: 'test_user_01',
    password: 'xiaosun123',
    confirmPassword: 'xiaosun123',
    email: '1522457459@qq.com',
    phone: '15897361469',
    agreement: true
})

// 表单验证规则
const rules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 8, max: 20, message: '长度在 8 到 20 个字符', trigger: 'blur' },
        { pattern: /^(?=.*[a-z])(?=.*\d).{8,20}$/, message: '密码需包含字母和数字', trigger: 'blur' }
    ],
    confirmPassword: [
        { required: true, message: '请再次输入密码', trigger: 'blur' },
        {
            validator: (rule, value, callback) => {
                if (value !== registerForm.password) {
                    callback(new Error('两次输入密码不一致'))
                } else {
                    callback()
                }
            },
            trigger: 'blur'
        }
    ],
    email: [
        { required: true, message: '请输入邮箱地址', trigger: 'blur' },
        { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }
    ],
    phone: [
        { required: true, message: '请输入手机号码', trigger: 'blur' },
        { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
    ],
    agreement: [
        {
            validator: (rule, value, callback) => {
                if (!value) {
                    callback(new Error('请阅读并同意用户协议'))
                } else {
                    callback()
                }
            },
            trigger: 'change'
        }
    ]
}

// 表单引用
const registerFormRef = ref(null)

// 注册状态
const loading = ref(false)

// 处理注册
const handleRegister = async () => {
    if (!registerFormRef.value) return

    await registerFormRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true
            try {
                // 调用注册API
                const res = await registerAPI({
                    username: registerForm.username,
                    password: registerForm.password,
                    email: registerForm.email,
                    phone: registerForm.phone,
                    role: 'USER'
                })

                if (res.code === '200') {
                    ElMessage({
                        type: 'success',
                        message: '注册成功，即将跳转到登录页',
                        duration: 2000
                    })
                    // 注册成功，跳转到登录页
                    setTimeout(() => {
                        router.push('/login')
                    }, 2000)
                } else {
                    ElMessage.error(res.msg || '注册失败，请稍后重试')
                }
            } catch (error) {
                ElMessage.error('注册失败，请检查网络连接')
                console.error('注册错误:', error)
            } finally {
                loading.value = false
            }
        }
    })
}

// 跳转到登录页
const goToLogin = () => {
    router.push('/login')
}
</script>

<template>
    <div class="register-container">
        <section id="register-form">
            <div class="logo-container">
                <h1>创建账号</h1>
                <p class="subtitle">欢迎加入我们！(〃∀〃)</p>
            </div>

            <div class="form-container">
                <el-form ref="registerFormRef" :model="registerForm" :rules="rules" class="register-form"
                    @submit.prevent="handleRegister" size="large">
                    <el-form-item prop="username">
                        <el-input v-model="registerForm.username" placeholder="请输入用户名" :prefix-icon="User"
                            class="custom-input" />
                    </el-form-item>

                    <el-form-item prop="password">
                        <el-input v-model="registerForm.password" type="password" placeholder="请输入密码"
                            :prefix-icon="Lock" class="custom-input" show-password />
                    </el-form-item>

                    <el-form-item prop="confirmPassword">
                        <el-input v-model="registerForm.confirmPassword" type="password" placeholder="请再次输入密码"
                            :prefix-icon="Lock" class="custom-input" show-password />
                    </el-form-item>

                    <el-form-item prop="email">
                        <el-input v-model="registerForm.email" placeholder="请输入邮箱地址" :prefix-icon="Message"
                            class="custom-input" />
                    </el-form-item>

                    <el-form-item prop="phone">
                        <el-input v-model="registerForm.phone" placeholder="请输入手机号码" :prefix-icon="Phone"
                            class="custom-input" />
                    </el-form-item>

                    <el-form-item prop="agreement" class="agreement-item">
                        <el-checkbox v-model="registerForm.agreement">
                            我已阅读并同意
                            <a href="javascript:void(0)" class="link">用户协议</a>
                            和
                            <a href="javascript:void(0)" class="link">隐私政策</a>
                        </el-checkbox>
                    </el-form-item>

                    <el-form-item>
                        <el-button type="primary" :loading="loading" @click="handleRegister" class="register-btn" round>
                            立即注册
                        </el-button>
                    </el-form-item>
                </el-form>
            </div>

            <p class="login-link">
                已有账号? <a href="javascript:void(0)" @click="goToLogin">立即登录</a>
            </p>
        </section>
    </div>
</template>

<style scoped lang="scss">
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

* {
    font-family: 'Poppins', sans-serif, 'PingFang SC', 'Microsoft YaHei';
}

.register-container {
    background-image: url('@/assets/images/background/t01.png');
    background-repeat: no-repeat;
    background-position: center;
    background-size: cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
}

.register-container::after {
    content: "";
    position: absolute;
    top: 0;
    bottom: 0;
    right: 0;
    left: 0;
    background-color: rgba(0, 0, 0, 0.4);
    z-index: 0;
}

#register-form {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    background-color: rgba(255, 255, 255, 0.15);
    width: 450px;
    padding: 40px 30px;
    border-radius: 20px;
    border: 1px solid rgba(255, 255, 255, 0.3);
    backdrop-filter: blur(10px);
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
    position: relative;
    z-index: 1;
    overflow: hidden;
}

.logo-container {
    text-align: center;
    margin-bottom: 20px;
    width: 100%;
    animation: fadeIn 0.8s ease-out forwards;
}

h1 {
    font-size: 2.2rem;
    color: white;
    margin: 0 0 10px;
    letter-spacing: 1px;
    font-weight: 600;
    text-align: center;
}

.subtitle {
    color: rgba(255, 255, 255, 0.8);
    font-size: 1rem;
    margin: 0;
}

.form-container {
    background-color: rgba(255, 255, 255, 0.1);
    border-radius: 15px;
    padding: 30px 20px;
    width: 100%;
    box-sizing: border-box;
    border: 1px solid rgba(255, 255, 255, 0.2);
    margin-bottom: 20px;
    animation: fadeIn 1s ease-out forwards;
    animation-delay: 0.2s;
    opacity: 0;
}

.register-form {
    width: 100%;

    :deep(.el-form-item) {
        margin-bottom: 20px;

        &:last-child {
            margin-bottom: 0;
        }
    }

    :deep(.el-form-item__error) {
        color: #ff6b6b;
        font-size: 12px;
        padding-left: 12px;
    }

    .custom-input {
        width: 100%;

        :deep(.el-input__wrapper) {
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 50px;
            box-shadow: none;
            border: 1px solid rgba(255, 255, 255, 0.6);
            transition: all 0.3s;

            &:hover,
            &.is-focus {
                border-color: white;
                box-shadow: 0 0 10px rgba(255, 255, 255, 0.3);
            }
        }

        :deep(.el-input__inner) {
            color: white;
            height: 45px;

            &::placeholder {
                color: rgba(255, 255, 255, 0.7);
            }
        }

        :deep(.el-input__prefix) {
            color: white;
            margin-right: 5px;
            font-size: 1.1rem;
        }

        :deep(.el-input__suffix) {
            color: white;
        }
    }

    .agreement-item {
        margin-top: 5px;
        margin-bottom: 25px;

        :deep(.el-checkbox) {
            height: auto;

            .el-checkbox__label {
                color: white;
                font-size: 0.9rem;
                line-height: 1.5;
            }

            .el-checkbox__input {
                .el-checkbox__inner {
                    background-color: transparent;
                    border-color: rgba(255, 255, 255, 0.8);
                }

                &.is-checked .el-checkbox__inner {
                    background-color: #4d8bc8;
                    border-color: #4d8bc8;
                }
            }
        }
    }

    .link {
        color: #4d8bc8;
        margin: 0 3px;
        text-decoration: none;

        &:hover {
            text-decoration: underline;
        }
    }

    .register-btn {
        width: 100%;
        height: 50px;
        font-size: 1.1rem;
        font-weight: 600;
        letter-spacing: 1px;
        background: linear-gradient(135deg, #4d8bc8, #5463cf);
        border: none;
        transition: all 0.3s;

        &:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.2);
        }

        &:active {
            transform: translateY(-1px);
            box-shadow: 0 5px 10px rgba(0, 0, 0, 0.2);
        }
    }
}

.login-link {
    font-size: 1rem;
    color: white;
    margin-top: 15px;
    text-align: center;
    animation: fadeIn 1s ease-out forwards;
    animation-delay: 0.4s;
    opacity: 0;

    a {
        color: #4d8bc8;
        font-weight: 500;
        margin-left: 5px;

        &:hover {
            text-decoration: underline;
        }
    }
}

// 动画
@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

// 媒体查询
@media (max-width: 480px) {
    #register-form {
        width: 90%;
        padding: 30px 20px;
    }

    h1 {
        font-size: 1.8rem;
        margin-bottom: 5px;
    }

    .form-container {
        padding: 25px 15px;
    }
}
</style>