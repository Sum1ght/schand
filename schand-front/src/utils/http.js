import axios from "axios";
import { useUserStore } from "@/stores/userStore";
import { ElMessage } from "element-plus";
//! 普通js文件里不能用useRouter，只能导入router对象
import router from "@/router/index";

const httpInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || "http://localhost:9090",
  headers: {
    "Content-Type": "application/json;charset=utf-8",
  },
  timeout: 5000,
});

// 请求拦截器
httpInstance.interceptors.request.use(
  (config) => {
    // 获取userStore实例
    const userStore = useUserStore();
    // 从store中获取token
    const token = userStore.userInfo?.token || "";
    config.headers["token"] = token;
    console.log(`${config.url}请求拦截器`, config);
    return config;
  },
  (e) => {
    ElMessage({ type: "warning", message: e.message });
    return Promise.reject(e);
  }
);

// 响应拦截器
httpInstance.interceptors.response.use(
  (res) => {
    console.log(`${res.config.url}响应拦截器res`, res);
    return res.data;
  },
  (e) => {
    if (e.status == "500") {
      router.replace("/login");
      console.log(`${e.config.url}响应拦截器e`, e);
      ElMessage({ type: "error", message: "请重新登录" });
      return Promise.reject(e);
    }
    ElMessage({ type: "warning", message: e.message });
    return Promise.reject(e);
  }
);

export default httpInstance;
