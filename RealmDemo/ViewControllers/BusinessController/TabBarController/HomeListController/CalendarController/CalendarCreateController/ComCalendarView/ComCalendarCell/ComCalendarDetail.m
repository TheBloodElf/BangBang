//
//  ComCalendarDetail.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarDetail.h"

@implementation ComCalendarDetail

- (void)awakeFromNib {
    [super awakeFromNib];
    self.detailTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.detailTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
