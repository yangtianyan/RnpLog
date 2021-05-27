//
//  WKWebView+hookAjax.m
//  RnpLog
//
//  Created by user on 2021/5/26.
//

#import "WKWebView+hookAjax.h"
#import "RnpDefine.h"
#import "RnpHookAjaxHandler.h"
@implementation WKWebView (hookAjax)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        RnpMethodSwizzle(self.class, @selector(loadRequest:), @selector(rnp_loadRequest:));
    });
}

- (WKNavigation *)rnp_loadRequest:(NSURLRequest *)request{
    if ([request.HTTPMethod isEqualToString:@"POST"]) {
        [self.configuration.userContentController removeScriptMessageHandlerForName:@"IMYXHR"];
        [self.configuration.userContentController addScriptMessageHandler:[RnpHookAjaxHandler new] name:@"IMYXHR"];
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"RnpLog" withExtension:@"bundle"];
        NSBundle * bundle = [NSBundle bundleWithURL:url];
        NSString * path = [bundle pathForResource:@"ajaxhook" ofType:@"js"];
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        WKUserScript * script = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
        [self.configuration.userContentController addUserScript:script];
    }
    WKNavigation * navigation = [self rnp_loadRequest:request];
    return navigation;
}

@end
