//
//  ServerConfig.h
//  WXReader
//
//  Created by Andrew on 2018/5/15.
//  Copyright © 2018年 Andrew. All rights reserved.
//

#ifndef ServerConfig_h
#define ServerConfig_h

/** 网络请求默认超时时间 */
#define kOvertime 30.0f

// 书城首页
#define Book_Mall_Center @"/book/store" //频道 1-女频 2-男频

// 书籍详情
#define Book_Mall_Detail @"/book/info"

// 阅读器末尾推荐
#define Book_Endof_Recommend @"/book/end-of-recommend"

// 查看更多
#define Book_Recommend_More @"/book/recommend"

// 获取章节
#define Book_Chapter_Text @"/chapter/text"

// 下载多章节
#define Book_Download_Multiple_Chapters @"/chapter/down-url"

// 小说分类
#define Book_Category_List @"/book/category-index"

// 小说包月
#define Book_Member_Store @"/book/baoyue-index"

// 小说榜单
#define Book_Rank_List @"/rank/index" //频道 1-男频 2-女频

// 小说榜单列表
#define Book_Rank_Detail_List @"/rank/book-list"

// 小说完本
#define Book_Finish @"/book/finish"

// 限免
#define Book_Free_Time @"/book/free-time"

// 免费
#define Book_Free @"/book/free"

// 发现首页
#define Book_Discover @"/book/new-featured"

// 目录
#define Book_Catalog @"/chapter/catalog"

// 新目录
#define Book_New_Catalog @"/chapter/new-catalog"

// 评论列表
#define Book_Comment_List @"/comment/list"

// 发送评论
#define Book_Comment_Post @"/comment/post"

// 添加书籍
#define Book_Add_Collect @"/user/collect-add"

// 删除书籍
#define Book_Delete_Collect @"/user/collect-del"

// 小说书架
#define Book_Rack @"/user/book-collect"

// 批量购买章节预览页
#define Book_Buy_Index @"/chapter/buy-index"

// 购买小说章节
#define Book_Buy_Chapter @"/chapter/buy"

// 章节下载预览
#define Book_Chapter_Download_Option @"/chapter/down-option"

// 我的评论
#define Book_Comments_List @"/user/comments"

// 删除小说阅读记录
#define Book_Readlog_Delete @"/user/del-read-log"

// 换一换
#define Book_Refresh @"/book/refresh"

// 猜你喜欢换一换
#define Book_Guess_Like @"/book/guess-like"

// 搜索首页
#define Book_Search @"/book/search-index"

// 搜索内容
#define Book_Search_List @"/book/search"

// 阅读记录
#define Book_Read_Log_List @"/user/read-log"

// 增加阅读记录
#define Book_Add_Read_log @"/user/add-read-log"

// 打赏礼物给作品
#define Book_Reward_Gift_Send @"/reward/gift-send"

// 投月票
#define Book_Reward_Ticket_Vote @"/reward/ticket-vote"

// 阅读器月票封面
#define Book_Gift_Montyly_Pass @"/reward/ticket-option"

// 月票记录
#define Book_Reward_Ticket_Log @"/reward/ticket-log"

// 打赏记录
#define Book_Reward_Gift_Log @"/reward/gift-log"



/*
 漫画相关接口
 */

// 漫画查看更多
#define Comic_Recommend_More @"/comic/recommend"

// 漫画分类标签
#define Comic_Category_List @"/comic/list"

// 漫画包月
#define Comic_Member_Store @"/comic/baoyue-list"

// 漫画榜单首页
#define Comic_Rank_List @"/rank/comic-index"

// 漫画榜单作品列表
#define Comic_Rank_Detail_List @"/rank/comic-list"

// 漫画书架
#define Comic_Rack @"/fav/index"

// 漫画书城首页
#define Comic_Mall @"/comic/home-stock"

// 换一换
#define Comic_Refresh @"/comic/refresh"

// 漫画评论列表
#define Comic_Comment_List @"/comic/comment-list"

// 漫画详情
#define Comic_Detail @"/comic/info"

// 漫画详情目录
#define Comic_Catalog @"/comic/catalog"

// 漫画章节
#define Comic_Chapter @"/comic/chapter"

// 漫画弹幕
#define Comic_Barrage @"/comic/barrage"

// 发送吐槽
#define Comic_Send_Barrage @"/comic/tucao"

// 发送评论
#define Comic_Comment_Post @"/comic/post"

// 下载列表
#define Comic_DownloadOption @"/comic/down-option"

// 下载漫画
#define Comic_Download @"/comic/down"

// 发现
#define Comic_Discover @"/comic/featured"

// 书架
#define Comic_Rack @"/fav/index"

// 添加收藏
#define Comic_Collect_Add @"/fav/add"

// 删除收藏
#define Comic_Collect_Delete @"/fav/del"

// 漫画完本
#define Comic_Finish @"/comic/finish"

// 漫画限免
#define Comic_Free_Time @"/comic/free-time"

// 漫画免费
#define Comic_Free @"/comic/free"

// 我的评论
#define Comic_Comments_List @"/user/comic-comments"

// 评论详情
#define Comment_Detail @"/user/comment-info"

// 漫画搜索
#define Comic_Search @"/comic/search-index"

// 漫画搜索内容
#define Comic_Search_List @"/comic/search"

// 购买漫画章节
#define Comic_Buy_Chapter @"/comic-chapter/buy"

// 漫画章节购买预览页
#define Comic_Buy_Index @"/comic-chapter/buy-index"

// 章节下载
#define Chapter_Download @"/chapter/down"

// 漫画阅读记录
#define Comic_Read_Log_List @"/user/comic-read-log"

// 漫画添加阅读记录
#define Comic_Add_Read_Log @"/user/add-comic-read-log"

// 删除漫画阅读记录
#define Comic_Readlog_Delete @"/user/del-comic-read-log"


/*
 有声相关接口
 */

// AI 详情页
#define Ai_Audio_Detail @"/book/detail"

// 有声详情页
#define Audio_Info @"/audio/info"

// 有声书城首页
#define Audio_Mall @"/audio/index"

// 有声目录
#define Audio_Catalog @"/audio/catalog"

// 有声详情页推荐
#define Audio_Info_Recommend @"/audio/info-recommend"

// 有声播放页
#define Audio_Chapter_Info @"/audio-chapter/info"

// 有声下载
#define Audio_Chapter_Download @"/audio-chapter/down"

// 有声播放页详情
#define Audio_Chapter_Detail @"/audio-chapter/detail"

// 有声评论列表
#define Audio_Comment_List @"/audio-chapter/comment-list"

// 我的评论列表
#define Audio_Comments_List @"/user/audio-comment"

// 有声免费列表
#define Audio_Free @"/audio/free"

// 有声完结
#define Audio_Finish @"/audio/finished"

// 有声分类
#define Audio_Category_Index @"/audio/category-index"

// 有声包月
#define Audio_Member_Store @"/audio/baoyue-list"

// 有声榜单首页
#define Audio_Rank_List @"/audio/top-index"

// 有声详情页
#define Audio_Rank_Detail_List @"/audio/top-list"

// 有声添加收藏
#define Audio_Collection_Add @"/audio-fav/add"

// 有声取消收藏
#define Audio_Collection_Delete @"/audio-fav/del"

// 有声发现页
#define Audio_Discover @"/audio/new-featured"

// 添加有声记录
#define Audio_Add_Read_Log @"/audio/add-read-log"

// 有声阅读记录
#define Audio_Read_Log_List @"/user/audio-read-log"

// 有声删除评论记录
#define Audio_Readlog_Delete @"/user/audio-del-read-log"

// 有声发送评论
#define Audio_Comment_Post @"/audio-chapter/comment-post"

// 有声书架
#define Audio_Rack @"/audio-fav/user-fav"

// 有声搜索首页
#define Audio_Search @"/audio/search-index"

// 有声搜索结果
#define Audio_Search_List @"/audio/search"

// 有声购买预览
#define Audio_Buy_Index @"/audio-chapter/buy-option"

// 有声章节购买
#define Audio_Buy_Chapter @"/audio-chapter/buy"

// 有声首页换一换
#define Audio_Refresh @"/audio/refresh"

// 有声查看更多
#define Audio_Recommend_More @"/audio/recommend"

/*
 公共相关接口
 */

// 个人中心
#define User_Center @"/user/index"

// 首次启动书架增加推荐作品
#define Shelf_Recommend @"/novel/shelf-recommend"

// 会员包月
#define Member_Monthly @"/user/vip-center"

// 提交反馈
#define Sub_Feed_Back @"/answer/post-feedback"

// 阅读器礼物列表
#define Gift_List @"/reward/gift-option"

// 金币充值
#define Pay_Center @"/pay/center"

// 开通包月
#define Member_Center @"/pay/baoyue-center"

// 阅读器广告
#define Advert_Info @"/advert/info"

// 广告点击统计
#define AdVert_Click @"/advert/click"

// 会员服务协议
#define Membership_Service @"/site/membership-service"

// 软件服务协议
#define Notify_Note @"/site/notify"

// 隐私政策
#define Privacy_Policy @"/site/privacy-policy"

// 用户服务协议
#define User_Agreement @"/site/user-agreement"

// 注销协议
#define Log_Off @"/site/logoff-protocol"

// 注销账号
#define Cancel_Account @"/user/cancel-account"

// 推送提醒状态
#define User_Push_State @"/user/push-state"

// 用户修改推送提醒状态Ai_Audio_Detail
#define User_Update_Push_State @"/user/update-push-state"

// 帮助反馈
#define Answer_List @"/answer/list"

// 上传图片
#define Upload_Image @"/upload/image"

// 删除图片
#define Delete_Upload_Image @"/upload/delete-image"

// 用户反馈列表
#define Feed_Back_List @"/answer/feedback-list"

// 发送验证码
#define Send_Verification_Code @"/message/send"

// 手机号登录
#define Mobile_Login @"/user/mobile-login"

// 账号密码登录
#define Account_Login @"/user/account-login"

// 游客登录
#define Tourists_Login @"/user/device-login"

// 微信登录
#define WeChat_Login @"/user/app-login-wechat"

// QQ登录
#define QQ_Login @"/user/qq-login"

// 绑定微信
#define WeChat_Binding @"/user/app-bind-wechat"

// 绑定QQ
#define QQ_Binding @"/user/bind-qq"

// 绑定手机号
#define Phone_Binding @"/user/bind-mobile"

// 分享跳转
#define Site_Share @"/site/share"

// 分享App请求
#define App_Share @"/user/app-share"

// 分享书籍章节
#define App_Chapter_Share @"/novel/share-novel"

// 关于我们
#define About_Soft @"/service/about"

// 分享回调
#define Share_Back @"/user/share-reward"

// 签到
#define Sign_Click @"/user/sign"

// 任务中心
#define Task_Center @"/task/center"

// 消费充值记录
#define Consumption_Records @"/pay/gold-detail"

// 个人资料
#define User_Data @"/user/data"

// 上传头像
#define Set_Avatar @"/user/set-avatar"

// 上传性别
#define Set_Gender @"/user/set-gender"

// 修改昵称
#define Set_NickName @"/user/set-nickname"

// 推荐
#define Start_Recommend @"/user/start-recommend"

// 保存推荐
#define Save_Recommed @"/user/save-recommend"

// 完成任务两本书
#define Task_Read @"/user/task-read"

// 自动订阅下一章
#define Auto_Sub_Chapter @"/user/auto-sub"

// 苹果支付验证
#define Apple_Pay_Back @"/pay/applepay"

// 拉取系统配置
#define Check_Setting @"/service/check-setting"

// 上传设备号
#define Upload_Device_Info @"/user/sync-device"





//漫画作者收藏
#define Comic_Auctor_colloc @"/fav/collect-author"

//漫画取消作者收藏
#define Comic_Del_Auctor_colloc @"/fav/dell-author"

//漫画原著收藏
#define Comic_Original_colloc @"/fav/collect-original"

//漫画取消原著收藏
#define Comic_Del_Original_colloc @"/fav/dell-original"


//漫画汉化组收藏
#define Comic_sinici_colloc @"/fav/collect-sinici"

//漫画取消汉化组收藏
#define Comic_Del_sinici_colloc @"/fav/dell-sinici"

//我喜欢的作者
#define MyLikeAuthor  @"/fav/my-author"

//我喜欢的原著
#define MyLikeOriginal  @"/fav/my-original"

//我喜欢的汉化组
#define MyLikeSinici  @"/fav/my-sinici"

//我喜欢的作者
#define MyLikeAuthorList  @"/comic/list-by-author"

//我喜欢的原著
#define MyLikeOriginalList  @"/comic/list-by-original"

//我喜欢的汉化组
#define MyLikeSiniciList  @"/comic/list-by-sinici"

//标签列表
#define MyTagList @"/category/category-list"
//标签对应的漫画列表
#define TagBookList @"/comic/list-by-sort"

#define ClassTagList @"/comic/list-by-tags";

#endif /* ServerConfig_h */
