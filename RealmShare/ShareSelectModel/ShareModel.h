//
//  ShareModel.h
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  分享内容模型
 */
@interface ShareModel : NSObject

@property (nonatomic, strong) NSString *shareUrl;//分享的URL
@property (nonatomic, strong) NSString *shareText;//分享的内容 系统自带的
@property (nonatomic, strong) NSString *shareImage;//分享的图片
@property (nonatomic, strong) NSString *shareUserText;//用户填写的内容
@property (nonatomic, strong) NSString *shareCompanyNo;//分享到公司的编号 多个用","隔开
@property (nonatomic, strong) NSString *shareUserGuid;//用户的guid
@property (nonatomic, strong) NSString *shareToken;//用户访问token
@property (nonatomic, strong) NSData *imageData;//图像数据

+ (instancetype) shareInstance;

@end
