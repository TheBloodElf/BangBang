//
//  BushSearchCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Company.h"

@protocol BushSearchCellDelegate <NSObject>

- (void)bushSearchCellJoin:(Company*)model;

@end

@interface BushSearchCell : UITableViewCell

@property (nonatomic, weak) id<BushSearchCellDelegate> delegate;

@end
