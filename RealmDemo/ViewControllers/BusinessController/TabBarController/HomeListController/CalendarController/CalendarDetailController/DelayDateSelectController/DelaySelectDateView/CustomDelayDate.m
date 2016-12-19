//
//  CustomDelayDate.m
//  RealmDemo
//
//  Created by Mac on 2016/11/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CustomDelayDate.h"
//按钮的高度
#define Bottom_Button_Height 40.f
//按钮的绿色
#define Bottom_Button_Color [UIColor colorWithRed:25/255.f green:136/255.f blue:202/255.f alpha:1]
@interface CustomDelayDate () {
    UIDatePicker *_datePicker;
}

@end

@implementation CustomDelayDate

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //创建取消按钮
        UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        cancleBtn.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH / 2.f, Bottom_Button_Height);
        [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancleBtn.layer.borderColor = Bottom_Button_Color.CGColor;
        cancleBtn.layer.borderWidth = 1.f;
        cancleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancleBtn setBackgroundColor:[UIColor whiteColor]];
        [cancleBtn setTitleColor:Bottom_Button_Color forState:UIControlStateNormal];
        [cancleBtn addTarget:self action:@selector(cancleClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancleBtn];
        //创建确定按钮
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        okBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 2.f, 0, MAIN_SCREEN_WIDTH / 2.f, Bottom_Button_Height);
        okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        [okBtn setBackgroundColor:Bottom_Button_Color];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(okClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:okBtn];
        //创建时间选择器
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(okBtn.frame) + Bottom_Button_Height / 2.f, MAIN_SCREEN_WIDTH, frame.size.height - 2 * Bottom_Button_Height)];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        [self addSubview:_datePicker];
    }
    return self;
}
- (void)cancleClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(customCancle)]) {
        [self.delegate customCancle];
    }
}
- (void)okClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(customSelectDate:)]) {
        [self.delegate customSelectDate:_datePicker.date];
    }
}

@end
