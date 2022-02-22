//
//  WKUserContentController+hookAjax.m
//  RnpLog
//
//  Created by user on 2021/5/27.
//

#import "WKUserContentController+hookAjax.h"
#import "RnpDefine.h"
#import "RnpHookAjaxHandler.h"

@implementation WKUserContentController (hookAjax)
+ (void)load{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        RnpMethodSwizzle(self.class, @selector(init), @selector(rnp_init));
//        RnpMethodSwizzle(self.class, @selector(removeAllUserScripts), @selector(rnp_removeAllUserScripts));
//    });
}
+ (void)open{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RnpMethodSwizzle(self.class, @selector(init), @selector(rnp_init));
        RnpMethodSwizzle(self.class, @selector(removeAllUserScripts), @selector(rnp_removeAllUserScripts));
    });

}
- (instancetype)rnp_init
{
    WKUserContentController *obj = [self rnp_init];
    [obj removeScriptMessageHandlerForName:@"IMYXHR"];
    [obj addScriptMessageHandler:[RnpHookAjaxHandler new] name:@"IMYXHR"];
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"RnpLog" withExtension:@"bundle"];
    NSBundle * bundle = [NSBundle bundleWithURL:url];
    NSString * path = [bundle pathForResource:@"ajaxhook" ofType:@"js" inDirectory:@"JS"];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    WKUserScript * script = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    [obj addUserScript:script];
    return obj;
}
- (void)rnp_removeAllUserScripts{
    [self rnp_removeAllUserScripts];
}


@end
