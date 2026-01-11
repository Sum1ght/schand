<script setup>
import { useUserStore } from '@/stores/userStore'
import { useRouter, useRoute } from 'vue-router'
import { ref, reactive } from 'vue'
import { User, Lock } from '@element-plus/icons-vue'

// 路由跳转
const router = useRouter()
const route = useRoute()

// 获取用户store
const userStore = useUserStore()

// 表单引用
const formRef = ref(null)

// 登录状态
const loading = ref(false)

// 登录表单数据
const formInfo = ref({
    username: 'chikengogogo',
    password: 'xiaosun123',
    role: 'USER',
    agree: true
})

// 表单验证规则
const rules = {
    username: [
        { required: true, message: '请输入账号', trigger: 'blur' },
        { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
    ],
    role: [
        { required: true, message: '请选择角色', trigger: 'change' },
    ],
    agree: [{
        validator: (rule, val, callback) => {
            return val ? callback() : callback(new Error('请同意用户协议'))
        },
        trigger: 'change'
    }]
}

// 登录方法
const login = () => {
    // 表单验证
    if (!formRef.value) return
    formRef.value.validate(async (valid) => {
        if (valid) {
            loading.value = true
            try {
                // 使用userStore的login方法
                const res = await userStore.login(formInfo.value)

                // 根据角色跳转到不同页面
                if (res.data.role === 'ADMIN') {
                    router.replace('/manager')
                    ElMessage({ type: 'success', message: '管理员登录成功', duration: 3000 })
                } else {
                    router.replace('/square')
                    ElMessage({ type: 'success', message: '用户登录成功', duration: 3000 })
                }
            } catch (error) {
                ElMessage.error('登录失败，请检查账号密码')
                console.error('登录错误:', error)
            } finally {
                loading.value = false
            }
        }
    })
}

// 跳转到注册页
const goToRegister = () => {
    router.push('/register')
}
</script>

<template>
    <div class="login-container">
        <section id="login-form">
            <div class="logo-container">
                <img src="@/assets/icons/shop.svg" alt="" class="logo-image">
                <h1>悠享二手交易网</h1>
                <h3>(๑╹◡╹๑)</h3>

            </div>

            <div class="form-container">
                <el-form :model="formInfo" ref="formRef" :rules="rules" class="login-form" @submit.prevent="login"
                    size="large">
                    <el-form-item prop="username">
                        <el-input v-model="formInfo.username" placeholder="请输入账号" :prefix-icon="User"
                            class="custom-input" />
                    </el-form-item>

                    <el-form-item prop="password">
                        <el-input v-model="formInfo.password" type="password" placeholder="请输入密码" :prefix-icon="Lock"
                            class="custom-input" show-password />
                    </el-form-item>

                    <el-form-item prop="role">
                        <el-select v-model="formInfo.role" placeholder="请选择角色" class="custom-select">
                            <el-option label="管理员" value="ADMIN"></el-option>
                            <el-option label="用户" value="USER"></el-option>
                        </el-select>
                    </el-form-item>

                    <el-form-item prop="agree" class="agreement-item">
                        <el-checkbox v-model="formInfo.agree">
                            我已同意
                            <a href="javascript:void(0)" class="link">隐私条款</a>
                            和
                            <a href="javascript:void(0)" class="link">服务条款</a>
                        </el-checkbox>
                    </el-form-item>

                    <el-form-item>
                        <el-button type="primary" :loading="loading" @click="login" class="login-btn" round>
                            登录
                        </el-button>
                    </el-form-item>
                </el-form>
            </div>

            <p class="reg">
                还没有账号?
                <a href="javascript:void(0)" @click="goToRegister">立即注册</a>
            </p>
        </section>
    </div>
</template>

<style scoped lang="scss">
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

* {
    font-family: 'Poppins', sans-serif, 'PingFang SC', 'Microsoft YaHei';
}

.login-container {
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

.login-container::after {
    content: "";
    position: absolute;
    top: 0;
    bottom: 0;
    right: 0;
    left: 0;
    background-color: rgba(0, 0, 0, 0.4);
    z-index: 0;
}

#login-form {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    background-color: rgba(255, 255, 255, 0.15);
    width: 400px;
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
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 20px;
    width: 100%;
    animation: fadeIn 0.8s ease-out forwards;

    .logo-image {
        width: 70px;
        height: 70px;
        margin-bottom: 15px;
    }
}

h1 {
    font-size: 2.2rem;
    color: white;
    margin: 0;
    letter-spacing: 1px;
    font-weight: 600;
    text-align: center;
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

.login-form {
    width: 100%;

    :deep(.el-form-item) {
        margin-bottom: 25px;

        &:last-child {
            margin-bottom: 0;
        }
    }

    :deep(.el-form-item__error) {
        color: #ff6b6b;
        font-size: 12px;
        padding-left: 12px;
    }

    .custom-input,
    .custom-select {
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

    .custom-select {
        :deep(.el-select__caret) {
            color: white;
        }
    }

    :deep(.el-select-dropdown__item) {
        &.selected {
            color: #4dbdc8;
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
                    background-color: #4dbdc8;
                    border-color: #4dbdc8;
                }
            }
        }
    }

    .link {
        color: #4dbdc8;
        margin: 0 3px;
        text-decoration: none;

        &:hover {
            text-decoration: underline;
        }
    }

    .login-btn {
        width: 100%;
        height: 50px;
        font-size: 1.1rem;
        font-weight: 600;
        letter-spacing: 1px;
        background: linear-gradient(135deg, #4dbdc8, #5471cf);
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

.reg {
    font-size: 1rem;
    color: white;
    margin-top: 15px;
    text-align: center;
    animation: fadeIn 1s ease-out forwards;
    animation-delay: 0.4s;
    opacity: 0;

    a {
        color: #4dbdc8;
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
    #login-form {
        width: 90%;
        padding: 30px 20px;
    }

    h1 {
        font-size: 1.8rem;
    }

    .form-container {
        padding: 25px 15px;
    }
}
</style>