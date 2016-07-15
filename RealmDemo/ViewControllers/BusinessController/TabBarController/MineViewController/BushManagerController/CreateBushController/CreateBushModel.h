//
//  CreateBushModel.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  创建圈子页面的圈子模型
 */
@interface CreateBushModel : NSObject

@property (nonatomic, copy  ) NSString *name;       //名字
@property (nonatomic, copy  ) NSString *typeString; //圈子类型 显示用
@property (nonatomic, assign) NSInteger type;       //圈子类型 给服务器用
@property (nonatomic, strong) UIImage *hasImage;    //圈子图标
@property (nonatomic, copy  ) NSString *detail;     //圈子详情

@end
