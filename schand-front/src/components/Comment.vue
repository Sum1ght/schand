<script setup>
/**
 * 评论组件
 * 支持评论、回复、删除功能
 * 可自定义主题和自定义标题
 * 用法：<Comment :fid="123" module="goods" theme="light" placeholder="说说你的看法..." />
 */
import { ref, onMounted, computed } from 'vue';
import { CaretTop, CaretBottom, ChatLineRound, Delete } from '@element-plus/icons-vue';
import { addCommentAPI, deleteCommentAPI, getCommentTreeAPI, getCommentCountAPI, selectAllCommentAPI } from '@/api/commentAPI';
import { useUserStore } from '@/stores/userStore';

// 获取用户状态
const userStore = useUserStore();
const user = computed(() => userStore.userInfo);

// 接收属性
const props = defineProps({
  fid: {
    type: [Number, String],
    required: true
  },
  module: {
    type: String,
    required: true
  },
  theme: {
    type: String,
    default: 'light', // light, dark
    validator: (value) => ['light', 'dark'].includes(value)
  },
  placeholder: {
    type: String,
    default: ''
  },
  defaultCollapsed: {
    type: Boolean,
    default: false
  }
});

// 响应式状态
const commentCount = ref(0);
const content = ref('');
const commentList = ref([]);
const pageNum = ref(1);
const pageSize = ref(10);
const total = ref(0);
const isCollapsed = ref(props.defaultCollapsed);
const isLoading = ref(false);

// 生命周期钩子
onMounted(() => {
  loadComment();
});

// 切换折叠状态
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value;
};

// 显示回复输入框
const handleShowReply = (comment) => {
  // 如果点击的评论已经显示回复框，则隐藏
  if (comment.showReply) {
    comment.showReply = false;
    return;
  }

  // 确保所有其他评论的回复框都被隐藏
  commentList.value.forEach(item => {
    item.showReply = false;
    if (item.children) {
      item.children.forEach(child => {
        child.showReply = false;
      });
    }
  });

  // 显示当前评论的回复框
  comment.showReply = true;
  if (!comment.replyContent) {
    comment.replyContent = '';
  }
};

// 删除评论
const delComment = (commentId) => {
  ElMessageBox.confirm('您确定要删除这条评论吗？删除后将无法恢复。', '确认删除', {
    type: 'warning',
    confirmButtonText: '确定删除',
    cancelButtonText: '取消',
    closeOnClickModal: false
  }).then(() => {
    isLoading.value = true;
    deleteCommentAPI(commentId).then(res => {
      if (res.code === '200') {
        ElMessage.success('评论已删除');
        loadComment();
      } else {
        ElMessage.error(res.msg || '删除失败');
      }
    }).finally(() => {
      isLoading.value = false;
    });
  }).catch(() => {
    // 取消删除操作
  });
};

// 加载评论列表
const loadComment = () => {
  isLoading.value = true;

  // 获取评论树
  getCommentTreeAPI(props.fid, props.module, pageNum.value, pageSize.value).then(res => {
    commentList.value = res.data?.list || [];
    total.value = res.data?.total || 0;
  }).finally(() => {
    isLoading.value = false;
  });

  // 获取评论总数
  getCommentCountAPI(props.fid, props.module).then(res => {
    commentCount.value = res.data || 0;
  });
};

// 添加评论或回复
const addComment = (comment) => {
  if (!user.value.id) {
    ElMessage.warning('请先登录后再评论');
    return;
  }

  let data = {
    fid: props.fid,
    userId: user.value.id,
    module: props.module,
    content: content.value
  };

  // 如果是回复评论
  if (comment) {
    data.content = comment.replyContent;
    data.pid = comment.id;
  }

  // 检查内容是否为空
  if (!data.content || !data.content.trim()) {
    ElMessage.warning('请输入内容!');
    return;
  }

  // 提交评论
  isLoading.value = true;
  addCommentAPI(data).then(res => {
    if (res.code === '200') {
      ElMessage.success('评论发布成功');
      content.value = '';
      // 清空回复内容并隐藏回复框
      if (comment) {
        comment.replyContent = '';
        comment.showReply = false;
      }
      loadComment();
    } else {
      ElMessage.error(res.msg || '评论发布失败');
    }
  }).finally(() => {
    isLoading.value = false;
  });
};

// 页码变化处理
const handleCurrentChange = (newPageNum) => {
  pageNum.value = newPageNum;
  loadComment();
};
</script>
<template>
  <div class="comment-container" :class="{ 'theme-light': theme === 'light', 'theme-dark': theme === 'dark' }">
    <div class="section-header">
      <div class="section-title">
        <slot name="title">当前评论数: {{ commentCount }} ヾ(*´∀ ˋ*)ﾉ 快来发表你的高见吧！</slot>
      </div>
      <div class="collapse-control" @click="toggleCollapse" :title="isCollapsed ? '展开评论区' : '收起评论区'">
        <el-icon>
          <component :is="isCollapsed ? CaretBottom : CaretTop" />
        </el-icon>
      </div>
    </div>

    <transition name="collapse">
      <div v-show="!isCollapsed" class="comment-content">
        <div class="comment-form">
          <el-input type="textarea" :placeholder="placeholder || '请输入评论'" v-model="content" :rows="3" resize="none"
            maxlength="500" show-word-limit></el-input>
          <div class="btn-container">
            <el-button type="primary" @click="addComment(null)" :disabled="!content.trim()">
              发布评论
            </el-button>
          </div>
        </div>

        <div class="comment-list">
          <template v-if="commentList.length">
            <div v-for="item in commentList" :key="item.id" class="comment-item">
              <!-- 一级评论-->
              <div class="comment-main">
                <el-avatar :src="item.avatar" class="user-avatar"></el-avatar>
                <div class="comment-body">
                  <div class="user-name">{{ item.userName }}</div>
                  <div class="comment-text">{{ item.content }}</div>
                  <div class="comment-actions">
                    <span class="time">{{ item.time }}</span>
                    <span @click="handleShowReply(item)" class="action-btn reply-btn"
                      :class="{ 'comment-active': item.showReply }">
                      <el-icon>
                        <ChatLineRound />
                      </el-icon>回复
                    </span>
                    <span v-if="item.userId === user.id" @click="delComment(item.id)" class="action-btn delete-btn">
                      <el-icon>
                        <Delete />
                      </el-icon>删除
                    </span>
                  </div>
                  <transition name="fade">
                    <div v-if="item.showReply" class="reply-form">
                      <el-input type="textarea" :placeholder="`回复 ${item.userName}:`" v-model="item.replyContent"
                        :rows="2" resize="none" maxlength="300" show-word-limit></el-input>
                      <div class="btn-container">
                        <el-button @click="item.showReply = false" plain size="small">取消</el-button>
                        <el-button type="primary" @click="addComment(item)" size="small"
                          :disabled="!item.replyContent?.trim()">
                          回复
                        </el-button>
                      </div>
                    </div>
                  </transition>
                </div>
              </div>

              <!-- 二级评论-->
              <transition name="fade">
                <div v-if="item.children && item.children.length" class="sub-comments">
                  <div v-for="sub in item.children" :key="sub.id" class="comment-main">
                    <el-avatar :src="sub.avatar" class="user-avatar"></el-avatar>
                    <div class="comment-body">
                      <div class="user-name">
                        {{ sub.userName }}
                        <span v-if="sub.parentUserName !== item.userName" class="reply-to">
                          回复 @{{ sub.parentUserName }}
                        </span>
                      </div>
                      <div class="comment-text">{{ sub.content }}</div>
                      <div class="comment-actions">
                        <span class="time">{{ sub.time }}</span>
                        <span @click="handleShowReply(sub)" class="action-btn reply-btn"
                          :class="{ 'comment-active': sub.showReply }">
                          <el-icon>
                            <ChatLineRound />
                          </el-icon>回复
                        </span>
                        <span v-if="sub.userId === user.id" @click="delComment(sub.id)" class="action-btn delete-btn">
                          <el-icon>
                            <Delete />
                          </el-icon>删除
                        </span>
                      </div>
                      <transition name="fade">
                        <div v-if="sub.showReply" class="reply-form">
                          <el-input type="textarea" :placeholder="`回复 ${sub.userName}:`" v-model="sub.replyContent"
                            :rows="2" resize="none" maxlength="300" show-word-limit></el-input>
                          <div class="btn-container">
                            <el-button @click="sub.showReply = false" plain size="small">取消</el-button>
                            <el-button type="primary" @click="addComment(sub)" size="small"
                              :disabled="!sub.replyContent?.trim()">
                              回复
                            </el-button>
                          </div>
                        </div>
                      </transition>
                    </div>
                  </div>
                </div>
              </transition>
            </div>
          </template>

          <!-- 无评论状态 -->
          <div v-if="!commentList.length && !isLoading" class="empty-comments">
            <el-empty description="暂无评论，来发表第一条评论吧"></el-empty>
          </div>

          <!-- 加载中状态 -->
          <div v-if="isLoading" class="loading-comments">
            <el-skeleton animated :rows="3" />
          </div>

          <!-- 分页 -->
          <div class="pagination-wrapper" v-if="total > pageSize">
            <el-pagination background @current-change="handleCurrentChange" :current-page="pageNum"
              :page-size="pageSize" layout="prev, pager, next" :total="total"
              :hide-on-single-page="true"></el-pagination>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style lang="scss" scoped>
.comment-container {
  padding: 0;

  &.theme-light {
    --comment-bg: #fff;
    --comment-border: #f0f0f0;
    --comment-text: #303133;
    --comment-secondary: #606266;
    --comment-placeholder: #aaa;
    --comment-active: #409eff;
    --comment-hover-bg: #f5f7fa;
  }

  &.theme-dark {
    --comment-bg: #252525;
    --comment-border: #3a3a3a;
    --comment-text: #e0e0e0;
    --comment-secondary: #aaa;
    --comment-placeholder: #777;
    --comment-active: #79bbff;
    --comment-hover-bg: #333;
  }
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 1px solid var(--comment-border, #f0f0f0);
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--comment-text, #303133);
}

.collapse-control {
  cursor: pointer;
  border-radius: 8px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 28px;
  width: 28px;
  background-color: var(--comment-hover-bg, #f5f7fa);

  &:hover {
    background-color: rgba(var(--el-color-primary-rgb), 0.1);
    color: var(--comment-active, #409eff);
    transform: scale(1.05);
  }
}

.comment-content {
  position: relative;
}

.comment-form {
  margin-bottom: 25px;

  .el-textarea {
    margin-bottom: 10px;

    :deep(.el-textarea__inner) {
      background-color: var(--comment-bg, #fff);
      border-color: var(--comment-border, #f0f0f0);
      color: var(--comment-text, #303133);
      border-radius: 8px;
      padding: 12px;
      min-height: 80px;
      transition: all 0.3s ease;

      &:focus {
        border-color: var(--el-color-primary);
        box-shadow: 0 0 0 2px rgba(var(--el-color-primary-rgb), 0.2);
      }

      &::placeholder {
        color: var(--comment-placeholder, #aaa);
      }
    }

    :deep(.el-input__count) {
      background: transparent;
      color: var(--comment-secondary, #606266);
      font-size: 12px;
      bottom: 5px;
      right: 10px;
    }
  }
}

.btn-container {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.comment-list {
  padding-top: 5px;
}

.comment-item {
  position: relative;
  margin-bottom: 20px;
  transition: all 0.3s ease;

  &:last-child {
    margin-bottom: 0;
  }

  &:not(:last-child) {
    padding-bottom: 20px;
    border-bottom: 1px dashed var(--comment-border, #f0f0f0);
  }
}

.comment-main {
  display: flex;
  margin-bottom: 15px;

  &:last-child {
    margin-bottom: 0;
  }
}

.user-avatar {
  flex-shrink: 0;
  width: 40px !important;
  height: 40px !important;
  border-radius: 50%;
  margin-right: 12px;
  border: 2px solid transparent;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;

  &:hover {
    transform: scale(1.05);
    border-color: var(--el-color-primary);
  }
}

.comment-body {
  flex: 1;
  overflow: hidden;
}

.user-name {
  font-weight: 500;
  color: var(--comment-text, #303133);
  margin-bottom: 6px;
  font-size: 15px;

  .reply-to {
    color: var(--el-color-primary);
    font-size: 13px;
    margin-left: 4px;
    font-weight: normal;
  }
}

.comment-text {
  margin-bottom: 8px;
  color: var(--comment-text, #303133);
  word-break: break-word;
  line-height: 1.6;
  font-size: 14px;
}

.comment-actions {
  display: flex;
  align-items: center;
  color: var(--comment-secondary, #606266);
  font-size: 13px;

  .time {
    margin-right: 15px;
    opacity: 0.8;
  }

  .action-btn {
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 4px;
    transition: all 0.3s ease;

    &:hover {
      background-color: var(--comment-hover-bg, #f5f7fa);
    }

    .el-icon {
      font-size: 14px;
    }
  }

  .reply-btn {
    margin-right: 15px;
  }

  .delete-btn {
    color: #f56c6c;

    &:hover {
      background-color: rgba(245, 108, 108, 0.1);
    }
  }
}

.comment-active {
  color: var(--comment-active, #409eff) !important;
}

.reply-form {
  margin-top: 15px;

  .el-textarea {
    margin-bottom: 10px;

    :deep(.el-textarea__inner) {
      background-color: var(--comment-bg, #fff);
      border-color: var(--comment-border, #f0f0f0);
      color: var(--comment-text, #303133);
      border-radius: 8px;
      padding: 8px 12px;
      font-size: 13px;
      min-height: 60px;

      &:focus {
        border-color: var(--el-color-primary);
      }

      &::placeholder {
        color: var(--comment-placeholder, #aaa);
      }
    }
  }

  .btn-container {
    justify-content: flex-end;
  }
}

.sub-comments {
  margin-left: 52px;
  padding-top: 5px;
  position: relative;

  &::before {
    content: '';
    position: absolute;
    left: -26px;
    top: 0;
    height: 100%;
    width: 2px;
    background-color: var(--comment-border, #f0f0f0);
    opacity: 0.5;
  }
}

.pagination-wrapper {
  margin-top: 24px;
  display: flex;
  justify-content: center;
}

.empty-comments {
  padding: 30px 0;
  text-align: center;
  color: var(--comment-secondary, #606266);
}

.loading-comments {
  padding: 20px 0;
}

/* 折叠动画相关样式 */
.collapse-enter-active,
.collapse-leave-active {
  transition: all 0.4s ease;
  max-height: 3000px;
  opacity: 1;
  overflow: hidden;
}

.collapse-enter-from,
.collapse-leave-to {
  max-height: 0;
  opacity: 0;
  overflow: hidden;
  margin: 0;
}

/* 淡入淡出动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .section-title {
    font-size: 16px;
  }

  .comment-text {
    font-size: 14px;
  }

  .sub-comments {
    margin-left: 30px;
  }

  .user-avatar {
    width: 32px !important;
    height: 32px !important;
    margin-right: 10px;
  }
}
</style>