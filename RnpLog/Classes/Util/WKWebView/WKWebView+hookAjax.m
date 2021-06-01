//
//  WKWebView+hookAjax.m
//  RnpLog
//
//  Created by user on 2021/5/26.
//

#import "WKWebView+hookAjax.h"
#import "RnpDefine.h"
#import "RnpHookAjaxHandler.h"
typedef void (^Block)(WKNavigationResponsePolicy) ;
@implementation WKWebView (hookAjax)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        RnpMethodSwizzle(self.class, @selector(init), @selector(rnp_init));
//        RnpMethodSwizzle(self.class, @selector(setNavigationDelegate:), @selector(rnp_setNavigationDelegate:));
    });
}
- (instancetype)rnp_init{
    WKWebView * webView = [self rnp_init];
    webView.navigationDelegate = self;
    return webView;
}

//- (WKNavigation *)rnp_loadRequest:(NSURLRequest *)request{
//
//    WKNavigation * navigation = [self rnp_loadRequest:request];
//    return navigation;
//}
- (BOOL)isContainSel:(SEL)sel inClass:(Class)class {
    unsigned int count;
    Method *methodList = class_copyMethodList(class,&count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *tempMethodString = [NSString stringWithUTF8String:sel_getName(method_getName(method))];
        if ([tempMethodString isEqualToString:NSStringFromSelector(sel)]) {
            return YES;
        }
    }
    return NO;
}

- (void)rnp_setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate
{
    [self rnp_setNavigationDelegate:navigationDelegate];
//    if ([navigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
//
//    }
    if ([self isContainSel:NSSelectorFromString(@"") inClass:[navigationDelegate class]]) {
        
    }
    NSString * exMString = @"rnp_webView:decidePolicyForNavigationResponse:decisionHandler:";
    SEL sel = @selector(webView:decidePolicyForNavigationResponse:decisionHandler:);
    SEL curSel = NSSelectorFromString(exMString);
    Method originalMethod = class_getInstanceMethod([navigationDelegate class], sel);
    Method swizzledMethod = class_getInstanceMethod([navigationDelegate class], curSel);

    class_addMethod([navigationDelegate class], NSSelectorFromString(exMString), (IMP)rnp_add_decidePolicyForNavigationResponse, method_getTypeEncoding(originalMethod));
    Method exM = class_getInstanceMethod([navigationDelegate class], NSSelectorFromString(exMString));
    BOOL didAddMethod = class_addMethod([navigationDelegate class],
                                        sel,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod([navigationDelegate class],
                            curSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void rnp_add_decidePolicyForNavigationResponse(id obj, void * sel, WKWebView *webView, WKNavigationResponse *navigationResponse, Block decisionHandler)
{
    // 开启了拦截
    
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)navigationResponse.response;
        NSInteger statusCode = httpResp.statusCode;
        NSString *redirectUrl = [httpResp.allHeaderFields valueForKey:@"Location"];
        if (statusCode >= 300 && statusCode < 400 && redirectUrl) {
            decisionHandler(WKNavigationActionPolicyCancel);
            // 不支持307、308post跳转情景
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:redirectUrl]]];
            return;
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
//    NSString * exMString = @"rnp_webView:decidePolicyForNavigationResponse:decisionHandler:";
    
}

@end

