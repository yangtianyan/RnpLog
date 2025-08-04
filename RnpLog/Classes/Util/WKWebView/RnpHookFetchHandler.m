//
//  RnpHookFetchHandler.m
//  RnpLog
//
//  Created by user on 2023/5/26.
//

#import "RnpHookFetchHandler.h"
#import "RnpCaptureDataManager.h"
/* -- Model -- */
#import "RnpDataModel.h"

@interface RnpHookFetchHandler ()

@property (nonatomic, weak) WKWebView * webView;

@end

@implementation RnpHookFetchHandler

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    self.webView = message.webView;

    id body = message.body;
    id requestID = body[@"id"];
    NSString *method = body[@"method"];
    id requestData = body[@"data"];
    NSDictionary *requestHeaders = body[@"headers"];
    
    NSMutableDictionary * mutable = [requestHeaders mutableCopy];
    NSString *urlString = body[@"url"];
    if (urlString.length == 0) {
        return;
    }
    requestHeaders = mutable;
    NSURL * url = [NSURL URLWithString:urlString];
    if (url.host == nil) {
        // hook fetch后拿到的url可能不完整 需要手动拼接
        __block NSString * scheme = self.webView.URL.scheme;
        __block NSString * host = self.webView.URL.host;
        NSString * webUrl = self.webView.URL.absoluteString;
        if (RnpCaptureDataManager.instance.redirecte_dict[webUrl]) {
            NSURL * redirectedUrl = [NSURL URLWithString:RnpCaptureDataManager.instance.redirecte_dict[webUrl]];
            scheme = redirectedUrl.scheme;
            host = redirectedUrl.host;
        }
        urlString = [NSString stringWithFormat:@"%@://%@%@",scheme,host,urlString];
        url = [NSURL URLWithString:urlString];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = method.uppercaseString;
    if ([requestData isKindOfClass:[NSString class]]) {
        request.HTTPBody = [requestData dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([requestData isKindOfClass:[NSData class]]) {
        request.HTTPBody = requestData;
    } else if ([NSJSONSerialization isValidJSONObject:requestData]) {
        NSError *err = nil;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&err];
    }
    
    /// 神奇的key、value可能存在number，强行转换一波
    NSMutableDictionary<NSString *, NSString *> *newRequestHeaders = [NSMutableDictionary new];
    [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        NSString * newKey = [NSString stringWithFormat:@"%@",key];
//        if ([[newKey capitalizedString] isEqualToString:@"Accept"]) {
//            newKey = @"Accept";
//            NSString * oldValue = newRequestHeaders[newKey];
//            if (oldValue) {
//                obj = [oldValue ];
//            }
//        }
        
//        [newRequestHeaders setValue:[NSString stringWithFormat:@"%@", obj] forKey:[NSString stringWithFormat:@"%@",key]];
        /// Accept与accept 在 setAllHTTPHeaderFields函数中认为是一个key
        [request setValue:[NSString stringWithFormat:@"%@", obj] forHTTPHeaderField:[NSString stringWithFormat:@"%@",key]];
    }];
    
//    [request setAllHTTPHeaderFields:newRequestHeaders];
    __weak typeof(self) weakSelf = self;
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];//创建一个临时会话配置
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDataTask * task =  [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpResponse = (id)response;
        }
        NSDictionary *allHeaderFields = httpResponse.allHeaderFields;
        NSString *responseString = nil;
        if (data.length > 0) {
            responseString = [weakSelf responseStringWithData:data charset:allHeaderFields[@"Content-Type"]];
            [weakSelf requestCallback:requestID httpCode:httpResponse.statusCode headers:allHeaderFields data:responseString];
        } else {
            // 处理没有响应数据的情况
            [weakSelf requestCallback:requestID httpCode:httpResponse.statusCode headers:allHeaderFields data:@""];
        }
    }];
    [task resume];
}

- (void)requestCallback:(id)requestId httpCode:(NSInteger)httpCode headers:(NSDictionary *)headers data:(NSString *)data
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"status"] = @(httpCode);
    dict[@"headers"] = headers ?: @{};
    if (data.length > 0) {
        dict[@"data"] = data;
    }
    NSString *jsonString = nil;
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    if (jsonData.length > 0) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else if (err) {
        NSLog(@"JSON序列化错误: %@", err);
        // 创建一个简单的错误响应
        jsonString = [NSString stringWithFormat:@"{\"status\":%ld,\"headers\":{},\"error\":\"JSON序列化错误\"}", (long)httpCode];
    }
    NSString *jsScript = [NSString stringWithFormat:@"window.imy_realfetch_callback('%@', %@);", requestId, jsonString?:@"{}"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:jsScript completionHandler:^(id result, NSError *error) {
            if (error) {
                NSLog(@"执行JavaScript回调错误: %@", error);
            }
        }];
    });
}

- (NSString *)responseStringWithData:(NSData *)data charset:(NSString *)charset
{
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    /// 对一些国内常见编码进行支持
    charset = charset.lowercaseString;
    if ([charset containsString:@"gb2312"]) {
        stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
    return responseString;
}

@end 
