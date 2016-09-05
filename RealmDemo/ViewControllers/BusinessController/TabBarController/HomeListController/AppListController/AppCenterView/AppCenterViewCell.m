//
//  AppCenterViewCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "AppCenterViewCell.h"
#import "UserApp.h"
#import "UIImageView+WebCache.h"

@interface AppCenterViewCell () {
    UIImageView *appImage;
}
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation AppCenterViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    UserApp *appModel = self.data;
    self.appName.text = appModel.app_name;
    if(appImage)
        [appImage removeFromSuperview];
    self.deleteBtn.hidden = !self.isEditStatue;
    self.deleteBtn.selected = appModel.isSelected;
    if(appModel.isSelected == YES) {
        self.appName.textColor = [UIColor colorWithRed:56/255.f green:180/255.f blue:152/255.f alpha:1];
    } else {
        self.appName.textColor = [UIColor blackColor];
    }
    UIImageView *iamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_5"]];
    appImage = [UIImageView new];
    appImage.frame = iamgeView.frame;
    appImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 8, MAIN_SCREEN_WIDTH / 8 - 8);
    [appImage sd_setImageWithURL:[NSURL URLWithString:appModel.logo] placeholderImage:[UIImage imageNamed:@"soft_logo_icon"]];
    [self.contentView addSubview:appImage];
}
@end
