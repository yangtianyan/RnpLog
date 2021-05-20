//
//  RnpBreakpointListController.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "RnpBreakpointListController.h"
#import "RnpAddBreakpointController.h"
/* -- Util -- */
#import <RnpKit/RnpKitView.h>
@interface RnpBreakpointListController ()

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation RnpBreakpointListController

- (void)initNav{
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithTitle:@"断点" style:UIBarButtonItemStylePlain target:self action:@selector(addAct)];
    self.navigationItem.rightBarButtonItems =@[addItem] ;
    self.title = @"断点列表";
}
- (void)initUI{
    
}

#pragma mark -- action
- (void)addAct{
    
}

#pragma mark -- lazy
#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark -- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self initNav];
}

@end
