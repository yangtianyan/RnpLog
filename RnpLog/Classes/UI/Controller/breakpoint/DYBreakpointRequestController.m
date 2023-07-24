//
//  DYBreakpointRequestController.m
//  RnpLog
//
//  Created by user on 2021/5/21.
//

#import "DYBreakpointRequestController.h"
/* -- Util -- */
#import "RnpDefine.h"
#import "NSObject+top.h"
#import "NSData+log.h"
#import "NSDictionary+log.h"
#import <RnpKit/RnpKitAttributedString.h>
#import "NSString+log.h"

@interface DYBreakpointRequestController ()

@property (nonatomic, strong) UITextView * urlTV;

@property (nonatomic, strong) UIView     * urlView;

@property (nonatomic, strong) UITextView * headerTV;

@property (nonatomic, strong) UIView     * headerView;

@property (nonatomic, strong) UITextView * bodyTV;

@property (nonatomic, strong) UIView     * bodyView;

@property (nonatomic, copy)   void(^completion)(void);

@end

@implementation DYBreakpointRequestController

- (void)initNav{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAct)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveAct)];
    self.navigationItem.rightBarButtonItems =@[saveItem] ;
}

- (void)initUI{
    UITextView * tv;
    self.urlView = [self createViewWithTitle:@"请求地址" info:self.request.URL.absoluteString textView:&tv];
    self.urlTV = tv;
    self.headerView = [self createViewWithTitle:@"请求头" info:self.request.allHTTPHeaderFields.toJson textView:&tv];
    self.headerTV = tv;
    self.bodyView = [self createViewWithTitle:@"请求体" info:[self requestBody] textView:&tv];
    self.bodyTV = tv;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.rnp.backgroundColor(UIColor.whiteColor);
    [self.urlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
    }];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.urlView.mas_bottom);
        make.width.left.equalTo(self.urlView);
        make.height.equalTo(self.urlView).multipliedBy(1.5);
    }];
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.width.left.equalTo(self.urlView);
        make.height.equalTo(self.urlView).multipliedBy(1.5);
        make.bottom.mas_equalTo(0);
    }];

    self.bodyView.hidden = ![self.request.HTTPMethod isEqual:@"POST"];
}

- (NSString *)requestBody{
    NSString * p_body = nil;
    if (self.request.HTTPBody) {
        NSString * string = [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
        p_body = string;
    }else if (self.request.HTTPBodyStream){
        uint8_t d[1024] = {0};
        NSInputStream *stream = self.request.HTTPBodyStream;
        NSMutableData *data = [[NSMutableData alloc] init];
        [stream open];
        
        while ([stream hasBytesAvailable]) {
            NSInteger len = [stream read:d maxLength:1024];
            if (len > 0 && stream.streamError == nil) {
                [data appendBytes:(void *)d length:len];
            }
        }
        [stream close];
        NSString * string = data.toString;
        p_body = string;
    }
    return p_body;
}


- (UIView *)createViewWithTitle:(NSString *)title info:(NSString *)info textView:(UITextView **)textView{
    
    UIView * view = UIViewNew().rnp
    .addToSuperView(self.view)
    .view;
   UILabel * label = UILabelNew().rnp
    .addToSuperView(view)
    .mas_makeConstraints(^(MASConstraintMaker * _Nonnull make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(10);
    })
    .text(title)
    .view;
    
    *textView = UITextViewNew().rnp
    .addToSuperView(view)
    .attributedText(info.toLogAttributedString)
    .mas_makeConstraints(^(MASConstraintMaker * make){
        make.left.right.equalTo(label);
        make.top.equalTo(label.mas_bottom).offset(10.f);
        make.bottom.mas_equalTo(0);
    })
    .view;
    return view;
}
#pragma mark -- Action
- (void)backAct{
    [self dismissViewControllerAnimated:YES completion:self.completion];
}
- (void)saveAct{
    if (self.urlTV.text.length > 0) {
        self.request.URL = [NSURL URLWithString:self.urlTV.text];
    }
    if (self.headerTV.text.length > 0) {
        NSData *jsonData = [self.headerTV.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(!err) {
            [self.request setAllHTTPHeaderFields:dic];
        }
    }
    if (self.bodyTV.text.length > 0) {
        self.request.HTTPBody = [self.bodyTV.text dataUsingEncoding:NSUTF8StringEncoding];
    }
    [self dismissViewControllerAnimated:YES completion:self.completion];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initUI];
}
+ (void)showWithRequest:(NSMutableURLRequest *)request completion:(void(^)(void))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{    
        DYBreakpointRequestController * controller = [DYBreakpointRequestController new];
        controller.request = request;
        controller.completion = completion;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [controller.topViewController presentViewController:nav animated:YES completion:nil];
    });
}
@end
