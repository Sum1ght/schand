// 收藏相关API
import httpInstance from "@/utils/http";

/**
 * @description - 添加收藏
 * @param {Object} collect - 收藏信息对象
 * @param {Number} collect.fid - 被收藏内容ID，必填
 * @param {String} collect.module - 模块名称，必填
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addCollectAPI = (collect) => {
  return httpInstance({
    url: "/collect/add",
    method: "POST",
    data: collect,
  });
};

/**
 * @description - 删除收藏
 * @param {Number} id - 收藏ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteCollectAPI = (id) => {
  return httpInstance({
    url: `/collect/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除收藏
 * @param {Array<Number>} ids - 收藏ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchCollectAPI = (ids) => {
  return httpInstance({
    url: "/collect/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 分页查询收藏
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       fid: number,
 *       userId: number,
 *       module: string,
 *       goodsName: string,
 *       goodsImg: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getCollectPageAPI = (params) => {
  return httpInstance({
    url: "/collect/selectPage",
    method: "GET",
    params,
  });
};
