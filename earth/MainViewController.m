//
//  ViewController.m
//  earth
//
//  Created by Feicun on 15/3/12.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "MainViewController.h"
#import "UINavigationController+YRBackGesture.h"
#import "ImgButton.h"
#import "SCLAlertView.h"
#import "GoogleMobileAds/GADBannerView.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface MainViewController () <WBHttpRequestDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate> {
    CLLocationManager *locationManager;
    CSqlite *m_sqlite;
    GADBannerView *bannerView;
}

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) ImgButton *phoneBtn;
@property (strong, nonatomic) UIButton *weiboBtn;
@property (strong, nonatomic) ImgButton *locationBtn;
@property (strong, nonatomic) ImgButton *moreBtn;
@property (strong, nonatomic) MKMapView *m_mapView;
@property (strong, nonatomic) UILabel *m_locationName;

@property (strong, nonatomic) NSString *province;
@property (strong, nonatomic) NSString *city;

//@property (strong, nonatomic) AppDelegate *appDelegate;
//@property (strong, nonatomic) NSString *localPos;
//@property (strong, nonatomic) CustomAnnotation *tempAnnotation;
@end

@implementation MainViewController


- (void)callPhone:(UIButton *)sender {
//uid 1771696403
    //区号的问题
    NSString *areaCode = @"";
    if (self.province && self.city) {
        areaCode = [[ResourceManager sharedInstance] getCityCode:self.city ofProvince:self.province];
    }
    areaCode = [areaCode stringByAppendingString:@"12369"];
    NSString * str = [NSString stringWithFormat:@"tel:%@", areaCode];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

#pragma mark - 更多 评价/邮件
- (void)showInfo:(id)sender {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    [alert addButton:@"评价一下" target:self selector:@selector(scoreApp:)];
    [alert addButton:@"提点意见" target:self selector:@selector(sendEmail:)];
    [alert showInfo:self title:@"更多" subTitle:MORE_INFO closeButtonTitle:@"确定" duration:0.0f];
}

- (void)sendEmail:(id)sender {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"发送邮件错误" subTitle:@"当前系统版本不支持应用内发送邮件功能。" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    if (![mailClass canSendMail]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showError:self title:@"未设置邮件账户" subTitle:@"您尚未设置邮件账户。" closeButtonTitle:@"确定" duration:0.0f];
        return;
    }
    [self displayMailPicker];
}

- (void)displayMailPicker {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"穹顶之下"];
    //添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: @"shuxiajian@outlook.com"];
    [mailPicker setToRecipients: toRecipients];
    
    NSString *emailBody = @"<font color='red'></font>";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:mailPicker animated:YES completion:^{
        ;
    }];
    //    [self presentModalViewController: mailPicker animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    BOOL successed;
    [controller dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    //[self dismissModalViewControllerAnimated:YES];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"邮件发送取消";
            successed = NO;
            break;
        case MFMailComposeResultSaved:
            successed = YES;
            msg = @"邮件保存成功";
            break;
        case MFMailComposeResultSent:
            successed = YES;
            msg = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            successed = NO;
            msg = @"邮件发送失败";
            break;
        default:
            break;
    }
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    if (successed) {
        [alert showSuccess:self title:msg subTitle:@"" closeButtonTitle:@"确定" duration:0.0f];
    } else {
        [alert showError:self title:msg subTitle:@"" closeButtonTitle:@"确定" duration:0.0f];
    }
}
#warning url需要替换
-(void)scoreApp:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/biu-yi-ge-hao-wan-deapp/id946737127?mt=8"]];
}

#pragma mark - 微博

- (void)loginWeibo:(UIButton *)sender {
//    [self performSegueWithIdentifier:@"ToWeibo" sender:self];
    if (![WeiboSDK isWeiboAppInstalled]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"未安装微博客户端" subTitle:@"目前版本发布微博需要您的设备安装微博客户端。" closeButtonTitle:@"确定" duration:0.0f];
    } else {
        NSString *dateString = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBExpirationDate"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *destDate= [dateFormatter dateFromString:dateString];
        //NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBToken"];
        //NSString *curUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBCurUserID"];
        
        if (!dateString && [destDate compare:[NSDate date]] != NSOrderedAscending) {
            WBAuthorizeRequest *request = [WBAuthorizeRequest request];
            request.redirectURI = kRedirectURI;
            request.scope = @"all";
            request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                                 @"Other_Info_1": [NSNumber numberWithInt:123],
                                 @"Other_Info_2": @[@"obj1", @"obj2"],
                                 @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
            [WeiboSDK sendRequest:request];
        } else {
            [self performSegueWithIdentifier:@"ToWeibo" sender:self];
        }
    }
}

- (void)getTokenSuccess:(NSNotification *)notification {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBToken"];
    NSString *curUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"WBCurUserID"];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:token forKey:@"access_token"];
    [dic setObject:curUserId forKey:@"uid"];
    
    [WBHttpRequest requestWithAccessToken:token url:@"https://api.weibo.com/2/users/show.json"  httpMethod:@"get" params:dic delegate:self withTag:@"getUsername"];
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result {
    //NSString *title = nil;
    //UIAlertView *alert = nil;
    
    //title = NSLocalizedString(@"收到网络回调", nil);
    //alert = [[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"%@",result] delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
    NSError *err;
    if ([request.tag isEqualToString:@"getUsername"]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
        NSString *username = [dic objectForKey:@"screen_name"];
        [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"WBUsername"];
        if (![AVUser currentUser]) {
            AVUser *newUser = [AVUser user];
            newUser.username = username;
            newUser.password = @"123456";
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"%@", error.localizedDescription);
                //The request timed out.
                if (succeeded && !error) {
                    [self performSegueWithIdentifier:@"ToWeibo" sender:self];
                } else if ([error.localizedDescription isEqualToString:@"Username has already been taken"]) {
                    [AVUser logInWithUsernameInBackground:newUser.username password:newUser.password block:^(AVUser *user, NSError *error) {
                        NSLog(@"%@", user.username);
                        if ((succeeded && !error) || user) {
                            [self performSegueWithIdentifier:@"ToWeibo" sender:self];
                        }
                    }];
                } else {
                    [self performSegueWithIdentifier:@"ToWeibo" sender:self];
                }
            }];
        } else {
            [self performSegueWithIdentifier:@"ToWeibo" sender:self];
        }

    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error; {
    NSString *title = nil;
    UIAlertView *alert = nil;
    
    title = NSLocalizedString(@"请求异常", nil);
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:[NSString stringWithFormat:@"%@",error]
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"确定", nil)
                             otherButtonTitles:nil];
    [alert show];
    //[alert release];
}

#pragma mark - 定位

- (void)updateLocation:(UIButton *)sender {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusDenied) {
        //[locationManager requestWhenInUseAuthorization];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"请打开系统设置中“隐私→定位服务”，允许“穹顶之下”使用您的位置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showWarning:self title:@"未开启定位服务" subTitle:@"请打开系统设置中“隐私→定位服务”，允许“穹顶之下”使用您的位置。" closeButtonTitle:@"确定" duration:0.0f];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [locationManager startUpdatingLocation]; // 开始定位
        self.m_mapView.showsUserLocation = YES;
    }
}

// 定位成功时调用
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D mylocation = newLocation.coordinate;//手机GPS
    mylocation = [self zzTransGPS:mylocation];///火星GPS
    //显示火星坐标
    [self setMapPoint:mylocation];
    CLLocationCoordinate2D location = {29.583058, 106.624346};//{32.073029, 112.131153};//重庆{29.583058, 106.624346};//天津{39.126243, 117.140673};//上海{31.219767,121.475826};//北京{39.914271, 116.402544};//西藏{29.656908,91.128851};//天津市  上海市  北京市市辖区
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    //CLLocation *loc = [[CLLocation alloc] initWithCoordinate:mylocation altitude:newLocation.altitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy course:newLocation.course speed:newLocation.speed timestamp:newLocation.timestamp];
    
    /////////获取位置信息
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray* placemarks,NSError *error) {
        if (placemarks.count > 0) {
            
            CLPlacemark *plmark = [placemarks objectAtIndex:0];
             
            //NSString *country = plmark.country;
            self.province = plmark.administrativeArea;
            self.city = plmark.locality;
            
            NSString *locStr = @"您的位置: ";
            self.m_locationName.text = [locStr stringByAppendingString:plmark.name];
            
            [[NSUserDefaults standardUserDefaults] setObject:plmark.administrativeArea forKey:@"Province"];
            [[NSUserDefaults standardUserDefaults] setObject:plmark.locality forKey:@"City"];
            [[NSUserDefaults standardUserDefaults] setObject:plmark.name forKey:@"Address"];
            //self.localPos = plmark.name;
            [self setMapPoint:mylocation];
         }
         [locationManager stopUpdatingLocation];
         //NSLog(@"%@",placemarks);
         
     }];
}
// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"error: %@", error.localizedDescription);
    
}

//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
//    if (status == kCLAuthorizationStatusAuthorized ||
//        status == kCLAuthorizationStatusAuthorizedAlways ||
//        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
//        
//        locationManager = [[CLLocationManager alloc] init];
//        locationManager.delegate = self;
//        locationManager.distanceFilter=0.5;
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        [locationManager startUpdatingLocation];
//        self.m_mapView.showsUserLocation = YES;
//    }
//}

- (CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps {
    int TenLat = 0;
    int TenLog = 0;
    TenLat = (int)(yGps.latitude * 10);
    TenLog = (int)(yGps.longitude * 10);
    NSString *sql = [[NSString alloc]initWithFormat:@"select offLat,offLog from gpsT where lat=%d and log = %d", TenLat, TenLog];
    //NSLog(sql);
    sqlite3_stmt *stmtL = [m_sqlite NSRunSql:sql];
    int offLat = 0;
    int offLog = 0;
    while (sqlite3_step(stmtL) == SQLITE_ROW) {
        offLat = sqlite3_column_int(stmtL, 0);
        offLog = sqlite3_column_int(stmtL, 1);
    }
    
    yGps.latitude = yGps.latitude + offLat * 0.0001;
    yGps.longitude = yGps.longitude + offLog * 0.0001;
    return yGps;
}

- (void)setMapPoint:(CLLocationCoordinate2D)myLocation {
//    //需要保存 annotation 然后每次进来删除掉
//    [self.m_mapView removeAnnotation:self.tempAnnotation];
//    CustomAnnotation *m_poi = [[CustomAnnotation alloc] initWithCoords:myLocation andTitle:self.localPos Subtitle:nil];
//    NSLog(@"%@", m_poi.title);
//    self.tempAnnotation = m_poi;
//    //大头针显示位置
//    [self.m_mapView addAnnotation:m_poi];
//    [self.m_mapView selectAnnotation:m_poi animated:YES];
    
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center = myLocation;
    [self.m_mapView setZoomEnabled:YES];
    [self.m_mapView setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [self.m_mapView setRegion:theRegion animated:YES];
}

#pragma mark - 初始化

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SKY_BLUE;
    [self googleAD];
    [self buttonInit];
    [self mapInfoInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTokenSuccess:) name:@"GetToken" object:nil];
    
    [self.navigationController setEnableBackGesture:YES];
}

- (void)googleAD {
    // 在屏幕顶部创建标准尺寸的视图。
    // 在GADAdSize.h中对可用的AdSize常量进行说明。
    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    // 指定广告单元ID。
    bannerView.adUnitID = GOOGLE_AD_ID;//@"ca-app-pub-9981528462779788/6387264958";
    // 告知运行时文件，在将用户转至广告的展示位置之后恢复哪个UIViewController
    // 并将其添加至视图层级结构。
    bannerView.rootViewController = self;
    [self.view addSubview:bannerView];
    
    // 启动一般性请求并在其中加载广告。
    [bannerView loadRequest:[GADRequest request]];
}

- (void)mapInfoInit {
    m_sqlite = [[CSqlite alloc]init];
    [m_sqlite openSqlite];
    
    self.m_mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, bannerView.frame.origin.y + bannerView.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - MAIN_PADDING * 2 - BTN_SIZE - bannerView.frame.origin.y - bannerView.frame.size.height - 50)];
    [self.m_mapView setMapType:MKMapTypeStandard];
    self.m_mapView.showsUserLocation = YES;
    //self.m_mapView.layer.cornerRadius = BTN_SIZE / 2;
    [self.view addSubview:self.m_mapView];
    
    self.m_locationName = [[UILabel alloc] initWithFrame:CGRectMake(0, self.m_mapView.frame.origin.y + self.m_mapView.frame.size.height, SCREEN_WIDTH, 50)];
    self.m_locationName.numberOfLines = 2;
    self.m_locationName.text = @"您的位置: ";
    self.m_locationName.font = [UIFont boldSystemFontOfSize:17];
    self.m_locationName.textColor = [UIColor whiteColor];
    
    [self.view addSubview:self.m_locationName];
    
    //self.tempAnnotation = [[CustomAnnotation alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 0.5;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    } else if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        [locationManager startUpdatingLocation]; // 开始定位
        self.m_mapView.showsUserLocation = YES;
    }
}

- (void)buttonInit {
    self.phoneBtn = [[ImgButton alloc] initWithFrame:CGRectMake(MAIN_PADDING, SCREEN_HEIGHT -  MAIN_PADDING - BTN_SIZE, BTN_SIZE, BTN_SIZE) withImgName:@"phone"];
    [self.phoneBtn addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.phoneBtn];
    
    self.weiboBtn = [[ImgButton alloc] initWithFrame:CGRectMake(BTN_SIZE + 2 * MAIN_PADDING, SCREEN_HEIGHT -  MAIN_PADDING - BTN_SIZE, BTN_SIZE, BTN_SIZE) withImgName:@"weibo"];
    [self.weiboBtn addTarget:self action:@selector(loginWeibo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.weiboBtn];
    
    self.locationBtn = [[ImgButton alloc] initWithFrame:CGRectMake(2 * BTN_SIZE + 3 * MAIN_PADDING, SCREEN_HEIGHT -  MAIN_PADDING - BTN_SIZE, BTN_SIZE, BTN_SIZE) withImgName:@"location"];
    [self.locationBtn addTarget:self action:@selector(updateLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationBtn];

    self.moreBtn = [[ImgButton alloc] initWithFrame:CGRectMake(3 * BTN_SIZE + 4 * MAIN_PADDING, SCREEN_HEIGHT -  MAIN_PADDING - BTN_SIZE, BTN_SIZE, BTN_SIZE) withImgName:@"more"];
    [self.moreBtn addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.moreBtn];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


//暂时没用  用于设置地图大头针
//@implementation CustomAnnotation
//
//@synthesize coordinate, title, subtitle;
//
//- (id)initWithCoords:(CLLocationCoordinate2D) coords{
//    
//    self = [super init];
//    
//    if (self != nil) {
//        coordinate = coords;
//    }
//    
//    return self;
//}
//
//- (id)initWithCoords:(CLLocationCoordinate2D)coords andTitle:(NSString *)mapTitle Subtitle:(NSString *)mapSubtitle {
//    self = [super init];
//    
//    if (self != nil) {
//        coordinate = coords;
//        title = mapTitle;
//        subtitle = mapSubtitle;
//    }
//    
//    return self;
//}
//@end
