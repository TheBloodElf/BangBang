//
//  RequestManagerCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/5.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Employee.h"

@protocol RequestManagerCellDelegate <NSObject>

- (void)requestManagerAgree:(Employee*)employee;
- (void)requestManagerRefuse:(Employee*)employee;

@end

@interface RequestManagerCell : UITableViewCell

@property (nonatomic, weak) id<RequestManagerCellDelegate> delegate;

@end
