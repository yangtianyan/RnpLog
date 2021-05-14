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
/* -- Model -- */
#import "RnpDataModel.h"
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
    return YES;
}
//自定义网络请求，如果不需要处理直接返回request。
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{
    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    [NSURLProtocol setProperty:@YES
                        forKey:hasInitKey
                     inRequest:mutableReqeust];
    return [mutableReqeust copy];
}


//开始请求
- (void)startLoading
{
    //业务逻辑写这里
    NSMutableURLRequest * mutableRequest = [[self request] mutableCopy];
    NSLog(@"************ 开始请求 %@",mutableRequest.URL);
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];//创建一个临时会话配置
    //网络请求
    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    // 注 这里也可以添加代理 捕获用户请求数据
    NSURLSessionDataTask * task = [self.session dataTaskWithRequest:self.request];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [task  resume];//开始任务
    });
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
        [self.client URLProtocolDidFinishLoading:self];
    }
}

/// 这个地方可以延迟执行
/// 抓包
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//    });
//
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    RnpDataModel * model = RnpCaptureDataManager.instance.requests_dict[dataTask];
    model.originalData = data;
//    NSLog(@"currentRequest: %@  %@", dataTask.currentRequest, dataTask.response);
    // 可以做消息拦截
    [self.client URLProtocol:self didLoadData:data];
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSLog(@"");
}

/// 开始监听
+ (void)startMonitor {
    RnpSessionConfiguration *sessionConfiguration = [RnpSessionConfiguration defaultConfiguration];
    [NSURLProtocol registerClass:[RnpMarkerURLProtocol class]];
    if (![sessionConfiguration isSwizzle]) {
        [sessionConfiguration load];
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
