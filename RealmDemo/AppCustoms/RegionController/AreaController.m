//
//  AreaController.m
//  fadein
//
//  Created by Apple on 15/12/22.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "AreaController.h"
#import "RegionController.h"
@interface AreaController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;//表格视图
}


@end

@implementation AreaController

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
    return self.areaArr.count;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaCell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AreaCell"];
    cell.textLabel.text = self.areaArr[indexPath.row];
    return cell;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"全部";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RegionController *lo_region = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
    if(lo_region.delegate && [lo_region.delegate respondsToSelector:@selector(regionSelectAdress:city:area:)])
    {
        [lo_region.delegate regionSelectAdress:self.regionName city:self.cityName area:self.areaArr[indexPath.row]];
    }
    [self.navigationController popToViewController:self.navigationController.viewControllers[self.navigationController.viewControllers.count - 4] animated:YES];
    
}
@end
