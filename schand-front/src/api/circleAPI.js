// 圈子相关API
// todo 到底加不加复数
import httpInstance from "@/utils/http";

/**
 * @description - 添加圈子
 * @param {Object} circles - 圈子信息对象
 * @param {String} circles.name - 圈子名称，必填
 * @param {String} circles.img - 圈子缩略图，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addCircleAPI = (circles) => {
  return httpInstance({
    url: "/circles/add",
    method: "POST",
    data: circles,
  });
};

/**
 * @description - 更新圈子
 * @param {Object} circles - 圈子信息对象
 * @param {Number} circles.id - 圈子ID，必填
 * @param {String} circles.name - 圈子名称，可选
 * @param {String} circles.img - 圈子缩略图，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateCircleAPI = (circles) => {
  return httpInstance({
    url: "/circles/update",
    method: "PUT",
    data: circles,
  });
};

/**
 * @description - 删除圈子
 * @param {Number} id - 圈子ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteCircleAPI = (id) => {
  return httpInstance({
    url: `/circles/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除圈子
 * @param {Array<Number>} ids - 圈子ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchCircleAPI = (ids) => {
  return httpInstance({
    url: "/circles/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询圈子
 * @param {Number} id - 圈子ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     name: string,
 *     img: string
 *   }
 * }>} 返回圈子详细信息
 */
export const getCircleByIdAPI = (id) => {
  return httpInstance({
    url: `/circles/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有圈子
 * @param {Object} circles - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     name: string,
 *     img: string
 *   }>
 * }>} 返回所有圈子列表
 */
export const getAllCirclesAPI = (circles = {}) => {
  return httpInstance({
    url: "/circles/selectAll",
    method: "GET",
    params: circles,
  });
};

/**
 * @description - 分页查询圈子
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} params.circles - 圈子查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       name: string,
 *       img: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getCirclesPageAPI = (params) => {
  return httpInstance({
    url: "/circles/selectPage",
    method: "GET",
    params,
  });
};

// 获取圈子列表
export const getCircleListAPI = () => {
  return httpInstance({
    url: "/circle/list",
    method: "GET",
  });
};

// 获取圈子详情
export const getCircleDetailAPI = (id) => {
  return httpInstance({
    url: `/circle/detail/${id}`,
    method: "GET",
  });
};

// 创建圈子
export const createCircleAPI = (data) => {
  return httpInstance({
    url: "/circle/create",
    method: "POST",
    data,
  });
};

// 加入圈子
export const joinCircleAPI = (id) => {
  return httpInstance({
    url: `/circle/join/${id}`,
    method: "POST",
  });
};

// 退出圈子
export const leaveCircleAPI = (id) => {
  return httpInstance({
    url: `/circle/leave/${id}`,
    method: "POST",
  });
};

// 获取用户已加入的圈子
export const getUserCirclesAPI = () => {
  return httpInstance({
    url: "/circle/user",
    method: "GET",
  });
};

// 获取热门圈子
export const getHotCirclesAPI = (params) => {
  return httpInstance({
    url: "/circle/hot",
    method: "GET",
    params,
  });
};

// 获取圈子成员
export const getCircleMembersAPI = (id, params) => {
  return httpInstance({
    url: `/circle/members/${id}`,
    method: "GET",
    params,
  });
};
