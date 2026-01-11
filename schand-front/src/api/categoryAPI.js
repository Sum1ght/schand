import httpInstance from "@/utils/http";

/**
 * @description - 添加分类
 * @param {Object} category - 分类信息对象
 * @param {String} category.name - 分类名称，必填
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addCategoryAPI = (category) => {
  return httpInstance({
    url: "/category/add",
    method: "POST",
    data: category,
  });
};

/**
 * @description - 更新分类
 * @param {Object} category - 分类信息对象
 * @param {Number} category.id - 分类ID，必填
 * @param {String} [category.name] - 分类名称，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateCategoryAPI = (category) => {
  return httpInstance({
    url: "/category/update",
    method: "PUT",
    data: category,
  });
};

/**
 * @description - 删除分类
 * @param {Number} id - 分类ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteCategoryAPI = (id) => {
  return httpInstance({
    url: `/category/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除分类
 * @param {Array<Number>} ids - 分类ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchCategoryAPI = (ids) => {
  return httpInstance({
    url: "/category/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询分类
 * @param {Number} id - 分类ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     name: string
 *   }
 * }>} 返回分类详细信息
 */
export const getCategoryByIdAPI = (id) => {
  return httpInstance({
    url: `/category/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 直接查询分类
 * @param {Object} category - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     name: string
 *   }>
 * }>} 返回所有分类列表
 */
export const getAllCategoryAPI = (category = {}) => {
  return httpInstance({
    url: "/category/selectAll",
    method: "GET",
    params: category,
  });
};

/**
 * @description - 分页查询分类
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} params.category - 分类查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       name: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getCategoryPageAPI = (params) => {
  return httpInstance({
    url: "/category/selectPage",
    method: "GET",
    params,
  });
};
