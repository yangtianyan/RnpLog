//
//  RnpDataModel.m
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import "RnpDataModel.h"
#import "NSDictionary+log.h"
#import "NSData+log.h"
#import "NSString+log.h"

@implementation RnpDataModel

- (void)setOriginalData:(NSData *)originalData{
    [self willChangeValueForKey:@"originalData"];
    _originalData = originalData;
    [self didChangeValueForKey:@"originalData"];
}
- (NSString *)rnpLogDataFormat
{
    ///    string = [string stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    NSString * p_url = [NSString stringWithFormat:@"%@",self.task.originalRequest.URL];
    NSString * p_method          = self.task.originalRequest.HTTPMethod;
    NSString * p_header          = [self requestHeader];
    NSString * p_body            = [self requestBody];
    NSString * p_response_header = [self responseHeader];
    NSString * p_response        = [self originalResponse];
    NSString * h_response        = [self hookResponse];
    NSMutableString * netLog;
    if (self.redirectedUrl.length) {
        netLog = [@"OriginURL: " mutableCopy];
        [netLog appendString:p_url];
        [netLog appendString:@"\n\n\n"];
        [netLog appendString:@"RedirectedURL: "];
        [netLog appendString:self.redirectedUrl];
    }else{
        netLog = [@"URL: " mutableCopy];
        [netLog appendString:p_url];
    }
    if([self.task.response isKindOfClass:NSHTTPURLResponse.class]){
        [netLog appendString:@"\n\n\n"];
        [netLog appendString:@"HttpCode: "];
        [netLog appendString:[NSString stringWithFormat:@"%lu",[(NSHTTPURLResponse *)self.task.response statusCode]]];
    }
    [netLog appendString:@"\n\n\n"];
    [netLog appendString:@"Method: "];
    [netLog appendString:p_method];
    [netLog appendString:@"\n\n\n"];
    [netLog appendString:@"Headers: "];
    [netLog appendString:p_header];
    [netLog appendString:@"\n\n\n"];
    [netLog appendString:@"RequestBody: "];
    [netLog appendString:p_body];
    [netLog appendString:@"\n\n\n"];
    [netLog appendString:@"ResponseHeader: "];
    [netLog appendString:p_response_header];
    [netLog appendString:@"\n\n\n"];
    [netLog appendString:@"Response: "];
    [netLog appendString:p_response];
    if (h_response.length > 0) {
        [netLog appendString:@"\n\n\n"];
        [netLog appendString:@"HookResponse: "];
        [netLog appendString:h_response];
    }
    return netLog;
}
- (NSDictionary *)rnpLogDataFormatToJson{
    NSString * p_url = [NSString stringWithFormat:@"%@",self.task.originalRequest.URL];
    NSString * p_method          = self.task.originalRequest.HTTPMethod;
    NSString * p_header          = [self requestHeader];
    NSString * p_body            = [self requestBody];
    NSString * p_response_header = [self responseHeader];
    NSString * p_response        = [self originalResponse];
    NSString * h_response        = [self hookResponse];
    NSMutableDictionary * json = @{}.mutableCopy;
    if (self.redirectedUrl.length) {
        [json setValue:p_url forKey:@"OriginURL"];
        [json setValue:self.redirectedUrl forKey:@"RedirectedURL"];
    }else{
        [json setValue:p_url forKey:@"URL"];
    }
    if([self.task.response isKindOfClass:NSHTTPURLResponse.class]){
        [json setValue:[NSString stringWithFormat:@"%lu",[(NSHTTPURLResponse *)self.task.response statusCode]] forKey:@"HttpCode"];
    }
    [json addEntriesFromDictionary:@{
        @"Method": p_method ?: @"",
        @"Headers": p_header.toJson ?: @{},
        @"RequestBody": p_body.toJson ?: @"",
        @"ResponseHeader": p_response_header.toJson ?: @"",
        @"Response": p_response.toJson ?: @"",
    }];
    if (h_response.length > 0) {
        [json setObject:h_response.toJson ?: @"" forKey:@"HookResponse"];
    }
    return json;
}

- (NSString *)rnpLogDataFormatToJsonString{

    return [self rnpLogDataFormatToJson].toJson;
}

- (NSString *)requestHeader{
    NSString * p_header = @"{\n\n}";
    if (self.task.originalRequest.allHTTPHeaderFields.count > 0) {
        p_header =  [NSString stringWithFormat:@"%@",self.task.originalRequest.allHTTPHeaderFields.toJson];
    }
    return p_header;
}
- (NSString *)requestBody{
    NSString * p_body = @"{\n\n}";
    if (self.task.originalRequest.HTTPBody) {
        NSString * string = [[NSString alloc] initWithData:self.task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        p_body = [NSString stringWithFormat:@"%@",string];
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
        NSString * string = data.toString;
        p_body = [NSString stringWithFormat:@"%@",string];
    }
    return p_body;
}

- (NSString *)responseHeader{
    NSString * p_response_header = @"{\n\n}";
    if ([self.task.response isKindOfClass:NSHTTPURLResponse.class]) {
        NSDictionary * dictionary = [(NSHTTPURLResponse *)self.task.response allHeaderFields];
        if (dictionary.count > 0) {
            NSString * string = dictionary.toJson;
            p_response_header = [NSString stringWithFormat:@"%@",string];
        }
    }
    return p_response_header;
}

- (NSString *)originalResponse{
    NSString * p_response = @"{\n\n}";
    if (self.originalData) {
        NSString * string = self.originalData.toString;
        p_response = [NSString stringWithFormat:@"%@",string];
    }else if (self.task.error){
        p_response = [NSString stringWithFormat:@"%@",self.task.error.localizedDescription];
    }
    return p_response;
}

- (NSString *)hookResponse{
    NSString * h_response = @"";
    if (self.hookData) {
        NSString * string = self.hookData.toString;
        h_response = [NSString stringWithFormat:@"%@",string];
    }else if (self.task.error){
        h_response = [NSString stringWithFormat:@"%@",self.task.error.localizedDescription];
    }
    return h_response;
}
@end
