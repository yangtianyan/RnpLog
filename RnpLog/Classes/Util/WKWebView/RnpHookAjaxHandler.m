//
//  RnpHookAjaxHandler.m
//  RnpLog
//
//  Created by user on 2021/5/26.
//

#import "RnpHookAjaxHandler.h"
#import "RnpCaptureDataManager.h"
/* -- Model -- */
#import "RnpDataModel.h"
@interface RnpHookAjaxHandler ()

@property (nonatomic, weak) WKWebView * webView;

@end
@implementation RnpHookAjaxHandler

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
        // hook ajax后拿到的url可能不完整 需要手动拼接
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
    [request setAllHTTPHeaderFields:requestHeaders];
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
        }
    }];
    [task resume];
//    NSLog(@"");
}

- (void)requestCallback:(id)requestId httpCode:(NSInteger)httpCode headers:(NSDictionary *)headers data:(NSString *)data
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"status"] = @(httpCode);
    dict[@"headers"] = headers;
    if (data.length > 0) {
        dict[@"data"] = data;
    }
    NSString *jsonString = nil;
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    if (jsonData.length > 0) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *jsScript = [NSString stringWithFormat:@"window.imy_realxhr_callback('%@', %@);", requestId, jsonString?:@"{}"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:jsScript completionHandler:^(id result, NSError *error) {
            
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
