//
//  RnpBreakpointModel.h
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpBreakpointModel : NSObject

@property (nonatomic, copy) NSString * url; // 断点的url

@property (nonatomic, assign) BOOL isActivate; // 断点是否激活

@property (nonatomic, copy) NSData * mockResultData;// 模拟的数据

@end

NS_ASSUME_NONNULL_END
