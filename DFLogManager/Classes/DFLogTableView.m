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

-(BOOL)canBecomeFirstResponder{
    return YES;
}

@end

@interface DFLogerTableViewHeader : UITableViewHeaderFooterView {
    
    UILabel *_titleLB;
    UILabel *_timeLB;
    UIButton *_bgBtn;
    UIActivityIndicatorView *_indicatorView;
    UILongPressGestureRecognizer *_longPressGes;
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
        
        _longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyAction)];
        _longPressGes.minimumPressDuration = .5;
        [_bgBtn addGestureRecognizer:_longPressGes];
        
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
    
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) {
        [menuController setMenuVisible:NO animated:YES];
    }
}

#pragma mark - 剪切板操作
- (void)copyAction {
    
    switch (_longPressGes.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self becomeFirstResponder];
            
            UIMenuItem *menuitem_01 = [[UIMenuItem alloc] initWithTitle:@"复制本条" action:@selector(copySelf)];
            UIMenuItem *menuitem_02 = [[UIMenuItem alloc] initWithTitle:@"复制出入参" action:@selector(copyAll)];
            
            UIMenuController* menuController = [UIMenuController sharedMenuController];
            menuController.menuItems = [NSArray arrayWithObjects:menuitem_01, menuitem_02, nil];
            [menuController setTargetRect:_bgBtn.frame inView:self];
            [menuController setMenuVisible:YES animated:YES];
            
            self.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.2];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDismiss) name:UIMenuControllerWillHideMenuNotification object:nil];
        }
            break;
            
        default:
            break;
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)copySelf{
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_model.selector];
}

- (void)copyAll {
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[NSString stringWithFormat:@"%@\n%@", _model.selector, [_model.contentSeperateArr componentsJoinedByString:@"\n"]]];
}

- (void)menuDismiss {
    
    if (_model.error.length) {
        
        self.contentView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.6];
    }
    else
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
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
            
            [self.items removeAllObjects];
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
    
    NSInteger pageSize = 10;
    NSArray *items = [[DFLogManager shareLogManager].dbManager getModelFrom:_items.count to:pageSize];
    [_items addObjectsFromArray:items];
    
    if (self.mj_header.isRefreshing) {
        [self.mj_header endRefreshing];
    }
    if (_items.count == [[DFLogManager shareLogManager].dbManager maxCountFromDB]) {
        // 没有填满一页，则视为没有更多，防止没有尽头的上拉刷新
        [self.mj_footer endRefreshingWithNoMoreData];
    }
    else {
        [self.mj_footer endRefreshing];
    }
    [self reloadData];
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
        
        DFLogModel *model = self -> _items[indexPath.section];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DFLogerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.showStr.length) {
        
        [cell becomeFirstResponder];
        
        UIMenuItem *menuitem_01 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copySelf)];
        
        UIMenuController* menuController = [UIMenuController sharedMenuController];
        menuController.menuItems = [NSArray arrayWithObjects:menuitem_01, nil];
        [menuController setTargetRect:cell.frame inView:self];
        [menuController setMenuVisible:YES animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDismiss) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
    else {
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DFLogerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell resignFirstResponder];
    return indexPath;
}

-(void)copySelf {
    
    // 复制到粘贴板
    NSIndexPath *indexPath = self.indexPathForSelectedRow;
    DFLogModel *model = _items[indexPath.section];
    NSString *showStr = model.contentSeperateArr[indexPath.row];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:showStr];
}

- (void)menuDismiss {
    
    // 取消选中
    NSIndexPath *indexPath = self.indexPathForSelectedRow;
    [self deselectRowAtIndexPath:indexPath animated:YES];
    DFLogerTableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    [cell resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
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
