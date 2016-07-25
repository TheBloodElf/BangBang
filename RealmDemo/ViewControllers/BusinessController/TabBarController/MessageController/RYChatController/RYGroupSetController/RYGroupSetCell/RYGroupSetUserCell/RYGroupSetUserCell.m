//
//  RYGroupSetUserCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYGroupSetUserCell.h"
#import "RYGroupSetAddUserCell.h"
#import "RYGroupSetDelUserCell.h"
#import "RYGroupSetUserImageCell.h"

@interface RYGroupSetUserCell ()<UICollectionViewDelegate,UICollectionViewDataSource,RYGroupSetUserImageDelegate> {
    UICollectionView *_collectionView;
    NSArray<RCUserInfo*> *_rCUserArr;//当前聊天的人员
}

@end

@implementation RYGroupSetUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    if(_collectionView)
        [_collectionView removeFromSuperview];
    _rCUserArr = self.data;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 5;
    layout.itemSize = CGSizeMake((MAIN_SCREEN_WIDTH - 50) / 5, (MAIN_SCREEN_WIDTH - 50) / 5 + 20);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 5, MAIN_SCREEN_WIDTH - 10, self.contentView.frame.size.height - 10) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.showsVerticalScrollIndicator = _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"RYGroupSetAddUserCell" bundle:nil] forCellWithReuseIdentifier:@"RYGroupSetAddUserCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"RYGroupSetDelUserCell" bundle:nil] forCellWithReuseIdentifier:@"RYGroupSetDelUserCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"RYGroupSetUserImageCell" bundle:nil] forCellWithReuseIdentifier:@"RYGroupSetUserImageCell"];
    [self.contentView addSubview:_collectionView];
}
#pragma mark -- 
#pragma mark -- UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //圈主会多两项
    if([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:_currRCDiscussion.creatorId])
        return _rCUserArr.count + 2;
    else {
        if(_currRCDiscussion.inviteStatus == 0)
            return _rCUserArr.count + 1;
    }
    return _rCUserArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //如果是圈主才能有删除\增加这一项
    if([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:_currRCDiscussion.creatorId]) {
        if(indexPath.row == _rCUserArr.count + 1) {//删除
            RYGroupSetDelUserCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RYGroupSetDelUserCell" forIndexPath:indexPath];
            return addCell;
        } else if (indexPath.row == _rCUserArr.count ) {//增加
            RYGroupSetAddUserCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RYGroupSetAddUserCell" forIndexPath:indexPath];
            return addCell;
        }
    } else {
        //开放了邀请权限就可以邀请
        if(_currRCDiscussion.inviteStatus == 0) {
            if(indexPath.row == _rCUserArr.count) {//增加
                RYGroupSetAddUserCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RYGroupSetAddUserCell" forIndexPath:indexPath];
                return addCell;
            }
        }
    }
    RYGroupSetUserImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RYGroupSetUserImageCell" forIndexPath:indexPath];
    imageCell.isUserEdit = self.isUserEdit;
    imageCell.delegate = self;
    imageCell.currRCDiscussion = self.currRCDiscussion;
    imageCell.data = _rCUserArr[indexPath.row];
    return imageCell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    //只有圈主才能增加删除项
    if([[RCIMClient sharedRCIMClient].currentUserInfo.userId isEqualToString:_currRCDiscussion.creatorId]) {
         if(indexPath.row == _rCUserArr.count + 1) {//删除
             if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetDeleteClicked)]) {
                 [self.delegate RYGroupSetDeleteClicked];
             }
             return;
         } else if (indexPath.row == _rCUserArr.count ) {//增加
             if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetAddClicked)]) {
                 [self.delegate RYGroupSetAddClicked];
             }
             return;
         }
    } else {
        //开放了权限可以邀请人
        if(_currRCDiscussion.inviteStatus == 0) {
            if(indexPath.row == _rCUserArr.count) {//增加
                if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetAddClicked)]) {
                    [self.delegate RYGroupSetAddClicked];
                }
                return;
            }
        }
    }
    //某个人被点击
    if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetUserClicked)]) {
        [self.delegate RYGroupSetUserClicked];
    }
}
#pragma mark -- RYGroupSetUserImageDelegate
- (void)RYGroupSetUserImageDelete:(RCUserInfo*)userInfo {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetUserDelete:)]) {
        [self.delegate RYGroupSetUserDelete:userInfo];
    }
}
@end
