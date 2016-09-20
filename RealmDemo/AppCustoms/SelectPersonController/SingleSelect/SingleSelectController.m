//
//  SingleSelectController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SingleSelectController.h"
#import "UserManager.h"
#import "SigleSelectCell.h"

@interface SingleSelectController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {
    UserManager *_userManager;//用户管理器
    NSMutableArray<Employee*> *_selectEmployees;//要显示的员工数组
    NSMutableArray *_employeekeyArr;//都有的首字母数组
    NSMutableArray *_employeeDataArr;//所有的值数组
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation SingleSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    _employeekeyArr = [@[] mutableCopy];
    _employeeDataArr = [@[] mutableCopy];
    _selectEmployees = [@[] mutableCopy];
    _userManager = [UserManager manager];
    self.title = @"人员选择";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"SigleSelectCell" bundle:nil] forCellReuseIdentifier:@"SigleSelectCell"];
    self.textField.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self getSureDataArr];
    [self searEmployeeWithText:@""];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
//获取正确员工数据
- (void)getSureDataArr {
    //获取应该显示的员工数组
    if(self.discussMember) {//显示讨论组的员工
        _selectEmployees = self.discussMember;
    } else if (self.companyNo) {//显示某个圈子的员工
        _selectEmployees = [_userManager getEmployeeWithCompanyNo:self.companyNo status:5];
    } else {//显示当前圈子员工
        _selectEmployees = [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5];
    }
    //排除掉不显示的员工
    NSMutableArray<NSString*> *outIdArr = [@[] mutableCopy];
    for (Employee *employee in self.outEmployees) {
        [outIdArr addObject:employee.employee_guid];
    }
    NSMutableArray *array = [@[] mutableCopy];
    for (Employee *employee in _selectEmployees) {
        if(![outIdArr containsObject:employee.employee_guid]) {
            [array addObject:employee];
        }
    }
    _selectEmployees = array;
}
- (void)searEmployeeWithText:(NSString*)text {
    NSMutableDictionary<NSString*,NSMutableArray*> *_currDataArr = [@{} mutableCopy];//根据搜索出的员工的首字母-员工数组的字典
    NSMutableArray *keyArr = [@[] mutableCopy];
    NSMutableArray *dataArr = [@[] mutableCopy];
    //先把字典填充A-Z对应的空数组
    for (int i = 0;i < 26;i ++) {
        char currChar = 'A' + i;
        NSString *currStr = [NSString stringWithFormat:@"%c",currChar];
        [_currDataArr setObject:[@[] mutableCopy] forKey:currStr];
    }
    [_currDataArr setObject:[@[] mutableCopy] forKey:@"#"];
    //填充数据
    for (Employee *tempEmployee in _selectEmployees) {
        //判断是否要加入到字典中
        if([NSString isBlank:text] || ([tempEmployee.user_real_name rangeOfString:text].location != NSNotFound)) {
            NSString *firstChar = [tempEmployee.user_real_name firstChar];
            NSMutableArray *currArr = _currDataArr[firstChar];
            [currArr addObject:tempEmployee];
            _currDataArr[firstChar] = currArr;
        }
    }
    //清除掉没有值的键值对
    for (NSString *currStr in _currDataArr.allKeys) {
        if(_currDataArr[currStr].count == 0) {
            [_currDataArr removeObjectForKey:currStr];
        }
    }
    //把key按照ABCDEFG...排序  分成两个数组装
    keyArr = [_currDataArr.allKeys mutableCopy];
    [keyArr sortUsingComparator:^NSComparisonResult(NSString* obj1,NSString* obj2) {
        return [obj1 compare:obj2] == 1;
    }];
    //把#放最后
    if(keyArr.count != 0) {
        if([keyArr[0] isEqualToString:@"#"]) {
            [keyArr removeObject:@"#"];
            [keyArr addObject:@"#"];
        }
    }
    //得到对应的名字数组
    for (NSString *keyStr in keyArr) {
        [dataArr addObject:_currDataArr[keyStr]];
    }
    _employeekeyArr = keyArr;
    _employeeDataArr = dataArr;
    [self.tableView reloadData];
}
#pragma mark -- 
#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searEmployeeWithText:textField.text];
    [self.view endEditing:YES];
    return YES;
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, tableView.frame.size.width - 30, 16)];
    label.textColor = [UIColor blackColor];
    label.text = _employeekeyArr[section];
    [bgView addSubview:label];
    return bgView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 57.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _employeekeyArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_employeeDataArr[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SigleSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigleSelectCell" forIndexPath:indexPath];
    Employee *employee = _employeeDataArr[indexPath.section][indexPath.row];
    cell.data = employee;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Employee *employee = _employeeDataArr[indexPath.section][indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(singleSelect:)]) {
        [self.delegate singleSelect:employee];
    }
    if(self.singleSelect)
        self.singleSelect(employee);
    [self.navigationController popViewControllerAnimated:YES];
}
@end
