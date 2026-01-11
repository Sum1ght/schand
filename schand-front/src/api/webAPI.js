import httpInstance from "@/utils/http";

/**
 * @description - 用户登录API
 * @param {Object} account - 登录参数对象
 * @param {string} account.role - 用户角色(USER/ADMIN)
 * @param {string} account.username - 用户名
 * @param {string} account.password - 密码
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
 * }>} 返回登录信息，包含用户基本信息和token
 */
export const loginAPI = (account) => {
  return httpInstance({
    url: "/login",
    method: "POST",
    data: account,
  });
};

/**
 * @description - 用户注册API
 * @param {Object} account - 注册参数对象
 * @param {string} account.username - 用户名
 * @param {string} account.password - 密码
 * @param {string} account.role - 用户角色(只支持USER)
 * @param {string} [account.name] - 姓名，可选
 * @param {string} [account.phone] - 手机号，可选
 * @param {string} [account.email] - 邮箱，可选
 * @param {string} [account.avatar] - 头像URL，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回注册结果，成功时code为"200"
 */
export const registerAPI = (account) => {
  return httpInstance({
    url: "/register",
    method: "POST",
    data: account,
  });
};

/**
 * @description - 更新用户密码API
 * @param {Object} account - 包含用户信息和新密码的对象
 * @param {string} account.username - 用户名
 * @param {string} account.password - 原密码
 * @param {string} account.newPassword - 新密码
 * @param {string} account.role - 用户角色(USER/ADMIN)
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新密码结果，成功时code为"200"
 */
export const updatePasswordAPI = (account) => {
  return httpInstance({
    url: "/updatePassword",
    method: "PUT",
    data: account,
  });
};


