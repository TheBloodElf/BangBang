//
//  WorkAdressCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/21.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
//办公地点

@protocol WorkAdressCellDelegate <NSObject>

- (void)workAdressCellBtnAction:(UIButton*)btn;

@end

@interface WorkAdressCell : UITableViewCell

@property (nonatomic, weak) id<WorkAdressCellDelegate> delegate;

@end
