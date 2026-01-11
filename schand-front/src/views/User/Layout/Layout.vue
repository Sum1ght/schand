<script setup>
import LayoutFooter from "./components/LayoutFooter.vue";
import LayoutNav from "./components/LayoutNav.vue";
import LayoutSiderTool from "./components/LayoutSiderTool.vue";
//!必须在起始路由里调用它的获取方法一次，不然是没有全局状态categoryData的
</script>

<template>
  <div class="layout-container">
    <LayoutNav />
    <main class="main-content">
      <RouterView />
    </main>
    <LayoutFooter />
    <LayoutSiderTool />
  </div>
</template>

<style scoped lang="scss">
.layout-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  position: relative;
}

.main-content {
  flex: 1;
  padding-bottom: 40px;
  /* 确保内容区域和页脚之间有足够的间距 */
}
</style>