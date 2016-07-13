//
//  LeftMenuController.m
//  RealmDemo
//
//  Created by Mac on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LeftMenuController.h"
#import "UserManager.h"
#import "LeftMenuCell.h"

@interface LeftMenuController ()<UITableViewDataSource,UITableViewDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    NSMutableArray<Company*> *_companyArr;
    RBQFetchedResultsController *_userFetchedResultsController;
    RBQFetchedResultsController *_commpanyFetchedResultsController;
}
@property (weak, nonatomic) IBOutlet UIButton *avaterImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMood;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager  = [UserManager manager];
    _companyArr = [@[] mutableCopy];
    _commpanyFetchedResultsController = [_userManager createCompanyFetchedResultsController];
    _commpanyFetchedResultsController.delegate = self;
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    User *user = _userManager.user;
    self.avaterImageView.layer.cornerRadius = 35.f;
    self.avaterImageView.clipsToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuCell" bundle:nil] forCellReuseIdentifier:@"LeftMenuCell"];
    self.tableView.tableFooterView = [UIView new];
    //设置用户信息
    [self.avaterImageView.imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = user.real_name;
    self.userMood.text = user.mood;
    //设置圈子信息
    _companyArr = [_userManager getCompanyArr];
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _userFetchedResultsController) {
        User *user = controller.fetchedObjects[0];
        [self.avaterImageView.imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        self.userName.text = user.real_name;
        self.userMood.text = user.mood;
    } else {
        [_companyArr removeAllObjects];
        [_companyArr addObjectsFromArray:(id)controller.fetchedObjects];
        [_tableView reloadData];
    }
}
//加入圈子被点击
- (IBAction)joinCompanyClicked:(id)sender {
    
}
//头像被点击
- (IBAction)avaterClicked:(id)sender {
    
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftMenuCell" forIndexPath:indexPath];
    cell.data = _companyArr[indexPath.row];
    return cell;
}
@end
