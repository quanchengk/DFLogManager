//
//  DFLogDBManager.m
//  DFLogManager
//
//  Created by 全程恺 on 2018/1/31.
//

#import "DFLogDBManager.h"
#import <sqlite3.h>

@interface DFLogDBManager () {
    
    sqlite3 *_db;
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

- (NSString *)dbFilePath {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"df_log.sqlite"];
    
    return filePath;
}

- (BOOL)db {
    
    // 实例化数据库对象
    int result = sqlite3_open([[self dbFilePath] UTF8String], &_db);
    
    if (result == SQLITE_OK) {
        
        // 初始化数据表
        NSString *logSql = @"CREATE TABLE if not exists 'log' ('request_id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'selector' text,'error' text,'request_object' text,'response_object' text, 'occur_time' text) ";
        char *err = NULL;
        const char *sql = logSql.UTF8String;
        result = sqlite3_exec(_db, sql, NULL, NULL, &err);
    }
    return result == SQLITE_OK;
}

- (NSArray *)getModelFrom:(NSInteger)fromIndex to:(NSInteger)toIndex {
    
    sqlite3_open([[self dbFilePath] UTF8String], &_db);
    sqlite3_stmt *stmt = NULL;
    
    NSString *sql = [NSString stringWithFormat:@"select * from log order by occur_time DESC limit %ld, %ld", fromIndex, toIndex];
    if (sqlite3_prepare(_db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
            
            DFLogModel *model = [DFLogModel new];
            model.requestID = @([[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding] integerValue]);
            model.selector = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            model.error = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            model.requestObject = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            model.responseObject = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
            NSInteger interval = [[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5) encoding:NSUTF8StringEncoding] integerValue];
            model.occurTime = [NSDate dateWithTimeIntervalSince1970:interval];
            [dataArray addObject:model];
        }
        return dataArray;
    }
    
    return nil;
}

- (BOOL)saveModel:(DFLogModel *)logModel {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO log(selector, request_object, response_object, occur_time, error) VALUES ('%@','%@','%@','%f','%@');", logModel.selector, logModel.requestObject, logModel.responseObject, logModel.occurTime.timeIntervalSince1970, logModel.error];
    char *err = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err);
    return result == SQLITE_OK;
}

- (BOOL)deleteModel:(DFLogModel *)logModel {
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM log WHERE request_id = %@",logModel.requestID];
    char *err = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err);
    return result == SQLITE_OK;
}

- (BOOL)deleteAllModel {
    
    NSString *sql = @"delete from log";
    char *err = NULL;
    int result = sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err);
    return result == SQLITE_OK;
}

@end
