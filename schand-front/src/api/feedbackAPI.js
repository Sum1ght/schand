// 反馈相关API
import httpInstance from "@/utils/http";

// 用户反馈API

/**
 * @description - 添加反馈
 * @param {Object} feedback - 反馈信息对象
 * @param {String} feedback.title - 反馈主题，必填
 * @param {String} feedback.content - 反馈内容，必填
 * @param {String} [feedback.phone] - 联系方式，可选
 * @param {String} [feedback.email] - 电子邮箱，可选
 * @param {Integer} feedback.userId - 提交人ID，必填
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addFeedbackAPI = (feedback) => {
  return httpInstance({
    url: "/feedback/add",
    method: "POST",
    data: feedback,
  });
};

/**
 * @description - 更新反馈
 * @param {Object} feedback - 反馈信息对象
 * @param {Number} feedback.id - 反馈ID，必填
 * @param {String} [feedback.title] - 反馈主题，可选
 * @param {String} [feedback.content] - 反馈内容，可选
 * @param {String} [feedback.phone] - 联系方式，可选
 * @param {String} [feedback.email] - 电子邮箱，可选
 * @param {String} [feedback.reply] - 回复内容，可选
 * @param {Integer} [feedback.userId] - 提交人ID，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateFeedbackAPI = (feedback) => {
  return httpInstance({
    url: "/feedback/update",
    method: "PUT",
    data: feedback,
  });
};

/**
 * @description - 删除反馈
 * @param {Number} id - 反馈ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteFeedbackAPI = (id) => {
  return httpInstance({
    url: `/feedback/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除反馈
 * @param {Array<Number>} ids - 反馈ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchFeedbackAPI = (ids) => {
  return httpInstance({
    url: "/feedback/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询反馈
 * @param {Number} id - 反馈ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     title: string,
 *     content: string,
 *     phone: string,
 *     email: string,
 *     reply: string,
 *     createtime: string,
 *     userId: number,
 *     userName: string
 *   }
 * }>} 返回反馈详细信息
 */
export const getFeedbackByIdAPI = (id) => {
  return httpInstance({
    url: `/feedback/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有反馈
 * @param {Object} feedback - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     title: string,
 *     content: string,
 *     phone: string,
 *     email: string,
 *     reply: string,
 *     createtime: string,
 *     userId: number,
 *     userName: string
 *   }>
 * }>} 返回所有反馈列表
 */
export const getAllFeedbackAPI = (feedback = {}) => {
  return httpInstance({
    url: "/feedback/selectAll",
    method: "GET",
    params: feedback,
  });
};

/**
 * @description - 分页查询反馈
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.feedback] - 反馈查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       title: string,
 *       content: string,
 *       phone: string,
 *       email: string,
 *       reply: string,
 *       createtime: string,
 *       userId: number,
 *       userName: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getFeedbackPageAPI = (params) => {
  return httpInstance({
    url: "/feedback/selectPage",
    method: "GET",
    params,
  });
};
