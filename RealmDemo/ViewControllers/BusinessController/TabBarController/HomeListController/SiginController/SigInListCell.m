//
//  SigInListCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SigInListCell.h"
#import "SignIn.h"

@interface SigInListCell ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//时间
@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;//头像
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//员工名字
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;//分类
@property (weak, nonatomic) IBOutlet UIButton *adressLabel;//地址
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;//说明
@property (weak, nonatomic) IBOutlet UIView *attemthLabel;//附件图片展示

@end

@implementation SigInListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dataDidChange {
    SignIn *signIn = self.data;
    
}

@end
