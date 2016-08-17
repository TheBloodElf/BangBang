//
//  CityController.m
//  fadein
//
//  Created by Apple on 15/12/14.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "CityController.h"
#import "AreaController.h"

@interface CityController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;//表格视图
}
@end

@implementation CityController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区";
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}
#pragma mark -返回每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cityDic.allKeys.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 41.f;
}
#pragma mark -配置每个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CityCell"];
    NSDictionary *tempDic = self.cityDic[self.cityDic.allKeys[indexPath.row]];
    cell.textLabel.text = tempDic.allKeys[0];
    return cell;
    return [UITableViewCell new];
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"全部";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.areaView = [AreaController new];
    NSDictionary *tempDic = self.cityDic[self.cityDic.allKeys[indexPath.row]];
    self.areaView.areaArr = tempDic[tempDic.allKeys[0]];
    self.areaView.regionName = self.regionName;
    self.areaView.cityName = tempDic.allKeys[0];
    [self.navigationController pushViewController:self.areaView animated:YES];
}
@end
