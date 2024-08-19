//
//  WKUserContentController+hookAjax.m
//  RnpLog
//
//  Created by user on 2021/5/27.
//

#import "WKUserContentController+hookAjax.h"
#import "RnpDefine.h"
#import "RnpHookAjaxHandler.h"
static BOOL isSwizzle = false;
static NSPointerArray * controllers;
static NSMapTable<WKUserContentController *, WKUserScript *> * userScriptMap;
@interface WKUserContentController ()

@property (nonatomic, strong, class) NSPointerArray * controllers;

@property (nonatomic, strong, class) NSMapTable<WKUserContentController *, WKUserScript *> * userScriptMap;


@end
@implementation WKUserContentController (hookAjax)

+ (void)swizzle{
    RnpMethodSwizzle(self.class, @selector(init), @selector(rnp_init));
    RnpMethodSwizzle(self.class, @selector(removeAllUserScripts), @selector(rnp_removeAllUserScripts));
}

+ (void)open{
    if (isSwizzle) {
        return;
    }
    isSwizzle = true;
    [self swizzle];
}

+ (void)close{
    if (!isSwizzle) {
        return;
    }
    isSwizzle = false;
    [self swizzle];
    [[WKUserContentController.controllers allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:WKUserContentController.class]) {
            [(WKUserContentController *)obj removeScriptMessageHandlerForName:@"IMYXHR"];
            SEL sel = NSSelectorFromString(@"_removeUserScript:");
            id userScript = [WKUserContentController.userScriptMap objectForKey:obj];
            if ([(id)obj respondsToSelector:sel] && userScript) {
                [obj performSelector:sel withObject:userScript];
            }
        }
    }];
}

+ (NSPointerArray *)controllers{
    if (!controllers) {
        controllers = [NSPointerArray weakObjectsPointerArray];
    }
    return controllers;
}

+ (NSMapTable<WKUserContentController *, WKUserScript *> *)userScriptMap
{
    if (!userScriptMap) {
        userScriptMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    return userScriptMap;
}

- (instancetype)rnp_init
{
    WKUserContentController *obj = [self rnp_init];
//    [obj removeScriptMessageHandlerForName:@"IMYXHR"];
//    [obj addScriptMessageHandler:[RnpHookAjaxHandler new] name:@"IMYXHR"];
//    NSURL * url = [[NSBundle mainBundle] URLForResource:@"RnpLog" withExtension:@"bundle"];
//    NSBundle * bundle = [NSBundle bundleWithURL:url];
//    NSString * path = [bundle pathForResource:@"ajaxhook" ofType:@"js" inDirectory:@"JS"];
//    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    WKUserScript * script = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
//    [obj addUserScript:script];
//    [WKUserContentController.controllers addPointer:(__bridge  void * _Nullable)obj];
//    [WKUserContentController.userScriptMap setObject:script forKey:self];
    [self addScript];
    return obj;
}
- (void)rnp_removeAllUserScripts{
    [self rnp_removeAllUserScripts];
    [self addScript];
}

- (void)addScript{
    WKUserScript * script = [WKUserContentController.userScriptMap objectForKey:self];
    if(!script){
        NSURL * url = [[NSBundle bundleForClass:[self class]] URLForResource:@"RnpLog" withExtension:@"bundle"];
        NSBundle * bundle = [NSBundle bundleWithURL:url];
        NSString * path = [bundle pathForResource:@"ajaxhook" ofType:@"js" inDirectory:@"JS"];
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        script = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    }
    [self removeScriptMessageHandlerForName:@"IMYXHR"];
    [self addScriptMessageHandler:[RnpHookAjaxHandler new] name:@"IMYXHR"];
    [self addUserScript:script];
    [WKUserContentController.controllers addPointer:(__bridge  void * _Nullable)self];
    [WKUserContentController.userScriptMap setObject:script forKey:self];
}

- (void)getMethod {
    unsigned int count;
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
    }
    free(methods);
}

@end
