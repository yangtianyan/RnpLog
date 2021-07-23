//
//  RnpHostManager.m
//  RnpLog
//
//  Created by user on 2021/5/24.
//

#import "RnpHostManager.h"

@interface RnpHostManager ()

@property (nonatomic, copy, readwrite) NSDictionary * replace_host_dict;

@property (nonatomic, copy) NSDictionary<NSString *, id> * white_list_dict;

@property (nonatomic, copy, readwrite) NSArray<NSString *> * white_list;

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
- (void)setupWhiteList:(NSArray *)whiteList{
    self.white_list = whiteList;
    NSMutableDictionary * dictionary = [NSMutableDictionary new];
    for (NSString * host in whiteList) {
        [dictionary setValue:@"" forKey:host];
    }
    self.white_list_dict = dictionary;
}

- (BOOL)checkWhiteList:(NSURLRequest *)request{
    if (self.white_list_dict.count == 0) {
        return YES;
    }
    id host = [self.white_list_dict valueForKey:request.URL.host];
    return host;
}
@end
