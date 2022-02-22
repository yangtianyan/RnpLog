//
//  RnpCaptureDataManager.h
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RnpDataModel;
@interface RnpCaptureDataManager : NSObject

@property (nonatomic, strong, class) RnpCaptureDataManager * instance;

///网络请求列表 最多存放100条
@property (nonatomic, copy, readonly) NSArray * requests;


/// 网络请求字典
@property (nonatomic, copy, readonly) NSDictionary * requests_dict;


- (void)addRequest:(NSURLSessionDataTask *)task;

/// 清空
- (void)clear;

/// 清空除model外的所有
- (void)clearOther:(RnpDataModel *)model;

/// 清除model数据
- (void)clearWith:(RnpDataModel *)model;
@end

NS_ASSUME_NONNULL_END
