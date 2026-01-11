<script setup>
import { ref } from 'vue';
// 导入图片
import banner1 from '@/assets/images/banner/t01.png';
import banner2 from '@/assets/images/banner/t02.png';
import banner3 from '@/assets/images/banner/t03.png';

// 轮播图数据
const bannerList = ref([
    {
        id: 1,
        imgUrl: banner1,
        title: '悠享二手交易网',
        desc: '让闲置物品流动起来，创造绿色经济价值'
    },
    {
        id: 2,
        imgUrl: banner2,
        title: '安全交易保障',
        desc: '放心买卖，无忧无疑无惑'
    },
    {
        id: 3,
        imgUrl: banner3,
        title: '严选优质商品',
        desc: '最好玩、最好看、最好用、最好食'
    }
])
</script>

<template>
    <div class="banner-container">
        <el-carousel height="300px" :interval="5000" motion-blur>
            <el-carousel-item v-for="item in bannerList" :key="item.id">
                <div class="carousel-content">
                    <img :src="item.imgUrl" :alt="item.title" class="carousel-image" />
                    <div class="carousel-info">
                        <h2 class="carousel-title">{{ item.title }}</h2>
                        <p class="carousel-desc">{{ item.desc }}</p>
                    </div>
                </div>
            </el-carousel-item>
        </el-carousel>
    </div>
</template>

<style lang="scss" scoped>
.banner-container {
    width: 100%;
    margin-bottom: 20px;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);

    :deep(.el-carousel) {
        border-radius: 12px;
        overflow: hidden;
    }

    :deep(.el-carousel__container) {
        border-radius: 12px;
    }

    :deep(.el-carousel__item) {
        border-radius: 12px;
    }

    :deep(.el-carousel__arrow) {
        background-color: rgba(255, 255, 255, 0.7);
        color: #333;
        border-radius: 50%;
        width: 40px;
        height: 40px;

        &:hover {
            background-color: rgba(255, 255, 255, 0.9);
        }
    }

    :deep(.el-carousel__indicators) {
        bottom: 16px;

        .el-carousel__button {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: rgba(255, 255, 255, 0.5);
        }
    }


}

.carousel-content {
    position: relative;
    width: 100%;
    height: 100%;
}

.carousel-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.carousel-info {
    position: absolute;
    bottom: 40px;
    left: 40px;
    color: white;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
    z-index: 2;
}

.carousel-title {
    font-size: 30px;
    font-weight: 700;
    margin-bottom: 8px;
}

.carousel-desc {
    font-size: 15px;
    max-width: 100%;
}

@media (max-width: 768px) {
    .banner-container {
        :deep(.el-carousel) {
            height: 180px !important;
        }
    }

    .carousel-info {
        bottom: 20px;
        left: 20px;
    }

    .carousel-title {
        font-size: 24px;
    }

    .carousel-desc {
        font-size: 14px;
    }
}
</style>