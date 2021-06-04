//
//  RnpHostManager.m
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import "RnpHostManager.h"

@interface RnpHostManager ()

@property (nonatomic, copy, readwrite) NSDictionary * replace_host_dict;

@end

@implementation RnpHostManager
+ (instancetype)shareManager{
    static RnpHostManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [RnpHostManager new];
    });
    return manager;
}
+ (RnpHostManager *)instance
{
    return [self shareManager];
}
+ (void)setInstance:(RnpHostManager *)instance{}


- (void)replaceHostDict:(NSDictionary *)dict{
    self.replace_host_dict = dict;
}

- (NSMutableURLRequest *)checkAndReplaceHost:(NSMutableURLRequest *)mutableRequest
{
    NSString * replace = [self.replace_host_dict valueForKey:mutableRequest.URL.host];
    NSLog(@"ori: %@ rep: %@",mutableRequest.URL.host, replace);
    if (replace) {
        NSString * url = mutableRequest.URL.absoluteString;
        url = [url stringByReplacingOccurrencesOfString:mutableRequest.URL.host withString:replace];
        mutableRequest.URL = [NSURL URLWithString:url];
    }
    
    return mutableRequest;
}
@end
