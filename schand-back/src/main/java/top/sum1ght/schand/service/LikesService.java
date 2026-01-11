package top.sum1ght.schand.service;

import top.sum1ght.schand.entity.Account;
import top.sum1ght.schand.entity.Likes;
import top.sum1ght.schand.mapper.LikesMapper;
import top.sum1ght.schand.utils.TokenUtils;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;

@Service
public class LikesService {

    @Resource
    LikesMapper likesMapper;

    public void add(Likes likes) {
        Account currentUser = TokenUtils.getCurrentUser();
        Integer userId = currentUser.getId();
        Integer fid = likes.getFid();
        Likes dbLikes = likesMapper.selectByUserIdAndFid(userId, fid);
        if (dbLikes != null) {
            likesMapper.deleteById(dbLikes.getId());
        } else {
            likes.setUserId(userId);
            likesMapper.insert(likes);
        }
    }

}
