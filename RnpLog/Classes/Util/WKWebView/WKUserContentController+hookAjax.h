//
//  WKUserContentController+hookAjax.h
//  RnpLog
//
//  Created by user on 2021/5/27.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKUserContentController (hookAjax)

+ (void)open;

+ (void)close;

// 添加fetch钩子方法
- (void)hookFetch;

@end

NS_ASSUME_NONNULL_END
