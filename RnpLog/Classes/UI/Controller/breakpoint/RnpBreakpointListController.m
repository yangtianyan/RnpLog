//
//  RnpBreakpointListController.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "RnpBreakpointListController.h"
#import "RnpBreakpointInfoController.h"
/* -- View -- */
#import "RnpBreakpointSwitchCell.h"
/* -- Model -- */
#import "RnpBreakpointModel.h"
/* -- Manager -- */
#import "RnpBreakpointManager.h"
/* -- Util -- */
#import "RnpDefine.h"
@interface RnpBreakpointListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation RnpBreakpointListController

- (void)initNav{
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAct)];
    self.navigationItem.rightBarButtonItems =@[addItem] ;
    self.title = @"断点列表";
}
- (void)initUI{
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark -- action
- (void)addAct{
    [self.navigationController pushViewController:[RnpBreakpointInfoController new] animated:YES];
}

#pragma mark -- lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = UITableViewNew().rnp
        .delegate(self)
        .dataSource(self)
        .tableFooterView(UIView.new)
        .registerClass(RnpBreakpointSwitchCell.class)
        .view;
    }
    return _tableView;
}
#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [RnpBreakpointManager.instance.all_breakpoint_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RnpBreakpointSwitchCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpBreakpointSwitchCell.class);
    RnpBreakpointModel * model = RnpBreakpointManager.instance.all_breakpoint_list[RnpBreakpointManager.instance.all_breakpoint_list.count-indexPath.row-1];
    cell.title = model.url;
    cell.isOn = model.isActivate;
    cell.label.font = [UIFont systemFontOfSize:15];
    cell.label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
//    __weak typeof(self) weakSelf = self;
    cell.onChange = ^(BOOL on) {
        model.isActivate = on;
    };
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RnpBreakpointInfoController * vc = [RnpBreakpointInfoController new];
    RnpBreakpointModel * model = RnpBreakpointManager.instance.all_breakpoint_list[RnpBreakpointManager.instance.all_breakpoint_list.count-indexPath.row-1];
    vc.breakpoint = model;
    [self.navigationController pushViewController:vc animated:YES];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认删除该断点?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        RnpBreakpointModel * breakpoint = RnpBreakpointManager.instance.all_breakpoint_list[RnpBreakpointManager.instance.all_breakpoint_list.count - indexPath.row - 1];
        [RnpBreakpointManager.instance deleteBreakpoint:breakpoint];
        [tableView reloadData];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self initNav];
    [self initUI];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

@end
