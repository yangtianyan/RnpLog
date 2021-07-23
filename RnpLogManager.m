//
//  RnpLogManager.m
//  RnpLog-RnpLog
//
//  Created by user on 2021/6/7.
//

#import "RnpLogManager.h"
#import "WKUserContentController+hookAjax.h"
@implementation RnpLogManager
+ (void)openWebViewCaught{
    //实现WKWebview拦截功能
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:sel withObject:@"http"];
        [cls performSelector:sel withObject:@"https"];
    #pragma clang diagnostic pop
        [WKUserContentController open];
    }
}
@end
