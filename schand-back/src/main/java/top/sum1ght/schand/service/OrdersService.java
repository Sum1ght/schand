package top.sum1ght.schand.service;

import cn.hutool.core.date.DateField;
import cn.hutool.core.date.DateTime;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.lang.Dict;
import cn.hutool.core.util.RandomUtil;
import top.sum1ght.schand.common.enums.OrderStatusEnum;
import top.sum1ght.schand.common.enums.RoleEnum;
import top.sum1ght.schand.entity.Account;
import top.sum1ght.schand.entity.Address;
import top.sum1ght.schand.entity.Goods;
import top.sum1ght.schand.entity.Orders;
import top.sum1ght.schand.mapper.OrdersMapper;
import top.sum1ght.schand.utils.TokenUtils;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import javax.annotation.Resource;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 订单信息业务处理
 **/
@Service
public class OrdersService {

    @Resource
    private OrdersMapper ordersMapper;
    @Resource
    GoodsService goodsService;
    @Resource
    AddressService addressService;

    /**
     * 新增
     */
    public void add(Orders orders) {
        Integer goodsId = orders.getGoodsId();
        Goods goods = goodsService.selectById(goodsId);
        orders.setGoodsName(goods.getName());
        orders.setGoodsImg(goods.getImg());
        orders.setSaleId(goods.getUserId());  //卖家用户ID
        orders.setTotal(goods.getPrice());

        Integer addressId = orders.getAddressId();
        Address address = addressService.selectById(addressId);
        orders.setAddress(address.getAddress());
        orders.setPhone(address.getPhone());

        Account currentUser = TokenUtils.getCurrentUser();
        orders.setUserId(currentUser.getId());  //下单人的ID
        orders.setStatus(OrderStatusEnum.NOTPAY.value); // 订单默认是待支付
        orders.setOrderNo(System.currentTimeMillis() + RandomUtil.randomNumbers(7)); // 20位的订单号
        orders.setTime(DateUtil.now());

        ordersMapper.insert(orders);
    }

    /**
     * 删除
     */
    public void deleteById(Integer id) {
        ordersMapper.deleteById(id);
    }

    /**
     * 批量删除
     */
    public void deleteBatch(List<Integer> ids) {
        for (Integer id : ids) {
            ordersMapper.deleteById(id);
        }
    }

    /**
     * 修改
     */
    public void updateById(Orders orders) {
        ordersMapper.updateById(orders);
    }

    /**
     * 根据ID查询
     */
    public Orders selectById(Integer id) {
        return ordersMapper.selectById(id);
    }

    /**
     * 查询所有
     */
    public List<Orders> selectAll(Orders orders) {
        return ordersMapper.selectAll(orders);
    }

    /**
     * 分页查询
     */
    public PageInfo<Orders> selectPage(Orders orders, Integer pageNum, Integer pageSize) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (RoleEnum.USER.name().equals(currentUser.getRole())) {
            orders.setUserId(currentUser.getId());
        }
        PageHelper.startPage(pageNum, pageSize);
        List<Orders> list = ordersMapper.selectAll(orders);
        return PageInfo.of(list);
    }

    public Orders selectByOrderNo(String orderNo) {
        return ordersMapper.selectByOrderNo(orderNo);
    }

    public PageInfo<Orders> selectSalePage(Orders orders, Integer pageNum, Integer pageSize) {
        Account currentUser = TokenUtils.getCurrentUser();
        if (RoleEnum.USER.name().equals(currentUser.getRole())) {
            orders.setSaleId(currentUser.getId());
        }
        PageHelper.startPage(pageNum, pageSize);
        List<Orders> list = ordersMapper.selectAll(orders);
        return PageInfo.of(list);
    }

    public List<Dict> selectLine() {
        List<Dict> dictList = new ArrayList<>();
        // 获取所有订单，不再只过滤已完成的
        List<Orders> ordersList = ordersMapper.selectAll(null);
        
        // 增加时间范围到30天
        Date date = new Date();
        DateTime start = DateUtil.offsetDay(date, -30);
        DateTime end = DateUtil.offsetDay(date, -1);
        List<DateTime> dateTimes = DateUtil.rangeToList(start, end, DateField.DAY_OF_YEAR);
        List<String> dateList = dateTimes.stream().map(DateUtil::formatDate).sorted(Comparator.naturalOrder()).collect(Collectors.toList());
        
        // 添加当天
        dateList.add(DateUtil.formatDate(date));
        
        for (String day : dateList) {
            // 统计当天所有订单（包括所有状态）
            BigDecimal total = ordersList.stream()
                    .filter(orders -> orders.getTime() != null && orders.getTime().contains(day))
                    .map(Orders::getTotal)
                    .reduce(BigDecimal::add)
                    .orElse(BigDecimal.ZERO);
            
            Dict dict = Dict.create().set("name", day).set("value", total);
            dictList.add(dict);
        }
        return dictList;
    }

    public List<Dict> selectBar() {
        List<Dict> dictList = new ArrayList<>();
        // 获取所有订单，不再只过滤已完成的
        List<Orders> ordersList = ordersMapper.selectAll(null);
        
        // 使用买家ID而非卖家进行分组
        Map<Integer, String> userNameMap = new HashMap<>();
        Map<Integer, BigDecimal> userTotalMap = new HashMap<>();
        
        for (Orders order : ordersList) {
            Integer userId = order.getUserId();
            if (userId != null) {
                // 累加用户的订单金额
                BigDecimal currentTotal = userTotalMap.getOrDefault(userId, BigDecimal.ZERO);
                userTotalMap.put(userId, currentTotal.add(order.getTotal()));
                
                // 记录用户名，使用买家名
                if (!userNameMap.containsKey(userId)) {
                    // 优先使用user字段，如果为空则使用"用户ID:XX"
                    String userName = order.getUser();
                    if (userName == null || userName.isEmpty()) {
                        userName = "用户ID:" + userId;
                    }
                    userNameMap.put(userId, userName);
                }
            }
        }
        
        // 构建结果
        for (Map.Entry<Integer, BigDecimal> entry : userTotalMap.entrySet()) {
            Integer userId = entry.getKey();
            BigDecimal total = entry.getValue();
            String userName = userNameMap.get(userId);
            
            Dict dict = Dict.create().set("name", userName).set("value", total);
            dictList.add(dict);
        }
        
        return dictList;
    }
}