//
//  TaskDetailBottomOpView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDetailBottomOpView.h"
#import "TaskModel.h"
#import "UserManager.h"
//按钮标签内容向上偏移量 设置按钮字体后字没有剧中
#define Button_Title_Top_Edge 0.f
//按钮中间分隔线向上偏移量 没有剧中
#define Line_Top_Edge         0.f

@interface TaskDetailBottomOpView () {
    TaskModel *_taskModel;
    UserManager *_userManager;
}

@end

@implementation TaskDetailBottomOpView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _userManager = [UserManager manager];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dataDidChange {
    _taskModel = self.data;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    //如果是负责人
    if([_taskModel.incharge isEqualToString:employee.employee_guid]) {
        if(_taskModel.status == 1) {//接收
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height);
            btn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn setTitle:@"接收" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(acceptClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        } else if (_taskModel.status == 2) {//提交
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height);
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            btn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            [btn setTitle:@"提交" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submitClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        } else if (_taskModel.status == 6) {//提交
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            btn.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height);
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn setTitle:@"提交" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submitClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
    //如果是创建者
    if([_taskModel.createdby isEqualToString:employee.employee_guid]) {
        if(_taskModel.status == 1) {//终止 编辑
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, (MAIN_SCREEN_WIDTH - 1) / 2.f, self.frame.size.height);
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            btn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            [btn setTitle:@"终止" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            //创建一条竖着的线条
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), Line_Top_Edge + (self.frame.size.height - 15) / 2, 1, 15)];
            view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [self addSubview:view];
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1 setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 1, 0, (MAIN_SCREEN_WIDTH - 1) / 2.f, self.frame.size.height);
            [btn1 setTitle:@"编辑" forState:UIControlStateNormal];
            btn1.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            btn1.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn1 addTarget:self action:@selector(updateClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn1];
        } else if (_taskModel.status == 2) {//终止 通过
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, (MAIN_SCREEN_WIDTH - 1) / 2.f, self.frame.size.height);
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            btn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            [btn setTitle:@"终止" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            //创建一条竖着的线条
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), Line_Top_Edge + (self.frame.size.height - 15) / 2, 1, 15)];
            view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [self addSubview:view];
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1 setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 1, 0, (MAIN_SCREEN_WIDTH - 1) / 2.f, self.frame.size.height);
            [btn1 setTitle:@"完结" forState:UIControlStateNormal];
            btn1.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            btn1.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn1 addTarget:self action:@selector(passClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn1];
        } else if (_taskModel.status == 4) {//终止 通过 退回
            UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            returnBtn.frame = CGRectMake(0, 0, (MAIN_SCREEN_WIDTH - 2) / 3 , self.frame.size.height);
            [returnBtn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            [returnBtn setTitle:@"终止" forState:UIControlStateNormal];
            returnBtn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            [returnBtn addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
            returnBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            [self addSubview:returnBtn];
            //创建一条竖着的线条
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(returnBtn.frame), Line_Top_Edge + (self.frame.size.height - 15) / 2, 1, 15)];
            view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [self addSubview:view];
            UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            stopBtn.frame = CGRectMake(CGRectGetMaxX(returnBtn.frame) + 1 , 0, (MAIN_SCREEN_WIDTH - 2) / 3 , self.frame.size.height);
            stopBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            stopBtn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            [stopBtn setTitle:@"通过" forState:UIControlStateNormal];
            [stopBtn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            [stopBtn addTarget:self action:@selector(passClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:stopBtn];
            //创建一条竖着的线条
            UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stopBtn.frame), Line_Top_Edge + (self.frame.size.height - 15) / 2, 1, 15)];
            view1.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [self addSubview:view1];
            UIButton *passBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [passBtn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            passBtn.frame = CGRectMake(CGRectGetMaxX(stopBtn.frame) + 1, 0, (MAIN_SCREEN_WIDTH - 2) / 3, self.frame.size.height);
            [passBtn setTitle:@"退回" forState:UIControlStateNormal];
            passBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            passBtn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            [passBtn addTarget:self action:@selector(returnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:passBtn];
        } else if (_taskModel.status == 6) {//终止 完结
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn.frame = CGRectMake(0, 0, (MAIN_SCREEN_WIDTH - 1) / 2, self.frame.size.height);
            btn.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            btn.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn setTitle:@"终止" forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(stopClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            //创建一条竖着的线条
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btn.frame), Line_Top_Edge + (self.frame.size.height - 15) / 2, 1, 15)];
            view.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [self addSubview:view];
            UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn1 setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
            btn1.frame = CGRectMake(CGRectGetMaxX(btn.frame) + 1, 0, (MAIN_SCREEN_WIDTH - 1) / 2.f, self.frame.size.height);
            [btn1 setTitle:@"完结" forState:UIControlStateNormal];
            btn1.titleEdgeInsets = UIEdgeInsetsMake(Button_Title_Top_Edge, 0, 0, 0);
            btn1.titleLabel.font = [UIFont systemFontOfSize:17];
            [btn1 addTarget:self action:@selector(passClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn1];
        }
    }
    //添加一条上面的线条
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 0.5)];
    topLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:topLine];
}
//编辑
- (void)updateClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateClicked:)]) {
        [self.delegate updateClicked:btn];
    }
}
//接收
- (void)acceptClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(acceptClicked:)]) {
        [self.delegate acceptClicked:btn];
    }
}
//终止
- (void)stopClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(stopClicked:)]) {
        [self.delegate stopClicked:btn];
    }
}
//退回
- (void)returnClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(returnClicked:)]) {
        [self.delegate returnClicked:btn];
    }
}
//通过
- (void)passClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(passClicked:)]) {
        [self.delegate passClicked:btn];
    }
}
//提交
- (void)submitClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(submitClicked:)]) {
        [self.delegate submitClicked:btn];
    }
}
@end
