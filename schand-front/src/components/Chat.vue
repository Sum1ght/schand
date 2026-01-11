<script setup>
/**
 * 聊天组件
 * 基于WebSocket实现实时聊天功能
 * 支持接收、发送消息、未读消息提示
 */
import { ref, reactive, onMounted, onBeforeUnmount, computed, nextTick, watch } from 'vue'
import {
  ChatDotRound,
  ChatLineRound,
  Delete,
  Message,
  Position,
  Loading
} from '@element-plus/icons-vue'
import {
  selectUserChatAPI,
  selectUserGroupAPI,
  addChatInfoAPI,
  updateChatInfoReadAPI,
  deleteChatGroupAPI
} from '@/api/chatAPI'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/userStore'

// 获取用户状态
const userStore = useUserStore()
const userInfo = computed(() => userStore.userInfo)

// WebSocket实例
let socket = null

// 响应式状态
const chatGroupList = ref([])
const activeChatUserId = ref(0)
const messageText = ref('')
const chatList = ref([])
const chatBodyRef = ref(null)
const isLoading = ref(false)
const isSending = ref(false)

// 当前聊天对象信息
const activeChatUserInfo = computed(() => {
  if (!activeChatUserId.value) return null
  return chatGroupList.value.find(item => item.chatUserId === activeChatUserId.value) || null
})

// 生命周期钩子
onMounted(() => {
  initWebSocket()
  loadChatGroup()
})

onBeforeUnmount(() => {
  closeWebSocket()
})

// 消息时间格式化相关函数
const formatMessageTime = (timestamp) => {
  if (!timestamp) return ''
  const date = new Date(timestamp)
  const hours = date.getHours().toString().padStart(2, '0')
  const minutes = date.getMinutes().toString().padStart(2, '0')
  return `${hours}:${minutes}`
}

const formatChatDate = (timestamp) => {
  if (!timestamp) return ''

  const date = new Date(timestamp)
  const today = new Date()
  const yesterday = new Date(today)
  yesterday.setDate(yesterday.getDate() - 1)

  if (date.toDateString() === today.toDateString()) {
    return '今天'
  } else if (date.toDateString() === yesterday.toDateString()) {
    return '昨天'
  } else {
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`
  }
}

// 判断是否需要显示日期分隔线
const shouldShowDate = (item, index) => {
  if (index === 0) return true

  const currentDate = new Date(item.createTime)
  const prevDate = new Date(chatList.value[index - 1].createTime)

  return currentDate.toDateString() !== prevDate.toDateString()
}

// 聊天内容滚动到底部
const scrollToBottom = () => {
  nextTick(() => {
    if (chatBodyRef.value) {
      chatBodyRef.value.scrollTop = chatBodyRef.value.scrollHeight
    }
  })
}

// 监听聊天列表变化，自动滚动到底部
watch(chatList, () => {
  scrollToBottom()
}, { deep: true })

// 初始化WebSocket
const initWebSocket = () => {
  if (typeof WebSocket === 'undefined') {
    ElMessage.warning('您的浏览器不支持WebSocket')
    return
  }

  closeWebSocket()

  const socketUrl = `ws://localhost:9090/chatServer/${userInfo.value.id}`
  socket = new WebSocket(socketUrl)

  socket.onopen = () => {
    console.log('WebSocket连接已建立')
  }

  socket.onmessage = (event) => {
    console.log('收到WebSocket消息:', event.data)
    loadChatGroup()
    if (activeChatUserId.value) {
      loadChatList(activeChatUserId.value)
    }
  }

  socket.onclose = () => {
    console.log('WebSocket连接已关闭')
  }

  socket.onerror = (error) => {
    console.error('WebSocket发生错误:', error)
    ElMessage.error('聊天服务连接失败')
  }
}

// 关闭WebSocket连接
const closeWebSocket = () => {
  if (socket) {
    socket.close()
    socket = null
  }
}

// 发送消息
const handleSend = async () => {
  if (!activeChatUserId.value) {
    ElMessage.warning('请选择聊天对象')
    return
  }

  if (!messageText.value.trim() || isSending.value) {
    return
  }

  try {
    isSending.value = true
    const chatInfo = {
      chatUserId: activeChatUserId.value,
      userId: userInfo.value.id,
      text: messageText.value.trim()
    }

    await addChatInfoAPI(chatInfo)
    messageText.value = ''
    await loadChatList(activeChatUserId.value)

    // 通过WebSocket通知其他用户
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send('聊天消息')
    }
  } catch (error) {
    console.error('发送消息失败:', error)
    ElMessage.error('发送消息失败')
  } finally {
    isSending.value = false
  }
}

// 加载聊天列表
const loadChatList = async (chatUserId) => {
  if (!chatUserId) return

  activeChatUserId.value = chatUserId
  messageText.value = ''

  try {
    isLoading.value = true
    // 更新消息读取状态
    await updateChatInfoReadAPI(chatUserId)
    await loadChatGroup()

    // 获取聊天记录
    const res = await selectUserChatAPI(chatUserId)
    chatList.value = res.data || []
    scrollToBottom()
  } catch (error) {
    console.error('加载聊天列表失败:', error)
    ElMessage.error('加载聊天列表失败')
  } finally {
    isLoading.value = false
  }
}

// 加载聊天组
const loadChatGroup = async () => {
  try {
    const res = await selectUserGroupAPI()
    chatGroupList.value = res.data || []
  } catch (error) {
    console.error('加载聊天组失败:', error)
    ElMessage.error('加载聊天组失败')
  }
}

// 关闭聊天组
const closeGroup = async (id) => {
  try {
    await deleteChatGroupAPI(id)
    await loadChatGroup()

    if (chatGroupList.value.length === 0 || !chatGroupList.value.some(item => item.chatUserId === activeChatUserId.value)) {
      activeChatUserId.value = 0
      chatList.value = []
    }
  } catch (error) {
    console.error('关闭聊天组失败:', error)
    ElMessage.error('关闭聊天组失败')
  }
}
</script>
<template>
  <div class="chat-container">
    <!-- 聊天模块布局 -->
    <div class="chat-layout">
      <!-- 左侧聊天列表 -->
      <div class="chat-sidebar">
        <div class="chat-sidebar-header">
          <h3>聊天列表</h3>
        </div>
        <div class="chat-sidebar-body">
          <div v-if="chatGroupList.length > 0" class="chat-group-list">
            <TransitionGroup name="chat-list">
              <div v-for="item in chatGroupList" :key="item.id" v-show="item.userId === userInfo.id"
                class="chat-group-item" :class="{ 'chat-group-active': item.chatUserId === activeChatUserId }"
                @click="loadChatList(item.chatUserId)">
                <div class="chat-group-avatar">
                  <el-avatar :src="item.chatUserAvatar" :size="40" />
                  <div class="chat-group-status" v-if="item.chatNum > 0 && item.chatUserId !== activeChatUserId"></div>
                </div>
                <div class="chat-group-info">
                  <div class="chat-group-name">
                    <span>{{ item.chatUserName }}</span>
                    <el-badge :value="item.chatNum" :max="99"
                      v-if="item.chatNum > 0 && item.chatUserId !== activeChatUserId" />
                  </div>
                  <div class="chat-group-last-msg" v-if="item.lastMessage">{{ item.lastMessage }}</div>
                </div>
                <div class="chat-group-actions">
                  <el-button type="danger" :icon="Delete" circle plain size="small" @click.stop="closeGroup(item.id)"
                    class="delete-btn"></el-button>
                </div>
              </div>
            </TransitionGroup>
          </div>
          <div v-else class="chat-empty">
            <el-empty description="暂无聊天对象" :image-size="60">
              <template #image>
                <el-icon :size="40">
                  <ChatDotRound />
                </el-icon>
              </template>
              <template #description>
                <div class="empty-description">
                  <p>您目前没有聊天对象</p>
                  <p class="empty-tip">在其他页面找到好友并发送消息，即可开始聊天</p>
                </div>
              </template>
            </el-empty>
          </div>
        </div>
      </div>

      <!-- 右侧聊天内容 -->
      <div class="chat-content">
        <!-- 聊天头部 -->
        <Transition name="fade" mode="out-in">
          <div class="chat-content-header" v-if="activeChatUserInfo" :key="activeChatUserId">
            <h3>{{ activeChatUserInfo.chatUserName }}</h3>
            <span class="chat-status">在线</span>
          </div>
          <div class="chat-content-header" v-else key="empty">
            <h3>请选择聊天对象</h3>
          </div>
        </Transition>

        <!-- 聊天消息区域 -->
        <div class="chat-content-body" ref="chatBodyRef">
          <div v-if="!activeChatUserId" class="chat-welcome">
            <el-empty description="选择联系人开始聊天" :image-size="100">
              <template #image>
                <el-icon :size="60">
                  <Message />
                </el-icon>
              </template>
              <template #description>
                <div class="empty-description">
                  <p>选择联系人开始聊天</p>
                  <p class="empty-tip">从左侧列表选择一位联系人，开始您的对话</p>
                </div>
              </template>
            </el-empty>
          </div>
          <Transition name="fade" mode="out-in">
            <div v-if="isLoading && activeChatUserId" class="chat-loading" key="loading">
              <el-skeleton :rows="5" animated />
            </div>
            <template v-else-if="activeChatUserId" key="messages">
              <div class="chat-messages" v-if="chatList.length > 0">
                <TransitionGroup name="message">
                  <div v-for="(item, index) in chatList" :key="item.id" class="chat-message-item" :class="{
                    'chat-message-received': item.chatUserId === userInfo.id,
                    'chat-message-sent': item.userId === userInfo.id
                  }">
                    <!-- 日期分隔线 -->
                    <div class="chat-date-divider" v-if="shouldShowDate(item, index)">
                      <span>{{ formatChatDate(item.createTime) }}</span>
                    </div>

                    <!-- 接收的消息 -->
                    <div v-if="item.chatUserId === userInfo.id" class="chat-message-received-content">
                      <el-avatar :src="item.userAvatar" :size="36" class="chat-avatar" />
                      <div class="chat-bubble">
                        <div class="chat-bubble-name">{{ item.userName }}</div>
                        <div class="chat-bubble-content">{{ item.text }}</div>
                        <div class="chat-bubble-time">{{ formatMessageTime(item.createTime) }}</div>
                      </div>
                    </div>

                    <!-- 发送的消息 -->
                    <div v-if="item.userId === userInfo.id" class="chat-message-sent-content">
                      <div class="chat-bubble">
                        <div class="chat-bubble-content">{{ item.text }}</div>
                        <div class="chat-bubble-time">{{ formatMessageTime(item.createTime) }}</div>
                      </div>
                      <el-avatar :src="item.userAvatar" :size="36" class="chat-avatar" />
                    </div>
                  </div>
                </TransitionGroup>
              </div>
              <div v-else class="chat-empty">
                <el-empty description="暂无聊天记录" :image-size="60">
                  <template #image>
                    <el-icon :size="40">
                      <ChatLineRound />
                    </el-icon>
                  </template>
                  <template #description>
                    <div class="empty-description">
                      <p>暂无聊天记录</p>
                      <p class="empty-tip">开始发送消息，建立美好的沟通</p>
                    </div>
                  </template>
                </el-empty>
              </div>
            </template>
          </Transition>
        </div>

        <!-- 聊天输入区域 -->
        <Transition name="slide-up">
          <div class="chat-content-footer" v-if="activeChatUserId">
            <div class="chat-input-wrapper">
              <el-input v-model="messageText" type="textarea" :rows="3" placeholder="请输入消息..." resize="none"
                @keyup.enter.exact.prevent="handleSend" />
            </div>
            <div class="chat-input-actions">
              <el-button type="primary" @click="handleSend" :disabled="!messageText.trim() || isSending">
                <span v-if="isSending">
                  <el-icon class="is-loading">
                    <Loading />
                  </el-icon>
                  发送中...
                </span>
                <span v-else>
                  发送 <el-icon class="el-icon--right">
                    <Position />
                  </el-icon>
                </span>
              </el-button>
            </div>
          </div>
          <div class="chat-content-footer chat-content-footer-empty" v-else>
            <el-alert title="请先选择聊天对象" type="info" :closable="false" center show-icon />
          </div>
        </Transition>
      </div>
    </div>
  </div>
</template>


<style lang="scss" scoped>
.chat-container {
  width: 90%;
  max-width: 1200px;
  margin: 20px auto;
}

.chat-layout {
  display: flex;
  height: calc(100vh - 180px);
  min-height: 600px;
  background-color: #fff;
  border-radius: 10px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

/* 侧边栏样式 */
.chat-sidebar {
  width: 280px;
  display: flex;
  flex-direction: column;
  border-right: 1px solid #f0f0f0;
  background-color: #f9f9f9;

  &-header {
    padding: 16px;
    border-bottom: 1px solid #f0f0f0;
    background-color: #fff;

    h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 500;
      color: #333;
    }
  }

  &-body {
    flex: 1;
    overflow-y: auto;

    &::-webkit-scrollbar {
      width: 6px;
    }

    &::-webkit-scrollbar-thumb {
      border-radius: 3px;
      background-color: rgba(0, 0, 0, 0.1);
    }

    &::-webkit-scrollbar-thumb:hover {
      background-color: rgba(0, 0, 0, 0.2);
    }
  }
}

/* 聊天组列表样式 */
.chat-group {
  &-list {
    padding: 10px 0;
  }

  &-item {
    display: flex;
    align-items: center;
    padding: 10px 16px;
    cursor: pointer;
    transition: all 0.3s;
    position: relative;

    &:hover {
      background-color: #f0f0f0;

      .chat-group-actions {
        opacity: 1;
      }
    }
  }

  &-active {
    background-color: #e6f7ff !important;
    border-right: 3px solid var(--el-color-primary);
  }

  &-avatar {
    position: relative;
    margin-right: 12px;
  }

  &-status {
    position: absolute;
    right: 0;
    bottom: 0;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background-color: #f56c6c;
    border: 2px solid #fff;
  }

  &-info {
    flex: 1;
    overflow: hidden;
  }

  &-name {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    font-weight: 500;
    color: #333;
    margin-bottom: 4px;
  }

  &-last-msg {
    font-size: 12px;
    color: #999;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  &-actions {
    opacity: 0;
    transition: opacity 0.3s;

    .delete-btn {
      padding: 4px;
      font-size: 12px;
    }
  }
}

/* 聊天内容区域样式 */
.chat-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: #fff;

  &-header {
    display: flex;
    align-items: center;
    padding: 16px 20px;
    border-bottom: 1px solid #f0f0f0;

    h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 500;
      color: #333;
    }

    .chat-status {
      display: inline-block;
      margin-left: 10px;
      font-size: 12px;
      color: #52c41a;

      &::before {
        content: "•";
        margin-right: 4px;
      }
    }
  }

  &-body {
    flex: 1;
    padding: 20px;
    overflow-y: auto;
    background-color: #f5f7f9;

    &::-webkit-scrollbar {
      width: 6px;
    }

    &::-webkit-scrollbar-thumb {
      border-radius: 3px;
      background-color: rgba(0, 0, 0, 0.1);
    }

    &::-webkit-scrollbar-thumb:hover {
      background-color: rgba(0, 0, 0, 0.2);
    }
  }

  &-footer {
    padding: 16px;
    background-color: #fff;
    border-top: 1px solid #f0f0f0;

    &-empty {
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
}

/* 聊天欢迎页 */
.chat-welcome,
.chat-empty {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #999;

  .empty-description {
    text-align: center;

    p {
      margin: 4px 0;
    }

    .empty-tip {
      font-size: 12px;
      color: #aaa;
    }
  }
}

/* 聊天消息样式 */
.chat-messages {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.chat-message {
  &-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  &-received-content,
  &-sent-content {
    display: flex;
    gap: 12px;
    max-width: 80%;
  }

  &-received-content {
    align-self: flex-start;
  }

  &-sent-content {
    align-self: flex-end;
  }
}

/* 日期分隔线 */
.chat-date-divider {
  display: flex;
  align-items: center;
  margin: 10px 0;

  &::before,
  &::after {
    content: "";
    flex: 1;
    height: 1px;
    background-color: #e8e8e8;
  }

  span {
    padding: 0 16px;
    font-size: 12px;
    color: #999;
  }
}

/* 聊天气泡 */
.chat-bubble {
  padding: 12px 16px;
  border-radius: 10px;
  max-width: 100%;
  position: relative;

  .chat-message-received-content & {
    background-color: #fff;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    border-top-left-radius: 2px;
  }

  .chat-message-sent-content & {
    background-color: var(--el-color-primary-light-9);
    border: 1px solid var(--el-color-primary-light-7);
    border-top-right-radius: 2px;
  }

  &-name {
    font-size: 12px;
    color: #999;
    margin-bottom: 4px;
  }

  &-content {
    font-size: 14px;
    line-height: 1.6;
    word-break: break-word;
    color: #333;
  }

  &-time {
    font-size: 11px;
    color: #999;
    margin-top: 4px;
    text-align: right;
  }
}

/* 聊天输入区域 */
.chat-input {
  &-wrapper {
    margin-bottom: 10px;

    :deep(.el-textarea__inner) {
      resize: none;
      border-color: #e8e8e8;
      transition: all 0.3s;

      &:focus {
        border-color: var(--el-color-primary);
        box-shadow: 0 0 0 2px rgba(24, 144, 255, 0.1);
      }
    }
  }

  &-actions {
    display: flex;
    justify-content: flex-end;

    .el-button {
      padding: 8px 20px;

      .el-icon {
        margin-left: 4px;
      }
    }
  }
}

/* 响应式设计 */
@media screen and (max-width: 768px) {
  .chat-container {
    width: 100%;
    margin: 0;
  }

  .chat-layout {
    height: calc(100vh - 100px);
    border-radius: 0;
  }

  .chat-sidebar {
    width: 220px;
  }
}

/* 修复深度选择器 */
:deep(.el-badge__content.is-fixed) {
  right: 2px;
}

/* 动画效果 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-up-enter-active,
.slide-up-leave-active {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(20px);
  opacity: 0;
}

.chat-list-enter-active,
.chat-list-leave-active {
  transition: all 0.5s ease;
}

.chat-list-enter-from,
.chat-list-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

.message-enter-active,
.message-leave-active {
  transition: all 0.5s ease;
}

.message-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.message-leave-to {
  opacity: 0;
  transform: translateX(100px);
}

.chat-loading {
  padding: 20px;
}

/* 聊天气泡动画 */
.chat-bubble {
  animation: bubble-in 0.3s ease-out;
}

@keyframes bubble-in {
  0% {
    transform: scale(0);
    opacity: 0;
  }

  70% {
    transform: scale(1.05);
  }

  100% {
    transform: scale(1);
    opacity: 1;
  }
}
</style>