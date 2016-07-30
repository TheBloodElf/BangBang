//
//  ShareContentController.h
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ShareType) {
    ShareTypeDynamic = 0,//动态
    ShareTypeMeet        //会议
};

@interface ShareContentController : UIViewController
//分享类型
@property (nonatomic, assign) ShareType shareType;

@end
