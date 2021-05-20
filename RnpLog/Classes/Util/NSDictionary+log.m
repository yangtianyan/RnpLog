//
//  NSDictionary+log.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "NSDictionary+log.h"

@implementation NSDictionary (log)

- (NSString *)toJson{
    NSString * string;
    
    @try {
    string = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        
    }@catch (NSException *exception) {
        
    }
    return string;
}

@end
