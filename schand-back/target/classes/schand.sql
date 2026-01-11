/*
Navicat MySQL Data Transfer

Source Server         : mysql8
Source Server Version : 80012
Source Host           : localhost:3306
Source Database       : secondhand

Target Server Type    : MYSQL
Target Server Version : 80012
File Encoding         : 65001

Date: 2024-09-23 14:17:31
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES ('1', '张三', '河南省郑州市中原区', '13520109202', '2');
INSERT INTO `address` VALUES ('2', '张三', '河南省开封市鼓楼区XX街道XX小区X号楼X单元XXX室', '13520109202', '2');
INSERT INTO `address` VALUES ('3', '李四', '河南省郑州市中原区中原路100号', '18634208045', '1');
INSERT INTO `address` VALUES ('4', '李四', '河南省郑州市中原区无名小区', '18634208045', '1');
INSERT INTO `address` VALUES ('5', '李四', '河北', '17512341234', '3');

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES ('1', 'admin', '123456', '管理员', '18634208045', '123@qq.com', 'http://localhost:9090/files/1727056854376-curr-user.png', 'ADMIN');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES ('1', '电子产品');
INSERT INTO `category` VALUES ('2', '家居用品');
INSERT INTO `category` VALUES ('3', '书籍');
INSERT INTO `category` VALUES ('4', '服装与配饰');
INSERT INTO `category` VALUES ('5', '运动与户外');

-- ----------------------------
-- Table structure for chat_group
-- ----------------------------
DROP TABLE IF EXISTS `chat_group`;
CREATE TABLE `chat_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_user_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of chat_group
-- ----------------------------
INSERT INTO `chat_group` VALUES ('1', '2', '1');
INSERT INTO `chat_group` VALUES ('2', '1', '2');
INSERT INTO `chat_group` VALUES ('3', '1', '3');
INSERT INTO `chat_group` VALUES ('4', '3', '1');

-- ----------------------------
-- Table structure for chat_info
-- ----------------------------
DROP TABLE IF EXISTS `chat_info`;
CREATE TABLE `chat_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_user_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `text` text,
  `isread` char(1) DEFAULT 'N',
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of chat_info
-- ----------------------------
INSERT INTO `chat_info` VALUES ('1', '2', '1', '你好', '是', '2024-09-23 10:55:22');
INSERT INTO `chat_info` VALUES ('2', '2', '1', '耳机还在吗？\n', '是', '2024-09-23 10:55:35');
INSERT INTO `chat_info` VALUES ('3', '1', '2', '在的', '是', '2024-09-23 10:56:02');
INSERT INTO `chat_info` VALUES ('4', '1', '3', '你好', '是', '2024-09-23 10:57:41');
INSERT INTO `chat_info` VALUES ('5', '1', '3', '你好手机还在吗？\n', '是', '2024-09-23 10:59:16');
INSERT INTO `chat_info` VALUES ('6', '3', '1', '你好', '是', '2024-09-23 11:19:40');
INSERT INTO `chat_info` VALUES ('7', '1', '3', '你好', 'N', '2024-09-23 14:11:58');

-- ----------------------------
-- Table structure for circles
-- ----------------------------
DROP TABLE IF EXISTS `circles`;
CREATE TABLE `circles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `img` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of circles
-- ----------------------------
INSERT INTO `circles` VALUES ('1', 'http://localhost:9090/files/1727056973418-remind-fill.png', '二手图书圈');
INSERT INTO `circles` VALUES ('2', 'http://localhost:9090/files/1727059273416-Snipaste_2024-09-23_10-41-00.png', '书友会');
INSERT INTO `circles` VALUES ('3', 'http://localhost:9090/files/1727059329001-Snipaste_2024-09-23_10-42-02.png', '运动爱好者');
INSERT INTO `circles` VALUES ('4', 'http://localhost:9090/files/1727059387963-Snipaste_2024-09-23_10-43-01.png', '美食分享圈');

-- ----------------------------
-- Table structure for collect
-- ----------------------------
DROP TABLE IF EXISTS `collect`;
CREATE TABLE `collect` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fid` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `module` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of collect
-- ----------------------------
INSERT INTO `collect` VALUES ('1', '5', '1', 'goods');
INSERT INTO `collect` VALUES ('2', '3', '2', 'goods');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `pid` int(11) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `fid` int(11) DEFAULT NULL,
  `module` varchar(255) NOT NULL,
  `root_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES ('1', '有图片吗？', '2', null, '2024-09-23 10:30:55', '2', 'posts', '1');
INSERT INTO `comment` VALUES ('2', '有图片吗？\n', '2', null, '2024-09-23 10:31:14', '1', 'posts', '2');
INSERT INTO `comment` VALUES ('3', '你好', '2', null, '2024-09-23 10:31:26', '2', 'help', '3');
INSERT INTO `comment` VALUES ('4', '你好', '2', null, '2024-09-23 10:31:31', '1', 'help', '4');
INSERT INTO `comment` VALUES ('5', '你好', '3', null, '2024-09-23 10:59:33', '2', 'help', '5');
INSERT INTO `comment` VALUES ('6', '你好', '1', '5', '2024-09-23 11:19:15', '2', 'help', '5');
INSERT INTO `comment` VALUES ('11', '你好', '3', null, '2024-09-23 14:14:13', '2', 'help', '11');
INSERT INTO `comment` VALUES ('12', '你好', '3', null, '2024-09-23 14:14:23', '5', 'posts', '12');

-- ----------------------------
-- Table structure for feedback
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `reply` text,
  `createtime` datetime DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of feedback
-- ----------------------------
INSERT INTO `feedback` VALUES ('1', '网站登录问题', '我在尝试登录网站时遇到了一些问题。每次输入正确的用户名和密码后，都会收到错误提示：“账户名或密码错误”。我已经多次重试并确认了我的输入是正确的，所以我认为可能是系统出现了故障。我希望你们能够调查一下这个问题，并尽快修复。谢谢！', '18634208045', '123@qq.com', '目前已经修复好了', '2024-09-23 10:25:38', '1');
INSERT INTO `feedback` VALUES ('2', '测试', '测试', '18634208045', '123@qq.com', null, '2024-09-23 14:14:41', '3');

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `content` text,
  `address` varchar(255) DEFAULT NULL,
  `img` varchar(255) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `sale_status` varchar(50) DEFAULT NULL,
  `read_count` int(11) DEFAULT '0',
  `user_name` varchar(255) DEFAULT NULL,
  `sort` varchar(255) DEFAULT NULL,
  `user_likes` tinyint(1) DEFAULT '0',
  `user_collect` tinyint(1) DEFAULT '0',
  `likes_count` int(11) DEFAULT '0',
  `collect_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES ('1', '苹果 iPhone 13 Pro Max', '5000.00', '<h3>商品概述</h3><p>这是一部经过精心保养的二手iPhone 13 Pro Max，外观成色良好，无明显划痕或磨损。设备功能正常，所有硬件组件均处于良好的工作状态。这部手机已解锁，可兼容任何运营商网络。我正在寻找一位对这款设备感兴趣的买家，希望它能带给您同样出色的体验。</p><h3>设备状况</h3><ul><li><strong>屏幕</strong>：无裂纹或刮痕，显示清晰明亮。</li><li><strong>背面及边框</strong>：轻微使用痕迹，不影响整体美观。</li><li><strong>摄像头</strong>：拍摄效果出色，无模糊或损坏。</li><li><strong>电池健康度</strong>：超过80%，剩余寿命充足。</li><li><strong>软件</strong>：运行 iOS 15.x 版本，无越狱或其他非法操作。</li><li><strong>配件</strong>：附带原装充电线和适配器（如有）</li></ul><h3>交易说明</h3><ul><li><strong>价格</strong>：由于是二手商品，价格比全新版本优惠很多。</li><li><strong>保修期</strong>：无官方保修，但我会提供一周内无理由退换货保障。</li><li><strong>支付方式</strong>：支持支付宝、微信支付等多种付款方式。</li><li><strong>配送</strong>：全国包邮，采用顺丰快递，确保安全送达。</li></ul>', '北京市朝阳区', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '2024-09-23 00:00:00', '通过', '电子产品', '1', '上架', '5', null, null, '0', '0', '0', '0');
INSERT INTO `goods` VALUES ('2', '苹果 iPhone 13 Pro', '4500.00', '<h3>商品概述</h3><p>这是一部经过精心保养的二手iPhone 13 Pro Max，外观成色良好，无明显划痕或磨损。设备功能正常，所有硬件组件均处于良好的工作状态。这部手机已解锁，可兼容任何运营商网络。我正在寻找一位对这款设备感兴趣的买家，希望它能带给您同样出色的体验。</p><h3>设备状况</h3><ul><li><strong>屏幕</strong>：无裂纹或刮痕，显示清晰明亮。</li><li><strong>背面及边框</strong>：轻微使用痕迹，不影响整体美观。</li><li><strong>摄像头</strong>：拍摄效果出色，无模糊或损坏。</li><li><strong>电池健康度</strong>：超过80%，剩余寿命充足。</li><li><strong>软件</strong>：运行 iOS 15.x 版本，无越狱或其他非法操作。</li><li><strong>配件</strong>：附带原装充电线和适配器（如有）</li></ul><h3>交易说明</h3><ul><li><strong>价格</strong>：由于是二手商品，价格比全新版本优惠很多。</li><li><strong>保修期</strong>：无官方保修，但我会提供一周内无理由退换货保障。</li><li><strong>支付方式</strong>：支持支付宝、微信支付等多种付款方式。</li><li><strong>配送</strong>：全国包邮，采用顺丰快递，确保安全送达。</li></ul>', '北京市朝阳区', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '2024-09-23 00:00:00', '通过', '电子产品', '1', '上架', '6', null, null, '0', '0', '0', '0');
INSERT INTO `goods` VALUES ('3', '苹果 iPhone 13', '4000.00', '<h3>商品概述</h3><p>这是一部经过精心保养的二手iPhone 13 Pro Max，外观成色良好，无明显划痕或磨损。设备功能正常，所有硬件组件均处于良好的工作状态。这部手机已解锁，可兼容任何运营商网络。我正在寻找一位对这款设备感兴趣的买家，希望它能带给您同样出色的体验。</p><h3>设备状况</h3><ul><li><strong>屏幕</strong>：无裂纹或刮痕，显示清晰明亮。</li><li><strong>背面及边框</strong>：轻微使用痕迹，不影响整体美观。</li><li><strong>摄像头</strong>：拍摄效果出色，无模糊或损坏。</li><li><strong>电池健康度</strong>：超过80%，剩余寿命充足。</li><li><strong>软件</strong>：运行 iOS 15.x 版本，无越狱或其他非法操作。</li><li><strong>配件</strong>：附带原装充电线和适配器（如有）</li></ul><h3>交易说明</h3><ul><li><strong>价格</strong>：由于是二手商品，价格比全新版本优惠很多。</li><li><strong>保修期</strong>：无官方保修，但我会提供一周内无理由退换货保障。</li><li><strong>支付方式</strong>：支持支付宝、微信支付等多种付款方式。</li><li><strong>配送</strong>：全国包邮，采用顺丰快递，确保安全送达。</li></ul>', '北京市朝阳区', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '2024-09-23 00:00:00', '通过', '电子产品', '1', '上架', '7', null, null, '0', '0', '0', '0');
INSERT INTO `goods` VALUES ('4', '二手Apple AirPods Pro无线耳机', '500.00', '<p># Apple AirPods Pro 无线蓝牙耳机\n\n- **品牌**：Apple\n- **型号**：AirPods Pro\n- **颜色**：白色\n- **成色**：九五成新\n- **功能**：主动降噪、透明模式、触摸控制、防水防汗\n- **配件**：充电盒、耳塞（S/M/L三副）、数据线\n\n这款AirPods Pro是我去年购买的，一直很爱惜，几乎每天都用，但由于最近换了新款，所以打算出掉。耳机没有任何损伤，音质和降噪效果都非常棒。充电盒电量足，续航持久。\n\n![AirPods Pro实物图]()\n\n价格可小刀，有意者私聊，非诚勿扰。支持当面交易或者邮寄，运费自理。<br/></p>', '北京市朝阳区', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '2024-09-23 00:00:00', '通过', '电子产品', '2', '上架', '5', null, null, '0', '0', '0', '0');
INSERT INTO `goods` VALUES ('5', '二手Apple AirPods无线耳机', '400.00', '<p># Apple AirPods Pro 无线蓝牙耳机\n\n- **品牌**：Apple\n- **型号**：AirPods Pro\n- **颜色**：白色\n- **成色**：九五成新\n- **功能**：主动降噪、透明模式、触摸控制、防水防汗\n- **配件**：充电盒、耳塞（S/M/L三副）、数据线\n\n这款AirPods Pro是我去年购买的，一直很爱惜，几乎每天都用，但由于最近换了新款，所以打算出掉。耳机没有任何损伤，音质和降噪效果都非常棒。充电盒电量足，续航持久。\n\n![AirPods Pro实物图]()\n\n价格可小刀，有意者私聊，非诚勿扰。支持当面交易或者邮寄，运费自理。<br/></p>', '北京市朝阳区', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '2024-09-23 00:00:00', '通过', '电子产品', '2', '上架', '15', null, null, '0', '0', '0', '0');
INSERT INTO `goods` VALUES ('6', '测试', '1.00', '<p>测试</p>', '北京市朝阳区', 'http://localhost:9090/files/1727071868039-Snipaste_2024-09-05_14-26-31.png', '2024-09-23 00:00:00', '待审核', '运动与户外', '3', '上架', '0', null, null, '0', '0', '0', '0');

-- ----------------------------
-- Table structure for help
-- ----------------------------
DROP TABLE IF EXISTS `help`;
CREATE TABLE `help` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text,
  `img` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `time` datetime DEFAULT NULL,
  `solved` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of help
-- ----------------------------
INSERT INTO `help` VALUES ('1', '二手笔记本电脑求购', '本人欲求购一台二手笔记本电脑，要求如下：\n\n处理器：Intel Core i5 或更高\n内存：至少 8GB RAM\n存储：SSD，容量大于 256GB\n显卡：独立显卡，NVIDIA GeForce GTX 1050 及以上\n屏幕尺寸：15.6 英寸及以上\n系统：Windows 10 或 macOS\n成色：外观良好，无明显划痕或破损\n价格范围：不超过 3000 元人民币\n如果有符合以上条件的笔记本电脑，请联系我，谢谢！', 'http://localhost:9090/files/1727057971430-Snipaste_2024-09-23_10-19-25.png', '通过', '1', '2024-09-23 10:19:32', '未解决');
INSERT INTO `help` VALUES ('2', '二手单反相机求购', '我想购买一款二手单反相机，具体要求如下：\n\n品牌：佳能或尼康\n型号：佳能 EOS 80D 或尼康 D7500\n镜头：18-135mm 或类似套装\n快门次数：低于 5,000 次\n包装：完整包装，包括相机、镜头、电池、充电器、说明书等\n成色：外观良好，无明显划痕或破损\n价格范围：不超过 4000 元人民币\n如果有符合条件的相机，请联系我，非常感谢！', 'http://localhost:9090/files/1727058054460-Snipaste_2024-09-23_10-20-48.png', '通过', '1', '2024-09-23 10:20:57', '未解决');
INSERT INTO `help` VALUES ('3', ' 测试', '测试', 'http://localhost:9090/files/1727071896109-Snipaste_2024-09-05_14-26-31.png', '待审核', '3', '2024-09-23 14:11:38', '未解决');

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fid` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `module` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of likes
-- ----------------------------
INSERT INTO `likes` VALUES ('1', '5', '1', 'goods');
INSERT INTO `likes` VALUES ('2', '3', '2', 'goods');

-- ----------------------------
-- Table structure for notice
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `time` datetime DEFAULT NULL,
  `user` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of notice
-- ----------------------------
INSERT INTO `notice` VALUES ('2', '关于近期平台维护的通知', '尊敬的同学们，\n\n大家好！为了给大家提供更好的服务，我们的校园二手交易平台将于本月末进行一次系统维护升级。在此期间，平台的部分功能可能会受到影响，包括但不限于商品发布、搜索和交易等功能。\n\n维护时间定于本月最后一个星期六凌晨2点至早上8点。在这段时间里，平台将暂时无法访问。请大家提前做好相关安排，避免不必要的困扰。\n\n维护结束后，我们将以全新的面貌为大家带来更加流畅、便捷的服务。感谢大家的理解和支持，让我们一起期待更好的校园二手交易平台吧！\n\n如有疑问或紧急需求，请联系我们的客服团队，我们会尽力协助解决。\n\n顺祝商祺，\n校园二手交易平台管理团队', '2024-09-23 00:00:00', 'admin');
INSERT INTO `notice` VALUES ('3', '冬季促销活动公告', '亲爱的用户们，\n\n随着冬天的到来，我们特别推出冬季促销活动！即日起至年底，凡是在平台上购买任意二手商品，均可享受满200减20的优惠。此外，如果您推荐朋友注册并完成首次交易，双方都将获得额外的50元代金券奖励。\n\n请注意，每个账号仅限使用一次优惠券，不可与其他折扣叠加使用。更多详情请参见活动规则页面。祝大家购物愉快！\n\n有任何问题，欢迎随时联系我们。祝大家在这个冬季找到心仪的好物！\n\n校园二手交易平台管理团队', '2024-09-23 00:00:00', 'admin');
INSERT INTO `notice` VALUES ('4', '平台新增功能介绍', '各位同学，\n\n很高兴告诉大家，我们的校园二手交易平台已经上线了两个新的功能——“一键估价”和“预约看货”。\n\n“一键估价”：只需上传商品照片和简单描述，系统即可自动评估其价值，方便快捷；\n“预约看货”：买家可以在线预约看货时间，减少来回奔波，提高交易效率。\n欢迎大家积极使用这两个新功能，提升交易体验。如有任何建议或问题，欢迎随时向我们反馈。\n\n祝大家交易顺利！\n\n校园二手交易平台管理团队', '2024-09-23 00:00:00', 'admin');

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `goods_name` varchar(255) NOT NULL,
  `goods_img` varchar(255) DEFAULT NULL,
  `order_no` varchar(255) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `time` datetime DEFAULT NULL,
  `pay_no` varchar(255) DEFAULT NULL,
  `pay_time` datetime DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `address` text,
  `phone` varchar(20) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `sale_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES ('1', '二手Apple AirPods无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270616048726155961', '400.00', '2024-09-23 11:20:04', null, null, '1', '河南省郑州市中原区无名小区', '18634208045', null, '已取消', '2');
INSERT INTO `orders` VALUES ('2', '二手Apple AirPods无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270638772199617328', '400.00', '2024-09-23 11:57:57', null, null, '1', '河南省郑州市中原区无名小区', '18634208045', null, '已取消', '2');
INSERT INTO `orders` VALUES ('3', '二手Apple AirPods Pro无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270642527786505821', '500.00', '2024-09-23 12:04:12', null, null, '1', '河南省郑州市中原区无名小区', '18634208045', null, '已取消', '2');
INSERT INTO `orders` VALUES ('4', '二手Apple AirPods无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270646061985991083', '400.00', '2024-09-23 12:10:06', null, null, '1', '河南省郑州市中原区无名小区', '18634208045', null, '已取消', '2');
INSERT INTO `orders` VALUES ('5', '二手Apple AirPods无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270660537423682871', '400.00', '2024-09-23 12:34:13', null, null, '1', '河南省郑州市中原区无名小区', '18634208045', null, '已取消', '2');
INSERT INTO `orders` VALUES ('6', '二手Apple AirPods无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270662669065154893', '400.00', '2024-09-23 12:37:46', '2024092322001435260504182101', '2024-09-23 12:38:19', '1', '河南省郑州市中原区无名小区', '18634208045', null, '待收货', '2');
INSERT INTO `orders` VALUES ('7', '苹果 iPhone 13', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '17270674048999386408', '4000.00', '2024-09-23 12:56:44', '2024092322001435260504188202', '2024-09-23 12:57:20', '2', '河南省郑州市中原区', '13520109202', null, '待发货', '1');
INSERT INTO `orders` VALUES ('8', '苹果 iPhone 13 Pro', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '17270676529604583521', '4500.00', '2024-09-23 13:00:52', null, null, '2', '河南省郑州市中原区', '13520109202', null, '已取消', '1');
INSERT INTO `orders` VALUES ('9', '苹果 iPhone 13 Pro', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '17270677210431689322', '4500.00', '2024-09-23 13:02:01', null, null, '2', '河南省郑州市中原区', '13520109202', null, '已取消', '1');
INSERT INTO `orders` VALUES ('10', '苹果 iPhone 13 Pro', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '17270678142710468411', '4500.00', '2024-09-23 13:03:34', null, null, '2', '河南省郑州市中原区', '13520109202', null, '待支付', '1');
INSERT INTO `orders` VALUES ('11', '二手Apple AirPods Pro无线耳机', 'http://localhost:9090/files/1727058824743-Snipaste_2024-09-23_10-33-36.png', '17270700126170258781', '500.00', '2024-09-23 13:40:12', null, null, '1', '河南省郑州市中原区无名小区', '18634208045', null, '待支付', '2');
INSERT INTO `orders` VALUES ('12', '苹果 iPhone 13 Pro Max', 'http://localhost:9090/files/1727057665712-Snipaste_2024-09-23_10-14-17.png', '17270719662189544178', '5000.00', '2024-09-23 14:12:46', '2024092322001435260504186685', '2024-09-23 14:13:45', '3', '河北', '17512341234', null, '待发货', '1');

-- ----------------------------
-- Table structure for posts
-- ----------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text,
  `img` varchar(255) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `time` datetime DEFAULT NULL,
  `circle` varchar(255) DEFAULT NULL,
  `descr` text,
  `read_count` int(11) DEFAULT '0',
  `status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of posts
-- ----------------------------
INSERT INTO `posts` VALUES ('1', '《Python编程：从入门到实践》二手书转让', '<h1>Python编程：从入门到实践</h1><p>这本书非常适合初学者，内容详实且易于理解。我已经完成了所有的练习，现在想把它转让给有需要的人。</p><h2>书籍详情</h2><ul><li>作者：<a href=\"https://www.amazon.cn/dp/B07CJ5B8HR\" target=\"_blank\">Mark Lutz</a></li><li>出版社：人民邮电出版社</li><li>ISBN：9787115448829</li><li>第几版：第三版</li><li>成色：九成新，无笔记，无折页</li></ul>', 'http://localhost:9090/files/1727058165548-Snipaste_2024-09-23_10-22-26.png', '1', '2024-09-23 10:22:59', '二手图书圈', '因学习需要购买，现已完成阅读，特此转售给有需要的同学。', '1', '通过');
INSERT INTO `posts` VALUES ('2', '《JavaScript高级程序设计》第四版低价转让', '<h1>JavaScript高级程序设计 第四版</h1><p>本书是我学习前端开发的重要参考资料，现因更新至第五版，故低价转让第四版。</p><h2>书籍详情</h2><ul><li>作者：<a href=\"https://www.amazon.cn/dp/B00KQOZGDA\" target=\"_blank\">Nicholas C. Zakas</a></li><li>出版社：人民邮电出版社</li><li>ISBN：9787115448829</li><li>第几版：第四版</li><li>成色：八成新，部分章节有少量笔记</li></ul><p><img alt=\"\" src=\"https://tongyi.aliyun.com/qianwen/book-cover.jpg\"/><br/></p>', 'http://localhost:9090/files/1727058273709-Snipaste_2024-09-23_10-24-05.png', '1', '2024-09-23 10:24:44', '二手图书圈', '因升级至最新版，现低价转让旧版教材。', '2', '通过');
INSERT INTO `posts` VALUES ('3', '《红楼梦》读书笔记', '<p>大家好！我刚刚开始阅读《红楼梦》，虽然只看了一部分，但是我已经有了很多感悟。今天我想跟大家分享一下我对林黛玉这个人物的理解...\n\n在我看来，林黛玉是一个非常复杂的人物。她聪明、敏感，同时又有些许忧郁。她的诗词才华让我惊叹不已，而她在贾府中的处境又让人感到同情。我希望我们能一起讨论这个角色以及书中其他的角色和情节。\n\n另外，我还拍了一张我正在阅读《红楼梦》的照片，大家可以看看。这本书真的值得一读！\n\n[插入图片]\n\n期待你们的回复！<br/></p>', 'http://localhost:9090/files/1727059776656-Snipaste_2024-09-23_10-49-31.png', '1', '2024-09-23 10:49:38', '书友会', '最近我在阅读《红楼梦》，发现这本书非常精彩，有很多值得探讨的地方。我想通过这篇帖子分享我的一些读书笔记和思考。', '0', '通过');
INSERT INTO `posts` VALUES ('4', '周末跑步计划', '<p>大家好！我是新来的，一直热爱运动，特别是跑步。我发现我们的“运动爱好者”圈子很活跃，所以决定发起一个周末跑步计划。\n\n每周六早上8点，我会在公园集合，邀请大家一起参加晨跑。希望这不仅能帮助我们保持健康，还能结交志同道合的朋友。\n\n如果有任何建议或者想法，请随时留言。期待见到你们！\n\n[插入图片]<br/></p>', 'http://localhost:9090/files/1727059862663-Snipaste_2024-09-23_10-50-55.png', '1', '2024-09-23 10:51:04', '运动爱好者', '让我们一起动起来！', '0', '通过');
INSERT INTO `posts` VALUES ('5', '自制披萨大挑战', '<p>大家好！我一直都是个披萨迷，尝试过各种口味。最近，我决定自己动手做披萨，结果出乎意料的好吃！\n\n步骤很简单：&nbsp;</p><p>1. 准备面团...\n2. 添加配料...\n3. 烤箱预热至200度，烤15分钟...&nbsp;</p><p>&nbsp;这就是我的成果，看起来是不是很有食欲？\n\n如果你也喜欢披萨，不妨试试看。期待看到你们的作品！<br/></p>', 'http://localhost:9090/files/1727059924724-Snipaste_2024-09-23_10-51-58.png', '1', '2024-09-23 10:52:06', '美食分享圈', '谁说外卖比萨最好吃？我自己做的才最棒！', '1', '通过');
INSERT INTO `posts` VALUES ('6', '测试', '<p>测试</p>', 'http://localhost:9090/files/1727072104748-Snipaste_2024-09-05_14-26-16.png', '3', '2024-09-23 14:15:08', '二手图书圈', '测试', '0', '待审核');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `role` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'user', '123', '用户1', '17512341234', '123@qq.com', 'http://localhost:9090/files/1727056755503-cat.png', 'USER');
INSERT INTO `user` VALUES ('2', 'zhangsan', '123', '张三', '13520109202', '123@qq.com', 'http://localhost:9090/files/1727056824767-menu-pet.png', 'USER');
INSERT INTO `user` VALUES ('3', 'lisi', '123', 'lisi', '13520109202', '123@qq.com', 'http://localhost:9090/files/1727060318691-Snipaste_2024-09-05_14-26-16.png', 'USER');
INSERT INTO `user` VALUES ('4', 'zhang', '123', '张三峰', '3520109202', '123@qq.com', 'http://localhost:9090/files/1727071828481-Snipaste_2024-09-05_14-26-16.png', 'USER');
