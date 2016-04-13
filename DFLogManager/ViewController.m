//
//  ViewController.m
//  DFLogManager
//
//  Created by 全程恺 on 16/4/1.
//  Copyright © 2016年 全程恺. All rights reserved.
//

#import "ViewController.h"
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
    
    [[_addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        addLogText(@"%@", [NSDate date]);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    addLogText(@"页面展示");
    
    [[DFLogView shareLogView] performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
