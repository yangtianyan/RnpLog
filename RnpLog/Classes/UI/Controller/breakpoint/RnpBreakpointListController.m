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
