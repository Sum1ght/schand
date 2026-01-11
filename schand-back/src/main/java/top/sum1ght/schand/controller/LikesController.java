package top.sum1ght.schand.controller;

import top.sum1ght.schand.common.Result;
import top.sum1ght.schand.entity.Likes;
import top.sum1ght.schand.service.LikesService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

@RestController
@RequestMapping("/likes")
public class LikesController {

    @Resource
    LikesService likesService;

    @PostMapping("/add")
    public Result add(@RequestBody Likes likes) {
        likesService.add(likes);
        return Result.success();
    }

}
