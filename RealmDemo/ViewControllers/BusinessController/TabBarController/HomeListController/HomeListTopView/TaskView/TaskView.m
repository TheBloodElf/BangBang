//
//  TaskView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskView.h"
#import "UserManager.h"
#import "LineProgressLayer.h"
//前几天算将要到期
#define NumberOfDealy 5

@interface TaskView  ()<RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    RBQFetchedResultsController *_userFetchedResultsController;
    RBQFetchedResultsController *_taskFetchedResultsController;
    int _leftWillEndCount;//我委派的将到期数量
    int _leftDidEndCount;//我委派的已到期数量
    int _leftAllCount;//我委派的总数
    int _rightWillEndCount;//我负责的讲到期数量
    int _rightDidEndCount;//我负责的已到期数量
    int _rightAllCount;//我负责的总数
    
    LineProgressLayer *leftLayer;//左边动画图层第一层
    LineProgressLayer *greenLayer;//左边绿色的画图层第二层
    LineProgressLayer *leftThridLayer;//左边第三层
    
    LineProgressLayer *rightLayer; // 右面动画图层第一层
    LineProgressLayer *rightGreenLayer;//右边第二层
    LineProgressLayer *rightThirdLayer;//右边第三层
}
//左边视图
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UILabel *leftWillEnd;
@property (weak, nonatomic) IBOutlet UILabel *leftDidEnd;
@property (weak, nonatomic) IBOutlet UILabel *leftAll;

//右边视图
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *rightWillEnd;
@property (weak, nonatomic) IBOutlet UILabel *rightDidEnd;
@property (weak, nonatomic) IBOutlet UILabel *rightAll;

@end

@implementation TaskView

- (void)setupUI {
    self.userInteractionEnabled = YES;
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    
    _taskFetchedResultsController = [_userManager createTaskFetchedResultsController:_userManager.user.currCompany.company_no];
    _taskFetchedResultsController.delegate = self;
    //给这几个数字填充值
    [self getCurrCount];
    //添加动画
    [self createPie];
    [_userManager addTaskNotfition];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(_userFetchedResultsController == controller) {
        _taskFetchedResultsController = [_userManager createTaskFetchedResultsController:_userManager.user.currCompany.company_no];
        _taskFetchedResultsController.delegate = self;
    }
    _leftWillEndCount = _leftDidEndCount = _leftAllCount = _rightAllCount = _rightDidEndCount = _rightWillEndCount = 0;
    [self getCurrCount];
    [self createPie];
    [_userManager addTaskNotfition];
}
- (void)getCurrCount {
    NSMutableArray<TaskModel*> *taskArr = [_userManager getTaskArr:_userManager.user.currCompany.company_no];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    for (TaskModel *model in taskArr) {
        if(model.status == 0) continue;
        if([model.createdby isEqualToString:employee.employee_guid]) {//我委派的
            _leftAllCount ++;
            if(model.status == 2) {
                if(model.enddate_utc < [NSDate date].timeIntervalSince1970 * 1000) {//已经延期的
                    _leftDidEndCount ++;
                } else if(model.enddate_utc > ([NSDate date].timeIntervalSince1970 * 1000 + (NumberOfDealy * 24 * 60 * 60 * 1000))){//将要到期的
                    _leftWillEndCount ++;
                }
            }
        } else if ([model.incharge isEqualToString:employee.employee_guid]) {//我负责的
            _rightAllCount ++;
            if(model.status == 2) {
                if(model.enddate_utc < [NSDate date].timeIntervalSince1970 * 1000) {//已经延期的
                    _rightDidEndCount ++;
                } else if(model.enddate_utc > ([NSDate date].timeIntervalSince1970 * 1000 + (NumberOfDealy * 24 * 60 * 60 * 1000))){//将要到期的
                    _rightWillEndCount ++;
                }
            }
        }
    }
}
- (void)createPie {
    [leftLayer removeFromSuperlayer];
    [leftThridLayer removeFromSuperlayer];
    [greenLayer removeFromSuperlayer];
    [rightLayer removeFromSuperlayer];
    [rightGreenLayer removeFromSuperlayer];
    [rightThirdLayer removeFromSuperlayer];
    
    self.leftAll.text = [NSString stringWithFormat:@"%d",_leftAllCount];
    self.leftDidEnd.text = [NSString stringWithFormat:@"%d",_leftDidEndCount];
    self.leftWillEnd.text = [NSString stringWithFormat:@"%d",_leftWillEndCount];
    self.rightAll.text = [NSString stringWithFormat:@"%d",_rightAllCount];
    self.rightDidEnd.text = [NSString stringWithFormat:@"%d",_rightDidEndCount];
    self.rightWillEnd.text = [NSString stringWithFormat:@"%d",_rightWillEndCount];
    //我委派的任务 数据面板
    float tempValueRed = 1.0;
    float tempValueYellow = (_leftAllCount - _leftDidEndCount)/(float)_leftAllCount;
    float tempValueGreen = (_leftAllCount - _leftDidEndCount - _leftWillEndCount)/(float)_leftAllCount;
    //我委派的数字动画和动画时间
    if (_leftWillEndCount == 0 && _leftDidEndCount == 0) {
        leftLayer = [LineProgressLayer layer];
        leftLayer.bounds = self.leftView.bounds;
        leftLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        leftLayer.contentsScale = [UIScreen mainScreen].scale;
        leftLayer.color = [UIColor colorWithRed:43 / 255.f green:181 / 255.f blue:162 / 255.f alpha:1];
        [leftLayer setNeedsDisplay];
        [leftLayer showAnimate];
        [self.leftView.layer insertSublayer:leftLayer atIndex:0];
    } else {
        //第一层
        leftLayer = [LineProgressLayer layer];
        leftLayer.bounds = self.leftView.bounds;
        leftLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        leftLayer.contentsScale = [UIScreen mainScreen].scale;
        leftLayer.color = [UIColor colorWithRed:43 / 255.f green:181 / 255.f blue:162 / 255.f alpha:1];
        leftLayer.animationDuration = tempValueRed * 1.5;
        leftLayer.completed =  leftLayer.total;
        leftLayer.completedColor = [UIColor colorWithRed:1 green:105/255.f blue:64/255.f alpha:1];
        [leftLayer setNeedsDisplay];
        [leftLayer showAnimate];
        [self.leftView.layer insertSublayer:leftLayer atIndex:0];
        //第二层
        greenLayer = [LineProgressLayer layer];
        greenLayer.bounds = self.leftView.bounds;
        greenLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        greenLayer.contentsScale = [UIScreen mainScreen].scale;
        greenLayer.color = [UIColor clearColor];
        greenLayer.animationDuration = tempValueYellow * 1.5;
        greenLayer.completed = tempValueYellow *leftLayer.total;
        greenLayer.completedColor = [UIColor colorWithRed:251/255.f green:214/255.f blue:66/255.f alpha:1];
        [greenLayer setNeedsDisplay];
        [greenLayer showAnimate];
        [self.leftView.layer insertSublayer:greenLayer above:leftLayer];
        //第三层
        leftThridLayer = [LineProgressLayer layer];
        leftThridLayer.bounds = self.leftView.bounds;
        leftThridLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        leftThridLayer.contentsScale = [UIScreen mainScreen].scale;
        leftThridLayer.color = [UIColor clearColor];
        leftThridLayer.animationDuration = tempValueGreen * 1.5;
        leftThridLayer.completed = tempValueGreen *leftLayer.total;
        leftThridLayer.completedColor = [UIColor colorFromHexCode:@"0x0ab499"];
        [leftThridLayer setNeedsDisplay];
        [leftThridLayer showAnimate];
        [self.leftView.layer insertSublayer:leftThridLayer above:greenLayer];
    }
    
    
    //我接受的任务正常数
    float rightValueRed = 1.0;
    float rightValueYellow = (_rightAllCount - _rightWillEndCount)/(float)_rightAllCount;
    float rightValueGreen = (_rightAllCount - _rightDidEndCount - _rightWillEndCount)/(float)_rightAllCount;
    if (_rightWillEndCount == 0 && _rightDidEndCount == 0) {
        //第一层
        rightLayer = [LineProgressLayer layer];
        rightLayer.bounds = self.rightView.bounds;
        rightLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        rightLayer.contentsScale = [UIScreen mainScreen].scale;
        rightLayer.color = [UIColor colorWithRed:43 / 255.f green:181 / 255.f blue:162 / 255.f alpha:1];
        [rightLayer setNeedsDisplay];
        [rightLayer showAnimate];
        [self.rightView.layer insertSublayer:rightLayer atIndex:0];
    } else {
        //第一层
        rightLayer = [LineProgressLayer layer];
        rightLayer.bounds = self.rightView.bounds;
        rightLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        rightLayer.contentsScale = [UIScreen mainScreen].scale;
        rightLayer.color = [UIColor colorWithRed:43 / 255.f green:181 / 255.f blue:162 / 255.f alpha:1];
        rightLayer.animationDuration = rightValueRed * 1.5;
        rightLayer.completed = rightValueRed *rightLayer.total;
        rightLayer.completedColor = [UIColor colorWithRed:1 green:105/255.f blue:64/255.f alpha:1];
        [rightLayer setNeedsDisplay];
        [rightLayer showAnimate];
        [self.rightView.layer insertSublayer:rightLayer atIndex:0];
        //第二层
        rightGreenLayer = [LineProgressLayer layer];
        rightGreenLayer.bounds = self.rightView.bounds;
        rightGreenLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        rightGreenLayer.contentsScale = [UIScreen mainScreen].scale;
        rightGreenLayer.color = [UIColor clearColor];
        rightGreenLayer.animationDuration = rightValueYellow * 1.5;
        rightGreenLayer.completed = rightValueYellow *rightLayer.total;
        rightGreenLayer.completedColor = [UIColor colorWithRed:251/255.f green:214/255.f blue:66/255.f alpha:1];
        [rightGreenLayer setNeedsDisplay];
        [rightGreenLayer showAnimate];
        [self.rightView.layer insertSublayer:rightGreenLayer above:rightLayer];
        //第三层
        rightThirdLayer = [LineProgressLayer layer];
        rightThirdLayer.bounds = self.rightView.bounds;
        rightThirdLayer.position = CGPointMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
        rightThirdLayer.contentsScale = [UIScreen mainScreen].scale;
        rightThirdLayer.color = [UIColor clearColor];
        rightThirdLayer.animationDuration = rightValueGreen * 1.5;
        rightThirdLayer.completed = rightValueGreen *rightLayer.total;
        rightThirdLayer.completedColor = [UIColor colorFromHexCode:@"0x0ab499"];
        [rightThirdLayer setNeedsDisplay];
        [rightThirdLayer showAnimate];
        [self.rightView.layer insertSublayer:rightThirdLayer above:rightGreenLayer];
    }
}
- (IBAction)todayClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(createTaskClicked)]) {
        [self.delegate createTaskClicked];
    }
}
- (IBAction)weekClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chargeTaskClicked)]) {
        [self.delegate chargeTaskClicked];
    }
}
@end
