//
//  RnpLogSearchListController.m
//  RnpLog
//
//  Created by user on 2022/2/16.
//

#import "RnpLogSearchListController.h"
#import "RnpRequestDetailController.h"
/* -- View -- */
#import "RnpRequestCell.h"
/* -- Model -- */
#import "RnpDataModel.h"
/* -- util -- */
#import "RnpDefine.h"
#import "RnpCaptureDataManager.h"
@interface RnpLogSearchListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UITextField * textField;

@property (nonatomic, strong) UIButton * button;

@property (nonatomic, strong) NSMutableArray * dataArr;

@end
 
@implementation RnpLogSearchListController
- (void)initUI{
    self.title = @"搜索过滤";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.backgroundColor = UIColor.whiteColor;
    self.textField = UITextFieldNew().rnp
    .placeholder(@"请输入(不区分大小写)")
    .clearButtonMode(UITextFieldViewModeWhileEditing)
    .view;
    
    __weak typeof(self) weakSelf = self;
    self.button = UIButtonNew().rnp
    .backgroundColor(rgba(52,158,103, 1))
    .text(@"搜索", UIControlStateNormal)
    .addToSuperView(self.view)
    .cornerRadius(8.f)
    .addClickBlock(^(UIButton *btn){
        [weakSelf.view endEditing:YES];
        [weakSelf filterUrl];
    })
    .view;
    
    UIViewNew().rnp
    .addSubView(self.textField)
    .addToSuperView(self.view)
    .backgroundColor(UIColor.whiteColor)
    .border(1, UIColor.lightGrayColor)
    .cornerRadius(5.f)
    .mas_makeConstraints(^(MASConstraintMaker * _Nonnull make) {
        make.left.mas_equalTo(15.f);
        make.top.mas_equalTo(10.f);
        make.right.equalTo(self.button.mas_left).offset(-10.f);
        make.height.mas_equalTo(40);
    });
    UIViewNew().rnp
    .addToSuperView(self.view)
    .backgroundColor(UIColor.lightGrayColor)
    .mas_makeConstraints(^(MASConstraintMaker * _Nonnull make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1.f);
        make.top.equalTo(self.textField.superview.mas_bottom).offset(9.f);
    });
    
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView);
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.height.centerY.equalTo(self.textField.superview);
        make.width.mas_equalTo(60.f);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.f);
        make.right.mas_equalTo(-5.f);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.top.equalTo(self.textField.mas_bottom).offset(10.f);
    }];
}
- (void)filterUrl{
    NSString * text = [self.textField.text lowercaseString];
    if (text.length == 0) {
        return;
    }
    [self.dataArr removeAllObjects];
    [[[RnpCaptureDataManager.instance.requests reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(RnpDataModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * url = [[NSString stringWithFormat:@"%@", obj.task.originalRequest.URL] lowercaseString];
        if ([url containsString:text]) {
            [self.dataArr addObject:obj];
        }
    }];
    [self.tableView reloadData];
}
#pragma mark -- lazy
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray new];
    }
    return _dataArr;
}
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
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RnpRequestCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpRequestCell.class);
    RnpDataModel * model = self.dataArr[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RnpRequestDetailController * vc = [RnpRequestDetailController new];
    vc.model = self.dataArr[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
#pragma mark -- notification
- (void)notification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRequest) name:kAddRequestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:kClearRequestNotification object:nil];
}
- (void)addRequest{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.textField.text == 0) {
            [self reloadData];
        }else{
            [self filterUrl];
        }
    });
}
- (void)reloadData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArr addObjectsFromArray:[[RnpCaptureDataManager.instance.requests reverseObjectEnumerator] allObjects]];
    [self initUI];
    [self notification];
}

@end
