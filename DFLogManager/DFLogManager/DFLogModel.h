//
//  DFLogModel.h
//  DFLogManager
//
//  Created by 全程恺 on 17/1/16.
//  Copyright © 2017年 全程恺. All rights reserved.
//

#import <Realm/Realm.h>

@interface DFLogModel : RLMObject

@property NSNumber<RLMInt> *requestID;
@property NSString *selector;
@property NSString *error;
@property NSString *requestObject;
@property NSString *responseObject;
@property NSDate *occurTime;

//cell用到的属性，区分当前数据是否已被选中
@property (assign, nonatomic) BOOL selected;

@end
