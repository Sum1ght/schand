<script setup>
/**
 * 商品发布组件
 * 提供表单界面用于创建（复用修改）商品信息
 */
import { ref, reactive, onMounted, nextTick, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowLeft, Picture, Coin, Delete, Location, Edit } from '@element-plus/icons-vue'
import E from "wangeditor"
import { getGoodsByIdAPI, addGoodsAPI, updateGoodsAPI } from '@/api/goodsAPI'
import { getAllCategoryAPI } from '@/api/categoryAPI'

// 使用Pinia存储获取用户信息
import { useUserStore } from '@/stores/userStore'

// 路由相关
const route = useRoute()
const router = useRouter()

// 响应式数据
const id = ref(route.query.id)
const userStore = useUserStore()
const user = computed(() => userStore.userInfo)
const categoryList = ref([])
const editor = ref(null)
const formRef = ref(null)
const isSubmitting = ref(false)
const previewVisible = ref(false)
const loading = ref(false)

// 表单数据
const form = reactive({
    name: 'test_goods_01',
    price: '100',
    category: '',
    img: '',
    address: 'test_address_01',
    saleStatus: '上架',
    content: '1111'
})

// 表单验证规则
const rules = {
    name: [
        { required: true, message: '请输入商品名称', trigger: 'blur' },
        { min: 2, max: 50, message: '标题长度应在2-50个字符之间', trigger: 'blur' }
    ],
    price: [
        { required: true, message: '请输入商品价格', trigger: 'blur' },
        { pattern: /^\d+(\.\d{1,2})?$/, message: '请输入有效的价格', trigger: 'blur' }
    ],
    category: [
        { required: true, message: '请选择商品分类', trigger: 'blur' }
    ],
    address: [
        { required: true, message: '请输入发货地址', trigger: 'blur' }
    ],
    content: [
        { required: true, message: '请输入商品详情', trigger: 'blur' }
    ]
}

// 加载商品数据（编辑模式）
const loadGoods = async () => {
    if (!id.value) {
        setRichText()
        return
    }
    try {
        loading.value = true
        const res = await getGoodsByIdAPI(id.value)
        if (res.code === '200' && res.data) {
            // 将API返回的数据映射到表单上
            form.name = res.data.name || ''
            form.price = res.data.price || ''
            form.category = res.data.category || ''
            form.img = res.data.img || ''
            form.address = res.data.address || ''
            // 直接使用API返回的上架状态（"上架"或"下架"）
            form.saleStatus = res.data.saleStatus

            // 设置富文本内容
            setRichText(res.data.content)
        } else {
            ElMessage.error(res.msg || '获取商品信息失败')
        }
    } catch (error) {
        console.error('获取商品信息失败:', error)
        ElMessage.error('获取商品信息失败')
    } finally {
        loading.value = false
    }
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

// 处理图片上传成功
const handleImgSuccess = (response, file, fileList) => {
    if (response.code === '200' && response.data) {
        form.img = response.data;
        console.log('图片上传成功，链接:', form.img);
        ElMessage.success({
            message: '图片上传成功',
            type: 'success',
            duration: 1500
        });
    } else {
        console.error('图片上传失败:', response);
        ElMessage.error('图片上传失败');
    }
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

    // 检查富文本内容是否为空（现在form.content应该已经是最新的值了）
    if (!form.content || form.content === '<p><br></p>') {
        ElMessage.error('请输入商品详情内容')
        return false
    }

    // 验证其他表单字段
    let valid = false
    await formRef.value.validate((isValid) => {
        valid = isValid
    })

    return valid
}

// 提交表单
const save = async () => {
    if (isSubmitting.value) return

    // 表单验证
    const valid = await validateForm()
    if (!valid) return

    isSubmitting.value = true

    try {
        // 准备提交的数据
        const goodsData = {
            name: form.name,
            content: form.content,
            price: form.price,
            category: form.category,
            img: form.img,
            address: form.address,
            saleStatus: form.saleStatus,
            userId: user.value.id,
        }

        // 编辑模式需要添加id
        if (id.value) {
            goodsData.id = id.value
        }

        const res = await (id.value ? updateGoodsAPI(goodsData) : addGoodsAPI(goodsData))

        if (res.code === '200') {
            ElMessage.success(id.value ? '商品修改成功' : '商品发布成功')
            router.push(id.value ? '/personal/mygoods' : '/square')
        } else {
            ElMessage.error(res.msg || '操作失败')
        }
    } catch (error) {
        ElMessage.error('保存失败')
        console.error(error)
    } finally {
        isSubmitting.value = false
    }
}

// 预览
const preview = () => {
    // 不需要再手动获取内容，因为已经实时同步
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

        // 设置初始内容
        editor.value.txt.html(html || form.content || '')

        // 监听内容变化，实时更新到表单对象
        editor.value.config.onchange = () => {
            form.content = editor.value.txt.html()
        }
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
onMounted(() => {
    loadCategory()
    loadGoods()
})
</script>

<template>
    <div class="goods-create-container">
        <!-- 顶部导航栏 -->
        <el-card class="detail-card header-card" shadow="hover">
            <div class="detail-nav">
                <el-button @click="goBack" text class="back-btn">
                    <el-icon>
                        <ArrowLeft />
                    </el-icon>
                    返回 | {{ id ? '我的商品' : '广场' }}
                </el-button>
                <div class="page-title">
                    <el-icon>
                        <Edit />
                    </el-icon>
                    {{ id ? '编辑商品' : '发布商品' }}
                </div>
            </div>
        </el-card>

        <!-- 表单卡片 -->
        <el-card class="detail-card form-card" shadow="hover">
            <el-form :model="form" label-position="left" label-width="100px" :rules="rules" ref="formRef"
                class="goods-form">
                <!-- 基本信息 -->
                <div class="form-section">
                    <div class="section-title">基本信息</div>

                    <el-form-item label="商品名称" prop="name">
                        <el-input v-model="form.name" placeholder="请输入商品名称" maxlength="50" show-word-limit></el-input>
                    </el-form-item>

                    <el-form-item label="商品价格" prop="price">
                        <el-input v-model="form.price" placeholder="请输入商品价格" type="number">
                            <template #prefix>
                                <el-icon>
                                    <Coin />
                                </el-icon>
                                <span style="margin-left: 5px;">￥</span>
                            </template>
                        </el-input>
                    </el-form-item>

                    <el-form-item label="商品分类" prop="category">
                        <el-select v-model="form.category" style="width: 100%" placeholder="请选择商品分类">
                            <el-option v-for="item in categoryList" :key="item.id" :label="item.name"
                                :value="item.name"></el-option>
                        </el-select>
                    </el-form-item>
                </div>

                <!-- 商品图片 -->
                <div class="form-section">
                    <div class="section-title">商品配图</div>

                    <el-form-item label="图片（可选）">
                        <div v-if="form.img" class="image-preview">
                            <div class="image-preview-wrapper">
                                <el-image :src="form.img" fit="cover" :preview-src-list="[form.img]"
                                    class="preview-image"></el-image>
                                <div class="image-actions">
                                    <el-button type="danger" circle size="small" @click="removeImage"
                                        class="delete-btn">
                                        <el-icon>
                                            <Delete />
                                        </el-icon>
                                    </el-button>
                                </div>
                            </div>
                        </div>

                        <el-upload v-else action="http://localhost:9090/files/upload" :headers="{ token: user.token }"
                            list-type="picture" :limit="1" :on-success="handleImgSuccess" class="image-uploader">
                            <div class="upload-trigger">
                                <el-icon class="upload-icon">
                                    <Picture />
                                </el-icon>
                                <span class="upload-text">点击上传</span>
                            </div>
                            <template #tip>
                                <div class="el-upload__tip">
                                    上传商品展示图片，一张好的图片能提高商品关注度
                                </div>
                            </template>
                        </el-upload>
                    </el-form-item>
                </div>

                <!-- 发货信息 -->
                <div class="form-section">
                    <div class="section-title">发货信息</div>

                    <el-form-item label="发货地址" prop="address">
                        <el-input v-model="form.address" placeholder="请输入发货地址">
                            <template #prefix>
                                <el-icon>
                                    <Location />
                                </el-icon>
                            </template>
                        </el-input>
                    </el-form-item>

                    <el-form-item label="上架状态" prop="saleStatus">
                        <el-radio-group v-model="form.saleStatus">
                            <el-radio :label="'上架'">上架</el-radio>
                            <el-radio :label="'下架'">下架</el-radio>
                        </el-radio-group>
                    </el-form-item>
                </div>

                <!-- 商品详情 -->
                <div class="form-section">
                    <div class="section-title">商品详情</div>

                    <el-form-item prop="content">
                        <div id="editor" class="editor-container"></div>
                        <div class="editor-tip">
                            请详细描述您的商品，包括商品特点、材质、尺寸、新旧程度等信息
                        </div>
                        <!-- 添加隐藏输入框用于表单验证 -->
                        <input type="hidden" v-model="form.content">
                    </el-form-item>

                    <!-- 操作按钮 -->
                    <div class="form-actions">
                        <el-button type="primary" plain @click="resetForm">重置</el-button>
                        <el-button type="primary" @click="preview">预览</el-button>
                        <el-button type="warning" @click="save" :loading="isSubmitting">
                            {{ id ? '保存修改' : '发布商品' }}
                        </el-button>
                    </div>
                </div>
            </el-form>
        </el-card>

        <!-- 预览弹窗 -->
        <el-dialog v-model="previewVisible" title="预览商品内容" width="600px" class="preview-dialog">
            <div class="preview-container">
                <h1 class="preview-title">{{ form.name }}</h1>

                <div class="preview-meta">
                    <div class="meta-item">
                        <el-icon>
                            <Coin />
                        </el-icon>
                        价格: ¥{{ form.price }}
                    </div>
                    <div class="meta-item">
                        <el-icon>
                            <Picture />
                        </el-icon>
                        分类: {{ form.category }}
                    </div>
                    <div class="meta-item">
                        <el-icon>
                            <Location />
                        </el-icon>
                        发货地: {{ form.address }}
                    </div>
                    <div class="meta-item">
                        <el-icon>
                            <Picture />
                        </el-icon>
                        状态: {{ form.saleStatus }}
                    </div>
                </div>

                <div class="preview-image-container" v-if="form.img">
                    <el-image :src="form.img" fit="contain" class="preview-img"></el-image>
                </div>

                <div class="preview-content" v-html="form.content"></div>
            </div>

            <template #footer>
                <div class="dialog-footer">
                    <el-button @click="previewVisible = false">关闭预览</el-button>
                    <el-button type="warning" @click="save">{{ id ? '保存修改' : '发布商品' }}</el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<style lang="scss" scoped>
.goods-create-container {
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

.goods-form {
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

    .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 20px;
    }
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
</style>