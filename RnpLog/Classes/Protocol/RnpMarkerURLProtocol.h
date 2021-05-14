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

+ (void)startMonitor ;

/// 停止监听
+ (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
