//
//  SelectAttachmentController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SelectAttachmentController.h"
#import "Attachment.h"
#import "FileManager.h"
#import "AttachDocumentView.h"
#import "AttachVideoView.h"
#import "AttachPicView.h"
#import "AttachMusicView.h"
#import "AttachOtherView.h"
#import "AttachmentSelectDelegate.h"

@interface SelectAttachmentController ()<AttachmentSelectDelegate> {
    AttachDocumentView *_attachDocumentView;//文档
    AttachVideoView *_attachVideoView;//视频
    AttachPicView *_attachPicView;//相册
    AttachMusicView *_attachMusicView;//音乐
    AttachOtherView *_attachOtherView;//其他
    
    UISegmentedControl *_segmentedControl;//上面的分段控件
    UIScrollView *_bottomScrollView;//下面的滚动视图
    NSMutableArray<Attachment*> *_userSelectAttachmentArr;//用户已经选择的附件数组
    
    BOOL isFirstLoad;//是不是第一次加载
}

@end

@implementation SelectAttachmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"附件选择";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.view showLoadingTips:@""];
    _userSelectAttachmentArr = [@[] mutableCopy];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"文档",@"视频",@"相册",@"音乐",@"其他"]];
    _segmentedControl.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 35);
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.tintColor = [UIColor homeListColor];
    [_segmentedControl addTarget:self action:@selector(segmentedClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 35 - 64)];
    _bottomScrollView.showsVerticalScrollIndicator = NO;
    _bottomScrollView.showsHorizontalScrollIndicator = NO;
    _bottomScrollView.bounces = NO;
    _bottomScrollView.pagingEnabled = YES;
    _bottomScrollView.scrollEnabled = NO;
    _bottomScrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH * 5, MAIN_SCREEN_HEIGHT - 35 - 64);
    [self.view addSubview:_bottomScrollView];
    _attachDocumentView = [[AttachDocumentView alloc] initWithFrame:CGRectMake(0, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    _attachDocumentView.delegate = self;
    [_bottomScrollView addSubview:_attachDocumentView];
    _attachVideoView = [[AttachVideoView alloc] initWithFrame:CGRectMake(_bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    _attachVideoView.delegate = self;
    [_bottomScrollView addSubview:_attachVideoView];
    _attachPicView = [[AttachPicView alloc] initWithFrame:CGRectMake(2 * _bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    _attachPicView.delegate = self;
    [_bottomScrollView addSubview:_attachPicView];
    _attachMusicView = [[AttachMusicView alloc] initWithFrame:CGRectMake(3 * _bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    _attachMusicView.delegate = self;
    [_bottomScrollView addSubview:_attachMusicView];
    _attachOtherView = [[AttachOtherView alloc] initWithFrame:CGRectMake(4 * _bottomScrollView.frame.size.width, 0, _bottomScrollView.frame.size.width, _bottomScrollView.frame.size.height)];
    _attachOtherView.delegate = self;
    [_bottomScrollView addSubview:_attachOtherView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //是不是第一次加载这个页面
    if(isFirstLoad) return;
    isFirstLoad = YES;
    
    //在这里加载每个页面应该显示的数据
    NSMutableArray<Attachment*> *attachDocumentArr = [@[] mutableCopy];//文档
    NSMutableArray<Attachment*> *attachVideoArr = [@[] mutableCopy];//视频
    NSMutableArray<Attachment*> *attachPicArr = [@[] mutableCopy];//相册
    NSMutableArray<Attachment*> *attachMusicArr = [@[] mutableCopy];//音乐
    NSMutableArray<Attachment*> *attachOtherArr = [@[] mutableCopy];//其他
    FileManager *fileManager = [FileManager shareManager];
    for (NSString *subFileUrl in [fileManager fileUrlArr]) {
        //创建附件对象
        Attachment *attachment = [Attachment new];
        attachment.fileName = subFileUrl;
        //得到附件的具体属性
        NSError *nSError = nil;
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:[fileManager fileStr:attachment.fileName] error:&nSError];
        attachment.fileCreateDate = fileDic[@"NSFileCreationDate"];
        attachment.fileSize = [fileDic[@"NSFileSize"] integerValue];
        attachment.fileData = [NSData dataWithContentsOfFile:[fileManager fileStr:attachment.fileName]];
        if(nSError) continue;//如果有错误就不加载
        switch ([fileManager fileType:attachment.fileName]) {
            case 0: [attachDocumentArr addObject:attachment]; break;
            case 1: [attachVideoArr addObject:attachment]; break;
            case 2: [attachPicArr addObject:attachment]; break;
            case 3: [attachMusicArr addObject:attachment]; break;
            default: [attachOtherArr addObject:attachment]; break;
        }
    }
    //分别给各自的视图赋值
    _attachDocumentView.data = attachDocumentArr;
    _attachVideoView.data = attachVideoArr;
    _attachPicView.data = attachPicArr;
    _attachMusicView.data = attachMusicArr;
    _attachOtherView.data = attachOtherArr;
    [self.navigationController.view dismissTips];
}
#pragma mark -- AttachmentSelectDelegate
- (void)attachmentDidSelect:(Attachment*)attachment {
    if(attachment.isSelected == YES)
        [ _userSelectAttachmentArr addObject:attachment];
    else
        [_userSelectAttachmentArr removeObject:attachment];
    if(_userSelectAttachmentArr.count == 0)
        self.title = @"附件选择";
    else
        self.title = [NSString stringWithFormat:@"附件选择（%@）",@(_userSelectAttachmentArr.count)];
    if(_userSelectAttachmentArr.count == self.maxSelect) {
        [self.navigationController showMessageTips:@"已达到最大选择数"];
    }
}
- (void)segmentedClicked:(UISegmentedControl*)segmentedControl {
    [_bottomScrollView setContentOffset:CGPointMake(segmentedControl.selectedSegmentIndex * MAIN_SCREEN_WIDTH, 0) animated:NO];
}
- (void)cancleClicked:(UIBarButtonItem*)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectAttachmentCancel)]) {
        [self.delegate selectAttachmentCancel];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)doneClicked:(UIBarButtonItem*)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectAttachmentFinish:)]) {
        while (_userSelectAttachmentArr.count > self.maxSelect) {
            [_userSelectAttachmentArr removeLastObject];
        }
        [self.delegate selectAttachmentFinish:_userSelectAttachmentArr];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
