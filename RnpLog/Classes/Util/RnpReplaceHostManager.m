//
//  RnpReplaceHostManager.m
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import "RnpReplaceHostManager.h"

@interface RnpReplaceHostManager ()

@property (nonatomic, copy, readwrite) NSDictionary * host_dict;

@end

@implementation RnpReplaceHostManager
+ (instancetype)shareManager{
    static RnpReplaceHostManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [RnpReplaceHostManager new];
    });
    return manager;
}
+ (RnpReplaceHostManager *)instance
{
    return [self shareManager];
}
+ (void)setInstance:(RnpReplaceHostManager *)instance{}


- (void)replaceHostDict:(NSDictionary *)dict{
    self.host_dict = dict;
}

- (NSMutableURLRequest *)checkAndReplaceHost:(NSMutableURLRequest *)mutableRequest
{
    NSString * replace = [self.host_dict valueForKey:mutableRequest.URL.host];
    NSLog(@"ori: %@ rep: %@",mutableRequest.URL.host, replace);
    if (replace) {
        NSString * url = mutableRequest.URL.absoluteString;
        url = [url stringByReplacingOccurrencesOfString:mutableRequest.URL.host withString:replace];
        mutableRequest.URL = [NSURL URLWithString:url];
    }
    
    return mutableRequest;
}
@end
