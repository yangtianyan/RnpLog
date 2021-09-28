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
@interface RnpMarkerURLProtocol()<NSURLSessionDelegate>
@property(nonatomic,strong)NSURLSession * session;
@end
@implementation RnpMarkerURLProtocol

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL isShow = [[NSUserDefaults standardUserDefaults] boolForKey:@"rnplog_show"];
        if (!isShow) {
            return;
        }
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
    cookies = [cookieJar cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    NSLog(@"request: %@\nCookie: %@",mutableRequest,cookieValue);
//    [mutableRequest addValue:cookieValue forHTTPHeaderField:@"Cookie"];
//
//
//
   NSDictionary * dict =  @{
//      @"Accept": @"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
//      @"Accept-Encoding": @"gzip, deflate, br",
//      @"Accept-Language": @"zh-cn",
//      @"Connection": @"keep-alive",
//      @"Cookie": @"ThinkingDataJSSDK_cross=%7B%22distinct_id%22%3A%2222E11EF6-6FC9-4B84-9503-FA90E43BABD8%22%2C%22device_id%22%3A%22179eb696bebb4b-0e2b715fdcd80c-67106c67-304500-179eb696becbe5%22%2C%22account_id%22%3A%2287101252%22%7D; appuuid=22E11EF6-6FC9-4B84-9503-FA90E43BABD8; usergrade=1b; bad_idee646b30-5f58-11e9-9552-192311c61dcb=41333fa1-c779-11eb-be01-ffdbb935e7d9; accessId=ee646b30-5f58-11e9-9552-192311c61dcb; pageViewNum=7; sessionid=bc13uerdo3ph92fd4mfgi4rfwnv3231e; sessionid=bc13uerdo3ph92fd4mfgi4rfwnv3231e; deviceid=22E11EF6-6FC9-4B84-9503-FA90E43BABD8; deviceid=22E11EF6-6FC9-4B84-9503-FA90E43BABD8",
//     @"Deviceid": @"22E11EF6-6FC9-4B84-9503-FA90E43BABD8",
//      @"User-Agent": @"Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 iPhoneX NBDIYI/iOS/8.3.4/AppStore"
//      @"User-Agent" : @"Mozilla/5.0 (iPhone; CPU iPhone OS 12_4_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 iPhone6 NBDIYI/iOS/8.3.4/AppStore",
//      @"Cookie" : @"sessionid=d3g2p8wph9cykl6xku1o8kiw0utfwjb8;usergrade=1b;ThinkingDataJSSDK_cross=%7B%22distinct_id%22%3A%2222E11EF6-6FC9-4B84-9503-FA90E43BABD8%22%2C%22device_id%22%3A%22179eb7d34e2295-098302b2b72b59-5794e4c-250125-179eb7d34e43f0%22%2C%22account_id%22%3A%2287101252%22%7D;deviceid=01A3BC59-19AE-4929-9DC0-B3466163B4B2;appuuid=01A3BC59-19AE-4929-9DC0-B3466163B4B2;",
      @"Cookie":@"ThinkingDataJSSDK_cross=%7B%22distinct_id%22%3A%2217ac1ee1c9fd2f-0604ffe60418-450e7f57-304500-17ac1ee1ca0a67%22%2C%22device_id%22%3A%2217ac1f59382b45-0a1da227b5b0768-450e7f57-304500-17ac1f59383bea%22%2C%22account_id%22%3A%2287101252%22%7D; bookcase_books=tape1a_000002,tape1a_002001,; usergrade=1a; deviceid=BE11D31D-B62B-45FF-8CAE-033BF8AC450E; sessionid=koxlv6u5wg57dx8jccm8f16z5essi1ql;",
      //deviceid=BE11D31D-B62B-45FF-8CAE-033BF8AC450E; sessionid=koxlv6u5wg57dx8jccm8f16z5essi1ql
//      @"Cookie": @"sessionid=koxlv6u5wg57dx8jccm8f16z5essi1ql;XSRF-TOKEN=7539a54d-a778-4604-bc7c-b4cc185df370;deviceid=01A3BC59-19AE-4929-9DC0-B3466163B4B2;usergrade=1a;bookcase_books=tape1a_000002,tape1a_002001,;appuuid=01A3BC59-19AE-4929-9DC0-B3466163B4B2;ThinkingDataJSSDK_cross=%7B%22distinct_id%22%3A%2201A3BC59-19AE-4929-9DC0-B3466163B4B2%22%2C%22device_id%22%3A%2217ac1ee1a18273-08d9c2d027bf46-955714f-250125-17ac1ee1a19109%22%2C%22account_id%22%3A%2287101453%22%7D;",
      @"Deviceid" : @"BE11D31D-B62B-45FF-8CAE-033BF8AC450E",
//     @"Host": @"wweb.namibox.com",
//     @"Referer": @"https://dev.namibox.com/dy/tab_recommend",
   };
    for (NSString * key in dict.allKeys) {
        [mutableRequest addValue:dict[key] forHTTPHeaderField:key];
    }
    
    
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
    [self.client URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    [task cancel];
    NSError * error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
    [self.client URLProtocol:self didFailWithError:error];
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

/// 开始监听
+ (void)startMonitor {
    RnpSessionConfiguration *sessionConfiguration = [RnpSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[RnpMarkerURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
    }
    // 暂时拦截 wkwebview中post请求 body会丢失
    //https://xiaoye220.github.io/NSProtocol-%E6%8B%A6%E6%88%AA-WKWebView/
//    //实现WKWebview拦截功能
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([(id)cls respondsToSelector:sel]) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:sel withObject:@"http"];
        [cls performSelector:sel withObject:@"https"];
    #pragma clang diagnostic pop
    }
}

/// 停止监听
+ (void)stopMonitor {
    RnpSessionConfiguration *sessionConfiguration = [RnpSessionConfiguration defaultConfiguration];
    [NSURLProtocol unregisterClass:[RnpMarkerURLProtocol class]];
    if ([sessionConfiguration isSwizzle]) {
        [sessionConfiguration unload];
    }
}
@end
