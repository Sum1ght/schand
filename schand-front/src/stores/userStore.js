import { ref } from "vue";
import { defineStore } from "pinia";
import { loginAPI } from "@/api/webAPI";

export const useUserStore = defineStore(
  "user",
  () => {
    // 用户信息
    const userInfo = ref({});

    // 获取用户登录状态
    const isLoggedIn = () => {
      return !!userInfo.value?.token;
    };

    // 登录
    const login = async (userData) => {
      try {
        const res = await loginAPI(userData);
        userInfo.value = res.data;
        return res;
      } catch (error) {
        console.log(error);
      }
    };

    // 退出登录
    const logout = () => {
      userInfo.value = {};
    };

    // 更新用户信息
    const updateUserInfo = (newUserInfo) => {
      userInfo.value = { ...userInfo.value, ...newUserInfo };
    };

    return {
      userInfo,
      isLoggedIn,
      login,
      logout,
      updateUserInfo,
    };
  },
  // 启用持久化存储
  // 不再需要手动初始化用户信息，由pinia-plugin-persistedstate自动处理
  {
    persist: true,
  }
);
