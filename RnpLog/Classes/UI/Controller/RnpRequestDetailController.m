//
//  RnpRequestDetailController.m
//  NetworkLog
//
//  Created by user on 2021/5/14.
//

#import "RnpRequestDetailController.h"
/* -- Model -- */
#import "RnpDataModel.h"
/* -- Util -- */
#import "RnpDefine.h"
#import <RnpKit/RnpKitAttributedString.h>
@interface RnpRequestDetailController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView * textView;

@end

@implementation RnpRequestDetailController

- (void)initUI{
    self.view.rnp
    .addSubView(self.textView);
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    [self showText];
}

- (void)initNav{
    UIBarButtonItem * copy = [[UIBarButtonItem alloc] initWithTitle:@"复制" style:UIBarButtonItemStylePlain target:self action:@selector(copyAction)];
    UIBarButtonItem * airDrop = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItems = @[airDrop,copy];
}

- (void)showText{
    NSString * content = [self.model rnpLogDataFormat];
    NSMutableAttributedString * attribute = [[NSMutableAttributedString alloc] initWithString:content];
    NSString * pattern0 = @"((.*?)\\s=)|(\"(.*?)\"\\s:)";
    NSRange contentRange0 = NSMakeRange(0, content.length);
//    NSRegularExpression.init(pattern: pattern0, options: .caseInsensitive);
    NSRegularExpression * express0 = [[NSRegularExpression alloc] initWithPattern:pattern0 options:NSRegularExpressionCaseInsensitive error:nil];
//    let expressResults0 = express0?.matches(in: content, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: contentRange0)
    NSArray<NSTextCheckingResult *> * expressResults0 = [express0 matchesInString:content options:NSMatchingReportProgress range:contentRange0];

    for (NSTextCheckingResult *check in expressResults0) {
        NSRange range = NSMakeRange(check.range.location, check.range.length > 1 ? check.range.length - 1 : check.range.length);
        UIColor * keycolor = [UIColor colorWithRed:58/255.f green:181/255.f blue:75/255.f alpha:1];
        attribute.rnp.addAttributes_range(@{NSForegroundColorAttributeName : keycolor}, range);
    }
    
    NSString * pattern = @"((https|http|ftp|rtsp|mms)?:\\/\\/)(.*?)(\"|\\s)";
    NSRegularExpression * express = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray<NSTextCheckingResult *> * expressResults = [express matchesInString:content options:NSMatchingReportProgress range:contentRange0];
    for (NSTextCheckingResult *check in expressResults) {
        NSRange range = NSMakeRange(check.range.location, check.range.length > 1 ? check.range.length - 1 : check.range.length);
        UIColor * httpcolor = [UIColor colorWithRed:97/255.f green:210/255.f blue:214/255.f alpha:1];
        attribute.rnp.addAttributes_range(@{NSForegroundColorAttributeName : httpcolor}, range);
    }

    NSArray * keys = @[@"URL:",@"Method:",@"Headers:",@"RequestBody:",@"Response:",@"ResponseHeader:", @"HookResponse:"];
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
#pragma mark -- Action
- (void)copyAction {
    UIPasteboard * board = [UIPasteboard generalPasteboard];
    board.string = self.textView.text;
}
- (void)shareAction {
    UIActivityViewController * vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.textView.text] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initNav];
}

@end
