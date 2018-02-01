//
//  DFLogTableView.h
//  DFLogManager
//
//  Created by 全程恺 on 2018/1/31.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@class DFLogerTableViewHeader;
@protocol DFLogerDelegate <NSObject>

- (void)selectHeaderViewAt:(DFLogerTableViewHeader *)header;
- (void)deselectHeaderViewAt:(DFLogerTableViewHeader *)header;

@end

@interface DFLogTableView : UITableView

@property (retain, nonatomic) NSMutableArray *items;
@end
