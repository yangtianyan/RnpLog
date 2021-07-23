//
//  RnpHostManagerController.m
//  RnpLog
//
//  Created by user on 2021/6/4.
//

#import "RnpHostManagerController.h"
#import "RnpBreakpointWhiteListController.h"
#import "RnpReplaceHostController.h"
/* -- Util -- */
#import "RnpDefine.h"

static const NSString * kWhiteListHost = @"域名白名单";
static const NSString * kReplaceHost = @"域名替换";

@interface RnpHostManagerController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, copy) NSArray * dataArr;

@end

@implementation RnpHostManagerController
- (void)initUI{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView);
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}
#pragma mark -- lazy
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = UITableViewNew().rnp
        .registerClass(UITableViewCell.class)
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
    UITableViewCell * cell = tableView.rnp.dequeueReusableCellWithClass(UITableViewCell.class);
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.f;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * string = self.dataArr[indexPath.row];
    if ([string isEqual:kWhiteListHost]) {
        [self.navigationController pushViewController:[RnpBreakpointWhiteListController new] animated:YES];
    }else if ([string isEqual:kReplaceHost])
    {
        [self.navigationController pushViewController:[RnpReplaceHostController new] animated:YES];
    }
}

#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr = @[kWhiteListHost, kReplaceHost];
    [self initUI];
}


@end
