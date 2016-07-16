//
//  MuliteSelectTopImageView.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/5.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectEmployeeModel.h"

@protocol MuliteSelectTopImageViewDelegate <NSObject>

- (void)muliteSelectTopDel:(SelectEmployeeModel*)model;

@end

@interface MuliteSelectTopImageView : UIView

@property (nonatomic, weak) id<MuliteSelectTopImageViewDelegate> delegate;

@end
