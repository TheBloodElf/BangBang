//
//  BottomItemModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//首页下面按钮视图每个item模型
@interface BottomItemModel : NSObject

@property (nonatomic, assign) NSInteger index;//按钮的下标
@property (nonatomic,   copy) NSString *titleName;//标题名称
@property (nonatomic,   copy) NSString *imageName;//图片名称

@end
