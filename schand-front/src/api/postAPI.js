import httpInstance from "@/utils/http";

/**
 * @description - 添加帖子
 * @param {Object} posts - 帖子信息对象
 * @param {String} posts.title - 帖子标题，必填
 * @param {String} posts.content - 帖子内容，必填
 * @param {String} [posts.img] - 帖子图片，可选
 * @param {Integer} posts.userId - 用户ID，必填
 * @param {String} posts.circle - 所属圈子，必填
 * @param {String} [posts.descr] - 帖子简介，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addPostsAPI = (posts) => {
  return httpInstance({
    url: "/posts/add",
    method: "POST",
    data: posts,
  });
};

/**
 * @description - 更新帖子
 * @param {Object} posts - 帖子信息对象
 * @param {Number} posts.id - 帖子ID，必填
 * @param {String} [posts.title] - 帖子标题，可选
 * @param {String} [posts.content] - 帖子内容，可选
 * @param {String} [posts.img] - 帖子图片，可选
 * @param {Integer} [posts.userId] - 用户ID，可选
 * @param {String} [posts.time] - 发布时间，可选
 * @param {String} [posts.circle] - 所属圈子，可选
 * @param {String} [posts.descr] - 帖子简介，可选
 * @param {Integer} [posts.readCount] - 浏览量，可选
 * @param {String} [posts.status] - 状态，可选
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updatePostsAPI = (posts) => {
  return httpInstance({
    url: "/posts/update",
    method: "PUT",
    data: posts,
  });
};

/**
 * @description - 删除帖子
 * @param {Number} id - 帖子ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回删除结果，成功时code为"200"
 */
export const deletePostsAPI = (id) => {
  return httpInstance({
    url: `/posts/delete/${id}`,
    method: "DELETE",
  });
};

/**
 * @description - 批量删除帖子
 * @param {Array<Number>} ids - 帖子ID数组
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回批量删除结果，成功时code为"200"
 */
export const deleteBatchPostsAPI = (ids) => {
  return httpInstance({
    url: "/posts/delete/batch",
    method: "DELETE",
    data: ids,
  });
};

/**
 * @description - 更新帖子阅读数
 * @param {Number} id - 帖子ID
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回更新结果，成功时code为"200"
 */
export const updatePostsCountAPI = (id) => {
  return httpInstance({
    url: `/posts/updateCount/${id}`,
    method: "PUT",
  });
};

/**
 * @description - 根据ID查询帖子
 * @param {Number} id - 帖子ID
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     id: number,
 *     title: string,
 *     content: string,
 *     img: string,
 *     userId: number,
 *     time: string,
 *     circle: string,
 *     descr: string,
 *     readCount: number,
 *     userName: string,
 *     status: string
 *   }
 * }>} 返回帖子详细信息
 */
export const getPostsByIdAPI = (id) => {
  return httpInstance({
    url: `/posts/selectById/${id}`,
    method: "GET",
  });
};

/**
 * @description - 查询所有帖子
 * @param {Object} posts - 查询条件
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: Array<{
 *     id: number,
 *     title: string,
 *     content: string,
 *     img: string,
 *     userId: number,
 *     time: string,
 *     circle: string,
 *     descr: string,
 *     readCount: number,
 *     userName: string,
 *     status: string
 *   }>
 * }>} 返回所有帖子列表
 */
export const getAllPostsAPI = (posts = {}) => {
  return httpInstance({
    url: "/posts/selectAll",
    method: "GET",
    params: posts,
  });
};

/**
 * @description - 分页查询帖子
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.posts] - 帖子查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       title: string,
 *       content: string,
 *       img: string,
 *       userId: number,
 *       time: string,
 *       circle: string,
 *       descr: string,
 *       readCount: number,
 *       userName: string,
 *       status: string
 *     }>
 *   }
 * }>} 返回分页查询结果
 */
export const getPostsPageAPI = (params) => {
  return httpInstance({
    url: "/posts/selectPage",
    method: "GET",
    params,
  });
};

/**
 * @description - 前台分页查询帖子
 * @param {Object} params - 查询参数
 * @param {Number} params.pageNum - 当前页码，必填
 * @param {Number} params.pageSize - 每页条数，必填
 * @param {Object} [params.posts] - 帖子查询条件，可选
 * @returns {Promise<{
 *   code: string,
 *   msg: string,
 *   data: {
 *     total: number,
 *     list: Array<{
 *       id: number,
 *       title: string,
 *       content: string,
 *       img: string,
 *       userId: number,
 *       time: string,
 *       circle: string,
 *       descr: string,
 *       readCount: number,
 *       userName: string,
 *       status: string
 *     }>
 *   }
 * }>} 返回前台分页查询结果
 */
export const getPostsFrontPageAPI = (params) => {
  return httpInstance({
    url: "/posts/selectFrontPage",
    method: "GET",
    params,
  });
};
