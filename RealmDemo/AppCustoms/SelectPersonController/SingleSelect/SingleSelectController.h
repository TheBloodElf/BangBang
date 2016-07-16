//
//  SingleSelectController.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"
@class SingleSelectController;
@protocol SingleSelectDelegate <NSObject>
@optional;
//单选回调
- (void)singleSelect:(Employee*)employee;
- (void)singleSelect:(SingleSelectController*)selectController employee:(Employee*)employee;

@end

//人员单选
@interface SingleSelectController : UIViewController
/**
 *  不显示的员工列表
 */
@property (nonatomic, strong) NSMutableArray<Employee*> *outEmployees;
/**
 *  选取@公司时 显示圈子的所有员工
 */
@property (nonatomic, assign) int companyNo;
/**
 *  如果有值，就显示这些值 否则显示
 */
@property (nonatomic, strong) NSMutableArray<Employee*> *discussMember;

@property (nonatomic, weak) id<SingleSelectDelegate> delegate;

@end
