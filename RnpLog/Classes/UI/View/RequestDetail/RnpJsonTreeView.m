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

@end
@implementation RnpJsonTreeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        self.tableView = UITableViewNew().rnp
        .separatorStyle(UITableViewCellSeparatorStyleNone)
        .delegate(self)
        .dataSource(self)
        .tableFooterView([UIView new])
        .registerClass(RnpJsonTreeCell.class)
        .addToSuperView(self)
        .mas_makeConstraints(^(MASConstraintMaker *make){
            (void)make.edges;
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RnpTreeValueModel * model = self.treeModel.allShowTrees[indexPath.row];
    if(model.subTrees.count == 0) return;
    model.isFold = !model.isFold;
    [self.treeModel updateAllTrees];
    [tableView reloadData];
}

#pragma mark -- Public
- (void)setTreeModel:(RnpTreeModel *)treeModel
{
    _treeModel = treeModel;
    [self.tableView reloadData];
}


@end
