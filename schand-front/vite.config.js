import { fileURLToPath, URL } from "node:url";

import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
// 引入图标库
// import Icons from "unplugin-icons/vite";
// import IconsResolver from "unplugin-icons/resolver";
// 引入开发工具
import vueDevTools from "vite-plugin-vue-devtools";
// elementPlus按需导入
import AutoImport from "unplugin-auto-import/vite";
import Components from "unplugin-vue-components/vite";
import { ElementPlusResolver } from "unplugin-vue-components/resolvers";

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    vueDevTools(),
    AutoImport({
      imports: ["vue", "vue-router"],
      // 自动导入elementPlus相关函数
      resolvers: [ElementPlusResolver()],
    }),
    Components({
      resolvers: [
        // 自动导入elementPlus相关组件 并采用sass样式配色系统
        ElementPlusResolver({ importStyle: "sass" }),
        // 不再使用自动注册图标组件，改为手动导入
        // IconsResolver({
        //   enabledCollections: ["ep"],
        // }),
      ],
    }),
    // 不再使用自动下载图标组件
    // Icons({
    //   autoInstall: true,
    // }),
  ],
  // 配置路径别名
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
  // 配置scss
  css: {
    preprocessorOptions: {
      scss: {
        //自动导入定制化样式文件进行样式覆盖
        additionalData: `
          @use "@/styles/element/index.scss" as *;
          @use "@/styles/var.scss" as *;
        `,
      },
    },
  },

  // 配置devServer
  server: {
    port:8080,
    // 配置跨域代理
    proxy: {
      // 新闻API代理配置
      "/news": {
        target: "https://whyta.cn/api",
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/news/, ""),
      },
    },
    cors: true, // 配置是否允许跨域
  },
});