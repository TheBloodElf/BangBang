//
//  LeftMenuCell.m
//  RealmDemo
//
//  Created by Mac on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LeftMenuCell.h"
#import "Company.h"

@interface LeftMenuCell ()
@property (weak, nonatomic) IBOutlet UIImageView *companyImage;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@end

@implementation LeftMenuCell

- (void)awakeFromNib {
    // Initialization code
    self.companyImage.layer.cornerRadius = 5;
    self.companyImage.clipsToBounds = YES;
}
- (void)dataDidChange {
    Company *company = self.data;
    [self.companyImage sd_setImageWithURL:[NSURL URLWithString:company.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.companyName.text = company.company_name;
}
@end
