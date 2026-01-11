<script setup>
import { Avatar, User, UserFilled } from '@element-plus/icons-vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 角色管理模块列表
const roleModules = [
    { id: 'user', title: '用户信息', path: '/manager/user', icon: Avatar, color: '#409EFF', desc: '管理平台注册用户的账号信息' },
    { id: 'admin', title: '管理员信息', path: '/manager/admin', icon: UserFilled, color: '#67C23A', desc: '管理平台管理员的账号信息' }
];

// 跳转到对应模块页面
const navigateTo = (path) => {
    router.push(path);
};
</script>

<template>
    <div class="role-page">
        <h2 class="page-title">
            <el-icon class="title-icon">
                <User />
            </el-icon>
            角色管理中心
        </h2>
        <p class="page-description">在这里您可以管理系统中所有用户和管理员的账号信息。选择下方任一模块进入对应管理页面。</p>

        <el-row :gutter="20">
            <el-col v-for="module in roleModules" :key="module.id" :xs="24" :sm="12" :md="8" :lg="8" :xl="6">
                <el-card class="module-card" shadow="hover" @click="navigateTo(module.path)">
                    <div class="card-content">
                        <div class="icon-container" :style="{ backgroundColor: `${module.color}30` }">
                            <el-icon :style="{ color: module.color }">
                                <component :is="module.icon" />
                            </el-icon>
                        </div>
                        <div class="text-container">
                            <h3 class="module-title">{{ module.title }}</h3>
                            <p class="module-desc">{{ module.desc }}</p>
                        </div>
                    </div>
                    <el-button type="primary" text class="enter-button">
                        进入管理
                        <el-icon class="right-icon">
                            <svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
                                <path fill="currentColor"
                                    d="M340.864 149.312a30.592 30.592 0 0 0 0 42.752L652.736 512 340.864 831.872a30.592 30.592 0 0 0 0 42.752 29.12 29.12 0 0 0 41.728 0L714.24 534.336a32 32 0 0 0 0-44.672L382.592 149.376a29.12 29.12 0 0 0-41.728 0z" />
                            </svg>
                        </el-icon>
                    </el-button>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<style scoped lang="scss">
.role-page {
    padding: 20px;

    .page-title {
        display: flex;
        align-items: center;
        font-size: 24px;
        margin-bottom: 16px;
        color: var(--el-color-primary);

        .title-icon {
            margin-right: 12px;
            font-size: 28px;
        }
    }

    .page-description {
        color: var(--el-text-color-secondary);
        margin-bottom: 30px;
        font-size: 16px;
        line-height: 1.6;
    }

    .module-card {
        margin-bottom: 20px;
        cursor: pointer;
        transition: all 0.3s;
        height: 160px;
        display: flex;
        flex-direction: column;
        justify-content: space-between;

        &:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }

        .card-content {
            display: flex;
            align-items: center;
        }

        .icon-container {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;

            .el-icon {
                font-size: 24px;
            }
        }

        .text-container {
            flex: 1;
        }

        .module-title {
            font-size: 18px;
            font-weight: 600;
            margin: 0 0 8px;
            color: var(--el-text-color-primary);
        }

        .module-desc {
            font-size: 14px;
            color: var(--el-text-color-secondary);
            margin: 0;
            line-height: 1.4;
        }

        .enter-button {
            align-self: flex-end;
            margin-top: 12px;
            display: flex;
            align-items: center;

            .right-icon {
                margin-left: 4px;
                font-size: 14px;
            }
        }
    }
}

// 深色主题适配
.theme-dark {
    .role-page {
        .module-card {
            background-color: var(--el-bg-color);

            &:hover {
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.25);
            }
        }
    }
}
</style>