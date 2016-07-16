//
//  MuliteSelectTopView.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectEmployeeModel.h"

@protocol MuliteSelectTopViewDelegate <NSObject>

- (void)muliteSelectTextField:(UITextField*)textField;
- (void)muliteSelectDel:(SelectEmployeeModel*)model;

@end

@interface MuliteSelectTopView : UIView

@property (nonatomic, weak) id<MuliteSelectTopViewDelegate> delegate;

@end
