//
//  RnpBreakpointManager.h
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RnpBreakpointModel;
@interface RnpBreakpointManager : NSObject

@property (nonatomic, strong, class) RnpBreakpointManager * instance;

/** 全部断点列表 */
@property (nonatomic, copy, readonly) NSArray<RnpBreakpointModel *> * all_breakpoint_list;

/** 所有激活的断点字典 */
@property (nonatomic, copy, readonly) NSDictionary<NSString *, RnpBreakpointModel *> * activate_breakpoint_dict;

// 添加断点
- (void)addBreakpointWithModel:(RnpBreakpointModel *)model;

// 设置是否开启断点
- (void)setActivate:(BOOL)isActivate model:(RnpBreakpointModel *)model;

// 删除断点
- (void)deleteBreakpoint:(RnpBreakpointModel *)model;

// 获取断点model
- (RnpBreakpointModel *)getModelForUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
