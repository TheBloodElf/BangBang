//
//  MeetingRoomTimeCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingRoomTimeCell.h"
#import "MeetingRoomTimeCollectionCell.h"
#import "MeetingRoomModel.h"
#import "MeetingRoomHandlerTimeModel.h"
#import "UserHttp.h"

@interface MeetingRoomTimeCell ()<JTCalendarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,MeetingRoomTimeDelegate> {
    JTCalendarManager *_managerView;
    NSMutableDictionary<NSString*,NSDate*> *_lineDate;//行，时间对应，好计算每个item的时间
    MeetingRoomCellModel *_userSelectDate;//用户选择的开始/结束时间
    NSDate *_currWeekDate;//当前周的时间，用来计算集合视图中每个的时间
    NSMutableArray<MeetingRoomHandlerTimeModel*> *_handlerArr;//有会议的模型数组
}
@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//已经选择的会议室模型
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet UICollectionView *timeCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collFlowLayout;

@end

@implementation MeetingRoomTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _lineDate = [@{} mutableCopy];
    _handlerArr = [@[] mutableCopy];
    _managerView = [JTCalendarManager new];
    _managerView.delegate = self;
    _managerView.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
    _managerView.settings.weekModeEnabled = YES;
    _managerView.dateHelper.calendar.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"CCD"];
    _managerView.dateHelper.calendar.locale = [NSLocale localeWithLocaleIdentifier:@"zh-Hans"];
    [_managerView setContentView:_calendarView];
    
    self.timeCollectionView.delegate = self;
    self.timeCollectionView.dataSource = self;
    [self.timeCollectionView registerNib:[UINib nibWithNibName:@"MeetingRoomTimeCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MeetingRoomTimeCollectionCell"];
    self.collFlowLayout.itemSize = CGSizeMake((MAIN_SCREEN_WIDTH - 60) / 7.f, (MAIN_SCREEN_WIDTH - 60) / 7.f-0.1);
    self.collFlowLayout.minimumLineSpacing = 0;
    self.collFlowLayout.minimumInteritemSpacing = 0;
    // Initialization code
}
- (void)dataDidChange {
    self.meetingRoomModel = self.data;
    //重新初始化用户选择的时间
    _userSelectDate = [MeetingRoomCellModel new];
    NSDate *currDate = [NSDate date];
    //日历设置当前时间
    [_managerView setDate:currDate];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",currDate.year,currDate.month];
    //创建左边的时间线
    for (UIView *view in self.tagView.subviews) {
        [view removeFromSuperview];
    }
    int count = (int)((_meetingRoomModel.end_time - _meetingRoomModel.begin_time) / 1000 / 30 / 60 + 1);
    if((_meetingRoomModel.end_time - _meetingRoomModel.begin_time) % (1000 * 30 * 60) != 0)
        count ++;
    NSDate *currDateDate = [NSDate dateWithTimeIntervalSince1970:_meetingRoomModel.begin_time / 1000];
    CGFloat currCenterY = -2;
    for (int index = 0;index < count;index ++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, currCenterY, 60, 10)];
        label.center = CGPointMake(30, currCenterY);
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%02ld:%02ld",currDateDate.hour,currDateDate.minute];
        [self.tagView addSubview:label];
        currDateDate = [currDateDate dateByAddingTimeInterval:30 * 60];
        currCenterY += (MAIN_SCREEN_WIDTH - 60) / 7.f;
    }
    _currWeekDate = [NSDate date];
    //获取集合视图每行对应的时间
    [self createLineDate];
    //刷新集合视图
    [_timeCollectionView reloadData];
    //在集合视图上添加已经存在的那些会议
    [self addHavedMeeting];
}
- (void)addHavedMeeting {
    //得到要查询的开始和结束时间
    NSDate *begin = [_lineDate[@"0"] firstTime];
    NSDate *end = [_lineDate[@"6"] lastTime];
    [UserHttp getMeetHandlerTime:_meetingRoomModel.room_id begin:begin.timeIntervalSince1970 * 1000 end:end.timeIntervalSince1970 * 1000 handler:^(id data, MError *error) {
        if(error) return;
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            MeetingRoomHandlerTimeModel *model = [MeetingRoomHandlerTimeModel new];
            [model mj_setKeyValues:dic];
            [array addObject:model];
        }
        _handlerArr = array;
        for (UIView *view in _timeCollectionView.subviews) {
            if([view isMemberOfClass:[UILabel class]])
                [view removeFromSuperview];
        }
        CGFloat cellWidth = (MAIN_SCREEN_WIDTH - 60) / 7.f;
        //在集合视图上加上有会议的标签
        for (MeetingRoomHandlerTimeModel *model in _handlerArr) {
            CGPoint pointLeftTop = CGPointZero;//标签的左上角位置
            CGPoint pointLeftBottom = CGPointZero;//标签的右下角位置
            for (int section = 0; section < [_timeCollectionView numberOfSections]; section ++) {
                for (int row = 0; row < [_timeCollectionView numberOfItemsInSection:section]; row ++) {
                    //如果找到了开始和结束点 就返回
                    if(!CGPointEqualToPoint(pointLeftTop, CGPointZero))
                        if(!CGPointEqualToPoint(pointLeftBottom, CGPointZero))
                            break;
                    MeetingRoomTimeCollectionCell *cell = (id)[_timeCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                    MeetingRoomCellModel *cellModel = [cell data];
                    //如果还没有找到开始点
                    if(CGPointEqualToPoint(pointLeftTop, CGPointZero)) {//如果还没有找到起始点
                        if(cellModel.begin.timeIntervalSince1970 == (model.begin/1000)) {
                            //给开始点赋值
                            pointLeftTop = [cell convertRect:cell.bounds toView:_timeCollectionView].origin;
                        }
                    }
                    //如果找到了开始点 就找结束点
                    if(!CGPointEqualToPoint(pointLeftTop, CGPointZero)){
                        //如果找到了结束点就返回
                        if(!CGPointEqualToPoint(pointLeftBottom, CGPointZero))
                            break;
                        if(cellModel.end.timeIntervalSince1970 == (model.end/1000)) {
                            //给结束点赋值，标志着已经找到本会议的位置了，后面的循环将不会执行
                            pointLeftBottom = [cell convertRect:cell.bounds toView:_timeCollectionView].origin;
                            //开始画标签
                            CGRect currMeetRect = CGRectMake(pointLeftTop.x + 0.5, pointLeftTop.y + 0.5, cellWidth - 1, pointLeftBottom.y - pointLeftTop.y + cellWidth - 1);
                            UILabel *meetLabel = [[UILabel alloc] initWithFrame:currMeetRect];
                            meetLabel.backgroundColor = [UIColor colorWithRed:255/255.f green:185/255.f blue:15/255.f alpha:1];
                            meetLabel.numberOfLines = 0;
                            meetLabel.layer.cornerRadius = 1;
                            meetLabel.clipsToBounds = YES;
                            meetLabel.textAlignment = NSTextAlignmentCenter;
                            meetLabel.font = [UIFont systemFontOfSize:14];
                            meetLabel.textColor = [UIColor whiteColor];
                            meetLabel.text = model.meeting_name;
                            [_timeCollectionView addSubview:meetLabel];
                        }
                    }
                }
            }
        }
    }];
}
//指定的时间是否被占用
- (BOOL)thisTimeIsHaveMeet:(MeetingRoomCellModel*)model handlerArr:(NSMutableArray<MeetingRoomHandlerTimeModel*>*)handlerArr{
    for (MeetingRoomHandlerTimeModel *timeModel in handlerArr) {
        if(model.begin.timeIntervalSince1970 >= (timeModel.begin / 1000))
            if(model.end.timeIntervalSince1970 <= (timeModel.end / 1000))
                return YES;
    }
    return NO;
}
- (void)createLineDate {
    NSInteger currWeek = _currWeekDate.weekday;
    if(currWeek == 7) {
        [_lineDate setValue:_currWeekDate forKey:@"0"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:24 * 60 * 60] forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:2 * 24 * 60 * 60] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:3 * 24 * 60 * 60] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:4 * 24 * 60 * 60] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:5 * 24 * 60 * 60] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:6 * 24 * 60 * 60] forKey:@"6"];
    }
    if(currWeek == 1) {
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-24 * 60 * 60] forKey:@"0"];
        [_lineDate setValue:_currWeekDate forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval: 24 * 60 * 60] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:2 * 24 * 60 * 60] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:3 * 24 * 60 * 60] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:4 * 24 * 60 * 60] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:5 * 24 * 60 * 60] forKey:@"6"];
    }
    if(currWeek == 2) {
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-2 * 24 * 60 * 60] forKey:@"0"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-24 * 60 * 60] forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:0] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:1 * 24 * 60 * 60] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:2 * 24 * 60 * 60] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:3 * 24 * 60 * 60] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:4 * 24 * 60 * 60] forKey:@"6"];
    }
    if(currWeek == 3) {
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-3 * 24 * 60 * 60] forKey:@"0"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-2 * 24 * 60 * 60] forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-24 * 60 * 60] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:0] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:1 * 24 * 60 * 60] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:2 * 24 * 60 * 60] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:3 * 24 * 60 * 60] forKey:@"6"];
    }
    if(currWeek == 4) {
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-4 * 24 * 60 * 60] forKey:@"0"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-3 * 24 * 60 * 60] forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-2 * 24 * 60 * 60] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:- 24 * 60 * 60] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:0] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:1 * 24 * 60 * 60] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:2 * 24 * 60 * 60] forKey:@"6"];
    }
    if(currWeek == 5) {
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-5 * 24 * 60 * 60] forKey:@"0"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-4 * 24 * 60 * 60] forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-3 * 24 * 60 * 60] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-2 * 24 * 60 * 60] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:- 24 * 60 * 60] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:0] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval: 24 * 60 * 60] forKey:@"6"];
    }
    if(currWeek == 6) {
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-6 * 24 * 60 * 60] forKey:@"0"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-5 * 24 * 60 * 60] forKey:@"1"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-4 * 24 * 60 * 60] forKey:@"2"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-3 * 24 * 60 * 60] forKey:@"3"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-2 * 24 * 60 * 60] forKey:@"4"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:-1 * 24 * 60 * 60] forKey:@"5"];
        [_lineDate setValue:[_currWeekDate dateByAddingTimeInterval:0] forKey:@"6"];
    }
}
#pragma mark -- UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 7;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int count = (int)((_meetingRoomModel.end_time - _meetingRoomModel.begin_time) / 1000 / 30 / 60);
    if((_meetingRoomModel.end_time - _meetingRoomModel.begin_time) % (1000 * 30 * 60))
        count ++;
    return count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //当前行的时间
    NSDate *currDate = [_lineDate[[NSString stringWithFormat:@"%ld",(long)indexPath.section]] firstTime];
    NSDate *roomDate = [NSDate dateWithTimeIntervalSince1970:_meetingRoomModel.begin_time / 1000];
    NSDate *currDateDate = [currDate dateByAddingTimeInterval:roomDate.second + 60 * roomDate.minute + 60 * 60 * roomDate.hour];
    MeetingRoomCellModel *model = [MeetingRoomCellModel new];
    model.begin = [currDateDate dateByAddingTimeInterval:indexPath.row * 30 * 60];
    model.end = [currDateDate dateByAddingTimeInterval:(indexPath.row + 1) * 30 * 60];
    //是不是过去的时间
    if(model.begin.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970)
        model.isDidDate = YES;
    //是不是今天的时间
    if((_userSelectDate.begin.timeIntervalSince1970 <= model.begin.timeIntervalSince1970) && (_userSelectDate.end.timeIntervalSince1970 >= model.end.timeIntervalSince1970))
        model.isUserSelectDate = YES;
    MeetingRoomTimeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MeetingRoomTimeCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.data = model;
    return cell;
}
#pragma mark -- MeetingRoomTimeDelegate
- (void)MeetingRoomTime:(MeetingRoomCellModel *)model {
    //如果用户没有选就直接给
    if(!_userSelectDate.begin.timeIntervalSince1970) {
        _userSelectDate = model;
    } else {
        //如果用户只选了一个
        if(_userSelectDate.end.timeIntervalSince1970 - _userSelectDate.begin.timeIntervalSince1970 == 30 * 60) {
            //去最大最小赋值
            if(model.begin.timeIntervalSince1970 < _userSelectDate.begin.timeIntervalSince1970)
                _userSelectDate.begin = [NSDate dateWithTimeIntervalSince1970:model.begin.timeIntervalSince1970];
            if(model.end.timeIntervalSince1970 > _userSelectDate.end.timeIntervalSince1970)
                _userSelectDate.end = [NSDate dateWithTimeIntervalSince1970:model.end.timeIntervalSince1970];
        } else {
            //重新给值
            _userSelectDate = model;
        }
    }
    [_timeCollectionView reloadData];
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingRoomSelectDate:)]) {
        [self.delegate MeetingRoomSelectDate:_userSelectDate];
    }
}
#pragma mark -- JTCalendarDelegate
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    dayView.circleView.hidden = YES;
    dayView.textLabel.textColor = [UIColor blackColor];
    if([dayView isFromAnotherMonth])
        dayView.textLabel.textColor = [UIColor grayColor];
    NSDate *date = [NSDate date];
    if(dayView.date.year == date.year)
        if(dayView.date.month == date.month)
            if(dayView.date.day == date.day)
            {
                dayView.circleView.hidden = NO;
                dayView.circleView.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
            }
}
- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar {
    _currWeekDate = calendar.date;
    [self createLineDate];
    [_timeCollectionView reloadData];
    [self addHavedMeeting];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",_currWeekDate.year,_currWeekDate.month];
}
- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar {
    _currWeekDate = calendar.date;
    [self createLineDate];
    [_timeCollectionView reloadData];
    [self addHavedMeeting];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld年%ld月",_currWeekDate.year,_currWeekDate.month];
}

@end
