//
//  RnpCaptureDataManager.m
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import "RnpCaptureDataManager.h"
/* -- Model -- */
#import "RnpDataModel.h"
#import "RnpDefine.h"
@interface RnpCaptureDataManager ()

@property (nonatomic, strong) NSMutableArray * mutable_requests;

@property (nonatomic, strong) NSMutableDictionary * mutable_requests_dict;

@end
@implementation RnpCaptureDataManager

+ (instancetype)shareManager{
    static RnpCaptureDataManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [RnpCaptureDataManager new];
    });
    return manager;
}

+ (RnpCaptureDataManager *)instance
{
    return [self shareManager];
}

+ (void)setInstance:(RnpCaptureDataManager *)instance{}

#pragma mark -- lazy
- (NSMutableArray *)mutable_requests
{
    if (!_mutable_requests) {
        _mutable_requests = [NSMutableArray new];
    }
    return _mutable_requests;
}
- (NSMutableDictionary *)mutable_requests_dict
{
    if (!_mutable_requests_dict) {
        _mutable_requests_dict = [NSMutableDictionary new];
    }
    return _mutable_requests_dict;
}
- (NSArray *)requests
{
    return self.mutable_requests;
}
- (NSDictionary *)requests_dict
{
    return self.mutable_requests_dict;
}

#pragma mark -- Public
- (void)addRequest:(NSURLSessionDataTask *)task
{
    @synchronized (self) {
        if (self.mutable_requests.count == 100) {
            RnpDataModel * rModel = self.mutable_requests.firstObject;
            [self.mutable_requests removeObjectAtIndex:0];
            [self.mutable_requests_dict removeObjectForKey:rModel.task];
        }
        RnpDataModel * model = [RnpDataModel new];
        model.task = task;
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
        //设定时间格式,这里可以设置成自己需要的格式
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss SS"];
        NSString *currentDateStr = [dateFormatter stringFromDate: date];

        model.requestDate = currentDateStr;
        [self.mutable_requests addObject:model];
        [self.mutable_requests_dict setObject:model forKey:task];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddRequestNotification object:model];
    }

}
- (void)clear{
    [self.mutable_requests removeAllObjects];
    [self.mutable_requests_dict removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearRequestNotification object:nil];
}
/// 清空除model外的所有
- (void)clearOther:(RnpDataModel *)model{
    [self.mutable_requests removeAllObjects];
    [self.mutable_requests_dict removeAllObjects];
    [self.mutable_requests addObject:model];
    [self.mutable_requests_dict setObject:model forKey:model.task];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearRequestNotification object:nil];
}

/// 清除model数据
- (void)clearWith:(RnpDataModel *)model{
    [self.mutable_requests removeObject:model];
    [self.mutable_requests_dict removeObjectForKey:model.task];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearRequestNotification object:nil];
}
@end
