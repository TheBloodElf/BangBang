//
//  RCDSelectPersonController.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"
#import <RongIMKit/RongIMKit.h>
//人员多选
@class RCDSelectPersonController;
@protocol MuliteSelectDelegate <NSObject>

- (void)muliteSelect:(NSMutableArray<RCUserInfo*>*)rCUserArr rCDSelect:(RCDSelectPersonController*)rCDSelect;

@end

@interface RCDSelectPersonController : UIViewController
/**
 *  已经被选中的员工列表 然后不显示这些人
 */
@property (nonatomic, strong) NSMutableArray<Employee*> *selectedEmployees;
@property (nonatomic, assign) int companyNo;

@property (nonatomic, weak) id<MuliteSelectDelegate> delegate;

@end
