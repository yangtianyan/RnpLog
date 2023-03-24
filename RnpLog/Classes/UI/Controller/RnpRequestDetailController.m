//
//  RnpRequestDetailController.m
//  NetworkLog
//
//  Created by user on 2021/5/14.
//

#import "RnpRequestDetailController.h"
#import "RnpBreakpointInfoController.h"
/* -- Model -- */
#import "RnpDataModel.h"
#import "RnpTreeModel.h"
/* -- Util -- */
#import "RnpDefine.h"
#import <RnpKit/RnpKitAttributedString.h>
#import "NSString+log.h"
#import "NSURLRequest+curl.h"
/* -- View -- */
#import "RnpJsonTreeView.h"


@interface RnpRequestDetailController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView * textView;

@property (nonatomic, strong) RnpJsonTreeView * treeView;

@end

@implementation RnpRequestDetailController

- (void)initUI{
    self.view.rnp
    .addSubView(self.textView)
    .addSubView(self.treeView)
    ;
    
    [self.treeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    self.treeView.treeModel = [[RnpTreeModel alloc] initWithJson:[self.model rnpLogDataFormatToJson]];
    
    [self showText];
}

- (void)initNav{
    UIBarButtonItem * copy = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:UIBarButtonItemStylePlain target:self action:@selector(copyAction)];
    UIBarButtonItem * airDrop = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    UIBarButtonItem * breakpoint = [[UIBarButtonItem alloc] initWithTitle:@"设置断点" style:UIBarButtonItemStylePlain target:self action:@selector(breakpointAct)];
    self.navigationItem.rightBarButtonItems = @[airDrop,copy,breakpoint];
}

- (void)showText{
    NSString * content = [self.model rnpLogDataFormat];
    NSMutableAttributedString * attribute = content.toLogAttributedString.mutableCopy;
    NSArray * keys = @[@"OriginURL:",@"RedirectedURL:",@"Method:",@"Headers:",@"RequestBody:",@"Response:",@"ResponseHeader:", @"HookResponse:"];
    for (NSString * m_key in keys) {
        UIColor * keycolor = rgba(146, 38, 143, 1);
        NSRange range = [content rangeOfString:m_key];
        if (range.location != NSNotFound) {
            attribute.rnp.addAttributes_range(@{NSForegroundColorAttributeName: keycolor}, range);
        }
    }
    self.textView.attributedText = attribute;
}

#pragma mark -- setter
- (void)setModel:(RnpDataModel *)model
{
    _model = model;
    self.title = [NSString stringWithFormat:@"%@", model.task.originalRequest.URL];
}
#pragma mark -- lazy
- (UITextView *)textView{
    if (!_textView) {
        _textView = UITextViewNew().rnp
        .editable(false)
        .backgroundColor(UIColor.whiteColor)
        .translatesAutoresizingMaskIntoConstraints(false)
        .delegate(self)
        .view;
    }
    return _textView;
}

- (RnpJsonTreeView *)treeView
{
    if(!_treeView){
        _treeView = [[RnpJsonTreeView alloc] init];
    }
    return _treeView;
}

#pragma mark -- Action
- (void)copyAction {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"复制" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    UIAlertAction * copy = [UIAlertAction actionWithTitle:@"返回值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard * board = [UIPasteboard generalPasteboard];
        board.string = [weakSelf.model rnpLogDataFormatToJsonString];
    }];
    UIAlertAction * curl = [UIAlertAction actionWithTitle:@"curl" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard * board = [UIPasteboard generalPasteboard];
        board.string = [weakSelf.model.task.originalRequest curl];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:copy];
    [alertController addAction:curl];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:true completion:nil];

}
- (void)shareAction {
    NSString * text = self.textView.text;
    text = [text stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@","];
    text = [NSString stringWithFormat:@"{%@}",text];
    NSString * string = [self.model rnpLogDataFormatToJsonString];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
   
    NSString *json_path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"文本-%@.txt",dateString]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:json_path]) {
        [[NSFileManager defaultManager] removeItemAtPath:json_path error:nil];
    }
    [[NSFileManager defaultManager] createFileAtPath:json_path contents:[string dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    UIActivityViewController * vc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:json_path]] applicationActivities:nil];
    //去除特定的分享功能 不需要展现的Activity类型
    vc.excludedActivityTypes = @[
                                         UIActivityTypePostToFacebook,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypeMessage,
                                         UIActivityTypeMail,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         ];
    if ([vc respondsToSelector:@selector(popoverPresentationController)]) {
        vc.popoverPresentationController.sourceView = self.view;
    }
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)breakpointAct{
    RnpBreakpointInfoController * vc = [RnpBreakpointInfoController new];
    vc.dataModel = self.model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initNav];
}

@end
