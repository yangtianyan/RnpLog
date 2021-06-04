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

    self.navigationItem.rightBarButtonItems =@[clearItem, breakpointItem, replaceItem];
    
    self.title = @"网络请求列表";
    
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
    cell.model = RnpCaptureDataManager.instance.requests[RnpCaptureDataManager.instance.requests.count-indexPath.row-1];
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
}
- (void)addRequest{
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
//    NSLog(@"requests: %@", RnpCaptureDataManager.instance.requests);
}
- (void)dealloc
{
    [RnpEnterPlugView show];
}

@end
