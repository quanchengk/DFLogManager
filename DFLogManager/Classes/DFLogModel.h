//
//  DFLogModel.h
//  DFLogManager
//
//  Created by 全程恺 on 17/1/16.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>

@interface DFLogModel : NSObject

@property (nonatomic, retain) NSNumber *requestID;
@property (nonatomic, copy) NSString *selector;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, copy) NSString *requestObject;
@property (nonatomic, copy) NSString *responseObject;
@property (nonatomic, retain) NSDate *occurTime;

//cell用到的属性，区分当前数据是否已被选中
@property (assign, nonatomic) BOOL selected;
@property (retain, nonatomic) NSArray *contentSeperateArr;   // 展示在文本区的内容
@end

