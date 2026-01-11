package top.sum1ght.schand.service;

import cn.hutool.core.date.DateUtil;
import top.sum1ght.schand.common.enums.RoleEnum;
import top.sum1ght.schand.common.enums.StatusEnum;
import top.sum1ght.schand.entity.Collect;
import top.sum1ght.schand.entity.Likes;
import top.sum1ght.schand.mapper.CollectMapper;
import top.sum1ght.schand.mapper.GoodsMapper;
import top.sum1ght.schand.mapper.LikesMapper;
import top.sum1ght.schand.entity.Account;
import top.sum1ght.schand.entity.Goods;
import top.sum1ght.schand.utils.TokenUtils;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 二手商品业务处理
 **/
@Service
public class GoodsService {

    @Resource
    private GoodsMapper goodsMapper;
    @Resource
    LikesMapper likesMapper;
    @Resource
    CollectMapper collectMapper;

    /**
     * 新增
     */
    public void add(Goods goods) {
        goods.setDate(DateUtil.now());
        Account currentUser = TokenUtils.getCurrentUser();
        goods.setUserId(currentUser.getId());
        goods.setStatus(StatusEnum.NOT_AUDIT.value);
        goods.setReadCount(0);
        goodsMapper.insert(goods);
    }

    /**
     * 删除
     */
    public void deleteById(Integer id) {
        goodsMapper.deleteById(id);
    }

    /**
     * 批量删除
     */
    public void deleteBatch(List<Integer> ids) {
        for (Integer id : ids) {
            goodsMapper.deleteById(id);
        }
    }

    /**
     * 修改
     */
    public void updateById(Goods goods) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (RoleEnum.USER.name().equals(currentUser.getRole())) {
            goods.setStatus(StatusEnum.NOT_AUDIT.value);
        }
        goodsMapper.updateById(goods);
    }

    /**
     * 根据ID查询
     */
    public Goods selectById(Integer id) {
        Goods goods = goodsMapper.selectById(id);

        Account currentUser = TokenUtils.getCurrentUser();
        Likes likes = likesMapper.selectByUserIdAndFid(currentUser.getId(), id);
        goods.setUserLikes(likes != null);
        int likesCount = likesMapper.selectCountByFid(id);
        goods.setLikesCount(likesCount);

        Collect collect = collectMapper.selectByUserIdAndFid(currentUser.getId(), id);
        goods.setUserCollect(collect != null);
        int collectCount = collectMapper.selectCountByFid(id);
        goods.setCollectCount(collectCount);

        return goods;
    }

    /**
     * 查询所有
     */
    public List<Goods> selectAll(Goods goods) {
        return goodsMapper.selectAll(goods);
    }

    /**
     * 分页查询
     */
    public PageInfo<Goods> selectPage(Goods goods, Integer pageNum, Integer pageSize) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (RoleEnum.USER.name().equals(currentUser.getRole())) {
            goods.setUserId(currentUser.getId());
        }
        PageHelper.startPage(pageNum, pageSize);
        List<Goods> list = goodsMapper.selectAll(goods);
        return PageInfo.of(list);
    }

    public PageInfo<Goods> selectFrontPage(Goods goods, Integer pageNum, Integer pageSize) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (RoleEnum.USER.name().equals(currentUser.getRole())) {
            goods.setUserId(currentUser.getId());
        }
        PageHelper.startPage(pageNum, pageSize);
        List<Goods> list = goodsMapper.selectFrontAll(goods);
        for (Goods g : list) {
            int likesCount = likesMapper.selectCountByFid(g.getId());
            g.setLikesCount(likesCount);
        }
        return PageInfo.of(list);
    }

    public void updateReadCount(Integer id) {
        goodsMapper.updateReadCount(id);
    }
}