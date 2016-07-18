//
//  DiscussListCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "DiscussListCell.h"
#import "UserDiscuss.h"

@interface DiscussListCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *discussImage;
@property (weak, nonatomic) IBOutlet UILabel *discussName;

@end

@implementation DiscussListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.discussImage.layer.cornerRadius = 25.f;
    self.discussImage.clipsToBounds = YES;
    // Initialization code
}

- (void)dataDidChange {
    UserDiscuss *userDiscuss = self.data;
    self.discussImage.image = [UIImage imageNamed:@"discussion_portrait"];
    self.discussName.text = userDiscuss.discuss_title;
}

@end
