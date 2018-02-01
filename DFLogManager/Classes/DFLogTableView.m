//
//  DFLogTableView.m
//  DFLogManager
//
//  Created by 全程恺 on 2018/1/31.
//

#import "DFLogTableView.h"
#import "DFLogModel.h"
#import <Masonry/Masonry.h>
#import "DFLogManager.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MJRefresh.h"

#define DFScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface DFLogerTableViewCell : UITableViewCell {
    
    //    UITextView *_contentTV;
    UILabel *_content;
}

@property (copy, nonatomic) NSString *showStr;
@end

@implementation DFLogerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _content = [UILabel new];
        _content.font = [UIFont systemFontOfSize:12];
        _content.numberOfLines = 0;
        _content.preferredMaxLayoutWidth = DFScreenWidth - 20 - 15 - 15;
        [self.contentView addSubview:_content];
        
        [_content mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 15, 0, 15));
        }];
    }
    return self;
}

- (void)setShowStr:(NSString *)showStr {
    
    _showStr = showStr;
    _content.text = _showStr;
}

@end

@interface DFLogerTableViewHeader : UITableViewHeaderFooterView {
    
    UILabel *_titleLB;
    UILabel *_timeLB;
    UIButton *_bgBtn;
    UIActivityIndicatorView *_indicatorView;
}

@property (assign, nonatomic) BOOL showWaitingView;
@property (retain, nonatomic) DFLogModel *model;
@property (weak, nonatomic) id <DFLogerDelegate> delegate;

@end

@implementation DFLogerTableViewHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        _bgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bgBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLB = [UILabel new];
        titleLB.font = [UIFont systemFontOfSize:12];
        titleLB.textColor = [UIColor blackColor];
        titleLB.numberOfLines = 0;
        titleLB.preferredMaxLayoutWidth = DFScreenWidth - 20 - 15 - 10 - 100;
        _titleLB = titleLB;
        [self.contentView addSubview:titleLB];
        
        _timeLB = [UILabel new];
        _timeLB.font = [UIFont systemFontOfSize:12];
        _timeLB.textColor = [UIColor grayColor];
        [self.contentView addSubview:_timeLB];
        [self.contentView addSubview:_bgBtn];
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView addSubview:line];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
        [self.contentView addSubview:_indicatorView];
        
        [titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.contentView).offset(15);
            make.top.equalTo(self.contentView).offset(5);
            make.bottom.equalTo(self.contentView).offset(-5);
            make.right.offset(-110);
        }];
        
        [_timeLB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-15);
            make.top.equalTo(titleLB);
        }];
        
        [_bgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(self.contentView);
        }];
        
        [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.center.equalTo(self.contentView);
        }];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(.5);
        }];
        
        [_timeLB setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

- (void)setShowWaitingView:(BOOL)showWaitingView {
    
    _showWaitingView = showWaitingView;
    if (showWaitingView) {
        [_indicatorView startAnimating];
    }
    else [_indicatorView stopAnimating];
}

- (void)setModel:(DFLogModel *)model {
    
    _model = model;
    _bgBtn.selected = model.selected;
    
    NSDateFormatter *dateF = [NSDateFormatter new];
    dateF.dateFormat = @"MM-dd HH:mm:ss";
    _timeLB.text = [dateF stringFromDate:model.occurTime];
    [_timeLB sizeToFit];
    
    _titleLB.text = model.selector;
    
    if (model.error.length) {
        
        self.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.6];
    }
    else
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self layoutIfNeeded];
}

- (void)click {
    
    _bgBtn.selected = !_bgBtn.selected;
    if (_bgBtn.selected && [self.delegate respondsToSelector:@selector(selectHeaderViewAt:)]) {
        
        self.showWaitingView = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.delegate selectHeaderViewAt:self];
        });
    }
    else if (!_bgBtn.selected && [self.delegate respondsToSelector:@selector(deselectHeaderViewAt:)]) {
        
        self.showWaitingView = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.delegate deselectHeaderViewAt:self];
        });
    }
}

@end

@interface DFLogTableView () <DFLogerDelegate, UITableViewDelegate, UITableViewDataSource>

@end

@implementation DFLogTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    
    if (self = [super initWithFrame:frame style:style]) {
        
        [self registerClass:[DFLogerTableViewCell class] forCellReuseIdentifier:@"DFLogerTableViewCell"];
        [self registerClass:[DFLogerTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"DFLogerTableViewHeader"];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        _items = [NSMutableArray array];
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            [_items removeAllObjects];
            [self loadData];
        }];
        self.mj_header = header;
        
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self loadData];
        }];
        self.mj_footer = footer;
        
        [self.mj_header beginRefreshing];
    }
    return self;
}

- (void)loadData {
    
    RLMResults *fliter = [DFLogModel allObjectsInRealm:[DFLogManager shareLogManager].realm];
    RLMResults *fliterResult = [fliter sortedResultsUsingKeyPath:@"occurTime" ascending:NO];
    NSInteger curCount = _items.count;
    for (NSInteger i = curCount; i < MIN(curCount + 10, fliterResult.count); i++) {
        
        DFLogModel *model = [fliterResult objectAtIndex:i];
        [_items addObject:model];
    }
    [self reloadData];
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DFLogModel *model = _items[section];
    
    return model.selected ? model.contentSeperateArr.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DFLogModel *model = _items[indexPath.section];
    DFLogerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DFLogerTableViewCell"];
    cell.showStr = model.contentSeperateArr[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DFLogerTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DFLogerTableViewHeader"];
    header.model = _items[section];
    header.delegate = self;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    DFLogerTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DFLogerTableViewHeader"];
    header.model = _items[section];
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return [tableView fd_heightForCellWithIdentifier:@"DFLogerTableViewCell" configuration:^(DFLogerTableViewCell *cell) {
        
        DFLogModel *model = _items[indexPath.section];
        cell.showStr = model.contentSeperateArr[indexPath.row];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return .1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DFLogerTableViewHeader *header = (DFLogerTableViewHeader *)[tableView headerViewForSection:indexPath.section];
    header.showWaitingView = NO;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DFLogerTableViewHeader *header = (DFLogerTableViewHeader *)[tableView headerViewForSection:indexPath.section];
    header.showWaitingView = NO;
}

#pragma mark - DFLogerDelegate
- (void)selectHeaderViewAt:(DFLogerTableViewHeader *)header {
    
    if (!header.model.selected) {
        
        NSInteger section = [_items indexOfObject:header.model];
        
        NSMutableArray *indexPathes = [NSMutableArray array];
        for (int i = 0; i < header.model.contentSeperateArr.count; i++) {
            
            [indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        header.model.selected = YES;
        
        [self insertRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)deselectHeaderViewAt:(DFLogerTableViewHeader *)header {
    
    if (header.model.selected) {
        
        NSInteger section = [_items indexOfObject:header.model];
        
        NSMutableArray *indexPathes = [NSMutableArray array];
        for (int i = 0; i < header.model.contentSeperateArr.count; i++) {
            
            [indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        
        header.model.selected = NO;
        
        [self deleteRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationTop];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
