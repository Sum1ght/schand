<script setup>
/**
 * 帖子创建组件
 * 
 * 功能：提供帖子发布功能，包括标题、内容、图片上传和圈子选择
 * 特点：界面简约而不简单，衔接优雅，过渡自然，特效丰满
 * 
 * @author schand-team
 * @date 2023
 */
import { getAllCirclesAPI } from '@/api/circleAPI'
import { addPostsAPI, getPostsByIdAPI, updatePostsAPI } from '@/api/postAPI'
import { uploadFileAPI } from '@/api/fileAPI'
import { useUserStore } from '@/stores/userStore'
import { ArrowLeft, ChatLineRound, Delete, Edit, Plus } from '@element-plus/icons-vue'
import { computed, nextTick, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import E from "wangeditor"

// ================ 基础配置 ================

// 路由实例
const router = useRouter()
const route = useRoute()
// 用户状态管理
const userStore = useUserStore()

// ================ 响应式状态 ================

// 编辑模式判断
const id = ref(route.query.id)
// 加载状态
const isSubmitting = ref(false) // 提交状态
const isLoading = ref(false) // 加载状态

// 数据实例
const circles = ref([]) // 圈子列表
const activeStep = ref(0) // 当前步骤
const previewMode = ref(false) // 预览模式
const previewVisible = ref(false) // 预览弹窗显示状态

// 表单相关
const formRef = ref(null) // 表单引用
const uploadRef = ref(null) // 上传组件引用
const contentRef = ref(null) // 内容输入框引用
const maxFileSize = 2 // 上传图片大小限制(MB)
const editor = ref(null)

// ================ 表单数据 ================

// 表单数据对象
const postForm = reactive({
  title: 'test_post_title_01',
  img: 'https://img.yzcdn.cn/vant/ipad.png',
  circle: '',
  descr: 'test_post_descr_01',
  content: 'test_post_content_01',
  userId: userStore.userInfo?.id || 0
})

// 表单校验规则
const rules = reactive({
  title: [
    { required: true, message: '请输入帖子标题', trigger: 'blur' },
    { min: 2, max: 50, message: '标题长度应在2-50个字符之间', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入帖子内容', trigger: 'blur' },
    { min: 5, message: '内容不能少于5个字符', trigger: 'blur' }
  ],
  circle: [
    { required: true, message: '请选择一个圈子', trigger: 'change' }
  ]
})

// ================ 计算属性 ================

// 计算自动生成的预览内容
const autoDescr = computed(() => {
  if (!postForm.content) return ''

  // 去除HTML标签，保留纯文本
  const plainText = postForm.content.replace(/<[^>]+>/g, '')
  // 截取前100个字符
  return plainText.substring(0, 100) + (plainText.length > 100 ? '...' : '')
})

// 计算内容字数
const contentLength = computed(() => {
  if (!postForm.content) return 0

  // 去除HTML标签，计算纯文本长度
  const plainText = postForm.content.replace(/<[^>]+>/g, '')
  return plainText.length
})

// 计算表单是否填写完整
const formComplete = computed(() => {
  const { title, content, circle } = postForm
  return title.length >= 2 && content.length >= 5 && circle
})

// ================ 生命周期钩子 ================

// 页面初始化
onMounted(async () => {
  try {
    // 检查用户登录状态
    await checkLoginStatus()
    // 加载圈子数据
    await loadCircles()
    // 如果是编辑模式，加载帖子数据
    if (id.value) {
      await loadPostData()
    } else {
      // 非编辑模式，初始化富文本编辑器
      setRichText('')
      // 自动聚焦标题输入框
      nextTick(() => {
        const titleInput = document.querySelector('.post-title-input input')
        if (titleInput) titleInput.focus()
      })
    }
  } catch (error) {
    console.error('页面初始化失败:', error)
  }
})

// ================ 方法定义 ================

/**
 * 检查用户登录状态
 * 如果未登录，则提示用户登录
 */
const checkLoginStatus = () => {
  return new Promise((resolve, reject) => {
    if (!userStore.isLoggedIn()) {
      ElMessageBox.confirm(
        '发布帖子需要先登录，是否前往登录页面？',
        '提示',
        {
          confirmButtonText: '前往登录',
          cancelButtonText: '取消',
          type: 'warning',
          draggable: true,
          closeOnClickModal: false
        }
      ).then(() => {
        router.push('/login?redirect=/post/create')
        reject(new Error('用户未登录'))
      }).catch(() => {
        router.push('/community')
        reject(new Error('用户取消登录'))
      })
    } else {
      resolve()
    }
  })
}

/**
 * 加载圈子数据
 * 获取所有可用的社区圈子
 */
const loadCircles = async () => {
  isLoading.value = true
  try {
    const res = await getAllCirclesAPI()
    if (res.code === '200') {
      circles.value = res.data || []
    } else {
      ElMessage.error(res.msg || '获取圈子列表失败')
    }
  } catch (error) {
    console.error('获取圈子列表失败:', error)
    ElMessage.error('获取圈子列表失败')
  } finally {
    isLoading.value = false
  }
}

/**
 * 加载帖子数据（编辑模式）
 */
const loadPostData = async () => {
  isLoading.value = true
  try {
    console.log('开始加载帖子数据，ID:', id.value)
    const res = await getPostsByIdAPI(id.value)
    console.log('获取帖子数据返回结果:', res)

    if (res.code === '200' && res.data) {
      // 将API返回的数据映射到表单上
      postForm.title = res.data.title || ''
      postForm.content = res.data.content || ''
      postForm.img = res.data.img || ''
      postForm.circle = res.data.circle || ''
      postForm.descr = res.data.descr || ''

      console.log('帖子数据加载成功，表单数据:', { ...postForm })

      // 如果帖子内容加载成功，跳转到内容编辑步骤
      if (postForm.content) {
        activeStep.value = 1
      }

      // 设置富文本内容
      nextTick(() => {
        setRichText(res.data.content)
        console.log('富文本编辑器已设置内容')
      })
    } else {
      console.error('获取帖子数据失败:', res)
      ElMessage.error(res.msg || '获取帖子信息失败')
    }
  } catch (error) {
    console.error('获取帖子信息失败:', error)
    ElMessage.error('获取帖子信息失败')
  } finally {
    isLoading.value = false
  }
}

/**
 * 上传图片前验证
 * @param {File} file - 待上传的文件对象
 * @returns {Boolean} 是否通过验证
 */
const beforeUpload = (file) => {
  // 验证文件类型
  const isImage = file.type.startsWith('image/')
  // 验证文件大小
  const isLt2M = file.size / 1024 / 1024 < maxFileSize

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error(`图片大小不能超过${maxFileSize}MB!`)
    return false
  }
  return true
}

/**
 * 自定义文件上传方法
 * @param {Object} options - 上传选项
 */
const customUpload = async (options) => {
  const { file } = options
  try {
    // 显示上传中状态
    isSubmitting.value = true
    // 调用上传API
    const res = await uploadFileAPI(file)
    console.log('图片上传响应:', res)

    if (res.code === '200') {
      // 上传成功
      postForm.img = res.data
      ElMessage.success({
        message: '图片上传成功',
        type: 'success',
        duration: 1500
      })
    } else {
      // 上传失败
      console.error('图片上传失败，服务器响应:', res)
      ElMessage.error(res.msg || '图片上传失败')
    }
  } catch (error) {
    console.error('图片上传出错:', error)
    ElMessage.error('图片上传失败，请稍后重试')
  } finally {
    isSubmitting.value = false
  }
}

/**
 * 移除已上传的图片
 */
const handleRemoveImage = () => {
  ElMessageBox.confirm(
    '确定要删除已上传的图片吗？',
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(() => {
    postForm.img = ''
    ElMessage.success({
      message: '图片已删除',
      type: 'success',
      duration: 1500
    })
  }).catch(() => {
    // 用户取消删除
  })
}

/**
 * 表单内容校验
 */
const validateForm = async () => {
  if (!formRef.value) return false

  // 检查富文本内容是否为空（现在postForm.content应该已经是最新的值了）
  if (!postForm.content || postForm.content === '<p><br></p>') {
    ElMessage.error('请输入帖子内容')
    return false
  }

  // 验证其他表单字段
  let valid = false
  await formRef.value.validate((isValid) => {
    valid = isValid
  })

  return valid
}

/**
 * 提交表单
 */
const submitForm = async () => {
  if (isSubmitting.value) return

  // 表单验证
  const valid = await validateForm()
  if (!valid) return

  // 手动检查circle字段
  if (!postForm.circle) {
    ElMessage.error('请选择一个圈子')
    return
  }

  isSubmitting.value = true

  try {
    // 准备提交的数据
    const postData = {
      title: postForm.title,
      content: postForm.content,
      img: postForm.img,
      circle: postForm.circle,
      descr: postForm.descr || autoDescr.value,
      userId: userStore.userInfo?.id || 0
    }

    // 编辑模式需要添加id
    if (id.value) {
      postData.id = parseInt(id.value)
      console.log('更新帖子数据:', postData)
    }

    const res = await (id.value ? updatePostsAPI(postData) : addPostsAPI(postData))
    console.log('API响应结果:', res)

    if (res.code === '200') {
      ElMessage.success(id.value ? '帖子修改成功' : '帖子发布成功')

      // 成功后等待一小段时间再跳转，确保后端处理完成
      setTimeout(() => {
        router.push(id.value ? '/personal/mypost' : '/community')
      }, 500)
    } else {
      ElMessage.error(res.msg || '操作失败')
    }
  } catch (error) {
    ElMessage.error('保存失败')
    console.error('保存出错:', error)
  } finally {
    isSubmitting.value = false
  }
}

/**
 * 返回上一页
 */
const goBack = () => {
  if (isSubmitting.value) {
    ElMessage.warning('正在提交中，请稍候...')
    return
  }

  // 检查表单是否有内容
  if (postForm.title || postForm.content || postForm.img) {
    ElMessageBox.confirm(
      '确定要离开吗？未保存的内容将会丢失',
      '提示',
      {
        confirmButtonText: '确定离开',
        cancelButtonText: '继续编辑',
        type: 'warning'
      }
    ).then(() => {
      router.back()
    }).catch(() => {
      // 用户取消离开
    })
  } else {
    router.back()
  }
}

/**
 * 重置表单
 */
const resetForm = () => {
  ElMessageBox.confirm(
    '确定要重置所有内容吗？',
    '提示',
    {
      confirmButtonText: '确定重置',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    if (formRef.value) {
      formRef.value.resetFields()
    }
    // 清除图片
    postForm.img = ''
    ElMessage.success({
      message: '表单已重置',
      type: 'success',
      duration: 1500
    })
  }).catch(() => {
    // 用户取消重置
  })
}

/**
 * 切换预览模式
 */
const togglePreview = () => {
  previewMode.value = !previewMode.value
}

/**
 * 切换到下一步
 */
const nextStep = async () => {
  // 验证当前步骤
  if (activeStep.value === 0) {
    // 验证标题和圈子
    const titleValid = postForm.title.length >= 2 && postForm.title.length <= 50
    const circleValid = !!postForm.circle

    if (!titleValid || !circleValid) {
      await formRef.value.validate((valid) => {
        if (!valid) {
          ElMessage.warning('请完成必填项')
        }
      })
      return
    }
  }

  if (activeStep.value < 1) {
    activeStep.value++

    // 切换到内容编辑步骤时自动聚焦
    if (activeStep.value === 1) {
      nextTick(() => {
        if (contentRef.value) {
          contentRef.value.focus()
        }
      })
    }
  }
}

/**
 * 返回上一步
 */
const prevStep = () => {
  if (activeStep.value > 0) {
    activeStep.value--
  }
}

/**
 * 设置富文本编辑器
 */
const setRichText = (html) => {
  nextTick(() => {
    // 确保在设置之前销毁旧的编辑器实例
    if (editor.value) {
      editor.value.destroy()
      editor.value = null
    }

    // 创建新的编辑器实例
    editor.value = new E(`#editor`)
    editor.value.config.uploadImgServer = 'http://localhost:9090/files/editor/upload'
    editor.value.config.uploadFileName = 'file'
    editor.value.config.uploadImgHeaders = {
      token: userStore.userInfo?.token || ''
    }
    editor.value.config.uploadImgParams = {
      type: 'img',
    }
    editor.value.config.zIndex = 0
    // 创建编辑器
    editor.value.create()

    // 设置内容，优先使用传入的html参数，否则使用表单中的content
    const contentToSet = html || postForm.content || ''
    editor.value.txt.html(contentToSet)

    // 监听内容变化，实时更新到表单对象
    editor.value.config.onchange = () => {
      postForm.content = editor.value.txt.html()
    }
  })
}

/**
 * 预览帖子内容
 */
const preview = () => {
  // 不需要再手动获取内容，因为已经实时同步
  previewVisible.value = true
}
</script>

<template>
  <div class="post-create-container">
    <!-- 顶部导航栏 -->
    <el-card class="detail-card header-card" shadow="hover">
      <div class="detail-nav">
        <el-button @click="goBack" text class="back-btn">
          <el-icon>
            <ArrowLeft />
          </el-icon>
          返回 | {{ id ? '我的帖子' : '社区' }}
        </el-button>
        <div class="page-title">
          <el-icon>
            <Edit />
          </el-icon>
          {{ id ? '编辑帖子' : '发布帖子' }}
        </div>
      </div>
    </el-card>

    <!-- 表单卡片 -->
    <el-card class="detail-card form-card" shadow="hover" v-loading="isLoading">
      <el-form ref="formRef" :model="postForm" :rules="rules" label-position="left" label-width="100px"
        class="post-form">
        <!-- 基本信息 -->
        <div class="form-section">
          <div class="section-title">基本信息</div>

          <el-form-item label="标题" prop="title">
            <el-input v-model="postForm.title" placeholder="请输入一个吸引人的标题" maxlength="50" show-word-limit clearable>
              <template #prefix>
                <el-icon>
                  <ChatLineRound />
                </el-icon>
              </template>
            </el-input>
          </el-form-item>

          <el-form-item label="所属圈子" prop="circle">
            <el-select v-model="postForm.circle" placeholder="请选择圈子" style="width: 100%" :loading="isLoading"
              filterable>
              <el-option v-for="item in circles" :key="item.id" :label="item.name" :value="item.name">
                <div class="circle-option">
                  <el-avatar :size="28" :src="item.img" class="circle-avatar">
                    {{ item.name ? item.name.charAt(0) : '?' }}
                  </el-avatar>
                  <span>{{ item.name }}</span>
                </div>
              </el-option>
            </el-select>
          </el-form-item>

          <el-form-item label="简介(可选)">
            <el-input v-model="postForm.descr" type="textarea" placeholder="请输入帖子简介（不填将自动从内容中提取）" maxlength="200"
              show-word-limit :rows="3" />
            <div class="form-tip">简介将显示在帖子列表中，帮助其他用户了解您的帖子内容</div>
          </el-form-item>
        </div>

        <!-- 配图上传 -->
        <div class="form-section">
          <div class="section-title">帖子配图</div>

          <el-form-item label="图片(可选)">
            <div v-if="postForm.img" class="image-preview">
              <div class="image-preview-wrapper">
                <el-image :src="postForm.img" fit="cover" :preview-src-list="[postForm.img]"
                  class="preview-image"></el-image>
                <div class="image-actions">
                  <el-button type="danger" circle size="small" @click="handleRemoveImage" class="delete-btn">
                    <el-icon>
                      <Delete />
                    </el-icon>
                  </el-button>
                </div>
              </div>
            </div>

            <div v-else class="image-uploader">
              <el-upload ref="uploadRef" :http-request="customUpload" :show-file-list="false"
                :before-upload="beforeUpload" class="uploader">
                <div class="upload-trigger">
                  <el-icon class="upload-icon">
                    <Plus />
                  </el-icon>
                  <span class="upload-text">点击上传</span>
                </div>
              </el-upload>
              <div class="el-upload__tip">
                支持JPG、PNG格式，大小不超过{{ maxFileSize }}MB
              </div>
            </div>
          </el-form-item>
        </div>

        <!-- 帖子内容 -->
        <div class="form-section">
          <div class="section-title">帖子详情</div>

          <el-form-item label="内容" prop="content">
            <div id="editor" class="editor-container"></div>
            <div class="editor-tip">
              在此描述您想分享的内容，可以添加图片和格式化文本
            </div>
            <!-- 添加隐藏输入框用于表单验证 -->
            <input type="hidden" v-model="postForm.content">
          </el-form-item>

          <!-- 操作按钮 -->
          <div class="form-actions">
            <el-button type="primary" plain @click="resetForm">重置</el-button>
            <el-button type="primary" @click="preview">预览</el-button>
            <el-button type="warning" @click="submitForm" :loading="isSubmitting">
              {{ id ? '保存修改' : '发布帖子' }}
            </el-button>
          </div>
        </div>
      </el-form>
    </el-card>

    <!-- 预览弹窗 -->
    <el-dialog v-model="previewVisible" title="预览帖子内容" width="600px" class="preview-dialog">
      <div class="preview-container">
        <h1 class="preview-title">{{ postForm.title }}</h1>

        <div class="preview-meta">
          <div class="meta-item">
            <el-icon>
              <ChatLineRound />
            </el-icon>
            圈子: {{ postForm.circle }}
          </div>
        </div>

        <div class="preview-image-container" v-if="postForm.img">
          <el-image :src="postForm.img" fit="contain" class="preview-img"></el-image>
        </div>

        <div class="preview-content" v-html="postForm.content"></div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="previewVisible = false">关闭预览</el-button>
          <el-button type="warning" @click="submitForm">{{ id ? '保存修改' : '发布帖子' }}</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="scss" scoped>
.post-create-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 20px;

  @media (max-width: 768px) {
    padding: 16px 12px;
  }
}

.detail-card {
  border-radius: 8px;
  margin-bottom: 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05) !important;
  background-color: #fff;
  transition: transform 0.3s, box-shadow 0.3s;

  &:hover {
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1) !important;
  }
}

.header-card {
  background-color: #f7f9fc;
}

.detail-nav {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .back-btn {
    display: flex;
    align-items: center;
    gap: 4px;
    color: #606266;
    font-weight: 500;

    &:hover {
      color: var(--el-color-primary);
    }
  }

  .page-title {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 20px;
    font-weight: 600;
    color: #303133;
  }
}

.form-card {
  padding: 10px;
}

.post-form {
  .form-section {
    margin-bottom: 32px;

    .section-title {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 1px solid #f0f0f0;
    }

    &:last-child {
      margin-bottom: 0;
    }
  }

  .image-preview {
    width: 100%;

    .image-preview-wrapper {
      position: relative;
      width: 200px;
      height: 200px;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

      .preview-image {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      .image-actions {
        position: absolute;
        top: 8px;
        right: 8px;

        .delete-btn {
          background-color: rgba(0, 0, 0, 0.5);
          border: none;

          &:hover {
            background-color: var(--el-color-danger);
          }
        }
      }
    }
  }

  .image-uploader {
    .upload-trigger {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      width: 200px;
      height: 200px;
      border: 1px dashed #dcdfe6;
      border-radius: 8px;
      cursor: pointer;
      transition: all 0.3s;

      &:hover {
        border-color: var(--el-color-primary);
        background-color: #f5f7fa;
      }

      .upload-icon {
        font-size: 48px;
        color: #909399;
        margin-bottom: 8px;
      }

      .upload-text {
        font-size: 14px;
        color: #909399;
      }
    }
  }

  .form-tip {
    font-size: 12px;
    color: #909399;
    margin-top: 4px;
  }

  .content-counter {
    text-align: right;
    font-size: 12px;
    color: #909399;
    margin-top: 4px;

    .text-warning {
      color: var(--el-color-danger);
    }
  }

  .form-actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 20px;
  }

  .editor-container {
    min-height: 300px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    margin-bottom: 10px;
  }

  .editor-tip {
    margin-bottom: 20px;
    font-size: 12px;
    color: #909399;
  }
}

// 圈子选项样式
.circle-option {
  display: flex;
  align-items: center;
  gap: 12px;
  height: 40px;

  .circle-avatar {
    background-color: var(--el-color-primary);
    color: #fff;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  }
}

/* 针对富文本编辑器的自定义样式 */
:deep(.w-e-toolbar) {
  border-top-left-radius: 4px;
  border-top-right-radius: 4px;
  border-bottom: 1px solid #dcdfe6;
}

:deep(.w-e-text-container) {
  border-bottom-left-radius: 4px;
  border-bottom-right-radius: 4px;
  height: 300px !important;
}

.preview-dialog {
  .preview-container {
    .preview-title {
      font-size: 22px;
      font-weight: 600;
      margin-bottom: 16px;
      color: #303133;
    }

    .preview-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      margin-bottom: 20px;

      .meta-item {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 14px;
        color: #606266;
        background-color: rgba(235, 237, 240, 0.5);
        padding: 4px 12px;
        border-radius: 16px;
      }
    }

    .preview-image-container {
      margin-bottom: 20px;
      text-align: center;

      .preview-img {
        max-width: 100%;
        max-height: 300px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      }
    }

    .preview-content {
      margin-bottom: 20px;
      line-height: 1.6;
      color: #303133;

      ::v-deep(img) {
        max-width: 100%;
        height: auto;
        border-radius: 4px;
        margin: 8px 0;
      }

      ::v-deep(p) {
        margin: 12px 0;
      }
    }
  }
}
</style>