//
//  NSURLRequest+curl.m
//  RnpLog
//
//  Created by user on 2022/6/1.
//

#import "NSURLRequest+curl.h"
#import "NSData+log.h"
@implementation NSURLRequest (curl)

- (NSString *)curl{
    NSString * space = @" ";
    NSString * method = [NSString stringWithFormat:@"-X %@%@", self.HTTPMethod, space];
    NSString * url    = [NSString stringWithFormat:@"--url %@%@", self.URL.absoluteString, space];
    __block NSMutableString * header = [@"" mutableCopy];
    if (self.allHTTPHeaderFields.allKeys.count) {
        [self.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [header appendString:[NSString stringWithFormat:@"-H \"%@: %@\"%@", key, obj, space]];
        }];
    }
    NSString * body = [self requestBody];
    if (body.length) {
        body = [NSString stringWithFormat:@"--data \"%@\"%@", body,space];
    }

    return [NSString stringWithFormat:@"curl %@%@%@%@",method?:@"", url?:@"", header?:@"", body?:@""];
}


- (NSString *)requestBody{
    NSString * p_body ;
    if (self.HTTPBody) {
        NSString * string = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
        p_body = [NSString stringWithFormat:@"%@",string];
    }else if (self.HTTPBodyStream){
        uint8_t d[1024] = {0};
        NSInputStream *stream = self.HTTPBodyStream;
        NSMutableData *data = [[NSMutableData alloc] init];
        [stream open];
        
        while ([stream hasBytesAvailable]) {
            NSInteger len = [stream read:d maxLength:1024];
            if (len > 0 && stream.streamError == nil) {
                [data appendBytes:(void *)d length:len];
            }
        }
        [stream close];
        p_body = [self toStringWithData:data];
    }
    return p_body;
}

- (NSString *)toStringWithData:(NSData *)data{
    NSString * string;
    @try {
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (json) {
            string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil] encoding:NSUTF8StringEncoding];
        }else{
            string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }@catch (NSException *exception) {
        
    }
    return string;
}


@end
