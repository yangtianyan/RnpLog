//
//  WKUserContentController+hookAjax.m
//  RnpLog
//
//  Created by user on 2021/5/27.
//

#import "WKUserContentController+hookAjax.h"
#import "RnpDefine.h"
#import "RnpHookAjaxHandler.h"
#import "RnpHookFetchHandler.h"
#import "RnpResourceLoader.h"
static BOOL isSwizzle = false;
static NSPointerArray * controllers;
static NSMapTable<WKUserContentController *, WKUserScript *> * userScriptMap;
// 添加fetch相关的静态变量
static NSPointerArray * fetchControllers;
static NSMapTable<WKUserContentController *, WKUserScript *> * fetchScriptMap;

@interface WKUserContentController ()

@property (nonatomic, strong, class) NSPointerArray * controllers;

@property (nonatomic, strong, class) NSMapTable<WKUserContentController *, WKUserScript *> * userScriptMap;

// 添加fetch相关的属性
@property (nonatomic, strong, class) NSPointerArray * fetchControllers;

@property (nonatomic, strong, class) NSMapTable<WKUserContentController *, WKUserScript *> * fetchScriptMap;

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
    
    // 关闭fetch钩子
    [[WKUserContentController.fetchControllers allObjects] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:WKUserContentController.class]) {
            [(WKUserContentController *)obj removeScriptMessageHandlerForName:@"IMYFETCH"];
            SEL sel = NSSelectorFromString(@"_removeUserScript:");
            id userScript = [WKUserContentController.fetchScriptMap objectForKey:obj];
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

// 添加fetch相关的getter方法
+ (NSPointerArray *)fetchControllers{
    if (!fetchControllers) {
        fetchControllers = [NSPointerArray weakObjectsPointerArray];
    }
    return fetchControllers;
}

+ (NSMapTable<WKUserContentController *, WKUserScript *> *)fetchScriptMap
{
    if (!fetchScriptMap) {
        fetchScriptMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    return fetchScriptMap;
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
    [self hookFetch];
    return obj;
}
- (void)rnp_removeAllUserScripts{
    [self rnp_removeAllUserScripts];
    [self addScript];
    [self hookFetch];
}

- (void)addScript{
    WKUserScript * script = [WKUserContentController.userScriptMap objectForKey:self];
    if(!script){
        NSURL * url = [[RnpResourceLoader currentBundle] URLForResource:@"RnpLog" withExtension:@"bundle"];
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

// 添加fetch钩子方法
- (void)hookFetch {
    [self addFetchScript];
}

// 添加fetch脚本的方法
- (void)addFetchScript {
    WKUserScript *script = [WKUserContentController.fetchScriptMap objectForKey:self];
    if (!script) {
        NSURL *url = [[RnpResourceLoader currentBundle] URLForResource:@"RnpLog" withExtension:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithURL:url];
        NSString *path = [bundle pathForResource:@"fetchhook" ofType:@"js" inDirectory:@"JS"];
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        script = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:true];
    }
    [self removeScriptMessageHandlerForName:@"IMYFETCH"];
    [self addScriptMessageHandler:[RnpHookFetchHandler new] name:@"IMYFETCH"];
    [self addUserScript:script];
    [WKUserContentController.fetchControllers addPointer:(__bridge void * _Nullable)self];
    [WKUserContentController.fetchScriptMap setObject:script forKey:self];
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
