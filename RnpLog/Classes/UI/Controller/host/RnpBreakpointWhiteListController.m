//
//  RnpBreakpointWhiteListController.m
//  RnpLog
//
//  Created by user on 2021/6/4.
//

#import "RnpBreakpointWhiteListController.h"
/* -- View -- */
#import "RnpWhiteListHostCell.h"
/* -- Util -- */
#import "RnpHostManager.h"
#import "RnpDefine.h"
/* -- Model -- */
#import "RnpWhiteListHostModel.h"
@interface RnpBreakpointWhiteListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, copy)   NSArray * dataArr;

@end

@implementation RnpBreakpointWhiteListController

- (void)initNav{
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAct)];
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAct)];

    self.navigationItem.rightBarButtonItems =@[saveItem,addItem] ;
    self.title = @"域名白名单";
}

- (void)initUI{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self resetDataArrWithArray:RnpHostManager.instance.white_list];
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView)
    ;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)resetDataArrWithArray:(NSArray *)whiteList{
    NSMutableArray * mutable = [NSMutableArray new];
    for (NSString * host in whiteList) {
        RnpWhiteListHostModel * model = [RnpWhiteListHostModel new];
        model.host = host;
        [mutable addObject:model];
    }
    if (mutable.count == 0) {
        [mutable addObject:[RnpWhiteListHostModel new]];
    }
    self.dataArr = mutable.copy;
}
#pragma mark -- Action
- (void)saveAct{
    NSMutableArray * whiteList = [NSMutableArray new];
    for (RnpWhiteListHostModel * model in self.dataArr) {
        if (model.host.length >0 ) {
            [whiteList addObject:model.host];
        }
    }
    [RnpHostManager.instance setupWhiteList:whiteList];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addAct{
    NSMutableArray * mutable = self.dataArr.mutableCopy;
    [mutable addObject:[RnpWhiteListHostModel new]];
    self.dataArr = mutable.copy;
    [self.tableView reloadData];
}
#pragma mark -- lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = UITableViewNew().rnp
        .registerClass(RnpWhiteListHostCell.class)
        .delegate(self)
        .dataSource(self)
        .tableFooterView([UIView new])
        .view;
    }
    return _tableView;
}

#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RnpWhiteListHostCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpWhiteListHostCell.class);
    cell.hostModel = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认删除?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray * mutable = self.dataArr.mutableCopy;
        [mutable removeObjectAtIndex:indexPath.row];
        weakSelf.dataArr = mutable.copy;
        [weakSelf.tableView reloadData];
        [tableView reloadData];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNav];
    [self initUI];
}

@end
