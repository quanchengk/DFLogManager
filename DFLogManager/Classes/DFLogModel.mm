//
//  DFLogModel.m
//  DFLogManager
//
//  Created by 全程恺 on 17/1/16.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import "DFLogModel.h"

@implementation DFLogModel

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

+ (NSArray *)mj_ignoredPropertyNames {
    
    return @[@"selected", @"contentSeperateArr"];
}

@end

