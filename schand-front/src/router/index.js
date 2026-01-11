import { createRouter, createWebHistory } from "vue-router";
import Login from "@/views/User/Web/Login.vue";
import Square from "@/views/User/Square/Square.vue";
const routes = [
  {
    path: "/",
    name: "Layout",
    component: () => import("@/views/User/Layout/Layout.vue"),
    // 需要登录才能访问
    // meta: { requiresAuth: false },
    children: [
      // 空路径重定向到广场
      {
        path: "",
        redirect: "/square",
      },
      {
        path: "square",
        name: "square",
        component: Square,
        meta: { title: "广场" },
      },
      {
        path: "community",
        name: "community",
        component: () => import("@/views/User/Community/Community.vue"),
        meta: { title: "社区" },
      },
      {
        path: "post/detail/:id",
        name: "postdetail",
        component: () => import("@/components/Post/PostDetail.vue"),
        meta: { title: "帖子详情" },
      },
      {
        path: "post/create",
        name: "postcreate",
        component: () => import("@/components/Post/PostCreate.vue"),
        meta: { title: "发布帖子", requiresAuth: true },
      },
      {
        path: "wanted",
        name: "wanted",
        component: () => import("@/views/User/Wanted/Wanted.vue"),
        meta: { title: "悬赏" },
      },
      {
        path: "wanted/create",
        name: "wantedcreate",
        component: () => import("@/components/Wanted/WantedCreate.vue"),
        meta: { title: "发布悬赏" },
      },
      {
        path: "wanted/detail/:id",
        name: "wanteddetail",
        component: () => import("@/components/Wanted/WantedDetail.vue"),
        meta: { title: "悬赏详情" },
      },
      {
        path: "notice",
        name: "notice",
        component: () => import("@/views/User/Notice/Notice.vue"),
        meta: { title: "公告" },
      },
      {
        path: "feedback",
        name: "feedback",
        component: () => import("@/views/User/Feedback/Feedback.vue"),
        meta: { title: "反馈" },
      },
      {
        path: "goods/create",
        name: "goodscreate",
        component: () => import("@/components/Goods/GoodsCreate.vue"),
        meta: { title: "发布商品" },
      },
      {
        path: "goods/detail/:id",
        name: "goodsdetail",
        component: () => import("@/components/Goods/GoodsDetail.vue"),
        meta: { title: "商品详情" },
      },
      {
        path: "chat",
        name: "chat",
        component: () => import("@/components/Chat.vue"),
      },
      // 支付相关路由
      {
        path: "pay",
        name: "pay",
        component: () => import("@/views/User/Pay/Pay.vue"),
        meta: { title: "订单支付", requiresAuth: true },
      },
      {
        path: "payback",
        name: "payback",
        component: () => import("@/views/User/Pay/PayBack.vue"),
        meta: { title: "支付结果", requiresAuth: true },
      },
      {
        path: "personal",
        name: "personal",
        meta: { requiresAuth: true },
        // 添加默认重定向
        redirect: "/personal/myinfo",
        children: [
          {
            path: "myinfo",
            name: "myinfo",
            component: () => import("@/views/User/Personal/MyInfo.vue"),
          },
          {
            path: "mygoods",
            name: "mygoods",
            component: () => import("@/views/User/Personal/MyGoods.vue"),
          },
          {
            path: "myorder",
            name: "myorder",
            component: () => import("@/views/User/Personal/MyOrder.vue"),
          },
          {
            path: "myfeedback",
            name: "myfeedback",
            component: () => import("@/views/User/Personal/MyFeedback.vue"),
          },
          {
            path: "myaddress",
            name: "myaddress",
            component: () => import("@/views/User/Personal/MyAddress.vue"),
          },
          {
            path: "mycollection",
            name: "mycollection",
            component: () => import("@/views/User/Personal/MyCollection.vue"),
          },
          {
            path: "mywanted",
            name: "mywanted",
            component: () => import("@/views/User/Personal/MyWanted.vue"),
          },
          {
            path: "mypost",
            name: "mypost",
            component: () => import("@/views/User/Personal/MyPost.vue"),
          },
        ],
      },
    ],
  },
  {
    path: "/login",
    name: "login",
    component: Login,
    meta: { requiresAuth: false },
  },
  {
    path: "/register",
    name: "register",
    component: () => import("@/views/User/Web/Register.vue"),
    meta: { requiresAuth: false },
  },
  {
    path: "/manager",
    name: "manager",
    component: () => import("@/views/Manager/Manager.vue"),
    redirect: "/manager/dashboard",
    children: [
      {
        path: "dashboard",
        name: "dashboard",
        component: () => import("@/views/Manager/components/DashBoard.vue"),
        meta: { name: "系统仪表盘" },
      },
      {
        path: "business",
        name: "business",
        component: () => import("@/views/Manager/components/Business.vue"),
        meta: { name: "业务管理" },
      },
      {
        path: "role",
        name: "role",
        component: () => import("@/views/Manager/components/Role.vue"),
        meta: { name: "角色管理" },
      },
      {
        path: "category",
        name: "m-category",
        component: () => import("@/views/Manager/components/ManaCategory.vue"),
      },
      {
        path: "goods",
        name: "m-goods",
        component: () => import("@/views/Manager/components/ManaGoods.vue"),
      },

      {
        path: "feedback",
        name: "m-feedback",
        component: () => import("@/views/Manager/components/ManaFeedback.vue"),
      },

      {
        path: "wanted",
        name: "m-wanted",
        component: () => import("@/views/Manager/components/ManaWanted.vue"),
      },
      {
        path: "notice",
        name: "m-notice",
        component: () => import("@/views/Manager/components/ManaNotice.vue"),
      },
      {
        path: "circles",
        name: "m-circles",
        component: () => import("@/views/Manager/components/ManaCircles.vue"),
      },
      {
        path: "posts",
        name: "m-posts",
        component: () => import("@/views/Manager/components/ManaPosts.vue"),
      },
      {
        path: "address",
        name: "m-address",
        component: () => import("@/views/Manager/components/ManaAddress.vue"),
      },
      {
        path: "comment",
        name: "m-comment",
        component: () => import("@/views/Manager/components/ManaComment.vue"),
      },
      {
        path: "user",
        name: "m-user",
        component: () => import("@/views/Manager/components/ManaUser.vue"),
      },
      {
        path: "admin",
        name: "m-admin",
        component: () => import("@/views/Manager/components/ManaAdmin.vue"),
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
  // 切换路由时返回顶部
  // eslint-disable-next-line no-unused-vars
  // to, from, savedPosition
  // eslint-disable-next-line no-unused-vars
  scrollBehavior(to, from, savedPosition) {
    return {
      top: 0,
    };
  },
});

export default router;
