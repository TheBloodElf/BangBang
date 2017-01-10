//
//  MuliteSelectCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectEmployeeModel;
//#BANG-561 点击整条或者最右边都可实现人员选中状态
//第一种方案：加一个代理，在外面处理
//第二张方案：设置按钮用户交互为no
//@protocol MuliteSelectCellDelegate <NSObject>
//
//- (void)muliteSelect:(SelectEmployeeModel*)model;
//
//@end

@interface MuliteSelectCell : UITableViewCell

//@property (nonatomic, weak) id<MuliteSelectCellDelegate> delegate;

@end
