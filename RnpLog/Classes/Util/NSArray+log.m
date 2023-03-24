//
//  NSArray+log.m
//  RnpLog
//
//  Created by user on 2023/3/24.
//

#import "NSArray+log.h"

@implementation NSArray (log)
- (NSString *)toJson{
    NSString * string;
    
    @try {
    string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    string = [string stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];

    }@catch (NSException *exception) {
        
    }
    return string;
}
@end
