//
//  UtikIes.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#ifndef UtikIes_h
#define UtikIes_h

#import <UIKit/UIKit.h>
#import "DataCache.h"//简单的KEY-VALUE存储
#import "GeTuiSdk.h"//个推推送
#import "QRCodeGenerator.h"//二维码生成识别工具
#import <Bugtags/Bugtags.h>//BUG提交工具
#import "BaiduMobStat.h"//百度统计
#import <Realm/Realm.h>//新型数据库
#import <MJExtension/MJExtension.h>//JSON 对象转换工具
#import <AFNetworking/AFNetworking.h>//网络请求库
#import <MJRefresh/MJRefresh.h>//上啦刷新，下拉加载
#import "REFrostedViewController.h"//侧滑菜单
#import "NSString+isBlank.h"//字符串是否为空
#import "NSString+firstChar.h"//字符串首字母
#import "CMDeviceInfo.h"//设备信息
#import "NSObject+data.h"//运行时添加DATA属性和改变前后方法
#import "NSObject+Tips.h"//消息提示框
#import "UIImage+scale.h"//图片缩放
#import <SDWebImage/UIImageView+WebCache.h>//图片下载缓存库
#import <JTCalendar/JTCalendar.h>//日历库
#import "WebViewJavascriptBridge.h"//JS 原生交互
#import "NSDate+Format.h"//时间分类 取出时/分/秒等
#import "UIView+parentViewController.h"//找到自己所在的视图控制器
#import "InterfaceConfig.h"//网络地址配置
#import "NSString+StringSize.h"//求字符串长/高
#import <RongIMKit/RongIMKit.h>//融云
#import <AMapSearchKit/AMapSearchKit.h>//高度地图
#import <MAMapKit/MAMapKit.h>//高德地图
#import <AMapFoundationKit/AMapFoundationKit.h>//高德地图
#import "RYChatManager.h"//融云
#import "UINavigationController+Direction.h"//导航自定义方向push/pop
#import "CMMacros.h"//一些简单的block
#import "UIColor+FlatUI.h"//软件自定义颜色
#import <EventKit/EKRecurrenceRule.h>//时间规则库 每隔一天/一月/一年
#import "EKRecurrenceRule+RRULE.h"//时间规则库 每隔一天/一月/一年
#import "Scheduler.h"//时间规则库 每隔一天/一月/一年
#import "RLMObject+JSON.h"//JSON和对象转换 Realm
#import "RLMObject+Copying.h"//JSON和对象转换 Realm
#import <TencentOpenAPI/TencentOAuth.h>//腾讯
#import "WBApiManager.h"//微博
#import "WXApiManager.h"//微信
#import "IQKeyboardManager.h"//一句话解决键盘遮挡
#import "UISearchBar+BackgroundColor.h"//搜索视图背景修改
#import <AVFoundation/AVAsset.h>//IOS8前的图片相册库
#import <AssetsLibrary/AssetsLibrary.h>//IOS8前的图片相册库
#import <Photos/Photos.h>//IOS8后的图片相册库
#import <PhotosUI/PhotosUI.h>//IOS8后的图片相册库
#import <MLeaksFinder/MLeaksFinder.h>//ARC下正确检查内存泄露
#import "ReactiveCocoa.h"//决战UI必备工具
#import "UIImageView+CornerRadius.h"//离屏渲染解决方案
#import "PPDragDropBadgeView.h"//QQ消息数字拖曳消失
#import "JPEngine.h"//通过JS来创建界面
#import "UIViewController+jumpRouter.h"//控制器之间解耦 中间件来跳转

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    #import <CoreSpotlight/CoreSpotlight.h>//Spotlight搜索
    #import <MobileCoreServices/MobileCoreServices.h>
#endif

#endif /* UtikIes_h */
