//
//  MyAppViewCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "MyAppViewCell.h"

@interface MyAppViewCell () {
    UIImageView *appImage;
}
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation MyAppViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.deleteBtn addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
    // Initialization code
}
- (void)deleteClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(myAppDeleteApp:)]) {
        [self.delegate myAppDeleteApp:self.data];
    }
}
- (void)dataDidChange {
    UserApp *appModel = self.data;
    self.appName.text = appModel.app_name;
    if(appImage)
        [appImage removeFromSuperview];
    self.deleteBtn.hidden = !self.isEditStatue;
    UIImageView *iamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_5"]];
    appImage = [UIImageView new];
    appImage.frame = iamgeView.frame;
    appImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 8, MAIN_SCREEN_WIDTH / 8 - 8);
    [appImage sd_setImageWithURL:[NSURL URLWithString:appModel.logo] placeholderImage:[UIImage imageNamed:@"soft_logo_icon"]];
    [self.contentView addSubview:appImage];
}

@end
