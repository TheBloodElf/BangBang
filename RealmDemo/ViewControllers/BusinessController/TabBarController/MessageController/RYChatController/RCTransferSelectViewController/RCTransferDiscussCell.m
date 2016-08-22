//
//  RCTransSelectCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RCTransferDiscussCell.h"
#import "UserDiscuss.h"

@interface RCTransferDiscussCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iamge;

@end

@implementation RCTransferDiscussCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.iamge zy_cornerRadiusRoundingRect];
    // Initialization code
}
- (void)dataDidChange {
    UserDiscuss *userDiscuss = self.data;
    self.nameLabel.text = userDiscuss.discuss_title;
}
@end
