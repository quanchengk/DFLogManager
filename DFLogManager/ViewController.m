//
//  ViewController.m
//  DFLogManager
//
//  Created by 全程恺 on 16/4/1.
//  Copyright © 2016年 全程恺. All rights reserved.
//

#import "ViewController.h"
#import "DFLogManager.h"
#import "DFLogView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *crachBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_crachBtn addTarget:self action:@selector(crachTest) forControlEvents:UIControlEventTouchUpInside];
    
    [_addBtn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
}

- (void)logOut {
    
    [[DFLogManager shareLogManager] updateSelector:[NSString stringWithFormat:@"加入方法%s", __func__] request:@{@"key": @"请求体"} response:@{@"key": @"数据回参"} error:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[DFLogManager shareLogManager] updateSelector:[NSString stringWithFormat:@"页面展示%s", __func__] request:@{@"key": @"请求体"} response:@{@"key": @"数据回参"} error:nil];
    
    [[DFLogView shareLogView] show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
