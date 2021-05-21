//
//  RnpRequestSetupController.m
//  RnpLog
//
//  Created by user on 2021/5/20.
//

#import "RnpRequestSetupController.h"
/* -- Util -- */
#import "RnpDefine.h"
#import "NSString+log.h"
@interface RnpRequestSetupController ()

@property (nonatomic, strong) UITextView * textView;

@end

@implementation RnpRequestSetupController

- (void)initNav{
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveAct)];
    self.navigationItem.rightBarButtonItems =@[saveItem] ;
}

- (void)initUI{
    self.textView = UITextViewNew().rnp
    .backgroundColor(UIColor.whiteColor)
    .translatesAutoresizingMaskIntoConstraints(false)
    .addToSuperView(self.view)
    .attributedText(self.text.toLogAttributedString)
    .mas_makeConstraints(^(MASConstraintMaker *make){
        make.edges.mas_equalTo(0);
    })
    .view;
    
}
#pragma mark -- Action
- (void)saveAct{
    if (self.textView.text.length > 0 && self.onSaveBlock) {
        self.onSaveBlock(self.textView.text);
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initUI];
}

@end
