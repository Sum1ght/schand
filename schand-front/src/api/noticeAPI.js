import httpInstance from "@/utils/http";

/**
 * @description - 添加公告
 * @param {Object} notice - 公告信息对象
 * @param {String} notice.title - 公告标题，必填
 * @param {String} notice.content - 公告内容，必填
 * @param {String} [notice.user] - 创建人，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addNoticeAPI = (notice) => {
  return httpInstance({
    url: "/notice/add",
    method: "POST",
    data: notice,
  });
};

/**
 * @description - 更新公告
 * @param {Object} notice - 公告信息对象
 * @param {Number} notice.id - 公告ID，必填
 * @param {String} [notice.title] - 公告标题，可选
 * @param {String} [notice.content] - 公告内容，可选
 * @param {String} [notice.time] - 创建时间，可选
 * @param {String} [notice.user] - 创建人，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateNoticeAPI = (notice) => {
  return httpInstance({
    url: "/notice/update",
    method: "PUT",
    data: notice,
  });
};

/**
 * @description - 删除公告
 * @param {Number} id - 公告ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteNoticeAPI = (id) => {
  return httpInstance({
    url: `/notice/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除公告
 * @param {Array<Number>} ids - 公告ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchNoticeAPI = (ids) => {
  return httpInstance({
    url: "/notice/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询公告
 * @param {Number} id - 公告ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     title: string,
 *     content: string,
 *     time: string,
 *     user: string
 *   }
 * }>} 返回公告详细信息
 */
export const getNoticeByIdAPI = (id) => {
  return httpInstance({
    url: `/notice/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有公告
 * @param {Object} [notice] - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     title: string,
 *     content: string,
 *     time: string,
 *     user: string
 *   }>
 * }>} 返回所有公告列表
 */
export const getAllNoticesAPI = (notice = {}) => {
  return httpInstance({
    url: "/notice/selectAll",
    method: "GET",
    params: notice,
  });
};

/**
 * @description - 分页查询公告
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.notice] - 公告查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       title: string,
 *       content: string,
 *       time: string,
 *       user: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getNoticePageAPI = (params) => {
  return httpInstance({
    url: "/notice/selectPage",
    method: "GET",
    params,
  });
};
