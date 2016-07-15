//
//  CreateBushModel.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "CreateBushModel.h"

@implementation CreateBushModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (NSString *)description {
    NSString *bushDes = [NSString stringWithFormat:@"圈子名字:%@,圈子类型:%@,:圈子详情%@",self.name,self.typeString,self.detail];
    return bushDes;
}
@end
