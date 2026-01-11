// 地址相关API
import httpInstance from "@/utils/http";

/**
 * @description - 添加地址
 * @param {Object} address - 地址信息对象
 * @param {String} address.name - 联系人姓名，必填
 * @param {String} address.address - 联系地址，必填
 * @param {String} address.phone - 联系电话，必填
 * @param {Integer} address.userId - 关联用户ID，必填
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addAddressAPI = (address) => {
  return httpInstance({
    url: "/address/add",
    method: "POST",
    data: address,
  });
};

/**
 * @description - 更新地址
 * @param {Object} address - 地址信息对象
 * @param {Number} address.id - 地址ID，必填
 * @param {String} address.name - 联系人姓名，可选
 * @param {String} address.address - 联系地址，可选
 * @param {String} address.phone - 联系电话，可选
 * @param {Integer} address.userId - 关联用户ID，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateAddressAPI = (address) => {
  return httpInstance({
    url: "/address/update",
    method: "PUT",
    data: address,
  });
};

/**
 * @description - 删除地址
 * @param {Number} id - 地址ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteAddressAPI = (id) => {
  return httpInstance({
    url: `/address/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除地址
 * @param {Array<Number>} ids - 地址ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchAddressAPI = (ids) => {
  return httpInstance({
    url: "/address/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询地址
 * @param {Number} id - 地址ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     name: string,
 *     address: string,
 *     phone: string,
 *     userId: number,
 *     userName: string
 *   }
 * }>} 返回地址详细信息
 */
export const getAddressByIdAPI = (id) => {
  return httpInstance({
    url: `/address/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有地址
 * @param {Object} address - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     name: string,
 *     address: string,
 *     phone: string,
 *     userId: number,
 *     userName: string
 *   }>
 * }>} 返回所有地址列表
 */
export const getAllAddressAPI = (address = {}) => {
  return httpInstance({
    url: "/address/selectAll",
    method: "GET",
    params: address,
  });
};

/**
 * @description - 分页查询地址
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} params.address - 地址查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       name: string,
 *       address: string,
 *       phone: string,
 *       userId: number,
 *       userName: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getAddressPageAPI = (params) => {
  return httpInstance({
    url: "/address/selectPage",
    method: "GET",
    params,
  });
};
