//
//  UserApp.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>
//用户已经选择的App
@interface UserApp : RLMObject

//网上的应用
@property (nonatomic, strong) NSString * app_guid;//应用编号
@property (nonatomic, strong) NSString * app_name;//应用名称
@property (nonatomic, strong) NSString * logo;//应用图标
@property (nonatomic, strong) NSString * app_url;//应用网址
@property (nonatomic, assign) BOOL isSelected;//是否被选中，在应用列表中有用

@end
