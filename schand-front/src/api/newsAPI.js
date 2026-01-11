import httpInstance from "@/utils/newsHttp";

/**
 * @description - 获取头条新闻列表
 * @returns {Promise<{
 *   code: number,
 *   name: string,
 *   title: string,
 *   type: string,
 *   link: string,
 *   total: number,
 *   fromCache: boolean,
 *   updateTime: string,
 *   data: Array<{
 *     id: string,
 *     title: string,
 *     cover: string,
 *     timestamp: number,
 *     hot: number,
 *     url: string,
 *     mobileUrl: string
 *   }>
 * }>} 返回头条新闻列表
 */

/**
 * @description - 获取知乎热点新闻列表
 * @returns {Promise<{
 *   status: string,
 *   id: string,
 *   updatedTime: number,
 *   items: Array<{
 *     id: string,
 *     title: string,
 *     extra: {
 *       icon: string
 *     },
 *     url: string
 *   }>
 * }>} 返回知乎热点新闻列表
 */

/**
 * @description - 获取华尔街见闻热点新闻列表
 * @returns {Promise<{
 *   status: string,
 *   id: string,
 *   updatedTime: number,
 *   items: Array<{
 *     id: number,
 *     title: string,
 *     url: string
 *   }>
 * }>} 返回华尔街见闻热点新闻列表
 */

/**
 * @description - 获取微博热点新闻列表
 * @returns {Promise<{
 *   status: string,
 *   id: string,
 *   updatedTime: number,
 *   items: Array<{
 *     id: string,
 *     title: string,
 *     extra: {
 *       icon: {
 *         url: string,
 *         scale: number
 *       }
 *     },
 *     url: string,
 *     mobileUrl: string
 *   }>
 * }>} 返回微博热点新闻列表
 */

// API密钥
const APIKEY = {
  weibo: "36de5db81215",
  zhihu: "36de5db81215",
  wallstreetcn: "36de5db81215",
};

// 模拟数据，在API请求失败时使用
const MOCK_DATA = {
  weibo: {
    items: [
      {
        title: "黄杨钿甜爸爸发文",
        url: "https://s.weibo.com/weibo?q=%23%E9%BB%84%E6%9D%A8%E9%92%BF%E7%94%9C%E7%88%B8%E7%88%B8%E5%8F%91%E6%96%87%23",
      },
      {
        title: "山姆绿豆糕",
        url: "https://s.weibo.com/weibo?q=%E5%B1%B1%E5%A7%86%E7%BB%BF%E8%B1%86%E7%B3%95",
      },
      {
        title: "欢迎来看热情活力的中国",
        url: "https://s.weibo.com/weibo?q=%23%E6%AC%A2%E8%BF%8E%E6%9D%A5%E7%9C%8B%E7%83%AD%E6%83%85%E6%B4%BB%E5%8A%9B%E7%9A%84%E4%B8%AD%E5%9B%BD%23",
      },
      {
        title: "歌手直播",
        url: "https://s.weibo.com/weibo?q=%E6%AD%8C%E6%89%8B%E7%9B%B4%E6%92%AD",
      },
      {
        title: "2024年平均工资出炉",
        url: "https://s.weibo.com/weibo?q=%232024%E5%B9%B4%E5%B9%B3%E5%9D%87%E5%B7%A5%E8%B5%84%E5%87%BA%E7%82%89%23",
      },
      {
        title: "蓝天立被查",
        url: "https://s.weibo.com/weibo?q=%23%E8%93%9D%E5%A4%A9%E7%AB%8B%E8%A2%AB%E6%9F%A5%23",
      },
      {
        title: "单依纯ladygaga时候",
        url: "https://s.weibo.com/weibo?q=%E5%8D%95%E4%BE%9D%E7%BA%AFladygaga%E6%97%B6%E5%80%99",
      },
      {
        title: "黄杨爸爸说耳环不是正品",
        url: "https://s.weibo.com/weibo?q=%23%E9%BB%84%E6%9D%A8%E7%88%B8%E7%88%B8%E8%AF%B4%E8%80%B3%E7%8E%AF%E4%B8%8D%E6%98%AF%E6%AD%A3%E5%93%81%23",
      },
      {
        title: "云南地震",
        url: "https://s.weibo.com/weibo?q=%E4%BA%91%E5%8D%97%E5%9C%B0%E9%9C%87",
      },
      {
        title: "天猫国补买空调首次能叠千元券",
        url: "https://s.weibo.com/weibo?q=%23%E5%A4%A9%E7%8C%AB%E5%9B%BD%E8%A1%A5%E4%B9%B0%E7%A9%BA%E8%B0%83%E9%A6%96%E6%AC%A1%E8%83%BD%E5%8F%A0%E5%8D%83%E5%85%83%E5%88%B8%23",
      },
      {
        title: "歌手开场 高级",
        url: "https://s.weibo.com/weibo?q=%E6%AD%8C%E6%89%8B%E5%BC%80%E5%9C%BA%20%E9%AB%98%E7%BA%A7",
      },
      {
        title: "618发券力度都向天猫看齐",
        url: "https://s.weibo.com/weibo?q=%23618%E5%8F%91%E5%88%B8%E5%8A%9B%E5%BA%A6%E9%83%BD%E5%90%91%E5%A4%A9%E7%8C%AB%E7%9C%8B%E9%BD%90%23",
      },
      {
        title: "刘宇宁 顺眼",
        url: "https://s.weibo.com/weibo?q=%E5%88%98%E5%AE%87%E5%AE%81%20%E9%A1%BA%E7%9C%BC",
      },
      {
        title: "vivo影像技术升级掌控歌手名场面",
        url: "https://s.weibo.com/weibo?q=%23vivo%E5%BD%B1%E5%83%8F%E6%8A%80%E6%9C%AF%E5%8D%87%E7%BA%A7%E6%8E%8C%E6%8E%A7%E6%AD%8C%E6%89%8B%E5%90%8D%E5%9C%BA%E9%9D%A2%23",
      },
      {
        title: "蔚来ET9技术下放新ES6新EC6",
        url: "https://s.weibo.com/weibo?q=%23%E8%94%9A%E6%9D%A5ET9%E6%8A%80%E6%9C%AF%E4%B8%8B%E6%94%BE%E6%96%B0ES6%E6%96%B0EC6%23",
      },
      {
        title: "那英说单依纯比她强多了",
        url: "https://s.weibo.com/weibo?q=%23%E9%82%A3%E8%8B%B1%E8%AF%B4%E5%8D%95%E4%BE%9D%E7%BA%AF%E6%AF%94%E5%A5%B9%E5%BC%BA%E5%A4%9A%E4%BA%86%23",
      },
      {
        title: "洗衣做饭20年女子离婚被判8万补偿",
        url: "https://s.weibo.com/weibo?q=%23%E6%B4%97%E8%A1%A3%E5%81%9A%E9%A5%AD20%E5%B9%B4%E5%A5%B3%E5%AD%90%E7%A6%BB%E5%A9%9A%E8%A2%AB%E5%88%A48%E4%B8%87%E8%A1%A5%E5%81%BF%23",
      },
      {
        title: "谁最有可能在歌手首期被淘汰",
        url: "https://s.weibo.com/weibo?q=%E8%B0%81%E6%9C%80%E6%9C%89%E5%8F%AF%E8%83%BD%E5%9C%A8%E6%AD%8C%E6%89%8B%E9%A6%96%E6%9C%9F%E8%A2%AB%E6%B7%98%E6%B1%B0",
      },
      {
        title: "植物是如何适应塔克拉玛干气候的",
        url: "https://s.weibo.com/weibo?q=%E6%A4%8D%E7%89%A9%E6%98%AF%E5%A6%82%E4%BD%95%E9%80%82%E5%BA%94%E5%A1%94%E5%85%8B%E6%8B%89%E7%8E%9B%E5%B9%B2%E6%B0%94%E5%80%99%E7%9A%84",
      },
      {
        title: "碎纸机里都可能暗藏窃密设备",
        url: "https://s.weibo.com/weibo?q=%23%E7%A2%8E%E7%BA%B8%E6%9C%BA%E9%87%8C%E9%83%BD%E5%8F%AF%E8%83%BD%E6%9A%97%E8%97%8F%E7%AA%83%E5%AF%86%E8%AE%BE%E5%A4%87%23",
      },
    ],
  },
  wallstreetcn: {
    items: [
      {
        title:
          "数据强化降息预期，美债回升，标普四连阳，纳指终结六连涨，阿里跌超7%，黄金大反弹",
        url: "https://wallstreetcn.com/articles/3747148",
      },
      {
        title:
          "鲍威尔：将重新评估2020版货币政策框架的「关键部分」，长期利率可能走高，「供应冲击」或成新常态",
        url: "https://wallstreetcn.com/articles/3747185",
      },
      {
        title: "华尔街见闻早餐FM-Radio | 2025年5月16日",
        url: "https://wallstreetcn.com/articles/3747206",
      },
      {
        title: "巴菲特、索罗斯、盖茨，看看大佬们买了点啥",
        url: "https://wallstreetcn.com/articles/3747226",
      },
      {
        title: "美联储的框架就像跳楼机",
        url: "https://wallstreetcn.com/articles/3747210",
      },
      {
        title:
          "伯克希尔Q1大砍银行股，清仓花旗，苹果持股未变，啤酒制造商持仓翻倍，存保密仓位",
        url: "https://wallstreetcn.com/articles/3747202",
      },
      {
        title:
          "阿里电话会：云业务增长主要靠AI需求带动，未来几个季度仍处于上升通道，将把更多淘宝用户转化为即时零售用户",
        url: "https://wallstreetcn.com/articles/3747182",
      },
      {
        title: "美国4月PPI同比上涨2.4%低于预期，环比-0.5%，降幅创下五年来最大!",
        url: "https://wallstreetcn.com/articles/3747184",
      },
      {
        title:
          "当下最火的问题：美股反弹到头了吗？摩根大通市场部门：还没有，这真让人痛苦",
        url: "https://wallstreetcn.com/articles/3747222",
      },
      {
        title: "财报后股价大跌，大摩发声：阿里云的增长逻辑没有变化！",
        url: "https://wallstreetcn.com/articles/3747208",
      },
    ],
  },
  zhihu: {
    items: [
      {
        title:
          "法拉利 CEO 称「车内屏幕多无用，你是开车不是看电视」，如何看待这一说法？",
        url: "https://www.zhihu.com/question/1906325804922693263",
      },
      {
        title: "哪个知名演员演砸了经典角色，导致事业跌落?",
        url: "https://www.zhihu.com/question/1905786782747985218",
      },
      {
        title:
          "发现同事请的病假是假的，医院开来的证明也是假的，要不要告诉领导？",
        url: "https://www.zhihu.com/question/1905378175636210729",
      },
      {
        title:
          "《碟中谍 8》内地定档 5 月 30 日上映并发布定档预告，对于这部电影你有哪些期待？",
        url: "https://www.zhihu.com/question/1906660105337923202",
      },
      {
        title: "为什么新发现的血型被命名为「郴州市第三人民医院」？",
        url: "https://www.zhihu.com/question/1906025227013588091",
      },
      {
        title: "为什么抱 10kg 的小孩比抱 10kg 的大米，感觉上要轻？",
        url: "https://www.zhihu.com/question/2445357217",
      },
      {
        title:
          "盒马无抗鸡蛋被检出兽药超标，供应商却表示复检合格，这究竟是怎么回事？吃这种鸡蛋会给身体带来哪些危害？",
        url: "https://www.zhihu.com/question/1905637389608682289",
      },
      {
        title:
          "互降关税后，中国至美国集装箱运输预订量飙升近 300%，关税调整对双边贸易的刺激效应有多大？",
        url: "https://www.zhihu.com/question/1906285899400061077",
      },
      {
        title:
          "王阳明真迹拍卖出 1.09 亿人民币天价，为什么能拍出这么高的价格？有哪些艺术价值？",
        url: "https://www.zhihu.com/question/1906324177008423392",
      },
      {
        title: "为什么领导总是分不清谁才是真正干活的人？",
        url: "https://www.zhihu.com/question/1906667707656561422",
      },
      {
        title:
          "演员黄杨钿甜戴 230 万耳环，网友质疑其父亲曾为公务员高额消费不合理，当地政府已介入，具体情况如何？",
        url: "https://www.zhihu.com/question/1906306855669602018",
      },
      {
        title: "如何评价庵野秀明？",
        url: "https://www.zhihu.com/question/27081935",
      },
      {
        title: "你有哪些很少人知道的开车技巧？",
        url: "https://www.zhihu.com/question/404035188",
      },
      {
        title:
          "如果你的两个领导都离职了，部门里只剩你一个人，老板要你交接他们俩的工作并没有给你升职加薪，该怎么做?",
        url: "https://www.zhihu.com/question/1905740770884945400",
      },
      {
        title: "有哪些故意缩短产品寿命的设计？",
        url: "https://www.zhihu.com/question/308056725",
      },
      {
        title:
          "为什么国家卫健委对肖某是吊销医师执业证书，对董某莹是撤销？有什么区别？",
        url: "https://www.zhihu.com/question/1906445269983261610",
      },
      {
        title: "在小公司，我一个人要做三个人的工作，还不涨工资，要辞职吗?",
        url: "https://www.zhihu.com/question/1889210942656602500",
      },
      {
        title:
          "如何评价新发布的联想拯救者平板 Y700 四代，这一代有哪些显著升级？",
        url: "https://www.zhihu.com/question/1906662604987930009",
      },
      {
        title: "有没有新能源车主来发表一下自己买的车以及优缺点?",
        url: "https://www.zhihu.com/question/1903788024959041820",
      },
      {
        title: "研究生（刚进组）怎么读文献?",
        url: "https://www.zhihu.com/question/403085395",
      },
    ],
  },
};

// 获取新闻列表，在API请求失败时使用模拟数据
export const getNewsList = async (param) => {
  try {
    const res = await httpInstance({
      url: `/${param}`,
      method: "GET",
      params: {
        key: APIKEY[param],
      },
    });
    return res;
  } catch (error) {
    console.error(`获取${param}新闻列表失败，使用模拟数据:`, error);
    // 返回模拟数据
    return MOCK_DATA[param] || { items: [] };
  }
};
