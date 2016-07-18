//
//  SearchAdressController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SearchAdressController.h"
#import "NoResultView.h"
#import "MJRefresh.h"
#import "SelectAdressTableCell.h"

@interface SearchAdressController ()<UITextFieldDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource> {
    AMapSearchAPI *_searchAPI;//百度搜索API
    NSMutableArray<AMapPOI*> *_searchDataArr;//搜索结果数组
    AMapPOI *_userSelectedPOI;//用户已经选择的位置

    UITableView *_tableView;//展示数据的表格视图
    NoResultView *_noResultView;//没有结果的视图
    UITextField *_searchBar;//搜索的输入框
}
@end

@implementation SearchAdressController

- (void)viewDidLoad {
    [super viewDidLoad];
    //配置表格
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 25, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64 - 25) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"SelectAdressTableCell" bundle:nil] forCellReuseIdentifier:@"SelectAdressTableCell"];
    [self.view addSubview:_tableView];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _searchPOIRequest.page = 0;
        [self searchPOIData];
    }];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _searchPOIRequest.page ++;
        [self searchPOIData];
    }];
    _noResultView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    
    //配置POI搜索
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate = self;
    _searchDataArr = [@[] mutableCopy];
    _userSelectedPOI = [AMapPOI new];
    
    [self setCenterNavigationBar];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightNavigationBarAction:)];
    [_tableView.mj_header beginRefreshing];
    // Do any additional setup after loading the view.
}
- (void)searchBtnSearch:(UIButton*)btn {
    _searchPOIRequest.keywords = _searchBar.text;
    [self.view endEditing:YES];
    [_tableView.mj_header beginRefreshing];
}
//百度搜索数据
- (void)searchPOIData {
    [_searchAPI AMapPOIAroundSearch:_searchPOIRequest];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchDataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectAdressTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectAdressTableCell" forIndexPath:indexPath];
    AMapPOI *poi = _searchDataArr[indexPath.row];
    cell.adressTitle.text = poi.name;
    cell.adressDetail.text = poi.address;
    if ([poi isEqual:_userSelectedPOI]) {
        cell.isSelectedBtn.selected = YES;
    } else {
        cell.isSelectedBtn.selected = NO;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _userSelectedPOI = _searchDataArr[indexPath.row];
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    //POI搜索结果回调
    if(request.page == 0)
        [_searchDataArr removeAllObjects];
    [_searchDataArr addObjectsFromArray:response.pois];
    if(request.page == 0) {
        if(_searchDataArr.count != 0) {
            _userSelectedPOI = _searchDataArr[0];
        } else {
            _userSelectedPOI = nil;
        }
    }
    [_tableView.header endRefreshing];
    if(_tableView.footer != (id)_noResultView)
        [_tableView.footer endRefreshing];
    if(_searchDataArr.count == 0) {
        _tableView.footer = (id)_noResultView;
    } else {
        _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            _searchPOIRequest.page ++;
            [self searchPOIData];
        }];
    }
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- ConfigNavigationBar
- (void)setCenterNavigationBar {
    _searchBar = [[UITextField alloc] initWithFrame:CGRectMake(50, 64, MAIN_SCREEN_WIDTH - 100, 25)];
    _searchBar.backgroundColor = [UIColor whiteColor];
    _searchBar.font = [UIFont systemFontOfSize:14];
    _searchBar.text = @" 输入你要搜索的内容...";
    _searchBar.delegate = self;
    _searchBar.textColor = [UIColor grayColor];
    _searchBar.layer.cornerRadius = 5;
    _searchBar.clipsToBounds = YES;
    [self.view addSubview:_searchBar];
}
- (void)rightNavigationBarAction:(UIBarButtonItem*)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchAdress:)]) {
        [self.delegate searchAdress:_userSelectedPOI];
    }
}
@end
