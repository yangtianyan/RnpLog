//
//  RnpMarkerURLProtocol.h
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
static NSString * const hasInitKey = @"RnpMarkerProtocolKey";

@interface RnpMarkerURLProtocol : NSURLProtocol

/// 是否在监听
@property (nonatomic, assign, class) BOOL isMonitor;

+ (void)startMonitor ;

/// 停止监听
+ (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
