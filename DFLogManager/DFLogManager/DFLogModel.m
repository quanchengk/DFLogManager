//
//  DFLogModel.m
//  DFLogManager
//
//  Created by 全程恺 on 17/1/16.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import "DFLogModel.h"

@implementation DFLogModel

+ (NSString *)primaryKey {
    
    return @"requestID";
}

+ (NSArray *)ignoredProperties {
    
    return @[@"selected"];
}

@end
