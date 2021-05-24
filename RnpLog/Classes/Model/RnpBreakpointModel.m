//
//  RnpBreakpointModel.m
//  RnpLog
//
//  Created by user on 2021/5/19.
//

#import "RnpBreakpointModel.h"

@implementation RnpBreakpointModel

- (instancetype)init
{
    if (self = [super init]) {
        _isActivate = true;
        _isAfter = true;
    }
    return self;
}

- (void)setIsActivate:(BOOL)isActivate
{
    _isActivate = isActivate;
    _isAfter = isActivate;
    _isBefore = isActivate;
}

@end
