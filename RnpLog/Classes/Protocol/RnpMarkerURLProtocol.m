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
/* -- Model -- */
#import "RnpDataModel.h"
#import "RnpBreakpointModel.h"
#import <WebKit/WebKit.h>
@interface RnpMarkerURLProtocol()<NSURLSessionDelegate>
@property(nonatomic,strong)NSURLSession * session;
@end
@implementation RnpMarkerURLProtocol

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
    NSLog(@"************ 开始请求 %@",mutableRequest.URL);
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];//创建一个临时会话配置
//    mutableRequest.URL.absoluteString;
    mutableRequest.URL = [NSURL URLWithString:@"https://www.baidu.com"]; // yty fix 可以篡改请求接口
    //网络请求
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 注 这里也可以添加代理 捕获用户请求数据
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:mutableRequest];
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
        if (breakpoint) {
            model.hookData = breakpoint.mockResultData;
            [self.client URLProtocol:self didLoadData:model.hookData];
        }
//        [self delayDidLoadData:task];
        [self.client URLProtocolDidFinishLoading:self];
    }
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
    if (![RnpBreakpointManager.instance getModelForUrl:dataTask.originalRequest.URL.absoluteString]) {
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
    //实现WKWebview拦截功能
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
