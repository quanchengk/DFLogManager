//
//  DFLogDBManager.m
//  DFLogManager
//
//  Created by 全程恺 on 2018/1/31.
//

#import "DFLogDBManager.h"
#import "DFLogModel.h"

@interface DFLogDBManager () {
    
    // 始终都在操作同一个对象，避免反复从内存中取
    NSMutableArray *_datas;
    NSString *_key;
}

@end

@implementation DFLogDBManager

- (instancetype)init {
    
    if (self = [super init]) {
        
        _key = @"df_log_models";
        _datas = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:_key]];
        
        [_datas sortUsingComparator:^NSComparisonResult(NSDictionary * _Nonnull obj1, NSDictionary * _Nonnull obj2) {
            
            if ([obj1[@"requestID"] integerValue] < [obj2[@"requestID"] integerValue]) {
                return NSOrderedDescending;
            }
            else if ([obj1[@"requestID"] integerValue] > [obj2[@"requestID"] integerValue]) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
    }
    
    return self;
}

- (NSArray<DFLogModel *> *)getModelFrom:(NSInteger)fromIndex to:(NSInteger)toIndex {
    
    if (fromIndex >= _datas.count) {
        
        return nil;
    }
    
    NSArray *tmpArr = [DFLogModel mj_objectArrayWithKeyValuesArray:[_datas subarrayWithRange:NSMakeRange(fromIndex, MIN(toIndex, _datas.count - fromIndex))]];
    return tmpArr;
}

- (NSInteger)maxCountFromDB {
    
    return _datas.count;
}

- (BOOL)saveModel:(DFLogModel *)logModel {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL res = NO;
    if (logModel.requestID > 0) {
        
        // 判重，如果是重复的，覆盖
        for (NSInteger i = 0; i < _datas.count; i++) {
            
            if ([logModel.requestID integerValue] == [_datas[i][@"requestID"] integerValue]) {
                
                [_datas replaceObjectAtIndex:i withObject:logModel];
                [userDefaults setObject:_datas forKey:_key];
                [userDefaults synchronize];
                res = YES;
                break;
            }
        }
    }
    else {
        
        if (_datas.count) {
            
            logModel.requestID = @([[_datas firstObject][@"requestID"] integerValue] + 1);
            [_datas insertObject:logModel.mj_keyValues atIndex:0];
        }
        else {
            
            logModel.requestID = @(1);

            [_datas addObject:logModel.mj_keyValues];
        }
        
        [userDefaults setObject:_datas forKey:_key];
        [userDefaults synchronize];
        res = YES;
    }
    
    return res;
}

- (BOOL)deleteModel:(DFLogModel *)logModel {
    
    if (logModel.requestID <= 0) {
        
        return NO;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (NSInteger i = 0; i < _datas.count; i++) {
        
        if ([logModel.requestID integerValue] == [_datas[i][@"requestID"] integerValue]) {
            
            [_datas removeObjectAtIndex:i];
            [userDefaults setObject:_datas forKey:_key];
            [userDefaults synchronize];
            return YES;
        }
    }
    
    NSLog(@"未找到记录%@", logModel.requestID);
    return NO;
}

- (void)deleteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    NSArray<DFLogModel *> *models = [self getModelFrom:fromIndex to:toIndex];
    [models enumerateObjectsUsingBlock:^(DFLogModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [self deleteModel:obj];
    }];
}

- (BOOL)deleteAllModel {
    
    [_datas removeAllObjects];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:_key];
    [userDefaults synchronize];
    return YES;
}

@end
