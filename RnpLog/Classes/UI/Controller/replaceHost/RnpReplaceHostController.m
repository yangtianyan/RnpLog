//
//  RnpReplaceHostController.m
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import "RnpReplaceHostController.h"
/* -- View -- */
#import "RnpReplaceHostCell.h"
/* -- Util -- */
#import "RnpDefine.h"
#import "RnpReplaceHostManager.h"
#import "NSDictionary+log.h"
/* -- Model -- */
#import "RnpReplaceHostModel.h"
@interface RnpReplaceHostController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) UITextView * textView;

@property (nonatomic, copy)   NSArray * dataArr;

@end
@implementation RnpReplaceHostController

- (void)initNav{
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAct)];
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAct)];
    UIBarButtonItem * switchItem = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(switchAct)];

    self.navigationItem.rightBarButtonItems =@[saveItem,addItem,switchItem] ;
}

- (void)initUI{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self resetDataArrWithDictionary:RnpReplaceHostManager.instance.host_dict];
    self.view.rnp
    .backgroundColor(UIColor.whiteColor)
    .addSubView(self.tableView)
    .addSubView(self.textView)
    ;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)resetDataArrWithDictionary:(NSDictionary *)dictionary{
    NSMutableArray * mutable = [NSMutableArray new];
    for (NSString * key in dictionary) {
        RnpReplaceHostModel * model = [RnpReplaceHostModel new];
        model.original_host = key;
        model.replace_host = dictionary[key];
        [mutable addObject:model];
    }
    if (mutable.count == 0) {
        [mutable addObject:[RnpReplaceHostModel new]];
    }
    self.dataArr = mutable.copy;
}
#pragma mark -- Action
- (void)saveAct{
    NSMutableDictionary * dictionary = [NSMutableDictionary new];
    for (RnpReplaceHostModel * model in self.dataArr) {
        if (model.original_host.length >0 && model.replace_host.length > 0) {
            [dictionary setValue:model.replace_host forKey:model.original_host];
        }
    }
    [RnpReplaceHostManager.instance replaceHostDict:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addAct{
    NSMutableArray * mutable = self.dataArr.mutableCopy;
    [mutable addObject:[RnpReplaceHostModel new]];
    self.dataArr = mutable.copy;
    [self.tableView reloadData];
}
- (void)switchAct{
    if (self.tableView.isHidden) {

        NSData *jsonData = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if (err) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"请设置正确的数据信息" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];

            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            self.tableView.hidden = false;
            self.textView.hidden = true;
            [self resetDataArrWithDictionary:dic];
            [self.tableView reloadData];
        }

      }else{
        self.textView.hidden = false;
        self.tableView.hidden = true;
        NSMutableDictionary * dictionary = [NSMutableDictionary new];
        for (RnpReplaceHostModel * model in self.dataArr) {
            if (model.original_host.length >0 || model.replace_host.length > 0) {
                [dictionary setValue:model.replace_host forKey:model.original_host];
            }
        }
        self.textView.text = dictionary.toJson;
    }
}
#pragma mark -- lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = UITableViewNew().rnp
        .registerClass(RnpReplaceHostCell.class)
        .delegate(self)
        .dataSource(self)
        .tableFooterView([UIView new])
        .view;
    }
    return _tableView;
}
- (UITextView *)textView{
    if (!_textView) {
        _textView = UITextViewNew().rnp
        .hidden(YES)
        .view;
    }
    return _textView;
}
#pragma mark -- UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RnpReplaceHostCell * cell = tableView.rnp.dequeueReusableCellWithClass(RnpReplaceHostCell.class);
    cell.hostModel = self.dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"确认删除?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray * mutable = self.dataArr.mutableCopy;
        [mutable removeObjectAtIndex:indexPath.row];
        weakSelf.dataArr = mutable.copy;
        [weakSelf.tableView reloadData];
        [tableView reloadData];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNav];
    [self initUI];
}
@end
