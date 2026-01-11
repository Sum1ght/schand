import httpInstance from "@/utils/http";

/**
 * @description - 添加评论
 * @param {Object} comment - 评论信息对象
 * @param {Number} comment.fid - 关联ID，必填
 * @param {Number} comment.userId - 用户ID，必填
 * @param {String} comment.module - 模块名称，必填
 * @param {String} comment.content - 评论内容，必填
 * @param {Number} [comment.pid] - 父评论ID，可选，回复评论时需要
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addCommentAPI = (comment) => {
  return httpInstance({
    url: "/comment/add",
    method: "POST",
    data: comment,
  });
};

/**
 * @description - 删除评论
 * @param {Number} id - 评论ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteCommentAPI = (id) => {
  return httpInstance({
    url: `/comment/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除评论
 * @param {Array} ids - 评论ID列表
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteBatchCommentAPI = (ids) => {
  return httpInstance({
    url: `/comment/deleteBatch`,
    method: "DELETE",
    data: { ids },
  });
};

/**
 * @description - 获取所有评论
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array
 * }>} 返回所有评论列表
 */
export const selectAllCommentAPI = () => {
  return httpInstance({
    url: "/comment/selectAll",
    method: "GET",
  });
};

/**
 * @description - 获取评论树结构（带分页）
 * @param {Number} fid - 关联ID
 * @param {String} module - 模块名称
 * @param {Number} pageNum - 当前页码
 * @param {Number} pageSize - 每页数量
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       content: string,
 *       userId: number,
 *       userName: string,
 *       avatar: string,
 *       fid: number,
 *       pid: number,
 *       parentUserName: string,
 *       time: string,
 *       module: string,
 *       children: Array
 *     }>
 *   }
 * }>} 返回评论树结构列表
 */
export const getCommentTreeAPI = (fid, module, pageNum, pageSize) => {
  return httpInstance({
    url: `/comment/selectTree/${fid}/${module}`,
    method: "GET",
    params: {
      pageNum,
      pageSize,
    },
  });
};

/**
 * @description - 获取评论总数
 * @param {Number} fid - 关联ID
 * @param {String} module - 模块名称
 * @returns {Promise<{code: string, msg: string, data: number}>} 返回评论总数
 */
export const getCommentCountAPI = (fid, module) => {
  return httpInstance({
    url: `/comment/selectCount/${fid}/${module}`,
    method: "GET",
  });
};

/**
 * @description - 获取评论分页
 * @param {String} content - 评论内容
 * @param {Number} pageNum - 当前页码
 * @param {Number} pageSize - 每页数量
 * @returns {Promise<{code: string, msg: string, data: {total: number, list: Array}}>} 返回评论分页
 */
export const getCommentPageAPI = (content, pageNum, pageSize) => {
  return httpInstance({
    url: "/comment/selectPage",
    method: "GET",
    params: {
      content,
      pageNum,
      pageSize,
    },
  });
};
