<script setup>
import {
    Aim,
    Bell,
    ChatLineSquare,
    Coin,
    Connection,
    Goods,
    Location,
    Menu,
    Message,
    Postcard
} from '@element-plus/icons-vue';
import { useRouter } from 'vue-router';

const router = useRouter();

// 业务管理模块列表
const businessModules = [
    { id: 'category', title: '分类信息', path: '/manager/category', icon: Coin, color: '#409EFF', desc: '管理系统中的所有商品分类信息' },
    { id: 'goods', title: '商品信息', path: '/manager/goods', icon: Goods, color: '#67C23A', desc: '管理用户发布的二手商品信息' },
    { id: 'circles', title: '圈子信息', path: '/manager/circles', icon: Connection, color: '#E6A23C', desc: '管理社区圈子相关内容' },
    { id: 'posts', title: '帖子信息', path: '/manager/posts', icon: Postcard, color: '#F56C6C', desc: '管理用户在社区发布的帖子' },
    { id: 'wanted', title: '悬赏信息', path: '/manager/wanted', icon: Aim, color: '#909399', desc: '管理用户发布的悬赏信息' },
    { id: 'address', title: '地址信息', path: '/manager/address', icon: Location, color: '#9254DE', desc: '管理用户的收货地址信息' },
    { id: 'comment', title: '评论信息', path: '/manager/comment', icon: ChatLineSquare, color: '#36CFC9', desc: '管理商品和帖子的评论' },
    { id: 'notice', title: '公告信息', path: '/manager/notice', icon: Bell, color: '#FF9C6E', desc: '管理系统公告信息' },
    { id: 'feedback', title: '反馈信息', path: '/manager/feedback', icon: Message, color: '#FF7875', desc: '管理用户提交的反馈信息' }
];

// 跳转到对应模块页面
const navigateTo = (path) => {
    router.push(path);
};
</script>

<template>
    <div class="business-page">
        <h2 class="page-title">
            <el-icon class="title-icon">
                <Menu />
            </el-icon>
            业务管理中心
        </h2>
        <p class="page-description">在这里您可以管理系统中所有与业务相关的数据和信息。选择下方任一模块进入对应管理页面。</p>

        <el-row :gutter="20">
            <el-col v-for="module in businessModules" :key="module.id" :xs="24" :sm="12" :md="8" :lg="8" :xl="6">
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
.business-page {
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
    .business-page {
        .module-card {
            background-color: var(--el-bg-color);

            &:hover {
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.25);
            }
        }
    }
}
</style>