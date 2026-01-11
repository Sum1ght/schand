import httpInstance from "@/utils/http";

/**
 * @description - 添加用户
 * @param {Object} user - 用户信息对象
 * @param {String} user.username - 用户名，必填
 * @param {String} user.password - 密码，必填
 * @param {String} [user.name] - 姓名，可选
 * @param {String} [user.phone] - 手机号，可选
 * @param {String} [user.email] - 邮箱，可选
 * @param {String} [user.avatar] - 头像URL，可选
 * @param {String} [user.role] - 角色标识，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addUserAPI = (user) => {
  return httpInstance({
    url: "/user/add",
    method: "POST",
    data: user,
  });
};

/**
 * @description - 删除用户
 * @param {Number} id - 用户ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteUserAPI = (id) => {
  return httpInstance({
    url: `/user/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除用户
 * @param {Array<Number>} ids - 用户ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchUserAPI = (ids) => {
  return httpInstance({
    url: "/user/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 更新用户信息
 * @param {Object} user - 用户信息对象
 * @param {Number} user.id - 用户ID，必填
 * @param {String} [user.name] - 姓名，可选
 * @param {String} [user.phone] - 手机号，可选
 * @param {String} [user.email] - 邮箱，可选
 * @param {String} [user.avatar] - 头像URL，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateUserAPI = (user) => {
  return httpInstance({
    url: "/user/update",
    method: "PUT",
    data: user,
  });
};

/**
 * @description - 根据ID查询用户
 * @param {Number} id - 用户ID
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
 * }>} 返回用户信息
 */
export const getUserByIdAPI = (id) => {
  return httpInstance({
    url: `/user/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有用户
 * @param {Object} [user] - 查询条件
 * @param {String} [user.username] - 用户名，可选，模糊查询
 * @param {String} [user.name] - 姓名，可选，模糊查询
 * @param {String} [user.phone] - 手机号，可选，模糊查询
 * @param {String} [user.email] - 邮箱，可选，模糊查询
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
 * }>} 返回用户列表
 */
export const getAllUsersAPI = (user = {}) => {
  return httpInstance({
    url: "/user/selectAll",
    method: "GET",
    params: user,
  });
};

/**
 * @description - 后台分页查询用户
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.user] - 用户查询条件，可选
 * @param {String} [params.user.username] - 用户名，可选，模糊查询
 * @param {String} [params.user.name] - 姓名，可选，模糊查询
 * @param {String} [params.user.phone] - 手机号，可选，模糊查询
 * @param {String} [params.user.email] - 邮箱，可选，模糊查询
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
export const getUserPageAPI = (params) => {
  return httpInstance({
    url: "/user/selectPage",
    method: "GET",
    params,
  });
};
