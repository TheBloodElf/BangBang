//
//  BushManagerCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "BushManagerCell.h"
#import "UIImageView+WebCache.h"
#import "Company.h"

@interface BushManagerCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *bushImage;
@property (weak, nonatomic) IBOutlet UILabel *bushName;
@property (weak, nonatomic) IBOutlet UILabel *bushTitle;


@end

@implementation BushManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bushImage.layer.cornerRadius = 5.f;
    self.bushImage.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    Company *model = self.data;
    //设置模型值 cell没有重新新建  所以里面写着不是很规范 不要模仿
    [self.bushImage sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:[UIImage imageNamed:@""]];
    self.bushName.text =[NSString stringWithFormat:@"%@（%@）",model.company_name,@(model.company_no)];
    self.bushTitle.text = [NSString stringWithFormat:@"%@",model.companyTypeStr];
}

@end
