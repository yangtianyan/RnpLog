//
//  NSData+log.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "NSData+log.h"

@implementation NSData (log)

- (NSString *)toString{
    NSString * string = [self toOriginString];
    string = [string stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    return string;
}

- (NSString *)toOriginString{
    NSString * string;
    @try {
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableLeaves error:&error];
        if (json) {
            string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        }else{
            string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
        }
    }@catch (NSException *exception) {
        
    }
    return string;
}

@end
