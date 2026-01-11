import httpInstance from "@/utils/http";

// 求购基础API

/**
 * @description - 添加求购
 * @param {Object} help - 求购信息对象
 * @param {String} help.title - 求购标题，必填
 * @param {String} help.content - 求购内容，必填
 * @param {String} [help.img] - 求购图片，可选
 * @param {String} [help.status] - 状态，可选
 * @param {Integer} help.userId - 用户ID，必填
 * @param {String} [help.solved] - 是否解决，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addHelpAPI = (help) => {
  return httpInstance({
    url: "/help/add",
    method: "POST",
    data: help,
  });
};

/**
 * @description - 更新求购
 * @param {Object} help - 求购信息对象
 * @param {Number} help.id - 求购ID，必填
 * @param {String} [help.title] - 求购标题，可选
 * @param {String} [help.content] - 求购内容，可选
 * @param {String} [help.img] - 求购图片，可选
 * @param {String} [help.status] - 状态，可选
 * @param {Integer} [help.userId] - 用户ID，可选
 * @param {String} [help.time] - 发布时间，可选
 * @param {String} [help.solved] - 是否解决，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateHelpAPI = (help) => {
  return httpInstance({
    url: "/help/update",
    method: "PUT",
    data: help,
  });
};

/**
 * @description - 删除求购
 * @param {Number} id - 求购ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteHelpAPI = (id) => {
  return httpInstance({
    url: `/help/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除求购
 * @param {Array<Number>} ids - 求购ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchHelpAPI = (ids) => {
  return httpInstance({
    url: "/help/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询求购
 * @param {Number} id - 求购ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     title: string,
 *     content: string,
 *     img: string,
 *     status: string,
 *     userId: number,
 *     time: string,
 *     solved: string,
 *     userName: string,
 *     avatar: string
 *   }
 * }>} 返回求购详细信息
 */
export const getHelpByIdAPI = (id) => {
  return httpInstance({
    url: `/help/selectById/${id}`,
    method: "GET",
  });
};

//! 已验证
/**
 * @description - 查询所有求购
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     title: string,
 *     content: string,
 *     img: string,
 *     status: string,
 *     userId: number,
 *     time: string,
 *     solved: string,
 *     userName: string,
 *     avatar: string
 *   }>
 * }>} 返回所有悬赏列表（包括当前用户发的）
 */
export const getAllHelpAPI = () => {
  return httpInstance({
    url: "/help/selectAll",
    method: "GET",
  });
};


/**
 * @description - 后台分页查询求购（有过滤）
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.help] - 求购查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       title: string,
 *       content: string,
 *       img: string,
 *       status: string,
 *       userId: number,
 *       time: string,
 *       solved: string,
 *       userName: string,
 *       avatar: string
 *     }>
 *   }
 * }>} 返回后台分页查询结果
 */
export const getHelpPageAPI = (params) => {
  return httpInstance({
    url: "/help/selectPage",
    method: "GET",
    params,
  });
};

/**
 * @description - 前台分页查询求购
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.help] - 求购查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       title: string,
 *       content: string,
 *       img: string,
 *       status: string,
 *       userId: number,
 *       time: string,
 *       solved: string,
 *       userName: string,
 *       avatar: string,
 *     }>
 *   }
 * }>} 返回前台分页查询结果
 */
export const getHelpFrontPageAPI = (params) => {
  return httpInstance({
    url: "/help/selectFrontPage",
    method: "GET",
    params,
  });
};
