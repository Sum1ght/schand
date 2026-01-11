<script setup>
/**
 * 社区页面头部组件
 * 显示社区标题、搜索栏和创建帖子按钮
 */
import { ref } from 'vue'
import { ChatDotRound, Edit, Search } from '@element-plus/icons-vue'

// 事件定义
const emit = defineEmits(['create-post', 'search'])

// 搜索关键词
const searchKeyword = ref('')

// 处理创建帖子
const handleCreatePost = () => {
  emit('create-post')
}

// 处理搜索
const handleSearch = () => {
  emit('search', searchKeyword.value)
}

// 按回车键搜索
const handleKeyDown = (e) => {
  if (e.key === 'Enter') {
    handleSearch()
  }
}
</script>

<template>
  <div class="community-header">
    <div class="header-left">
      <div class="title-icon">
        <el-icon :size="24">
          <ChatDotRound />
        </el-icon>
      </div>
      <div class="title-content">
        <h1 class="main-title">社区</h1>
        <p class="subtitle">分享经验和交流二手交易心得</p>
      </div>
    </div>

    <div class="search-box">
      <el-input v-model="searchKeyword" placeholder="搜索帖子" clearable @keydown="handleKeyDown">
        <template #prefix>
          <el-icon class="search-icon">
            <Search />
          </el-icon>
        </template>
        <template #append>
          <el-button @click="handleSearch">搜索</el-button>
        </template>
      </el-input>
    </div>

    <div class="header-right">
      <el-button type="primary" @click="handleCreatePost" class="create-button">
        <el-icon>
          <Edit />
        </el-icon>
        发布帖子
      </el-button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.community-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  gap: 20px;

  @media (max-width: 768px) {
    flex-direction: column;
    align-items: stretch;
  }

  .header-left {
    display: flex;
    align-items: center;

    .title-icon {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 48px;
      height: 48px;
      border-radius: 12px;
      background: linear-gradient(135deg, #f0f9ff, #409eff);
      color: white;
      box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
      margin-right: 16px;
    }

    .title-content {
      .main-title {
        font-size: 24px;
        font-weight: 600;
        margin: 0 0 4px;
        color: #303133;
      }

      .subtitle {
        font-size: 14px;
        color: #909399;
        margin: 0;
      }
    }
  }

  .search-box {
    flex: 1;
    max-width: 400px;

    @media (max-width: 768px) {
      max-width: 100%;
      order: 2;
    }

    .search-icon {
      color: var(--el-text-color-secondary);
    }
  }

  .header-right {
    @media (max-width: 768px) {
      align-self: flex-end;
    }

    .create-button {
      display: flex;
      align-items: center;
      gap: 6px;
      font-weight: 500;
    }
  }
}
</style>