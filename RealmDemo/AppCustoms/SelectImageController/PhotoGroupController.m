//
//  PhotoGroupController.m
//  fadein
//
//  Created by Apple on 16/1/19.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "PhotoGroupController.h"
@interface PhotoGroupController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    
    ALAssetsLibrary *_libary;
    
    NSMutableArray *_groupArr;
}
@end

@implementation PhotoGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
     _groupArr = [NSMutableArray new];
    [self configTableView];
    [self loadDefulatData];
    self.title = @"相册";
    [self setupLeftNavigationButton];
    [self setupRightNavigationButton];
    // Do any additional setup after loading the view.
}

- (void)dataDidChange
{
    _libary = self.data;
}

#pragma mark -- 加载缺省的数据

- (void)loadDefulatData
{
    [_libary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //便利完成了
        if(group == nil)
        {
            dispatch_main_async_safe(^(){
                [_tableView reloadData];
            });
            *stop = YES;
        }
        else
        {
            if(group.numberOfAssets)
                [_groupArr addObject:group];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark -- 配置表格视图

- (void)configTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor whiteColor];
    [_tableView registerNib:[UINib nibWithNibName:@"PhotoGroupTableCell" bundle:nil] forCellReuseIdentifier:@"PhotoGroupTableCell"];
    _tableView.rowHeight = 80;
    [self.view addSubview:_tableView];
}

#pragma mark -- UITableViewDataSource
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoGroupTableCell *photoCell = [_tableView dequeueReusableCellWithIdentifier:@"PhotoGroupTableCell" forIndexPath:indexPath];
    ALAssetsGroup *tempGroup = _groupArr[indexPath.row];
    photoCell.photoImageView.image = [UIImage imageWithCGImage:tempGroup.posterImage];
    photoCell.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)tempGroup.numberOfAssets];
    photoCell.title.text = [tempGroup valueForProperty:@"ALAssetsGroupPropertyName"];
    return photoCell;
}

#pragma mark -- UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.delegate)
        [self.delegate loadDataWithGroup:_groupArr[indexPath.row]];
    
    [self.navigationController setDirection:E_NAVIGATION_DIRECTION_RIGHT];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark - Navigation Config

#pragma mark -- Navigation buttons

- (void)setupLeftNavigationButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:self action:@selector(leftNavigationButtonAction:)];
}

- (void)setupRightNavigationButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightNavigationButtonAction:)];
}

#pragma mark -- Navigation Actions

- (void)popBackViewController {
    [self.navigationController setDirection:E_NAVIGATION_DIRECTION_RIGHT];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark - Button Actions

- (void)leftNavigationButtonAction:(id)sender {
    [self popBackViewController];
}

- (void)rightNavigationButtonAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
