//
//  RnpMarkerURLProtocol.m
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import "RnpMarkerURLProtocol.h"
#import "RnpSessionConfiguration.h"
/* -- Manager -- */
#import "RnpCaptureDataManager.h"
#import "RnpBreakpointManager.h"
#import "RnpHostManager.h"
/* -- Model -- */
#import "RnpDataModel.h"
#import "RnpBreakpointModel.h"
#import <WebKit/WebKit.h>
/* -- Controller -- */
#import "DYBreakpointRequestController.h"
#import "DYBreakpointResponseController.h"
#import <objc/runtime.h>

static BOOL isMonitor = false;

@interface RnpMarkerURLProtocol()<NSURLSessionDelegate>
@property(nonatomic,strong)NSURLSession * session;
@end
@implementation RnpMarkerURLProtocol

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifndef LogForceShow
        BOOL isShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"rnplog_show"];
        if (!isShow) {
            return;
        }
#endif
        [RnpMarkerURLProtocol startMonitor];
    });
}

+ (NSURLSessionConfiguration *) defaultSessionConfiguration{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableArray *array = [[config protocolClasses] mutableCopy];
    [array insertObject:[self class] atIndex:0];
    config.protocolClasses = array;
    return config;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    // 不是网络请求，不处理
    if (![request.URL.scheme isEqualToString:@"http"] &&
        ![request.URL.scheme isEqualToString:@"https"]) {
        return NO;
    }
    if (![RnpHostManager.instance checkWhiteList:request]) {
        return NO;
    }
    if ([NSURLProtocol propertyForKey: hasInitKey inRequest:request] ) {
        return NO;
    }
    NSString * content_type = [request valueForHTTPHeaderField:@"Content-Type"];
    if (content_type && [content_type containsString:@"multipart/form-data"]) {
        return NO;
    }
    return YES;
}
//自定义网络请求，如果不需要处理直接返回request。
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    return mutableReqeust;
}
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return true;
}

//开始请求
- (void)startLoading
{
    //业务逻辑写这里
    NSMutableURLRequest * mutableRequest = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:hasInitKey
                     inRequest:mutableRequest];
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies = [cookieJar cookiesForURL:mutableRequest.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    NSLog(@"request: %@\nCookie: %@",mutableRequest,cookieValue);
    [mutableRequest addValue:cookieValue forHTTPHeaderField:@"Cookie"];
//    [mutableRequest addValue:@"pingtas.qq.com" forHTTPHeaderField:@"Host"];

    NSLog(@"************ 开始请求 %@",mutableRequest.URL);
//    mutableRequest.URL = [NSURL URLWithString:@"https://www.baidu.com"]; // yty fix 可以篡改请求接口
    mutableRequest = [RnpHostManager.instance checkAndReplaceHost:mutableRequest];
    RnpBreakpointModel * breakpoint = [RnpBreakpointManager.instance getModelForUrl:mutableRequest.URL.absoluteString];
    if (breakpoint.isActivate && breakpoint.isBefore) {
        __weak typeof(self) weakSelf = self;
        [DYBreakpointRequestController showWithRequest:mutableRequest completion:^{
            [weakSelf startFetchWithRequest:mutableRequest];
        }];
    }else{
        [self startFetchWithRequest:mutableRequest];
    }
}

- (void)startFetchWithRequest:(NSURLRequest *)request{
    //网络请求
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];//创建一个临时会话配置
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 注 这里也可以添加代理 捕获用户请求数据
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:request];
    [task  resume];//开始任务
    [RnpCaptureDataManager.instance addRequest:task];
}

//停止请求
- (void)stopLoading
{
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark ---- NSURLSessionDelegate
/*
   NSURLSessionDelegate接到数据后,通过URLProtocol传出去
*/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //在这写入数据
    if (error){
        [self.client URLProtocol:self didFailWithError:error];
    }else{
        RnpBreakpointModel * breakpoint = [RnpBreakpointManager.instance getModelForUrl:task.originalRequest.URL.absoluteString];
        RnpDataModel * model = RnpCaptureDataManager.instance.requests_dict[task];
        if (breakpoint.isActivate && breakpoint.isAfter) {
            __weak typeof(self) weakSelf = self;
            [DYBreakpointResponseController showWithDataModel:model completion:^{
                [weakSelf finishFetchWithDataModel:model ];
            }];
        }else{
            if (breakpoint && breakpoint.mockResultData) {
                model.hookData = breakpoint.mockResultData;
                [self.client URLProtocol:self didLoadData:model.hookData ?: model.originalData];
            }
            [self.client URLProtocolDidFinishLoading:self];
        }
    }
}

- (void)finishFetchWithDataModel:(RnpDataModel *)model{
    [self.client URLProtocol:self didLoadData:model.hookData ?: model.originalData];
    [self.client URLProtocolDidFinishLoading:self];
}


/*
    Webview中请求可能会重定向会造成html中依赖的资源文件读取不到(js,图片等),需要此方法
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
                     willPerformHTTPRedirection:(NSHTTPURLResponse *)response
                                     newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
//    [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
//    NSError * error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
//    [self.client URLProtocol:self didFailWithError:error];
    RnpDataModel * model = RnpCaptureDataManager.instance.requests_dict[task];
    model.redirectedUrl = [NSString stringWithFormat:@"%@",request.URL];
    completionHandler(request);
}
///在认证的代理方法中强制信任证书
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}
/// 这个地方可以延迟执行
/// 抓包
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSString * set_cookie = [(NSHTTPURLResponse *)response allHeaderFields][@"Set-Cookie"];
        if (set_cookie) {
            NSArray * cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[(NSHTTPURLResponse *)response allHeaderFields] forURL:response.URL];
            for (NSHTTPCookie * cookie in cookies) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }
        }
    }
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    RnpDataModel * model = RnpCaptureDataManager.instance.requests_dict[dataTask];
    NSMutableData * newData = [data mutableCopy];
    if (model.originalData) {
        newData = [[NSMutableData alloc] initWithData:model.originalData];
        [newData appendData:data];
    }
    model.originalData = newData;
    RnpBreakpointModel * breakpoint = [RnpBreakpointManager.instance getModelForUrl:dataTask.originalRequest.URL.absoluteString];
    if (!breakpoint) {
        [self.client URLProtocol:self didLoadData:data];
    }
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"");
}

- (void)delayDidLoadData:(NSURLSessionTask *)dataTask{
    RnpDataModel * model = RnpCaptureDataManager.instance.requests_dict[dataTask];
    [self.client URLProtocol:self didLoadData:model.originalData];
}

+ (BOOL)isMonitor{
    return isMonitor;
}

/// 开始监听
+ (void)startMonitor {
    isMonitor = true;
     RnpSessionConfiguration *sessionConfiguration = [RnpSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[RnpMarkerURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
    // 暂时拦截 wkwebview中post请求 body会丢失
    //https://xiaoye220.github.io/NSProtocol-%E6%8B%A6%E6%88%AA-WKWebView/
//    //实现WKWebview拦截功能
//    Class cls = NSClassFromString(@"WKBrowsingContextController");
//    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
//    if ([(id)cls respondsToSelector:sel]) {
//    #pragma clang diagnostic push
//    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [cls performSelector:sel withObject:@"http"];
//        [cls performSelector:sel withObject:@"https"];
//    #pragma clang diagnostic pop
//    }
}

/// 停止监听
+ (void)stopMonitor {
    isMonitor = false;
    RnpSessionConfiguration *sessionConfiguration = [RnpSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[RnpMarkerURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
//    ///卸载webview抓包
//    Class cls = NSClassFromString(@"WKBrowsingContextController");
//    SEL sel = NSSelectorFromString(@"unregisterSchemeForCustomProtocol:");
//    if ([(id)cls respondsToSelector:sel]) {
//    #pragma clang diagnostic push
//    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [cls performSelector:sel withObject:@"http"];
//        [cls performSelector:sel withObject:@"https"];
//    #pragma clang diagnostic pop
//    }
//    [WKUserContentController close];

}
@end
