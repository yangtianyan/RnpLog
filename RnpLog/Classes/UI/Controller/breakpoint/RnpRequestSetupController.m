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
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
#pragma mark -- notification
- (void)notification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyBoardDidShow:(NSNotification *)notify{
    CGRect rect = [notify.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-rect.size.height);
    }];
}

- (void)keyBoardDidHide:(NSNotification *)notify{
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
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
    [self notification];
}

@end
