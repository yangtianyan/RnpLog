//
//  RnpAddBreakpointController.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "RnpBreakpointInfoController.h"
#import "RnpRequestSetupController.h"
/* -- View -- */
#import "RnpAddBreakpointUrlCell.h"
#import "RnpBreakpointSwitchCell.h"
/* -- Model -- */
#import "RnpDataModel.h"
#import "RnpBreakpointModel.h"
/* -- Manager -- */
#import "RnpBreakpointManager.h"
/* -- Util -- */
#import "RnpDefine.h"
#import "NSData+log.h"
#import "NSDictionary+log.h"

static const NSString * kUrl = @"kUrl";
static const NSString * kRequestHeader = @"设置请求头";
static const NSString * kRequestBody = @"设置请求体";
//static const NSString * kResponseHeader = @"设置响应头";
static const NSString * kResponse = @"设置响应体";
static const NSString * kEnabled = @"启用";
static const NSString * kRequestBefore = @"请求前";
static const NSString * kRequestAfter = @"请求后";

@interface RnpBreakpointInfoController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, copy)   NSArray * dataArr;

@property (nonatomic, copy)   NSString * url;

@property (nonatomic, copy)   NSString * mock_response;

@property (nonatomic, copy)   NSString * mock_request_header;

@property (nonatomic, copy)   NSString * mock_request_body;

@end

@implementation RnpBreakpointInfoController

- (void)initNav{
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAct)];
    self.navigationItem.rightBarButtonItems =@[saveItem] ;
    self.title = @"断点信息";
}
- (void)initUI{
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}
- (void)initData{
    if (!self.breakpoint) {
        self.breakpoint = [RnpBreakpointModel new];
        self.breakpoint.mockResultData = self.dataModel.originalData;
//        self.breakpoint.mockRquestHeaderData = [self.dataModel.task.originalRequest.allHTTPHeaderFields.toJson dataUsingEncoding:NSUTF8StringEncoding];
//        self.breakpoint.mockRquestBodyData = [self requestBody];
    }
    self.mock_response = self.breakpoint.mockResultData.toString;
//    self.mock_request_header = self.breakpoint.mockRquestHeaderData.toString;
//    self.mock_request_body = self.breakpoint.mockRquestBodyData.toString;

    if (self.breakpoint.isActivate) {
        self.dataArr = @[kUrl,kResponse,kEnabled,kRequestBefore,kRequestAfter];
    }else{
        self.dataArr = @[kUrl,kResponse,kEnabled];
    }
    if (self.dataModel) {
        self.url = self.dataModel.task.originalRequest.URL.absoluteString;
    }else{
        self.url = self.breakpoint.url;
    }
    [self.breakpoint addObserver:self forKeyPath:@"isActivate" options:NSKeyValueObservingOptionNew context:nil];
    [self.breakpoint addObserver:self forKeyPath:@"isBefore" options:NSKeyValueObservingOptionNew context:nil];
    [self.breakpoint addObserver:self forKeyPath:@"isAfter" options:NSKeyValueObservingOptionNew context:nil];
}
- (NSData *)requestBody{
    NSURLRequest * request = self.dataModel.task.originalRequest;
    if (request.HTTPBody) {
        return request.HTTPBody;
    }else if (request.HTTPBodyStream){
        uint8_t d[1024] = {0};
        NSInputStream *stream = request.HTTPBodyStream;
        NSMutableData *data = [[NSMutableData alloc] init];
        [stream open];
        
        while ([stream hasBytesAvailable]) {
            NSInteger len = [stream read:d maxLength:1024];
            if (len > 0 && stream.streamError == nil) {
                [data appendBytes:(void *)d length:len];
            }
        }
        [stream close];
        return data;
    }
    return nil;
}

#pragma mark -- Action
- (void)saveAct{
    if (self.url.length > 0) {
        self.breakpoint.url = self.url;
        if (self.mock_response) {
            self.breakpoint.mockResultData = [self.mock_response dataUsingEncoding:NSUTF8StringEncoding];
        }
        if (self.mock_request_body) {
            self.breakpoint.mockRquestBodyData = [self.mock_request_body dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if (self.mock_request_header) {
            self.breakpoint.mockResultData = [self.mock_request_header dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if ([RnpBreakpointManager.instance getModelForUrl:self.url]) {
            __weak typeof(self) weakSelf = self;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"已设置断点, 确认更换断点信息?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [RnpBreakpointManager.instance addBreakpointWithModel:weakSelf.breakpoint];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            [RnpBreakpointManager.instance addBreakpointWithModel:self.breakpoint];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
#pragma mark -- lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = UITableViewNew().rnp
        .delegate(self)
        .dataSource(self)
        .registerClass(RnpAddBreakpointUrlCell.class)
        .registerClass(RnpBreakpointSwitchCell.class)
        .registerClass(UITableViewCell.class)
        .tableFooterView(UIView.new)
        .view;
    }
    return _tableView;
}
#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * string = self.dataArr[indexPath.row];
    __weak typeof(self) weakSelf = self;
    if ([string isEqual:kUrl]) {
        RnpAddBreakpointUrlCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpAddBreakpointUrlCell.class);
        cell.textChangeBlock = ^(NSString * _Nonnull text) {
            weakSelf.url = text;
        };
        cell.url = self.url;
        cell.editable = self.type == 0;
        return cell;
    }else if([string isEqual:kEnabled] || [string isEqual:kRequestBefore] || [string isEqual:kRequestAfter]){
        RnpBreakpointSwitchCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpBreakpointSwitchCell.class);
        cell.title = string;
        if ([string isEqual:kEnabled]) {
            cell.isOn = self.breakpoint.isActivate;
        }else if ([string isEqual:kRequestBefore]) {
            cell.isOn = self.breakpoint.isBefore;
        }else if ([string isEqual:kRequestAfter]) {
            cell.isOn = self.breakpoint.isAfter;
        }
        cell.onChange = ^(BOOL on) {
            if ([string isEqual:kEnabled]) {
                weakSelf.breakpoint.isActivate = on;
            }else if ([string isEqual:kRequestBefore]) {
                weakSelf.breakpoint.isBefore = on;
            }else if ([string isEqual:kRequestAfter]) {
                weakSelf.breakpoint.isAfter = on;
            }
        };
        return cell;
    }else{
        UITableViewCell * cell = tableView.rnp.dequeueReusableCellWithClass(UITableViewCell.class);
        cell.textLabel.text = string;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * string = self.dataArr[indexPath.row];
    if ([string isEqual:kUrl]) {
        return 150.f;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    NSString * string = self.dataArr[indexPath.row];
    if([string isEqual:kResponse] || [string isEqual:kRequestHeader] || [string isEqual:kRequestBody]){
        RnpRequestSetupController * controller = [RnpRequestSetupController new];
        controller.title = string;
        __weak typeof(self) weakSelf = self;
        if ([string isEqual:kResponse]) {
            controller.text = self.mock_response;
            controller.onSaveBlock = ^(NSString * _Nonnull text) {
                weakSelf.mock_response = text;
            };
        }else if ([string isEqual:kRequestHeader]){
            controller.text = self.mock_request_header;
            controller.onSaveBlock = ^(NSString * _Nonnull text) {
                weakSelf.mock_request_header = text;
            };
        }else if ([string isEqual:kRequestBody]){
            controller.text = self.mock_request_body;
            controller.onSaveBlock = ^(NSString * _Nonnull text) {
                weakSelf.mock_request_body = text;
            };
        }
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
#pragma mark -- observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqual:@"isActivate"]) {
        if (self.breakpoint.isActivate == NO) {
            self.dataArr = @[kUrl,kRequestHeader,kRequestBody,kResponse,kEnabled];
        }else{
            self.breakpoint.isAfter = YES;
            self.breakpoint.isBefore = NO;
            self.dataArr = @[kUrl,kRequestHeader,kRequestBody,kResponse,kEnabled,kRequestBefore,kRequestAfter];
        }
    }else{
        if (self.breakpoint.isAfter == NO && self.breakpoint.isBefore == NO) {
            self.breakpoint.isActivate = NO;
            self.dataArr = @[kUrl,kRequestHeader,kRequestBody,kResponse,kEnabled];
        }
    }
    [self.tableView reloadData];
    
}

#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initNav];
    [self initUI];
}
- (void)dealloc
{
    [self.breakpoint removeObserver:self forKeyPath:@"isActivate"];
    [self.breakpoint removeObserver:self forKeyPath:@"isBefore"];
    [self.breakpoint removeObserver:self forKeyPath:@"isAfter"];
}
@end
