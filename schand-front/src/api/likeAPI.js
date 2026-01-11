import httpInstance from "@/utils/http";

// 点赞相关API

/**
 * @description - 添加点赞
 * @param {Object} likes - 点赞信息对象
 * @param {Number} likes.fid - 被点赞内容ID，必填
 * @param {String} likes.module - 模块名称，必填
 * @returns {Promise<{code: string, msg: string, data: null}>} 返回添加结果，成功时code为"200"
 */
export const addLikesAPI = (likes) => {
  return httpInstance({
    url: "/likes/add",
    method: "POST",
    data: likes,
  });
};
