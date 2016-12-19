//
//  Identity.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

//用来判断是否登录的 不存在数据库 归档处理
@interface Identity : NSObject

//当前登录的用户guid
@property (nonatomic, copy) NSString *user_guid;
//是否需要展示介绍页
@property (nonatomic, assign) BOOL firstUseSoft;
//是否需要展示引导页
//@property (nonatomic, assign) BOOL bootOfUse;
//上一次软件的版本号
@property (nonatomic, strong) NSString *lastSoftVersion;
//请求接口的token
@property (nonatomic, copy) NSString *accessToken;
//推送的设备标示符号
@property (nonatomic, copy) NSString *deviceIDAPNS;

@end
