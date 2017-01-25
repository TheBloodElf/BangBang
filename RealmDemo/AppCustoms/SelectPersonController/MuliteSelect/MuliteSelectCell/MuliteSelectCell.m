//
//  MuliteSelectCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "MuliteSelectCell.h"
#import "SelectEmployeeModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MuliteSelectCell  ()

@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;

@end

@implementation MuliteSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.avaterImage zy_cornerRadiusRoundingRect];
//    [self.selectedBtn addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchUpInside];
    // Initialization code
}
//- (void)selectClicked:(UIButton*)btn {
//    if(self.delegate && [self.delegate respondsToSelector:@selector(muliteSelect:)]) {
//        [self.delegate muliteSelect:self.data];
//    }
//}
- (void)dataDidChange {
    SelectEmployeeModel *employee = self.data;
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:employee.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.nameLabel.text = employee.real_name;
    self.selectedBtn.selected = employee.isSelected;
}

@end
