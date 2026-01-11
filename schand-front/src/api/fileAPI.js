import httpInstance from "@/utils/http";

/**
 * @description - 上传文件API
 * @param {File} file - 要上传的文件
 * @returns {Promise<{code: string, msg: string, data: string}>} 返回文件上传结果，data为文件URL
 */
export const uploadFileAPI = (file) => {
  const formData = new FormData();
  formData.append("file", file);
  return httpInstance({
    url: "/files/upload",
    method: "POST",
    data: formData,
    headers: {
      "Content-Type": "multipart/form-data",
    },
  });
};
