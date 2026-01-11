// 订单相关API
import httpInstance from "@/utils/http";

/**
 * @description - 获取用户购买的订单列表
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {String} [params.goodsName] - 商品名称，可选
 * @param {String} [params.status] - 订单状态，可选
 * @param {String} [params.orderNo] - 订单编号，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       orderNo: string,
 *       goodsId: number,
 *       goodsName: string,
 *       goodsPrice: number,
 *       status: string,
 *       userId: number,
 *       userName: string,
 *       sellerId: number,
 *       sellerName: string,
 *       address: string,
 *       totalPrice: number,
 *       createTime: string
 *     }>
 *   }
 * }>} 返回订单列表数据
 */
export const getUserOrdersAPI = (params) => {
  return httpInstance({
    url: "/orders/selectPage",
    method: "GET",
    params,
  });
};

/**
 * @description - 获取用户出售的订单列表
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {String} [params.goodsName] - 商品名称，可选
 * @param {String} [params.status] - 订单状态，可选
 * @param {String} [params.orderNo] - 订单编号，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       orderNo: string,
 *       goodsId: number,
 *       goodsName: string,
 *       goodsPrice: number,
 *       status: string,
 *       userId: number,
 *       userName: string,
 *       sellerId: number,
 *       sellerName: string,
 *       address: string,
 *       totalPrice: number,
 *       createTime: string
 *     }>
 *   }
 * }>} 返回订单列表数据
 */
export const getUserSaleOrdersAPI = (params) => {
  return httpInstance({
    url: "/orders/selectSalePage",
    method: "GET",
    params,
  });
};

/**
 * @description - 更新订单状态
 * @param {Object} orders - 订单信息对象
 * @param {Number} orders.id - 订单ID，必填
 * @param {String} [orders.goodsName] - 商品名称，可选
 * @param {String} [orders.goodsImg] - 商品图片，可选
 * @param {String} [orders.orderNo] - 订单编号，可选
 * @param {Number} [orders.total] - 总价，可选
 * @param {String} [orders.time] - 下单时间，可选
 * @param {String} [orders.payNo] - 支付单号，可选
 * @param {String} [orders.payTime] - 支付时间，可选
 * @param {Integer} [orders.userId] - 下单人ID，可选
 * @param {String} [orders.address] - 收货地址，可选
 * @param {String} [orders.phone] - 联系方式，可选
 * @param {String} [orders.userName] - 收货人名称，可选
 * @param {String} [orders.status] - 订单状态，可选
 * @param {Integer} [orders.saleId] - 卖家ID，可选
 * @param {Integer} [orders.goodsId] - 商品ID，可选
 * @param {Integer} [orders.addressId] - 地址ID，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updateOrderAPI = (orders) => {
  return httpInstance({
    url: "/orders/update",
    method: "PUT",
    data: orders,
  });
};

/**
 * @description - 添加订单
 * @param {Object} orders - 订单信息对象
 * @param {String} orders.goodsName - 商品名称，必填
 * @param {Integer} [orders.addressId] - 地址ID，必填
 * @param {String} [orders.goodsImg] - 商品图片，可选
 * @param {String} [orders.orderNo] - 订单编号，可选
 * @param {Number} [orders.total] - 总价，必填
 * @param {Integer} [orders.userId] - 下单人ID，必填
 * @param {String} [orders.address] - 收货地址，必填
 * @param {String} [orders.phone] - 联系方式，必填
 * @param {String} [orders.userName] - 收货人名称，必填
 * @param {Integer} [orders.saleId] - 卖家ID，必填
 * @param {Integer} [orders.goodsId] - 商品ID，必填
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addOrderAPI = (orders) => {
  return httpInstance({
    url: "/orders/add",
    method: "POST",
    data: orders,
  });
};

/**
 * @description - 删除订单
 * @param {Number} id - 订单ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deleteOrderAPI = (id) => {
  return httpInstance({
    url: `/orders/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除订单
 * @param {Array<Number>} ids - 订单ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchOrderAPI = (ids) => {
  return httpInstance({
    url: "/orders/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 根据ID查询订单
 * @param {Number} id - 订单ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     goodsName: string,
 *     goodsImg: string,
 *     orderNo: string,
 *     total: number,
 *     time: string,
 *     payNo: string,
 *     payTime: string,
 *     userId: number,
 *     address: string,
 *     phone: string,
 *     userName: string,
 *     status: string,
 *     saleId: number,
 *     goodsId: number,
 *     addressId: number,
 *     user: string,
 *     saleName: string
 *   }
 * }>} 返回订单详细信息
 */
export const getOrderByIdAPI = (id) => {
  return httpInstance({
    url: `/orders/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有订单
 * @param {Object} [orders] - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     goodsName: string,
 *     goodsImg: string,
 *     orderNo: string,
 *     total: number,
 *     time: string,
 *     payNo: string,
 *     payTime: string,
 *     userId: number,
 *     address: string,
 *     phone: string,
 *     userName: string,
 *     status: string,
 *     saleId: number,
 *     goodsId: number,
 *     addressId: number,
 *     user: string,
 *     saleName: string
 *   }>
 * }>} 返回所有订单列表
 */
export const getAllOrdersAPI = (orders = {}) => {
  return httpInstance({
    url: "/orders/selectAll",
    method: "GET",
    params: orders,
  });
};

/**
 * @description - 分页查询订单
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.orders] - 订单查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       goodsName: string,
 *       goodsImg: string,
 *       orderNo: string,
 *       total: number,
 *       time: string,
 *       payNo: string,
 *       payTime: string,
 *       userId: number,
 *       address: string,
 *       phone: string,
 *       userName: string,
 *       status: string,
 *       saleId: number,
 *       goodsId: number,
 *       addressId: number,
 *       user: string,
 *       saleName: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getOrderPageAPI = (params) => {
  return httpInstance({
    url: "/orders/selectPage",
    method: "GET",
    params,
  });
};

/**
 * @description - 查询卖家订单分页数据
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.orders] - 订单查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       goodsName: string,
 *       goodsImg: string,
 *       orderNo: string,
 *       total: number,
 *       time: string,
 *       payNo: string,
 *       payTime: string,
 *       userId: number,
 *       address: string,
 *       phone: string,
 *       userName: string,
 *       status: string,
 *       saleId: number,
 *       goodsId: number,
 *       addressId: number,
 *       user: string,
 *       saleName: string
 *     }>
 *   }
 * }>} 返回卖家分页查询结果
 */
export const getOrderSalePageAPI = (params) => {
  return httpInstance({
    url: "/orders/selectSalePage",
    method: "GET",
    params,
  });
};

/**
 * @description - 查询订单折线图数据
 * @returns {Promise<{
 *   code: string,    
 *   msg: string,    
 *   data: Array<{    
 *     name: string,  // 用户姓名
 *     value: number  // 订单总金额
 *   }>
 * }>} 返回折线图数据
 */
export const getOrderLineAPI = () => {
  return httpInstance({
    url: "/orders/selectLine",
    method: "GET",
  });
};

/**
 * @description - 查询订单柱状图数据
 * @returns {Promise<{
 *   code: string,    
 *   msg: string,     
 *   data: Array<{    // 柱状图数据数组
 *     name: string,  // 日期
 *     value: number  // 销售额
 *   }>
 * }>} 返回柱状图数据
 */
export const getOrderBarAPI = () => {
  return httpInstance({
    url: "/orders/selectBar",
    method: "GET",
  });
};

//// 弃用
// /**
//  * @description - 获取支付订单的URL
//  * @param {String} orderNo - 订单编号
//  * @returns {String} 返回支付URL
//  */
// export const getPayUrlAPI = (orderNo) => {
//   return `http://localhost:9090/alipay/pay?orderNo=${orderNo}`;
// };
