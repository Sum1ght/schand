package top.sum1ght.schand.controller;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.io.FileUtil;
import cn.hutool.core.lang.Dict;
import cn.hutool.core.util.StrUtil;
import top.sum1ght.schand.common.Result;
import top.sum1ght.schand.common.enums.ResultCodeEnum;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.OutputStream;
import java.net.URLEncoder;

/**
 * 文件接口
 */
@RestController
@RequestMapping("/files")
public class FileController {

    // 文件上传存储路径
    private static final String filePath = System.getProperty("user.dir") + "/files/";

    @Value("${server.port:9090}")
    private String port;

    @Value("${ip:localhost}")
    private String ip;

    /**
     * 文件上传
     */
    @PostMapping("/upload")
    public Result upload(MultipartFile file) {
        // 移除时间戳生成，直接使用原始文件名
        String fileName = file.getOriginalFilename();
        try {
            if (!FileUtil.isDirectory(filePath)) {
                FileUtil.mkdir(filePath);
            }
            // 直接使用原始文件名存储
            FileUtil.writeBytes(file.getBytes(), filePath + fileName);
            System.out.println(fileName + "--上传成功");

        } catch (Exception e) {
            System.err.println(fileName + "--文件上传失败: " + e.getMessage());
            e.printStackTrace();
            return Result.error(ResultCodeEnum.SYSTEM_ERROR);
        }
        String http = "http://" + ip + ":" + port + "/files/";
        return Result.success(http + fileName);
    }

    /**
     * 富文本文件上传
     */
    @PostMapping("/editor/upload")
    public Dict editorUpload(MultipartFile file) {
        // 富文本编辑器需要唯一文件名，保留时间戳
        String flag = System.currentTimeMillis() + "";
        String fileName = file.getOriginalFilename();
        try {
            if (!FileUtil.isDirectory(filePath)) {
                FileUtil.mkdir(filePath);
            }
            // 富文本编辑器保留时间戳前缀以避免文件名冲突
            FileUtil.writeBytes(file.getBytes(), filePath + flag + "-" + fileName);
            System.out.println(fileName + "--上传成功");

        } catch (Exception e) {
            System.err.println(fileName + "--文件上传失败: " + e.getMessage());
            e.printStackTrace();
            return Dict.create().set("errno", 1).set("message", "上传失败");
        }
        String http = "http://" + ip + ":" + port + "/files/";
        return Dict.create().set("errno", 0).set("data", CollUtil.newArrayList(Dict.create().set("url", http + flag + "-" + fileName)));
    }


    /**
     * 获取文件
     *
     * @param flag
     * @param response
     */
    @GetMapping("/{flag}")
    public void avatarPath(@PathVariable String flag, HttpServletResponse response) {
        OutputStream os;
        try {
            if (StrUtil.isNotEmpty(flag)) {
                response.addHeader("Content-Disposition", "attachment;filename=" + URLEncoder.encode(flag, "UTF-8"));
                response.setContentType("application/octet-stream");
                // 读取具体文件
                byte[] bytes = FileUtil.readBytes(filePath + flag);
                os = response.getOutputStream();
                os.write(bytes);
                os.flush();
                os.close();
            }
        } catch (Exception e) {
            System.out.println("文件下载失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 删除文件
     *
     * @param flag
     */
    @DeleteMapping("/{flag}")
    public void delFile(@PathVariable String flag) {
        FileUtil.del(filePath + flag);
        System.out.println("删除文件" + flag + "成功");
    }
}
