//
//  ShareContentTopCell.h
//  BangBang
//
//  Created by haigui on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShareContentTopCellDelegate <NSObject>

- (void)textDidChange:(UITextView*)textView;

@end

@interface ShareContentTopCell : UITableViewCell

@property (nonatomic, weak) id<ShareContentTopCellDelegate> delegate;

@end
