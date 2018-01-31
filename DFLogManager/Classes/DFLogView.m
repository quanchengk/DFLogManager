//
//  XDJDDLogView.m
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import "DFLogView.h"
#import "DFLogManager.h"
#import <Masonry/Masonry.h>
#import "UITableView+FDTemplateLayoutCell.h"

#define DFScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface CLILogerTableViewCell : UITableViewCell {
    
    //    UITextView *_contentTV;
    UILabel *_content;
}

@property (copy, nonatomic) NSString *showStr;
@end

@implementation CLILogerTableViewCell

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

@class CLILogerTableViewHeader;
@protocol CLILogerDelegate <NSObject>

- (void)selectHeaderViewAt:(CLILogerTableViewHeader *)header;
- (void)deselectHeaderViewAt:(CLILogerTableViewHeader *)header;

@end

@interface CLILogerTableViewHeader : UITableViewHeaderFooterView {
    
    UILabel *_titleLB;
    UILabel *_timeLB;
    UIButton *_bgBtn;
    UIActivityIndicatorView *_indicatorView;
}

@property (assign, nonatomic) BOOL showWaitingView;
@property (retain, nonatomic) DFLogModel *model;
@property (weak, nonatomic) id <CLILogerDelegate> delegate;

@end

@implementation CLILogerTableViewHeader

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

@interface DFLogView () <UITableViewDelegate, UITableViewDataSource, CLILogerDelegate> {
    
    NSMutableArray *_selectArr;
    NSMutableArray<DFLogModel *> *_items;
    UITableView *_tableView;
    
    UIPanGestureRecognizer *_moveGesture;
    UIPanGestureRecognizer *_scaleGesture;
}

@property (retain, nonatomic) UIView *scaleView;
@end

@implementation DFLogView

static DFLogView *_instance;
+ (instancetype)shareLogView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (UIView *)scaleView {
    
    if (!_scaleView) {
        
        _scaleView = [UIView new];
        _scaleView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.1];
    }
    
    return _scaleView;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        UIView *moveableView = [[UIView alloc] init];
        moveableView.backgroundColor = [[UIColor groupTableViewBackgroundColor] colorWithAlphaComponent:.8];
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePosition)];
        [moveableView addGestureRecognizer:_moveGesture];
        
        NSBundle *selfBundle = [NSBundle bundleForClass:[self class]];
        UIImageView *scalableIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        scalableIcon.image = [UIImage imageNamed:@"df_scale" inBundle:selfBundle compatibleWithTraitCollection:NULL];
        scalableIcon.contentMode = UIViewContentModeScaleAspectFit;
        scalableIcon.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.6];
        scalableIcon.userInteractionEnabled = YES;
        _scaleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scale)];
        [scalableIcon addGestureRecognizer:_scaleGesture];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [resetBtn setTitle:@"清空" forState:UIControlStateNormal];
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
//        UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        [removeBtn setTitle:@"关闭" forState:UIControlStateNormal];
//        removeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        _scaleView.hidden = YES;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_tableView registerClass:[CLILogerTableViewCell class] forCellReuseIdentifier:@"CLILogerTableViewCell"];
        [_tableView registerClass:[CLILogerTableViewHeader class] forHeaderFooterViewReuseIdentifier:@"CLILogerTableViewHeader"];
        
        [self addSubview:moveableView];
        [self addSubview:resetBtn];
//        [self addSubview:removeBtn];
        //        [self addSubview:sendBtn];
        [self addSubview:_tableView];
        [self addSubview:scalableIcon];
        
        [moveableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.equalTo(self);
            make.top.equalTo(self);
        }];
        
        [scalableIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.bottom.equalTo(self);
            make.size.mas_equalTo(scalableIcon.frame.size);
        }];
        
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self).offset(15);
            make.top.equalTo(moveableView).offset(10);
            make.bottom.equalTo(moveableView).offset(-10);
            make.size.mas_equalTo(CGSizeMake(60, 30));
        }];
        
        //        [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        //            make.left.equalTo(resetBtn.mas_right).offset(15);
        //            make.top.equalTo(resetBtn);
        //            make.size.equalTo(resetBtn);
        //        }];
        
//        [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//
//            make.right.equalTo(self).offset(-15);
//            make.top.equalTo(resetBtn);
//            make.size.equalTo(resetBtn);
//        }];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(resetBtn.mas_bottom).offset(10);
        }];
        
        [_scaleView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(self);
        }];
        
        [resetBtn addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
//        [removeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        //        [sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
        
        RLMResults *fliter = [DFLogModel allObjectsInRealm:[DFLogManager shareLogManager].realm];
        
        RLMResults *fliterResult = [fliter sortedResultsUsingKeyPath:@"requestID" ascending:NO];
        _items = [NSMutableArray array];
        _selectArr = [NSMutableArray array];
        for (int i = 0; i < fliterResult.count; i++) {
            
            DFLogModel *model = [fliterResult objectAtIndex:i];
            [_items addObject:model];
        }
    }
    return self;
}


#pragma mark - action

- (void)movePosition {
    
    static CGPoint startPoint;
    static CGRect startFrame;
    switch (_moveGesture.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            startPoint = [_moveGesture locationInView:self.superview];
            startFrame = self.frame;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                CGPoint currentPoint = [_moveGesture locationInView:self.superview];
                
                CGRect frame = startFrame;
                double x = currentPoint.x - startPoint.x + startFrame.origin.x;
                if (x < 0) {
                    x = 0;
                }
                else if (x + startFrame.size.width > self.superview.frame.size.width) {
                    x = self.superview.frame.size.width - startFrame.size.width;
                }
                
                double y = currentPoint.y - startPoint.y + startFrame.origin.y;
                if (y < 0) {
                    
                    y = 0;
                }
                else if (y + startFrame.size.height > self.superview.frame.size.height) {
                    
                    y = self.superview.frame.size.height - startFrame.size.height;
                }
                frame.origin = CGPointMake(x, y);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.frame = frame;
                    [self layoutIfNeeded];
                });
            });
            break;
        }
            
        default:
            break;
    }
}

- (void)scale {
    
    static CGPoint startPoint;
    static CGRect startFrame;
    switch (_scaleGesture.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            [self.superview addSubview:self.scaleView];
            self.scaleView.frame = self.frame;
            startPoint = [_scaleGesture locationInView:self.superview];
            startFrame = self.frame;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                CGPoint currentPoint = [_scaleGesture locationInView:self.superview];
                CGRect frame = startFrame;
                
                CGFloat toWidth = currentPoint.x - startFrame.origin.x;
                if (toWidth < _scaleGesture.view.frame.size.width) {
                    
                    toWidth = _scaleGesture.view.frame.size.width;
                }
                
                CGFloat toHeight = currentPoint.y - startFrame.origin.y;
                if (toHeight < _scaleGesture.view.frame.size.height) {
                    
                    toHeight = _scaleGesture.view.frame.size.height;
                }
                
                frame.size = CGSizeMake(toWidth, toHeight);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    _scaleView.frame = frame;
                });
            });
            break;
        }
        case UIGestureRecognizerStateEnded: {
            
            self.frame = _scaleView.frame;
            [_scaleView removeFromSuperview];
            [self layoutIfNeeded];
            break;
        }
        default:
            break;
    }
}

- (void)reset {
    
    [[DFLogManager shareLogManager] reset];
}

- (void)showComplete:(void (^)(void))animations
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        
        self.frame = UIEdgeInsetsInsetRect(keyWindow.bounds, UIEdgeInsetsMake(20, 10, 110, 10));
    }
    if (animations) {
        animations();
    }
}

- (void)close {
    
    [self removeFromSuperview];
}

- (void)send {
    
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DFLogModel *manager = _items[section];
    if ([_selectArr containsObject:manager]) {
        
        return manager.contentSeperateArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CLILogerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CLILogerTableViewCell"];
    cell.showStr = _items[indexPath.section].contentSeperateArr[indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CLILogerTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CLILogerTableViewHeader"];
    header.model = _items[section];
    header.delegate = self;
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CLILogerTableViewHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"CLILogerTableViewHeader"];
    header.model = _items[section];
    CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    return [tableView fd_heightForCellWithIdentifier:@"CLILogerTableViewCell" configuration:^(CLILogerTableViewCell *cell) {
        
        cell.showStr = _items[indexPath.section].contentSeperateArr[indexPath.row];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return .1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CLILogerTableViewHeader *header = (CLILogerTableViewHeader *)[tableView headerViewForSection:indexPath.section];
    header.showWaitingView = NO;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CLILogerTableViewHeader *header = (CLILogerTableViewHeader *)[tableView headerViewForSection:indexPath.section];
    header.showWaitingView = NO;
}

#pragma mark - CLILogerDelegate
- (void)selectHeaderViewAt:(CLILogerTableViewHeader *)header {
    
    NSInteger section = [_items indexOfObject:header.model];
    NSMutableArray *indexPathes = [NSMutableArray array];
    for (int i = 0; i < header.model.contentSeperateArr.count; i++) {
        
        [indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    if (![_selectArr containsObject:header.model]) {
        
        header.model.selected = YES;
        [_selectArr addObject:header.model];
        
        [_tableView insertRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)deselectHeaderViewAt:(CLILogerTableViewHeader *)header {
    
    NSInteger section = [_items indexOfObject:header.model];
    NSMutableArray *indexPathes = [NSMutableArray array];
    for (int i = 0; i < header.model.contentSeperateArr.count; i++) {
        
        [indexPathes addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    if ([_selectArr containsObject:header.model]) {
        
        header.model.selected = NO;
        [_selectArr removeObject:header.model];
        
        [_tableView deleteRowsAtIndexPaths:indexPathes withRowAnimation:UITableViewRowAnimationTop];
    }
}

- (void)add:(DFLogModel *)model {
    
    [_items insertObject:model atIndex:0];
    [_tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)deleteIndexes:(NSIndexSet *)indexSet {
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        
        DFLogModel *model = [_items objectAtIndex:idx];
        [_selectArr removeObject:model];
    }];
    
    [_items removeObjectsAtIndexes:indexSet];
    [_tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end


