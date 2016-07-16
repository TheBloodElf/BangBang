//
//  SigleSelectCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SigleSelectCell.h"
#import "Employee.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SigleSelectCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SigleSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avaterImage.layer.cornerRadius = 20.f;
    self.avaterImage.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    Employee *employee = self.data;
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[UIImage imageNamed:@"soft_logo_icon"]];
    self.nameLabel.text = employee.user_real_name;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
