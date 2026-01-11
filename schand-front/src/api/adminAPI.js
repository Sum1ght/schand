// 管理员相关API
import httpInstance from "@/utils/http";

/**
 * @description - 添加管理员
 * @param {Object} admin - 管理员信息对象
 * @param {String} admin.username - 用户名，必填
 * @param {String} admin.password - 密码，必填
 * @param {String} [admin.name] - 姓名，可选
 * @param {String} [admin.phone] - 手机号，可选
 * @param {String} [admin.email] - 邮箱，可选
 * @param {String} [admin.avatar] - 头像URL，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addAdminAPI = (admin) => {
  return httpInstance({
    url: "/admin/add",
    method: "POST",
    data: admin,
  });
};

/**
 * @description - 删除管理员
 * @param {Number} id - 管理员ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteAdminAPI = (id) => {
  return httpInstance({
    url: `/admin/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除管理员
 * @param {Array<Number>} ids - 管理员ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchAdminAPI = (ids) => {
  return httpInstance({
    url: "/admin/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 更新管理员信息
 * @param {Object} admin - 管理员信息对象
 * @param {Number} admin.id - 管理员ID，必填
 * @param {String} [admin.name] - 姓名，可选
 * @param {String} [admin.phone] - 手机号，可选
 * @param {String} [admin.email] - 邮箱，可选
 * @param {String} [admin.avatar] - 头像URL，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateAdminAPI = (admin) => {
  return httpInstance({
    url: "/admin/update",
    method: "PUT",
    data: admin,
  });
};

/**
 * @description - 根据ID查询管理员
 * @param {Number} id - 管理员ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     username: string,
 *     name: string,
 *     phone: string,
 *     email: string,
 *     avatar: string,
 *     role: string,
 *     token: string
 *   }
 * }>} 返回管理员信息
 */
export const getAdminByIdAPI = (id) => {
  return httpInstance({
    url: `/admin/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有管理员
 * @param {Object} [admin] - 查询条件
 * @param {String} [admin.username] - 用户名，可选，模糊查询
 * @param {String} [admin.name] - 姓名，可选，模糊查询
 * @param {String} [admin.phone] - 手机号，可选，模糊查询
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     username: string,
 *     name: string,
 *     phone: string,
 *     email: string,
 *     avatar: string,
 *     role: string,
 *     token: string
 *   }>
 * }>} 返回管理员列表
 */
export const getAllAdminsAPI = (admin = {}) => {
  return httpInstance({
    url: "/admin/selectAll",
    method: "GET",
    params: admin,
  });
};

/**
 * @description - 分页查询管理员
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.admin] - 管理员查询条件，可选
 * @param {String} [params.admin.username] - 用户名，可选，模糊查询
 * @param {String} [params.admin.name] - 姓名，可选，模糊查询
 * @param {String} [params.admin.phone] - 手机号，可选，模糊查询
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       username: string,
 *       name: string,
 *       phone: string,
 *       email: string,
 *       avatar: string,
 *       role: string,
 *       token: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getAdminPageAPI = (params) => {
  return httpInstance({
    url: "/admin/selectPage",
    method: "GET",
    params,
  });
};
