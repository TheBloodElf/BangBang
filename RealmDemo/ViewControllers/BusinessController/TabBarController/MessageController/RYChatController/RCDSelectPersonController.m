//
//  RCDSelectPersonController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "RCDSelectPersonController.h"
#import "MuliteSelectCell.h"
#import "MuliteSelectTopView.h"
#import "SelectEmployeeModel.h"
#import "AllSelectBtn.h"
#import "UserManager.h"

@interface RCDSelectPersonController ()<UITableViewDelegate,UITableViewDataSource,MuliteSelectTopViewDelegate> {
    NSMutableArray<SelectEmployeeModel*> *_selectEmployees;//要显示的"员工"数组
    MuliteSelectTopView *_muliteSelectTopView;
    AllSelectBtn *_allSelectBtn;
    UITableView *_tableView;
    NSMutableArray *_employeekeyArr;//都有的首字母数组
    NSMutableArray *_employeeDataArr;//所有的值数组
}


@end

@implementation RCDSelectPersonController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectEmployees = [@[] mutableCopy];
    _employeekeyArr = [@[] mutableCopy];
    _employeeDataArr = [@[] mutableCopy];
    self.title = @"人员选择";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightBarButtomItemAction)];
    
    _muliteSelectTopView = [[MuliteSelectTopView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 44)];
    _muliteSelectTopView.delegate = self;
    [self.view addSubview:_muliteSelectTopView];
    
    _allSelectBtn = [AllSelectBtn buttonWithType:UIButtonTypeCustom];
    _allSelectBtn.frame = CGRectMake(0, CGRectGetMaxY(_muliteSelectTopView.frame) + 10, MAIN_SCREEN_WIDTH,30);
    _allSelectBtn.backgroundColor = [UIColor whiteColor];
    [_allSelectBtn setTitleColor:[UIColor colorFromHexCode:@"848484"] forState:UIControlStateNormal];
    [_allSelectBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_allSelectBtn setTitleColor:[UIColor colorFromHexCode:@"848484"] forState:UIControlStateSelected];
    [_allSelectBtn setTitle:@"全选" forState:UIControlStateSelected];
    [_allSelectBtn setImage:[UIImage imageNamed:@"btn_nomaril_icon"] forState:UIControlStateNormal];
    [_allSelectBtn setImage:[UIImage imageNamed:@"btn_select_icon"] forState:UIControlStateSelected];
    [_allSelectBtn addTarget:self action:@selector(allSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_allSelectBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_allSelectBtn.frame), MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - CGRectGetMaxY(_allSelectBtn.frame) + 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
    [_tableView registerNib:[UINib nibWithNibName:@"MuliteSelectCell" bundle:nil] forCellReuseIdentifier:@"MuliteSelectCell"];
    [self.view addSubview:_tableView];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self getSureDataArr];
    [self searEmployeeWithText:@""];
    // Do any additional setup after loading the view from its nib.
}
//获取正确员工数据
- (void)getSureDataArr {
    NSMutableArray<Employee*> *employeeArr = [@[] mutableCopy];
    //获取应该显示的员工数组
    employeeArr = [[UserManager manager] getEmployeeWithCompanyNo:self.companyNo ?: [UserManager manager].user.currCompany.company_no status:1];
    //获取已经被选中的用户NO 不显示这些人
    NSMutableArray<NSString*> *selectedUserNoArr = [@[] mutableCopy];
    for (Employee *employee in self.selectedEmployees) {
        if(employee.user_no)
            [selectedUserNoArr addObject:@(employee.user_no).stringValue];
    }
    for (Employee *tempEmployee in employeeArr) {
        SelectEmployeeModel *model = [[SelectEmployeeModel alloc] initWithEmployee:tempEmployee];
        if(![selectedUserNoArr containsObject:@(model.user_no).stringValue])
            [_selectEmployees addObject:model];
    }
    //显示已经选择的人
    _muliteSelectTopView.data = [self getSelected];
}
- (void)allSelectBtn:(UIButton*)btn {
    BOOL selected = !_allSelectBtn.selected;
    for (NSArray *dataArr in _employeeDataArr) {
        for (SelectEmployeeModel *employee in dataArr) {
            employee.isSelected = selected;
        }
    }
    [_tableView reloadData];
    _allSelectBtn.selected = selected;
    _muliteSelectTopView.data = [self getSelected];
}
//获取所有的被选中的人
- (NSMutableArray*)getSelected {
    NSMutableArray *array = [@[] mutableCopy];
    for (SelectEmployeeModel *employee in _selectEmployees) {
        if(employee.isSelected == YES)
            [array addObject:employee];
    }
    return array;
}
//判断全选按钮是否选中
- (BOOL)judgeAllBtnSelect {
    BOOL selected = YES;
    for (NSArray *dataArr in _employeeDataArr) {
        for (SelectEmployeeModel *employee in dataArr) {
            if(employee.isSelected == NO)
                return NO;
        }
    }
    return selected;
}
- (void)searEmployeeWithText:(NSString*)text {
    NSMutableDictionary<NSString*,NSMutableArray*> *_currDataArr = [@{} mutableCopy];//根据搜索出的员工的首字母-员工数组的字典
    [_employeeDataArr removeAllObjects];
    [_employeekeyArr removeAllObjects];
    //先把字典填充A-Z对应的空数组
    for (int i = 0;i < 26;i ++) {
        char currChar = 'A' + i;
        NSString *currStr = [NSString stringWithFormat:@"%c",currChar];
        [_currDataArr setObject:[@[] mutableCopy] forKey:currStr];
    }
    [_currDataArr setObject:[@[] mutableCopy] forKey:@"#"];
    //填充数据
    for (SelectEmployeeModel *tempEmployee in _selectEmployees) {
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
    _employeekeyArr = [_currDataArr.allKeys mutableCopy];
    [_employeekeyArr sortUsingComparator:^NSComparisonResult(NSString* obj1,NSString* obj2) {
        return [obj1 compare:obj2] == 1;
    }];
    //把#放最后
    if(_employeekeyArr.count != 0) {
        if([_employeekeyArr[0] isEqualToString:@"#"]) {
            [_employeekeyArr removeObject:@"#"];
            [_employeekeyArr addObject:@"#"];
        }
    }
    //得到对应的名字数组
    for (NSString *keyStr in _employeekeyArr) {
        [_employeeDataArr addObject:_currDataArr[keyStr]];
    }
    [_tableView reloadData];
    _allSelectBtn.selected = [self judgeAllBtnSelect];
}
#pragma mark --
#pragma mark -- MuliteSelectTopViewDelegate
- (void)muliteSelectTextField:(UITextField *)textField {
    [self searEmployeeWithText:textField.text];
    [self.view endEditing:YES];
}
- (void)muliteSelectDel:(SelectEmployeeModel*)model {
    model.isSelected = NO;
    [_tableView reloadData];
    _muliteSelectTopView.data = [self getSelected];
    [self judgeAllBtnSelect];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    bgView.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
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
    MuliteSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MuliteSelectCell" forIndexPath:indexPath];
    SelectEmployeeModel *employee = _employeeDataArr[indexPath.section][indexPath.row];
    cell.data = employee;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectEmployeeModel *employee = _employeeDataArr[indexPath.section][indexPath.row];
    employee.isSelected = !employee.isSelected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    _allSelectBtn.selected = [self judgeAllBtnSelect];
    _muliteSelectTopView.data = [self getSelected];
}
- (void)rightBarButtomItemAction {
    //得到选中的员工数组
    NSMutableArray<Employee*> *employeeArr = [@[] mutableCopy];
    for (SelectEmployeeModel *model in _selectEmployees) {
        if(model.isSelected == YES) {
            Employee *em = [Employee new];
            [em mj_setKeyValues:[model mj_keyValues]];
            [employeeArr addObject:em];
        }
    }
    //转换成融云用户数组
    if (employeeArr.count < 2 && (self.selectedEmployees.count == 0)) {
        [self.navigationController.view showMessageTips:@"讨论组至少需要选择两个人！"];
        return;
    }
    //得到当前被选择的人
    NSMutableArray *rcUsers = [NSMutableArray new];
    for (Employee *employee in employeeArr) {
        RCUserInfo *user = [RCUserInfo new];
        user.userId = @(employee.user_no).stringValue;
        user.name = employee.user_real_name;
        user.portraitUri = employee.avatar;
        [rcUsers addObject:user];
    }
    //得到已经被选中的人
    for (Employee *employee in self.selectedEmployees) {
        RCUserInfo *user = [RCUserInfo new];
        user.userId = @(employee.user_no).stringValue;
        user.name = employee.user_real_name;
        user.portraitUri = employee.avatar;
        [rcUsers addObject:user];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(muliteSelect:rCDSelect:)]) {
        [self.delegate muliteSelect:rcUsers rCDSelect:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
