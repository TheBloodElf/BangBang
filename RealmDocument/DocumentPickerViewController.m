//
//  DocumentPickerViewController.m
//  RealmDocument
//
//  Created by lottak_mac2 on 16/8/17.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "DocumentPickerViewController.h"

@interface DocumentPickerViewController ()<UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;
}

@end

@implementation DocumentPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}
#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
}
-(void)prepareForPresentationInMode:(UIDocumentPickerMode)mode {
    // TODO: present a view controller appropriate for picker mode here
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

@end
