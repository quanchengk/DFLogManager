//
//  DFLogDBManager.m
//  DFLogManager
//
//  Created by 全程恺 on 2018/1/31.
//

#import "DFLogDBManager.h"
#import "FMDB.h"

@interface DFLogDBManager () {
    
    FMDatabase *_db;
}

@end

@implementation DFLogDBManager

- (instancetype)init {
    
    if (self = [super init]) {
        
        BOOL res = [self db];
        if (!res) {
            NSLog(@"数据库创建失败");
        }
    }
    
    return self;
}

- (BOOL)db {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"df_log.sqlite"];
    
    // 实例化FMDataBase对象
    
    _db = [FMDatabase databaseWithPath:filePath];
    
    [_db open];
    
    // 初始化数据表
    NSString *logSql = @"CREATE TABLE if not exists 'log' ('request_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'selector' text,'error' text,'request_object' text,'response_object' text, 'occur_time' datetime) ";
    
    BOOL res = [_db executeUpdate:logSql];
    
    [_db close];
    return res;
}

- (NSArray *)getAllModel {
    
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM log ORDER BY occur_time DESC"];
    
    while ([res next]) {
        
        DFLogModel *model = [DFLogModel new];
        model.requestID = @([res intForColumn:@"request_id"]);
        model.selector = [res stringForColumn:@"selector"];
        model.requestObject = [res stringForColumn:@"request_object"];
        model.responseObject = [res stringForColumn:@"response_object"];
        model.error = [res stringForColumn:@"error"];
        model.occurTime = [res dateForColumn:@"occur_time"];
        
        [dataArray addObject:model];
    }
    
    [_db close];
    return dataArray;
}

- (NSArray *)getModelFrom:(NSInteger)fromIndex to:(NSInteger)toIndex {
    
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *sql = [NSString stringWithFormat:@"select * from log order by occur_time DESC limit %ld, %ld", fromIndex, toIndex];
    FMResultSet *res = [_db executeQuery:sql];
    
    while ([res next]) {
        
        DFLogModel *model = [DFLogModel new];
        model.requestID = @([res intForColumn:@"request_id"]);
        model.selector = [res stringForColumn:@"selector"];
        model.requestObject = [res stringForColumn:@"request_object"];
        model.responseObject = [res stringForColumn:@"response_object"];
        model.error = [res stringForColumn:@"error"];
        model.occurTime = [res dateForColumn:@"occur_time"];
        
        [dataArray addObject:model];
    }
    
    [_db close];
    return dataArray;
}

- (BOOL)saveModel:(DFLogModel *)logModel {
    
    [_db open];
    
    BOOL result = [_db executeUpdate:@"INSERT INTO log(selector, request_object, response_object, occur_time, error) VALUES (?,?,?,?,?);", logModel.selector, logModel.requestObject, logModel.responseObject, logModel.occurTime, logModel.error];
    
    [_db close];
    
    return result;
}

- (BOOL)deleteModel:(DFLogModel *)logModel {
    
    [_db open];
    
    BOOL res = [_db executeUpdate:@"DELETE FROM log WHERE request_id = ?",logModel.requestID];
    
    [_db close];
    return res;
}

- (BOOL)deleteAllModel {
    
    [_db open];
    
    BOOL res = [_db executeUpdate:@"delete from log"];
    
    [_db close];
    return res;
}

@end
