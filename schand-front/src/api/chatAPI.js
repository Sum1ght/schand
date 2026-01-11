import httpInstance from "@/utils/http";
/**
 * 查询用户聊天记录
 * @param {number} chatUserId - 聊天用户ID
 * @returns {Promise<Result<Array<ChatInfo>>>} 返回聊天记录列表
 */
export function selectUserChatAPI(chatUserId) {
  return httpInstance({
    url: `/chatInfo/selectUserChat/${chatUserId}`,
    method: "get",
  });
}

/**
 * 添加聊天信息
 * @param {Object} chatInfo - 聊天信息对象
 * @returns {Promise<Result>} 返回操作结果
 */
export function addChatInfoAPI(chatInfo) {
  return httpInstance({
    url: "/chatInfo/add",
    method: "post",
    data: chatInfo,
  });
}

/**
 * 更新消息已读状态
 * @param {number} chatUserId - 聊天用户ID
 * @returns {Promise<Result>} 返回操作结果
 */
export function updateChatInfoReadLegacyAPI(chatUserId) {
  return httpInstance({
    url: `/chatInfo/updateRead/${chatUserId}`,
    method: "put",
  });
}

/**
 * 更新消息已读状态
 * @param {number} chatUserId - 聊天用户ID
 * @returns {Promise<Result>} 返回操作结果
 */
export function updateChatInfoReadAPI(chatUserId) {
  return httpInstance({
    url: `/chatInfo/updateRead/${chatUserId}`,
    method: "put",
  });
}

/**
 * 查询用户聊天组
 * @returns {Promise<Result<Array<ChatGroup>>>} 返回用户聊天组列表
 */
export function selectUserGroupAPI() {
  return httpInstance({
    url: "/chatGroup/selectUserGroup",
    method: "get",
  });
}

/**
 * 删除聊天组
 * @param {number} id - 聊天组ID
 * @returns {Promise<Result>} 返回操作结果
 */
export function deleteChatGroupAPI(id) {
  return httpInstance({
    url: `/chatGroup/delete/${id}`,
    method: "delete",
  });
}

/**
 * 增加聊天组
 * @param {number} ChatUserId - 商品所属用户
 * @param {number} userId - 当前登录用户
 * @returns {Promise<Result>} 返回操作结果
 */
export function addChatGroupAPI(data) {
  return httpInstance({
    url: "/chatGroup/add",
    method: "post",
    data,
  });
}
