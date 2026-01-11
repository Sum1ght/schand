/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80041
 Source Host           : localhost:3306
 Source Schema         : schand

 Target Server Type    : MySQL
 Target Server Version : 80041
 File Encoding         : 65001

 Date: 17/05/2025 00:38:27
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `address` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 10 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, '张三', '河南省郑州市中原区', '15897361463', 2);
INSERT INTO `address` VALUES (8, '肖日', '湖南工商大学', '15897361460', 5);
INSERT INTO `address` VALUES (9, '肖月', '湖南工商大学', '15897361461', 9);

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int NOT NULL,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '123456', '管理员', '15897361467', '152245745@qq.com', 'http://localhost:9090/files/管理员.png', 'ADMIN');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 10 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '数码电子');
INSERT INTO `category` VALUES (2, '家居');
INSERT INTO `category` VALUES (3, '书籍');
INSERT INTO `category` VALUES (4, '服饰');
INSERT INTO `category` VALUES (5, '运动');
INSERT INTO `category` VALUES (8, '饮食');
INSERT INTO `category` VALUES (9, '日用百货');

-- ----------------------------
-- Table structure for chat_group
-- ----------------------------
DROP TABLE IF EXISTS `chat_group`;
CREATE TABLE `chat_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `chat_user_id` int NOT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 7 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Records of chat_group
-- ----------------------------
INSERT INTO `chat_group` VALUES (1, 2, 1);
INSERT INTO `chat_group` VALUES (2, 1, 2);
INSERT INTO `chat_group` VALUES (3, 1, 3);
INSERT INTO `chat_group` VALUES (4, 3, 1);
INSERT INTO `chat_group` VALUES (5, 5, 9);
INSERT INTO `chat_group` VALUES (6, 9, 5);

-- ----------------------------
-- Table structure for chat_info
-- ----------------------------
DROP TABLE IF EXISTS `chat_info`;
CREATE TABLE `chat_info`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `chat_user_id` int NOT NULL,
  `user_id` int NOT NULL,
  `text` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `isread` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'N',
  `time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 13 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chat_info
-- ----------------------------
INSERT INTO `chat_info` VALUES (1, 2, 1, '你好', '是', '2024-09-23 10:55:22');
INSERT INTO `chat_info` VALUES (2, 2, 1, '耳机还在吗？\n', '是', '2024-09-23 10:55:35');
INSERT INTO `chat_info` VALUES (3, 1, 2, '在的', '是', '2024-09-23 10:56:02');
INSERT INTO `chat_info` VALUES (4, 1, 3, '你好', '是', '2024-09-23 10:57:41');
INSERT INTO `chat_info` VALUES (5, 1, 3, '你好手机还在吗？\n', '是', '2024-09-23 10:59:16');
INSERT INTO `chat_info` VALUES (6, 3, 1, '你好', '是', '2024-09-23 11:19:40');
INSERT INTO `chat_info` VALUES (7, 1, 3, '你好', '是', '2024-09-23 14:11:58');
INSERT INTO `chat_info` VALUES (8, 1, 2, '111', '是', '2025-04-04 19:08:15');
INSERT INTO `chat_info` VALUES (9, 5, 9, 'hellohello', '是', '2025-05-06 13:24:32');
INSERT INTO `chat_info` VALUES (10, 5, 9, '在吗？', '是', '2025-05-06 13:24:41');
INSERT INTO `chat_info` VALUES (11, 9, 5, '有事说事', 'N', '2025-05-16 20:02:20');
INSERT INTO `chat_info` VALUES (12, 9, 5, '这是看上我哪个宝贝了', 'N', '2025-05-16 20:02:29');

-- ----------------------------
-- Table structure for circles
-- ----------------------------
DROP TABLE IF EXISTS `circles`;
CREATE TABLE `circles`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `img` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 10 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of circles
-- ----------------------------
INSERT INTO `circles` VALUES (6, 'http://localhost:9090/files/学习圈.jpg', '学习圈');
INSERT INTO `circles` VALUES (2, 'http://localhost:9090/files/阅读圈.jpg', '阅读圈');
INSERT INTO `circles` VALUES (3, 'http://localhost:9090/files/健身圈.jpg', '健身圈');
INSERT INTO `circles` VALUES (4, 'http://localhost:9090/files/美食圈.jpg', '美食圈');
INSERT INTO `circles` VALUES (7, 'http://localhost:9090/files/电竞圈.jpg', '电竞圈');
INSERT INTO `circles` VALUES (8, 'http://localhost:9090/files/影视圈.jpg', '影视圈');
INSERT INTO `circles` VALUES (9, 'http://localhost:9090/files/二次元圈.jpg', '二次元圈');

-- ----------------------------
-- Table structure for collect
-- ----------------------------
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `fid` int NOT NULL,
  `user_id` int NOT NULL,
  `module` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 22 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collect
-- ----------------------------
INSERT INTO `collect` VALUES (1, 5, 1, 'goods');
INSERT INTO `collect` VALUES (16, 2, 2, 'goods');
INSERT INTO `collect` VALUES (21, 3, 5, 'goods');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `user_id` int NOT NULL,
  `pid` int NULL DEFAULT NULL,
  `time` datetime NULL DEFAULT NULL,
  `fid` int NULL DEFAULT NULL,
  `module` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `root_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 29 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (22, '地狱乐只能说勉强能看\n', 5, NULL, '2025-05-16 19:56:50', 10, 'posts', 22);
INSERT INTO `comment` VALUES (21, '我推的孩子最后八成要烂尾\n', 5, NULL, '2025-05-16 19:56:31', 10, 'posts', 21);
INSERT INTO `comment` VALUES (19, '狐狸感觉不如阿卡丽一根', 5, NULL, '2025-05-16 18:51:13', 8, 'posts', 19);
INSERT INTO `comment` VALUES (20, '评分高了，让我来打分顶多7分', 5, NULL, '2025-05-16 19:48:09', 9, 'posts', 20);
INSERT INTO `comment` VALUES (24, '我正好有台闲置的，私你了', 5, NULL, '2025-05-16 20:01:32', 1, 'help', 24);
INSERT INTO `comment` VALUES (25, '流口水了', 5, NULL, '2025-05-16 20:01:56', 12, 'posts', 25);
INSERT INTO `comment` VALUES (26, '做的可以，一看就很好吃', 5, NULL, '2025-05-16 20:09:59', 5, 'posts', 26);
INSERT INTO `comment` VALUES (27, '红楼梦是封建文学的巅峰，值得细细品读', 5, NULL, '2025-05-16 20:10:21', 3, 'posts', 27);
INSERT INTO `comment` VALUES (28, '一起加油！', 5, NULL, '2025-05-16 21:11:03', 7, 'posts', 28);

-- ----------------------------
-- Table structure for feedback
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `reply` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `createtime` datetime NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 9 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of feedback
-- ----------------------------
INSERT INTO `feedback` VALUES (1, '网站登录问题', '我在尝试登录网站时遇到了一些问题。每次输入正确的用户名和密码后，都会收到错误提示：“账户名或密码错误”。我已经多次重试并确认了我的输入是正确的，所以我认为可能是系统出现了故障。我希望你们能够调查一下这个问题，并尽快修复。谢谢！', '18634208045', '123@qq.com', '目前已经修复好了', '2024-09-23 10:25:38', 1);

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `price` decimal(10, 2) NOT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `img` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `date` datetime NULL DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `category` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `user_id` int NULL DEFAULT NULL,
  `sale_status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `read_count` int NULL DEFAULT 0,
  `user_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `sort` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `user_likes` tinyint(1) NULL DEFAULT 0,
  `user_collect` tinyint(1) NULL DEFAULT 0,
  `likes_count` int NULL DEFAULT 0,
  `collect_count` int NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 74 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, '苹果 iPhone 13 Pro Max', 5000.00, '<h3>商品概述</h3><p>这是一部经过精心保养的二手iPhone 13 Pro Max，外观成色良好，无明显划痕或磨损。设备功能正常，所有硬件组件均处于良好的工作状态。这部手机已解锁，可兼容任何运营商网络。我正在寻找一位对这款设备感兴趣的买家，希望它能带给您同样出色的体验。</p><h3>设备状况</h3><ul><li><strong>屏幕</strong>：无裂纹或刮痕，显示清晰明亮。</li><li><strong>背面及边框</strong>：轻微使用痕迹，不影响整体美观。</li><li><strong>摄像头</strong>：拍摄效果出色，无模糊或损坏。</li><li><strong>电池健康度</strong>：超过80%，剩余寿命充足。</li><li><strong>软件</strong>：运行 iOS 15.x 版本，无越狱或其他非法操作。</li><li><strong>配件</strong>：附带原装充电线和适配器（如有）</li></ul><h3>交易说明</h3><ul><li><strong>价格</strong>：由于是二手商品，价格比全新版本优惠很多。</li><li><strong>保修期</strong>：无官方保修，但我会提供一周内无理由退换货保障。</li><li><strong>支付方式</strong>：支持支付宝、微信支付等多种付款方式。</li><li><strong>配送</strong>：全国包邮，采用顺丰快递，确保安全送达。</li></ul>', '北京市朝阳区', 'http://localhost:9090/files/ipone.png', '2024-09-25 00:00:00', '通过', '数码电子', 1, '上架', 155, NULL, NULL, 0, 0, 0, 0);
INSERT INTO `goods` VALUES (2, '苹果 iPhone 13 Pro', 4500.00, '<h3>商品概述</h3><p>这是一部经过精心保养的二手iPhone 13 Pro Max，外观成色良好，无明显划痕或磨损。设备功能正常，所有硬件组件均处于良好的工作状态。这部手机已解锁，可兼容任何运营商网络。我正在寻找一位对这款设备感兴趣的买家，希望它能带给您同样出色的体验。</p><h3>设备状况</h3><ul><li><strong>屏幕</strong>：无裂纹或刮痕，显示清晰明亮。</li><li><strong>背面及边框</strong>：轻微使用痕迹，不影响整体美观。</li><li><strong>摄像头</strong>：拍摄效果出色，无模糊或损坏。</li><li><strong>电池健康度</strong>：超过80%，剩余寿命充足。</li><li><strong>软件</strong>：运行 iOS 15.x 版本，无越狱或其他非法操作。</li><li><strong>配件</strong>：附带原装充电线和适配器（如有）</li></ul><h3>交易说明</h3><ul><li><strong>价格</strong>：由于是二手商品，价格比全新版本优惠很多。</li><li><strong>保修期</strong>：无官方保修，但我会提供一周内无理由退换货保障。</li><li><strong>支付方式</strong>：支持支付宝、微信支付等多种付款方式。</li><li><strong>配送</strong>：全国包邮，采用顺丰快递，确保安全送达。</li></ul>', '北京市朝阳区', 'http://localhost:9090/files/ipone.png', '2024-09-24 00:00:00', '通过', '数码电子', 1, '上架', 34, NULL, NULL, 0, 0, 0, 0);
INSERT INTO `goods` VALUES (3, '苹果 iPhone 13', 4000.00, '<h3>商品概述</h3><p>这是一部经过精心保养的二手iPhone 13 Pro Max，外观成色良好，无明显划痕或磨损。设备功能正常，所有硬件组件均处于良好的工作状态。这部手机已解锁，可兼容任何运营商网络。我正在寻找一位对这款设备感兴趣的买家，希望它能带给您同样出色的体验。</p><h3>设备状况</h3><ul><li><strong>屏幕</strong>：无裂纹或刮痕，显示清晰明亮。</li><li><strong>背面及边框</strong>：轻微使用痕迹，不影响整体美观。</li><li><strong>摄像头</strong>：拍摄效果出色，无模糊或损坏。</li><li><strong>电池健康度</strong>：超过80%，剩余寿命充足。</li><li><strong>软件</strong>：运行 iOS 15.x 版本，无越狱或其他非法操作。</li><li><strong>配件</strong>：附带原装充电线和适配器（如有）</li></ul><h3>交易说明</h3><ul><li><strong>价格</strong>：由于是二手商品，价格比全新版本优惠很多。</li><li><strong>保修期</strong>：无官方保修，但我会提供一周内无理由退换货保障。</li><li><strong>支付方式</strong>：支持支付宝、微信支付等多种付款方式。</li><li><strong>配送</strong>：全国包邮，采用顺丰快递，确保安全送达。</li></ul>', '北京市朝阳区', 'http://localhost:9090/files/ipone.png', '2024-09-23 00:00:00', '通过', '数码电子', 1, '上架', 30, NULL, NULL, 0, 0, 0, 0);
INSERT INTO `goods` VALUES (4, '二手Apple AirPods Pro无线耳机', 500.00, '<p># Apple AirPods Pro 无线蓝牙耳机\n\n- **品牌**：Apple\n- **型号**：AirPods Pro\n- **颜色**：白色\n- **成色**：九五成新\n- **功能**：主动降噪、透明模式、触摸控制、防水防汗\n- **配件**：充电盒、耳塞（S/M/L三副）、数据线\n\n这款AirPods Pro是我去年购买的，一直很爱惜，几乎每天都用，但由于最近换了新款，所以打算出掉。耳机没有任何损伤，音质和降噪效果都非常棒。充电盒电量足，续航持久。\n\n![AirPods Pro实物图]()\n\n价格可小刀，有意者私聊，非诚勿扰。支持当面交易或者邮寄，运费自理。<br/></p>', '北京市朝阳区', 'http://localhost:9090/files/airpod.png', '2024-09-23 00:00:00', '通过', '数码电子', 2, '上架', 11, NULL, NULL, 0, 0, 0, 0);
INSERT INTO `goods` VALUES (5, '二手Apple AirPods无线耳机', 400.00, '<p># Apple AirPods Pro 无线蓝牙耳机\n\n- **品牌**：Apple\n- **型号**：AirPods Pro\n- **颜色**：白色\n- **成色**：九五成新\n- **功能**：主动降噪、透明模式、触摸控制、防水防汗\n- **配件**：充电盒、耳塞（S/M/L三副）、数据线\n\n这款AirPods Pro是我去年购买的，一直很爱惜，几乎每天都用，但由于最近换了新款，所以打算出掉。耳机没有任何损伤，音质和降噪效果都非常棒。充电盒电量足，续航持久。\n\n![AirPods Pro实物图]()\n\n价格可小刀，有意者私聊，非诚勿扰。支持当面交易或者邮寄，运费自理。<br/></p>', '北京市朝阳区', 'http://localhost:9090/files/airpod.png', '2024-09-23 00:00:00', '通过', '数码电子', 2, '上架', 19, NULL, NULL, 0, 0, 0, 0);
INSERT INTO `goods` VALUES (14, '喝了一半的东方树叶', 100.00, '<p>1111</p>', '长沙市岳麓区', 'http://localhost:9090/files/喝了一半的东方树叶.jpg', '2025-05-06 12:47:22', '拒绝', '饮食', 5, '上架', 0, NULL, NULL, 0, 0, 0, 0);
INSERT INTO `goods` VALUES (55, 'iPhone 15 Pro', 8999.00, '<p><strong>最新款苹果旗舰手机</strong></p><p>配置：</p><ul><li>A17 Pro芯片</li><li>6.1英寸超视网膜XDR显示屏</li><li>4800万像素主摄像头</li><li>钛金属边框</li></ul>', '北京市海淀区', 'http://localhost:9090/files/苹果15 pro.png', '2025-05-04 10:00:00', '通过', '数码电子', 5, '上架', 90, NULL, NULL, 0, 0, 42, 35);
INSERT INTO `goods` VALUES (73, '智能手环', 199.00, '<p><strong>多功能健康监测手环</strong></p><ul><li>心率/血氧监测</li><li>睡眠分析</li><li>50米防水</li><li>14天续航</li></ul>', '武汉市洪山区', 'http://localhost:9090/files/智能手环.png', '2025-05-04 18:00:00', '通过', '数码电子', 5, '上架', 87, NULL, NULL, 0, 0, 53, 41);
INSERT INTO `goods` VALUES (72, '全棉四件套', 369.00, '<p><b>1.8米床纯棉四件套</b></p><p>包含：被套*1+床单*1+枕套*2</p><p>材质：100%新疆长绒棉</p><p>工艺：活性印染</p>', '南通市崇川区', 'http://localhost:9090/files/全棉四件套.png', '2025-05-04 17:20:00', '通过', '家居', 5, '上架', 30, NULL, NULL, 0, 0, 17, 11);
INSERT INTO `goods` VALUES (71, '无线蓝牙耳机', 299.00, '<div><h3>主动降噪蓝牙耳机</h3><p>特点：</p><ul><li>ANC主动降噪</li><li>30小时续航</li><li>IPX5防水</li><li>触控操作</li></ul></div>', '东莞市长安镇', 'http://localhost:9090/files/无线蓝牙耳机.png', '2025-05-04 12:40:00', '通过', '数码电子', 5, '上架', 71, NULL, NULL, 0, 0, 48, 36);
INSERT INTO `goods` VALUES (70, '不锈钢保温杯', 89.00, '<p><strong>480ml大容量保温杯</strong></p><ul><li>304不锈钢材质</li><li>保热24小时</li><li>一键开盖</li><li>多色可选</li></ul>', '宁波市鄞州区', 'http://localhost:9090/files/不锈钢保温杯.png', '2025-05-04 15:30:00', '通过', '日用百货', 5, '上架', 62, NULL, NULL, 0, 0, 31, 22);
INSERT INTO `goods` VALUES (69, '云南普洱茶饼', 280.00, '<p><i>2018年陈年普洱</i></p><p>规格：357g/饼</p><p>产地：云南西双版纳</p><p>存储条件：清洁、通风、避光</p>', '昆明市官渡区', 'http://localhost:9090/files/云南普洱茶饼.png', '2025-05-04 13:10:00', '通过', '饮食', 5, '上架', 45, NULL, NULL, 0, 0, 23, 15);
INSERT INTO `goods` VALUES (68, '智能跑步机', 3299.00, '<div><h4>家用折叠跑步机</h4><p>特点：</p><ol><li>15.6寸触控屏</li><li>静音马达</li><li>最大承重120kg</li><li>APP互联</li></ol></div>', '深圳市南山区', 'http://localhost:9090/files/智能跑步机.png', '2025-05-04 16:45:00', '通过', '运动', 5, '上架', 78, NULL, NULL, 0, 0, 39, 27);
INSERT INTO `goods` VALUES (67, '男士休闲衬衫', 199.00, '<p><b>春季新款男士衬衫</b></p><ul><li>100%纯棉</li><li>修身版型</li><li>多色可选：白色/蓝色/灰色</li><li>尺码：S-XXL</li></ul>', '广州市天河区', 'http://localhost:9090/files/男士休闲衬衫.png', '2025-05-04 14:20:00', '待审核', '服饰', 5, '上架', 34, NULL, NULL, 0, 0, 12, 8);
INSERT INTO `goods` VALUES (66, 'Java核心技术卷一', 108.00, '<p><span style=\"color:#f40\">经典编程书籍第11版</span></p><p>作者：Cay S. Horstmann</p><p>出版社：机械工业出版社</p><p>包含Java最新特性讲解</p>', '杭州市西湖区', 'http://localhost:9090/files/Java核心技术卷一.png', '2025-05-04 09:15:00', '通过', '书籍', 5, '上架', 94, NULL, NULL, 0, 0, 65, 47);
INSERT INTO `goods` VALUES (65, '北欧风格沙发', 2599.00, '<div style=\"color:#333\"><h3>简约北欧风布艺沙发</h3><p>材质：优质棉麻面料+高密度海绵</p><p>尺寸：2.2米三人位</p><p>颜色：浅灰色/深蓝色可选</p></div>', '上海市浦东新区', 'http://localhost:9090/files/北欧风格沙发.png', '2025-05-04 11:30:00', '通过', '家居', 5, '上架', 56, NULL, NULL, 0, 0, 28, 19);

-- ----------------------------
-- Table structure for help
-- ----------------------------
DROP TABLE IF EXISTS `help`;
CREATE TABLE `help`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `img` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  `time` datetime NULL DEFAULT NULL,
  `solved` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 9 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of help
-- ----------------------------
INSERT INTO `help` VALUES (1, '二手笔记本电脑求购', '本人欲求购一台二手笔记本电脑，要求如下：\n\n处理器：Intel Core i5 或更高\n内存：至少 8GB RAM\n存储：SSD，容量大于 256GB\n显卡：独立显卡，NVIDIA GeForce GTX 1050 及以上\n屏幕尺寸：15.6 英寸及以上\n系统：Windows 10 或 macOS\n成色：外观良好，无明显划痕或破损\n价格范围：不超过 3000 元人民币\n如果有符合以上条件的笔记本电脑，请联系我，谢谢！', 'http://localhost:9090/files/拯救者笔记本.png', '通过', 1, '2024-09-23 10:19:32', '已解决');
INSERT INTO `help` VALUES (2, '二手单反相机求购', '我想购买一款二手单反相机，具体要求如下：\n\n品牌：佳能或尼康\n型号：佳能 EOS 80D 或尼康 D7500\n镜头：18-135mm 或类似套装\n快门次数：低于 5,000 次\n包装：完整包装，包括相机、镜头、电池、充电器、说明书等\n成色：外观良好，无明显划痕或破损\n价格范围：不超过 4000 元人民币\n如果有符合条件的相机，请联系我，非常感谢！', 'http://localhost:9090/files/单反相机.png', '通过', 1, '2025-04-25 10:20:57', '未解决');
INSERT INTO `help` VALUES (4, '摄影爱好者诚意求购佳能大三元镜头', '致各位摄影同好：\r\n\r\n作为刚入行的人像摄影师，现诚意求购一支成色良好的佳能EF 24-70mm f2.8L II USM镜头。这支\"大三元\"中的标准变焦镜头是我目前设备链中最关键的一环。\r\n\r\n【专业要求】\r\n◇ 镜片状况：前后镜组无霉、无划、无脱膜\r\n◇ 机械性能：变焦环阻尼适中，无松动；对焦迅速准确\r\n◇ 外观：镜身字迹清晰，橡胶环无老化\r\n◇ 配件：原装前后盖、遮光罩（最好有镜头包）\r\n\r\n【交易细节】\r\n▷ 理想价格区间：5500-6500元（视成色浮动）\r\n▷ 可提供我的5D4作为测试机身\r\n▷ 支持任何形式的专业检测\r\n▷ 同城优先（可约在相机店验货）\r\n\r\n附：如果您恰好要升级RF系统而出售EF镜头，我也可以考虑搭配转接环的方案。期待与您交流摄影心得！', 'http://localhost:9090/files/佳能大三元.png', '通过', 9, '2025-05-15 14:30:00', '未解决');
INSERT INTO `help` VALUES (3, '毕业设计急需！求购高性能游戏笔记本', '各位校友好！我是一名数字媒体专业的大四学生，正在为毕业设计寻找一台性能足够的笔记本。因为要处理4K视频剪辑和3D渲染，希望能求购一台满足以下要求的游戏本：\r\n\r\n【核心配置】\r\n★ 处理器：Intel i7-10750H或AMD Ryzen 7 4800H及以上\r\n★ 显卡：RTX 3060 6G及以上，最好是满血版\r\n★ 内存：16GB DDR4（最好可扩展）\r\n★ 存储：512GB NVMe SSD（有额外硬盘位更佳）\r\n★ 屏幕：15.6英寸/17.3英寸，144Hz高刷，100%sRGB色域\r\n\r\n【其他要求】\r\n✓ 机身无明显磕碰，屏幕无坏点\r\n✓ 电池健康度80%以上\r\n✓ 箱说全、带原装电源\r\n✓ 最好剩余保修期\r\n\r\n【心路历程】\r\n已经对比了新品价格，但作为学生预算实在有限（6000-8000元）。如果您正好有闲置的\"战友\"，请联系我！可以上门验机，坐标大学城附近。期待能遇到有缘的\"它\"，助我顺利完成毕业设计！', 'http://localhost:9090/files/高性能笔记本.jpg', '通过', 5, '2025-05-16 10:15:00', '未解决');
INSERT INTO `help` VALUES (5, '学弟紧急求助！求购《数据结构》经典教材', '亲爱的学长学姐们：\r\n\r\n我是计算机系大二学生小王。上周不慎将图书馆借阅的《数据结构与算法分析》（Mark Allen Weiss著，C语言版）遗失，面临三倍赔偿！现紧急求购同版本教材救急。\r\n\r\n【教材详情】\r\n• 书名：Data Structures and Algorithm Analysis in C\r\n• ISBN：978-7-111-45367-6\r\n• 理想版本：第二版及以上\r\n\r\n【特别说明】\r\n☆ 希望书内有少量笔记（正好学习前辈心得）\r\n☆ 若有配套习题解答更好\r\n☆ 价格可议（学校书店新书定价89元）\r\n\r\n【情感牌】\r\n记得开学时看到很多学长在出旧书，现在才体会到\"书到用时方恨少\"。如果您恰好有这本\"计算机系圣经\"闲置，请给我一个补救的机会！可以在图书馆、教学楼等地交接，奶茶答谢！', 'http://localhost:9090/files/数据结构.jpg', '通过', 2, '2025-05-14 18:45:00', '未解决');
INSERT INTO `help` VALUES (6, '寻找骑行伙伴！求购入门级山地车', '致校园骑行爱好者：\r\n\r\n想加入学校的\"环湖骑行社\"，急需一辆靠谱的二手山地车。作为骑行新手，经过社团前辈推荐，希望能找到这样一辆车：\r\n\r\n【理想配置】\r\n☑ 车架：捷安特ATX系列或美利达勇士系列（17寸车架）\r\n☑ 变速：Shimano Altus及以上级别变速系统\r\n☑ 刹车：油压碟刹优先\r\n☑ 轮胎：27.5英寸齿胎\r\n\r\n【特别期待】\r\n▶ 带码表、水壶架等配件可适当加价\r\n▶ 最好有近期保养记录\r\n▶ 可接受轻微使用痕迹\r\n\r\n【我的故事】\r\n预算800-1200元，是勤工俭学攒下的。记得去年常在校园看到毕业学长出车，现在轮到我寻找\"人生第一辆战驹\"了。如果您有用爱车，请联系我！周末可看车，坐标学生公寓7号楼。', 'http://localhost:9090/files/自行车.jpg', '通过', 1, '2025-05-13 09:20:00', '未解决');
INSERT INTO `help` VALUES (7, '音乐社萌新求购雅马哈FG800吉他', '亲爱的校园音乐人：\r\n\r\n我是吉他社新成员小林，在上了三节体验课后，决定认真学琴。经老师推荐，现求购一把雅马哈FG800作为入门琴。\r\n\r\n【求购详情】\r\n✓ 型号：Yamaha FG800原声吉他（41寸）\r\n✓ 期望状态：无开裂、琴颈笔直、品丝平整\r\n✓ 配件：原装琴包/琴盒更佳\r\n✓ 心理价位：1000-1500元（视配件情况）\r\n\r\n【学习故事】\r\n• 每周三跟着社团在湖畔练习\r\n• 目前能弹《成都》前奏\r\n• 老师说这把琴是\"千元面单天花板\"\r\n\r\n特别希望能遇到一位细心保养琴的前主人。如果您要升级设备或者毕业离校，请考虑将爱琴托付给一个会珍惜它的新手！可以约在音乐社活动室验琴。', 'http://localhost:9090/files/雅马哈.jpg', '通过', 5, '2025-05-12 16:50:00', '未解决');

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `fid` int NOT NULL,
  `user_id` int NOT NULL,
  `module` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 24 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of likes
-- ----------------------------
INSERT INTO `likes` VALUES (1, 5, 1, 'goods');
INSERT INTO `likes` VALUES (2, 3, 2, 'goods');
INSERT INTO `likes` VALUES (13, 2, 2, 'goods');
INSERT INTO `likes` VALUES (22, 1, 2, 'goods');
INSERT INTO `likes` VALUES (23, 5, 9, 'goods');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `time` datetime NULL DEFAULT NULL,
  `user` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 10 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES (2, '关于近期平台维护的通知', '尊敬的同学们，\n\n大家好！为了给大家提供更好的服务，我们的校园二手交易平台将于本月末进行一次系统维护升级。在此期间，平台的部分功能可能会受到影响，包括但不限于商品发布、搜索和交易等功能。\n\n维护时间定于本月最后一个星期六凌晨2点至早上8点。在这段时间里，平台将暂时无法访问。请大家提前做好相关安排，避免不必要的困扰。\n\n维护结束后，我们将以全新的面貌为大家带来更加流畅、便捷的服务。感谢大家的理解和支持，让我们一起期待更好的校园二手交易平台吧！\n\n如有疑问或紧急需求，请联系我们的客服团队，我们会尽力协助解决。\n\n顺祝商祺，\n校园二手交易平台管理团队', '2025-05-12 14:25:33', 'admin');
INSERT INTO `notice` VALUES (3, '夏季促销活动公告', '亲爱的用户们，\n\n随着冬天的到来，我们特别推出冬季促销活动！即日起至年底，凡是在平台上购买任意二手商品，均可享受满200减20的优惠。此外，如果您推荐朋友注册并完成首次交易，双方都将获得额外的50元代金券奖励。\n\n请注意，每个账号仅限使用一次优惠券，不可与其他折扣叠加使用。更多详情请参见活动规则页面。祝大家购物愉快！\n\n有任何问题，欢迎随时联系我们。祝大家在这个冬季找到心仪的好物！\n\n校园二手交易平台管理团队', '2025-05-01 13:30:00', 'admin');
INSERT INTO `notice` VALUES (4, '平台新增功能介绍', '各位同学，\n\n很高兴告诉大家，我们的校园二手交易平台已经上线了两个新的功能——“一键估价”和“预约看货”。\n\n“一键估价”：只需上传商品照片和简单描述，系统即可自动评估其价值，方便快捷；\n“预约看货”：买家可以在线预约看货时间，减少来回奔波，提高交易效率。\n欢迎大家积极使用这两个新功能，提升交易体验。如有任何建议或问题，欢迎随时向我们反馈。\n\n祝大家交易顺利！\n\n校园二手交易平台管理团队', '2025-04-04 12:00:00', 'admin');
INSERT INTO `notice` VALUES (7, '平台正式发布运行了！', '<p>尊敬的各位用户：</p><p>经过团队的不懈努力，悠享二手交易平台于今日正式上线运营。本平台采用SpringBoot+Vue技术架构，致力于为广大人民群众提供安全、便捷的二手交易服务。</p><p><strong>平台主要功能：</strong></p><ol><li>商品交易：支持各类二手物品发布与交易</li><li>悬赏求购：可发布求购信息，等待卖家响应</li><li>社区互动：提供用户交流讨论空间</li><li>即时通讯：内置聊天功能方便买卖双方沟通</li></ol><p><strong>上线优惠活动：</strong></p><ul><li>新用户注册可获得50元优惠券</li><li>首月交易免手续费</li><li>每日前10名完成交易的用户可获得额外积分</li></ul><p><strong>注意事项：</strong></p><ol><li>请妥善保管账号密码</li><li>交易时请选择平台提供的安全支付方式</li><li>如遇问题可通过平台反馈渠道联系我们</li></ol><p>悠享运营团队\n2025年5月12日</p>', '2025-04-01 00:00:00', 'admin');

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `goods_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `goods_img` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `order_no` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `total` decimal(10, 2) NOT NULL,
  `time` datetime NULL DEFAULT NULL,
  `pay_no` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `pay_time` datetime NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  `address` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `sale_id` int NULL DEFAULT NULL,
  `address_id` int NULL DEFAULT NULL,
  `goods_id` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 50 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (49, '苹果 iPhone 13', 'http://localhost:9090/files/ipone.png', '17474009183188823615', 4000.00, '2025-05-16 21:08:38', 'PAY1747400925781688195', '2025-05-16 21:08:45', 5, '湖南工商大学', '15897361469', '待发货', 1, 8, 3);
INSERT INTO `orders` VALUES (48, '苹果 iPhone 13 Pro', 'http://localhost:9090/files/ipone.png', '17474009082375975931', 4500.00, '2025-05-16 21:08:28', NULL, NULL, 5, '湖南工商大学', '15897361469', '已取消', 1, 8, 2);
INSERT INTO `orders` VALUES (47, '二手Apple AirPods无线耳机', 'http://localhost:9090/files/airpod.png', '17474008938794391958', 400.00, '2025-05-16 21:08:13', 'PAY1747400901232344006', '2025-05-16 21:08:21', 5, '湖南工商大学', '15897361469', '待发货', 2, 8, 5);
INSERT INTO `orders` VALUES (46, '二手Apple AirPods Pro无线耳机', 'http://localhost:9090/files/airpod.png', '17474008860165706079', 500.00, '2025-05-16 21:08:06', NULL, NULL, 5, '湖南工商大学', '15897361469', '已取消', 2, 8, 4);
INSERT INTO `orders` VALUES (45, '二手Apple AirPods Pro无线耳机', 'http://localhost:9090/files/airpod.png', '17473960221670615714', 500.00, '2025-05-16 19:47:02', 'PAY1747396035165188123', '2025-05-16 19:47:15', 5, '湖南工商大学', '15897361469', '待发货', 2, 8, 4);
INSERT INTO `orders` VALUES (43, '苹果 iPhone 13 Pro Max', 'http://localhost:9090/files/ipone.png', '17473959851830032051', 5000.00, '2025-05-16 19:46:25', NULL, NULL, 5, '湖南工商大学', '15897361469', '已取消', 1, 8, 1);
INSERT INTO `orders` VALUES (44, '苹果 iPhone 13 Pro', 'http://localhost:9090/files/ipone.png', '17473959948419412120', 4500.00, '2025-05-16 19:46:34', 'PAY1747396003564618528', '2025-05-16 19:46:43', 5, '湖南工商大学', '15897361469', '待发货', 1, 8, 2);

-- ----------------------------
-- Table structure for posts
-- ----------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `img` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  `time` datetime NULL DEFAULT NULL,
  `circle` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `descr` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `read_count` int NULL DEFAULT 0,
  `status` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 13 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of posts
-- ----------------------------
INSERT INTO `posts` VALUES (7, '考研数学复习计划', '<p>准备26考研，制定了数学复习计划：</p><ol><li>第一阶段：基础知识点梳理(3个月)</li><li>第二阶段：专题强化训练(2个月)</li><li>第三阶段：真题模拟冲刺(1个月)</li></ol><p>求研友一起监督打卡！</p>', 'http://localhost:9090/files/考研数学.jpg', 9, '2025-05-12 14:30:00', '学习圈', '考研数学复习经验交流', 80, '通过');
INSERT INTO `posts` VALUES (8, 'LOL新版本英雄强度分析', '<p>12.5版本更新后英雄强度变化：</p><p>上单：剑姬、格温T0</p><p>打野：佛耶戈、赵信强势</p><p>中单：维克托、阿狸</p><p>下路：厄斐琉斯、金克丝</p><p>辅助：锤石、泰坦</p><p>大家觉得这个版本平衡性如何？</p>', 'http://localhost:9090/files/lol.jpg', 2, '2025-05-15 20:45:00', '电竞圈', 'LOL新版本英雄强度讨论', 117, '通过');
INSERT INTO `posts` VALUES (9, '《流浪地球3》观后感', '<p>刚看完《流浪地球2》，特效依然震撼！</p><p>优点：</p><ul><li>太空电梯场景惊艳</li><li>数字生命计划有新意</li><li>吴京演技在线</li></ul><p>不足：</p><ul><li>部分剧情转折生硬</li><li>新角色塑造不够深入</li></ul><p>总体8.5/10，值得一看！</p>', 'http://localhost:9090/files/流浪地球2.jpg', 1, '2025-05-14 19:20:00', '影视圈', '流浪地球2观影感受', 97, '通过');
INSERT INTO `posts` VALUES (3, '《红楼梦》读书笔记', '<p>大家好！我刚刚开始阅读《红楼梦》，虽然只看了一部分，但是我已经有了很多感悟。今天我想跟大家分享一下我对林黛玉这个人物的理解...\n\n在我看来，林黛玉是一个非常复杂的人物。她聪明、敏感，同时又有些许忧郁。她的诗词才华让我惊叹不已，而她在贾府中的处境又让人感到同情。我希望我们能一起讨论这个角色以及书中其他的角色和情节。\n\n另外，我还拍了一张我正在阅读《红楼梦》的照片，大家可以看看。这本书真的值得一读！\n期待你们的回复！<br/></p>', 'http://localhost:9090/files/红楼梦.png', 1, '2024-09-23 10:49:38', '阅读圈', '最近我在阅读《红楼梦》，发现这本书非常精彩，有很多值得探讨的地方。我想通过这篇帖子分享我的一些读书笔记和思考。', 5, '通过');
INSERT INTO `posts` VALUES (4, '周末跑步计划', '<p>大家好！我是新来的，一直热爱运动，特别是跑步。我发现我们的圈子很活跃，所以决定发起一个周末跑步计划。\n\n每周六早上8点，我会在公园集合，邀请大家一起参加晨跑。希望这不仅能帮助我们保持健康，还能结交志同道合的朋友。\n\n如果有任何建议或者想法，请随时留言。期待见到你们！\n<br/></p>', 'http://localhost:9090/files/跑步.png', 1, '2024-09-23 10:51:04', '健身圈', '让我们一起动起来！', 5, '通过');
INSERT INTO `posts` VALUES (5, '自制披萨大挑战', '<p>大家好！我一直都是个披萨迷，尝试过各种口味。最近，我决定自己动手做披萨，结果出乎意料的好吃！\n\n步骤很简单：&nbsp;</p><p>1. 准备面团...\n2. 添加配料...\n3. 烤箱预热至200度，烤15分钟...&nbsp;</p><p>&nbsp;这就是我的成果，看起来是不是很有食欲？\n\n如果你也喜欢披萨，不妨试试看。期待看到你们的作品！<br/></p>', 'http://localhost:9090/files/披萨.png', 1, '2025-04-24 10:52:06', '美食圈', '谁说外卖比萨最好吃？我自己做的才最棒！', 37, '通过');
INSERT INTO `posts` VALUES (6, 'Java学习心得分享', '<p>最近系统学习了Java集合框架，分享一下我的学习笔记：</p><ul><li>ArrayList基于动态数组实现，查询快增删慢</li><li>LinkedList基于双向链表，增删快查询慢</li><li>HashMap采用数组+链表+红黑树结构</li></ul><p>大家有什么学习技巧可以一起交流！</p>', 'http://localhost:9090/files/java学习心得.jpg', 5, '2025-05-10 09:15:00', '学习圈', 'Java集合框架学习经验分享', 48, '通过');
INSERT INTO `posts` VALUES (10, '四月新番推荐', '<p>本季值得追的新番：</p><ol><li>《我推的孩子》- 悬疑+偶像题材</li><li>《天国大魔境》- 科幻冒险</li><li>《地狱乐》- 黑暗战斗</li><li>《跃动青春》- 校园治愈</li></ol><p>大家在看哪些？求推荐！</p>', 'http://localhost:9090/files/四月新番.jpg', 9, '2025-05-13 18:10:00', '二次元圈', '四月新番观看指南', 68, '通过');
INSERT INTO `posts` VALUES (11, '三个月健身成果', '<p>坚持健身三个月的变化：</p><p>体重：75kg → 68kg</p><p>体脂：22% → 15%</p><p>三大项成绩：</p><ul><li>深蹲：60kg → 100kg</li><li>卧推：40kg → 70kg</li><li>硬拉：80kg → 120kg</li></ul><p>继续努力，目标体脂12%！</p>', 'http://localhost:9090/files/健身.png', 5, '2025-05-11 07:30:00', '健身圈', '健身三个月成果分享', 85, '通过');
INSERT INTO `posts` VALUES (12, '家常红烧肉做法', '<p>分享我家祖传红烧肉秘方：</p><ol><li>五花肉切块冷水下锅焯水</li><li>炒糖色至琥珀色</li><li>加入香料：八角、桂皮、香叶</li><li>小火慢炖1.5小时</li><li>收汁前加少许醋提鲜</li></ol><p>这样做出来的红烧肉肥而不腻！</p>', 'http://localhost:9090/files/红烧肉.png', 2, '2025-05-09 12:00:00', '美食圈', '家常红烧肉烹饪技巧', 59, '通过');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `register_time` timestamp NULL DEFAULT NULL COMMENT '用户注册时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 11 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'miaomiao', '123', '猫猫头', '17512341234', '123@qq.com', 'http://localhost:9090/files/cat.png', 'USER', '2025-01-01 14:32:18');
INSERT INTO `user` VALUES (2, 'wangwang', '123', '大狗叫', '13520109201', '123@qq.com', 'http://localhost:9090/files/dog.png', 'USER', '2025-02-11 14:32:18');
INSERT INTO `user` VALUES (10, 'zkk', 'xiao123', 'zkk', '19976652444', '123@qq.com', NULL, 'USER', '2025-05-16 19:02:04');
INSERT INTO `user` VALUES (5, 'chikengogogo', 'xiaosun123', '叮咚鸡', '15897361462', '1522457459@qq.com', 'http://localhost:9090/files/叮咚鸡.png', 'USER', '2025-05-08 14:32:18');
INSERT INTO `user` VALUES (9, 'sum1ght', 'xiao123', '晴夜', '15897361461', '1522457459@qq.com', 'http://localhost:9090/files/狐狸.png', 'USER', '2025-05-16 14:32:18');

SET FOREIGN_KEY_CHECKS = 1;
