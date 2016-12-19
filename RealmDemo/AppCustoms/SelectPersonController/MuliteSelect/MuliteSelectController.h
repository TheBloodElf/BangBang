//
//  MuliteSelectController.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"
//人员多选 通过user_guid来判断
@protocol MuliteSelectDelegate <NSObject>
//多选回调
- (void)muliteSelect:(NSMutableArray<Employee*>*)employeeArr;

@end

typedef void(^MuliteSelect)(NSMutableArray<Employee*>*);

@interface MuliteSelectController : UIViewController
/**
 *  过滤的员工列表
 */
@property (nonatomic, strong) NSMutableArray<Employee*> *outEmployees;
/**
 *  已经被选中的员工列表
 */
@property (nonatomic, strong) NSMutableArray<Employee*> *selectedEmployees;

/**
 *  选取@某人时
 */
@property (nonatomic, assign) int companyNo;
/**
 *  显示特定的成员 日程分享选择人使用，需要显示加入圈子的所有员工
 */
@property (nonatomic, strong) NSMutableArray<Employee*> *discussMember;

@property (nonatomic, weak) id<MuliteSelectDelegate> delegate;

@property (nonatomic, copy) MuliteSelect muliteSelect;

@end
