##介绍

图文项目iOS

##软件架构
架构说明

__*全局遵循MVC模式开发*__

```

├── BookRack（书架模块）   
│　　├── BookSearh（搜索页）  
│　　├── BookRackCenter（书架首页）  
│　　├── BookDiretory（书籍目录）  
│　　├── BookDownload（书籍下载管理）  
│　　├── BookReader（阅读器）  
│　　├── LocalBookManager（本地书籍缓存）  
│　　└── Resouces（书架资源）  

├── BookMall（书城模块）   
│　　├── BookLimitFree（限免页）  
│　　├── BookComplete（完本页）  
│　　├── BookMonthly（包月页）  
│　　├── BookRankList（排行页）  
│　　├── BookClassify（分类页）  
│　　├── BookMallCenter（书城首页）  
│　　├── BookMallMore（书籍查看更多）  
│　　├── BookMallDetail（书籍详情）  
│　　├── BookComment（书籍评论）  
│　　├── InterestView（兴趣选择页面）  
│　　└── Resource（书城资源）  

├── Discover（发现模块）  

├── Mine（我的模块）  
│　　├── Task（任务中心）  
│　　├── UserData（用户个人资料页面）  
│　　├── Records（流水记录）  
│　　├── Setting（设置）  
│　　├── About（关于我们）  
│　　├── Login（登录）  
│　　├── Recharge（充值）  
│　　├── FeedBack（意见反馈）  
│　　├── BookAppraise（书评）  
│　　├── MineCenter（我的首页）  
│　　└── Resource（我的资源）  

├── BasicModule（基类相关）  
│　　├── BasicReview（过审壳存放位置）  
│　　├── BasicNav（导航基类）  
│　　├── BasicTabbar（Tabbar基类）  
│　　└── Resource（基类资源）  

├── Utils（工具类）  
│　　├── WXYZ\_Utils（主工具类）   
│　　├── WXYZ\_ColorUtils（颜色工具管理）   
│　　├── PubModel（公用Model）   
│　　└── DPNetworkRequestManager（网络请求基类）  

├── Config（全局设置）  
│　　├── SystemConfig.h（系统设置）  
│　　├── UserInfoConfig.h（主开关位置）  
│　　├── ServerConfig.h（服务端接口）  
│　　├── ColorConfig.h（全局颜色）  
│　　├── NotificationConfig.h（全局通知）  
│　　├── FrameConfig.h（全局使用frame）  
│　　├── MenoryConfig.h（记录字段）  
│　　└── ImportConfig.h（头文件导入）  

├── Verdor（三方库）  
│　　├── CountDown（限时免费计时器）  
│　　├── BookTransition（书籍打开动画类）  
│　　├── GCDDownloadManager（网络文件夹在管理类）  
│　　├── PangolinAD（穿山甲广告）  
│　　├── ShareManager（分享弹框）  
│　　├── AssistiveTouchView（悬浮广告控件）  
│　　├── CYLTabBarController（[CYLTabBarController](https://github.com/ChenYilong/CYLTabBarController)）  
│　　├── LYEmptyView（[LYEmptyView](https://github.com/dev-liyang/LYEmptyView)）  
│　　├── KLSwitch（开关按钮）  
│　　├── KSGuaidViewManager（引导页）  
│　　├── Refresh（下拉刷新控件）  
│　　├── SGPagingView（[滚动视图](https://github.com/kingsic/SGPagingView)）  
│　　├── YJBannerView（[轮播图](https://github.com/fozuyouxin/YJBannerView.-)）  
│　　├── UUID（获取设备号）  
│　　├── IAPManager（内购支付管理）  
│　　├── WeChatManager（微信功能管理类）  
│　　├── WeChatSDK（微信）  
│　　├── AliPush（阿里推送）  
│　　├── EMWaveView（波浪控件）  
│　　├── RollingADView（广告条）  
│　　├── PageViewController（翻页样式）  
│　　├── WebView（浏览器）  
│　　├── AlertView（各种场景弹框）  
│　　├── UserInfoManager（）  
│　　├── SendCodeButton（验证码发送按钮）  
│　　├── DPGDTimer（定时器）  
│　　└── DPProgressHUD（提示框）   

├── Resources（资源文件）  
├── AppDelegateCategory（Appdelegate扩展）  
│　　├── AppDelegate+CheckData（过审状态审查）  
│　　├── AppDelegate+CheckVersion（版本审查）  
│　　├── AppDelegate+Insterest（兴趣页面初始化）  
│　　├── AppDelegate+StartNumber（启动次数）  
│　　├── AppDelegate+AppSign（签到）  
│　　├── AppDelegate+RegisterView（提示注册）  
│　　├── AppDelegate+LaunchAD（启动页）  
│　　├── AppDelegate+GuidePage（引导页）  
│　　├── AppDelegate+ShortcutTouch（3D Touch）  
│　　├── AppDelegate+Score（App评分）  
│　　├── AppDelegate+UMShare（分享）  
│　　├── AppDelegate+WeChat（微信）  
│　　├── AppDelegate+AliPush（推送）  
│　　├── AppDelegate+DeviceID（设备信息上传）  
│　　├── AppDelegate+UMAnalysis（友盟统计）  
│　　└── AppDelegate+Pangolin（穿山甲初始化）   

├── AppDelegate  

└── Assets.xcassets


```
