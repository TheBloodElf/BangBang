//
//  MyAppView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "MyAppView.h"
#import "MyAppViewAddCell.h"
#import "MyAppViewCell.h"
#import "HomeListBottomViewCell.h"
#import "UserManager.h"
#import "LocalUserApp.h"
#import "UserHttp.h"

@interface MyAppView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,RBQFetchedResultsControllerDelegate,MyAppViewDelegate> {
    // 应用
    UICollectionView *appcollection;
    UserManager *_userManager;
    RBQFetchedResultsController *_userAppFetchedResultsController;
    NSMutableArray<UserApp*> *_userAppArr;
    NSMutableArray<LocalUserApp*> *_localUserAppArr;
}

@end

@implementation MyAppView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _localUserAppArr = [self localUserApp];
        _userManager = [UserManager manager];
        _userAppFetchedResultsController = [_userManager createUserAppFetchedResultsController];
        _userAppFetchedResultsController.delegate = self;
        //创建下面的集合视图
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        [flowLayout setItemSize:CGSizeMake(MAIN_SCREEN_WIDTH/4, MAIN_SCREEN_WIDTH/4)];//设置cell的尺寸
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向

        appcollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, frame.size.height) collectionViewLayout:flowLayout];
        [appcollection registerNib:[UINib nibWithNibName:@"MyAppViewAddCell" bundle:nil] forCellWithReuseIdentifier:@"MyAppViewAddCell"];
        [appcollection registerNib:[UINib nibWithNibName:@"MyAppViewCell" bundle:nil] forCellWithReuseIdentifier:@"MyAppViewCell"];
        [appcollection registerNib:[UINib nibWithNibName:@"HomeListBottomViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeListBottomViewCell"];
        appcollection.delegate = self;
        appcollection.dataSource = self;
        appcollection.backgroundColor = [UIColor colorWithRed:248/255.f green:248/255.f blue:248/255.f alpha:1];
        appcollection.userInteractionEnabled = YES;
        appcollection.showsVerticalScrollIndicator = NO;
        [self addSubview:appcollection];
        [self reloadCollentionView];
        if(_userAppArr.count == 0) {
            [UserHttp getMyAppList:_userManager.user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    [self showFailureTips:error.statsMsg];
                    return ;
                }
                NSMutableArray *array = [@[] mutableCopy];
                for (NSDictionary *dic in data) {
                    UserApp *userApp = [UserApp new];
                    [userApp mj_setKeyValues:dic];
                    [array addObject:userApp];
                }
                [_userManager updateUserAppArr:array];
            }];
        }
    }
    return self;
}
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self reloadCollentionView];
}
- (void)reloadCollentionView {
    _userAppArr = [_userManager getUserAppArr];
    [appcollection reloadData];
}
#pragma mark - UICollectionDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _localUserAppArr.count + _userAppArr.count + 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //添加
    if(indexPath.row == _localUserAppArr.count + _userAppArr.count) {
        MyAppViewAddCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyAppViewAddCell" forIndexPath:indexPath];
        return cell;
    }
    //本地应用
    if(indexPath.row < _localUserAppArr.count) {
        HomeListBottomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeListBottomViewCell" forIndexPath:indexPath];
        cell.data = _localUserAppArr[indexPath.row];
        return cell;
    }
    MyAppViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyAppViewCell" forIndexPath:indexPath];
    cell.isEditStatue = self.isEditStatue;
    cell.delegate = self;
    cell.data = _userAppArr[indexPath.row - _localUserAppArr.count];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(indexPath.row == _localUserAppArr.count + _userAppArr.count) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(MyAppViewAddApp)]) {
            [self.delegate MyAppViewAddApp];
        }
    } else {
        if(indexPath.row < _localUserAppArr.count) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(MyAppLocalAppSelect:)]) {
                [self.delegate MyAppLocalAppSelect:_localUserAppArr[indexPath.row]];
            }
        } else {
            if(self.delegate && [self.delegate respondsToSelector:@selector(MyAppNetAppSelect:)]) {
                [self.delegate MyAppNetAppSelect:_userAppArr[indexPath.row - _localUserAppArr.count]];
            }
        }
    }
}
//定义每个UICollectionCellView 的大小
- (CGSize)collectionView:(UICollectionView *)sender layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(MAIN_SCREEN_WIDTH/4,MAIN_SCREEN_WIDTH/4);
}
- (void)myAppDeleteApp:(UserApp*)app {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MyAppViewDeleteApp:)]) {
        [self.delegate MyAppViewDeleteApp:app];
    }
}
//本地应用列表
- (NSMutableArray*)localUserApp {
    NSMutableArray *modelArr = [@[] mutableCopy];
    NSArray *nameArr = @[@"公告",@"动态",@"签到",@"审批",@"帮邮", @"会议",@"投票"];
    NSArray *imageNameArr = @[@"home_0",@"home_1",@"home_2",@"home_3",@"home_4",@"home_5",@"home_6"];
    for (NSInteger index = 0; index < nameArr.count; index ++) {
        LocalUserApp *model = [LocalUserApp new];
        model.titleName = nameArr[index];
        model.imageName = imageNameArr[index];
        [modelArr addObject:model];
    }
    return modelArr;
}

@end
