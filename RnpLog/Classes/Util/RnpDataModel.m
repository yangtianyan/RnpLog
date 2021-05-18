//
//  RnpDataModel.m
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import "RnpDataModel.h"

@implementation RnpDataModel

- (void)setOriginalData:(NSData *)originalData{
    [self willChangeValueForKey:@"originalData"];
    _originalData = originalData;
    [self didChangeValueForKey:@"originalData"];

}


- (NSString *)rnpLogDataFormat
{
//    self.task.originalRequest.HTTPMethod
    NSString * p_url = [NSString stringWithFormat:@"%@",self.task.originalRequest.URL];
    NSString * p_method = self.task.originalRequest.HTTPMethod;
    NSString * p_header = @"{\n\n}";
    if (self.task.originalRequest.allHTTPHeaderFields.count > 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.task.originalRequest.allHTTPHeaderFields options:NSJSONWritingPrettyPrinted error:nil];
        p_header =  [NSString stringWithFormat:@"{\n%@\n}",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]];
    }
    NSString * p_body = @"{\n\n}";
    if (self.task.originalRequest.HTTPBody) {
        NSString * string = [[NSString alloc] initWithData:self.task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        p_body = [NSString stringWithFormat:@"{\n%@\n}",string];
    }else if (self.task.originalRequest.HTTPBodyStream){
        uint8_t d[1024] = {0};
        NSInputStream *stream = self.task.originalRequest.HTTPBodyStream;
        NSMutableData *data = [[NSMutableData alloc] init];
        [stream open];
        
        while ([stream hasBytesAvailable]) {
            NSInteger len = [stream read:d maxLength:1024];
            if (len > 0 && stream.streamError == nil) {
                [data appendBytes:(void *)d length:len];
            }
        }
        [stream close];
        NSString * string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        p_body = [NSString stringWithFormat:@"{\n%@\n}",string];
    }
    NSString * p_response = @"{\n\n}";
    if (self.originalData) {
        NSString * string = [[NSString alloc] initWithData:self.originalData encoding:NSUTF8StringEncoding];
        p_response = [NSString stringWithFormat:@"{\n%@\n}",string];
    }else if (self.task.error){
        p_response = [NSString stringWithFormat:@"{\n%@\n}",self.task.error.localizedDescription];
    }
    NSString * h_response = @"";
    if (self.hookData) {
        NSString * string = [[NSString alloc] initWithData:self.hookData encoding:NSUTF8StringEncoding];
        h_response = [NSString stringWithFormat:@"{\n%@\n}",string];
    }else if (self.task.error){
        h_response = [NSString stringWithFormat:@"{\n%@\n}",self.task.error.localizedDescription];
    }
    NSMutableString * netLog = [@"URL: " mutableCopy];
    [netLog appendString:p_url];
    [netLog appendString:@"\n\n"];
    [netLog appendString:@"Method: "];
    [netLog appendString:p_method];
    [netLog appendString:@"\n\n"];
    [netLog appendString:@"Headers: "];
    [netLog appendString:p_header];
    [netLog appendString:@"\n\n"];
    [netLog appendString:@"RequestBody: "];
    [netLog appendString:p_body];
    [netLog appendString:@"\n\n"];
    [netLog appendString:@"Response: "];
    [netLog appendString:p_response];
    if (h_response.length > 0) {
        [netLog appendString:@"\n\n"];
        [netLog appendString:@"HookResponse: "];
        [netLog appendString:h_response];
    }
    return netLog;
}

//@objc public static func dnpLogDataFormat(url: String?,method: String?,headers: Any?,body: Any?,response: Any?,error: NSError?) {
//        var p_url = ""
//        if let m_url = url{
//            p_url = m_url
//        }
//        var p_method = "{\n\n}"
//        if let m_method = method{
//            p_method = m_method
//        }
//        var p_headers = "{\n\n}"
//        if let m_headers = headers as? [String: Any]{
//            p_headers = String.jsonToString(dic: m_headers)
//        }else if let n_headers = headers{
//            p_headers = "{\n\(n_headers)\n}"
//        }
//        var p_body = "{\n\n}"
//        if let m_body = body as? [String: Any]{
//            p_body = String.jsonToString(dic: m_body)
//        }else if let n_body = body{
//            p_body = "{\n\(n_body)\n}"
//        }
//        var p_response = "{\n\n}"
//        if let e = error{
//            p_response = "{\n\(e)\n}"
//        }else if let m_response = response as? [String: Any]{
//            p_response = String.jsonToString(dic: m_response)
//            //m_response.customDescription(level: 0)
//        }else if let n_response = response{
//            p_response = "{\n\(n_response)\n}"
//        }
//        let netlog = "URL: " + "\(p_url)" + "\n\n"
//            + "Method: " + "\(p_method)" + "\n\n"
//            + "Headers: " + "\(p_headers)" + "\n\n"
//            + "RequestBody: " + "\(p_body)" + "\n\n"
//            + "Response: " + "\(p_response)" + "\n\n"
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: DnpLogNotification), object: nil,userInfo: [DnpLog:netlog])
//    }

@end
