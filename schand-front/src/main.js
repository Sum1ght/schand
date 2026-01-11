import { createApp } from "vue";
import App from "./App.vue";

import { createPinia } from "pinia";
import piniaPluginPersistedstate from "pinia-plugin-persistedstate";
import router from "./router";

// import * as ElementPlusIconsVue from "@element-plus/icons-vue";
// import "@/styles/common.scss";

const app = createApp(App);

const pinia = createPinia();
pinia.use(piniaPluginPersistedstate);

app.use(pinia);
app.use(router);

//! 全局注册和手动导入用<User />，自动按需导入用<i-ep-user />
//全局注册组件
// for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
//   app.component(key, component);
// }

app.mount("#app");
