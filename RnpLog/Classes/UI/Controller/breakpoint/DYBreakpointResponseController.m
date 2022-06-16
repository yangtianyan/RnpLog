//
//  DYBreakpointResponseController.m
//  RnpLog
//
//  Created by user on 2021/5/21.
//

#import "DYBreakpointResponseController.h"
/* -- Model -- */
#import "RnpDataModel.h"
/* -- Util -- */
#import "RnpDefine.h"
#import "NSString+log.h"
#import "NSObject+top.h"
#import "NSData+log.h"

@interface DYBreakpointResponseController ()

@property (nonatomic, strong) UITextView * textView;

@property (nonatomic, copy)   void(^completion)(void);

@end

@implementation DYBreakpointResponseController

- (void)initNav{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAct)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveAct)];
    self.navigationItem.rightBarButtonItems =@[saveItem] ;
}


- (void)initUI{
    self.textView = UITextViewNew().rnp
    .backgroundColor(UIColor.whiteColor)
    .translatesAutoresizingMaskIntoConstraints(false)
    .addToSuperView(self.view)
    .attributedText(self.dataModel.originalData.toString.toLogAttributedString)
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
- (void)backAct{
    [self dismissViewControllerAnimated:YES completion:self.completion];
}
- (void)saveAct{
    if (self.textView.text.length > 0 ) {
        NSData * data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
        self.dataModel.hookData = data;
        [self dismissViewControllerAnimated:YES completion:self.completion];
    }
}
#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initUI];
    [self notification];
}
+ (void)showWithDataModel:(RnpDataModel *)dataModel completion:(void(^)(void))completion{
    dispatch_async(dispatch_get_main_queue(), ^{
        DYBreakpointResponseController * controller = [DYBreakpointResponseController new];
        controller.completion = completion;
        controller.dataModel = dataModel;
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [controller.topViewController presentViewController:nav animated:YES completion:nil];
    });
}

@end
