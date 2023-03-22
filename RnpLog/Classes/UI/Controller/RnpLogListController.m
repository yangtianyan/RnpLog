//
//  RnpLogListController.m
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import "RnpLogListController.h"
#import "RnpRequestDetailController.h"
#import "RnpBreakpointListController.h"
#import "RnpReplaceHostController.h"
#import "RnpHostManagerController.h"
#import "RnpLogSearchListController.h"
/* -- View --*/
#import "RnpEnterPlugView.h"
#import "RnpRequestCell.h"
/* -- Manager -- */
#import "RnpCaptureDataManager.h"
/* -- Util -- */
#import "RnpDefine.h"
@interface RnpLogListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation RnpLogListController

- (void)initUI{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAct)];
    self.navigationItem.leftBarButtonItem = backItem;
    UIBarButtonItem * clearItem = [[UIBarButtonItem alloc] initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(clearAct)];
    UIBarButtonItem * breakpointItem = [[UIBarButtonItem alloc] initWithTitle:@"断点" style:UIBarButtonItemStylePlain target:self action:@selector(breakpointAct)];
    UIBarButtonItem * replaceItem = [[UIBarButtonItem alloc] initWithTitle:@"域名管理" style:UIBarButtonItemStylePlain target:self action:@selector(hostAct)];
    UIBarButtonItem * searchItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchAct)];

    self.navigationItem.rightBarButtonItems =@[clearItem, breakpointItem, replaceItem, searchItem];
    self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor;
    self.title = @"网络请求列表";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}
#pragma mark -- backAct
- (void)backAct{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)clearAct{
    [RnpCaptureDataManager.instance clear];
    [self.tableView reloadData];
}
- (void)breakpointAct{
    [self.navigationController pushViewController:[RnpBreakpointListController new] animated:YES];
}
- (void)hostAct{
    [self.navigationController pushViewController:[RnpHostManagerController new] animated:YES];
}
- (void)searchAct{
    [self.navigationController pushViewController:[RnpLogSearchListController new] animated:YES];
}
#pragma mark -- lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = UITableViewNew().rnp
        .delegate(self)
        .dataSource(self)
        .estimatedRowHeight(60)
        .tableFooterView([UIView new])
        .registerClass(RnpRequestCell.class)
        .view;
    }
    return _tableView;
}

#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return RnpCaptureDataManager.instance.requests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RnpRequestCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpRequestCell.class);
    RnpDataModel * model = RnpCaptureDataManager.instance.requests[RnpCaptureDataManager.instance.requests.count-indexPath.row-1];
    cell.model = model;
    __weak typeof(self) weakSelf = self;
    cell.longPressBlock = ^{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * clear = [UIAlertAction actionWithTitle:@"清除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [RnpCaptureDataManager.instance clearWith:model];
        }];
        UIAlertAction * clearOther = [UIAlertAction actionWithTitle:@"清除其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [RnpCaptureDataManager.instance clearOther:model];
        }];
        [alert addAction:clear];
        [alert addAction:clearOther];
        [alert addAction:cancel];
        [weakSelf presentViewController:alert animated:YES completion:^{
            
        }];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RnpRequestDetailController * vc = [RnpRequestDetailController new];
    vc.model = RnpCaptureDataManager.instance.requests[RnpCaptureDataManager.instance.requests.count-indexPath.row-1];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- notification
- (void)notification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRequest) name:kAddRequestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kClearRequestNotification object:nil];
}
- (void)addRequest{
    [self reloadData];
}
- (void)reloadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [RnpEnterPlugView hidden];
    [self notification];
}
- (void)dealloc
{
    [RnpEnterPlugView show];
}

@end
