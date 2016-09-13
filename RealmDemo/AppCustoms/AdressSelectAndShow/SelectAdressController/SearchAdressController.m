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

@interface SearchAdressController ()<UISearchBarDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource> {
    AMapSearchAPI *_searchAPI;//百度搜索API
    AMapPOIKeywordsSearchRequest *_searchPOIRequest;//关键字搜索
    NSMutableArray<AMapPOI*> *_searchDataArr;//搜索结果数组

    UITableView *_tableView;//展示数据的表格视图
    NoResultView *_noResultView;//没有结果的视图
    UISearchBar *_searchBar;//搜索的输入框
}
@end

@implementation SearchAdressController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择位置";
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.placeholder = @" 输入你要搜索的内容...";
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
    [_searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
    _searchBar.returnKeyType = UIReturnKeySearch;
    for(UIView * view in [_searchBar.subviews[0] subviews]) {
        if([view isKindOfClass:[UITextField class]]) {
            [(UITextField*)view setEnablesReturnKeyAutomatically:NO];
            break;
        }
    }
    [self.view addSubview:_searchBar];
    //配置表格
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64 - 55) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _noResultView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    [_tableView registerNib:[UINib nibWithNibName:@"SelectAdressTableCell" bundle:nil] forCellReuseIdentifier:@"SelectAdressTableCell"];
    [self.view addSubview:_tableView];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _searchPOIRequest.page = 0;
        [_searchAPI AMapPOIKeywordsSearch:_searchPOIRequest];
    }];
    _tableView.mj_footer = (id)_noResultView;
    
    
    //配置POI搜索
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate = self;
    _searchDataArr = [@[] mutableCopy];
    _searchPOIRequest = [AMapPOIKeywordsSearchRequest new];
    _searchPOIRequest.requireExtension = YES;
    _searchPOIRequest.sortrule = 1;
    // Do any additional setup after loading the view.
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    _searchPOIRequest.keywords = _searchBar.text;
    [searchBar endEditing:YES];
    [_tableView.mj_header beginRefreshing];
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
    cell.isSelectedBtn.hidden = YES;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(searchAdress:)]) {
        [self.delegate searchAdress:_searchDataArr[indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    //POI搜索结果回调
    if(request.page == 0)
        [_searchDataArr removeAllObjects];
    [_searchDataArr addObjectsFromArray:response.pois];
    [_tableView.mj_header endRefreshing];
    if(_tableView.mj_footer != (id)_noResultView)
        [_tableView.mj_footer endRefreshing];
    if(_searchDataArr.count == 0) {
        _tableView.mj_footer = (id)_noResultView;
    } else {
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            _searchPOIRequest.page ++;
            [_searchAPI AMapPOIKeywordsSearch:_searchPOIRequest];
        }];
    }
    [_tableView reloadData];
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
@end
