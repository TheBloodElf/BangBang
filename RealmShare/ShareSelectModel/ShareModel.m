//
//  ShareModel.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ShareModel.h"

@implementation ShareModel
+ (instancetype) shareInstance
{
    static ShareModel *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [ShareModel new];
        model.shareImage = @"";
        model.shareUrl = @"";
        model.shareText = @"";
        model.shareToken = @"";
        model.shareUserText = @"";
        model.shareCompanyNo = @"";
        model.shareUserGuid = @"";
    });
    return model;
}
@end
