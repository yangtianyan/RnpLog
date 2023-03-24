//
//  RnpJsonTreeView.m
//  RnpLog
//
//  Created by user on 2023/3/23.
//

#import "RnpJsonTreeView.h"
#import "RnpJsonTreeCell.h"
/* -- Model -- */
#import "RnpTreeModel.h"
/* -- Util -- */
#import <RnpKit.h>

@interface RnpJsonTreeView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UIScrollView * scrollView;

@end
@implementation RnpJsonTreeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.scrollView = UIScrollViewNew().rnp
        .addToSuperView(self)
        .backgroundColor(UIColor.whiteColor)
        .mas_makeConstraints(^(MASConstraintMaker *make){
            (void)make.edges;
        })
        .view;
        
        self.tableView = UITableViewNew().rnp
        .separatorStyle(UITableViewCellSeparatorStyleNone)
        .delegate(self)
        .dataSource(self)
        .tableFooterView([UIView new])
        .registerClass(RnpJsonTreeCell.class)
        .backgroundColor(UIColor.whiteColor)
        .addToSuperView(self.scrollView)
        .mas_makeConstraints(^(MASConstraintMaker *make){
            make.top.height.equalTo(self);
            make.left.equalTo(self.scrollView);
            make.width.mas_equalTo(0);
        })
        .view;
    }
    return self;
}

#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.treeModel.allCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RnpJsonTreeCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpJsonTreeCell.class);
    RnpTreeValueModel * model = self.treeModel.allShowTrees[indexPath.row];
    cell.valueModel = model;
//    __weak typeof(self) weakSelf = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath{
      return YES;// 设置哪里显示。
}
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return YES;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action == @selector(copy:)) {
        RnpTreeValueModel * model = self.treeModel.allShowTrees[indexPath.row];
        [UIPasteboard generalPasteboard].string = model.cpText;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RnpTreeValueModel * model = self.treeModel.allShowTrees[indexPath.row];
    if(model.subTrees.count == 0) return;
    model.isFold = !model.isFold;
    [self.treeModel updateAllTrees];
    [self updateUI];
}

- (void)updateUI{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.treeModel.maxWidth);
    }];
    [self.scrollView setContentSize:CGSizeMake(self.treeModel.maxWidth, 0)];
    [self.tableView reloadData];
}

#pragma mark -- Public
- (void)setTreeModel:(RnpTreeModel *)treeModel
{
    _treeModel = treeModel;
    [self updateUI];
}

- (void)allFoldAct{
    [self.treeModel allFold];
    [self updateUI];
}
@end
