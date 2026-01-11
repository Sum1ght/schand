import axios from "axios";

// 外部新闻

const httpInstance = axios.create({
  baseURL: "/news",
  timeout: 10000,
});

httpInstance.interceptors.request.use((config) => {
  // 只设置安全的请求头
  config.headers = {
    ...config.headers,
    Accept: "application/json, text/plain, */*",
  };
  return config;
});

// 添加响应拦截器，用于调试
httpInstance.interceptors.response.use(
  (response) => {
    console.log("新闻API响应:", response.config.url, response.data);
    return response.data;
  },
  (error) => {
    console.error("新闻API错误:", error);
    return Promise.reject(error);
  }
);

export default httpInstance;
