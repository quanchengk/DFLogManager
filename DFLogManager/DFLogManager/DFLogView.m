//
//  XDJDDLogView.m
//  XDJHR
//
//  Created by apple on 16/3/22.
//  Copyright © 2016年 danfort. All rights reserved.
//

#import "DFLogView.h"

static DFLogView *_instance;

@implementation DFLogView

+ (instancetype)shareLogView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        self.alpha = .7;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        UIView *moveableView = [UIView new];
        moveableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
        _moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePosition)];
        [moveableView addGestureRecognizer:_moveGesture];
        
        UIView *scalableView = [UIView new];
        scalableView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.4];
        _scaleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scale)];
        [scalableView addGestureRecognizer:_scaleGesture];
        
        UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resetBtn.backgroundColor = [UIColor darkGrayColor];
        [resetBtn setTitle:@"清空" forState:UIControlStateNormal];
        resetBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        removeBtn.backgroundColor = [UIColor redColor];
        [removeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        removeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        
        UITextField *searchTF = [UITextField new];
        searchTF.placeholder = @"搜索关键字";
        searchTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        searchTF.delegate = self;
        searchTF.returnKeyType = UIReturnKeySearch;
        searchTF.clearButtonMode = UITextFieldViewModeAlways;
        searchTF.leftViewMode = UITextFieldViewModeAlways;
        _searchTF = searchTF;
        
        UILabel *leftLabel = [UILabel new];
        leftLabel.font = [UIFont systemFontOfSize:10];
        leftLabel.textColor = [UIColor yellowColor];
        searchTF.leftView = leftLabel;
        
        UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [preBtn setTitle:@"<" forState:UIControlStateNormal];
        [preBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [preBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        preBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _preBtn = preBtn;
        
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [nextBtn setTitle:@">" forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _nextBtn = nextBtn;
        
        UITextView *textView = [UITextView new];
        textView.font = [UIFont boldSystemFontOfSize:12];
        textView.textColor = [UIColor blackColor];
        textView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.4];
        textView.editable = NO;
        [self addSubview:textView];
        _textView = textView;
        
        [self addSubview:moveableView];
        [self addSubview:resetBtn];
        [self addSubview:removeBtn];
        [self addSubview:searchTF];
        [self addSubview:preBtn];
        [self addSubview:nextBtn];
        [self addSubview:scalableView];
        
        [scalableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.right.bottom.equalTo(self);
        }];
        
        [moveableView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.top.equalTo(self);
            make.width.equalTo(self);
            make.height.mas_equalTo(@(30 + 30));
        }];
        
        [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.height.mas_equalTo(30);
            make.width.equalTo(@50).priorityHigh();
            make.left.equalTo(self).offset(30);
            make.bottom.equalTo(moveableView);
        }];
        
        [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.top.height.equalTo(resetBtn);
            make.left.equalTo(resetBtn.mas_right).offset(10);
        }];
        
        [searchTF mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.height.equalTo(resetBtn);
            make.right.equalTo(preBtn.mas_left);
            make.left.mas_lessThanOrEqualTo(removeBtn.mas_right).offset(10);
        }];
        
        [preBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(searchTF.mas_right);
            make.centerY.equalTo(removeBtn);
        }];
        
        [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(preBtn.mas_right);
            make.right.equalTo(self);
            make.centerY.equalTo(removeBtn);
        }];
        
        [[resetBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[DFLogManager shareLogManager] reset];
                [self updateContent];
            });
        }];
        
        [[removeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [self removeFromSuperview];
        }];
        
        [[preBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            if (!preBtn.selected) {
                
                NSInteger index = [_searchRanges indexOfObject:_selectRange];
                
                if (--index >= 0) {
                    
                    _selectRange = _searchRanges[index];
                    [self selectIndex:index];
                }
            }
        }];
        
        [[nextBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            if (!nextBtn.selected) {
                
                NSInteger index = [_searchRanges indexOfObject:_selectRange];
                
                if (++index < _searchRanges.count) {
                    
                    _selectRange = _searchRanges[index];
                    [self selectIndex:index];
                }
            }
        }];
        
        preBtn.selected = YES;
        nextBtn.selected = YES;
        
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self).offset(60).priorityHigh();
            make.left.right.bottom.equalTo(self);
        }];
        
        _searchRanges = [NSMutableArray array];
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
                frame.origin = CGPointMake(currentPoint.x - startPoint.x + startFrame.origin.x, currentPoint.y - startPoint.y + startFrame.origin.y);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    self.frame = frame;
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
                    
                    self.frame = frame;
                });
            });
            break;
        }
            
        default:
            break;
    }
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    self.frame = UIEdgeInsetsInsetRect(keyWindow.bounds, UIEdgeInsetsMake(20, 10, 10, 10));
    
    [self updateContent];
}

- (void)updateContent
{
    NSString *logFilePath = [[DFLogManager shareLogManager] logsDirectory];
    NSData *logData = [NSData dataWithContentsOfFile:logFilePath];
    _logStr = [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
    [self search:_searchTF.text];
}

- (void)search:(NSString *)keyStr {
    
    [_searchRanges removeAllObjects];
    
    NSRange range = [_logStr rangeOfString:keyStr options:NSCaseInsensitiveSearch range:NSMakeRange(0, _logStr.length)];
    while (range.length) {
        
        [_searchRanges addObject:[NSValue valueWithRange:range]];
        range = [_logStr rangeOfString:keyStr options:NSCaseInsensitiveSearch range:NSMakeRange(range.length + range.location, _logStr.length - range.length - range.location)];
    }
    
    NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] initWithString:_logStr];
    [mAttr addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           NSBackgroundColorAttributeName: [UIColor clearColor]} range:NSMakeRange(0, _logStr.length)];
    for (NSValue *rangeValue in _searchRanges) {
        
        [mAttr addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                               NSBackgroundColorAttributeName: [UIColor yellowColor]} range:[rangeValue rangeValue]];
    }
    UILabel *leftLabel = (UILabel *)_searchTF.leftView;
    _textView.attributedText = mAttr;
    
    if (_searchRanges.count) {
        
        _selectRange = _searchRanges[0];
        [self selectIndex:0];
    }
    else {
        
        [_textView scrollRangeToVisible:NSMakeRange(_logStr.length - 1, 1)];
        leftLabel.text = @"";
        [leftLabel sizeToFit];
        
        _preBtn.selected = YES;
        _nextBtn.selected = YES;
    }
}

- (void)selectIndex:(NSInteger)index {
    
    _preBtn.selected = index == 0;
    _nextBtn.selected = index == _searchRanges.count - 1;
    
    UILabel *leftLabel = (UILabel *)_searchTF.leftView;
    [_textView scrollRangeToVisible:[_searchRanges[index] rangeValue]];
    leftLabel.text = [NSString stringWithFormat:@"%ld/%lu条 ", (long)index + 1, (unsigned long)_searchRanges.count];
    [leftLabel sizeToFit];
}

+ (void)addLogText:(NSString *)logStr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableString *mString = [NSMutableString stringWithString:@"\n"];
        [mString appendString:logStr];
        [mString appendString:@"\n"];
        DDLogInfo(mString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_instance updateContent];
        });
    });
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self search:textField.text];
    [textField resignFirstResponder];
    
    return YES;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
