import httpInstance from "@/utils/http";
// 商品API

/**
 * @description - 更新商品
 * @param {Object} goods - 商品信息对象
 * @param {Number} goods.id - 商品ID，必填
 * @param {String} [goods.name] - 商品名称，可选
 * @param {Number} [goods.price] - 商品价格，可选
 * @param {String} [goods.content] - 商品详情，可选
 * @param {String} [goods.address] - 发货地址，可选
 * @param {String} [goods.img] - 商品图片，可选
 * @param {String} [goods.date] - 上架日期，可选
 * @param {String} [goods.status] - 审核状态，可选
 * @param {String} [goods.category] - 分类，可选
 * @param {Integer} [goods.userId] - 所属用户ID，可选
 * @param {String} [goods.saleStatus] - 上架状态，可选
 * @param {Integer} [goods.readCount] - 浏览量，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateGoodsAPI = (goods) => {
  return httpInstance({
    url: "/goods/update",
    method: "PUT",
    data: goods,
  });
};

/**
 * @description - 删除商品
 * @param {Number} id - 商品ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteGoodsAPI = (id) => {
  return httpInstance({
    url: `/goods/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除商品
 * @param {Array<Number>} ids - 商品ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchGoodsAPI = (ids) => {
  return httpInstance({
    url: "/goods/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

//! 已验证正确性
/**
 * @description - 更新商品阅读计数
 * @param {Number} id - 商品ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateGoodsReadCountAPI = (id) => {
  return httpInstance({
    url: `/goods/updateReadCount/${id}`,
    method: "PUT",
  });
};

/**
 * @description - 添加商品
 * @param {Object} goods - 商品信息对象
 * @param {String} goods.name - 商品名称，必填
 * @param {Number} goods.price - 商品价格，必填
 * @param {String} goods.content - 商品详情，必填
 * @param {String} goods.address - 发货地址，可选
 * @param {String} goods.img - 商品图片，可选
 * @param {String} goods.category - 分类，必填
 * @param {Integer} goods.userId - 所属用户ID，必填
 * @param {String} goods.status - 审核状态，可选
 * @param {String} goods.saleStatus - 上架状态，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addGoodsAPI = (goods) => {
  return httpInstance({
    url: "/goods/add",
    method: "POST",
    data: goods,
  });
};

/**
 * @description - 查询所有商品
 * @param {Object} goods - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     name: string,
 *     price: number,
 *     content: string,
 *     address: string,
 *     img: string,
 *     date: string,
 *     status: string,
 *     category: string,
 *     userId: number,
 *     saleStatus: string,
 *     readCount: number,
 *     userName: string,
 *     sort: string,
 *     userLikes: boolean,
 *     userCollect: boolean,
 *     likesCount: number,
 *     collectCount: number
 *   }>
 * }>} 返回商品列表
 */
export const getAllGoodsAPI = (goods = {}) => {
  return httpInstance({
    url: "/goods/selectAll",
    method: "GET",
    params: goods,
  });
};

/**
 * @description - 后台分页查询所有商品
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.goods] - 商品查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       name: string,
 *       price: number,
 *       content: string,
 *       address: string,
 *       img: string,
 *       date: string,
 *       status: string,
 *       category: string,
 *       userId: number,
 *       saleStatus: string,
 *       readCount: number,
 *       userName: string,
 *       sort: string,
 *       userLikes: boolean,
 *       userCollect: boolean,
 *       likesCount: number,
 *       collectCount: number
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getGoodsPageAPI = (params) => {
  return httpInstance({
    url: "/goods/selectPage",
    method: "GET",
    params,
  });
};

/**
 * @description - 前台分页查询所有商品
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {String} params.category - 分类，必填
 * @param {String} params.sort - 排序方式，必填
 * @param {String} params.name - 搜索关键词，必填
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       name: string,
 *       price: number,
 *       content: string,
 *       address: string,
 *       img: string,
 *       date: string,
 *       status: string,
 *       category: string,
 *       userId: number,
 *       saleStatus: string,
 *       readCount: number,
 *       userName: string,
 *       sort: string,
 *       userLikes: boolean,
 *       userCollect: boolean,
 *       likesCount: number,
 *       collectCount: number
 *     }>
 *   }
 * }>} 返回前台分页查询结果
 */
export const getGoodsFrontPageAPI = (params) => {
  return httpInstance({
    url: "/goods/selectFrontPage",
    method: "GET",
    params,
  });
};


/**
 * @description - 根据ID查询商品
 * @param {Number} id - 商品ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     name: string,
 *     price: number,
 *     content: string,
 *     address: string,
 *     img: string,
 *     date: string,
 *     status: string,
 *     category: string,
 *     userId: number,
 *     saleStatus: string,
 *     readCount: number,
 *     userName: string,
 *     sort: string,
 *     userLikes: boolean,
 *     userCollect: boolean,
 *     likesCount: number,
 *     collectCount: number
 *   }
 * }>} 返回商品详细信息
 */
export const getGoodsByIdAPI = (id) => {
  return httpInstance({
    url: `/goods/selectById/${id}`,
    method: "GET",
  });
};