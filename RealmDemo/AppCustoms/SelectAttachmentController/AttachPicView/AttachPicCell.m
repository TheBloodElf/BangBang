//
//  AttachPicCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachPicCell.h"
#import "Attachment.h"
#import "AttachPicCollection.h"

@interface AttachPicCell ()<UICollectionViewDelegate,UICollectionViewDataSource> {
    NSMutableArray<Attachment*> *_AttachmentArr;
}

@property (weak, nonatomic) IBOutlet UICollectionView *attachPicCollection;

@end

@implementation AttachPicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(MAIN_SCREEN_WIDTH / 4, MAIN_SCREEN_WIDTH / 4);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.attachPicCollection.collectionViewLayout = layout;
    self.attachPicCollection.delegate = self;
    self.attachPicCollection.dataSource = self;
    [self.attachPicCollection registerNib:[UINib nibWithNibName:@"AttachPicCollection" bundle:nil] forCellWithReuseIdentifier:@"AttachPicCollection"];
    // Initialization code
}
- (void)dataDidChange {
    _AttachmentArr = self.data;
    [self.attachPicCollection reloadData];
}
#pragma mark -- UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _AttachmentArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AttachPicCollection *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AttachPicCollection" forIndexPath:indexPath];
    cell.data = _AttachmentArr[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    Attachment *attachment = _AttachmentArr[indexPath.row];
    attachment.isSelected = !attachment;
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}
@end
