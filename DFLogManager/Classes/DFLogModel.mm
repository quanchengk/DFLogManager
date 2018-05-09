//
//  DFLogModel.m
//  DFLogManager
//
//  Created by 全程恺 on 17/1/16.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import "DFLogModel.h"

@implementation DFLogModel

- (id)copyWithZone:(NSZone *)zone {
    
    DFLogModel *model = [[[self class] allocWithZone:zone] init];
    model.requestID = self.requestID;
    model.selector = self.selector;
    model.error = self.error;
    model.requestObject = self.requestObject;
    model.responseObject = self.responseObject;
    model.occurTime = self.occurTime;
    
    return model;
}

- (NSString *)error {
    
    if (!_error) {
        _error = @"";
    }
    return _error;
}

- (NSArray *)contentSeperateArr {
    
    if (!_contentSeperateArr) {
        
        NSString *contentStr = [NSString stringWithFormat:@"%@\n%@\n%@\n==end==", self.requestObject, self.responseObject.length ? self.responseObject : @"无", self.error.length ? self.error : @""];
        _contentSeperateArr = [contentStr componentsSeparatedByString:@"\n"];
    }
    
    return _contentSeperateArr;
}

@end

