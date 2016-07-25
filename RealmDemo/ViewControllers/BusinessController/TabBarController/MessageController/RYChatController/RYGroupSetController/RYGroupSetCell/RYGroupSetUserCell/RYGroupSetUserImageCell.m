//
//  RYGroupSetUserImageCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYGroupSetUserImageCell.h"

@interface RYGroupSetUserImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@end

@implementation RYGroupSetUserImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImage.layer.cornerRadius = 5;
    self.userImage.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    RCUserInfo *userInfo = self.data;
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:userInfo.portraitUri] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = userInfo.name;
    self.deleteBtn.hidden = !self.isUserEdit;
    if([userInfo.userId isEqualToString:_currRCDiscussion.creatorId]) {
        self.deleteBtn.hidden = YES;
    }
}
- (IBAction)deleteClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetUserImageDelete:)]) {
        [self.delegate RYGroupSetUserImageDelete:self.data];
    }
}

@end
