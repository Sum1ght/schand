<script setup>
/**
 * 悬赏发布组件
 * 提供表单界面用于创建（复用修改）悬赏信息
 */
import { ref, reactive, onMounted, nextTick, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Picture, Coin, Delete, Timer, Edit, Location, Phone } from '@element-plus/icons-vue'
import E from "wangeditor"
import { getAllCategoryAPI } from '@/api/categoryAPI'
import { addHelpAPI, getHelpByIdAPI, updateHelpAPI } from '@/api/wantedAPI'
import { uploadFileAPI } from '@/api/fileAPI'

// 使用Pinia存储获取用户信息
import { useUserStore } from '@/stores/userStore'

// 路由相关
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const user = computed(() => userStore.userInfo)

// 响应式数据
const id = ref(route.query.id)
const categoryList = ref([])
const form = reactive({
    title: 'test_wanted_title_01',
    budget: '100',
    category: '',
    categoryId: '',
    img: 'test_wanted_img_01',
    address: '湖南师范大学',
    contact: '15897361469',
    deadline: '',
    content: '111'
})
const editor = ref(null)
const formRef = ref(null)
const isSubmitting = ref(false)
const previewVisible = ref(false)
const loading = ref(false)

// 表单验证规则
const rules = {
    title: [
        { required: true, message: '请输入求购标题', trigger: 'blur' },
        { min: 2, max: 50, message: '标题长度应在2-50个字符之间', trigger: 'blur' }
    ],
    budget: [
        { required: true, message: '请输入预算价格', trigger: 'blur' },
        { pattern: /^\d+(\.\d{1,2})?$/, message: '请输入有效的价格', trigger: 'blur' }
    ],
    category: [
        { required: true, message: '请选择商品分类', trigger: 'blur' }
    ],
    address: [
        { required: true, message: '请输入收货地址', trigger: 'blur' }
    ],
    contact: [
        { required: true, message: '请输入联系方式', trigger: 'blur' },
        { pattern: /^1[3-9]\d{9}$|^(\w-*\.*)+@(\w-?)+(\.\w{2,})+$/, message: '请输入有效的手机号或邮箱', trigger: 'blur' }
    ],
    deadline: [
        { required: true, message: '请选择有效期限', trigger: 'blur' }
    ],
    content: [
        { required: true, message: '请输入详细需求', trigger: 'blur' }
    ]
}

// 禁用日期（今天之前的日期不可选）
const disabledDate = (time) => {
    return time.getTime() < Date.now() - 8.64e7; // 禁用今天之前的日期
}

// 加载分类数据
const loadCategory = async () => {
    try {
        const res = await getAllCategoryAPI()
        categoryList.value = res.data || []
    } catch (error) {
        ElMessage.error('获取分类信息失败')
        console.error(error)
    }
}

// 处理分类选择变化
const handleCategoryChange = () => {
    // 根据选择的分类名称找到对应的分类ID
    const selectedCategory = categoryList.value.find(item => item.name === form.category)
    form.categoryId = selectedCategory ? selectedCategory.id : null
}


const uploadFile = (fromData) => {
    uploadFileAPI(fromData)
}

// 处理图片上传成功
const handleImgSuccess = (response, file, fileList) => {
    form.img = response.data
    ElMessage.success({
        message: '图片上传成功',
        type: 'success',
        duration: 1500
    })
}

// 移除已上传的图片
const removeImage = () => {
    ElMessageBox.confirm('确定要移除当前图片吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(() => {
        form.img = ''
        ElMessage.success('图片已移除')
    }).catch(() => { })
}

// 表单内容校验
const validateForm = async () => {
    if (!formRef.value) return false

    // 获取富文本内容并设置到表单中
    if (editor.value) {
        form.content = editor.value.txt.html()
    }

    // 检查富文本内容是否为空
    if (!form.content || form.content === '<p><br></p>') {
        ElMessage.error('请输入详细需求内容')
        return false
    }

    // 验证其他表单字段
    let valid = false
    await formRef.value.validate((isValid) => {
        valid = isValid
    })

    return valid
}

// 加载悬赏数据（编辑模式）
const loadWanted = async () => {
    if (!id.value) {
        setRichText()
        return
    }
    try {
        console.log('开始加载悬赏数据，ID:', id.value)
        loading.value = true
        const res = await getHelpByIdAPI(id.value)
        console.log('获取悬赏数据返回结果:', res)

        if (res.code === '200' && res.data) {
            // 将API返回的数据映射到表单上
            form.title = res.data.title || ''
            form.content = res.data.content || ''
            form.img = res.data.img || ''
            form.budget = res.data.budget || ''
            form.address = res.data.address || ''
            form.contact = res.data.contact || ''
            form.deadline = res.data.deadline || ''

            // 其他必要字段映射
            if (res.data.categoryId) {
                form.categoryId = res.data.categoryId
                // 根据categoryId查找对应的分类名称
                const category = categoryList.value.find(item => item.id === res.data.categoryId)
                if (category) {
                    form.category = category.name
                }
            }

            console.log('悬赏数据加载成功，表单数据:', { ...form })

            // 设置富文本内容
            nextTick(() => {
                setRichText(res.data.content)
                console.log('富文本编辑器已设置内容')
            })
        } else {
            console.error('获取悬赏数据失败:', res)
            ElMessage.error(res.msg || '获取悬赏信息失败')
        }
    } catch (error) {
        console.error('获取悬赏信息失败:', error)
        ElMessage.error('获取悬赏信息失败')
    } finally {
        loading.value = false
    }
}

// 发布悬赏
const save = async () => {
    if (isSubmitting.value) return

    // 表单验证
    const valid = await validateForm()
    if (!valid) return

    // 手动检查必填字段
    if (!form.category) {
        ElMessage.error('请选择商品分类')
        return
    }

    isSubmitting.value = true

    try {
        // 获取最新的富文本内容
        if (editor.value) {
            form.content = editor.value.txt.html()
        }

        // 准备提交的数据
        const helpData = {
            title: form.title,
            content: form.content,
            img: form.img,
            budget: form.budget,
            address: form.address,
            contact: form.contact,
            deadline: form.deadline,
            userId: user.value.id,
            solved: '未解决', // 默认状态为未解决
            status: '待审核'  // 默认状态为待审核
        }

        // 如果选择了分类，添加分类ID
        if (form.categoryId) {
            helpData.categoryId = form.categoryId
        }

        // 编辑模式需要添加id
        if (id.value) {
            helpData.id = parseInt(id.value)
            console.log('更新悬赏数据:', helpData)
        }

        // 调用API
        const res = await (id.value ? updateHelpAPI(helpData) : addHelpAPI(helpData))
        console.log('API响应结果:', res)

        if (res.code === '200') {
            ElMessage.success(id.value ? '悬赏修改成功' : '悬赏发布成功')

            // 成功后等待一小段时间再跳转，确保后端处理完成
            setTimeout(() => {
                router.push(id.value ? '/personal/mywanted' : '/wanted')
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

// 预览
const preview = () => {
    if (editor.value) {
        form.content = editor.value.txt.html()
    }
    previewVisible.value = true
}

// 返回列表
const goBack = () => {
    ElMessageBox.confirm('确定要离开吗？未保存的内容将丢失', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(() => {
        router.back()
    }).catch(() => { })
}


// 设置富文本编辑器
const setRichText = (html) => {
    nextTick(() => {
        editor.value = new E(`#editor`)
        editor.value.config.uploadImgServer = 'http://localhost:9090/files/editor/upload'
        editor.value.config.uploadFileName = 'file'
        editor.value.config.uploadImgHeaders = {
            token: user.value.token
        }
        editor.value.config.uploadImgParams = {
            type: 'img',
        }
        editor.value.config.zIndex = 0
        editor.value.create()  // 创建
        editor.value.txt.html(html || '')
    })
}

// 重置表单
const resetForm = () => {
    ElMessageBox.confirm('确定要重置所有内容吗？', '提示', {
        confirmButtonText: '确定重置',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(() => {
        if (formRef.value) {
            formRef.value.resetFields()
        }
        // 清除图片
        form.img = ''
        // 清除富文本内容
        if (editor.value) {
            editor.value.txt.html('')
        }
        ElMessage.success({
            message: '表单已重置',
            type: 'success',
            duration: 1500
        })
    }).catch(() => {
        // 用户取消重置
    })
}

// 生命周期钩子
onMounted(async () => {
    console.log('WantedCreate组件挂载，ID:', id.value)
    try {
        // 先加载分类数据
        await loadCategory()
        console.log('分类数据加载完成')

        // 然后加载悬赏数据（如果有ID）
        if (id.value) {
            console.log('开始加载悬赏数据')
            await loadWanted()
        } else {
            // 如果没有ID，初始化富文本编辑器
            console.log('新建悬赏，初始化编辑器')
            setRichText()
        }
    } catch (error) {
        console.error('组件初始化失败:', error)
        ElMessage.error('页面加载失败，请刷新重试')
    }
})
</script>

<template>
    <div class="wanted-create-container">
        <!-- 顶部导航栏 -->
        <div class="page-header">
            <div class="header-back" @click="goBack">
                <el-icon>
                    <ArrowLeft />
                </el-icon>
                <span>返回{{ id ? '我的悬赏' : '悬赏' }}</span>
            </div>
            <div class="header-title">
                <el-icon>
                    <Edit />
                </el-icon>
                <span>{{ id ? '编辑悬赏' : '发布悬赏' }}</span>
            </div>
        </div>

        <!-- 表单卡片 -->
        <div class="form-wrapper" v-loading="loading">
            <el-form :model="form" label-position="top" :rules="rules" ref="formRef" class="wanted-form">
                <!-- 基本信息 -->
                <div class="form-section">
                    <div class="section-header">
                        <div class="section-icon"><el-icon>
                                <Edit />
                            </el-icon></div>
                        <h2 class="section-title">基本信息</h2>
                    </div>

                    <div class="grid-layout">
                        <el-form-item label="标题" prop="title" class="grid-item full-width">
                            <el-input v-model="form.title" placeholder="请输入您要求购的商品标题" maxlength="50"
                                show-word-limit></el-input>
                        </el-form-item>

                        <el-form-item label="预算价格" prop="budget" class="grid-item">
                            <el-input v-model="form.budget" placeholder="您的预算价格" type="number">
                                <template #prefix>
                                    <el-icon>
                                        <Coin />
                                    </el-icon>
                                    <span class="input-prefix">￥</span>
                                </template>
                            </el-input>
                        </el-form-item>

                        <el-form-item label="分类" prop="category" class="grid-item">
                            <el-select v-model="form.category" style="width: 100%" @change="handleCategoryChange"
                                placeholder="请选择商品分类">
                                <el-option v-for="item in categoryList" :key="item.id" :label="item.name"
                                    :value="item.name"></el-option>
                            </el-select>
                        </el-form-item>

                        <el-form-item label="有效期限" prop="deadline" class="grid-item">
                            <el-date-picker v-model="form.deadline" type="date" placeholder="悬赏有效期限"
                                :disabled-date="disabledDate" style="width: 100%" format="YYYY-MM-DD"
                                value-format="YYYY-MM-DD">
                                <template #prefix>
                                    <el-icon>
                                        <Timer />
                                    </el-icon>
                                </template>
                            </el-date-picker>
                        </el-form-item>
                    </div>
                </div>

                <!-- 图片上传 -->
                <div class="form-section">
                    <div class="section-header">
                        <div class="section-icon"><el-icon>
                                <Picture />
                            </el-icon></div>
                        <h2 class="section-title">悬赏配图</h2>
                    </div>

                    <el-form-item label="参考图片（可选）">
                        <div v-if="form.img" class="image-preview">
                            <div class="image-preview-wrapper">
                                <el-image :src="form.img" fit="cover" :preview-src-list="[form.img]"
                                    class="preview-image"></el-image>
                                <div class="image-actions">
                                    <div class="image-delete" @click="removeImage">
                                        <el-icon>
                                            <Delete />
                                        </el-icon>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <el-upload v-else action="http://localhost:9090/files/upload" :headers="{ token: user.token }"
                            list-type="picture" :limit="1" :on-success="handleImgSuccess" class="image-uploader">
                            <div class="upload-area">
                                <el-icon class="upload-icon">
                                    <Picture />
                                </el-icon>
                                <div class="upload-text">点击上传</div>
                                <div class="upload-tip">上传与您需求相关的参考图片</div>
                            </div>
                        </el-upload>
                    </el-form-item>
                </div>

                <!-- 联系信息 -->
                <div class="form-section">
                    <div class="section-header">
                        <div class="section-icon"><el-icon>
                                <Phone />
                            </el-icon></div>
                        <h2 class="section-title">联系信息</h2>
                    </div>

                    <div class="grid-layout">
                        <el-form-item label="收货地址" prop="address" class="grid-item">
                            <el-input v-model="form.address" placeholder="您希望收货的地址">
                                <template #prefix>
                                    <el-icon>
                                        <Location />
                                    </el-icon>
                                </template>
                            </el-input>
                        </el-form-item>

                        <el-form-item label="联系方式" prop="contact" class="grid-item">
                            <el-input v-model="form.contact" placeholder="您的联系方式，如手机号码或邮箱">
                                <template #prefix>
                                    <el-icon>
                                        <Phone />
                                    </el-icon>
                                </template>
                            </el-input>
                        </el-form-item>
                    </div>
                </div>

                <!-- 详细内容 -->
                <div class="form-section">
                    <div class="section-header">
                        <div class="section-icon"><el-icon>
                                <Document />
                            </el-icon></div>
                        <h2 class="section-title">详细需求</h2>
                    </div>

                    <el-form-item prop="content">
                        <div id="editor" class="editor-container"></div>
                        <div class="editor-tip">
                            请详细描述您的需求，包括商品细节、新旧程度要求、特殊要求等信息
                        </div>
                    </el-form-item>
                </div>

                <!-- 表单操作区 -->
                <div class="form-actions">
                    <el-button plain @click="resetForm" class="reset-btn">
                        <el-icon>
                            <RefreshRight />
                        </el-icon> 重置
                    </el-button>
                    <el-button type="primary" plain @click="preview" class="preview-btn">
                        <el-icon>
                            <View />
                        </el-icon> 预览
                    </el-button>
                    <el-button type="primary" @click="save" :loading="isSubmitting" class="submit-btn">
                        <el-icon>
                            <Check />
                        </el-icon> {{ id ? '保存修改' : '发布悬赏' }}
                    </el-button>
                </div>
            </el-form>
        </div>

        <!-- 预览弹窗 -->
        <el-dialog v-model="previewVisible" title="预览悬赏内容" width="650px" class="preview-dialog" top="5vh">
            <div class="preview-container">
                <h1 class="preview-title">{{ form.title }}</h1>

                <div class="preview-meta">
                    <div class="meta-item">
                        <el-icon>
                            <Coin />
                        </el-icon>
                        <span>预算: <strong>¥{{ form.budget }}</strong></span>
                    </div>
                    <div class="meta-item">
                        <el-icon>
                            <Picture />
                        </el-icon>
                        <span>分类: <strong>{{ form.category }}</strong></span>
                    </div>
                    <div class="meta-item" v-if="form.deadline">
                        <el-icon>
                            <Timer />
                        </el-icon>
                        <span>截止日期: <strong>{{ form.deadline }}</strong></span>
                    </div>
                </div>

                <div class="preview-image-container" v-if="form.img">
                    <el-image :src="form.img" fit="contain" class="preview-img"></el-image>
                </div>

                <div class="preview-content-wrapper">
                    <div class="preview-content" v-html="form.content"></div>
                </div>

                <div class="preview-contact">
                    <h3>联系信息</h3>
                    <div class="contact-details">
                        <div class="contact-item">
                            <el-icon>
                                <Phone />
                            </el-icon>
                            <span>联系方式: <strong>{{ form.contact }}</strong></span>
                        </div>
                        <div class="contact-item">
                            <el-icon>
                                <Location />
                            </el-icon>
                            <span>收货地址: <strong>{{ form.address }}</strong></span>
                        </div>
                    </div>
                </div>
            </div>

            <template #footer>
                <div class="dialog-footer">
                    <el-button @click="previewVisible = false">关闭预览</el-button>
                    <el-button type="primary" @click="save">{{ id ? '保存修改' : '发布悬赏' }}</el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
.wanted-create-container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 0 20px 40px;
    color: #2c3e50;

    @media (max-width: 768px) {
        padding: 0 12px 30px;
    }
}

// 页面头部
.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px 0;
    margin-bottom: 24px;
    border-bottom: 1px solid #ebeef5;
    position: sticky;
    top: 0;
    z-index: 10;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(10px);

    .header-back {
        display: flex;
        align-items: center;
        gap: 6px;
        cursor: pointer;
        font-weight: 500;
        color: #606266;
        transition: all 0.3s;

        &:hover {
            color: var(--el-color-primary);
        }

        .el-icon {
            font-size: 16px;
        }
    }

    .header-title {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 20px;
        font-weight: 600;
        color: #303133;

        .el-icon {
            font-size: 22px;
            color: var(--el-color-primary);
        }
    }
}

// 表单容器
.form-wrapper {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
    overflow: hidden;
    transition: transform 0.3s, box-shadow 0.3s;

    &:hover {
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
    }
}

// 表单样式
.wanted-form {
    padding: 20px 30px 30px;

    @media (max-width: 768px) {
        padding: 16px;
    }

    .form-section {
        margin-bottom: 40px;

        &:last-child {
            margin-bottom: 20px;
        }

        .section-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;

            .section-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 40px;
                height: 40px;
                background: var(--el-color-primary-light-9);
                color: var(--el-color-primary);
                border-radius: 8px;
                margin-right: 12px;

                .el-icon {
                    font-size: 20px;
                }
            }

            .section-title {
                font-size: 18px;
                font-weight: 600;
                color: #303133;
                margin: 0;
            }
        }
    }

    // 网格布局
    .grid-layout {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;

        @media (max-width: 768px) {
            grid-template-columns: 1fr;
        }

        .grid-item {
            &.full-width {
                grid-column: 1 / -1;
            }
        }
    }

    // 输入框样式
    :deep(.el-input__wrapper) {
        border-radius: 8px;
        box-shadow: 0 0 0 1px #dcdfe6 inset;
        transition: all 0.3s;

        &:hover {
            box-shadow: 0 0 0 1px #c0c4cc inset;
        }

        &.is-focus {
            box-shadow: 0 0 0 1px var(--el-color-primary) inset;
        }
    }

    // 输入框前缀样式
    .input-prefix {
        margin-left: 4px;
        margin-right: 4px;
        color: #909399;
    }

    // 图片上传样式
    .image-preview {
        .image-preview-wrapper {
            position: relative;
            width: 240px;
            height: 240px;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);

            .preview-image {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.3s;

                &:hover {
                    transform: scale(1.05);
                }
            }

            .image-actions {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.4);
                display: flex;
                align-items: center;
                justify-content: center;
                opacity: 0;
                transition: all 0.3s;

                .image-delete {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    width: 48px;
                    height: 48px;
                    border-radius: 50%;
                    background: rgba(255, 255, 255, 0.9);
                    color: var(--el-color-danger);
                    cursor: pointer;
                    transform: scale(0.8);
                    transition: all 0.3s;

                    .el-icon {
                        font-size: 24px;
                    }

                    &:hover {
                        transform: scale(1);
                        background: #fff;
                    }
                }
            }

            &:hover .image-actions {
                opacity: 1;
            }
        }
    }

    .image-uploader {
        .upload-area {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 240px;
            height: 240px;
            border: 2px dashed #dcdfe6;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s;

            &:hover {
                border-color: var(--el-color-primary);
                background-color: var(--el-color-primary-light-9);
            }

            .upload-icon {
                font-size: 48px;
                color: #909399;
                margin-bottom: 12px;
            }

            .upload-text {
                font-size: 16px;
                font-weight: 500;
                color: #606266;
                margin-bottom: 8px;
            }

            .upload-tip {
                font-size: 13px;
                color: #909399;
                text-align: center;
                padding: 0 16px;
            }
        }
    }

    // 富文本编辑器样式
    .editor-container {
        border: 1px solid #dcdfe6;
        border-radius: 8px;
        overflow: hidden;
        min-height: 300px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
    }

    .editor-tip {
        margin-top: 8px;
        font-size: 13px;
        color: #909399;
        line-height: 1.5;
    }

    // 表单操作区
    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 16px;
        margin-top: 32px;
        padding-top: 24px;
        border-top: 1px solid #f0f0f0;

        .el-button {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 10px 24px;
            font-weight: 500;

            .el-icon {
                font-size: 16px;
            }
        }

        .reset-btn {
            color: #606266;
        }

        .preview-btn {
            color: var(--el-color-primary);
        }

        .submit-btn {
            background: var(--el-color-primary);
            border-color: var(--el-color-primary);
            padding: 10px 30px;
            font-weight: 600;
        }
    }
}

// 预览对话框样式
.preview-dialog {
    :deep(.el-dialog__header) {
        border-bottom: 1px solid #f0f0f0;
        padding: 20px 24px;
        margin-right: 0;

        .el-dialog__title {
            font-size: 18px;
            font-weight: 600;
            color: #303133;
        }
    }

    :deep(.el-dialog__body) {
        padding: 24px;
    }

    :deep(.el-dialog__footer) {
        border-top: 1px solid #f0f0f0;
        padding: 16px 24px;
    }

    .preview-container {
        .preview-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #303133;
            line-height: 1.4;
        }

        .preview-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 24px;

            .meta-item {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 14px;
                color: #606266;
                background-color: #f5f7fa;
                padding: 6px 14px;
                border-radius: 20px;
                box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04);

                .el-icon {
                    color: var(--el-color-primary);
                    font-size: 16px;
                }

                strong {
                    color: #303133;
                    font-weight: 600;
                }
            }
        }

        .preview-image-container {
            margin: 0 -24px 24px;
            background: #f5f7fa;
            padding: 24px;
            text-align: center;

            .preview-img {
                max-width: 100%;
                max-height: 320px;
                border-radius: 8px;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
            }
        }

        .preview-content-wrapper {
            padding: 20px;
            background: #f9f9fa;
            border-radius: 8px;
            margin-bottom: 24px;

            .preview-content {
                line-height: 1.6;
                color: #303133;

                :deep(img) {
                    max-width: 100%;
                    height: auto;
                    border-radius: 4px;
                    margin: 8px 0;
                }

                :deep(p) {
                    margin: 12px 0;
                }
            }
        }

        .preview-contact {
            padding: 20px;
            background-color: #f0f7ff;
            border-radius: 8px;
            border-left: 4px solid var(--el-color-primary);

            h3 {
                font-size: 16px;
                margin-top: 0;
                margin-bottom: 12px;
                color: #303133;
                font-weight: 600;
            }

            .contact-details {
                display: flex;
                flex-direction: column;
                gap: 8px;

                .contact-item {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-size: 14px;
                    color: #606266;

                    .el-icon {
                        color: var(--el-color-primary);
                    }

                    strong {
                        color: #303133;
                        font-weight: 500;
                    }
                }
            }
        }
    }

    .dialog-footer {
        display: flex;
        justify-content: flex-end;
        gap: 16px;
    }
}

/* 针对富文本编辑器的自定义样式 */
:deep(.w-e-toolbar) {
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
    border-bottom: 1px solid #dcdfe6;
    background: #f5f7fa;
}

:deep(.w-e-text-container) {
    border-bottom-left-radius: 8px;
    border-bottom-right-radius: 8px;
    height: 320px !important;
}
</style>
