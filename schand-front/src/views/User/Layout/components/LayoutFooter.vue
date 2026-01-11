<script setup>
import { Service, Location, Message } from '@element-plus/icons-vue'
</script>

<template>
    <div class="footer">
        <div class="container">
            <div class="service">
                <ul>
                    <li>
                        <Service />
                        <p>品质保障</p>
                    </li>
                    <li>
                        <Location />
                        <p>便捷服务</p>
                    </li>
                    <li>
                        <Message />
                        <p>快速响应</p>
                    </li>
                </ul>
            </div>
            <div class="links">
                <dl>
                    <dt>关于我们</dt>
                    <dd><a href="javascript:;">公司介绍</a></dd>
                    <dd><a href="javascript:;">联系我们</a></dd>
                    <dd><a href="javascript:;">加入我们</a></dd>
                </dl>
                <dl>
                    <dt>帮助中心</dt>
                    <dd><a href="javascript:;">常见问题</a></dd>
                    <dd><a href="javascript:;">售后服务</a></dd>
                    <dd><a href="javascript:;">意见反馈</a></dd>
                </dl>
                <dl>
                    <dt>用户服务</dt>
                    <dd><a href="javascript:;">隐私政策</a></dd>
                    <dd><a href="javascript:;">用户协议</a></dd>
                    <dd><a href="javascript:;">安全须知</a></dd>
                </dl>
            </div>
            <div class="copyright">
                <p>© 版权所有 侵权必究</p>
                <p>联系方式：1522457459@qq.com</p>
            </div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.footer {
    background: #404040;
    padding: 20px 0;
    margin-top: 20px;

    .container {
        width: 1240px;
        margin: 0 auto;
    }

    .service {
        padding: 20px 0;
        border-bottom: 1px solid #cdcdcd;

        ul {
            display: flex;
            justify-content: space-around;
            list-style: none;

            li {
                display: flex;
                flex-direction: column;
                align-items: center;
                color: #cdcdcd;

                svg {
                    width: 30px;
                    height: 30px;
                    margin-bottom: 8px;
                }

                &:hover {
                    color: $baseColor;
                }
            }
        }
    }

    .links {
        display: flex;
        justify-content: space-between;
        padding: 30px 0;

        dl {
            width: 180px;

            dt {
                font-size: 16px;
                color: #cdcdcd;
                font-weight: bold;
                margin-bottom: 10px;
            }

            dd {
                margin-bottom: 5px;

                a {
                    color: #cdcdcd;

                    &:hover {
                        color: $baseColor;
                    }
                }
            }
        }
    }

    .copyright {
        text-align: center;
        color: #cdcdcd;
        padding-top: 10px;
        border-top: 1px solid #cdcdcd;

        p {
            line-height: 1.5;
        }
    }
}
</style>