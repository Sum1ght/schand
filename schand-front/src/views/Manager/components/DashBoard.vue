<script setup>
import {
    getAllGoodsAPI
} from '@/api/goodsAPI'
import {
    getAllOrdersAPI,
    getOrderBarAPI,
    getOrderLineAPI
} from '@/api/orderAPI'
import {
    getAllUsersAPI
} from '@/api/userAPI'
import {
    getAllHelpAPI
} from '@/api/wantedAPI'
import { useUserStore } from '@/stores/userStore'
import {
    Aim,
    Goods,
    Tickets,
    User
} from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { computed, onMounted, reactive, ref, nextTick } from 'vue'

// 获取用户store
const userStore = useUserStore()
const user = computed(() => userStore.userInfo)

// 数据加载状态
const loading = reactive({
    cards: false,
    goodsChart: false,
    userChart: false,
    orderChart: false,
    categoryChart: false
})

// 统计卡片数据
const statsCards = ref([
    { id: 1, title: '商品总数', value: 0, icon: Goods, color: '#5e76ff', subTitle: '店铺内的商品数量', bgColor: '#e1e6ff' },
    { id: 2, title: '用户总数', value: 0, icon: User, color: '#36cfc9', subTitle: '注册用户数量', bgColor: '#d7f7f5' },
    { id: 3, title: '订单总数', value: 0, icon: Tickets, color: '#ff6b35', subTitle: '所有状态的订单', bgColor: '#ffe4dc' },
    { id: 4, title: '悬赏总数', value: 0, icon: Aim, color: '#722ed1', subTitle: '用户发布的悬赏', bgColor: '#f0e5ff' }
])

// 图表DOM引用
const goodsChartRef = ref(null)
const userChartRef = ref(null)
const orderChartRef = ref(null)
const categoryChartRef = ref(null)

// 图表实例
let goodsChart = null
let userChart = null
let orderChart = null
let categoryChart = null

// 图表数据筛选类型
const chartFilterType = ref('date') // 'date' 或 'user'

// 商品销售情况折线图数据
const goodsData = reactive({
    dates: [],
    values: [],
    userData: [] // 按用户分组的销售数据
})

// 用户增长图数据
const userData = reactive({
    dates: [],
    values: []
})

// 订单分布饼图数据
const orderData = reactive({
    status: ['待支付', '待发货', '待收货', '已完成', '已取消'],
    values: [0, 0, 0, 0, 0]
})

// 商品分类分布图数据
const categoryData = reactive({
    categories: [],
    values: []
})

// ======= 加载数据方法 =======
// 加载统计卡片数据
const loadStatsCardData = async () => {
    loading.cards = true
    try {
        // 商品总数
        const goodsRes = await getAllGoodsAPI()
        if (goodsRes.code === '200') {
            statsCards.value[0].value = goodsRes.data?.length || 0
        }

        // 用户总数
        const usersRes = await getAllUsersAPI()
        if (usersRes.code === '200') {
            statsCards.value[1].value = usersRes.data?.length || 0
        }

        // 订单总数 - 使用getAllOrdersAPI获取所有订单
        const ordersRes = await getAllOrdersAPI()
        if (ordersRes.code === '200') {
            statsCards.value[2].value = ordersRes.data?.length || 0
        }

        // 悬赏总数
        const helpRes = await getAllHelpAPI()
        if (helpRes.code === '200') {
            statsCards.value[3].value = helpRes.data?.length || 0
        }
    } catch (error) {
        console.error('加载统计卡片数据失败:', error)
    } finally {
        loading.cards = false
    }
}

// 加载商品销售数据
const loadGoodsChartData = async () => {
    loading.goodsChart = true;

    try {
        // 清空之前的数据，确保数据结构正确
        goodsData.dates = [];
        goodsData.values = [];

        // 根据图表类型选择不同的数据加载逻辑
        if (chartFilterType.value === 'date') {
            // 调用折线图API
            const lineRes = await getOrderLineAPI();

            // 检查API响应是否成功且包含数据
            if (lineRes?.code === '200' && lineRes.data && lineRes.data.length > 0) {
                // 数据排序（日期升序）
                const sortedData = [...lineRes.data].sort((a, b) => new Date(a.name) - new Date(b.name));

                // 提取数据
                goodsData.dates = sortedData.map(item => item.name);
                goodsData.values = sortedData.map(item => Number(item.value || 0));

                return true;
            } else {
                // 生成模拟数据
                const dates = [];
                const values = [];
                const today = new Date();

                for (let i = 6; i >= 0; i--) {
                    const date = new Date(today);
                    date.setDate(today.getDate() - i);
                    dates.push(formatDate(date));
                    values.push(Math.floor(Math.random() * 5000) + 1000);
                }

                goodsData.dates = dates;
                goodsData.values = values;

                return false;
            }
        } else {
            // 调用柱状图API
            const barRes = await getOrderBarAPI();

            // 检查API响应是否成功且包含数据
            if (barRes?.code === '200' && barRes.data && barRes.data.length > 0) {
                // 数据排序（销售额升序）
                const sortedData = [...barRes.data].sort((a, b) => Number(a.value || 0) - Number(b.value || 0));

                // 提取数据
                goodsData.dates = sortedData.map(item => item.name || '未知用户');
                goodsData.values = sortedData.map(item => Number(item.value || 0));

                return true;
            } else {
                // 生成模拟数据
                goodsData.dates = ['张三', '李四', '王五', '赵六'];
                goodsData.values = [5000, 3500, 2800, 1600];

                return false;
            }
        }
    } catch (error) {
        // 出错时使用模拟数据
        if (chartFilterType.value === 'date') {
            goodsData.dates = ['2024-09-17', '2024-09-18', '2024-09-19', '2024-09-20', '2024-09-21', '2024-09-22', '2024-09-23'];
            goodsData.values = [2500, 3200, 3800, 4200, 3900, 4500, 5000];
        } else {
            goodsData.dates = ['张三', '李四', '王五', '赵六'];
            goodsData.values = [5000, 3500, 2800, 1600];
        }

        return false;
    } finally {
        loading.goodsChart = false;
    }
}

// 加载用户增长数据
const loadUserChartData = async () => {
    loading.userChart = true
    try {
        // 获取用户分页数据
        const usersRes = await getAllUsersAPI()

        // 检查响应是否成功且包含数据
        if (usersRes.code === '200' && usersRes.data && usersRes.data.length > 0) {
            // 创建月份统计数据
            const monthStats = new Map()

            // 按月统计用户
            usersRes.data.forEach(user => {
                if (user.registerTime) {
                    const registerDate = new Date(user.registerTime)
                    const monthStr = formatMonth(registerDate)

                    if (!monthStats.has(monthStr)) {
                        monthStats.set(monthStr, 0)
                    }
                    monthStats.set(monthStr, monthStats.get(monthStr) + 1)
                }
            })

            // 如果有月度数据
            if (monthStats.size > 0) {
                // 排序月份
                const sortedMonths = Array.from(monthStats.keys()).sort()

                // 计算累计用户
                userData.dates = sortedMonths

                let totalUsers = 0
                userData.values = sortedMonths.map(month => {
                    totalUsers += monthStats.get(month)
                    return totalUsers
                })
            } else {
                // 如果没有注册时间数据，使用模拟数据
                generateMockUserData()
            }
        } else {
            // 无用户数据，使用模拟数据
            generateMockUserData()
        }

        // 更新图表
        if (userChart) {
            updateUserChart()
        }
    } catch (error) {
        console.error('加载用户增长数据失败:', error)
        // 出错时使用模拟数据
        generateMockUserData()
    } finally {
        loading.userChart = false
    }
}

// 生成模拟的用户增长数据
const generateMockUserData = () => {
    // 生成最近12个月的数据
    const dates = []
    const values = []
    const today = new Date()
    let totalUsers = 0

    for (let i = 11; i >= 0; i--) {
        const date = new Date(today)
        date.setMonth(today.getMonth() - i)
        const monthStr = formatMonth(date)
        dates.push(monthStr)

        // 生成随机新增用户数
        const monthlyNewUsers = Math.floor(Math.random() * 50) + 10
        totalUsers += monthlyNewUsers
        values.push(totalUsers)
    }

    userData.dates = dates
    userData.values = values
}

// 模拟订单状态分布数据
const loadOrderChartData = async () => {
    loading.orderChart = true
    try {
        // 从后端获取所有订单数据
        const ordersRes = await getAllOrdersAPI()

        if (ordersRes.code === '200' && ordersRes.data) {
            // 初始化各状态订单数量
            const orderStatusCount = {
                '待支付': 0,
                '待发货': 0,
                '待收货': 0,
                '已完成': 0,
                '已取消': 0
            }

            // 遍历订单统计各状态数量
            ordersRes.data.forEach(order => {
                if (orderStatusCount.hasOwnProperty(order.status)) {
                    orderStatusCount[order.status]++
                }
            })

            // 更新订单数据
            orderData.values = [
                orderStatusCount['待支付'],
                orderStatusCount['待发货'],
                orderStatusCount['待收货'],
                orderStatusCount['已完成'],
                orderStatusCount['已取消']
            ]
        } else {
            console.error('获取订单数据失败:', ordersRes.msg || '未知错误')
        }

        // 更新图表
        if (orderChart) {
            updateOrderChart()
        }
    } catch (error) {
        console.error('加载订单分布数据失败:', error)
    } finally {
        loading.orderChart = false
    }
}

// 商品分类分布数据
const loadCategoryChartData = async () => {
    loading.categoryChart = true
    try {
        // 从后端获取所有商品数据
        const goodsRes = await getAllGoodsAPI()

        if (goodsRes.code === '200' && goodsRes.data) {
            // 统计各分类数量
            const categoryCountMap = {}

            // 遍历商品统计各分类数量
            goodsRes.data.forEach(goods => {
                if (goods.category) {
                    if (!categoryCountMap[goods.category]) {
                        categoryCountMap[goods.category] = 0
                    }
                    categoryCountMap[goods.category]++
                }
            })

            // 提取分类名称和对应数量
            const categories = []
            const values = []

            for (const category in categoryCountMap) {
                categories.push(category)
                values.push(categoryCountMap[category])
            }

            // 更新商品分类数据
            categoryData.categories = categories
            categoryData.values = values
        } else {
            console.error('获取商品分类数据失败:', goodsRes.msg || '未知错误')
        }

        // 更新图表
        if (categoryChart) {
            updateCategoryChart()
        }
    } catch (error) {
        console.error('加载分类分布数据失败:', error)
    } finally {
        loading.categoryChart = false
    }
}

// ======= 图表初始化和更新方法 =======
// 创建日期视图的折线图配置
const createDateChartOption = () => {
    // 确保数据存在
    if (!goodsData.dates || !goodsData.values || goodsData.dates.length === 0) {
        // 生成默认的模拟数据
        const dates = [];
        const values = [];
        const today = new Date();

        for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(today.getDate() - i);
            dates.push(formatDate(date));
            values.push(Math.floor(Math.random() * 5000) + 1000);
        }

        goodsData.dates = dates;
        goodsData.values = values;
    }

    // 返回折线图配置
    return {
        title: {
            text: '销售额趋势',
            left: 'center',
            textStyle: {
                fontWeight: 'normal',
                fontSize: 16,
                color: '#333'
            }
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: {
                type: 'line',
                lineStyle: {
                    color: 'rgba(0, 0, 0, 0.2)',
                    width: 1,
                    type: 'solid'
                }
            },
            formatter: function (params) {
                const data = params[0];
                return `${data.name}<br/>${data.seriesName}: ￥${data.value.toLocaleString()}`;
            }
        },
        legend: {
            show: false
        },
        grid: {
            left: '8%',
            right: '8%',
            bottom: '8%',
            top: '15%',
            containLabel: true
        },
        xAxis: {
            type: 'category',
            boundaryGap: false,
            data: goodsData.dates,
            axisLine: {
                lineStyle: {
                    color: '#ddd'
                }
            },
            axisTick: {
                show: false
            },
            axisLabel: {
                color: '#666',
                fontSize: 12,
                formatter: function (value) {
                    // 确保值存在并且有足够长度
                    if (value && value.length >= 5) {
                        return value.substring(5); // 只显示月-日部分
                    }
                    return value;
                }
            }
        },
        yAxis: {
            type: 'value',
            name: '销售额(元)',
            nameTextStyle: {
                color: '#666',
                fontSize: 12,
                align: 'center',
                padding: [0, 0, 0, 0]
            },
            nameLocation: 'end',
            nameGap: 15,
            axisLine: {
                show: true,
                lineStyle: {
                    color: '#ddd'
                }
            },
            axisTick: {
                show: false
            },
            splitLine: {
                lineStyle: {
                    color: '#eee',
                    type: 'dashed'
                }
            },
            axisLabel: {
                color: '#666',
                formatter: function (value) {
                    return '￥' + value.toLocaleString();
                }
            }
        },
        series: [
            {
                name: '销售额',
                type: 'line',
                smooth: true,
                symbol: 'circle',
                symbolSize: 6,
                showSymbol: false,
                lineStyle: {
                    width: 3,
                    color: '#5e76ff'
                },
                itemStyle: {
                    color: '#5e76ff'
                },
                areaStyle: {
                    color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                        { offset: 0, color: 'rgba(94, 118, 255, 0.3)' },
                        { offset: 1, color: 'rgba(94, 118, 255, 0.05)' }
                    ])
                },
                data: goodsData.values
            }
        ]
    };
}

// 创建用户视图的柱状图配置
const createUserChartOption = () => {
    // 确保数据存在
    if (!goodsData.dates || !goodsData.values || goodsData.dates.length === 0) {
        // 生成默认的用户销售数据
        goodsData.dates = ['张三', '李四', '王五', '赵六'];
        goodsData.values = [5000, 3500, 2800, 1600];
    }

    // 返回柱状图配置
    return {
        title: {
            text: '用户消费排名',
            left: 'center',
            textStyle: {
                fontWeight: 'normal',
                fontSize: 16,
                color: '#333'
            }
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: {
                type: 'shadow'
            },
            formatter: function (params) {
                const data = params[0];
                return `${data.name}<br/>${data.seriesName}: ￥${data.value.toLocaleString()}`;
            }
        },
        legend: {
            show: false
        },
        grid: {
            left: '5%',
            right: '8%',
            bottom: '8%',
            top: '15%',
            containLabel: true
        },
        xAxis: {
            type: 'value',
            name: '销售额(元)',
            nameTextStyle: {
                color: '#666',
                fontSize: 12,
                align: 'center',
                padding: [0, 0, 5, 0]
            },
            nameLocation: 'end',
            nameGap: 15,
            axisLine: {
                show: true,
                lineStyle: {
                    color: '#ddd'
                }
            },
            axisTick: {
                show: false
            },
            splitLine: {
                lineStyle: {
                    color: '#eee',
                    type: 'dashed'
                }
            },
            axisLabel: {
                color: '#666',
                formatter: function (value) {
                    return '￥' + value.toLocaleString();
                }
            }
        },
        yAxis: {
            type: 'category',
            data: goodsData.dates,
            inverse: true, // 反转Y轴，让最高值显示在顶部
            axisLine: {
                show: true,
                lineStyle: {
                    color: '#ddd'
                }
            },
            axisTick: {
                show: false
            },
            axisLabel: {
                color: '#666',
                fontSize: 12,
                margin: 8, // 减小标签与轴的距离
                formatter: function (value) {
                    // 如果用户名太长，截断显示
                    if (value && value.length > 8) {
                        return value.substring(0, 8) + '...';
                    }
                    return value;
                }
            }
        },
        series: [
            {
                name: '销售额',
                type: 'bar',
                barWidth: 20,
                itemStyle: {
                    color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
                        { offset: 0, color: '#5e76ff' },
                        { offset: 1, color: '#36cfc9' }
                    ]),
                    borderRadius: [0, 4, 4, 0]
                },
                label: {
                    show: true,
                    position: 'right',
                    formatter: function (params) {
                        return '￥' + params.value.toLocaleString();
                    }
                },
                data: goodsData.values
            }
        ]
    };
}

// 初始化用户增长图表
const initUserChart = () => {
    userChart = echarts.init(userChartRef.value)
    updateUserChart()
    window.addEventListener('resize', () => userChart.resize())
}

// 更新用户增长图表
const updateUserChart = () => {
    const option = {
        title: {
            text: '用户增长趋势',
            left: 'center',
            textStyle: {
                fontWeight: 'normal',
                fontSize: 16,
                color: '#333'
            }
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: {
                type: 'shadow'
            }
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '3%',
            containLabel: true
        },
        xAxis: {
            type: 'category',
            data: userData.dates,
            axisLine: {
                lineStyle: {
                    color: '#ddd'
                }
            },
            axisTick: {
                show: false
            },
            axisLabel: {
                color: '#666',
                fontSize: 12
            }
        },
        yAxis: {
            type: 'value',
            axisLine: {
                show: false
            },
            axisTick: {
                show: false
            },
            splitLine: {
                lineStyle: {
                    color: '#eee',
                    type: 'dashed'
                }
            },
            axisLabel: {
                color: '#666'
            }
        },
        series: [
            {
                name: '累计用户数',
                type: 'bar',
                barWidth: 16,
                itemStyle: {
                    color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
                        { offset: 0, color: '#36cfc9' },
                        { offset: 1, color: '#5cdbd3' }
                    ]),
                    borderRadius: [4, 4, 0, 0]
                },
                data: userData.values
            }
        ]
    }

    userChart.setOption(option)
}

// 初始化订单分布图表
const initOrderChart = () => {
    orderChart = echarts.init(orderChartRef.value)
    updateOrderChart()
    window.addEventListener('resize', () => orderChart.resize())
}

// 更新订单分布图表
const updateOrderChart = () => {
    const option = {
        title: {
            text: '订单状态分布',
            left: 'center',
            textStyle: {
                fontWeight: 'normal',
                fontSize: 16,
                color: '#333'
            }
        },
        tooltip: {
            trigger: 'item',
            formatter: '{a} <br/>{b}: {c} ({d}%)'
        },
        legend: {
            orient: 'horizontal',
            bottom: 10,
            data: orderData.status,
            icon: 'circle',
            itemWidth: 10,
            itemHeight: 10,
            textStyle: {
                color: '#666'
            }
        },
        series: [
            {
                name: '订单状态',
                type: 'pie',
                radius: ['35%', '60%'],
                center: ['50%', '45%'],
                avoidLabelOverlap: false,
                itemStyle: {
                    borderRadius: 8,
                    borderColor: '#fff',
                    borderWidth: 2
                },
                label: {
                    show: false,
                    position: 'center'
                },
                emphasis: {
                    label: {
                        show: true,
                        fontSize: 16,
                        fontWeight: 'bold'
                    }
                },
                labelLine: {
                    show: false
                },
                data: orderData.status.map((name, index) => {
                    const colors = ['#ffc53d', '#40a9ff', '#73d13d', '#52c41a', '#ff4d4f'];
                    return {
                        name,
                        value: orderData.values[index],
                        itemStyle: {
                            color: colors[index]
                        }
                    }
                })
            }
        ]
    }

    orderChart.setOption(option)
}

// 初始化商品分类分布图表
const initCategoryChart = () => {
    categoryChart = echarts.init(categoryChartRef.value)
    updateCategoryChart()
    window.addEventListener('resize', () => categoryChart.resize())
}

// 更新商品分类分布图表
const updateCategoryChart = () => {
    const option = {
        title: {
            text: '商品分类分布',
            left: 'center',
            textStyle: {
                fontWeight: 'normal',
                fontSize: 16,
                color: '#333'
            }
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: {
                type: 'shadow'
            }
        },
        grid: {
            left: '3%',
            right: '4%',
            bottom: '10%',
            containLabel: true
        },
        xAxis: {
            type: 'value',
            axisLine: {
                show: false
            },
            axisTick: {
                show: false
            },
            splitLine: {
                lineStyle: {
                    color: '#eee',
                    type: 'dashed'
                }
            },
            axisLabel: {
                color: '#666'
            }
        },
        yAxis: {
            type: 'category',
            data: categoryData.categories,
            axisLine: {
                lineStyle: {
                    color: '#ddd'
                }
            },
            axisTick: {
                show: false
            },
            axisLabel: {
                color: '#666',
                fontSize: 12
            }
        },
        series: [
            {
                name: '商品数量',
                type: 'bar',
                barWidth: 16,
                itemStyle: {
                    color: function (params) {
                        const colorList = [
                            '#ff6b35', '#5e76ff', '#36cfc9', '#ffc53d',
                            '#73d13d', '#ff4d4f', '#722ed1'
                        ];
                        return colorList[params.dataIndex % colorList.length];
                    },
                    borderRadius: [0, 4, 4, 0]
                },
                data: categoryData.values
            }
        ]
    }

    categoryChart.setOption(option)
}

// ======= 辅助函数 =======
// 格式化日期为 YYYY-MM-DD
const formatDate = (date) => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
}

// 格式化月份为 YYYY-MM
const formatMonth = (date) => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    return `${year}-${month}`
}

// 切换销售数据展示类型
const changeChartFilterType = async (type) => {
    // 只有当类型确实发生变化时才执行
    if (chartFilterType.value === type) {
        return;
    }

    try {
        // 更新类型并开始加载
        chartFilterType.value = type;
        loading.goodsChart = true;

        // 1. 销毁旧图表
        if (goodsChart) {
            goodsChart.dispose();
            goodsChart = null;
        }

        // 2. 加载新数据
        await loadGoodsChartData();

        // 确保DOM已更新
        await nextTick();

        // 3. 检查DOM引用是否存在
        if (!goodsChartRef.value) {
            return;
        }

        // 4. 初始化新图表
        goodsChart = echarts.init(goodsChartRef.value);

        // 5. 根据类型设置不同的配置
        let option;
        if (type === 'date') {
            option = createDateChartOption();
        } else {
            option = createUserChartOption();
        }

        // 6. 应用图表配置
        goodsChart.setOption(option);
        goodsChart.resize();

        // 7. 设置resize监听器
        window.removeEventListener('resize', handleResize);
        window.addEventListener('resize', handleResize);
    } catch (error) {
        console.error("切换图表类型时发生错误:", error);
    } finally {
        loading.goodsChart = false;
    }
}

// 处理窗口大小调整的函数
const handleResize = () => {
    if (goodsChart) {
        goodsChart.resize();
    }
}

// ======= 生命周期钩子 =======
onMounted(async () => {
    try {
        // 1. 加载统计卡片数据
        loadStatsCardData();

        // 2. 加载并初始化其他图表
        await loadUserChartData();
        await loadOrderChartData();
        await loadCategoryChartData();

        // 3. 初始化其他图表实例
        initUserChart();
        initOrderChart();
        initCategoryChart();

        // 4. 直接初始化销售图表（默认为日期折线图）
        // 确保加载数据
        await loadGoodsChartData();

        // 等待DOM更新
        await nextTick();

        // 初始化图表
        if (goodsChartRef.value) {
            // 创建图表实例
            goodsChart = echarts.init(goodsChartRef.value);

            // 应用日期折线图配置
            const option = createDateChartOption();
            goodsChart.setOption(option);

            // 调整大小
            goodsChart.resize();

            // 添加窗口大小调整监听
            window.addEventListener('resize', handleResize);
        }
    } catch (error) {
        console.error("仪表盘初始化失败:", error);
    }
});
</script>

<template>
    <div class="dashboard-container">
        <!-- 页面头部 -->
        <div class="page-header">
            <div class="header-title">
                <el-icon>
                    <Dashboard />
                </el-icon>
                <!-- 欢迎横幅 -->
                <div class="welcome-banner">
                    <div class="welcome-content">
                        <div class="welcome-text">
                            <h1>您好，{{ user?.name || '管理员' }}</h1>
                            <p>欢迎使用悠享二手交易管理系统</p>
                        </div>
                        <div class="welcome-decoration">
                            <img src="@/assets/icons/dashboard.svg" alt="Dashboard" class="dashboard-icon" />
                        </div>
                    </div>
                </div>

                <!-- 统计卡片 -->
                <div class="stats-cards">
                    <el-skeleton :loading="loading.cards" animated :count="4" :throttle="500">
                        <template #template>
                            <div class="skeleton-card"></div>
                        </template>
                        <template #default>
                            <div v-for="card in statsCards" :key="card.id" class="stats-card"
                                :style="{ '--card-color': card.color, '--card-bg-color': card.bgColor }">
                                <div class="card-icon">
                                    <el-icon>
                                        <component :is="card.icon" />
                                    </el-icon>
                                </div>
                                <div class="card-content">
                                    <div class="card-value">{{ card.value.toLocaleString() }}</div>
                                    <div class="card-title">{{ card.title }}</div>
                                    <div class="card-subtitle">{{ card.subTitle }}</div>
                                </div>
                            </div>
                        </template>
                    </el-skeleton>
                </div>

                <!-- 图表卡片 -->
                <div class="chart-row">
                    <!-- 商品销售趋势图 -->
                    <div class="chart-card">
                        <el-skeleton :loading="loading.goodsChart" animated :rows="8" :throttle="500">
                            <template #template>
                                <div class="skeleton-chart"></div>
                            </template>
                            <template #default>
                                <!-- 添加图表控制器 -->
                                <div class="chart-controls">
                                    <el-button-group size="small">
                                        <el-button :type="chartFilterType === 'date' ? 'primary' : 'default'"
                                            @click="changeChartFilterType('date')">
                                            按日期
                                        </el-button>
                                        <el-button :type="chartFilterType === 'user' ? 'primary' : 'default'"
                                            @click="changeChartFilterType('user')">
                                            按用户
                                        </el-button>
                                    </el-button-group>
                                </div>
                                <div ref="goodsChartRef" class="chart-container"></div>
                            </template>
                        </el-skeleton>
                    </div>

                    <!-- 用户增长趋势图 -->
                    <div class="chart-card">
                        <el-skeleton :loading="loading.userChart" animated :rows="8" :throttle="500">
                            <template #template>
                                <div class="skeleton-chart"></div>
                            </template>
                            <template #default>
                                <div ref="userChartRef" class="chart-container"></div>
                            </template>
                        </el-skeleton>
                    </div>
                </div>

                <div class="chart-row">
                    <!-- 订单状态分布图 -->
                    <div class="chart-card">
                        <el-skeleton :loading="loading.orderChart" animated :rows="8" :throttle="500">
                            <template #template>
                                <div class="skeleton-chart"></div>
                            </template>
                            <template #default>
                                <div ref="orderChartRef" class="chart-container"></div>
                            </template>
                        </el-skeleton>
                    </div>

                    <!-- 商品分类分布图 -->
                    <div class="chart-card">
                        <el-skeleton :loading="loading.categoryChart" animated :rows="8" :throttle="500">
                            <template #template>
                                <div class="skeleton-chart"></div>
                            </template>
                            <template #default>
                                <div ref="categoryChartRef" class="chart-container"></div>
                            </template>
                        </el-skeleton>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style lang="scss" scoped>
// 变量定义
$primary-color: #5e76ff;
$primary-gradient: linear-gradient(135deg, #5e76ff, #36cfc9);
$text-color: #333;
$text-secondary: #666;
$card-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
$border-radius: 16px;
$transition-time: 0.3s;

// 仪表盘容器
.dashboard-container {
    padding: 0;
    overflow: hidden;
    background-color: #f5f7fa;
}

// 欢迎横幅
.welcome-banner {
    background: $primary-gradient;
    padding: 32px;
    border-radius: $border-radius;
    margin-bottom: 24px;
    color: white;
    position: relative;
    overflow: hidden;
    box-shadow: $card-shadow;

    .welcome-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
        position: relative;
        z-index: 2;

        .welcome-text {
            h1 {
                font-size: 28px;
                font-weight: 600;
                margin: 0 0 8px 0;
            }

            p {
                font-size: 16px;
                margin: 0;
                opacity: 0.8;
            }
        }

        .welcome-decoration {
            .dashboard-icon {
                width: 120px;
                height: 120px;
                opacity: 0.9;
            }
        }
    }

    &::before {
        content: '';
        position: absolute;
        top: -100px;
        right: -100px;
        width: 300px;
        height: 300px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        z-index: 1;
    }

    &::after {
        content: '';
        position: absolute;
        bottom: -80px;
        left: 30%;
        width: 200px;
        height: 200px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        z-index: 1;
    }
}

// 统计卡片
.stats-cards {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 24px;
    margin-bottom: 24px;

    @media (max-width: 1200px) {
        grid-template-columns: repeat(2, 1fr);
    }

    @media (max-width: 768px) {
        grid-template-columns: 1fr;
    }

    .stats-card {
        background: white;
        border-radius: $border-radius;
        padding: 24px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        transition: transform $transition-time, box-shadow $transition-time;
        display: flex;
        align-items: center;
        position: relative;
        overflow: hidden;

        &:hover {
            transform: translateY(-5px);
            box-shadow: $card-shadow;

            .card-icon {
                transform: scale(1.05);
            }
        }

        .card-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            background-color: var(--card-bg-color);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
            transition: transform $transition-time;

            .el-icon {
                font-size: 32px;
                color: var(--card-color);
            }
        }

        .card-content {
            flex: 1;

            .card-value {
                font-size: 28px;
                font-weight: 600;
                color: $text-color;
                margin-bottom: 4px;
            }

            .card-title {
                font-size: 16px;
                font-weight: 500;
                color: $text-color;
                margin-bottom: 4px;
            }

            .card-subtitle {
                font-size: 12px;
                color: $text-secondary;
                opacity: 0.7;
            }
        }

        &::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 4px;
            background-color: var(--card-color);
        }
    }

    .skeleton-card {
        height: 132px;
        background: #f0f2f5;
        border-radius: $border-radius;
    }
}

// 图表行
.chart-row {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
    margin-bottom: 24px;

    @media (max-width: 1200px) {
        grid-template-columns: 1fr;
    }
}

// 图表卡片
.chart-card {
    background: white;
    border-radius: $border-radius;
    padding: 16px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    transition: transform $transition-time, box-shadow $transition-time;

    &:hover {
        transform: translateY(-5px);
        box-shadow: $card-shadow;
    }

    .chart-controls {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 16px;
    }

    .chart-container {
        height: 350px;
        width: 100%;
    }

    .skeleton-chart {
        height: 350px;
        background: #f0f2f5;
        border-radius: 8px;
    }
}

// 动画效果
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

.welcome-banner,
.stats-cards,
.chart-row {
    animation: fadeIn 0.5s ease-out forwards;
}

.stats-cards {
    animation-delay: 0.1s;
}

.chart-row:nth-child(3) {
    animation-delay: 0.2s;
}

.chart-row:nth-child(4) {
    animation-delay: 0.3s;
}
</style>
