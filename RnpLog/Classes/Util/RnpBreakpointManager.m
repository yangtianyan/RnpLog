//
//  RnpBreakpointManager.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "RnpBreakpointManager.h"
/* -- Model -- */
#import "RnpBreakpointModel.h"
@interface RnpBreakpointManager ()

@property (nonatomic, strong) NSMutableArray<RnpBreakpointModel *> * mutable_all_breakpoint;

@property (nonatomic, strong) NSMutableDictionary<NSString *,RnpBreakpointModel *> * mutable_breakpoint_dict;

@property (nonatomic, strong) NSMutableDictionary<NSString *,RnpBreakpointModel *> * mutable_activate_breakpoint_dict;

@end
@implementation RnpBreakpointManager

+ (instancetype)shareManager{
    static RnpBreakpointManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [RnpBreakpointManager new];
    });
    return manager;
}

+ (RnpBreakpointManager *)instance
{
    return [self shareManager];
}

+ (void)setInstance:(RnpBreakpointManager *)instance{}
#pragma mark -- lazy
- (NSMutableArray<RnpBreakpointModel *> *)mutable_all_breakpoint
{
    if (!_mutable_all_breakpoint) {
        _mutable_all_breakpoint = [NSMutableArray new];
    }
    return _mutable_all_breakpoint;
}
- (NSMutableDictionary<NSString *,RnpBreakpointModel *> *)mutable_breakpoint_dict
{
    if (!_mutable_breakpoint_dict) {
        _mutable_breakpoint_dict = [NSMutableDictionary new];
    }
    return _mutable_breakpoint_dict;
}
- (NSMutableDictionary<NSString *,RnpBreakpointModel *> *)mutable_activate_breakpoint_dict
{
    if (!_mutable_activate_breakpoint_dict) {
        _mutable_activate_breakpoint_dict = [NSMutableDictionary new];
    }
    return _mutable_activate_breakpoint_dict;
}

- (NSArray<RnpBreakpointModel *> *)all_breakpoint_list
{
    return self.mutable_all_breakpoint;
}
- (NSDictionary<NSString *,RnpBreakpointModel *> *)activate_breakpoint_dict
{
    return self.mutable_activate_breakpoint_dict;
}

#pragma mark -- Public
// 添加断点
- (void)addBreakpointWithModel:(RnpBreakpointModel *)model{
    if (!self.mutable_breakpoint_dict[model.url]) {
        self.mutable_breakpoint_dict[model.url] = model;
        [self.mutable_all_breakpoint addObject:model];
        self.mutable_activate_breakpoint_dict[model.url] = model;
    }
}

// 设置是否开启断点
- (void)setActivate:(BOOL)isActivate model:(RnpBreakpointModel *)model{
    model.isActivate = isActivate;
    if (isActivate) {
        self.mutable_activate_breakpoint_dict[model.url] = model;
    }else{
        [self.mutable_activate_breakpoint_dict removeObjectForKey:model.url];
    }
}

// 删除断点
- (void)deleteBreakpoint:(RnpBreakpointModel *)model{
    [self.mutable_activate_breakpoint_dict removeObjectForKey:model.url];
    [self.mutable_breakpoint_dict removeObjectForKey:model.url];
    [self.mutable_all_breakpoint removeObject:model];
}

- (RnpBreakpointModel *)getModelForUrl:(NSString *)url
{
    if (self.mutable_breakpoint_dict[url]) {
        return self.mutable_breakpoint_dict[url];
    }
    NSArray * allKeys = self.mutable_breakpoint_dict.allKeys;
    for (NSString * key in allKeys) {
        if ([url containsString:key]) {
            return self.mutable_breakpoint_dict[key];
        }
    }
    return nil;
}


@end
