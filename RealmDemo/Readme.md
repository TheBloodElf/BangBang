#pragma mark - lifeCycle
- (void)viewDidLoad {
[super viewDidLoad];
isOverMonth = NO;
_dateSelected = [NSDate date];
calMonth = [[ITTCalMonth alloc]initWithDate:_dateSelected];
calDay = [[ITTCalDay alloc]initWithDate:_dateSelected];

allCalendarArray = [NSMutableArray array];
[allCalendarArray addObjectsFromArray:[Calendar valueListNotDeleteFromDB]];
// 设置小红点
[self createRandomEvents];
NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
NSString *firstStr = [userDefault objectForKey:XYFFirstLoadCalendar];
XYFLog(@"是否是第一次打开日程：%@",firstStr);
if (allCalendarArray.count <= 0 && [firstStr isEqualToString:@"1"])
[self syncCalendar];

NSMutableArray * tempArray = [[NSMutableArray alloc] init];
calendarArray = [[NSMutableArray alloc]init];//当日事件
[calendarArray removeAllObjects];
[calendarArray addObjectsFromArray:[Calendar valueListFromDBWithToday:calDay]];//得到不重复事件是今天的 和重复事件有经过今天的 所有事件
for (Calendar * obj in calendarArray) {
//如果是重复事件
if (obj.rrule.length > 0&&obj.r_begin_date_utc >0&&obj.r_end_date_utc>0) {
Scheduler * s = [[Scheduler alloc] initWithDate:obj.startTime.date andRule:obj.rrule];
NSArray * occurences = [s occurencesBetween:obj.startTime.date andDate:[NSDate dateWithTimeIntervalSince1970:obj.r_end_date_utc/1000]];
//得到要经过的时间
for (NSDate *date in occurences) {
ITTCalDay *tempCal = [[ITTCalDay alloc]initWithDate:date];
//如果事件等于今天 才进入循环
if ([tempCal compare:calDay] == NSOrderedSame) {
//如果当前时间是被删除的 就不加入数组
if ([obj haveDeleteDate:date]) {
continue;
}
//如果有完成的 就更新状态为完成
else if ([obj haveFinishDate:date]&&obj.status != 2){
obj.status = 2;
}
[tempArray addObject:obj];
}
}
}//不重复事件直接加
else{
[tempArray addObject:obj];
}
}





/**
*  创建事件的字典 用于创建小红点
*/
- (void)createRandomEvents
{
_eventsByDate = [NSMutableDictionary new];
_eventsFinishDate = [NSMutableDictionary new];
for (Calendar * obj in allCalendarArray) {
if (obj.repeat_type == 0) {
if (obj.status == Calendar_Normal) {//不循环正常状态
if (obj.is_over_day) {//跨天就循环得到时间
NSDate *startTimeTemp = obj.startTime.date;//得到日程循环的开始时间
do {
startTimeTemp = [startTimeTemp addTimeInterval:24*60*60];
NSString *key = [[self dateFormatter] stringFromDate:startTimeTemp];//把开始时间格式化 作为key

if(!_eventsByDate[key]){
_eventsByDate[key] = [NSMutableArray new];
}
//对应的value加上
[_eventsByDate[key] addObject:startTimeTemp];
} while (obj.enddate_utc >= ([startTimeTemp timeIntervalSince1970] +24*60*60)*1000);
}
NSString *key = [[self dateFormatter] stringFromDate:obj.startTime.date];

if(!_eventsByDate[key]){
_eventsByDate[key] = [NSMutableArray new];
}

[_eventsByDate[key] addObject:obj.startTime.date];
//得到这个日程要经过多少天 比如跨三天的日程将得到下面的字典 @{@"2016-07-10":@[@"2016-07-10",@"2016-07-11",@"2016-07-12"]};
}
else if(obj.status == Calendar_Finished){//不循环完成状态
NSString *key = [[self dateFormatter] stringFromDate:obj.startTime.date];

if(!_eventsFinishDate[key]){
_eventsFinishDate[key] = [NSMutableArray new];
}
[_eventsFinishDate[key] addObject:obj.startTime.date];
}
}
else{//如果是重复的日程
if (obj.rrule.length > 0 && obj.r_begin_date_utc > 0 && obj.r_end_date_utc > 0) {
//通过开始时间和循环规则得到所有要经过的时间
Scheduler * s = [[Scheduler alloc] initWithDate:obj.startTime.date andRule:obj.rrule];
NSArray * occurences = [s occurencesBetween:obj.startTime.date andDate:[NSDate dateWithTimeIntervalSince1970:obj.r_end_date_utc/1000]];
//一个一个时间进行判断
for (NSDate *date in occurences) {
NSString *key = [[self dateFormatter] stringFromDate:date];
//如果已经删除
if ([obj haveDeleteDate:date]) {
continue;
}
//除去因为通过RRule计算时提前一天多余的数据
else if([date timeIntervalSince1970] < obj.r_begin_date_utc/1000)
continue;
//完成
else if([obj haveFinishDate:date] || obj.status == Calendar_Finished){
if(!_eventsFinishDate[key]){
_eventsFinishDate[key] = [NSMutableArray new];
}
[_eventsFinishDate[key] addObject:date];
}
else{
if(!_eventsByDate[key]){
_eventsByDate[key] = [NSMutableArray new];
}
[_eventsByDate[key] addObject:date];
}
}
}
}

}
}


@end
