//
//  TestViewController.m
//  earth
//
//  Created by Feicun on 15/3/30.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()

//@property (strong, nonatomic) WZFlashButton *btn;
@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(toMain:) userInfo:nil repeats:NO];
}

- (void)toMain:(NSTimer *)timer {
    [timer invalidate];
    [self performSegueWithIdentifier:@"ToMain" sender:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
