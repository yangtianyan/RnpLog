//
//  WKWebView+hookAjax.m
//  RnpLog
//
//  Created by user on 2021/5/26.
//

#import "WKWebView+hookAjax.h"
#import "RnpDefine.h"
@implementation WKWebView (hookAjax)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RnpMethodSwizzle(self.class, @selector(loadRequest:), @selector(rnp_loadRequest:));
    });
}

- (WKNavigation *)rnp_loadRequest:(NSURLRequest *)request{
    NSString * string = [[NSBundle mainBundle] pathForResource:@"imywk_hookajax" ofType:@"js"];
    WKUserScript * script = [[WKUserScript alloc] initWithSource:string injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [self.configuration.userContentController addUserScript:script];
    
    
    WKNavigation * navigation = [self rnp_loadRequest:request];
    return navigation;
}

@end
