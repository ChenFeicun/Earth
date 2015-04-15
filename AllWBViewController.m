//
//  TestViewController.m
//  earth
//
//  Created by Feicun on 15/4/12.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "AllWBViewController.h"
#import "SCLAlertView.h"
#import "GoogleMobileAds/GADBannerView.h"

#define IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)

@interface AllWBViewController () <UITableViewDataSource, UITableViewDelegate> {
    GADBannerView *bannerView;
}

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *treeArray;
@property (strong, nonatomic) ResourceManager *resourceManager;

@end

@implementation AllWBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self googleAD];
    [self listInit];
    self.resourceManager = [ResourceManager sharedInstance];
    
    self.treeArray = [[NSMutableArray alloc] initWithArray:self.resourceManager.provinceArray];
    
    // Do any additional setup after loading the view.
}

- (void)listInit {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, bannerView.frame.size.height - 1)];
    self.titleLabel.backgroundColor = SKY_BLUE;
    self.titleLabel.text = @"各省市环保机构官方微博";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:IS_PAD ? 30 : 20];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, bannerView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - 2 * bannerView.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    [self.view addSubview:self.tableView];
    
    //防止广告显示不出来 下方一片白不和谐
    UILabel *fillLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bannerView.frame.origin.y, SCREEN_WIDTH, bannerView.frame.size.height)];
    fillLabel.backgroundColor = SKY_BLUE;
    [self.view addSubview:fillLabel];
}

- (void)googleAD {
    // 在屏幕顶部创建标准尺寸的视图。
    // 在GADAdSize.h中对可用的AdSize常量进行说明。
    CGPoint origin = CGPointMake(0, self.view.frame.size.height - CGSizeFromGADAdSize(kGADAdSizeSmartBannerPortrait).height);
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:origin];
    // 指定广告单元ID。
    bannerView.adUnitID = GOOGLE_AD_ID;//@"ca-app-pub-9981528462779788/6387264958";
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个UIViewController
    // 并将其添加至视图层级结构。
    bannerView.rootViewController = self;

    [self.view addSubview:bannerView];
    // 启动一般性请求并在其中加载广告。
    [bannerView loadRequest:[GADRequest request]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [ResourceManager sharedInstance].provinceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *tempSectionString = [NSString stringWithFormat:@"%ld",(long)section];
    if ([self.treeArray containsObject:tempSectionString]) {
        NSArray *cities = [self.resourceManager getAllCitiesOfProvince:self.resourceManager.provinceArray[section]];
        return cities.count;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *tempV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ALLWB_HEIGHT)];
    tempV.backgroundColor = SKY_BLUE;//[UIColor colorWithRed:(236)/255.0f green:(236)/255.0f blue:(236)/255.0f alpha:1];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(16, 2, 200, ALLWB_HEIGHT)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor whiteColor];
    label1.font = [UIFont boldSystemFontOfSize:20];//[UIFont fontWithName:@"Arial" size:20];
    label1.text = [ResourceManager sharedInstance].provinceArray[section];
    
    UIImageView *tempImageV = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - ALLWB_HEIGHT + 10, 10, ALLWB_HEIGHT - 20, ALLWB_HEIGHT - 20)];
    NSString *tempSectionString = [NSString stringWithFormat:@"%ld", (long)section];
    if ([self.treeArray containsObject:tempSectionString]) {
        tempImageV.image = [UIImage imageNamed:@"close"];
    }else{
        tempImageV.image = [UIImage imageNamed:@"open"];
    }
    ///给section加一条线。
    CALayer *_separatorL = [CALayer layer];
    _separatorL.frame = CGRectMake(0.0f, ALLWB_HEIGHT - 1, [UIScreen mainScreen].bounds.size.width, 1.0f);
    _separatorL.backgroundColor = [UIColor whiteColor].CGColor;
    
    [tempV addSubview:label1];
    [tempV addSubview:tempImageV];
    [tempV.layer addSublayer:_separatorL];
    
    UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tempBtn.frame = CGRectMake(0, 0, SCREEN_WIDTH, ALLWB_HEIGHT);
    [tempBtn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    tempBtn.tag = section;
    [tempV addSubview:tempBtn];
    return tempV;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ALLWB_HEIGHT;
}

-(void)tapAction:(UIButton *)sender {
    NSString *tempSectionString = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    if ([self.treeArray containsObject:tempSectionString]) {
        [self.treeArray removeObject:tempSectionString];
    }else{
        [self.treeArray addObject:tempSectionString];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = [self.resourceManager getAllCitiesOfProvince:self.resourceManager.provinceArray[indexPath.section]][indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = SKY_BLUE;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *province = self.resourceManager.provinceArray[indexPath.section];
    NSString *city = [self.resourceManager getAllCitiesOfProvince:province][indexPath.row];
    NSString *subTitle = @"";
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    if ([province containsString:@"市"]) {
        subTitle = [NSString stringWithFormat:@"%@官微:%@\n%@区号:%@", province, [self.resourceManager getCityWB:city ofProvince:province], province, [self.resourceManager getCityCode:city ofProvince:province]];
    } else {
        NSString *cityWB = [self.resourceManager getCityWB:city ofProvince:province];
        NSString *provinceWB = [self.resourceManager getProvinceWB:province];
        if (!cityWB || [cityWB isEqualToString:@""]) {
            cityWB = @"(暂未开通)";
        }
        if (!provinceWB || [provinceWB isEqualToString:@""]) {
            provinceWB = @"(暂未开通)";
        }
        subTitle = [NSString stringWithFormat:@"%@官微:%@\n市官微:%@\n市区号:%@", province, provinceWB, cityWB, [self.resourceManager getCityCode:city ofProvince:province]];
    }
    [alert showInfo:self title:city subTitle:subTitle closeButtonTitle:@"确定" duration:0.0f];
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
