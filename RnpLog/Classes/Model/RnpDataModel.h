//
//  RnpDataModel.h
//  NetworkLog
//
//  Created by user on 2021/5/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RnpDataModel : NSObject

@property (nonatomic, strong) NSURLSessionDataTask * task;

@property (nonatomic, strong) NSData * originalData; // 原始的数据信息

@property (nonatomic, strong) NSData * hookData;

@property (nonatomic, copy)   NSString * requestDate;

@property (nonatomic, copy)  NSString * redirectedUrl;

- (NSString *)rnpLogDataFormat;

- (NSString *)rnpLogDataFormatToJson;

@end

NS_ASSUME_NONNULL_END
