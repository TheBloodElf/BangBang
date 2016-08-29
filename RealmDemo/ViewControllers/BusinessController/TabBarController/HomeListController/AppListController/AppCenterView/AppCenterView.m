//
//  AppCenterView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "AppCenterView.h"
#import "AppCenterViewCell.h"
#import "UserHttp.h"
#import "UserManager.h"

@interface AppCenterView () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,RBQFetchedResultsControllerDelegate> {
    // 应用
    UICollectionView *appcollection;
    UserManager *_userManager;
    RBQFetchedResultsController *_userAppFetchedResultsController;
    NSMutableArray<UserApp*> *_netUserAppArr;
}

@end

@implementation AppCenterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _userManager = [UserManager manager];
        _userAppFetchedResultsController = [_userManager createUserAppFetchedResultsController];
        _userAppFetchedResultsController.delegate = self;
        _netUserAppArr = [@[] mutableCopy];
        //创建下面的集合视图
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        [flowLayout setItemSize:CGSizeMake(MAIN_SCREEN_WIDTH/4, MAIN_SCREEN_WIDTH/4)];//设置cell的尺寸
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
        
        appcollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, frame.size.height) collectionViewLayout:flowLayout];
        [appcollection registerNib:[UINib nibWithNibName:@"AppCenterViewCell" bundle:nil] forCellWithReuseIdentifier:@"AppCenterViewCell"];
        appcollection.delegate = self;
        appcollection.dataSource = self;
        appcollection.backgroundColor = [UIColor colorWithRed:248/255.f green:248/255.f blue:248/255.f alpha:1];
        appcollection.userInteractionEnabled = YES;
        appcollection.showsVerticalScrollIndicator = NO;
        [self addSubview:appcollection];
        [UserHttp getCenterAppListHandler:^(id data, MError *error) {
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
            _netUserAppArr = array;
            [self reloadCollentionView];
        }];
    }
    return self;
}
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self reloadCollentionView];
}
- (void)reloadCollentionView {
    //把已经选中的状态改了
    [_netUserAppArr enumerateObjectsUsingBlock:^(UserApp * _Nonnull temp, NSUInteger idx, BOOL * _Nonnull stop) {
        [[_userManager getUserAppArr] enumerateObjectsUsingBlock:^(UserApp * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([temp.app_guid isEqualToString:obj.app_guid]) {
                temp.isSelected = YES;
                *stop = YES;
            }
        }];
    }];
    [appcollection reloadData];
}
#pragma mark - UICollectionDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _netUserAppArr.count;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AppCenterViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AppCenterViewCell" forIndexPath:indexPath];
    cell.isEditStatue = self.isEditStatue;
    cell.data = _netUserAppArr[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(self.isEditStatue == NO) return;
    UserApp *tempApp = _netUserAppArr[indexPath.row];
    if(tempApp.isSelected == YES) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(appCenterDelApp:)]) {
            [self.delegate appCenterDelApp:tempApp];
        }
    } else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(appCenterAddApp:)]) {
            [self.delegate appCenterAddApp:tempApp];
        }
    }
}
@end
