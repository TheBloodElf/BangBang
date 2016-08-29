//
//  HomeListBottomView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListBottomView.h"
#import "LocalUserApp.h"
#import "HomeListBottomViewCell.h"
#import "MoreAppCollectionCell.h"

@interface HomeListBottomView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout> {
    // 应用
    UICollectionView *appcollection;
    NSMutableArray<LocalUserApp*> *_localAppArr;
}

@end

@implementation HomeListBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _localAppArr = [self localUserApp];
        //创建下面的集合视图
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        [flowLayout setItemSize:CGSizeMake(MAIN_SCREEN_WIDTH/4, MAIN_SCREEN_WIDTH/4)];//设置cell的尺寸
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
        
        appcollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, frame.size.height) collectionViewLayout:flowLayout];
        [appcollection registerNib:[UINib nibWithNibName:@"MoreAppCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MoreAppCollectionCell"];
        [appcollection registerNib:[UINib nibWithNibName:@"HomeListBottomViewCell" bundle:nil] forCellWithReuseIdentifier:@"HomeListBottomViewCell"];
        appcollection.delegate = self;
        appcollection.dataSource = self;
        appcollection.backgroundColor = [UIColor colorWithRed:248/255.f green:248/255.f blue:248/255.f alpha:1];
        appcollection.userInteractionEnabled = YES;
        appcollection.showsVerticalScrollIndicator = NO;
        [self addSubview:appcollection];
    }
    return self;
}
#pragma mark - UICollectionDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _localAppArr.count + 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == _localAppArr.count) {
        MoreAppCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MoreAppCollectionCell" forIndexPath:indexPath];
        return cell;
    }
    HomeListBottomViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeListBottomViewCell" forIndexPath:indexPath];
    cell.data = _localAppArr[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(indexPath.row == _localAppArr.count) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(homeListBottomMoreApp)]) {
            [self.delegate homeListBottomMoreApp];
        }
    } else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(homeListBottomLocalAppSelect:)]) {
            [self.delegate homeListBottomLocalAppSelect:_localAppArr[indexPath.row]];
        }
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
