//
//  DFLogDBManager.h
//  DFLogManager
//
//  Created by 全程恺 on 2018/1/31.
//

#import <Foundation/Foundation.h>
#import "DFLogModel.h"

@interface DFLogDBManager : NSObject

@property (assign, nonatomic) NSInteger maxLogerCount;

- (NSArray *)getModelFrom:(NSInteger)fromIndex to:(NSInteger)toIndex;
- (NSInteger)maxCountFromDB;

- (BOOL)saveModel:(DFLogModel *)logModel;

- (BOOL)deleteModel:(DFLogModel *)logModel;
- (void)deleteFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;
- (BOOL)deleteAllModel;

@end
